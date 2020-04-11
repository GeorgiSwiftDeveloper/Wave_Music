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
    @IBOutlet weak var favoriteSongArtistNameUILabel: UILabel!
    @IBOutlet weak var favoriteSongNameLabel: UILabel!
    
    
    func confiigurationCell(albums: SelectedAlbumModel) {
          self.favoriteSongNameLabel.text = albums.singerName
          self.favoriteSongArtistNameUILabel.text = albums.songTitle
          if albums.songImage != "" {
          self.favorteSongImageView.image = UIImage(data: NSData(contentsOf: URL(string:albums.songImage!)!)! as Data)
          }else{
                self.favorteSongImageView.image = UIImage(named: "")
          }
      
        favorteSongImageView.layer.borderWidth = 1
        favorteSongImageView.layer.masksToBounds = false
        favorteSongImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        favorteSongImageView.layer.cornerRadius = self.favorteSongImageView.frame.height/2 
        favorteSongImageView.clipsToBounds = true
      }
    
}
