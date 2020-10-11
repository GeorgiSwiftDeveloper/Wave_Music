//
//  FetchRecentPlayedVideo.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/19/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

protocol CheckIfSelectedSongIsExsistInDatabaseDelegate: AnyObject {
    func ifSelectedSongIsExsistInDatabase(_ coreDataMananger: CoreDataVideoClass, _ ifAlreadyInDatabase: Bool)
}

class CoreDataVideoClass: NSObject {
    
    
    static var coreDataVideoInstance = CoreDataVideoClass()
    
    weak var selectedSongIsAlreadyExsistInDatabase: CheckIfSelectedSongIsExsistInDatabaseDelegate?
    
    func fetchVideoWithEntityName(coreDataEntityName: String, searchBarText: String,playlistName: String, loadVideoList: @escaping(_ returnVideoList: [Video]?, _ returnError: Error? ) -> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntityName)
        
        if searchBarText != "" {
            let predicate = NSPredicate(format: "title contains[c]%@", searchBarText as CVarArg)
            request.predicate = predicate
            
        }else if playlistName != ""{
            let predicate = NSPredicate(format: "playlistName == %@", playlistName as CVarArg)
            request.predicate = predicate
        }
        request.returnsObjectsAsFaults = false
        
        do {
            guard  let result = try context?.fetch(request) else {return}
            print(result.count)
            var videoArray = [Video]()
            var videoList: Video
            
            for data in result as! [NSManagedObject] {
                
                let videoId = data.value(forKey: "videoId") as? String ?? ""
                let title = data.value(forKey: "title") as? String ?? ""
                let image = data.value(forKey: "image") as? String ?? ""
                
                if videoId != "" && title != "" && image != "" {
                    videoList = Video(videoId: videoId, videoTitle: title , videoDescription: "" , videoPlaylistId: "", videoImageUrl: image , channelId:"", genreTitle: "")
                    videoArray.append(videoList)
                }
//                let videoList = Video(videoId: videoId, videoTitle: title , videoDescription: "" , videoPlaylistId: "", videoImageUrl: image , channelId:"", genreTitle: "")
//                videoArray.append(videoList)

            }
                loadVideoList(videoArray,nil)
        } catch {
            loadVideoList(nil,error)
            print("Failed")
        }
    }
    
    func saveVideoWithEntityName(videoTitle: String,videoImage:String,videoId: String,playlistName: String, coreDataEntityName: String, loadVideoList: @escaping(_ returnError: Error?)-> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntityName)
        if playlistName != ""{
            let predicate = NSPredicate(format: "title == %@ AND playlistName == %@", argumentArray: [videoTitle, playlistName])
            request.predicate = predicate
        }else{
            let predicate = NSPredicate(format: "title == %@", videoTitle as CVarArg)
            request.predicate = predicate
        }
        do{
            let count = try context?.count(for: request)
            if(count == 0){
                // no matching object
                let entity = NSEntityDescription.entity(forEntityName: coreDataEntityName, in: context!)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                newEntity.setValue(videoTitle, forKey: "title")
                newEntity.setValue(videoImage, forKey: "image")
                newEntity.setValue(videoId, forKey: "videoId")
                if playlistName != ""{
                    newEntity.setValue(playlistName, forKey: "playlistName")
                }
                try context?.save()
                loadVideoList(nil)
                selectedSongIsAlreadyExsistInDatabase?.ifSelectedSongIsExsistInDatabase(self, false)
                print("data has been saved ")
            }else{
                print("this song is in database")
                selectedSongIsAlreadyExsistInDatabase?.ifSelectedSongIsExsistInDatabase(self, true)
                loadVideoList(nil)
            }
        }catch{
            loadVideoList(error)
            print("error")
        }
    }
}
