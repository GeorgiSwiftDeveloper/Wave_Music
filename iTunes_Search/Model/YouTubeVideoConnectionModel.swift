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
    var UPLOADS_PLAYLIST_ID = ""
    
    let YouTubeUrl = "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50"
    
    var genreTitle: GenreModel?
    var videoArray = [Video]()
    
    func getFeedVideos(genreType: String?, loadStationList: @escaping(_ returnStationList: [Video]?, _ returnError: Error? ) -> ()) {
        
        switch genreType {
        case "Rap":
            UPLOADS_PLAYLIST_ID = "PL3-sRm8xAzY-556lOpSGH6wVzyofoGpzU"
        case "Hip-Hop":
            UPLOADS_PLAYLIST_ID = "PLAPo1R_GVX4IZGbDvUH60bOwIOnZplZzM"
        case "Pop":
            UPLOADS_PLAYLIST_ID = "PLMC9KNkIncKtGvr2kFRuXBVmBev6cAJ2u"
        case "Classic Rock":
            UPLOADS_PLAYLIST_ID = "PLNxOe-buLm6cz8UQ-hyG1nm3RTNBUBv3K"
        case "R&B":
            UPLOADS_PLAYLIST_ID = "PLFbWuc6jwPGeqFkoDBq87CcmlurwrlEGv"
        case "Dance":
            UPLOADS_PLAYLIST_ID = "PL64E6BD94546734D8"
        case "Electronic":
            UPLOADS_PLAYLIST_ID = "PLFPg_IUxqnZNnACUGsfn50DySIOVSkiKI"
        case "Jazz":
            UPLOADS_PLAYLIST_ID = "PL8F6B0753B2CCA128"
        case "Instrumental":
            UPLOADS_PLAYLIST_ID = "PLsUMoyJKBqcn7dk3jC3i1023Ie-BntpgF"
        case "Blues":
            UPLOADS_PLAYLIST_ID = "PLjzeyhEA84sQKuXp-rpM1dFuL2aQM_a3S"
        default:
            break
        }
        let parameters = ["part":"snippet","playlistId":UPLOADS_PLAYLIST_ID, "key":API_KEY]
        AF.request(YouTubeUrl, parameters: parameters).responseJSON { response in
            if let JSON = response.value as? [String: Any] {
//                print(JSON)
                let listOfVideos = JSON["items"] as! NSArray
                var videoObjArray = [Video]()
                
                for videos in listOfVideos {
                    var youTubeVideo  = Video()
                    youTubeVideo.videoId = (videos as AnyObject).value(forKeyPath: "snippet.resourceId.videoId") as! String
                    youTubeVideo.videoTitle = (videos as AnyObject).value(forKeyPath:"snippet.title") as! String
                    youTubeVideo.videoDescription =  (videos as AnyObject).value(forKeyPath:"snippet.description") as! String
                    youTubeVideo.videoPlaylistId =  (videos as AnyObject).value(forKeyPath:"snippet.playlistId") as! String
                    youTubeVideo.videoImageUrl =  (videos as AnyObject).value(forKeyPath:"snippet.thumbnails.medium.url") as! String
                    youTubeVideo.channelId =  (videos as AnyObject).value(forKeyPath:"snippet.channelId") as! String
                    
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

