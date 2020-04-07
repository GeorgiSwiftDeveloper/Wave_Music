//
//  RadioStationViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class RadioStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    
     @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 0
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? SectonTableViewCell {
                   DispatchQueue.main.async {
                       
                   }
                   return cell
               }else {
                   return SectonTableViewCell()
               }   }


}
