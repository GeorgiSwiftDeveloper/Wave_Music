//
//  GenreListViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import Alamofire

class GenreListViewController: UIViewController {

    @IBOutlet weak var topGenreLabelText: UILabel!
    
    var genreTitle: GenreModel?
    
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
    let YouTubeUrl = "https://www.googleapis.com/youtube/v3/playlistItems"
    override func viewDidLoad() {
        super.viewDidLoad()
        topGenreLabelText.text  = "Top \(genreTitle!.genreTitle)"
        getFeedVideos()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func getFeedVideos() {
        let parameters = ["part":"snippet","playlistId":UPLOADS_PLAYLIST_ID, "key":API_KEY]
        AF.request(YouTubeUrl, parameters: parameters).responseJSON { response in
            switch  response.result{
            case .success(let _data):
//                print(_data)
                if let JSON = response.value as? [String: Any] {
                    let listOfVideos = JSON["items"] as! NSArray
                    for videos in listOfVideos {
                        print(videos)
                    }
                }
            default:
                break
            }
//            if let JSON = response.value {
//
//                print("JSON \(JSON)")
//
//            }else{
//           debugPrint(response)
//            }
        }
    }

}
