//
//  GenreListViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import  YoutubePlayer_in_WKWebView

class GenreListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var genreBottomNSLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var genreTableView: UITableView!
    
    
    var genreModel: GenreModel?
    var videoArray = [Video]()
    var webView = WKYTPlayerView()
    var entityName = String()
    var youTubeVideoID =  String()
    var youTubeVideoTitle =  String()
    var selectedIndex = Int()
    var searchIsSelected = Bool()
    var selectedmyLybrary = Bool()
    
    var isEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.takeGenreName(genreModel!.genreTitle))
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title  = "  Top \(genreModel!.genreTitle) Song's"
        genreTableView.delegate = self
        genreTableView.dataSource = self
        if isEmpty{
            YouTubeVideoConnection.getYouTubeVideoInstace.getYouTubeVideo(genreType: self.genreModel!.genreTitle, selectedViewController: "GenreListViewController") { (loadVideolist, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }else{
                    self.videoArray = loadVideolist!
                    for songIndex in 0..<self.videoArray.count{
                        let title =   self.videoArray[songIndex].videoTitle ?? ""
                        //                        let description =  self.videoArray[songIndex].videoDescription ?? ""
                        let image =  self.videoArray[songIndex].videoImageUrl ?? ""
                        //                        let playlistId = self.videoArray[songIndex].videoPlaylistId ?? ""
                        let videoId =  self.videoArray[songIndex].videoId ?? ""
                        //                        let channelId =  self.videoArray[songIndex].channelId ?? ""
                        let genreTitle = self.videoArray[songIndex].genreTitle ?? ""
                        
                        CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: title, videoImage: image, videoId: videoId, playlistName: "", coreDataEntityName:self.takeGenreName(genreTitle)) { (checkIfSaveIsSuccessful, error, checkIfSongAlreadyInDatabase) in
                            if error != nil {
                                print(error?.localizedDescription as Any)
                            }
                        }
                        DispatchQueue.main.async {
                            self.genreTableView.reloadData()
                        }
                    }
                }
            }
        }else{
            fetchVideoWithEntityName()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        switch pause {
        case true:
            VideoPlayer.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayer.callVideoPlayer.cardViewController.view)
            VideoPlayer.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
                if let error = error {
                    print("Error getting player state:" + error.localizedDescription)
                } else if let playerState = playerState as? WKYTPlayerState {
                    
                    self?.updatePlayerState(playerState)
                }
            })
        case false:
            VideoPlayer.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayer.callVideoPlayer.cardViewController.view)
            VideoPlayer.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
                if let error = error {
                    print("Error getting player state:" + error.localizedDescription)
                } else if let playerState = playerState as? WKYTPlayerState {
                    
                    self?.updatePlayerState(playerState)
                }
            })
        default:
            break
        }
        self.navigationController?.navigationBar.isHidden = false
        ActivityIndecator.activitySharedInstace.activityIndecator(self.view, genreTableView)
    }
    
    func updatePlayerState(_ playerState: WKYTPlayerState){
        switch playerState {
        case .ended:
            self.showVideoPlayerPause()
        case .paused:
            self.showVideoPlayerPause()
        case .playing:
            self.showVideoPlayer()
        default:
            break
        }
    }
    
    func showVideoPlayer(){
        VideoPlayer.callVideoPlayer.webView.playVideo()
        self.genreBottomNSLayoutConstraint.constant = 150
        self.view.layoutIfNeeded()
    }
    
    func showVideoPlayerPause(){
        VideoPlayer.callVideoPlayer.superViewController = self
        self.view.addSubview(VideoPlayer.callVideoPlayer.cardViewController.view)
        VideoPlayer.callVideoPlayer.webView.pauseVideo()
        self.genreBottomNSLayoutConstraint.constant = 150
        self.view.layoutIfNeeded()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        VideoPlayer.callVideoPlayer.cardViewController.removeFromParent()
    }
    
    
    
    func takeGenreName(_ genreName: String) -> String {
        switch genreName {
        case "Rap":
            self.entityName = "YouTubeDataModel"
        case "Hip-Hop":
            self.entityName = "YouTubeHipHopData"
        case "Pop":
            self.entityName = "YouTubePopData"
        case "Rock":
            self.entityName = "YouTubeRockData"
        case "R&B":
            self.entityName = "YouTubeRBData"
        case "Dance":
            self.entityName = "YouTubeDanceData"
        case "Electronic":
            self.entityName = "YouTubeElectronicData"
        case "Jazz":
            self.entityName = "YouTubeJazzData"
        case "Instrumental":
            self.entityName = "YouTubeInstrumentalData"
        case "Blues":
            self.entityName = "YouTubeBluesData"
        case "Car Music":
            self.entityName = "YouTubeCarMusicData"
        case "Deep Bass":
            self.entityName = "YouTubeDeepBassData"
        default:
            break
        }
        return entityName
    }
    
    func fetchVideoWithEntityName(){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: self.takeGenreName(genreModel!.genreTitle), searchBarText: "", playlistName: "") { (videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if videoList != nil {
                    self.videoArray.append(videoList!)
                    self.genreTableView.reloadData()
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: genreTableViewCellIdentifier, for: indexPath) as? GenreVideoTableViewCell {
            cell.addToFavoriteButton.addTarget(self, action: #selector(addToFavoriteTapped), for: .touchUpInside)
            cell.addToFavoriteButton.tag = indexPath.row;
            DispatchQueue.main.async {
                cell.configureGenreCell(self.videoArray[indexPath.row])
                
            }
            return cell
        }else {
            return GenreVideoTableViewCell()
        }
    }
    
    
    @objc func addToFavoriteTapped(sender: UIButton){
        let selectedRow = IndexPath(row: sender.tag, section: 0)
        self.genreTableView.selectRow(at: selectedRow, animated: true, scrollPosition: .none)
        let selectedCell = self.genreTableView.cellForRow(at: selectedRow) as! GenreVideoTableViewCell
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myLibraryEntityName)
        let predicate = NSPredicate(format: "title == %@", selectedCell.singerNameLabel.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        
        
        let alert = UIAlertController(title: "\(selectedCell.singerNameLabel.text ?? "")", message: "", preferredStyle: .actionSheet)
        let addMyLibraryAction = UIAlertAction(title: "Add to MyLibrary", style: .default) { (action) in
            do{
                let count = try context?.count(for: request)
                if(count == 0){
                    let entity = NSEntityDescription.entity(forEntityName: myLibraryEntityName, in: context!)
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(selectedCell.singerNameLabel.text, forKey: "title")
                    newEntity.setValue(selectedCell.videoImageUrl, forKey: "image")
                    newEntity.setValue(selectedCell.videoID, forKey: "videoId")
                    try context?.save()
                    print("data has been saved ")
                    let selectedImageViewUrl = selectedCell.videoImageUrl
                    AlertView.instance.showAlert(title: "\(selectedCell.singerNameLabel.text ?? "")", message: "Successfuly added to MyLibrary list", alertType: .success, videoImage: selectedImageViewUrl)
                } else{
                    // at least one matching object exists
                    let alert = UIAlertController(title: "Please check your Library", message: "This song is already exist in your library list", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }catch{
                print("error")
            }
        }
        
        
        let addPlaylistAction = UIAlertAction(title: "Add to Playlist", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.selectedIndex = 3
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(addMyLibraryAction)
        alert.addAction(addPlaylistAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <=  0.000000 {
            ActivityIndecator.activitySharedInstace.activityIndicatorView.startAnimating()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.genreBottomNSLayoutConstraint.constant = 150
            let selectedCell = self.genreTableView.cellForRow(at: indexPath) as! GenreVideoTableViewCell
            VideoPlayer.callVideoPlayer.superViewController = self
            VideoPlayer.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: selectedCell.videoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle:selectedCell.singerNameLabel.text!)
            
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.singerNameLabel.text!, videoImage: selectedCell.videoImageUrl, videoId: selectedCell.videoID, playlistName: "", coreDataEntityName: recentPlayedEntityName) { (checkIfLoadIsSuccessful, error, checkIfSongAlreadyInDatabase) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
        }
        
    }
}
