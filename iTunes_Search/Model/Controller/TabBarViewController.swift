//
//  TabBarViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/7/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
}
