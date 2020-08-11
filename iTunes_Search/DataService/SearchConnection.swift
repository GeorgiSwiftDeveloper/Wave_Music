//
//  iTunesConnection.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import Alamofire

protocol AlbumManagerDelegate: AnyObject {
    func didUpdateAlbum(_ albumManager:SearchConnection, album: [Video])
    func didFailWithError(error: String)
}

class SearchConnection {
   weak var searchAlbumDelegate: AlbumManagerDelegate?
    var videoArray = [Video]()
    let  API_KEY = "AIzaSyDnZJailNum2kVdCTUPpK80O8ERYBqbnX4"
    
    func fetchYouTubeData(name: String) {
        let url1 = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,channelTitle,thumbnails))&order=viewCount&q=\(name)&type=video&maxResults=15&key=\(API_KEY)"
        performRequest(with: url1)
    }
    
    
    func performRequest(with urlStrng: String) {
        
        AF.request(urlStrng, parameters: nil).responseJSON {[weak self] response in
            if let JSON = response.value as? [String: Any] {
                print(JSON)
                guard let listOfVideos = JSON["items"] as? NSArray else {return}
                var videoObjArray = [Video]()
                
                for videos in listOfVideos {
                    let videoId = (videos as AnyObject).value(forKeyPath: "id.videoId") as! String
                    let videoTitle = (videos as AnyObject).value(forKeyPath:"snippet.title") as! String
                    let videoDescription =  (videos as AnyObject).value(forKeyPath:"snippet.channelTitle") as! String
                    let videoImageUrl =  (videos as AnyObject).value(forKeyPath:"snippet.thumbnails.high.url") as! String
                    
                    let youTubeVideo  = Video(videoId: videoId, videoTitle: videoTitle, videoDescription: videoDescription, videoPlaylistId: "", videoImageUrl: videoImageUrl, channelId: "", genreTitle: "")
                    
                    videoObjArray.append(youTubeVideo)
                    
                }
                self?.searchAlbumDelegate?.didUpdateAlbum(self!, album: videoObjArray)
            }else{
                self?.searchAlbumDelegate?.didFailWithError(error: "Something whent wrong")
            }
            
        }
        
    }
}

