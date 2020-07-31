//
//  TopHitsListTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/28/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class SelectedSectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topHitImageView: UIImageView!
    @IBOutlet weak var topHitLabelText: UILabel!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    var videoIDProperty = String()
    var videoImageUrlProperty = String()
    var videoTitleProperty = String()
    
    func configureTopHitsCell(_ video: Video){
        configureMainVideoCell(video)
    }
    
    func configureMyLibraryCell(_ video: Video){
        configureMainVideoCell(video)
    }
    
    
    func configureRecentlyPlayedCell(_ video: Video){
        configureMainVideoCell(video)
    }
    
    func configureMainVideoCell(_ video: Video){
        self.videoImageUrlProperty = video.videoImageUrl ?? ""
        self.videoIDProperty = video.videoId ?? ""
        self.videoTitleProperty = video.videoTitle ?? ""
        
        DispatchQueue.main.async {
            self.topHitLabelText.text = video.videoTitle
            if video.videoImageUrl != ""{
                let imageUrl = URL(string: video.videoImageUrl ?? "")
                do{
                    let data:NSData = try NSData(contentsOf: imageUrl!)
                    self.topHitImageView.image =  UIImage(data: data as Data)
                    
                }catch{
                    print("Image data not found")
                }
            }
          self.topHitImageView?.layer.borderWidth = 3
          self.topHitImageView?.layer.masksToBounds = false
          self.topHitImageView?.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
          self.topHitImageView?.layer.shadowOpacity = 2
          self.topHitImageView.layer.shadowPath = UIBezierPath(rect: self.topHitImageView!.bounds).cgPath
          self.topHitImageView?.layer.cornerRadius = self.topHitImageView!.frame.height/2
          self.topHitImageView?.layer.shadowRadius = 3
          self.topHitImageView?.layer.shadowOffset = .zero
          self.topHitImageView?.clipsToBounds = true
        }
    }
}
