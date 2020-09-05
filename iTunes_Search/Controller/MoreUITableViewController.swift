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
     MoreModel(settingsImage: "play.rectangle.fill", settingsName: "YouTube Login"),
     MoreModel(settingsImage: "camera.fill", settingsName: "Wave on Instagram"),
     MoreModel(settingsImage: "questionmark.square.fill", settingsName: "Help & Support"),
     MoreModel(settingsImage: "bubble.left.and.bubble.right.fill", settingsName: "Send Feedback"),
     MoreModel(settingsImage: "lightbulb.fill", settingsName: "Dark Mode"),
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

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//       return 1
//    }
    
//  override  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    var backupDescription  = String()
//    if section == 1{
//          backupDescription =  "Backup your music, transfer your library to other devices recover deleted music, and more."
//    }
//         return backupDescription
//     }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return getSettingsListArray().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as?  MoreTableViewCell
        
        cell?.imageView?.image = UIImage(systemName: settingsArray[indexPath.row].settingsImage)
        cell?.textLabel?.text = settingsArray[indexPath.row].settingsName
        
        cell?.textLabel!.lineBreakMode = .byCharWrapping
        cell?.textLabel!.font = UIFont.systemFont(ofSize: 16.0)
        cell?.textLabel?.textColor = UIColor.black
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.textAlignment = .center
     

        return cell!
    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        var height = Int()
//        if section == 1{
//            height = 100
//        }
//        return CGFloat(height)
//    }
    
   override  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        view.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana", size: 10)!
        header.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        header.textLabel?.numberOfLines  = 0
    }

}
