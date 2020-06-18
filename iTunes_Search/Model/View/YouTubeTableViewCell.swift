//
//  YouTubeTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/21/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class YouTubeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var singerNameLabel: UILabel!

    func configureGenreCell(_ video: Video){
        
        singerNameLabel.text = video.videoTitle
        if video.videoImageUrl != ""{
        let imageUrl = URL(string: video.videoImageUrl)
        do{
            let data:NSData = try NSData(contentsOf: imageUrl!)
            videoImageView.image =  UIImage(data: data as Data)
            
        }catch{
            print("Image data not found")
            }
        }
        videoImageView.layer.borderWidth = 3
        videoImageView.layer.masksToBounds = false
        videoImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        videoImageView.layer.shadowOpacity = 2
        videoImageView.layer.shadowPath = UIBezierPath(rect: videoImageView.bounds).cgPath
        videoImageView.layer.shadowRadius = 5
        videoImageView.layer.shadowOffset = .zero
        videoImageView.layer.cornerRadius = 7.0
        videoImageView.clipsToBounds = true
    }
    
}
