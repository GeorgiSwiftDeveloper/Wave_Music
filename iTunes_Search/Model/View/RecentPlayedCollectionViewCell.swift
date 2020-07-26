//
//  RecentPlayedCollectionViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/18/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class RecentPlayedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    
    @IBOutlet weak var recentlyPlayedVideoCountLabel: UILabel!
    
    @IBOutlet weak var collectionImageView: UIView!
    
    @IBOutlet weak var imageMainView: UIView!
    
    @IBOutlet weak var defaultImageView: UIImageView!
    
    
    override func awakeFromNib() {
        collectionImageView.layer.cornerRadius = 10.0
        collectionImageView.layer.borderWidth = 2.0
        collectionImageView.layer.shadowRadius = 2
        collectionImageView.layer.shadowOffset = .zero
        collectionImageView.layer.shadowOpacity = 2
        collectionImageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionImageView.layer.masksToBounds = true
        
        imageMainView.layer.cornerRadius = 8
        imageMainView.layer.masksToBounds = true
    }
    
    
}
