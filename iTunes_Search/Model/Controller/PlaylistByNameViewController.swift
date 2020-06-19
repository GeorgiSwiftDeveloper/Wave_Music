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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.playlistNameTableView.delegate = self
        self.playlistNameTableView.dataSource = self
    }
    

 

}

extension PlaylistByNameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  playlistCell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as? MainLibrariMusciTableViewCell
             

        return playlistCell!
    }
    
    
}
