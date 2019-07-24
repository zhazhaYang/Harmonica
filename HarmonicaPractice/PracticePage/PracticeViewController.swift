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
    private let accompany1ForKey = "accompany1"
    private let accompany2ForKey = "accompany2"
    
    private var data: PracticeData!
    private var createName: String!
    private var createScore: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if(retrieveName()) {
            self.noneTipText.isHidden = true
            self.chooseDataToShow(atIndex: 0)
        }
        comboBox.delegate = self
    }
    
    @IBAction func addMusicScoreClicked(_ sender: NSButton) {
        let alert = NSAlert()
        alert.informativeText = "添加曲谱"
        alert.messageText = "请输入名称"
        alert.addButton(withTitle: "取消")
        alert.addButton(withTitle: "下一步")
        let nameText = NSTextField(string: "")
        nameText.frame = NSRect(x:0, y:0, width: 300, height: 25)
        nameText.font = NSFont.labelFont(ofSize: 16)
        alert.accessoryView = nameText
        let pressed = alert.runModal()
        
        if pressed == NSApplication.ModalResponse.alertSecondButtonReturn {
            createName = nameText.stringValue
            if createName == "" {
                alertRemind(message: "内容不能为空！")
                return
            }
            openPanel(types: ["jpg", "png"])
        }
        
    }
    
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
                    self.alertRemind(message: "添加失败！")
                    return
                } else {
                    self.comboBox.addItem(withObjectValue: self.createName)
                    self.chooseDataToShow(atIndex: 0)
                    
                }
            }
        }
    }
    
    func alertRemind(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "我知道啦")
        alert.runModal()
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
    
    private func selectFromCoreData(byName name: String) -> PracticeData? {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return nil }
        
        var practice = PracticeData()
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        do {
            let context = try managedContext.fetch(fetchRequest)
            let object = context[0] as! NSManagedObject
            practice.name = name
            practice.score = object.value(forKey: self.scoreForKey) as? NSData
            practice.accompany1 = object.value(forKey: self.accompany1ForKey) as? NSData
            practice.accompany2 = object.value(forKey: self.accompany2ForKey) as? NSData
        } catch {
            return nil
        }
        return practice
    }
    
    private func deletion(byName name: String) -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        do {
            let context = try managedContext.fetch(fetchRequest)
            let objectToDelete = context[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
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

extension PracticeViewController: NSComboBoxDelegate, NSComboBoxDataSource, NSTabViewDelegate {
    
    func chooseDataToShow(atIndex at: Int) {
        var praticeData: PracticeData!
        var name: String!
        self.comboBox.selectItem(at: at)
        name = self.comboBox.objectValueOfSelectedItem as? String
        praticeData = selectFromCoreData(byName: name)
        let image = NSImage(data: praticeData.score as Data)
        self.imageView.image = image
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        self.chooseDataToShow(atIndex: self.comboBox.indexOfSelectedItem)
    }
}
