//
//  SingerModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 7/26/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import UIKit

struct SingerResponse: Decodable {
    var album : Singer
}


class Singer: Decodable {
    var actors: String
    var title: String
    
    
    init(title: String, actors: String) {
        self.title = title
        self.actors = actors
    }
}
