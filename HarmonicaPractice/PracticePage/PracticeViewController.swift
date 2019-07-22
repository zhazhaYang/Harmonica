//
//  PracticeViewController.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/21.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class PracticeViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addMusicScore(_ sender: NSButton) {
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
            print(nameText.stringValue)
        }
        
    }
    
    private func openPanel(_ name: [String]) {
        let chooseImage: NSOpenPanel = NSOpenPanel()
        chooseImage.canChooseDirectories = false
        chooseImage.canChooseFiles = true
        chooseImage.allowsMultipleSelection = false
        chooseImage.beginSheetModal(for: self.view.window!) { (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectPath = chooseImage.url!.path
            }
        }
    }
}
