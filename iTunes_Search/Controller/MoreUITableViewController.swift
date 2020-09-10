//
//  MoreUITableViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 9/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class MoreModel: NSObject {
    var settingsImage: String
    var settingsName: String
    
    
    init(settingsImage: String, settingsName:String) {
        self.settingsImage = settingsImage
        self.settingsName = settingsName
    }
}


let settingsArray = [
    MoreModel(settingsImage: "gear", settingsName: "Settings"),
    MoreModel(settingsImage: "arrow.counterclockwise.icloud.fill", settingsName: "Backup and Recover"),
    MoreModel(settingsImage: "alarm.fill", settingsName: "Sleep Timer"),
    MoreModel(settingsImage: "lightbulb.fill", settingsName: "Dark Mode"),
    MoreModel(settingsImage: "play.rectangle.fill", settingsName: "YouTube Login"),
    MoreModel(settingsImage: "camera.fill", settingsName: "Wave on Instagram"),
    MoreModel(settingsImage: "questionmark.square.fill", settingsName: "Help & Support"),
    MoreModel(settingsImage: "bubble.left.and.bubble.right.fill", settingsName: "Send Feedback"),
    MoreModel(settingsImage: "message.fill", settingsName: "Ask Question"),
    MoreModel(settingsImage: "person.2.fill", settingsName: "Contact us"),
    MoreModel(settingsImage: "dollarsign.square.fill", settingsName: "Donation"),
]

func getSettingsListArray() -> [MoreModel] {
    return settingsArray
}



class MoreUITableViewController: UITableViewController {
    @IBOutlet var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return getSettingsListArray().count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as?  MoreTableViewCell
        
        cell?.imageView?.image = UIImage(systemName: settingsArray[indexPath.row].settingsImage)
        cell?.textLabel?.text = settingsArray[indexPath.row].settingsName
        
        cell?.textLabel!.lineBreakMode = .byCharWrapping
        cell?.textLabel?.font = UIFont(name: "Verdana", size: 16.0)
        cell?.textLabel?.textColor = UIColor.black
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.textAlignment = .center
        
        
        return cell!
    }
}
