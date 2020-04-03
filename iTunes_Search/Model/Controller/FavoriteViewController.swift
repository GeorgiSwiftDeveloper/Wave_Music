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
  
    

    var favoriteMovieAlbum = [MoviesModel]()
    var delegate: SelectedAlbumFromFavorites?
    var futureMoviesModelConnection = FutureMoviesModel()
    
    @IBOutlet weak var tableview: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
          futureMoviesModelConnection.delegate = self
        self.futureMoviesModelConnection.fetchiTunes()
        self.tableview.reloadData()
    }
    

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMovieAlbum.count
      }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? FutureMoviesTableViewCell
        DispatchQueue.main.async {
            cell?.confiigurationCell(movieAlbums: self.favoriteMovieAlbum[indexPath.row])
        }
        return cell!
    }

     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            favoriteMovieAlbum.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}

extension FavoriteViewController: MovieManagerDelegate {
    func didUpdateAlbum(_ albumManager: FutureMoviesModel, album: [MoviesModel]) {
        self.favoriteMovieAlbum.append(contentsOf: album)
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print("Cann't fidn movie list ")
    }
}
