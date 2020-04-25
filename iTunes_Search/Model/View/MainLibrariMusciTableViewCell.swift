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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureGenreCell(_ video: Video){
        
        musicTitleLabel.text = video.videoTitle
        let imageUrl = URL(string: video.videoImageUrl)
        do{
            let data:NSData = try NSData(contentsOf: imageUrl!)
            musicImageView.image =  UIImage(data: data as Data)
            
        }catch{
            print("error")
        }
//        videoImageView.layer.borderWidth = 3
//        videoImageView.layer.masksToBounds = false
//        videoImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
//        videoImageView.layer.shadowOpacity = 2
//        videoImageView.layer.shadowPath = UIBezierPath(rect: videoImageView.bounds).cgPath
//        videoImageView.layer.shadowRadius = 5
//        videoImageView.layer.shadowOffset = .zero
//        videoImageView.layer.cornerRadius = 7.0
//        videoImageView.clipsToBounds = true
    }

}
