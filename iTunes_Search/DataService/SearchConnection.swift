//
//  iTunesConnection.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import Alamofire
protocol AlbumManagerDelegate {
    func didUpdateAlbum(_ albumManager:SearchConnection, album: [Video])
    func didFailWithError(error: String)
}

class SearchConnection {
    var delegate: AlbumManagerDelegate?
    var videoArray = [Video]()
    let  API_KEY = "AIzaSyDnZJailNum2kVdCTUPpK80O8ERYBqbnX4"
    
    func fetchYouTubeData(name: String) {
        let url1 = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,channelTitle,thumbnails))&order=viewCount&q=\(name)&type=video&maxResults=15&key=\(API_KEY)"
        performRequest(with: url1)
    }
    
    
    func performRequest(with urlStrng: String) {
        
        AF.request(urlStrng, parameters: nil).responseJSON { response in
            if let JSON = response.value as? [String: Any] {
                print(JSON)
                let listOfVideos = JSON["items"] as! NSArray
                var videoObjArray = [Video]()
                
                for videos in listOfVideos {
                    var youTubeVideo  = Video()
                    youTubeVideo.videoId = (videos as AnyObject).value(forKeyPath: "id.videoId") as! String
                    youTubeVideo.videoTitle = (videos as AnyObject).value(forKeyPath:"snippet.title") as! String
                    youTubeVideo.videoDescription =  (videos as AnyObject).value(forKeyPath:"snippet.channelTitle") as! String
                    youTubeVideo.videoImageUrl =  (videos as AnyObject).value(forKeyPath:"snippet.thumbnails.medium.url") as! String
                    videoObjArray.append(youTubeVideo)
                    
                }
                self.delegate?.didUpdateAlbum(self, album: videoObjArray)
            }else{
                self.delegate?.didFailWithError(error: "Something whent wrong")
            }
            
        }
        
    }
}

