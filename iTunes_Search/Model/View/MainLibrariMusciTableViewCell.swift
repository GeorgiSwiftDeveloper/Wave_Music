//
//  MainLibrariMusciTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/25/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class MainLibrariMusciTableViewCell: UITableViewCell {

    
    
    
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var musicTitleLabel: UILabel!
    
    
    var imageViewUrl = String()
    var videoID = String()
    
    
    func configureGenreCell(_ video: Video){
        imageViewUrl = video.videoImageUrl
        videoID = video.videoId
        musicTitleLabel.text = video.videoTitle
        let imageUrl = URL(string: video.videoImageUrl)
        do{
            let data:NSData = try NSData(contentsOf: imageUrl!)
            musicImageView.image =  UIImage(data: data as Data)
            
        }catch{
            print("error")
        }
        musicImageView.layer.borderWidth = 3
        musicImageView.layer.masksToBounds = false
        musicImageView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        musicImageView.layer.shadowOpacity = 2
        musicImageView.layer.shadowPath = UIBezierPath(rect: musicImageView.bounds).cgPath
        self.musicImageView.layer.cornerRadius = self.musicImageView.frame.height/2
        musicImageView.layer.shadowRadius = 3
        musicImageView.layer.shadowOffset = .zero
        musicImageView.clipsToBounds = true
    }

}
