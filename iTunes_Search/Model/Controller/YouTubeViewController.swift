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
    
    var genreTitle: Video?
    var youTubeVideoWebView: WKWebView!

      var getYouTubeData  = GetSelectedPlayList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        youTubeVideoWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350), configuration: webConfiguration)
        self.view.addSubview(youTubeVideoWebView)
        loadYouTubeVideoUrl()
//        getYouTubeData.getVideos(genreType: genreTitle?.videoPlaylistId) { (req, error) in
//            print(req)
//        }
        print(genreTitle?.videoDescription)
    }
    
    
    func loadYouTubeVideoUrl(){
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
                "<iframe id='playerId' type='text/html' width='100%' height='100%' src='https://www.youtube.com/embed/\(genreTitle!.videoId)?" +
                "enablejsapi=1&rel=0&playsinline=1&autoplay=0&showinfo=0&modestbranding=1' frameborder='0'>" +
                "</div>" +
                "</body>" +
        "</html>"
        youTubeVideoWebView.loadHTMLString(html, baseURL: URL(string: "http://www.youtube.com"))
    }
}
