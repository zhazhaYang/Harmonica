//
//  PlayAccompany.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/24.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa
import AVFoundation

class PlayAccompany: NSViewController, NSControlTextEditingDelegate{
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var volumeButton: NSButton!
    @IBOutlet weak var accompanyComboBox: NSComboBox!
    
    var audioPlayer: AVAudioPlayer!
    var accData: PracticeData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    
    }
    
    func initAccompanyData(accData data:PracticeData) {
        self.accData = data
    }
    
    func dataForAccompanyComboBox() {
        if self.accData.accompany1 == nil && self.accData.accompany2 == nil {
            self.accompanyComboBox.stringValue = "还没有添加伴奏"
        } else {
            if self.accData.accompany1 != nil {
                self.accompanyComboBox.addItem(withObjectValue: self.accData.acc1_name)
            }
            if accData.accompany2 != nil {
                self.accompanyComboBox.addItem(withObjectValue: self.accData.acc2_name)
            }
            self.accompanyComboBox.selectItem(at: 0)
        }
    }
    
    func initAudioPlayer() {
        if let nameStr = (self.accompanyComboBox.objectValueOfSelectedItem as? String) {
            if nameStr == accData.acc1_name {
                do {
                    audioPlayer = try AVAudioPlayer(data: accData.accompany1 as Data)
                } catch {
                    print("audioPlayer init ERROR!")
                }
            } else {
                do {
                    audioPlayer = try AVAudioPlayer(data: accData.accompany2 as Data)
                } catch {
                    print("audioPlayer init ERROR!")
                }
            }
        }
    }

    func alertRemind(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "我知道了")
        alert.runModal()
    }
    
    @IBAction func playAccompany(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.audioPlayer.play()
        } else {
            self.audioPlayer.stop()
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
    }
    
    
}
