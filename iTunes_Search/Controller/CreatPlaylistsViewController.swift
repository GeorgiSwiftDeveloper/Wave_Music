//
//  CreatPlaylistsViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/30/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import  YoutubePlayer_in_WKWebView

class CreatPlaylistsViewController: UIViewController, CheckIfRowIsSelectedDelegate, CheckIfMusicRecordDeletedDelegate {
    
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    @IBOutlet weak var topHitsCollectionCell: UICollectionView!
    @IBOutlet weak var recentPlayedCollectionCell: UICollectionView!
    
    var createdPlaylistArray = ["New Playlist"]
    var selectedPlaylistRowTitle: String?
    
    var topHitsArray = [Video]()
    var recentPlayerArray = [Data]()
    var recentPlayedVideo = [Video]()
    
    var checkTableViewName: String = ""
    var selectTopHitsRow = Bool()
    var videoSelected = Bool()
    
    var libraryImageArray: [UIImageView] = []
    
    var isEntityIsEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: topHitsEntityName)
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topHitsCollectionCell.delegate = self
        self.topHitsCollectionCell.dataSource = self
        
        self.recentPlayedCollectionCell.delegate = self
        self.recentPlayedCollectionCell.dataSource = self
        
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        
        getYouTubeResults()
        if let musicPlaylist = UserDefaults.standard.object(forKey: "MusicPlaylist") as? [String] {
            createdPlaylistArray = musicPlaylist
        }
        self.playlistTableView.reloadData()
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
        fetchRecentlyPlayedVideoData()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        VideoPlayer.callVideoPlayer.cardViewController.removeFromParent()
    }
    
    
    func fetchRecentlyPlayedVideoData() {
        
        self.recentPlayedVideo = []
        fetchVideoWithEntityName(recentPlayedEntityName)
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
    }
    func showVideoPlayerPause(){
        VideoPlayer.callVideoPlayer.webView.pauseVideo()
    }
    
    
    func fetchVideoWithEntityName(_ entityName: String){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: entityName, searchBarText: "", playlistName: "") { (videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if videoList != nil {
                    switch entityName {
                    case recentPlayedEntityName:
                        self.recentPlayedVideo.append(videoList!)
                        self.recentPlayedCollectionCell.reloadData()
                    case topHitsEntityName:
                        self.topHitsArray.append(videoList!)
                        self.topHitsCollectionCell.reloadData()
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    
    
    func getYouTubeResults(){
        if isEntityIsEmpty{
            YouTubeVideoConnection.getYouTubeVideoInstace.getYouTubeVideo(genreType: genreTypeHits, selectedViewController: "MyLibraryViewController") { (loadVideolist, error) in
                if error != nil  {
                    print("erorr")
                }else{
                    DispatchQueue.main.async{
                        self.topHitsArray = loadVideolist!
                        for songIndex in 0..<self.topHitsArray.count{
                            
                            let title =   self.topHitsArray[songIndex].videoTitle ?? ""
                            //                            let description =  self.topHitsArray[songIndex].videoDescription ?? ""
                            let image =  self.topHitsArray[songIndex].videoImageUrl ?? ""
                            //                            let playlistId = self.topHitsArray[songIndex].videoPlaylistId ?? ""
                            let videoId =  self.topHitsArray[songIndex].videoId ?? ""
                            //                            let channelId =  self.topHitsArray[songIndex].channelId ?? ""
                            
                            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: title, videoImage: image, videoId: videoId, playlistName: "", coreDataEntityName: topHitsEntityName) { (checkIfSaveIsSuccessful, error, checkIfSongAlreadyInDatabase) in
                                if error != nil {
                                    print(error?.localizedDescription as Any)
                                }
                            }
                            self.topHitsCollectionCell.reloadData()
                            
                        }
                    }
                }
            }
        }else{
            fetchVideoWithEntityName(topHitsEntityName)
        }
    }
    
    
    func recentPlayerVideoImage(videoCount:Int,imageData: @escaping(_ imageData: [Data]) -> ()) {
        
        var imageDataArray = [Data]()
        
        for i in 0..<videoCount {
            let imageUrl1 = URL(string: recentPlayedVideo[i].videoImageUrl! )
            do{
                let data1:NSData = try NSData(contentsOf: imageUrl1!)
                
                imageDataArray.append(data1 as Data)
                
            }catch{
                print("no image data found")
            }
            imageData(imageDataArray)
        }
        
    }
    
    func checkIfRowIsSelected(_ checkIf: Bool) {
        if checkIf == true{
            DispatchQueue.main.async {
                self.selectTopHitsRow = true
            }
        }
    }
    
    
    func musicRecordDeletedDelegate(_ alertTitleName: String) {
        if alertTitleName == "RECENTLY PLAYED"{
            libraryImageArray = libraryImageArray.map { image in
                image.image = nil
                return image
            }
            recentPlayedCollectionCell.reloadData()
        }
    }
    
}

extension CreatPlaylistsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createdPlaylistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? PlaylistsTableViewCell {
            if indexPath.row == 0 {
                cell.trackCountLabel.isHidden = true
                cell.playlistName.text = createdPlaylistArray[0]
                cell.playlistName.textColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 1)
                cell.playlistName.font = UIFont(name: "Verdana-Bold", size: 14.0)
                cell.playlistImage.image = UIImage(systemName: "list.bullet")
            }else{
                
                cell.playlistName.text = createdPlaylistArray[indexPath.row]
                cell.playlistName.textColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 1)
                cell.playlistName.font = UIFont(name: "Verdana", size: 12.0)
                cell.playlistName.textAlignment = .left
                cell.playlistImage.image = UIImage(systemName: "music.note.list")
                cell.playlistImage.tintColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            }
            return cell
        }else {
            return PlaylistsTableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            var playlistTxt = UITextField()
            let alert = UIAlertController(title: "New Playlist", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }
            let createPlaylistAction = UIAlertAction(title: "Create", style: .default) { (action) in
                let text = (alert.textFields?.first as! UITextField).text
                if text == ""{
                    print("data is empty")
                }else{
                    var playlistNameArray = [String]()
                    
                    for playlistName in self.createdPlaylistArray {
                        playlistNameArray.append(playlistName)
                    }
                    
                    if playlistNameArray.contains(text!){
                        print("This playlist is already exists")
                        let alert = UIAlertController(title: "Please change your Playlist name", message: "Playlist with name \(text ?? "") is already exists", preferredStyle: .alert)
                        let libraryAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            
                        }
                        alert.addAction(libraryAction)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.createdPlaylistArray.append(text!)
                        UserDefaults.standard.set(self.createdPlaylistArray, forKey:"MusicPlaylist")
                        self.playlistTableView.reloadData()
                    }
                }
            }
            
            alert.addAction(action)
            alert.addAction(createPlaylistAction)
            //Add text field
            alert.addTextField { (texfield) in
                playlistTxt = texfield
                playlistTxt.placeholder = "Enter  name for this playlist"
            }
            present(alert, animated: true, completion: nil)
        }else{
            
            selectedPlaylistRowTitle = createdPlaylistArray[indexPath.row]
            UserDefaults.standard.set(self.selectedPlaylistRowTitle, forKey:"selectedPlaylistRowTitle")
            self.performSegue(withIdentifier: destinationToSelectedIdentifier, sender: selectedPlaylistRowTitle)
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender as? String {
        case SelectedTableView.topHitsTableView.rawValue:
            if  let nc = segue.destination as? SelectedSectionViewController {
                nc.navigationItem.title = "World Top 100"
                if videoSelected == true{
                    nc.videoSelected = true
                    nc.ifRowIsSelectedDelegate = self
                }
                let selectedSearch = UserDefaults.standard.object(forKey: "selectedSearch") as? Bool
                if selectedSearch == true {
                    nc.searchIsSelected = true
                }
                UserDefaults.standard.set(false, forKey:"selectedSearch")
                nc.checkTableViewName = sender as! String
                nc.ifRowIsSelectedDelegate = self
            }
        case SelectedTableView.recentPlayedTableView.rawValue:
            
            if  let nc = segue.destination as? SelectedSectionViewController {
                nc.navigationItem.title = "RECENTLY PLAYED"
                if videoSelected == true{
                    nc.videoSelected = true
                }
                let selectedSearch = UserDefaults.standard.object(forKey: "selectedSearch") as? Bool
                if selectedSearch == true {
                    nc.searchIsSelected = true
                }
                UserDefaults.standard.set(false, forKey:"selectedSearch")
                nc.checkTableViewName = sender as! String
                nc.ifRowIsSelectedDelegate = self
                nc.musicRecordDeletedDelegate = self
            }
        case selectedPlaylistRowTitle:
            if let playlistDestVC = segue.destination as? SelectedSectionViewController{
                playlistDestVC.navigationItem.title = sender as? String
                playlistDestVC.checkTableViewName = "Playlist"
            }
        default:
            break
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row != 0{
            return true
        }else{
            return false
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == PlaylistsTableViewCell.EditingStyle.delete{
//            selectedPlaylistRowTitle = createdPlaylistArray[indexPath.row]
//            deleteSelectedPlaylist(predicateName: selectedPlaylistRowTitle!)
//            createdPlaylistArray.remove(at: indexPath.row)
//            UserDefaults.standard.set(self.createdPlaylistArray, forKey:"MusicPlaylist")
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//
//        }
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: {a,b,c in
            // example of your delete function
            self.selectedPlaylistRowTitle = self.createdPlaylistArray[indexPath.row]
            print(self.selectedPlaylistRowTitle!)
            self.deleteSelectedPlaylist(predicateName: self.selectedPlaylistRowTitle!)
            self.createdPlaylistArray.remove(at: indexPath.row)
            UserDefaults.standard.set(self.createdPlaylistArray, forKey:"MusicPlaylist")
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })

        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .black
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    func deleteSelectedPlaylist(predicateName playlistName: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: playlistEntityName)
        let predicate = NSPredicate(format: "playlistName == %@", playlistName as CVarArg)
        request.predicate = predicate
        
        do {
            let arrMusicObject = try context?.fetch(request)
            for musicObjc in arrMusicObject as! [NSManagedObject] { // Fetching Object
                context?.delete(musicObjc) // Deleting Object
            }
        } catch {
            print("Failed")
        }
        
        // Saving the Delete operation
        do {
            try context?.save()
        } catch {
            print("Failed saving")
        }
        do{
            try context?.save()
        }catch {
            print("Could not remove music list from Database \(error.localizedDescription)")
        }
    }
    
    
    
}

extension CreatPlaylistsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var collectionCell = UICollectionViewCell()
        switch collectionView {
        case topHitsCollectionCell:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as! TopHitsCollectionViewCell
            
            cell.cellTitleLabel.text = "World Top 100"
            cell.topHitsVideoCountLabel.text = "\(topHitsArray.count) tracks"
            
            var topImageArray = [cell.imageView1, cell.imageView2,cell.imageView3,cell.imageView4]
            
            if topHitsArray.count >= 4 {
                let imageUrl1 = URL(string: topHitsArray[0].videoImageUrl ?? "")
                let imageUrl2 = URL(string: topHitsArray[1].videoImageUrl ?? "")
                let imageUrl3 = URL(string: topHitsArray[2].videoImageUrl ?? "")
                let imageUrl4 = URL(string: topHitsArray[3].videoImageUrl ?? "")
                do{
                    let data1:NSData = try NSData(contentsOf: imageUrl1!)
                    let data2:NSData = try NSData(contentsOf: imageUrl2!)
                    let data3:NSData = try NSData(contentsOf: imageUrl3!)
                    let data4:NSData = try NSData(contentsOf: imageUrl4!)
                    cell.imageView1.image =  UIImage(data: data1 as Data)
                    cell.imageView2.image =  UIImage(data: data2 as Data)
                    cell.imageView3.image =  UIImage(data: data3 as Data)
                    cell.imageView4.image =  UIImage(data: data4 as Data)
                    
                    
                }catch{
                    print("error")
                }
            }else if topHitsArray.count == 0 {
                
                topImageArray = topImageArray.map { image in
                    image?.image = nil
                    return image
                }
            }
            collectionCell = cell
        case recentPlayedCollectionCell:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentCell", for: indexPath) as! RecentPlayedCollectionViewCell
            
            cell.cellTitleLabel.text = "RECENTLY PLAYED"
            cell.recentlyPlayedVideoCountLabel.text = "\(recentPlayedVideo.count) tracks"
            
            libraryImageArray = [cell.imageView1, cell.imageView2,cell.imageView3,cell.imageView4]
            
            
            switch recentPlayedVideo.count {
            case 0:
                
                libraryImageArray = libraryImageArray.map { image in
                    image.image = nil
                    return image
                }
                
            case 1:
                let imageUrl1 = URL(string: recentPlayedVideo[0].videoImageUrl ?? "")
                do {
                    let data1:NSData = try NSData(contentsOf: imageUrl1!)
                    cell.imageView1.image =  UIImage(data: data1 as Data)
                } catch  {
                    print("error")
                }
                
            case 2:
                let imageUrl1 = URL(string: recentPlayedVideo[0].videoImageUrl ?? "")
                let imageUrl2 = URL(string: recentPlayedVideo[1].videoImageUrl ?? "")
                do {
                    let data1:NSData = try NSData(contentsOf: imageUrl1!)
                    let data2:NSData = try NSData(contentsOf: imageUrl2!)
                    cell.imageView1.image =  UIImage(data: data1 as Data)
                    cell.imageView2.image =  UIImage(data: data2 as Data)
                } catch  {
                    print("error")
                }
                
            case 3:
                let imageUrl1 = URL(string: recentPlayedVideo[0].videoImageUrl ?? "")
                let imageUrl2 = URL(string: recentPlayedVideo[1].videoImageUrl ?? "")
                let imageUrl3 = URL(string: recentPlayedVideo[2].videoImageUrl ?? "")
                
                do {
                    let data1:NSData = try NSData(contentsOf: imageUrl1!)
                    let data2:NSData = try NSData(contentsOf: imageUrl2!)
                    let data3:NSData = try NSData(contentsOf: imageUrl3!)
                    
                    cell.imageView1.image =  UIImage(data: data1 as Data)
                    cell.imageView2.image =  UIImage(data: data2 as Data)
                    cell.imageView3.image =  UIImage(data: data3 as Data)
                    
                } catch  {
                    print("error")
                }
            default:
                let imageUrl1 = URL(string: recentPlayedVideo[0].videoImageUrl ?? "")
                let imageUrl2 = URL(string: recentPlayedVideo[1].videoImageUrl ?? "")
                let imageUrl3 = URL(string: recentPlayedVideo[2].videoImageUrl ?? "")
                let imageUrl4 = URL(string: recentPlayedVideo[3].videoImageUrl ?? "")
                do {
                    let data1:NSData = try NSData(contentsOf: imageUrl1!)
                    let data2:NSData = try NSData(contentsOf: imageUrl2!)
                    let data3:NSData = try NSData(contentsOf: imageUrl3!)
                    let data4:NSData = try NSData(contentsOf: imageUrl4!)
                    cell.imageView1.image =  UIImage(data: data1 as Data)
                    cell.imageView2.image =  UIImage(data: data2 as Data)
                    cell.imageView3.image =  UIImage(data: data3 as Data)
                    cell.imageView4.image =  UIImage(data: data4 as Data)
                } catch  {
                    print("error")
                }
            }
            
            
            collectionCell = cell
        default:
            break
        }
        
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case topHitsCollectionCell:
            self.performSegue(withIdentifier: destinationToSelectedIdentifier, sender: SelectedTableView.topHitsTableView.rawValue)
        case recentPlayedCollectionCell:

            self.performSegue(withIdentifier: destinationToSelectedIdentifier, sender: SelectedTableView.recentPlayedTableView.rawValue)
        default:
            break
        }
    }
}
