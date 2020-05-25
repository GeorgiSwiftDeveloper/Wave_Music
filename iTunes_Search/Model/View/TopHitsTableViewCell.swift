//
//  TopHitsTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/26/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class TopHitsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topHitSongTitle: UILabel!
    @IBOutlet weak var topHitImageView: UIImageView!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    var videoID = String()
    var videoImageUrl = String()
    
    func configureGenreCell(_ video: Video){
           self.videoID = video.videoId
        DispatchQueue.main.async {
            self.topHitSongTitle.text = video.videoTitle
            if video.videoImageUrl != ""{
            self.videoImageUrl = video.videoImageUrl
            let imageUrl = URL(string: video.videoImageUrl)
            do{
                let data:NSData = try NSData(contentsOf: imageUrl!)
                self.topHitImageView.image =  UIImage(data: data as Data)
                
            }catch{
                print("error")
                    }
            }
            self.topHitImageView.layer.borderWidth = 3
            self.topHitImageView.layer.masksToBounds = false
            self.topHitImageView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            self.topHitImageView.layer.shadowOpacity = 2
            self.topHitImageView.layer.shadowPath = UIBezierPath(rect: self.topHitImageView.bounds).cgPath
            self.topHitImageView.layer.cornerRadius = self.topHitImageView.frame.height/2
            self.topHitImageView.layer.shadowRadius = 3
            self.topHitImageView.layer.shadowOffset = .zero
            self.topHitImageView.clipsToBounds = true
        }
    }
    
    
}
