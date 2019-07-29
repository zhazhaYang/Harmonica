//
//  RootSongName.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/25.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class RootScoreName: NSObject {
    var scoreName: String!
    var children = [LeafRecord]()
    init(scoreName name: String) {
        self.scoreName = name
    }
}

class LeafRecord: NSObject {
    var recordName:String!
    
    init(recordName n: String) {
        self.recordName = n
    }
}

struct RecordData {
    var scoreName: String!
    var recordName: String!
    var recordData: NSData!
}
