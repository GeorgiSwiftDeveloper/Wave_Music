//
//  FutureMoviesTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/2/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class FutureMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var moviewName: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    
    
    func confiigurationCell(movieAlbums: MoviesModel) {
//
        let posterPath = movieAlbums.poster_path
        let baseUrl = "https://image.tmdv.org/t/p/w500/4U7hpTK0XTQBKT5X60bKmJd05ha.jpg"
        let imageUrl = URL(string: baseUrl + posterPath!)
        

        self.moviewName.text = movieAlbums.title
        self.movieOverview.text = movieAlbums.overview
              
    }

}
