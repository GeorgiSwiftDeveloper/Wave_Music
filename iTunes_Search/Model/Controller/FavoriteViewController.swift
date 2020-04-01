//
//  FavoriteViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
protocol SelectedAlbumFromFavorites {
    func selectedAlbum(album: AlbumModel)
}
class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    

    var favoriteAlbum = [AlbumModel]()
    var delegate: SelectedAlbumFromFavorites?

    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableview.delegate = self
        self.tableview.dataSource = self
        // Do any additional setup after loading the view.
    }
    

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteAlbum.count
      }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as? FavoriteAlbumTableViewCell
        cell?.confiigurationCell(albums: favoriteAlbum[indexPath.row])
        
        return cell!
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            favoriteAlbum.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example

        let currentCell = tableView.cellForRow(at: indexPath!) as? FavoriteAlbumTableViewCell
        
        self.dismiss(animated: true, completion: nil)
    }
}
