//
//  FavoriteSongsCollectionViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class GenresCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var genreImageView: UIImageView!
    @IBOutlet weak var genreNameLabel: UILabel!
    
    
    func confiigurationCell(_ albums: GenreModel) {
   
        self.genreNameLabel.text = albums.genreTitle
//        self.genreNameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.genreImageView.image = UIImage(named: albums.genreImage)
        genreImageView.layer.borderWidth = 3
        genreImageView.layer.masksToBounds = false
        genreImageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        genreImageView.layer.shadowOpacity = 3
        genreImageView.layer.shadowPath = UIBezierPath(rect: genreImageView.bounds).cgPath
        genreImageView.layer.shadowRadius = 5
        genreImageView.layer.shadowOffset = .zero
        genreImageView.layer.cornerRadius = 7.0
        genreImageView.clipsToBounds = true
        
       
      }
    
//    func getRandomColor() -> UIColor {
//         //Generate between 0 to 1
//         let red:CGFloat = CGFloat(drand48())
//         let green:CGFloat = CGFloat(drand48())
//         let blue:CGFloat = CGFloat(drand48())
//
//         return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
//    }
    
}
