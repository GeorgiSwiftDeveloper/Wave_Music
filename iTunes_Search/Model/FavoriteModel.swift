//
//  FavoriteModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
 class FavoriteModel {
    var title: String!
    var artist: String!
    
    var artworkURL: String!
    
    init(title: String, artist:String,artworkURL:String) {
        
        self.title = title
        self.artist = artist
        
        self.artworkURL = artworkURL
        
        
    }
 }
