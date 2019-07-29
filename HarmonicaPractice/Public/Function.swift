//
//  Function.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/28.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

func changeSecToMin(seconds totalSec: Double) -> String {
    let min: Int = Int(totalSec) / 60
    let sec = Int(totalSec) % 60
    var minStr: String!
    var secStr: String!
    if min < 10 {
        minStr = "0" + String(min)
    } else {
        minStr = String(min)
    }
    if sec < 10 {
        secStr = "0" + String(sec)
    } else {
        secStr = String(sec)
    }
    let str = minStr + ":" + secStr
    return str
}
