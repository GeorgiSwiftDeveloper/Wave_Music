//
//  GetSelectedMusicPlaylist.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/20/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import Alamofire
class GetSelectedPlayList {
     let API_KEY = "AIzaSyBI-iZ4gcuK_TB8vfRTLBdQjH2PvfX8GE4"
     var videoArray = [Video]()
    
     let youTubeUrl = "https://www.googleapis.com/youtube/v3/playlists?maxResults=5"
            func getVideos(genreType: String?, loadStationList: @escaping(_ returnStationList: [Video]?, _ returnError: Error? ) -> ()) {
                let a  = "https://www.googleapis.com/youtube/v3/playlists"
                let parameters = ["part":"snippet","channelId":"UC0C-w0YjGpqDXGB8IHb662A", "key":API_KEY]
                AF.request(youTubeUrl, parameters: parameters).responseJSON { response in
                    if let JSON = response.value as? [String: Any] {
                        print(JSON)
//                        let listOfVideos = JSON["items"] as AnyObject?
                        var videoObjArray = [Video]()
                        
    //                    for videos in listOfVideos {
    //                        var youTubeVideo  = Video()
    //                        youTubeVideo.videoId = (videos as AnyObject).value(forKeyPath: "snippet.resourceId.videoId") as! String
    //                        youTubeVideo.videoTitle = (videos as AnyObject).value(forKeyPath:"snippet.title") as! String
    //                        youTubeVideo.videoDescription =  (videos as AnyObject).value(forKeyPath:"snippet.description") as! String
    //                        youTubeVideo.videoPlaylistId =  (videos as AnyObject).value(forKeyPath:"snippet.playlistId") as! String
    //                        youTubeVideo.videoImageUrl =  (videos as AnyObject).value(forKeyPath:"snippet.thumbnails.medium.url") as! String
    //                        youTubeVideo.channelId =  (videos as AnyObject).value(forKeyPath:"snippet.channelId") as! String
    //
    //                        videoObjArray.append(youTubeVideo)
    //                    }
                        
    //                    self.videoArray = videoObjArray
                        loadStationList(self.videoArray,nil)
                    }else{
                        loadStationList(nil,Error.self as? Error)
                    }
                }
            }
}
