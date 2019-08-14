//
//  TextHUD.swift
//  TryTextHUD
//
//  Created by yang on 2019/8/12.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class WaitingTextHUD: NSObject {
    var view: NSView!
    var timer: Timer!
    func showWaitingWithText(size: NSSize, text: String, autoRemove: Bool) {
        view = WaitingTextView(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor(gray: 0.5, alpha: 0.5)
        let label = NSTextField(labelWithString: text)
        label.isEditable = false
        label.isBordered = false
        label.frame.size = NSSize(width: 200, height: 40)
        label.frame.origin = NSPoint(x: (size.width / 2 - 100), y: (size.height / 2 - 20))
        label.font = NSFont(name: "Arial", size: 20)
        label.alignment = NSTextAlignment.left
        view.addSubview(label)
        let window = NSApplication.shared.keyWindow
        window?.contentView?.addSubview(view)
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            switch label.stringValue {
            case text:
                label.stringValue = text + "。"
                break
            case text + "。":
                label.stringValue = text + "。。"
                break
            case text + "。。":
                label.stringValue = text + "。。。"
                break
            case text + "。。。":
                label.stringValue = text
                break
            default:
                break
            }
        })
        if autoRemove {
            let selec = #selector(removeHUD(_:))
            perform(selec, with: window, afterDelay: 60)
        }
    }
    
    @objc func removeHUD(_ object: AnyObject?) {
        view.removeFromSuperview()
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
}
