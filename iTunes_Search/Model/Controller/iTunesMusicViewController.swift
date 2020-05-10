//
//  ViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import  YoutubePlayer_in_WKWebView
protocol SelectedMusicDelegate {
    func selectedMusicObject(_ selected: [AlbumModel])
}
let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

class iTunesMusicViewController: UIViewController,UISearchControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating {
    
    @IBOutlet weak var favoriteMusicTableView: UITableView!
    
    var iTunesConnectionManager = iTunesConnection()
    var selectedAlbumManager = FavoriteViewController()
    var favoriteAlbum = [Video]()
    var selectedMusic = [SelectedAlbumModel]()
    var selectedMusicDelegate: SelectedMusicDelegate?
    let searchController = UISearchController(searchResultsController: nil)

    
    var checkIfEmptySearchText = Bool()
 
    var selectedIndex = Int()
    var selectedVideo: Video?
    var webView = WKYTPlayerView()
    var genreVideoID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iTunesConnectionManager.delegate = self
        self.favoriteMusicTableView.delegate = self
        self.favoriteMusicTableView.dataSource = self
        setupNavBar()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        favoriteMusicTableView.reloadData()
        let checkVideoIsPlaying = UserDefaults.standard.object(forKey: "checkVideoIsPlaying") as? Bool
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        DispatchQueue.main.async {
        if checkVideoIsPlaying == true {
        if pause == nil || pause == true{
            self.showVideoPlayer()
        }else{
            self.showVideoPlayerPause()
                }
        }
    }
    }
    
    
    func showVideoPlayer(){
         VideoPlayerClass.callVideoPlayer.superViewController = self
         self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
         VideoPlayerClass.callVideoPlayer.webView.playVideo()
     }
     func showVideoPlayerPause(){
         VideoPlayerClass.callVideoPlayer.superViewController = self
         self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
         VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
     }
    
    override func viewDidDisappear(_ animated: Bool) {
            super .viewDidDisappear(animated)
            VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
            NotificationCenter.default.post(name: Notification.Name("not"), object: nil)
        }
    
    
    func setupNavBar() {
         searchController.obscuresBackgroundDuringPresentation  = false
         searchController.searchBar.placeholder = "Search"
         searchController.searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
         searchController.searchBar.sizeToFit()
         searchController.delegate = self
         searchController.searchBar.delegate = self
         searchController.searchBar.isHidden = false
         navigationItem.searchController?.searchBar.delegate = self
         navigationItem.searchController?.searchResultsUpdater = self
         navigationItem.searchController = searchController
         navigationItem.hidesSearchBarWhenScrolling = false
     }
    
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
          print("search end editing.")
          let songName = searchBar.text
          iTunesConnectionManager.fetchiTunes(name: songName!)
          searchBar.text = ""
          searchController.isActive = false
          
      }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        print("update search results ... called here")
    }
}

extension iTunesMusicViewController: AlbumManagerDelegate {
    func didUpdateAlbum(_ albumManager: iTunesConnection, album: [Video]) {
        DispatchQueue.main.async {
            if  album.count != 0 {
                self.favoriteAlbum.append(contentsOf: album)
                //self.favoriteAlbum[0].checkIfSelected = false
                DispatchQueue.main.async{
                    self.favoriteAlbum = album
                    for songIndex in 0..<self.favoriteAlbum.count{
                        let title =   self.favoriteAlbum[songIndex].videoTitle
                        let description =  self.favoriteAlbum[songIndex].videoDescription
                        let image =  self.favoriteAlbum[songIndex].videoImageUrl
                        let playlistId = self.favoriteAlbum[songIndex].videoPlaylistId
                        let videoId =  self.favoriteAlbum[songIndex].videoId
                        let channelId =  self.favoriteAlbum[songIndex].channelId
//
//                        self.saveItems(title: title, description: description, image: image, videoId: videoId, playlistId: playlistId,genreTitle: "Hits", channelId: channelId)
                    }
                      self.favoriteMusicTableView.reloadData()
                }
            }
        }
    }
    
    func didFailWithError(error: String) {
        print("\(error)")
    }
}

//extension iTunesMusicViewController: UITextFieldDelegate {
//
////    func textFieldDidEndEditing(_ textField: UITextField) {
////
////        if let songName = searchTextField.text , checkIfEmptySearchText == false{
////            self.favoriteAlbum = []
////            iTunesConnectionManager.fetchiTunes(name: songName)
////        }else{
////            let alert = UIAlertController(title: "No Playlists Found \n Add playists to Wave by tapping the search field", message: nil, preferredStyle: .alert)
////
////            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
////            }
////            alert.addAction(cancelAction)
////            present(alert, animated: true, completion: nil)
////        }
////
////        searchTextField.text = ""
////
////    }
//
////    @objc func doneButtonAction(){
////        searchTextField.resignFirstResponder()
////    }
//}
extension iTunesMusicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteAlbum.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchMusicCell", for: indexPath) as? FavoriteAlbumTableViewCell {
//            DispatchQueue.main.async {
//                if(indexPath.row == self.selectedIndex)
//                {
//                    cell.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 0.8004936733)
//                    cell.singerNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
////                    cell.favoriteButton.addTarget(self, action: #selector(self.showFavoriteAlertFunction), for: .touchUpInside)
//                    cell.favoriteButton.isHidden = false
//                }
//                else
//                {
//                    cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                    cell.singerNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//                    cell.favoriteButton.isHidden = true
//                }
//            }
            cell.confiigurationCell(albums: self.favoriteAlbum[indexPath.row])
            return cell
        }else {
            return FavoriteAlbumTableViewCell()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexRow = tableView.indexPathForSelectedRow
        let selectedCell = self.favoriteMusicTableView.cellForRow(at: selectedIndexRow!) as! FavoriteAlbumTableViewCell
        selectedIndex = indexPath.row
        selectedVideo = favoriteAlbum[indexPath.row]
        webView.load(withVideoId: "")
        genreVideoID = selectedVideo?.videoId
        VideoPlayerClass.callVideoPlayer.superViewController = self
        VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: selectedVideo!)
    }
}
