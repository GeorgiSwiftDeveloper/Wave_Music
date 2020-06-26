//
//  YouTubeVideo.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation

struct Video {
    var videoId: String?
    var videoTitle: String?
    var videoDescription: String?
    var videoPlaylistId: String?
    var videoImageUrl: String?
    var channelId: String?
    var genreTitle: String?
    
    
    init(videoId: String,videoTitle: String,videoDescription:String,videoPlaylistId:String,videoImageUrl:String,channelId:String,genreTitle:String) {
        self.videoId = videoId
        self.videoTitle = videoTitle
        self.videoDescription = videoDescription
        self.videoPlaylistId = videoPlaylistId
        self.videoImageUrl = videoImageUrl
        self.channelId = channelId
        self.genreTitle = genreTitle
    }
}
