//
//  MainTabController.swift
//  HarmonicaPractice
//
//  Created by yang on 2019/7/21.
//  Copyright © 2019 yang. All rights reserved.
//

import Cocoa

class MainTabController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.switchTabItem(tabItemIndex: 0)
    }
    
    public func switchTabItem(tabItemIndex index: Int)
    {
        self.selectedTabViewItemIndex = index
    }
}
