//
//  FavoriteSongsCollectionViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class FavoriteSongsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var favorteSongImageView: UIStackView!
    @IBOutlet weak var favoriteSongArtistNameUILabel: UILabel!
    
    @IBOutlet weak var favoriteSongNameLabel: UILabel!
    
    
    
    func confiigurationCell(albums: AlbumModel) {
//        if albums.artworkURL != "" {
//              self.songImageView.image = UIImage(data: NSData(contentsOf: URL(string:albums.artworkURL!)!)! as Data)
//
//        }else{
//              self.songImageView.image = UIImage(named: "")
//        }
        self.favoriteSongNameLabel.text = albums.title
        self.favoriteSongArtistNameUILabel.text = albums.artist
//        self.genre = albums.genre!
//        self.artworkURL = albums.artworkURL!
//        self.title = albums.title!
//        self.artist = albums.artist!
//        self.trackViewUrl = albums.trackViewUrl!

        

    }
    
}
