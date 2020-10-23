//
//  GenreModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/15/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class GenreModel: NSObject {
    var genreImage: String?
    var genreTitle: String?
    
    
    init(genreImage: String, genreTitle:String) {
        self.genreImage = genreImage
        self.genreTitle = genreTitle
    }
}
