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
import WebKit
class YouTubeViewController: UIViewController, WKNavigationDelegate {
    
    
    @IBOutlet weak var loadYouTubeVideo: WKWebView?
    
    
    
    var genreTitle: Video?
    let appGroupName = "br.com.tntstudios.youtubeplayer"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let urlw = URL(string: "https://www.youtube.com/watch?v=\(genreTitle!.videoId)&index=4&showinfo=0&controls=0&autohide=1" )
   
        loadYoutubeIframe(youtubeVideoId: genreTitle!.videoId)
    }

    
    
    func loadYoutubeIframe(youtubeVideoId: String) {
        
        let html =
            "<html>" +
                "<body style='margin: 0;'>" +
                "<script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>" +
                "<script type='text/javascript'> " +
                "   function onYouTubeIframeAPIReady() {" +
                "      ytplayer = new YT.Player('playerId',{events:{'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange}}) " +
                "   } " +
                "   function onPlayerReady(a) {" +
                "       window.location = 'br.com.tntstudios.youtubeplayer://state=6'; " +
                "   }" +
                "   function onPlayerStateChange(d) {" +
                "       window.location = 'br.com.tntstudios.youtubeplayer://state=' + d.data; " +
                "   }" +
                "</script>" +
                "<div style='justify-content: center; align-items: center; display: flex; height: 100%;'>" +
                "   <iframe id='playerId' type='text/html' width='100%' height='100%' src='https://www.youtube.com/embed/\(youtubeVideoId)?" +
                "enablejsapi=1&rel=0&playsinline=0&autoplay=0&showinfo=0&modestbranding=1' frameborder='0'>" +
                "</div>" +
                "</body>" +
        "</html>"
        
        loadYouTubeVideo?.loadHTMLString(html, baseURL:  URL(string: "http://www.youtube.com"))
    }
    
    
    
    
}
