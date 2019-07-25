//
//  PlayAccompany.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/24.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa
import AVFoundation

class AccompanyController: NSViewController, NSComboBoxDelegate{
    
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var totalTimeLabel: NSTextField!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var playButton: NSButton!
//    @IBOutlet weak var volumeButton: NSButton!
    @IBOutlet weak var accompanyComboBox: NSComboBox!
    
    var audioPlayer: AVAudioPlayer!
    var accData: PracticeData!
    var timer: Timer!
    
    let entityName = "Practice"
    let nameForKey = "name"
    let scoreForKey = "score"
    let accompany1ForKey = "accompany1"
    let accompany2ForKey = "accompany2"
    let acc1NameForKey = "acc1_name"
    let acc2NameForKey = "acc2_name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.accompanyComboBox.delegate = self
    }
    
    func setAccompanyData(accData data: PracticeData) {
        self.accData = data
    }
    
    func dataForAccompanyComboBox(accData data: PracticeData) {
        self.accompanyComboBox.removeAllItems()
        if data.acc1_name == nil && data.acc2_name == nil {
            self.accompanyComboBox.stringValue = "还没有添加伴奏"
        } else {
            if data.acc1_name != nil {
                self.accompanyComboBox.addItem(withObjectValue: data.acc1_name)
            }
            if data.acc2_name != nil {
                self.accompanyComboBox.addItem(withObjectValue: data.acc2_name)
            }
            self.accompanyComboBox.selectItem(at: 0)
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        selectedAccompany()
    }
    
    func selectedAccompany() {
        if let nameStr = self.accompanyComboBox.objectValueOfSelectedItem as? String {
            if nameStr == accData.acc1_name {
                setAudioPlayer(accompany: accData.accompany1)
            } else if nameStr == accData.acc2_name {
                setAudioPlayer(accompany: accData.accompany2)
            }
        }
    }
    
    func setAudioPlayer(accompany acc: NSData) {
        
        do {
            self.audioPlayer = try AVAudioPlayer(data: acc as Data)
        } catch {
            print("audioPlayer init ERROR!")
            return
        }
            
        if (self.audioPlayer != nil) {
            self.audioPlayer.volume = self.volumeSlider.floatValue / 100
            self.timeSlider.integerValue = 0
            self.timeSlider.maxValue = self.audioPlayer.duration
            self.currentTimeLabel.stringValue = "00:00"
            self.totalTimeLabel.stringValue = self.changeSecToMin(seconds:  self.audioPlayer.duration)
        }
        
    }

    func changeSecToMin(seconds totalSec: Double) -> String {
        let min: Int = Int(totalSec) / 60
        let sec = Int(totalSec) % 60
        var minStr: String!
        var secStr: String!
        if min < 10 {
            minStr = "0" + String(min)
        } else {
            minStr = String(min)
        }
        if sec < 10 {
            secStr = "0" + String(sec)
        } else {
            secStr = String(sec)
        }
        let str = minStr + ":" + secStr
        return str
    }
    
    private func openPanelToSelectAccompany(accompanyData data: PracticeData) {
        var createAccData = data
        let fileTypes = ["mp3", "wav", "AIFF", "AIFC", "Sd2f", "NeXT", "MPG3",
                         "MPG2", "MPG1", "ac-3", "adts", "mp4f","m4af", "m4bf",
                         "caff", "3gp2", "3gpp"]
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = fileTypes
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectedURL = openPanel.url!
                if (data.acc1_name != nil) {
                    createAccData.accompany1 = NSData(contentsOf: selectedURL)
                } else if (data.acc2_name != nil) {
                    createAccData.accompany2 = NSData(contentsOf: selectedURL)
                }

                if self.updateAccompanyToCoreData(accompanyData: createAccData, updateOrDelete: true) == false {
                    alertRemind(message: "添加失败！")
                    return
                } else {
                    if (createAccData.acc1_name != nil) {
                        self.accompanyComboBox.addItem(withObjectValue: createAccData.acc1_name)
                        
                    } else if (createAccData.acc2_name != nil) {
                        self.accompanyComboBox.addItem(withObjectValue: createAccData.acc2_name)
                    }
                    self.accData = createAccData
                    self.accompanyComboBox.selectItem(at: 0)
                    self.selectedAccompany()
                }
            }
        }
    }
    
    func updateAccompanyToCoreData(accompanyData data: PracticeData, updateOrDelete op: Bool) -> Bool {
        guard let applegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = applegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", data.name)
        do {
            let object = try managedContext.fetch(fetchRequest)
            let update = object[0] as! NSManagedObject
            if (data.acc1_name != nil) {
                if op {
                    update.setValue(data.acc1_name, forKey: self.acc1NameForKey)
                    update.setValue(data.accompany1, forKey: self.accompany1ForKey)
                } else {
                    update.setValue(nil, forKey: self.acc1NameForKey)
                    update.setValue(nil, forKey: self.accompany1ForKey)
                }
            } else if (data.acc2_name != nil) {
                if op {
                    update.setValue(data.acc2_name, forKey: self.acc2NameForKey)
                    update.setValue(data.accompany2, forKey: self.accompany2ForKey)
                } else {
                    update.setValue(nil, forKey: self.acc2NameForKey)
                    update.setValue(nil, forKey: self.accompany2ForKey)
                }
            }
            do {
                try managedContext.save()
            } catch {
                return false
            }
        } catch {
            return false
        }
        return true
        
    }
    
    @objc func tickDown() {
        self.timeSlider.integerValue += 1
        self.currentTimeLabel.stringValue = self.changeSecToMin(seconds: self.timeSlider.doubleValue)
        if timeSlider.integerValue == Int(timeSlider.maxValue) {
            timer.invalidate()
            timeSlider.integerValue = 0
            self.currentTimeLabel.stringValue = "00:00"
            self.playButton.state = NSControl.StateValue.off
            self.playButton.image = NSImage(named: "play")
        }
    }
    
    @IBAction func addAccompany(_ sender: NSButton) {
        var createAccData = PracticeData()
        var enterStr: String!
        createAccData.name = self.accData.name
        if (accData.acc1_name != nil && accData.acc2_name != nil) {
            alertRemind(message: "伴奏数量达到上限！")
            return
        } else {
            enterStr = enterTextFieldAlert(message: "为曲谱添加伴奏", infomative: "请输入名称：")
            if (accData.acc1_name == nil) {
                createAccData.acc1_name = enterStr
            } else if (accData.acc2_name == nil) {
                createAccData.acc2_name = enterStr
            }
        }
        
        if (enterStr != nil)
        {
            openPanelToSelectAccompany(accompanyData: createAccData)
        }
        
    }
    
    
    @IBAction func deleteAccompany(_ sender: NSButton) {
        if self.accompanyComboBox.numberOfItems == 0 { return }
        if ensureAlert(message: "删除伴奏", infomativeText: "你确定要删除该伴奏吗？") {
            var data = PracticeData()
            data.name = self.accData.name
            let str = accompanyComboBox.objectValueOfSelectedItem as! String
            if str == self.accData.acc1_name {
                data.acc1_name = self.accData.acc1_name
                data.acc2_name = nil
            } else if str == self.accData.acc2_name {
                data.acc2_name = self.accData.acc2_name
                data.acc1_name = nil
            }
            if updateAccompanyToCoreData(accompanyData: data, updateOrDelete: false) {
                alertRemind(message: "删除成功！")
                self.accompanyComboBox.removeItem(at: self.accompanyComboBox.indexOfSelectedItem)
                if self.accompanyComboBox.numberOfItems == 0 {
                    self.accompanyComboBox.stringValue = "还没有添加伴奏"
                } else {
                    self.accompanyComboBox.selectItem(at: 0)
                }
            } else {
                alertRemind(message: "删除失败！")
            }
        }
    }
    
    @IBAction func playAccompany(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.playButton.image = NSImage(named: "stop")
            if audioPlayer != nil {
                self.audioPlayer.play()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.tickDown), userInfo: nil, repeats: true)
            } else {
                alertRemind(message: "还没有添加伴奏！")
                self.playButton.state = NSControl.StateValue.off
                self.playButton.image = NSImage(named: "play")
            }
        } else {
            self.audioPlayer.stop()
            timer.invalidate()
            self.playButton.image = NSImage(named: "play")
        }
    }
    
    @IBAction func adjustVolume(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            volumeLabel.isHidden = false
            volumeSlider.isHidden = false
        } else if sender.state == NSControl.StateValue.off {
            volumeLabel.isHidden = true
            volumeSlider.isHidden = true
        }
    }
    
    @IBAction func volumeSliderDidChange(_ sender: NSSlider) {
                volumeLabel.stringValue = String(sender.integerValue) + "%"
        if audioPlayer != nil {
            audioPlayer.volume = sender.floatValue / 100
        }
    }
    
    @IBAction func playTimeControl(_ sender: NSSlider) {
        self.audioPlayer.currentTime = self.timeSlider.doubleValue
        if self.timeSlider.doubleValue == self.timeSlider.maxValue {
            self.timeSlider.integerValue = 0
        }
    }
    
    
}
