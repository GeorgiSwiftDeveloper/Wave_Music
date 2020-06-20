//
//  FetchRecentPlayedVideo.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/19/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

class FetchRecentPlayedVideo: NSObject {
static var fetchVideoInstance = FetchRecentPlayedVideo()
    
    func fetchVideoWithEntityName(loadVideoList: @escaping(_ returnVideoList: Video?, _ returnError: Error? ) -> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentPlayedMusicData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as! String
                let image = data.value(forKey: "image") as! String
                let videoId = data.value(forKey: "videoId") as! String
                let fetchedVideoList = Video(videoId: videoId, videoTitle: title, videoDescription: "", videoPlaylistId: "", videoImageUrl: image, channelId:"")
                loadVideoList(fetchedVideoList,nil)
            }
            
        } catch {
            loadVideoList(nil,error)
            print("Failed")
        }
    }
    
    func saveVideoWithEntityName(selectedCellTitleLabel: String,selectedCellImageViewUrl:String,selectedCellVideoID: String, coreDataEntityName: String, loadVideoList: @escaping(_ returnVideoList: Bool?, _ returnError: Error?)-> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntityName)
        let predicate = NSPredicate(format: "title == %@", selectedCellTitleLabel as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        do{
            let count = try context?.count(for: request)
            if(count == 0){
                // no matching object
                let entity = NSEntityDescription.entity(forEntityName: coreDataEntityName, in: context!)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                newEntity.setValue(selectedCellTitleLabel, forKey: "title")
                newEntity.setValue(selectedCellImageViewUrl, forKey: "image")
                newEntity.setValue(selectedCellVideoID, forKey: "videoId")
                try context?.save()
                loadVideoList(true,nil)
                print("data has been saved ")
            }else{
                print("this song is in database")
            }
        }catch{
            loadVideoList(false,error)
            print("error")
        }
    }
}
