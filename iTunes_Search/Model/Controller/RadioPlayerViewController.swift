//
//  RadioPlayerViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import FRadioPlayer
import AVFoundation
class RadioPlayerViewController: UIViewController {
    
    
    @IBOutlet weak var radioSongImageView: UIImageView!
    @IBOutlet weak var radioSongNameLabel: UILabel!
    @IBOutlet weak var radioSongArtistNameLabel: UILabel!
    
    @IBOutlet weak var goBackRadioButton: UIButton!
    @IBOutlet weak var playRadioButton: UIButton!
    @IBOutlet weak var stopRadioButton: UIButton!
    @IBOutlet weak var goForwardRadioButton: UIButton!
    
    var audioPlayer = AVPlayer()
    
    var selectedRadioImage = UIImage()
    var selectedRadioName = String()
    var selectedRadioDesc = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        self.radioSongNameLabel.text = selectedRadioName
        self.radioSongArtistNameLabel.text = selectedRadioDesc
        self.radioSongImageView.image = selectedRadioImage

//        let urlstring = "http://strm112.1.fm/acountry_mobile_mp3"
//        let url = NSURL(string: urlstring)
//        print("the url = \(url!)")
//        downloadFileFromURL(url: url!)
        
        var player: AVPlayer!
        let url  = URL.init(string:   "http://strm112.1.fm/acountry_mobile_mp3")

        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)

        let playerLayer = AVPlayerLayer(player: player!)

        playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.view.layer.addSublayer(playerLayer)
        player.play()
        
    }
    
//    func playThis(url: NSURL)
//    {
//        do {
//
//            let audioPlayer = try AVAudioPlayer(contentsOf: url as URL)
//                   audioPlayer.prepareToPlay()
//                   audioPlayer.play()
//        } catch let error as NSError {
//            //self.player = nil
//            print(error.localizedDescription)
//        } catch {
//            print("AVAudioPlayer init failed")
//        }
//    }
    
//    func downloadFileFromURL(url:NSURL){
//
//        var downloadTask:URLSessionDownloadTask
//        downloadTask = URLSession.shared.downloadTask(with: url as URL, completionHandler: { [weak self](URL, response, error) -> Void in
//            self?.playThis(url: downloadTaskr)
//        })
//
//        downloadTask.resume()
//
//    }
  
    @IBAction func goBackAction(_ sender: UIButton) {
        
    }
    
    @IBAction func playRadioAction(_ sender: UIButton) {
let urlstring = "http://strm112.1.fm/acountry_mobile_mp3"
//       let url = NSURL(string: urlstring)
//       print("the url = \(url!)")
//       downloadFileFromURL(url: url!)
    }
    
    @IBAction func stopRadioAction(_ sender: UIButton) {
         audioPlayer.pause()
    }
    
    @IBAction func goForwardAction(_ sender: Any) {
    }
    @IBAction func sliderAction(_ sender: UISlider) {
        audioPlayer.volume = sender.value
    }
}
