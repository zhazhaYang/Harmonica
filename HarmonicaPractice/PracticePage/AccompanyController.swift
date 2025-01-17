//
//  PlayAccompany.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/24.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa
import AVFoundation

class AccompanyController: NSViewController, NSComboBoxDelegate {
    
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var totalTimeLabel: NSTextField!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var playButton: NSButton!
//    @IBOutlet weak var volumeButton: NSButton!
    @IBOutlet weak var accompanyComboBox: NSComboBox!
    
    @IBOutlet weak var recorderButton: NSButton!
    @IBOutlet weak var recordTimeLabel: NSTextField!
    
    
    var audioPlayer: AVAudioPlayer!
    var recorder: AVAudioRecorder!
    
    var scoreName: String!
    
    var playTimer: Timer!
    var recordTimer: Timer!
    var timeCounter: Double!
    
    let entityName = "Accompany"
    let scoreNameForKey = "score_name"
    let accNameForKey = "acc_name"
    let accompanyForKey = "accompany"
    
    let recordEntityName = "Records"
    let recordNameForKey = "record_name"
    let recordForKey = "record"
    
    let noneAcc = "清吹"
    
    var recordsPath: String!
    var recordSetting: [String: Any]!
    var saveRecordName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        accompanyComboBox.delegate = self
        
        recordsPath = NSHomeDirectory() + "/Documents/Records"
        recordSetting = [AVSampleRateKey: NSNumber(value: 44100.0),//采样率
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),//音频格式
            AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
            AVNumberOfChannelsKey: NSNumber(value: 2),//通道数
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)//录音质量
        ]
    }
    

    
    @IBAction func addAccompany(_ sender: NSButton) {
        if scoreName == nil {
            alertRemind(message: "请先添加曲谱！")
            return
        }
        var createAccData = AccompanyData()
        var exist = [AccompanyData]()
        var enterStr: String!
        createAccData.score_name = scoreName
        exist = selectAccompanyDataFrom(scoreName: self.scoreName)
        if (exist.count == 2) {
            alertRemind(message: "伴奏数量达到上限！")
            return
        } else {
            enterStr = enterTextFieldAlert(message: "为曲谱添加伴奏", infomative: "请输入名称：")
            if selectOneAccompany(scoreName: scoreName, accName: enterStr) != nil {
                alertRemind(message: "该名字与现有的伴奏名字重复了！")
                return
            }
            createAccData.acc_name = enterStr
        }
        
        if (createAccData.acc_name != nil && createAccData.score_name != nil)
        {
            openPanelToSelectAccompany(accompanyData: createAccData)
        }
        
    }
    
    
    @IBAction func deleteAccompany(_ sender: NSButton) {
        if self.accompanyComboBox.numberOfItems == 0 { return }
        let str = accompanyComboBox.objectValueOfSelectedItem as! String
        if str == noneAcc { return }
        if ensureAlert(message: "删除伴奏", infomativeText: "你确定要删除该伴奏吗？") {
            if deleteAccompanyByName(scoreName: scoreName, accompanyName: str) {
                alertRemind(message: "删除成功！")
                self.accompanyComboBox.removeItem(at: self.accompanyComboBox.indexOfSelectedItem)
                if self.accompanyComboBox.numberOfItems == 1 {
                    self.accompanyComboBox.removeItem(at: 0)
                    self.setAudioPlayer(accompany: nil)
                } else {
                    self.accompanyComboBox.selectItem(at: 1)
                }
            } else {
                alertRemind(message: "删除失败, 稍后再试！")
            }
        }
        
        
    }
    
    @IBAction func playAccompany(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.playButton.image = NSImage(named: "stop")
            if audioPlayer != nil {
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
                self.audioPlayer.currentTime = self.timeSlider.doubleValue
                playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.playTickDown), userInfo: nil, repeats: true)
            } else {
                //alertRemind(message: "还没有添加伴奏！")
                self.playButton.state = NSControl.StateValue.off
                self.playButton.image = NSImage(named: "play")
            }
        } else {
            if audioPlayer != nil {
                self.audioPlayer.stop()
            }
            if playTimer != nil {
                playTimer.invalidate()
            }
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
        if timeSlider.maxValue == 0 {
            return
        }
        self.audioPlayer.currentTime = self.timeSlider.doubleValue
        currentTimeLabel.stringValue = changeSecToMin(seconds:timeSlider.doubleValue)
        if self.timeSlider.doubleValue == self.timeSlider.maxValue {
            self.timeSlider.integerValue = 0
            currentTimeLabel.stringValue = "00:00"
            if playTimer != nil {
                playTimer.invalidate()
            }
        }
    }
    
    @IBAction func recordAction(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            saveRecordName = enterTextFieldAlert(message: "先为录音文件取个名字", infomative: "输入:")
            if saveRecordName == nil {
                recorderButton.state = NSControl.StateValue.off
                return
            }
            if findRecordByName(scoreName: scoreName, recordName: saveRecordName) {
                alertRemind(message: "该录音名字与已存在的录音重复了！")
                recorderButton.state = NSControl.StateValue.off
                return
            }
            
            
            if !recordSound(recordName: saveRecordName!) {
                alertRemind(message: "录音初始化失败，请稍后再尝试！")
                recorderButton.state = NSControl.StateValue.off
                return
            }
            recorder.record()
            recorderButton.title = "停止录音"
            playButton.state = NSControl.StateValue.on
            timeSlider.integerValue = 0
            currentTimeLabel.stringValue = "00:00"
            playAccompany(playButton)
            recordTimeLabel.isHidden = false
            recordTimeLabel.stringValue = "00:00"
            timeCounter = 0
            recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.recordTickDown), userInfo: nil, repeats: true)
            playButton.isEnabled = false
        } else {
            if recorder != nil {
                if recorder.isRecording {
                    recorder.stop()
                }
            } else {
                return
            }
            recorderButton.title = "开始录音"
            if playTimer != nil {
                playTimer.invalidate()
            }
            recordTimeLabel.isHidden = true
            playButton.isEnabled = true
            playButton.state = NSControl.StateValue.off
            playAccompany(playButton)
            if recordTimer != nil {
                recordTimer.invalidate()
            }
            
            let path = recordsPath + "/" + saveRecordName + ".m4a"
            let synPath = recordsPath!
            if FileManager.default.fileExists(atPath: path) {
                var saveUrl: URL!
                let str = accompanyComboBox.objectValueOfSelectedItem as? String
                if str == "清吹" || str == nil {
                    saveUrl = URL(fileURLWithPath: path)
                } else {
                    if let url = synthesisAudio(recordPath: path, savePath: synPath) {
                        saveUrl = url
                    } else {
                        alertRemind(message: "录音保存失败了！")
                    }
                }
                
                if saveRecordToCoreData(recordUrl: saveUrl, recordName: saveRecordName) {
                    alertRemind(message: "录音成功啦！请到[我的录音]查看！")
                } else {
                    alertRemind(message: "录音保存失败了！")
                }
                
            } else {
                alertRemind(message: "录音保存失败了！")
            }
            
            do {
                try FileManager.default.removeItem(atPath: recordsPath)
            } catch {
                print("删除本地录音文件夹失败了！")
            }
            saveRecordName = nil
        }
        
    }
    
    
}

//MARK: -  Accompany Base Fuction
extension AccompanyController {
    func initAccComboBox(scoreName score_name: String) {
        self.scoreName = score_name
        dataForAccompanyComboBox(scoreName: score_name)
    }
    
    func dataForAccompanyComboBox(scoreName score: String) {
        let accData = selectAccompanyDataFrom(scoreName: score)
        self.accompanyComboBox.removeAllItems()
        if accData.count == 0 {
            self.setAudioPlayer(accompany: nil)
        } else {
            self.accompanyComboBox.addItem(withObjectValue: noneAcc)
            for acc in accData {
                self.accompanyComboBox.addItem(withObjectValue: acc.acc_name)
            }
            self.accompanyComboBox.selectItem(at: 1)
            
        }
        
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        selectedAccompany()
    }
    
    func selectedAccompany() {
        if self.accompanyComboBox.indexOfSelectedItem != -1 {
            if let nameStr = self.accompanyComboBox.objectValueOfSelectedItem as? String {
                if nameStr == noneAcc {
                    setAudioPlayer(accompany: nil)
                } else {
                    if let accData = selectOneAccompany(scoreName: scoreName, accName: nameStr) {
                        setAudioPlayer(accompany: accData.accompany)
                    }
                }
            }
        } else {
            setAudioPlayer(accompany: nil)
        }
    }
    
    func setAudioPlayer(accompany acc: NSData?) {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                audioPlayer = nil
                playButton.state = NSControl.StateValue.off
                playButton.image = NSImage(named: "play")
                if playTimer != nil {
                    playTimer.invalidate()
                }
            }
        }
        if acc != nil {
            do {
                self.audioPlayer = try AVAudioPlayer(data: acc! as Data)
            } catch {
                print("audioPlayer init ERROR!")
                return
            }
            
            if (self.audioPlayer != nil) {
                self.audioPlayer.volume = self.volumeSlider.floatValue / 100
                self.timeSlider.integerValue = 0
                self.timeSlider.maxValue = self.audioPlayer.duration
                self.currentTimeLabel.stringValue = "00:00"
                self.totalTimeLabel.stringValue = changeSecToMin(seconds:  self.audioPlayer.duration)
                self.playButton.isEnabled = true
            }
        } else {
            self.audioPlayer = nil
            self.timeSlider.integerValue = 0
            self.timeSlider.maxValue = 0
            self.currentTimeLabel.stringValue = "00:00"
            self.totalTimeLabel.stringValue = "00:00"
            self.playButton.isEnabled = false
            self.accompanyComboBox.stringValue = "还没有添加伴奏"
        }
        
    }
    
    
    
    
    private func openPanelToSelectAccompany(accompanyData data: AccompanyData) {
        var createAccData = data
        let fileTypes = ["mp3", "wav", "m4a"]
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = fileTypes
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectedURL = openPanel.url!
                createAccData.accompany = NSData(contentsOf: selectedURL)
                if self.addAccompanyDataTo(accompanyData: createAccData) == false {
                    alertRemind(message: "添加失败！")
                    return
                } else {
                    if self.accompanyComboBox.numberOfItems == 0 {
                        self.accompanyComboBox.addItem(withObjectValue: self.noneAcc)
                    }
                    self.accompanyComboBox.addItem(withObjectValue: createAccData.acc_name)
                    self.accompanyComboBox.selectItem(at: 1)
                }
            }
        }
    }
    
    @objc func playTickDown() {
        self.timeSlider.integerValue += 1
        self.currentTimeLabel.stringValue = changeSecToMin(seconds: self.timeSlider.doubleValue)
        if timeSlider.integerValue == Int(timeSlider.maxValue) {
            playTimer.invalidate()
            timeSlider.integerValue = 0
            self.currentTimeLabel.stringValue = "00:00"
            self.playButton.state = NSControl.StateValue.off
            self.playButton.image = NSImage(named: "play")
        }
    }
    
    @objc func recordTickDown() {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                recordTimeLabel.stringValue = currentTimeLabel.stringValue
                return
            }
        }
        timeCounter = timeCounter + 1
        recordTimeLabel.stringValue = changeSecToMin(seconds: timeCounter)
    }
    
}


//MARK: - Accompany Core Data
extension AccompanyController {
    
    func selectOneAccompany(scoreName score_name: String, accName acc_name: String) -> AccompanyData? {
        guard let appdelegate = NSApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "score_name = %@ and acc_name = %@ ", score_name, acc_name)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            if fetched.count > 0 {
                var accData = AccompanyData()
                let selected = fetched[0] as? NSManagedObject
                accData.score_name = selected?.value(forKey: scoreNameForKey) as? String
                accData.acc_name = selected?.value(forKey: accNameForKey) as? String
                accData.accompany = selected?.value(forKey: accompanyForKey) as? NSData
                return accData
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func selectAccompanyDataFrom(scoreName score_name: String) -> [AccompanyData] {
        var accData = [AccompanyData]()
        guard  let appdelegate = NSApplication.shared.delegate as? AppDelegate else {
            return accData
        }
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: " score_name = %@ ", score_name)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            for data in fetched as! [NSManagedObject] {
                var acc = AccompanyData()
                acc.score_name = data.value(forKey: scoreNameForKey) as? String
                acc.acc_name = data.value(forKey: accNameForKey) as? String
                acc.accompany = data.value(forKey: accompanyForKey) as? NSData
                accData.append(acc)
            }
        } catch let error as NSError {
            print("Could not fetch accompany. \(error), \(error.userInfo)")
        }
        return accData
    }
    
    func addAccompanyDataTo(accompanyData data: AccompanyData) -> Bool {
        guard let appdelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appdelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: managedContext)
        
        let setData = NSManagedObject(entity: entity!, insertInto: managedContext)
        setData.setValue(data.score_name, forKey: self.scoreNameForKey)
        setData.setValue(data.acc_name, forKey: self.accNameForKey)
        setData.setValue(data.accompany, forKey: self.accompanyForKey)
        
        do {
            try managedContext.save()
        } catch {
            return false
        }
        
        return true
    }
    
    func deleteAccompanyByName(scoreName sname: String, accompanyName name: String) -> Bool {
        guard let applegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = applegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "score_name = %@ and acc_name = %@", sname, name)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            let deleteObject = fetched[0] as! NSManagedObject
            managedContext.delete(deleteObject)
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
    
    func deleteAccompanyByScore(scoreName name: String) -> Bool {
        guard let applegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = applegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "score_name = %@", name)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            for deleteObject in fetched as! [NSManagedObject] {
                managedContext.delete(deleteObject)
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
    
}


//MARK: - Recorder
extension AccompanyController {
    func recordSound(recordName name: String) -> Bool {
        if self.scoreName != nil {
            var path = recordsPath!
            do {
                try FileManager.default.createDirectory(atPath:path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建录音文件夹失败！")
                return false
            }
            path = path + "/" + name + ".m4a"
            let url = URL(fileURLWithPath: path)
            do {
                recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            } catch {
                print("录音初始化失败！")
                return false
            }
            if recorder == nil {
                print("录音初始化失败！")
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    func saveRecordToCoreData(recordUrl url: URL, recordName rName: String) -> Bool {
        guard let appdelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appdelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: recordEntityName, in: managedContext)
        let object = NSManagedObject(entity: entity!, insertInto: managedContext)
        let record = NSData(contentsOf: url)
        if (record == nil) || (scoreName == nil){
            return false
        }
        object.setValue(scoreName, forKey: scoreNameForKey)
        object.setValue(rName, forKey: recordNameForKey)
        object.setValue(record, forKey: recordForKey)
        
        do {
            try managedContext.save()
        } catch {
            return false
        }
        
        return true
    }
    
    func findRecordByName(scoreName sname: String, recordName rname: String) -> Bool {
        guard let appdelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let contextManaged = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: recordEntityName)
        fetchRequest.predicate = NSPredicate(format: "score_name = %@ and record_name = %@", sname, rname)
        do {
            let fetched = try contextManaged.fetch(fetchRequest)
            if fetched.count == 0 {
                return false
            } else {
                return true
            }
        } catch {
            return false
        }
    }
    
    func synthesisAudio(recordPath rPath: String, savePath sPath: String) -> URL? {
        let rUrl = URL(fileURLWithPath: rPath)
        var aUrl: URL!
        let str = accompanyComboBox.objectValueOfSelectedItem as? String
        if let acc = selectOneAccompany(scoreName: scoreName, accName: str!) {
            if let type =  mimeType(for: acc.accompany as Data) {
                let newPath = sPath + "/acc" + type
                aUrl = URL(fileURLWithPath: newPath)
                acc.accompany.write(to: aUrl, atomically: true)
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        let recordAsset = AVURLAsset(url: rUrl, options: nil)
        
        let accompanyAsset = AVURLAsset(url: aUrl, options: nil)
        let composition: AVMutableComposition = AVMutableComposition()
        let appendedAudioTrack1: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let appendedAudioTrack2: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)!
        let assetTrack1: AVAssetTrack = recordAsset.tracks(withMediaType: AVMediaType.audio)[0]
        let assetTrack2: AVAssetTrack = accompanyAsset.tracks(withMediaType: AVMediaType.audio)[0]
        let timeRange1 = CMTimeRangeMake(start: CMTime.zero, duration: recordAsset.duration)
        let timeRange2 = CMTimeRangeMake(start: CMTime.zero, duration: accompanyAsset.duration)
        do {
            try appendedAudioTrack1.insertTimeRange(timeRange1, of: assetTrack1, at: CMTime.zero)
            try appendedAudioTrack2.insertTimeRange(timeRange2, of: assetTrack2, at: CMTime.zero)
        } catch {
            print("拼接失败了！")
            return nil
        }
        
        let export: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        
        let path = recordsPath + "/synthesis.m4a"
        let url = URL(fileURLWithPath: path)
        export.outputURL = url
        export.outputFileType = AVFileType.m4a
        let show = WaitingTextHUD()
        if let view = NSApplication.shared.keyWindow?.contentView {
            show.showWaitingWithText(size: view.frame.size ,text: "合成录音中", autoRemove: true)
        }
        var signal = true
        export.exportAsynchronously (
            completionHandler: { () -> Void in
                print("export...", export)
                switch export.status {
                case .failed:
                    print("导出失败了！")
                    break
                case .completed:
                    print("导出成功！")
                    break
                case .waiting:
                    print("正在导出中...")
                    break
                default:
                    break
                }
                signal = false
        })
        while signal {}
        show.removeHUD(nil)
        return url
    }
    
    func mimeType(for data: Data) -> String? {
        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)
        switch b {
        case 0x52:
            return ".wav"
        case 0x49:
            return ".mp3"
        default:
            return nil
        }
    }
    
    
}
