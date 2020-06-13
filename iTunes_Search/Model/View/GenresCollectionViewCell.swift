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
    @IBOutlet weak var trackCountLabel: UILabel!
    
    
    func confiigurationCell(_ albums: GenreModel) {
            self.genreNameLabel.text = albums.genreTitle
            self.genreImageView.image = UIImage(named: albums.genreImage)
        DispatchQueue.main.async {
            self.genreImageView.layer.borderWidth = 3
            self.genreImageView.layer.masksToBounds = false
            self.genreImageView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            self.genreImageView.layer.shadowOpacity = 2
            self.genreImageView.layer.shadowPath = UIBezierPath(rect:  self.genreImageView.bounds).cgPath
            self.genreImageView.layer.shadowRadius = 5
            self.genreImageView.layer.shadowOffset = .zero
            self.genreImageView.clipsToBounds = true
            self.genreImageView.layer.cornerRadius = self.genreImageView.frame.height/2
        }
    }
    

    
}
