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
    @IBOutlet weak var recentPlayedCollectionCell: UICollectionView!
    
    var createdPlaylistArray = ["New Playlist"]
    var selectedPlaylistRowTitle: String?
    
    var topHitsArray = [Video]()
    var recentPlayerArray = [Data]()
    var recentPlayedVideo = [Video]()
    
    var checkTableViewName: String = ""
    var selectTopHitsRow = Bool()
    var videoSelected = Bool()
    
    
    
    var videoPlaylistCount = [Int]()
    
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
        self.view.accessibilityIdentifier = "PlaylistView"
        
        self.recentPlayedCollectionCell.delegate = self
        self.recentPlayedCollectionCell.dataSource = self
        
        collectionViewConstraints()
        
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        
        getYouTubeResults()
        loadCreatedMusicPlaylist()
    }
    
    func loadCreatedMusicPlaylist(){
        if let musicPlaylist = UserDefaults.standard.object(forKey: "MusicPlaylist") as? [String] {
            createdPlaylistArray = musicPlaylist
        }
        DispatchQueue.main.async {
            self.playlistTableView.reloadData()
        }
    }
    
    
    func collectionViewConstraints() {
        let layout = self.recentPlayedCollectionCell.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 0)
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: (self.view.frame.size.width - 30)/2, height: (self.recentPlayedCollectionCell.frame.size.width - 40)/2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        switch pause {
        case true:
            updatePlayerView()
        case false:
            updatePlayerView()
        default:
            break
        }
        
        getPlaylistMusicCount()
        
        DispatchQueue.main.async {
            self.playlistTableView.reloadData()
        }
        fetchRecentlyPlayedVideoData()
    }
    
    
    func getPlaylistMusicCount(){
        for i in 0..<createdPlaylistArray.count {
            fetchVideoWithEntityName("PlaylistMusicData", createdPlaylistArray[i])
        }
        print("video count is \(videoPlaylistCount)")
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoPlaylistCount = []
    }
    
    
    func fetchVideoWithEntityName(_ entityName: String, _ selectedPlaylistName: String){
        if selectedPlaylistName != "New Playlist" {
            CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: entityName, searchBarText: "", playlistName: selectedPlaylistName) { [weak self] (videoList, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }else{
                    if videoList != nil {
                        switch entityName {
                        case "PlaylistMusicData":
                            
                            
                            self?.videoPlaylistCount.append(videoList!.count)
                            
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    func  updatePlayerView() {
        DispatchQueue.main.async {
            VideoPlayer.callVideoPlayer.cardViewController.removeFromParent()
            VideoPlayer.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayer.callVideoPlayer.cardViewController.view)
        }
        VideoPlayer.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else {
                self?.updatePlayerState(playerState)
            }
        })
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
                        self.recentPlayedVideo.append(contentsOf: videoList!)
                        self.recentPlayedCollectionCell.reloadData()
                    case topHitsEntityName:
                        self.topHitsArray.append(contentsOf: videoList!)
                        DispatchQueue.main.async {
                            self.recentPlayedCollectionCell.reloadData()
                        }
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
                            
                            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: title, videoImage: image, videoId: videoId, playlistName: "", coreDataEntityName: topHitsEntityName) { (error) in
                                if error != nil {
                                    print(error?.localizedDescription as Any)
                                }
                            }
                            DispatchQueue.main.async {
                                self.recentPlayedCollectionCell.reloadData()
                            }
                        }
                    }
                }
            }
        }else{
            fetchVideoWithEntityName(topHitsEntityName)
        }
    }
    
    
    func checkIfRowIsSelected(_ checkIf: Bool) {
        if checkIf == true{
            self.selectTopHitsRow = true
        }
    }
    
    
    func musicRecordDeletedDelegate(_ alertTitleName: String) {
        if alertTitleName == "RECENTLY PLAYED"{
            libraryImageArray = libraryImageArray.map { image in
                image.image = nil
                return image
            }
            DispatchQueue.main.async {
                self.recentPlayedCollectionCell.reloadData()
            }
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
                cell.trackCountLabel.text = "\(videoPlaylistCount[indexPath.row - 1]) tracks"
                cell.playlistName.textColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 1)
                cell.playlistName.font = UIFont(name: "Verdana", size: 12.0)
                cell.trackCountLabel.font = UIFont(name: "Verdana-Bold", size: 10.0)
                cell.trackCountLabel.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
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
                let text = alert.textFields?.first?.text
                if text == ""{
                    print("data is empty")
                }else{
                    if self.createdPlaylistArray.contains(text!){
                        print("This playlist is already exists")
                        let alert = UIAlertController(title: "Please change your Playlist name", message: "Playlist with name \(text ?? "") is already exists", preferredStyle: .alert)
                        let libraryAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            
                        }
                        alert.addAction(libraryAction)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.createdPlaylistArray.append(text!)
                        print("count is \(self.createdPlaylistArray.count)")
                        UserDefaults.standard.set(self.createdPlaylistArray, forKey:"MusicPlaylist")
                        self.videoPlaylistCount = []
                        self.getPlaylistMusicCount()
                        DispatchQueue.main.async {
                            self.playlistTableView.reloadData()
                        }
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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == PlaylistsTableViewCell.EditingStyle.delete{
            self.selectedPlaylistRowTitle = self.createdPlaylistArray[indexPath.row]
            print(self.selectedPlaylistRowTitle!)
            self.deleteSelectedPlaylist(predicateName: self.selectedPlaylistRowTitle!)
            self.createdPlaylistArray.remove(at: indexPath.row)
            
            print("count is \(self.createdPlaylistArray.count)")
            
            UserDefaults.standard.set(self.createdPlaylistArray, forKey:"MusicPlaylist")
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
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
        return 2
    }
    
    
    func getImageFromUrl(_ arrayWithImageIndex: [Video]) -> [UIImage] {
        
        var imageList = [UIImage]()
        
        var imageUrlList = [URL]()
        
        var imageDataList = [NSData]()
        
        
        do
        {
            
            for i in arrayWithImageIndex{
                let imageUrl = URL(string: i.videoImageUrl ?? "")
                imageUrlList.append(imageUrl!)
                
            }
            
            for imageUrl in imageUrlList {
                if imageUrlList.count > 0  {
                    let imageData:NSData =  try NSData(contentsOf: imageUrl)
                    imageDataList.append(imageData)
                }
            }
            
            for imageData in imageDataList {
                if imageDataList.count > 0 {
                    let image: UIImage = UIImage(data: imageData as Data)!
                    imageList.append(image)
                }
            }
            
        }
        catch {
            // error
            print("Could not get image from url \(error.localizedDescription)")
        }
        
        
        return imageList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var collectionCell = UICollectionViewCell()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! RecentPlayedCollectionViewCell
        
        if indexPath.row == 0 {
            cell.cellTitleLabel.text = "World Top 100"
            cell.recentlyPlayedVideoCountLabel.text = "\(topHitsArray.count) tracks"
          
            var topImageArray = [cell.imageView1, cell.imageView2,cell.imageView3,cell.imageView4]
            
            if topHitsArray.count >= 4 {
                
                let imageArray =  getImageFromUrl(topHitsArray)
                DispatchQueue.main.async {
                    cell.imageView1.image =  imageArray[0]
                    cell.imageView2.image =  imageArray[1]
                    cell.imageView3.image =  imageArray[2]
                    cell.imageView4.image =  imageArray[3]
                }
            }else if topHitsArray.count == 0 {
                
                topImageArray = topImageArray.map { image in
                    image?.image = nil
                    return image
                }
            }
            collectionCell = cell
            
        }else{
            
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
                let imageArray =  getImageFromUrl(recentPlayedVideo)
                DispatchQueue.main.async {
                    cell.imageView1.image =  imageArray[0]
                }
                
            case 2:
                let imageArray =  getImageFromUrl(recentPlayedVideo)
                DispatchQueue.main.async {
                    cell.imageView1.image =  imageArray[0]
                    cell.imageView2.image =  imageArray[1]
                }
            case 3:
                let imageArray =  getImageFromUrl(recentPlayedVideo)
                DispatchQueue.main.async {
                    cell.imageView1.image =  imageArray[0]
                    cell.imageView2.image =  imageArray[1]
                    cell.imageView3.image =  imageArray[2]
                }
            default:
                let imageArray =  getImageFromUrl(recentPlayedVideo)
                DispatchQueue.main.async {
                    cell.imageView1.image =  imageArray[0]
                    cell.imageView2.image =  imageArray[1]
                    cell.imageView3.image =  imageArray[2]
                    cell.imageView4.image =  imageArray[3]
                }
            }
            
            
            collectionCell = cell
        }
        
        return collectionCell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.performSegue(withIdentifier: destinationToSelectedIdentifier, sender: SelectedTableView.topHitsTableView.rawValue)
            
        }else{
            self.performSegue(withIdentifier: destinationToSelectedIdentifier, sender: SelectedTableView.recentPlayedTableView.rawValue)
        }
    }
}
