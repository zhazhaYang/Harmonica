//
//  SoundRecordController.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/25.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa
import AVFoundation

class SoundRecordController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var muteButton: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var endTimeLabel: NSTextField!
    @IBOutlet weak var currentTimeSlider: NSSlider!
    @IBOutlet weak var recordNameLabel: NSTextField!
    
    
    var root = [RootScoreName]()
    
    let entityName = "Records"
    let scoreNameForKey = "score_name"
    let recordNameForKey = "record_name"
    let recordForKey = "record"
    
    var audioPlayer: AVAudioPlayer!
    
    var playTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setSoundRecordData()
        outlineView.dataSource = self
        outlineView.delegate = self
    }
    
    override func viewWillAppear() {
        setSoundRecordData()
        outlineView.reloadData()
    }
    
    func setSoundRecordData() {
        if let records = getRecords() {
            self.root = records
        }
    }
    
    @IBAction func playAction(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            if audioPlayer == nil {
                playButton.state = NSControl.StateValue.off
                return
            }
            beginPlay()
            playButton.image = NSImage(named: NSImage.touchBarPauseTemplateName)
        } else {
            stopPlay()
            playButton.image = NSImage(named: NSImage.touchBarPlayTemplateName)
        }
    }
 
    @IBAction func muteAction(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            muteButton.image = NSImage(named: NSImage.touchBarAudioOutputMuteTemplateName)
            if audioPlayer != nil {
                audioPlayer.volume = 0.0
            }
        } else {
            muteButton.image = NSImage(named: NSImage.touchBarAudioOutputVolumeHighTemplateName)
            if audioPlayer != nil {
                audioPlayer.volume = volumeSlider.floatValue / 100
            }
        }
    }
    
    @IBAction func volumeSliderAction(_ sender: NSSlider) {
        if audioPlayer != nil {
            audioPlayer.volume = volumeSlider.floatValue / 100
        }
        volumeLabel.stringValue = String(volumeSlider.integerValue) + "%"
    }
    
    @IBAction func currentPlayTimeAction(_ sender: NSSlider) {
        if currentTimeSlider.integerValue == Int(currentTimeSlider.maxValue) {
            initPlay()
            endPlay()
        } else {
            if audioPlayer != nil {
                audioPlayer.currentTime = currentTimeSlider.doubleValue
            }
            currentTimeLabel.stringValue = changeSecToMin(seconds: currentTimeSlider.doubleValue)
            
        }
    }
    
}

//MARK: - Records Core Data
extension SoundRecordController {
    func getRecords() -> [RootScoreName]? {
        var records = [RootScoreName]()
        guard let appdelegate = NSApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            for data in fetched as! [NSManagedObject] {
                var recordsInScore = [LeafRecord]()
                if let scoreName = data.value(forKey: scoreNameForKey) as? String {
                    var jud = true
                    for n in records {
                        if n.scoreName == scoreName {
                            jud = false
                        }
                    }
                    if jud {
                        let aScore = RootScoreName(scoreName: scoreName)
                        recordsInScore = getRecordsByScoreName(scoreName: aScore.scoreName)!
                        if recordsInScore .isEmpty {
                            return nil
                        }
                        aScore.children = recordsInScore
                            records.append(aScore)
                    }
                }
            }
        } catch {
            return nil
        }
        return records
    }
    
    func getRecordsByScoreName(scoreName sname: String) -> [LeafRecord]? {
        var records = [LeafRecord]()
        guard let appdelegate = NSApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: " score_name = %@ ", sname)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            for data in fetched as! [NSManagedObject] {
                let recordName = data.value(forKey: recordNameForKey) as? String
                let aRecordName = LeafRecord(recordName: recordName!)
                records.append(aRecordName)
            }
        } catch {
            return nil
        }
        return records
    }
    
    func getARecordByName(score sname: String, record rname: String) -> NSData? {
        guard let appdelegate = NSApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "score_name = %@ and record_name = %@", sname, rname)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            let object = fetched[0] as? NSManagedObject
            let data = object?.value(forKey: recordForKey) as? NSData
            return data
        } catch {
            return nil
        }
    }
    
}


//MARK: - Records List Show By OutlineView
extension SoundRecordController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? RootScoreName {
            return item.children.count
        }
        return root.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? RootScoreName {
            return item.children[index]
        }
        return root[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is RootScoreName
    }

}

extension SoundRecordController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell: NSTableCellView!
        if item is RootScoreName {
            cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = (item as! RootScoreName).scoreName
        } else if item is LeafRecord {
            cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = (item as! LeafRecord).recordName
        }
        return cell
    }
    
    
    func outlineViewSelectionIsChanging(_ notification: Notification) {
        
        if let name = getSelectedName() {
            for recordName in name.values {
                recordNameLabel.stringValue = recordName
            }
            endPlay()
        } else {
            let row = outlineView.selectedRow
            outlineView.deselectRow(row)
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if !setAudioPlayer() {
            print("录音播放出始化失败了！")
        }
    }
    

}


//MARK: - Play Part
extension SoundRecordController {
    
    func setAudioPlayer() -> Bool {
        if let record = getSelectedRecord() {
            do {
                audioPlayer = try AVAudioPlayer(data: record as Data)
            } catch {
                return false
            }
            initPlay()
            return true
        }
        return false
    }
    
    func getSelectedRecord() -> NSData? {
        if let nameDic = getSelectedName() {
            for (scoreName, recordName) in nameDic {
                if let data = getARecordByName(score: scoreName, record: recordName) {
                    return data
                } else {
                    return nil
                }
            }
        }
        return nil
    }
    
    func getSelectedName() -> [String: String]? {
        let row = outlineView.selectedRow
        let count = outlineView.numberOfRows
        //outlineView.is
        var parent: String!
        var child: String!
        var i = 0
        var rootNum = 0
        while i < count {
            let item = outlineView.item(atRow: i)
            let expandable = outlineView.isExpandable(item)
            if (expandable && outlineView.isItemExpanded(item)) {
                for leaf in root[rootNum].children {
                    i += 1
                    if row == i {
                        parent = root[rootNum].scoreName
                        child = leaf.recordName
                        return [parent!: child!]
                    }
                }
            }
            rootNum += 1
            i += 1
        }
        return nil
    }
    
    func initPlay() {
        if audioPlayer != nil {
            currentTimeLabel.stringValue = "00:00"
            currentTimeSlider.doubleValue = 0.0
            currentTimeSlider.maxValue = audioPlayer.duration
            endTimeLabel.stringValue = changeSecToMin(seconds: audioPlayer.duration)
            audioPlayer.volume = volumeSlider.floatValue / 100
        }
    }
    
    func beginPlay() {
        if audioPlayer != nil {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.volume = volumeSlider.floatValue / 100
            audioPlayer.currentTime = currentTimeSlider.doubleValue
            playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeTick), userInfo: nil, repeats: true)
        }
    }
    
    func stopPlay() {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        
        if playTimer != nil {
            playTimer.invalidate()
            playTimer = nil
        }
    }
    
    @objc func timeTick() {
        currentTimeSlider.integerValue += 1
        currentTimeLabel.stringValue = changeSecToMin(seconds: currentTimeSlider.doubleValue)
        if currentTimeSlider.integerValue == Int(currentTimeSlider.maxValue) {
            endPlay()
            initPlay()
        }
    }
    
    func endPlay() {
        if playTimer != nil {
            playTimer.invalidate()
            playTimer = nil
        }
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
            audioPlayer.currentTime = 0.0
        }
        currentTimeSlider.integerValue = 0
        currentTimeLabel.stringValue = "00:00"
        playButton.state = NSControl.StateValue.off
        playButton.image = NSImage(named: NSImage.touchBarPlayTemplateName)
    }
    
}

