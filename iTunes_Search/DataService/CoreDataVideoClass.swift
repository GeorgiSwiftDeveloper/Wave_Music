//
//  FetchRecentPlayedVideo.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/19/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataVideoClass: NSObject {
    static var coreDataVideoInstance = CoreDataVideoClass()
    
    func fetchVideoWithEntityName(coreDataEntityName: String, searchBarText: String,playlistName: String, loadVideoList: @escaping(_ returnVideoList: Video?, _ returnError: Error? ) -> ()){
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
            for data in result as! [NSManagedObject] {
                let videoId = data.value(forKey: "videoId") as! String
                let title = data.value(forKey: "title") as! String
                let image = data.value(forKey: "image") as! String
                //                let channelId = data.value(forKey: "channelId") as? String ?? ""
                //                let songDescription = data.value(forKey: "songDescription") as! String
                //                let playListId = data.value(forKey: "playListId") as! String
                 let videoList = Video(videoId: videoId, videoTitle: title , videoDescription: "" , videoPlaylistId: "", videoImageUrl: image , channelId:"", genreTitle: "")
                    loadVideoList(videoList,nil)
            }
            
        } catch {
            loadVideoList(nil,error)
            print("Failed")
        }
    }
    
    func saveVideoWithEntityName(videoTitle: String,videoImage:String,videoId: String,playlistName: String, coreDataEntityName: String, loadVideoList: @escaping(_ returnVideoList: Bool?, _ returnError: Error?, _ checkIfSongAlreadyInDatabase: Bool)-> ()){
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
                loadVideoList(true,nil, false)
                print("data has been saved ")
            }else{
                print("this song is in database")
                loadVideoList(false,nil, true)
            }
        }catch{
            loadVideoList(false,error,false)
            print("error")
        }
    }
}
