//
//  AlbumModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class AlbumModel: NSObject {
    var title: String?
    var artist: String?
    var genre: String?
    var artworkURL: String?
    var trackViewUrl: String?
    var previewUrl: String?
    
    init(title: String, artist:String, genre:String,artworkURL:String, trackViewUrl: String,previewUrl: String) {
    
            self.title = title
            self.artist = artist
            self.genre = genre
            self.artworkURL = artworkURL
            self.trackViewUrl = trackViewUrl
            self.previewUrl = previewUrl
    
        }
}
