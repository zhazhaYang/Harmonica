//
//  PracticeViewController.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/21.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class PracticeViewController: NSViewController {

    @IBOutlet weak var noneTipText: NSTextField!
    @IBOutlet weak var comboBox: NSComboBox!

    @IBOutlet weak var imageView: NSImageView!
    
    private let entityName = "Practice"
    private let nameForKey = "name"
    private let scoreForKey = "score"
    private let acc1NameForKey = "acc1_name"
    private let acc2NameForKey = "acc2_name"
    private let accompany1ForKey = "accompany1"
    private let accompany2ForKey = "accompany2"
    
    private var createName: String!
    private var createScore: NSData!
    
    private var accompanyController: AccompanyController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToPlayAccompany") {
            accompanyController = segue.destinationController as? AccompanyController
            accompanyController.loadView()
            if(retrieveName()) {
                noneTipText.isHidden = true
                chooseDataToShow(atIndex: 0)
            }
            comboBox.delegate = self
        }
        
    }
    
    @IBAction func addMusicScoreClicked(_ sender: NSButton) {
        createName = enterTextFieldAlert(message: "添加曲谱", infomative: "请输入名称：")
        if createName == nil {
            return
        }
        if selectFromCoreData(byName: createName) != nil {
            alertRemind(message: "该名称重复了！")
        } else {
            openPanel(types: ["jpg", "png"])
        }
    }
    
    
    @IBAction func deleteMusicScoreClicked(_ sender: NSButton) {
        if self.comboBox.numberOfItems == 0 { return }
        if ensureAlert(message: "删除曲谱", infomativeText: "删除曲谱的操作连同该曲谱的伴奏也会删除，你确定吗？") {
            let scoreName = self.comboBox.objectValueOfSelectedItem as! String
            if self.deleteInCoreData(byname: scoreName) {
                if self.accompanyController.deleteAccompanyByScore(scoreName: scoreName) {
                    alertRemind(message: "删除成功！")
                } else {
                    print("删除伴奏失败了！")
                }
                if self.comboBox.numberOfItems == 1 {
                    self.comboBox.stringValue = ""
                    self.imageView.image = nil
                    self.noneTipText.isHidden = false
                    self.accompanyController.setAudioPlayer(accompany: nil)
                } else if self.comboBox.numberOfItems > 1 {
                    self.chooseDataToShow(atIndex: 0)
                }
                self.comboBox.removeItem(at: self.comboBox.indexOfSelectedItem)
            } else {
                alertRemind(message: "删除失败, 请稍后再试！")
            }
        }
    }
    
}


//MARK: - Practice Core Data Operation

extension PracticeViewController {
    private func openPanel(types typesName: [String]) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = typesName
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectedURL = openPanel.url!
                self.createScore = NSData(contentsOf: selectedURL)
                self.noneTipText.isHidden = true
                if self.saveMusiceScore(scoreName: self.createName, withImage: self.createScore) == false {
                    alertRemind(message: "添加失败！")
                    return
                } else {
                    self.comboBox.addItem(withObjectValue: self.createName)
                    self.chooseDataToShow(atIndex: 0)
                    
                }
            }
        }
    }
    
    private func saveMusiceScore(scoreName name: String,withImage score: NSData) -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: managedContext)!
        let practice = NSManagedObject(entity: entity, insertInto: managedContext)
        practice.setValue(name, forKey: self.nameForKey)
        practice.setValue(score, forKey: self.scoreForKey)
        
        do { try managedContext.save() } catch {
            return false
        }
        return true
    }
    
    private func retrieveName() -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count == 0 {
                return false
            } else {
                for data in result as! [NSManagedObject] {
                    comboBox.addItem(withObjectValue: data.value(forKey: self.nameForKey) as! String)
                }
                self.comboBox.selectItem(at: 0)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    private func deleteInCoreData(byname name: String) -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: " name = %@ ", name)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            let objectDelete = fetched[0] as! NSManagedObject
            managedContext.delete(objectDelete)
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
    
    private func selectFromCoreData(byName name: String) -> PracticeData? {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return nil }
        
        var practice = PracticeData()
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        do {
            let context = try managedContext.fetch(fetchRequest)
            if context.count == 0 {
                return nil
            }
            let object = context[0] as! NSManagedObject
            practice.name = name
            practice.score = object.value(forKey: self.scoreForKey) as? NSData
        } catch {
            return nil
        }
        return practice
    }
    
}

//MARK: - ComboBox to choose music score
extension PracticeViewController: NSComboBoxDelegate, NSComboBoxDataSource, NSTabViewDelegate {
    
    func chooseDataToShow(atIndex at: Int) {
        var practiceData: PracticeData!
        var name: String!
        self.comboBox.selectItem(at: at)
        name = self.comboBox.objectValueOfSelectedItem as? String
        practiceData = selectFromCoreData(byName: name)
        let image = NSImage(data: practiceData.score as Data)
        self.imageView.image = image!
        self.accompanyController.initAccComboBox(scoreName: practiceData.name)
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        self.chooseDataToShow(atIndex: self.comboBox.indexOfSelectedItem)
    }
}

