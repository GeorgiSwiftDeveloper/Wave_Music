//
//  RadioPlayerViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class RadioPlayerViewController: UIViewController {
    
    @IBOutlet weak var radioSongImageView: UIImageView!
    @IBOutlet weak var radioSongNameLabel: UILabel!
    @IBOutlet weak var radioSongArtistNameLabel: UILabel!
    
    
    var selectedRadioImage = UIImage()
    var selectedRadioName = String()
    var selectedRadioDesc = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.radioSongNameLabel.text = selectedRadioName
          self.radioSongArtistNameLabel.text = selectedRadioDesc
        self.radioSongImageView.image = selectedRadioImage
        // Do any additional setup after loading the view.
    
    }
}
