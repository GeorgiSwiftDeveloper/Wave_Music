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
    
    func configureGenreCell(_ video: Video){
        
        singerNameLabel.text = video.videoTitle
        let imageUrl = URL(string: video.videoImageUrl)
        do{
            let data:NSData = try NSData(contentsOf: imageUrl!)
            videoImageView.image =  UIImage(data: data as Data)
            
        }catch{
            print("error")
        }
       videoImageView.layer.borderWidth = 3
       videoImageView.layer.masksToBounds = false
       videoImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
       videoImageView.layer.shadowOpacity = 2
       videoImageView.layer.shadowPath = UIBezierPath(rect: videoImageView.bounds).cgPath
       self.videoImageView.layer.cornerRadius = self.videoImageView.frame.height/2
       videoImageView.layer.shadowRadius = 3
       videoImageView.layer.shadowOffset = .zero
       videoImageView.clipsToBounds = true
    }

}
