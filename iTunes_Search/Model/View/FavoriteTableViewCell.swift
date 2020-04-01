//
//  FavoriteTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var singerName: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    
    
    func configureCell(iTunesData: AlbumModel) {
        songImageView.image = UIImage(data: NSData(contentsOf: URL(string:iTunesData.artworkURL)!)! as Data)
        singerName.text = iTunesData.artist
        songNameLabel.text = iTunesData.title
    }

}
