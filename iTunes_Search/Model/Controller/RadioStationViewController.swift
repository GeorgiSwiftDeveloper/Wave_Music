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
    
    
        let radioConnection = ReadDataFromStationJSONList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radioConnection.readStationJSONList(fileName: "station") { (radioJsonList, error) in
            print(radioJsonList?.station[0].name as Any)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 0
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationRadioTableViewCell {
                   DispatchQueue.main.async {
                       
                   }
                   return cell
               }else {
                   return StationRadioTableViewCell()
               }   }


}
