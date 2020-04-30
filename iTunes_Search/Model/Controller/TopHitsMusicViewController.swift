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
    var myLibraryList = [MyLibraryMusicData]()
    var checkTable = Bool()
    
    @IBOutlet weak var topHitsListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topHitsListTableView.delegate = self
        self.topHitsListTableView.dataSource = self
        if checkTable == false{
            fetchTopHitList()
        }else{
            fetchMyLibraryList()
        }
    }
    
    
    func fetchTopHitList(){
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
    
    
    func fetchMyLibraryList(){
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
          request.returnsObjectsAsFaults = false
          do {
              let result = try context?.fetch(request)
              for data in result as! [NSManagedObject] {
                  myLibraryList.append(data as! MyLibraryMusicData)
                  topHitsListTableView.reloadData()
              }
              
          } catch {
              print("Failed")
          }
      }

  

}

extension TopHitsMusicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        switch checkTable {
        case false:
            numberOfRowsInSection = topHitsLists.count
        case true:
            numberOfRowsInSection = myLibraryList.count
        }
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
            switch checkTable {
            case false:
              if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? TopHitsListTableViewCell {
                      cell.configureTopHitsCell(topHitsLists[indexPath.row])
                            return cell
                        }else {
                            return TopHitsListTableViewCell()
                        }
            case true:
              if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? TopHitsListTableViewCell {
                      cell.configureMyLibraryCell(myLibraryList[indexPath.row])
                      cell.addToFavoriteButton.isHidden = true
                            return cell
                        }else {
                            return TopHitsListTableViewCell()
                        }
            }
            return cell
    }
    
    
}
