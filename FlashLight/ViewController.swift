//
//  ViewController.swift
//  FlashLight
//
//  Created by Omer Faruk ZORLU on 31/08/16.
//  Copyright © 2016 Omer Faruk ZORLU. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private var device : AVCaptureDevice!
    private var levels = [String : Float]()
    private var lastSelectedRow : Int?
    
    @IBOutlet weak var uiPicker: UIPickerView!

    private func setFlashOrTorchWithRowIndex(rowIndex : Int) -> Void {
        self.lastSelectedRow = rowIndex
        self.uiPicker.selectRow(rowIndex, inComponent: 0, animated: true)
        self.setFlashOrTorchWithValue(self.getSelectedRowKey(rowIndex)!.1)
    }
    
    private func setFlashOrTorchWithValue(value: Float) -> Void {
        if(self.isTorcModeAvaliable()){
            do {
                try getDevice()!.lockForConfiguration()
                do {
                    if(value>0){
                        try getDevice()!.setTorchModeOnWithLevel(min(value, 1.0))
                    }
                    else{
                        getDevice()!.torchMode = AVCaptureTorchMode.Off
                    }
                } catch {
                    print(error)
                }
                
                getDevice()!.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    private func getSelectedRowKey(rowIndex : Int) -> (String, Float)?
    {
        var i = 0
        for item in levels.sortedKeysByValue(<) {
            if(i == rowIndex)
            {
                return (item, levels[item]!)
            }
            i += 1
        }
        
        return nil
    }
    
    private func getLevels() -> [String : Float] {
        var levels : [String : Float]
        
        if(self.isTorcModeAvaliable()){
            levels = [
                        "Off" : 0.0,
                        "10%" : 0.1,
                        "20%" : 0.2,
                        "30%" : 0.3,
                        "40%" : 0.4,
                        "50%" : 0.5,
                        "60%" : 0.6,
                        "70%" : 0.7,
                        "80%" : 0.8,
                        "90%" : 0.9,
                        "100%" : 1.0
                    ]
        }
        else
        {
            levels = [
                        "Off" : 0.0,
                        "On" : 1.0
                    ]
        }
        
        return levels
    }
    
    private func getDevice() -> AVCaptureDevice? {
        if (self.device == nil){
            self.device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        }
        
        return device
    }
    
    private func isTorcModeAvaliable() -> Bool {
        return (getDevice() != nil && (getDevice()!).hasTorch && (getDevice()!).torchAvailable)
    }
    
    // PickerView - begin
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.levels.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.getSelectedRowKey(row)?.0
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.setFlashOrTorchWithRowIndex(row)
    }
    
    // PickerView - end
    
    
    func applicationBecameActive(notification: NSNotification){
        if(lastSelectedRow != nil) {
            setFlashOrTorchWithRowIndex(lastSelectedRow!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        levels = self.getLevels()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.applicationBecameActive),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
    }
    
    deinit {
        if(device != nil)
        {
            device = nil
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension Dictionary {
    
    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sort(isOrderedBefore)
    }
    
    func sortedKeysByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
}

