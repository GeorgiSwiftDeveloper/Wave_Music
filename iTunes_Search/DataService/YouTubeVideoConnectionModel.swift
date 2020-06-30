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
    var API_KEY = ""
    var UPLOADS_PLAYLIST_ID = ""
    
    let YouTubeUrl = "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=20&utoplay=0"
    
    var genreTitle: GenreModel?
    var videoArray = [Video]()
    
    func getYouTubeVideo(genreType: String?,selectedViewController: String, loadYouTubeList: @escaping(_ returnYoutubeList: [Video]?, _ returnError: Error? ) -> ()) {
        
        switch selectedViewController {
        case "GenreListViewController":
            
            API_KEY = "AIzaSyDnZJailNum2kVdCTUPpK80O8ERYBqbnX4"
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
            case "Car Music":
                UPLOADS_PLAYLIST_ID = "RDQMLL-TQCYO44I"
            case "Deep Bass":
                UPLOADS_PLAYLIST_ID = "PLJmFLIy2AgO_jmMr5zh6c6HfAV0WZ9SWl"
            default:
                break
            }
        case "MyLibraryViewController":
            API_KEY = "AIzaSyD_ftHSeTLdHnAqtUv-pnWW8jOXv5TFZg8"
            switch genreType {
            case "Hits":
                UPLOADS_PLAYLIST_ID = "PLyORnIW1xT6waC0PNjAMj33FdK2ngL_ik"
            default:
                break
            }
        default:
            break
        }
        
        let parameters = ["part":"snippet","playlistId":UPLOADS_PLAYLIST_ID, "key":API_KEY]
        AF.request(YouTubeUrl, parameters: parameters).responseJSON { response in
            if let JSON = response.value as? [String: Any] {
                print(JSON)
                guard  let listOfVideos = JSON["items"] as? NSArray else {return}
                
                var videoObjArray = [Video]()
                
                for videos in listOfVideos {
                    let videoId = (videos as AnyObject).value(forKeyPath: "snippet.resourceId.videoId") as! String
                    let videoTitle = (videos as AnyObject).value(forKeyPath:"snippet.title") as! String
                    let videoDescription =  (videos as AnyObject).value(forKeyPath:"snippet.description") as! String
                    let videoPlaylistId =  (videos as AnyObject).value(forKeyPath:"snippet.playlistId") as! String
                    let videoImageUrl =  (videos as AnyObject).value(forKeyPath:"snippet.thumbnails.high.url") as! String
                    let channelId =  (videos as AnyObject).value(forKeyPath:"snippet.channelId") as! String
                    let genreTitle = genreType!
                    
                    let youTubeVideo  = Video(videoId: videoId, videoTitle: videoTitle, videoDescription: videoDescription, videoPlaylistId: videoPlaylistId, videoImageUrl: videoImageUrl, channelId: channelId, genreTitle: genreTitle)
                    videoObjArray.append(youTubeVideo)
                }
                
                self.videoArray = videoObjArray
                loadYouTubeList(self.videoArray,nil)
            }else{
                loadYouTubeList(nil,Error.self as? Error)
            }
        }
    }
}

