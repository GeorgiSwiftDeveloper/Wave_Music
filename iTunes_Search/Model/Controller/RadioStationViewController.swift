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
     var listOfRadioStations =  [RadioModel]()
    
    
    let radioConnection = ReadDataFromStationJSONList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radioConnection.readStationJSONList(fileName: "station") { (radioJsonList, error) in
            if error != nil  {
                print(error?.localizedDescription as Any)
                return
            }
            if  let radioJsonList = radioJsonList {
                self.listOfRadioStations = radioJsonList
                self.tableView.reloadData()
            }
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRadioStations.count
      }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationRadioTableViewCell {
            DispatchQueue.main.async {
                cell.confiigurationCell(radioLsit: self.listOfRadioStations[indexPath.row])
            }
            return cell
        }else {
            return StationRadioTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get selected row  data
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as? StationRadioTableViewCell
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "RadioPlayerViewController") as! RadioPlayerViewController
        
        if let checkRadioName = currentCell?.stationNameLabel.text, let checkRadioDesc =  currentCell?.stationDescLabel.text, let checkRadioImage = currentCell?.stationImageView.image {
             nextViewController.selectedRadioName = checkRadioName
             nextViewController.selectedRadioDesc = checkRadioDesc
            nextViewController.selectedRadioImage = checkRadioImage
        }
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }


}
