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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPlaylistVideoFromCoreData()
    }
    
    
    func fetchPlaylistVideoFromCoreData(){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: playlistEntityName, searchBarText: "") { (fetchVideoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if fetchVideoList != nil {
                    self.videoList = []
                    self.videoList.append(fetchVideoList!)
                    DispatchQueue.main.async {
                        self.playlistNameTableView.reloadData()
                    }
                }
            }
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
