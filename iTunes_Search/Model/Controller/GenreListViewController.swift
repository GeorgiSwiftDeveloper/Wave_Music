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
    var genreTitle: GenreModel?
    var videoArray = [Video]()
    var getYouTubeData  = YouTubeVideoConnection()
    var webView = WKYTPlayerView()
    var entityName = String()
    var youTubeVideoID =  [String]()
    var youTubeVideoTitle =  [String]()
    var selectedIndex = Int()
    var searchIsSelected = Bool()
    var selectedmyLybrary = Bool()
    var isEmpty: Bool {
        switch genreTitle?.genreTitle {
        case "Rap":
            entityName = "YouTubeDataModel"
        case "Hip-Hop":
            entityName = "YouTubeHipHopData"
        case "Pop":
            entityName = "YouTubePopData"
        case "Rock":
            entityName = "YouTubeRockData"
        case "R&B":
            entityName = "YouTubeRBData"
        case "Dance":
            entityName = "YouTubeDanceData"
        case "Electronic":
            entityName = "YouTubeElectronicData"
        case "Jazz":
            entityName = "YouTubeJazzData"
        case "Instrumental":
            entityName = "YouTubeInstrumentalData"
        case "Blues":
            entityName = "YouTubeBluesData"
        case "Car Music":
            entityName = "YouTubeCarMusicData"
        case "Deep Bass":
            entityName = "YouTubeDeepBassData"
        default:
            break
        }
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title  = "  Top \(genreTitle!.genreTitle) Song's"
        genreTableView.delegate = self
        genreTableView.dataSource = self
        if isEmpty{
            self.getYouTubeData.getYouTubeVideo(genreType: self.genreTitle!.genreTitle, selectedViewController: "GenreListViewController") { (loadVideolist, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }else{
                    self.videoArray = loadVideolist!
                    for songIndex in 0..<self.videoArray.count{
                        let title =   self.videoArray[songIndex].videoTitle ?? ""
                        let description =  self.videoArray[songIndex].videoDescription ?? ""
                        let image =  self.videoArray[songIndex].videoImageUrl ?? ""
                        let playlistId = self.videoArray[songIndex].videoPlaylistId ?? ""
                        let videoId =  self.videoArray[songIndex].videoId ?? ""
                        let channelId =  self.videoArray[songIndex].channelId ?? ""
                        let genreTitle = self.videoArray[songIndex].genreTitle ?? ""
                        
//                        print(genreTitle)
                        
                        
                        self.saveItems(title: title, description: description, image: image, videoId: videoId, playlistId: playlistId,genreTitle: self.genreTitle!.genreTitle, channelId: channelId)
                        DispatchQueue.main.async {
                            self.genreTableView.reloadData()
                        }
                    }
                }
            }
        }else{
            self.fetchFromCoreData { (videoList, error) in
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
    
    //MARK: MOVE TO THE MODEL
    func saveItems(title:String,description:String,image:String,videoId:String,playlistId:String,genreTitle: String, channelId: String) {
        switch genreTitle {
        case "Rap":
            entityName = "YouTubeDataModel"
        case "Hip-Hop":
            entityName = "YouTubeHipHopData"
        case "Pop":
            entityName = "YouTubePopData"
        case "Rock":
            entityName = "YouTubeRockData"
        case "R&B":
            entityName = "YouTubeRBData"
        case "Dance":
            entityName = "YouTubeDanceData"
        case "Electronic":
            entityName = "YouTubeElectronicData"
        case "Jazz":
            entityName = "YouTubeJazzData"
        case "Instrumental":
            entityName = "YouTubeInstrumentalData"
        case "Blues":
            entityName = "YouTubeBluesData"
        case "Car Music":
            entityName = "YouTubeCarMusicData"
        case "Deep Bass":
            entityName = "YouTubeDeepBassData"
        default:
            break
        }
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context!)
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        newEntity.setValue(title, forKey: "title")
        newEntity.setValue(image, forKey: "image")
        newEntity.setValue(videoId, forKey: "videoId")
        newEntity.setValue(description, forKey: "songDescription")
        newEntity.setValue(playlistId, forKey: "playListId")
        newEntity.setValue(channelId, forKey: "channelId")
        do {
            try context?.save()
        } catch {
            print("Failed saving")
        }
    }
    //MARK: MOVE TO THE MODEL
    func fetchFromCoreData(loadVideoList: @escaping(_ returnVideoList: Video?, _ returnError: Error? ) -> ()){
        switch genreTitle?.genreTitle {
        case "Rap":
            entityName = "YouTubeDataModel"
        case "Hip-Hop":
            entityName = "YouTubeHipHopData"
        case "Pop":
            entityName = "YouTubePopData"
        case "Rock":
            entityName = "YouTubeRockData"
        case "R&B":
            entityName = "YouTubeRBData"
        case "Dance":
            entityName = "YouTubeDanceData"
        case "Electronic":
            entityName = "YouTubeElectronicData"
        case "Jazz":
            entityName = "YouTubeJazzData"
        case "Instrumental":
            entityName = "YouTubeInstrumentalData"
        case "Blues":
            entityName = "YouTubeBluesData"
        case "Car Music":
            entityName = "YouTubeCarMusicData"
        case "Deep Bass":
            entityName = "YouTubeDeepBassData"
        default:
            break
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as! String
                let image = data.value(forKey: "image") as! String
                let videoId = data.value(forKey: "videoId") as! String
                let songDescription = data.value(forKey: "songDescription") as! String
                let playlistId = data.value(forKey: "playListId") as! String
                let channelId = data.value(forKey: "channelId") as! String
                let fetchedVideoList = Video(videoId: videoId, videoTitle: title, videoDescription: songDescription, videoPlaylistId: playlistId, videoImageUrl: image, channelId:channelId)
                loadVideoList(fetchedVideoList,nil)
            }
            
        } catch {
            loadVideoList(nil,error)
            print("Failed")
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
            //            let saveGenreSelectedIndex = UserDefaults.standard.object(forKey: "saveGenreSelectedIndex") as? Int
            //            let checkGenreRowIsSelected = UserDefaults.standard.object(forKey: "checkGenreRowIsSelected") as? Bool
            //            DispatchQueue.main.async {
            //                if checkGenreRowIsSelected == true{
            //                    if(indexPath.row == saveGenreSelectedIndex)
            //                    {
            //                        cell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
            //                        cell.singerNameLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            //                    }else{
            //                        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            //                        cell.singerNameLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
            //                    }
            //                }else{
            //                    cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            //                    cell.singerNameLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
            //                }
            //            }
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
            for i in 0..<self.videoArray.count{
                self.youTubeVideoID.append(self.videoArray[i].videoId ?? "")
                self.youTubeVideoTitle.append(self.videoArray[i].videoTitle ?? "")
            }
            self.webView.load(withVideoId: "")
            VideoPlayerClass.callVideoPlayer.superViewController = self
            VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
            
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(selectedCellTitleLabel: selectedCell.singerNameLabel.text!, selectedCellImageViewUrl: selectedCell.videoImageUrl, selectedCellVideoID: selectedCell.videoID, coreDataEntityName: "RecentPlayedMusicData") { (checkIfLoadIsSuccessful, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
            }
            
            self.genreTableView.reloadData()
        }
        
    }
}
