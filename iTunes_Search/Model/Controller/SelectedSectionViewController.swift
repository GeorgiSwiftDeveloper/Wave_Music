//
//  TopHitsMusicViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/28/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import  YoutubePlayer_in_WKWebView

protocol CheckIfRowIsSelectedDelegate:class {
    func checkIfRowIsSelectedDelegate(_ checkIf: Bool)
}
class SelectedSectionViewController: UIViewController,WKNavigationDelegate,WKYTPlayerViewDelegate {
    
    var topHitsLists = [Video]()
    var myLibraryList = [Video]()
    var recentPlayedVideo = [Video]()
    var checkTable = String()
    var videoSelected = false
    var checkVideoIsSelected = false
    var libraryIsSelected = false
    var topHitsIsSelected = false
    var youTubeVideoID =  [String]()
    var youTubeVideoTitle =  [String]()
    var webView = WKYTPlayerView()
    var selectedVideo: Video?
    var topHitsListHeight = 190
    var selectedIndex = Int()
    var searchIsSelected = Bool()
    
    weak var checDelegate: CheckIfRowIsSelectedDelegate?
    
    @IBOutlet weak var selectedSectionTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedSectionTableView.delegate = self
        self.selectedSectionTableView.dataSource = self
        switch checkTable {
        case "topHits":
            fetchTopHitList()
        case "MyLibrary":
            fetchMyLibraryList()
            let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.circle.fill"), style: .plain, target: self, action:#selector(rightButtonAction))
            self.navigationItem.rightBarButtonItem  = deleteButton
        case "RecentPlayed":
            fetchRecentPlayedVideo()
            let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.circle.fill"), style: .plain, target: self, action:#selector(rightButtonAction)) 
            self.navigationItem.rightBarButtonItem  = deleteButton
            print(recentPlayedVideo.count)
            if recentPlayedVideo.count == 0 {
                let alert = UIAlertController(title: "There is no RECENTLY PLAYED songs", message: "Your recently played songs will be placed here after you play any song", preferredStyle: .alert)
                let libraryAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.selectedIndex = 0
                    self.tabBarController?.tabBar.isHidden = false
                }
                alert.addAction(libraryAction)
                present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
        
    }
    
    @objc func rightButtonAction() {
        var alertTitle = String()
        switch checkTable {
        case "topHits":
            break
        case "MyLibrary":
            alertTitle = "My Library"
        case "RecentPlayed":
            alertTitle = "RECENTLY PLAYED"
        default:
            break
        }
        let alert = UIAlertController(title: alertTitle, message: "Are you sure you want to delete \(alertTitle) music list ?", preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "YES", style: .default) { (action) in
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierRecentPlayedDeleteRecords"), object: nil)
            self.deleteRecords()
            self.selectedSectionTableView.reloadData()
        }
        
        let actionNo = UIAlertAction(title: "NO", style: .cancel) { (action) in
            
        }
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteRecords() -> Void {
        var entityName = String()
        switch checkTable {
        case "topHits":
            break
        case "MyLibrary":
            entityName = "MyLibraryMusicData"
            myLibraryList = []
        case "RecentPlayed":
            entityName = "RecentPlayedMusicData"
            recentPlayedVideo = []
        default:
            break
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let result = try? context?.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            context?.delete(object)
        }
        
        do {
            try context?.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        searchisSelected()
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierGenreRowSelected(notification:)), name: Notification.Name("NotificationIdentifierGenreRowSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierSearchRowSelected(notification:)), name: Notification.Name("NotificationIdentifierSearchRowSelected"), object: nil)
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
        switch checkTable {
        case "topHits":
            break
        case "MyLibrary":
            break
        case "RecentPlayed":
            break
        default:
            break
        }
    }
    
    func showVideoPlayerPause(){
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        switch checkTable {
        case "topHits":
            break
        case "MyLibrary":
            break
        case "RecentPlayed":
            break
        default:
            break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        searchisSelected()
        VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    
    
    @objc func NotificationIdentifierSearchRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkIfLibraryRowIsSelected")
        selectedSectionTableView.reloadData()
        
    }
    
    
    @objc func NotificationIdentifierGenreRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkIfLibraryRowIsSelected")
        selectedSectionTableView.reloadData()
        
    }
    
    
    func searchisSelected() {
        if searchIsSelected == true {
            UserDefaults.standard.set(false, forKey:"checkIfLibraryRowIsSelected")
            selectedSectionTableView.reloadData()
        }
        searchIsSelected = false
    }
    
    func fetchTopHitList(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                let videoId = data.value(forKey: "videoId") as? String ?? ""
                let title = data.value(forKey: "title") as? String ?? ""
                let songDescription = data.value(forKey: "songDescription") as? String ?? ""
                let playListId = data.value(forKey: "playListId") as? String ?? ""
                let image = data.value(forKey: "image") as? String ?? ""
                let channelId = data.value(forKey: "channelId") as? String ?? ""
                let videoList = Video(videoId: videoId, videoTitle: title , videoDescription: songDescription , videoPlaylistId: playListId, videoImageUrl: image , channelId:channelId, genreTitle: "")
                
                
                topHitsLists.append(videoList)
                     DispatchQueue.main.async {
                        self.selectedSectionTableView.reloadData()
                }
            }
            
        } catch {
            print("Failed")
        }
    }
    
    
    func fetchMyLibraryList(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                let videoId = data.value(forKey: "videoId") as? String ?? ""
                let title = data.value(forKey: "title") as? String ?? ""
                let songDescription = data.value(forKey: "songDescription") as? String ?? ""
                let playListId = data.value(forKey: "playListId") as? String ?? ""
                let image = data.value(forKey: "image") as? String ?? ""
                let genreTitle = data.value(forKey: "genreTitle") as? String ?? ""
                let videoList = Video(videoId: videoId, videoTitle: title , videoDescription: songDescription , videoPlaylistId: playListId, videoImageUrl: image , channelId:"", genreTitle: genreTitle)
                
                
                myLibraryList.append(videoList)
                     DispatchQueue.main.async {
                        self.selectedSectionTableView.reloadData()
                }
            }
            
        } catch {
            print("Failed")
        }
    }
    
    
    func fetchRecentPlayedVideo(){
        FetchRecentPlayedVideo.fetchRecentPlayedVideo.fetchRecentPlayedFromCoreData { (videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if videoList != nil {
                    self.recentPlayedVideo.append(videoList!)
                         DispatchQueue.main.async {
                    self.selectedSectionTableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension SelectedSectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        switch checkTable {
        case "topHits":
            numberOfRowsInSection = topHitsLists.count
        case "MyLibrary":
            numberOfRowsInSection = myLibraryList.count
        case "RecentPlayed":
            numberOfRowsInSection = recentPlayedVideo.count
        default:
            break
        }
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var selectedTableViewCell = UITableViewCell()
        switch checkTable {
        case "topHits":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? SelectedSectionTableViewCell {
//                var checkIfRowIsSelected = UserDefaults.standard.object(forKey: "checkIfLibraryRowIsSelected") as? Bool
//                let saveTopHitsSelectedIndex = UserDefaults.standard.object(forKey: "saveTopHitsSelectedIndex") as? Int
//                let checkIfAnotherViewControllerRowIsSelected = UserDefaults.standard.object(forKey: "checkIfAnotherViewControllerRowIsSelected") as? Bool
//                if checkIfAnotherViewControllerRowIsSelected == true {
//                    checkIfRowIsSelected = false
//                }
//                DispatchQueue.main.async {
//                    if checkIfRowIsSelected == true{
//                        if(indexPath.row == saveTopHitsSelectedIndex)
//                        {
//                            cell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
//                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//                        }else{
//                            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                        }
//                    }else{
//                        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                        cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                    }
//                }
                cell.configureTopHitsCell(topHitsLists[indexPath.row])
                cell.addToFavoriteButton.tag = indexPath.row;
                cell.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
                selectedTableViewCell = cell
            }else {
                return SelectedSectionTableViewCell()
            }
        case "MyLibrary":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? SelectedSectionTableViewCell {
//                var checkIfLibraryRowIsSelected = UserDefaults.standard.object(forKey: "checkIfLibraryRowIsSelected") as? Bool
//                let saveLibrarySelectedIndex = UserDefaults.standard.object(forKey: "saveLibrarySelectedIndex") as? Int
//                let checkIfAnotherViewControllerRowIsSelected = UserDefaults.standard.object(forKey: "checkIfAnotherViewControllerRowIsSelected") as? Bool
//                if checkIfAnotherViewControllerRowIsSelected == true {
//                    checkIfLibraryRowIsSelected = false
//                }
//                DispatchQueue.main.async {
//                    if checkIfLibraryRowIsSelected == true{
//                        if(indexPath.row == saveLibrarySelectedIndex)
//                        {
//                            cell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
//                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//                        }else{
//                            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                        }
//                    }else{
//                        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                        cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                    }
//                }
                cell.configureMyLibraryCell(myLibraryList[indexPath.row])
                cell.addToFavoriteButton.isHidden = true
                selectedTableViewCell = cell
            }else {
                return SelectedSectionTableViewCell()
            }
        case "RecentPlayed":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? SelectedSectionTableViewCell {
//                var checkIfLibraryRowIsSelected = UserDefaults.standard.object(forKey: "checkIfRecentlyPlayedRowIsSelected") as? Bool
//                let saveLibrarySelectedIndex = UserDefaults.standard.object(forKey: "saveRecentlyPlayedSelectedIndex") as? Int
//                let checkIfAnotherViewControllerRowIsSelected = UserDefaults.standard.object(forKey: "checkIfAnotherViewControllerRowIsSelected") as? Bool
//                if checkIfAnotherViewControllerRowIsSelected == true {
//                    checkIfLibraryRowIsSelected = false
//                }
//                DispatchQueue.main.async {
//                    if checkIfLibraryRowIsSelected == true{
//                        if(indexPath.row == saveLibrarySelectedIndex)
//                        {
//                            cell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
//                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//                        }else{
//                            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                        }
//                    }else{
//                        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                        cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                    }
//                }
                cell.configureRecentlyPlayedCell(recentPlayedVideo[indexPath.row])
                cell.addToFavoriteButton.tag = indexPath.row;
                cell.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
                selectedTableViewCell = cell
            }else {
                return SelectedSectionTableViewCell()
            }
        default:
            break
        }
        return selectedTableViewCell
    }
    
    
    @objc func addToMyLibraryButton(sender: UIButton){
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        self.selectedSectionTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        let selectedCell = self.selectedSectionTableView.cellForRow(at: selectedIndex) as! SelectedSectionTableViewCell
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        let predicate = NSPredicate(format: "title == %@", selectedCell.topHitLabelText.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        let alert = UIAlertController(title: "\(selectedCell.topHitLabelText.text ?? "")", message: "", preferredStyle: .actionSheet)
        let addMyLibraryAction = UIAlertAction(title: "Add to MyLibrary", style: .default) { (action) in
            do{
                let count = try context?.count(for: request)
                if(count == 0){
                    let entity = NSEntityDescription.entity(forEntityName: "MyLibraryMusicData", in: context!)
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(selectedCell.topHitLabelText.text, forKey: "title")
                    newEntity.setValue(selectedCell.videoImageUrl, forKey: "image")
                    newEntity.setValue(selectedCell.videoID, forKey: "videoId")
                    try context?.save()
                    print("data has been saved ")
                    let selectedImageViewUrl = selectedCell.videoImageUrl
                    AlertView.instance.showAlert(title: "\(selectedCell.topHitLabelText.text ?? "")", message:"Successfuly added to MyLibrary list", alertType: .success, videoImage: selectedImageViewUrl)
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
    
   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var canEdit = Bool()
        switch checkTable {
        case "topHits":
            canEdit = false
        case "MyLibrary":
            canEdit =  true
        case "RecentPlayed":
            canEdit =  true
        default:
            break
        }
        return canEdit
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == MainLibrariMusciTableViewCell.EditingStyle.delete{
            removeSelectedVideoRow(atIndexPath: indexPath)
            switch checkTable {
            case "topHits":
                break
            case "MyLibrary":
                myLibraryList.remove(at: indexPath.row)
            case "RecentPlayed":
                recentPlayedVideo.remove(at: indexPath.row)
            default:
                break
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    func removeSelectedVideoRow(atIndexPath indexPath: IndexPath) {
        var entityName = String()
        switch checkTable {
        case "topHits":
            break
        case "MyLibrary":
            entityName = "MyLibraryMusicData"
        case "RecentPlayed":
            entityName = "RecentPlayedMusicData"
        default:
            break
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let result = try? context?.fetch(request)
        let resultData = result as! [NSManagedObject]
        context?.delete(resultData[indexPath.row])
        do{
            try context?.save()
        }catch {
            print("Could not remove video \(error.localizedDescription)")
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checDelegate?.checkIfRowIsSelectedDelegate(true)
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierSelectionLibraryRowSelected"), object: nil)
        UserDefaults.standard.set(false, forKey:"selectedSearch")
        UserDefaults.standard.set(false, forKey:"selectedmyLybrary")
        switch checkTable {
        case "MyLibrary":
            DispatchQueue.main.async {
                self.selectedVideo = self.myLibraryList[indexPath.row]
                let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
                self.getSelectedLibraryVideo(indexPath)
                self.webView.load(withVideoId: "")
                for i in 0..<self.myLibraryList.count{
                    self.youTubeVideoID.append(self.myLibraryList[i].videoId)
                    self.youTubeVideoTitle.append(self.myLibraryList[i].videoTitle)
                }
                
                VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
            }
        case "topHits":
            DispatchQueue.main.async {
                self.selectedVideo = self.topHitsLists[indexPath.row]
                let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
                self.getSelectedTopHitsVideo(indexPath)
                self.webView.load(withVideoId: "")
                
                for i in 0..<self.topHitsLists.count{
                    self.youTubeVideoID.append(self.topHitsLists[i].videoId)
                    self.youTubeVideoTitle.append(self.topHitsLists[i].videoTitle)
                }
                VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
                FetchRecentPlayedVideo.fetchRecentPlayedVideo.saveRecentPlayedVideo(selectedCellTitleLabel: selectedCell.topHitLabelText.text!, selectedCellImageViewUrl: selectedCell.videoImageUrl, selectedCellVideoID: selectedCell.videoID) { (checkIfLoadIsSuccessful, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        case "RecentPlayed":
            DispatchQueue.main.async {
                self.selectedVideo = self.recentPlayedVideo[indexPath.row]
                let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
                self.getSelectedRecentlyPlayedVideo(indexPath)
                self.webView.load(withVideoId: "")
                for i in 0..<self.recentPlayedVideo.count{
                    self.youTubeVideoID.append(self.recentPlayedVideo[i].videoId)
                    self.youTubeVideoTitle.append(self.recentPlayedVideo[i].videoTitle)
                }
                VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
            }
        default:
            break
        }
    }
    
    
    func getSelectedLibraryVideo(_ indexPath: IndexPath){
        UserDefaults.standard.set(true, forKey:"checkIfLibraryRowIsSelected")
        UserDefaults.standard.set(false, forKey:"checkIfAnotherViewControllerRowIsSelected")
        selectedIndex = indexPath.row
        UserDefaults.standard.set(selectedIndex, forKey:"saveLibrarySelectedIndex")
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        VideoPlayerClass.callVideoPlayer.superViewController = self
        UserDefaults.standard.removeObject(forKey: "saveTopHitsSelectedIndex")
        UserDefaults.standard.removeObject(forKey: "saveRecentlyPlayedSelectedIndex")
        selectedSectionTableView.reloadData()
    }
    
    
    func getSelectedTopHitsVideo(_ indexPath: IndexPath){
        UserDefaults.standard.set(true, forKey:"checkIfLibraryRowIsSelected")
        UserDefaults.standard.set(false, forKey:"checkIfAnotherViewControllerRowIsSelected")
        selectedIndex = indexPath.row
        UserDefaults.standard.set(selectedIndex, forKey:"saveTopHitsSelectedIndex")
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        VideoPlayerClass.callVideoPlayer.superViewController = self
        UserDefaults.standard.removeObject(forKey: "saveLibrarySelectedIndex")
        UserDefaults.standard.removeObject(forKey: "saveRecentlyPlayedSelectedIndex")
        selectedSectionTableView.reloadData()
    }
    
    
    func getSelectedRecentlyPlayedVideo(_ indexPath: IndexPath){
        UserDefaults.standard.set(true, forKey:"checkIfRecentlyPlayedRowIsSelected")
        UserDefaults.standard.set(false, forKey:"checkIfAnotherViewControllerRowIsSelected")
        selectedIndex = indexPath.row
        UserDefaults.standard.set(selectedIndex, forKey:"saveRecentlyPlayedSelectedIndex")
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        VideoPlayerClass.callVideoPlayer.superViewController = self
        UserDefaults.standard.removeObject(forKey: "saveLibrarySelectedIndex")
        UserDefaults.standard.removeObject(forKey: "saveTopHitsSelectedIndex")
        selectedSectionTableView.reloadData()
    }
}


