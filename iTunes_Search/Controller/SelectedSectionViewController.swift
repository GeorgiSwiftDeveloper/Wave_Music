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

protocol CheckIfRowIsSelectedDelegate:AnyObject {
    func checkIfRowIsSelected(_ checkIfRowIsSelected: Bool)
}

protocol CheckIfMusicRecordDeletedDelegate:AnyObject {
    func musicRecordDeletedDelegate(_ alertTitleName: String)
}

class SelectedSectionViewController: UIViewController,WKNavigationDelegate,WKYTPlayerViewDelegate {
    
    var topHitsLists = [Video]()
    var myLibraryList = [Video]()
    var recentPlayedVideo = [Video]()
    var videoPlaylist = [Video]()
    
    
    
    var checkTableViewName = String()


    var webView = WKYTPlayerView()
    
    var topHitsListHeight = 190
    var searchIsSelected = Bool()
    
    weak var ifRowIsSelectedDelegate: CheckIfRowIsSelectedDelegate?
    weak var musicRecordDeletedDelegate: CheckIfMusicRecordDeletedDelegate?
    
    @IBOutlet weak var selectedSectionTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedSectionTableView.delegate = self
        self.selectedSectionTableView.dataSource = self
        
        switch checkTableViewName {
        case SelectedTableView.topHitsTableView.rawValue:
            fetchVideoWithEntityName("TopHitsModel", "")
        case SelectedTableView.libraryTableView.rawValue:
            fetchVideoWithEntityName("MyLibraryMusicData", "")
            let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.circle.fill"), style: .plain, target: self, action:#selector(rightButtonAction))
            self.navigationItem.rightBarButtonItem  = deleteButton
        case SelectedTableView.recentPlayedTableView.rawValue:
            fetchVideoWithEntityName("RecentPlayedMusicData", "")
            let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.circle.fill"), style: .plain, target: self, action:#selector(rightButtonAction)) 
            self.navigationItem.rightBarButtonItem  = deleteButton
            if recentPlayedVideo.count == 0 {
                let alert = UIAlertController(title: "No Tracks Found", message: "Your recently played songs will be placed here after you play any song", preferredStyle: .alert)
                let libraryAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.selectedIndex = 3
                    self.tabBarController?.tabBar.isHidden = false
                }
                alert.addAction(libraryAction)
                present(alert, animated: true, completion: nil)
            }
        case SelectedTableView.playlistTableView.rawValue:
            guard let selectedPaylistName = UserDefaults.standard.object(forKey: "selectedPlaylistRowTitle") as? String else{return}
            saveSelectedMusicCoreDataEntity(selectedPaylistName)
            
            fetchVideoWithEntityName(playlistEntityName, selectedPaylistName)
            
            UserDefaults.standard.removeObject(forKey: "videoId")
            UserDefaults.standard.removeObject(forKey: "image")
            UserDefaults.standard.removeObject(forKey: "title")
            
            let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.circle.fill"), style: .plain, target: self, action:#selector(rightButtonAction))
            self.navigationItem.rightBarButtonItem  = deleteButton
            if videoPlaylist.count == 0 {
                let alert = UIAlertController(title: "No Tracks Found", message: "Your songs will be placed here after you add any song", preferredStyle: .alert)
                let libraryAction = UIAlertAction(title: "OK", style: .default) {[weak self] (action) in
                    self?.navigationController?.popViewController(animated: true)
                    self?.tabBarController?.selectedIndex = 3
                    self?.tabBarController?.tabBar.isHidden = false
                }
                alert.addAction(libraryAction)
                present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
        
    }
    
    
    func saveSelectedMusicCoreDataEntity(_ selectedPlaylistRowTitle: String) {
        
        let videoIDProperty = UserDefaults.standard.object(forKey: "videoId") as? String
        let videoImageUrlProperty = UserDefaults.standard.object(forKey: "image") as? String
        let videoTitleProperty = UserDefaults.standard.object(forKey: "title") as? String
        
        if (videoIDProperty != nil) || (videoImageUrlProperty != nil) || (videoTitleProperty != nil) {
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: videoTitleProperty!, videoImage: videoImageUrlProperty!, videoId: videoIDProperty!, playlistName: selectedPlaylistRowTitle, coreDataEntityName: playlistEntityName) {[weak self] (checkIfLoadIsSuccessful, error, checkIfSongAlreadyInDatabase)  in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                if  checkIfSongAlreadyInDatabase == true  {
                    let alert = UIAlertController(title: "Please check your Playlist", message: "\(videoTitleProperty ?? "")  already exist in your list", preferredStyle: .alert)
                    let libraryAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        
                    }
                    alert.addAction(libraryAction)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func rightButtonAction() {
        var alertTitle = String()
        switch checkTableViewName {
        case SelectedTableView.libraryTableView.rawValue:
            alertTitle = "My Library"
        case SelectedTableView.recentPlayedTableView.rawValue:
            alertTitle = "RECENTLY PLAYED"
        case SelectedTableView.playlistTableView.rawValue:
            alertTitle = "Playlist"
        default:
            break
        }
        let alert = UIAlertController(title: alertTitle, message: "Are you sure you want to delete \(alertTitle) music list ?", preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "YES", style: .default) { [weak self](action) in
            self?.musicRecordDeletedDelegate?.musicRecordDeletedDelegate(alertTitle)
            self?.deleteRecords()
            self?.selectedSectionTableView.reloadData()
        }
        
        let actionNo = UIAlertAction(title: "NO", style: .cancel) { (action) in
            
        }
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteRecords() -> Void {
        var entityName = String()
        switch checkTableViewName {
        case SelectedTableView.libraryTableView.rawValue:
            entityName = "MyLibraryMusicData"
            myLibraryList = []
        case SelectedTableView.recentPlayedTableView.rawValue:
            entityName = "RecentPlayedMusicData"
            recentPlayedVideo = []
        case SelectedTableView.playlistTableView.rawValue:
            entityName = "Playlist"
            videoPlaylist = []
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
            print("\(entityName) data has been deleted from database and Saved succesfully!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        searchisSelected()
        
        
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        switch pause {
        case true:
            updatePlayerView()
        case false:
            updatePlayerView()
        default:
            break
        }
        
        ActivityIndecator.activitySharedInstace.activityIndecator(self.view, selectedSectionTableView)
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
            } else if let playerState = playerState as? WKYTPlayerState {
                
                self?.updatePlayerState(playerState)
            }
        })
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        searchisSelected()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    
    func searchisSelected() {
        if searchIsSelected == true {
            UserDefaults.standard.set(false, forKey:"checkIfLibraryRowIsSelected")
            selectedSectionTableView.reloadData()
        }
        searchIsSelected = false
    }
    
    
    
    func fetchVideoWithEntityName(_ entityName: String, _ selectedPlaylistName: String){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: entityName, searchBarText: "", playlistName: selectedPlaylistName) { [weak self] (videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if videoList != nil {
                    switch entityName {
                    case "TopHitsModel":
                        self?.topHitsLists.append(videoList!)
                    case "MyLibraryMusicData":
                        self?.myLibraryList.append(videoList!)
                    case "RecentPlayedMusicData":
                        self?.recentPlayedVideo.append(videoList!)
                    case "PlaylistMusicData":
                        self?.videoPlaylist.append(videoList!)
                        
                    default:
                        break
                    }
                    
                    DispatchQueue.main.async {
                        self?.selectedSectionTableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension SelectedSectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        switch checkTableViewName {
        case SelectedTableView.topHitsTableView.rawValue:
            numberOfRowsInSection = topHitsLists.count
        case SelectedTableView.libraryTableView.rawValue:
            numberOfRowsInSection = myLibraryList.count
        case SelectedTableView.recentPlayedTableView.rawValue:
            numberOfRowsInSection = recentPlayedVideo.count
        case SelectedTableView.playlistTableView.rawValue:
            numberOfRowsInSection = videoPlaylist.count
            
        default:
            break
        }
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var selectedTableViewCell = UITableViewCell()
        switch checkTableViewName {
        case SelectedTableView.topHitsTableView.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectedTableViewCellIdentifier, for: indexPath) as? SelectedSectionTableViewCell {
                DispatchQueue.main.async {
                    cell.configureSelectedVideoCell(self.topHitsLists[indexPath.row])
                    
                }
                cell.addToFavoriteButton.tag = indexPath.row;
                cell.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
                selectedTableViewCell = cell
            }else {
                return SelectedSectionTableViewCell()
            }
        case SelectedTableView.libraryTableView.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectedTableViewCellIdentifier, for: indexPath) as? SelectedSectionTableViewCell {
                DispatchQueue.main.async {
                    cell.configureSelectedVideoCell(self.myLibraryList[indexPath.row])
                    
                }
                cell.addToFavoriteButton.isHidden = true
                selectedTableViewCell = cell
            }else {
                return SelectedSectionTableViewCell()
            }
        case SelectedTableView.recentPlayedTableView.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectedTableViewCellIdentifier, for: indexPath) as? SelectedSectionTableViewCell {
                DispatchQueue.main.async {
                    cell.configureSelectedVideoCell(self.recentPlayedVideo[indexPath.row])
                    
                }
                cell.addToFavoriteButton.tag = indexPath.row;
                cell.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
                selectedTableViewCell = cell
            }else {
                return SelectedSectionTableViewCell()
            }
        case SelectedTableView.playlistTableView.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectedTableViewCellIdentifier, for: indexPath) as? SelectedSectionTableViewCell {
                DispatchQueue.main.async {
                    cell.configureSelectedVideoCell(self.videoPlaylist[indexPath.row])
                    
                }
                cell.addToFavoriteButton.isHidden = true
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
        let predicate = NSPredicate(format: "title == %@", selectedCell.videoTitleProperty as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        let alert = UIAlertController(title: "\(selectedCell.videoTitleProperty)", message: "", preferredStyle: .actionSheet)
        let addMyLibraryAction = UIAlertAction(title: "Add to MyLibrary", style: .default) { [weak self](action) in
            do{
                let count = try context?.count(for: request)
                if(count == 0){
                    let entity = NSEntityDescription.entity(forEntityName: "MyLibraryMusicData", in: context!)
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(selectedCell.videoTitleProperty, forKey: "title")
                    newEntity.setValue(selectedCell.videoImageUrlProperty, forKey: "image")
                    newEntity.setValue(selectedCell.videoIDProperty, forKey: "videoId")
                    try context?.save()
                    print("data has been saved ")
                    let selectedImageViewUrl = selectedCell.videoImageUrlProperty
                    AlertView.instance.showAlert(title: "\(selectedCell.videoTitleProperty)", message:"Successfuly added to MyLibrary list", alertType: .success, videoImage: selectedImageViewUrl)
                } else{
                    // at least one matching object exists
                    let alert = UIAlertController(title: "Please check your Library", message: "This song is already exist in your library list", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    }
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                }
            }catch{
                print("error")
            }
        }
        let addPlaylistAction = UIAlertAction(title: "Add to Playlist", style: .default) { (action) in
            UserDefaults.standard.set(selectedCell.videoIDProperty, forKey:"videoId")
            UserDefaults.standard.set(selectedCell.videoImageUrlProperty, forKey:"image")
            UserDefaults.standard.set(selectedCell.videoTitleProperty, forKey:"title")
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
        switch checkTableViewName {
        case SelectedTableView.topHitsTableView.rawValue:
            canEdit = false
        case SelectedTableView.libraryTableView.rawValue:
            canEdit =  true
        case SelectedTableView.recentPlayedTableView.rawValue:
            canEdit =  true
        default:
            break
        }
        return canEdit
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <=  0.000000 {
            ActivityIndecator.activitySharedInstace.activityIndicatorView.startAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == MainLibrariMusciTableViewCell.EditingStyle.delete{
            removeSelectedVideoRow(atIndexPath: indexPath)
            switch checkTableViewName {
            case SelectedTableView.libraryTableView.rawValue:
                myLibraryList.remove(at: indexPath.row)
            case SelectedTableView.recentPlayedTableView.rawValue:
                recentPlayedVideo.remove(at: indexPath.row)
            default:
                break
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    func removeSelectedVideoRow(atIndexPath indexPath: IndexPath) {
        var entityName = String()
        switch checkTableViewName {
        case SelectedTableView.libraryTableView.rawValue:
            entityName = myLibraryEntityName
        case SelectedTableView.recentPlayedTableView.rawValue:
            entityName = recentPlayedEntityName
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
        ifRowIsSelectedDelegate?.checkIfRowIsSelected(true)
        switch checkTableViewName {
        case SelectedTableView.libraryTableView.rawValue:
            
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
        case SelectedTableView.topHitsTableView.rawValue:
            
            let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.videoTitleProperty, videoImage: selectedCell.videoImageUrlProperty, videoId: selectedCell.videoIDProperty, playlistName: "", coreDataEntityName: "RecentPlayedMusicData") { (checkIfLoadIsSuccessful, error, checkIfSongAlreadyInDatabase) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
            }
        case SelectedTableView.recentPlayedTableView.rawValue:
            
            
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
        case SelectedTableView.playlistTableView.rawValue:
            
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
        default:
            break
        }
    }
    
    
    func getSelectedMusicRowAndPlayVideoPlayer(_ indexPath: IndexPath){
         VideoPlayer.callVideoPlayer.cardViewController.view = nil
        let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
        
        VideoPlayer.callVideoPlayer.webView.pauseVideo()
        VideoPlayer.callVideoPlayer.superViewController = self
        
        VideoPlayer.callVideoPlayer.videoPalyerClass(genreVideoID: selectedCell.videoIDProperty, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: selectedCell.topHitLabelText.text!)
        
        selectedSectionTableView.reloadData()
    }
}


