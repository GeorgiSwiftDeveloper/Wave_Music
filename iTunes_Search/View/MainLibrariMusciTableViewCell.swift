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
        self.videoID = video.videoId ?? ""
        DispatchQueue.main.async {
            self.musicTitleLabel.text = video.videoTitle
            if video.videoImageUrl != ""{
            self.imageViewUrl = video.videoImageUrl ?? ""
            let imageUrl = URL(string: video.videoImageUrl ?? "")
            do{
                let data:NSData = try NSData(contentsOf: imageUrl!)
                self.musicImageView.image =  UIImage(data: data as Data)
                
            }catch{
                print("Image data not found")
                }
            }
            self.musicImageView.layer.borderWidth = 3
            self.musicImageView.layer.masksToBounds = false
            self.musicImageView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            self.musicImageView.layer.shadowOpacity = 2
            self.musicImageView.layer.shadowPath = UIBezierPath(rect: self.musicImageView.bounds).cgPath
            self.musicImageView.layer.cornerRadius = self.musicImageView.frame.height/2
            self.musicImageView.layer.shadowRadius = 3
            self.musicImageView.layer.shadowOffset = .zero
            self.musicImageView.clipsToBounds = true
        }
    }
    
}
