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
    
    @IBOutlet weak var goBackRadioButton: UIButton!
    @IBOutlet weak var playRadioButton: UIButton!
    @IBOutlet weak var stopRadioButton: UIButton!
    @IBOutlet weak var goForwardRadioButton: UIButton!
    
    
    
    var selectedRadioImage = UIImage()
    var selectedRadioName = String()
    var selectedRadioDesc = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.radioSongNameLabel.text = selectedRadioName
        self.radioSongArtistNameLabel.text = selectedRadioDesc
        self.radioSongImageView.image = selectedRadioImage

    }
    
    @IBAction func goBackAction(_ sender: UIButton) {
    }
    
    @IBAction func playRadioAction(_ sender: UIButton) {
    }
    
    @IBAction func stopRadioAction(_ sender: UIButton) {
    }
    
    @IBAction func goForwardAction(_ sender: Any) {
    }
    
}
