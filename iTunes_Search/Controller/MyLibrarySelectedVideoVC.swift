//
//  MyLibrarySelectedVideoVC.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/25/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import WebKit
class MyLibrarySelectedVideoVC: UIViewController,WKNavigationDelegate {
    

    @IBOutlet weak var youTubeWebView: WKWebView!
    
    var myLibraryVideo = MyLibraryViewController()
    var videoID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//  NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifMyLibrrarySelectedVideo(notification:)), name: Notification.Name("MyLibrrarySelectedVideo"), object: nil)
//        myLibraryVideo.selectedVideoIDdelegate = self
//        let webConfiguration = WKWebViewConfiguration()
//               webConfiguration.allowsInlineMediaPlayback = true
//               webConfiguration.mediaTypesRequiringUserActionForPlayback = []
//               self.view.addSubview(youTubeWebView)
//        loadYouTubeVideoUrl(genreVidoID: videoID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
               DispatchQueue.main.async {
        let webConfiguration = WKWebViewConfiguration()
                    webConfiguration.allowsInlineMediaPlayback = true
                    webConfiguration.mediaTypesRequiringUserActionForPlayback = []
                self.view.addSubview(self.youTubeWebView)
                self.loadYouTubeVideoUrl(genreVidoID: self.videoID)
        }
    }
    
//    @objc func NotificationIdentifMyLibrrarySelectedVideo(notification: Notification) {
//       loadYouTubeVideoUrl(genreVidoID: <#T##String#>)
//    }
    
    
//    func videoID(videoID: String) {
//          loadYouTubeVideoUrl(genreVidoID: videoID)
//      }
    
  
    func loadYouTubeVideoUrl(genreVidoID: String){
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
                  "<iframe id='playerId' type='text/html' width='100%' height='100%' src='https://www.youtube.com/embed/\(genreVidoID)?" +
                  "enablejsapi=1&rel=0&playsinline=1&autoplay=0&showinfo=0&modestbranding=1' frameborder='0'>" +
                  "</div>" +
                  "</body>" +
          "</html>"
          youTubeWebView.loadHTMLString(html, baseURL: URL(string: "http://www.youtube.com"))
      }
}
