//
//  TopHitsMusicViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/28/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

class TopHitsMusicViewController: UIViewController {

    
    var topHitsLists = [TopHitsModel]()
    
    @IBOutlet weak var topHitsListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Do any additional setup after loading the view.
        self.topHitsListTableView.delegate = self
        self.topHitsListTableView.dataSource = self
       fetchFromCoreData()
    }
    
    
    func fetchFromCoreData(){
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
         request.returnsObjectsAsFaults = false
         do {
             let result = try context?.fetch(request)  as? [TopHitsModel]
            topHitsLists  = result!
            topHitsListTableView.reloadData()
         } catch {
            
             print("Failed")
         }
     }

  

}

extension TopHitsMusicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topHitsLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? TopHitsListTableViewCell {
            cell.configureGenreCell(topHitsLists[indexPath.row])
                  return cell
              }else {
                  return TopHitsListTableViewCell()
              }
    }
    
    
}
