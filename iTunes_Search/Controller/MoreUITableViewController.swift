//
//  MoreUITableViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 9/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import SafariServices



class MoreUITableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView.reloadData()
        self.settingsTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return getSettingsListArray().count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: moreCellIdentifire, for: indexPath)
        
        cell.imageView?.image = UIImage(systemName: settingsArray[indexPath.row].settingsImage)
        cell.textLabel?.text = settingsArray[indexPath.row].settingsName
        
        cell.textLabel!.lineBreakMode = .byCharWrapping
        cell.textLabel?.font = UIFont(name: "Verdana", size: 16.0)
        cell.textLabel?.textColor = UIColor.black
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textAlignment = .center
        
        
        return cell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? UITableViewCell
        
        switch indexPath.row {
        case 3:
            SettingsDetailView.sharedSettingsDetail.showSafariVC(for: "https://www.youtube.com", view: self)
        case 4:
            SettingsDetailView.sharedSettingsDetail.openInstagramApp(username: "georgi___yan")
        case 8:
            SettingsDetailView.sharedSettingsDetail.showAlertView(title: settingsArray[indexPath.row].settingsName, message: "Cell: 323-332-75-03 \n Email: developermalkhasyan@gmail.com", actionTitle: "OK", view: self)
        default:
            let newViewController = SelectedSettingsViewController()
            newViewController.selectedSettingsTitle = selectedCell?.textLabel?.text
            newViewController.selectedSettingsIndex = indexPath.row
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
}
