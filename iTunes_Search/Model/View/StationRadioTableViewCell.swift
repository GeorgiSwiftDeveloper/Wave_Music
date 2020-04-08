//
//  SectonTableViewCell.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class StationRadioTableViewCell: UITableViewCell {
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var stationImageView: UIImageView!
    var stationStreamUrl = String()
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func confiigurationCell(radioLsit: RadioModel) {
        stationStreamUrl = radioLsit.streamURL
        stationNameLabel.text = radioLsit.name
        stationDescLabel.text = radioLsit.desc
        stationImageView.image = UIImage(named: radioLsit.imageURL)
      }

}
