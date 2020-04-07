//
//  iTunesConnection.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

protocol AlbumManagerDelegate {
    func didUpdateAlbum(_ albumManager:iTunesConnection, album: [AlbumModel])
    func didFailWithError(error: Error)
}

class iTunesConnection {
    var delegate: AlbumManagerDelegate?
    func fetchiTunes(name: String) {
        let url  =  "https://itunes.apple.com/search?term=\(name)&media=music"
        performRequest(with: url)
    }
    
    
    func performRequest(with urlStrng: String) {
        if let url = URL(string: urlStrng){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, resposne, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let itunes = self.parseJSON(safeData)
                    
                    self.delegate?.didUpdateAlbum( self, album: itunes!)
                    
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ itunesData:Data) -> [AlbumModel]? {
        do{
            var sharedAlbum = [AlbumModel]()
            
            let itunesDict = try JSONSerialization.jsonObject(with: itunesData, options: .mutableContainers) as? [String:Any]
            let results = (itunesDict! as NSDictionary).object(forKey: "results") as? [Dictionary<String,AnyObject>]
            if results != nil {
                for _ in 0..<results!.count{
                    
                let resultDict = results?.randomElement()
                let artist = resultDict?["artistName"] as? String ?? ""
                let artworkUrl = resultDict?["artworkUrl100"] as? String ?? ""
                let albumTitle = resultDict?["collectionName"] as? String ?? ""
                let genre = resultDict?["primaryGenreName"] as? String  ?? ""
                let trackViewUrl = resultDict?["trackViewUrl"] as? String  ?? ""
                let album = AlbumModel(title: albumTitle, artist: artist, genre: genre, artworkURL:artworkUrl, trackViewUrl: trackViewUrl)
                    sharedAlbum.append(album)
                }
            }else{
                delegate?.didFailWithError(error: Error.self as! Error)
            }
            return sharedAlbum
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

