//
//  PopupWindow.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/24.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

func alertRemind(message: String) {
    let alert = NSAlert()
    alert.messageText = message
    alert.addButton(withTitle: "我知道了")
    alert.runModal()
}

func ensureAlert(message mess: String, infomativeText infomative: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = mess
    alert.informativeText = infomative
    alert.addButton(withTitle: "我确定")
    alert.addButton(withTitle: "取消")
    let pressed = alert.runModal()
    
    if pressed == NSApplication.ModalResponse.alertFirstButtonReturn {
        return true
    }
    return false
}

func enterTextFieldAlert(message mess: String, infomative infomativeText: String) -> String? {
    let alert = NSAlert()
    alert.messageText = mess
    alert.informativeText = infomativeText
    alert.addButton(withTitle: "取消")
    alert.addButton(withTitle: "下一步")
    let nameText = NSTextField(string: "")
    nameText.frame = NSRect(x:0, y:0, width: 300, height: 25)
    nameText.font = NSFont.labelFont(ofSize: 16)
    alert.accessoryView = nameText
    let pressed = alert.runModal()
    
    if pressed == NSApplication.ModalResponse.alertSecondButtonReturn {
        let createName = nameText.stringValue
        if createName == "" {
            alertRemind(message: "内容不能为空！")
            return nil
        } else {
            return createName
        }
    }
    return nil
}

