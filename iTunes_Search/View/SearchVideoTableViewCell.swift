//
//  SearchVideoTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/13/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class SearchVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var videoID = String()
    var videoImageUrl = String()
    
    func configureSearchCell(albums: Video) {
        self.singerNameLabel.text = albums.videoTitle
        self.videoID = albums.videoId ?? ""
        if albums.videoImageUrl != ""{
            self.videoImageUrl = albums.videoImageUrl ?? ""
            let imageUrl = URL(string: albums.videoImageUrl ?? "")
            do{
                let data:NSData = try NSData(contentsOf: imageUrl!)
                self.songImageView.image =  UIImage(data: data as Data)
                
            }catch{
                print("Image data not found")
            }
        }
        self.songImageView.layer.borderWidth = 3
        self.songImageView.layer.masksToBounds = false
        self.songImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        self.songImageView.layer.shadowOpacity = 2
        self.songImageView.layer.shadowPath = UIBezierPath(rect:  self.songImageView.bounds).cgPath
        self.songImageView.layer.cornerRadius = self.songImageView.frame.height/2
        self.songImageView.layer.shadowRadius = 5
        self.songImageView.layer.shadowOffset = .zero
        self.songImageView.clipsToBounds = true
    }
    
}
