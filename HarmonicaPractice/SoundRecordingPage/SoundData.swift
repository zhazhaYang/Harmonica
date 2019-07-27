//
//  RootSongName.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/25.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class RootSongName: NSObject {
    var songName: String!
    var children = [LeafRecord]()
    init(songName name: String) {
        self.songName = name
    }
}

class LeafRecord: NSObject {
    var recordName:String!
    //var recordData:NSData!
    
    init(name n: String) {
        self.recordName = n
    }
}
