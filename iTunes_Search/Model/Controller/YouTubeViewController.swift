//
//  YouTubeViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/18/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import YouTubePlayer
import AVFoundation
import AVKit
class YouTubeViewController: UIViewController {

    
    @IBOutlet weak var loadYouTubeVideo: UIWebView!
    
    
     var genreTitle: Video?
  var player = AVPlayer()
  var playerLayer = AVPlayerViewController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlw = URL(string: "https://www.youtube.com/watch?v=\(genreTitle!.videoId)=\(genreTitle!.videoPlaylistId)&index=4" )
        let urlRequest = URLRequest(url: urlw!)
//                    loadYouTubeVideo.loadVideoURL(url as URL)

        loadYouTubeVideo.loadRequest(urlRequest)
        loadYouTubeVideo.scrollView.isScrollEnabled = false
        //        self.player = AVPlayer(url: urlw!)
//        self.playerLayer.player = self.player
    }

    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        playerLayer.frame = loadYouTubeVideo.bounds
    }

    


}
