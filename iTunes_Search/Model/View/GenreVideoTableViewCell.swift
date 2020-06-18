//
//  GenreVideoTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class GenreVideoTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    
    var videoID = String()
    var videoImageUrl = String()
    func configureGenreCell(_ video: Video){
        DispatchQueue.main.async {
            
            self.videoID = video.videoId ?? ""
            if video.videoImageUrl != ""{
            self.videoImageUrl = video.videoImageUrl ?? ""
            self.singerNameLabel.text = video.videoTitle
            let imageUrl = URL(string: video.videoImageUrl ?? "")
            do{
                let data:NSData = try NSData(contentsOf: imageUrl!)
                self.videoImageView.image =  UIImage(data: data as Data)
                
            }catch{
                print("Image data not found")
                }
            }
            self.videoImageView.layer.borderWidth = 3
            self.videoImageView.layer.masksToBounds = false
            self.videoImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            self.videoImageView.layer.shadowOpacity = 2
            self.videoImageView.layer.shadowPath = UIBezierPath(rect:  self.videoImageView.bounds).cgPath
            self.videoImageView.layer.cornerRadius = self.videoImageView.frame.height/2
            self.videoImageView.layer.shadowRadius = 3
            self.videoImageView.layer.shadowOffset = .zero
            self.videoImageView.clipsToBounds = true
            
        }
    }
    
}
