//
//  SoundRecordController.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/25.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class SoundRecordController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    
    var song = [RootSongName]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setSoundRecordData()
        outlineView.dataSource = self
        outlineView.delegate = self
    }
    
    func setSoundRecordData() {
        var root: RootSongName!
        var leaf: LeafRecord!
        for i in 0...4 {
            var record = [LeafRecord]()
            root = RootSongName(songName: String(i))
            for j in 11...13 {
                leaf = LeafRecord(name: String(j))
                record.append(leaf)
            }
            root.children = record
            song.append(root)
        }
    }
}

extension SoundRecordController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? RootSongName {
            return item.children.count
        }
        return song.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? RootSongName {
            return item.children[index]
        }
        return song[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is RootSongName
    }

}

extension SoundRecordController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell: NSTableCellView!
        if item is RootSongName {
            cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = (item as! RootSongName).songName
        } else if item is LeafRecord {
            cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = (item as! LeafRecord).recordName
        }
        return cell
    }

}
