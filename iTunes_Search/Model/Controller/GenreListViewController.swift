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
        ActivityIndecator.activitySharedInstace.activityIndecator(self.view, genreTableView)
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
        iFMyLybraryOrSearchSelected()
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierSelectionLibraryRowSelected(notification:)), name: Notification.Name("NotificationIdentifierSelectionLibraryRowSelected"), object: nil)
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        switch pause {
        case true:
            VideoPlayerClass.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
            VideoPlayerClass.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
                if let error = error {
                    print("Error getting player state:" + error.localizedDescription)
                } else if let playerState = playerState as? WKYTPlayerState {
                    
                    self?.updatePlayerState(playerState)
                }
            })
        case false:
            VideoPlayerClass.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
            VideoPlayerClass.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
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
        VideoPlayerClass.callVideoPlayer.webView.playVideo()
        self.genreBottomNSLayoutConstraint.constant = 150
        self.view.layoutIfNeeded()
    }
    
    func showVideoPlayerPause(){
        VideoPlayerClass.callVideoPlayer.superViewController = self
        self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        self.genreBottomNSLayoutConstraint.constant = 150
        self.view.layoutIfNeeded()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
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
                    DispatchQueue.main.async {
                        self.genreTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    func iFMyLybraryOrSearchSelected() {
        DispatchQueue.main.async {
            if self.searchIsSelected == true {
                UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
                self.genreTableView.reloadData()
            }
            self.searchIsSelected = false
        }
        
        
        DispatchQueue.main.async {
            if self.selectedmyLybrary == true {
                UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
                self.genreTableView.reloadData()
            }
            self.selectedmyLybrary = false
        }
        
        let selectedSearch = UserDefaults.standard.object(forKey: "selectedSearch") as? Bool
        if selectedSearch == true {
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
                self.genreTableView.reloadData()
                
            }
        }
        
        let selectedmyLybrary = UserDefaults.standard.object(forKey: "selectedmyLybrary") as? Bool
        if selectedmyLybrary == true {
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
                self.genreTableView.reloadData()
                
            }
        }
    }
    
    @objc func NotificationIdentifierSelectionLibraryRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
        genreTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath) as? GenreVideoTableViewCell {
            cell.addToFavoriteButton.addTarget(self, action: #selector(addToFavoriteTapped), for: .touchUpInside)
            cell.addToFavoriteButton.tag = indexPath.row;
            cell.configureGenreCell(videoArray[indexPath.row])
            return cell
        }else {
            return GenreVideoTableViewCell()
        }
    }
    
    
    @objc func addToFavoriteTapped(sender: UIButton){
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        self.genreTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        let selectedCell = self.genreTableView.cellForRow(at: selectedIndex) as! GenreVideoTableViewCell
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        let predicate = NSPredicate(format: "title == %@", selectedCell.singerNameLabel.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        
        
        let alert = UIAlertController(title: "\(selectedCell.singerNameLabel.text ?? "")", message: "", preferredStyle: .actionSheet)
        let addMyLibraryAction = UIAlertAction(title: "Add to MyLibrary", style: .default) { (action) in
            do{
                let count = try context?.count(for: request)
                if(count == 0){
                    let entity = NSEntityDescription.entity(forEntityName: "MyLibraryMusicData", in: context!)
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
         NSLog("Table view scroll detected at offset: %f", scrollView.contentOffset.y)
         if scrollView.contentOffset.y <=  0.000000 {
               ActivityIndecator.activitySharedInstace.activityIndicatorView.startAnimating()
         }
     }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            UserDefaults.standard.set(true, forKey:"checkGenreRowIsSelected")
            UserDefaults.standard.set(false, forKey:"selectedSearch")
            UserDefaults.standard.set(false, forKey:"selectedmyLybrary")
            self.selectedIndex = indexPath.row
            UserDefaults.standard.set(self.selectedIndex, forKey:"saveGenreSelectedIndex")
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierGenreRowSelected"), object: nil)
            self.genreBottomNSLayoutConstraint.constant = 150
            let selectedCell = self.genreTableView.cellForRow(at: indexPath) as! GenreVideoTableViewCell
//            for i in 0..<self.videoArray.count{
//                self.youTubeVideoID.append(self.videoArray[i].videoId ?? "")
//                self.youTubeVideoTitle.append(self.videoArray[i].videoTitle ?? "")
//            }
            self.youTubeVideoID = selectedCell.videoID
            self.youTubeVideoTitle = selectedCell.singerNameLabel.text!
            self.webView.load(withVideoId: "")
            VideoPlayerClass.callVideoPlayer.superViewController = self
            VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
            
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.singerNameLabel.text!, videoImage: selectedCell.videoImageUrl, videoId: selectedCell.videoID, playlistName: "", coreDataEntityName: "RecentPlayedMusicData") { (checkIfLoadIsSuccessful, error, checkIfSongAlreadyInDatabase) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
            }
            
            self.genreTableView.reloadData()
        }
        
    }
}
