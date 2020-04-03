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
        
        let posterPath = movieAlbums.poster_path
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        let imageUrl = URL(string: baseUrl + posterPath!)
        do{
            let data:NSData = try NSData(contentsOf: imageUrl!)
              movieImage.image =  UIImage(data: data as Data)
        }catch{
           print("error")
        }
       
      
        self.moviewName.text = movieAlbums.title
        self.movieOverview.text = movieAlbums.overview
              
    }

}
