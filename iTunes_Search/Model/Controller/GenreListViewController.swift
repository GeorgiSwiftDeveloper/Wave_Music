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
    var arrrayInt = Int()
    
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
                    for songIndex in 0..<self.videoArray.count{
                    let title =   self.videoArray[songIndex].videoTitle
                    let description =  self.videoArray[songIndex].videoDescription
                    let image =  self.videoArray[songIndex].videoImageUrl
                    let playlistId = self.videoArray[songIndex].videoPlaylistId
                    let videoId =  self.videoArray[songIndex].videoId
                    
                    }
                
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
        arrrayInt = indexPath.row
//        print(arrrayInt)
        return cell
    }else {
        return GenreVideoTableViewCell()
    }
}


}
