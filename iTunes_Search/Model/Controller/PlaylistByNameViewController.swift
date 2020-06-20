//
//  PlaylistByNameViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 6/19/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class PlaylistByNameViewController: UIViewController {
    
    @IBOutlet weak var playlistNameTableView: UITableView!
    
    var videoList = [Video]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playlistNameTableView.delegate = self
        self.playlistNameTableView.dataSource = self
        
        
    }
    
    
    
    
}

extension PlaylistByNameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  playlistCell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? SelectedSectionTableViewCell
        
        //        playlistCell?.configureRecentlyPlayedCell(videoList[indexPath.row])
        return playlistCell!
    }
    
    
}
