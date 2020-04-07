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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? FutureMoviesTableViewCell {
            DispatchQueue.main.async {
                cell.confiigurationCell(movieAlbums: self.favoriteMovieAlbum[indexPath.row])
                self.tableview.separatorStyle = .singleLine
                self.tableview.separatorColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            return cell
        }else {
            return FutureMoviesTableViewCell()
        }
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
        DispatchQueue.main.async {
            self.favoriteMovieAlbum.append(contentsOf: album)
            self.tableview.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print("Cann't find movie ")
    }
}
