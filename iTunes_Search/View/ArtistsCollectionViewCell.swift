//
//  ArtistsCollectionViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 7/28/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class ArtistsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var artistImageView: UIImageView!
    
    
    func configureArtistCell(_ artists: String) {
        artistImageView.image =  UIImage(named: artists)
    }
    
    
    override func awakeFromNib() {
        self.artistImageView.layer.borderWidth = 2
        self.artistImageView.layer.masksToBounds = false
        self.artistImageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.artistImageView.layer.shadowOpacity = 2
        self.artistImageView.layer.shadowPath = UIBezierPath(rect: self.artistImageView.bounds).cgPath
        self.artistImageView.layer.cornerRadius = self.artistImageView.frame.height/2
        self.artistImageView.layer.shadowRadius = 3
        self.artistImageView.layer.shadowOffset = .zero
        self.artistImageView.clipsToBounds = true
    }
}
