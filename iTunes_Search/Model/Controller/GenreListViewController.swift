//
//  GenreListViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import Alamofire

class GenreListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var topGenreLabelText: UILabel!
    
    @IBOutlet weak var genreTableView: UITableView!
    var genreTitle: GenreModel?
    var videoArray = [Video]()
    var getYouTubeData  = YouTubeVideoConnection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topGenreLabelText.text  = "Top \(genreTitle!.genreTitle) Song's"
        genreTableView.delegate = self
        genreTableView.dataSource = self
        getYouTubeData.getFeedVideos(genreType: genreTitle!.genreTitle) { (loadVideolist, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else{
                DispatchQueue.main.async{
                self.videoArray = loadVideolist!
                self.genreTableView.reloadData()
            }
        }
    }
}


override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
}


func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videoArray.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath) as? GenreVideoTableViewCell {
        cell.configureGenreCell(videoArray[indexPath.row])
        return cell
    }else {
        return GenreVideoTableViewCell()
    }
}


}
