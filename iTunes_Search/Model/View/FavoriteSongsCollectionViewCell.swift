//
//  FavoriteSongsCollectionViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class FavoriteSongsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var favorteSongImageView: UIImageView!
//    @IBOutlet weak var favoriteSongArtistNameUILabel: UILabel!
    @IBOutlet weak var favoriteSongNameLabel: UILabel!
    
    
    func confiigurationCell(_ albums: GenreModel) {
        self.favoriteSongNameLabel.text = albums.genreTitle
        self.favorteSongImageView.image = UIImage(named: albums.genreImage)
//          self.favoriteSongArtistNameUILabel.text = albums.songTitle
//          if albums.songImage != "" {
//          self.favorteSongImageView.image = UIImage(data: NSData(contentsOf: URL(string:albums.songImage!)!)! as Data)
//          }else{
//                self.favorteSongImageView.image = UIImage(named: "")
//          }
        

       
        favorteSongImageView.layer.borderWidth = 3
        favorteSongImageView.layer.masksToBounds = false
        favorteSongImageView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        favorteSongImageView.layer.shadowOpacity = 3
        favorteSongImageView.layer.shadowPath = UIBezierPath(rect: favorteSongImageView.bounds).cgPath
        favorteSongImageView.layer.shadowRadius = 5
        favorteSongImageView.layer.shadowOffset = .zero
        favorteSongImageView.layer.cornerRadius = 7.0
        favorteSongImageView.clipsToBounds = true
        
       
      }
    
}
