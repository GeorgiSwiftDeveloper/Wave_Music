//
//  YouTubeVideoConnectionModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import Alamofire

class  YouTubeVideoConnection {
    
    
    
    let API_KEY = "AIzaSyASK8aArpUEg1OnKYTSYUoqyHqBQicQfHE"
    let UPLOADS_PLAYLIST_ID = "PL3-sRm8xAzY-556lOpSGH6wVzyofoGpzU"
    let UPLOADS_PLAYLIST_ID_HIP_HOP = "PLAPo1R_GVX4IZGbDvUH60bOwIOnZplZzM"
    let UPLOADS_PLAYLIST_ID_POP = "PLMC9KNkIncKtGvr2kFRuXBVmBev6cAJ2u"
    let UPLOADS_PLAYLIST_ID_ROCK = "PL6Lt9p1lIRZ311J9ZHuzkR5A3xesae2pk"
    let UPLOADS_PLAYLIST_ID_R_B = "PLFbWuc6jwPGeqFkoDBq87CcmlurwrlEGv"
    let UPLOADS_PLAYLIST_ID_DANCE = "PL64E6BD94546734D8"
    let UPLOADS_PLAYLIST_ID_ELECTRONIC = "PLFPg_IUxqnZNnACUGsfn50DySIOVSkiKI"
    let UPLOADS_PLAYLIST_ID_JAZZ = "PL8F6B0753B2CCA128"
    let UPLOADS_PLAYLIST_ID_INSTRUMENTAL = "PLsUMoyJKBqcn7dk3jC3i1023Ie-BntpgF"
    let UPLOADS_PLAYLIST_ID_BLUES = "PLjzeyhEA84sQKuXp-rpM1dFuL2aQM_a3S"
    
    let YouTubeUrl = "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50"
    
    var genreTitle: GenreModel?
    var videoArray = [Video]()
    
    func getFeedVideos(genreType: String?, loadStationList: @escaping(_ returnStationList: [Video]?, _ returnError: Error? ) -> ()) {
        let parameters = ["part":"snippet","playlistId":UPLOADS_PLAYLIST_ID, "key":API_KEY]
        AF.request(YouTubeUrl, parameters: parameters).responseJSON { response in
            if let JSON = response.value as? [String: Any] {
                print(JSON)
                let listOfVideos = JSON["items"] as! NSArray
                var videoObjArray = [Video]()
                
                for videos in listOfVideos {
//                                            print(videos)
                    var youTubeVideo  = Video()
                    youTubeVideo.videoId = (videos as AnyObject).value(forKeyPath: "snippet.resourceId.videoId") as! String
                    youTubeVideo.videoTitle = (videos as AnyObject).value(forKeyPath:"snippet.title") as! String
                    youTubeVideo.videoDescription =  (videos as AnyObject).value(forKeyPath:"snippet.description") as! String
                    youTubeVideo.videoPlaylistId =  (videos as AnyObject).value(forKeyPath:"snippet.playlistId") as! String
                    youTubeVideo.videoImageUrl =  (videos as AnyObject).value(forKeyPath:"snippet.thumbnails.medium.url") as! String
                    
                    videoObjArray.append(youTubeVideo)
                }
                
                self.videoArray = videoObjArray
                loadStationList(self.videoArray,nil)
            }else{
                loadStationList(nil,Error.self as? Error)
            }
        }
    }
}

