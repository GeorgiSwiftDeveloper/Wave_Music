//
//  FavoriteAlbumTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class FavoriteAlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    func confiigurationCell(albums: Video) {
        singerNameLabel.text = albums.videoTitle
           let imageUrl = URL(string: albums.videoImageUrl)
           do{
               let data:NSData = try NSData(contentsOf: imageUrl!)
               songImageView.image =  UIImage(data: data as Data)
               
           }catch{
               print("error")
           }
           songImageView.layer.borderWidth = 3
           songImageView.layer.masksToBounds = false
           songImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
           songImageView.layer.shadowOpacity = 2
           songImageView.layer.shadowPath = UIBezierPath(rect: songImageView.bounds).cgPath
            self.songImageView.layer.cornerRadius = self.songImageView.frame.height/2
           songImageView.layer.shadowRadius = 5
           songImageView.layer.shadowOffset = .zero
           songImageView.layer.cornerRadius = 7.0
           songImageView.clipsToBounds = true
    }
}
