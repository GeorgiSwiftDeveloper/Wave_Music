//
//  PlaylistByNameViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 6/19/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
class PlaylistByNameViewController: UIViewController {
    
    @IBOutlet weak var playlistNameTableView: UITableView!
    
    var videoList = [Video]()
    var selectedPlaylistName = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playlistNameTableView.delegate = self
        self.playlistNameTableView.dataSource = self
        print(selectedPlaylistName)
        fetchPlaylistVideoFromCoreData()
    }
    
    
    func fetchPlaylistVideoFromCoreData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaylistMusicData")
        request.returnsObjectsAsFaults = false
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "PlaylistMusicData", in: context!)
        //
        do {
            let result = try context?.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as? String
                let image = data.value(forKey: "image") as? String
                let videoId = data.value(forKey: "videoId") as? String
                let fetchedVideoList = Video(videoId: videoId, videoTitle: title, videoDescription: "", videoPlaylistId: "", videoImageUrl: image, channelId:"")
                videoList = []
                self.videoList.append(fetchedVideoList)
                playlistNameTableView.reloadData()
            }
        } catch {
            
            print("Failed")
        }
    }
    
}

extension PlaylistByNameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  playlistCell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? SelectedSectionTableViewCell
        
        playlistCell?.configureRecentlyPlayedCell(videoList[indexPath.row])
        return playlistCell!
    }
    
    
}
