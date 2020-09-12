//
//  SelectedSettingsTableViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 9/11/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class SelectedSettingsTableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        NSLog("sections")
        return 2
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("rows")
        return 3
    }

     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("get cell")
       
    }

}
