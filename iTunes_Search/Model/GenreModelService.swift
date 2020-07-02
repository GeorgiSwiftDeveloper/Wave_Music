//
//  DataService.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation

class GenreModelService {
    static let instance = GenreModelService()
 
    let genreArray = [
        GenreModel(genreImage: "rap.jpg", genreTitle: "Rap"),
        GenreModel(genreImage: "hiphop.jpg", genreTitle: "Hip-Hop"),
        GenreModel(genreImage: "pop.jpg", genreTitle: "Pop"),
        GenreModel(genreImage: "rock1.jpg", genreTitle: "Rock"),
        GenreModel(genreImage: "r&b.jpg", genreTitle: "R&B"),
        GenreModel(genreImage: "dance.jpg", genreTitle: "Dance"),
        GenreModel(genreImage: "electro.jpg", genreTitle: "Electronic"),
        GenreModel(genreImage: "jazz.jpg", genreTitle: "Jazz"),
        GenreModel(genreImage: "instrumental.jpg", genreTitle: "Instrumental"),
        GenreModel(genreImage: "blues.jpg", genreTitle: "Blues"),
        GenreModel(genreImage: "car.jpg", genreTitle: "Car Music"),
        GenreModel(genreImage: "deep.jpg", genreTitle: "Deep Bass"),
    ]
    
    func getGenreArray() -> [GenreModel] {
        return genreArray
    }
}
