//
//  SplitViewController.swift
//  splitViewApp
//
//  Created by John Cook on 6/11/16.
//  Copyright © 2016 John Cook. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
    
    let PreferredWidth: CGFloat! = 0.5
    
    override func viewDidLoad() {
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        self.preferredPrimaryColumnWidthFraction = PreferredWidth
    }
}