//
//  ViewController.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/18.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTabViewDelegate {
    
    @IBOutlet weak var firstTableView: NSTableView!
    @IBOutlet weak var secondTableView: NSTableView!
    private var mainTabController: MainTabController?
    @IBOutlet weak var containerView: NSView!
    
    private let firstTableID = "FirstTable"
    private let secondTableID = "SecondTable"
    private let firstCellID = "IDFirstCell"
    private let secondCellID = "IDSecondCell"

    private let firstStr = ["口琴练习"]
    private let firstImage = ["harmonica"]
    private let secondStr = ["本地录音"]
    private let secondImage = ["audio"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstTableView.delegate = self
        firstTableView.dataSource = self
        secondTableView.delegate = self
        secondTableView.dataSource = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "TOMAINTAB" {
            mainTabController = segue.destinationController as? MainTabController
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier!.rawValue == firstTableID {
            return firstStr.count
        }
        return secondStr.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
                var cellID: String? = nil
                var str: String? = nil
                var image = NSImage()
                if tableView.identifier!.rawValue == firstTableID {
                    cellID = firstCellID
                    str = firstStr[row]
                    image = NSImage.init(named: firstImage[row])!
                    
                } else if tableView.identifier!.rawValue == secondTableID {
                    cellID = secondCellID
                    str = secondStr[row]
                    image = NSImage.init(named: secondImage[row])!
                }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID!), owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = str!
                    cell.imageView?.image = image
                    return cell
                }
                return nil
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return true
    }

    func tableViewSelectionIsChanging(_ notification: Notification) {
        if firstTableView.identifier!.rawValue == (notification.object as? NSTableView)!.identifier!.rawValue {
            secondTableView.deselectAll(nil)
        } else {
            firstTableView.deselectAll(nil)
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let firSelectedRow = firstTableView.selectedRow
        let secSelectedRow = secondTableView.selectedRow
        if firSelectedRow >= 0 {
            mainTabController!.switchTabItem(tabItemIndex: firSelectedRow)
        } else if secSelectedRow >= 0 {
            mainTabController!.switchTabItem(tabItemIndex:( secSelectedRow + firstStr.count))
        }
    }
    
}

