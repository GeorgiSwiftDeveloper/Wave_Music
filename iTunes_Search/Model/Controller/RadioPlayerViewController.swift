//
//  RadioPlayerViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import AVFoundation
class RadioPlayerViewController: UIViewController {
    
    
    @IBOutlet weak var radioSongImageView: UIImageView!
    @IBOutlet weak var radioSongNameLabel: UILabel!
    @IBOutlet weak var radioSongArtistNameLabel: UILabel!
    
    @IBOutlet weak var goBackRadioButton: UIButton!
    @IBOutlet weak var playRadioButton: UIButton!
    @IBOutlet weak var stopRadioButton: UIButton!
    @IBOutlet weak var goForwardRadioButton: UIButton!
    @IBOutlet weak var sliderButtonOutlet: UISlider!
    
    var audioPlayer = AVPlayer()
     var player = AVAudioPlayer()
    
    var selectedRadioImage = UIImage()
    var selectedRadioName = String()
    var selectedRadioDesc = String()
    var selectedStreamUrl = String()
    
    
    
    var checkIfAudioisPause = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        self.radioSongNameLabel.text = selectedRadioName
        self.radioSongArtistNameLabel.text = selectedRadioDesc
        self.radioSongImageView.image = selectedRadioImage
    }
    
    func playThis(url: NSURL)
    {
        do {
            let playerItem: AVPlayerItem = AVPlayerItem(url: url as URL)
            audioPlayer = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: audioPlayer)
            playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
            self.view.layer.addSublayer(playerLayer)
            audioPlayer.play()
        } catch  {
            print(error.localizedDescription)
        }
    }
  
    @IBAction func goBackAction(_ sender: UIButton) {
        
    }
    
    @IBAction func playRadioAction(_ sender: UIButton) {
        if checkIfAudioisPause == false {
            guard let url = NSURL(string: selectedStreamUrl) else { return}
            playThis(url: url)
            checkIfAudioisPause = true
        }else{
        }
    }
    
    @IBAction func stopRadioAction(_ sender: UIButton) {
        audioPlayer.pause()
        self.checkIfAudioisPause = false
    }
    
    @IBAction func goForwardAction(_ sender: Any) {
    }
    @IBAction func sliderAction(_ sender: UISlider) {
        audioPlayer.volume = sender.value
    }
}
