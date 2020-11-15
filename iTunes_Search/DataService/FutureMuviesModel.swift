////
////  FutureMoviesModel.swift
////  iTunes_Search
////
////  Created by Georgi Malkhasyan on 4/2/20.
////  Copyright © 2020 Malkhasyan. All rights reserved.
////
//
//import UIKit
//
//protocol MuvieManagerDelegate {
//    func didUpdateAlbum(_ albumManager:FutureMuviesModel, album: [MuviesModel])
//    func didFailWithError(error: Error)
//}
//
//class FutureMuviesModel: NSObject {
//
//    var delegate: MuvieManagerDelegate?
//
//    func fetchiTunes() {
//           let url  =  "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
//           performRequest(with: url)
//       }
//       
//       func performRequest(with urlStrng: String) {
//           if let url = URL(string: urlStrng){
//               let session = URLSession(configuration: .default)
//               let task = session.dataTask(with: url) { (data, resposne, error) in
//                   if error != nil {
//                       self.delegate?.didFailWithError(error: error!)
//                       return
//                   }
//                   
//                   if let safeData = data {
//                       let futureMovies = self.parseJSON(safeData)
//                       
//                    self.delegate?.didUpdateAlbum( self, album: futureMovies!)
//                       
//                   }
//               }
//               task.resume()
//           }
//       }
//       
//       func parseJSON(_ itunesData:Data) -> [MuviesModel]? {
//           do{
//               var sharedAlbum = [MuviesModel]()
//               
//               let itunesDict = try JSONSerialization.jsonObject(with: itunesData, options: .mutableContainers) as? [String:Any]
//               let results = (itunesDict! as NSDictionary).object(forKey: "results") as? [Dictionary<String,AnyObject>]
//
//            for _ in 0..<results!.count {
//                if results != nil {
//                    let resultDict = results?.randomElement()
//                    let title = resultDict?["title"] as? String ?? ""
//                    let poster_path = resultDict?["poster_path"] as? String ?? ""
//                    let overview = resultDict?["overview"] as? String ?? ""
//                    let release_date = resultDict?["release_date"] as? String  ?? ""
//                    let album = MuviesModel(title: title, poster_path: poster_path, release_date: release_date, overview: overview)
//                    sharedAlbum.append(album)
//                }else{
//                    delegate?.didFailWithError(error: Error.self as! Error)
//                }
//            }
//               
//               return sharedAlbum
//           }catch{
//               delegate?.didFailWithError(error: error)
//               return nil
//           }
//       }
//}
