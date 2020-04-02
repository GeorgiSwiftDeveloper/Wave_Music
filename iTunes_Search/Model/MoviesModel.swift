//
//  MoviesModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/2/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class MoviesModel: NSObject {
    var title: String?
    var poster_path: String?
    var release_date: String?
    var overview: String?
    
    init(title: String, poster_path:String, release_date:String,overview:String) {
    
            self.title = title
            self.poster_path = poster_path
            self.release_date = release_date
            self.overview = overview
    
        }
}
