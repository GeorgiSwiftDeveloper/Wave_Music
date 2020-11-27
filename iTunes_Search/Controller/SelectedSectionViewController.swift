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

protocol CheckIfMusicRecordDeletedDelegate:AnyObject {
    func musicRecordDeletedDelegate(_ alertTitleName: String)
}

class SelectedSectionViewController: UIViewController,WKNavigationDelegate,WKYTPlayerViewDelegate, CheckIfSelectedSongIsExsistInDatabaseDelegate {
    
    let defaults = UserDefaults.standard
    
    var webView = WKYTPlayerView()
    var topHitsLists = [Video]()
    var myLibraryList = [Video]()
    var recentPlayedVideo = [Video]()
    var videoPlaylist = [Video]()
    
    
    var descriptionLabel = MusicTextLabel()
    
    var checkTableViewName = String()
    
    var selectedGenreTitle: String?
    var videoArray = [Video]()
    var entityName = String()
    var youTubeVideoID =  String()
    var youTubeVideoTitle =  String()
    var selectedIndex = Int()
    
    weak var musicRecordDeletedDelegate: CheckIfMusicRecordDeletedDelegate?
    
    
    var coreDataConnectionManage = CoreDataVideoClass()
    
    @IBOutlet weak var sectedTableViewTopNSLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectedSectionTableView: UITableView!
    
    var isEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.takeGenreName(selectedGenreTitle!))
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedSectionTableView.delegate = self
        self.selectedSectionTableView.dataSource = self
        
        self.coreDataConnectionManage.selectedSongIsAlreadyExsistInDatabase = self
        
        returnTableViewNameWithAction()
    }
    
    
    func returnTableViewNameWithAction() {
        switch checkTableViewName {
        case SelectedTableView.topHitsTableView.rawValue:
            fetchVideoWithEntityName(topHitsEntityName, selectedPlaylistName: "")
        case SelectedTableView.libraryTableView.rawValue:
            fetchVideoWithEntityName(myLibraryEntityName, selectedPlaylistName: "")
            let deleteButton = UIBarButtonItem(image: SFSymbols.trush, style: .plain, target: self, action:#selector(rightButtonAction))
            self.navigationItem.rightBarButtonItem  = deleteButton
        case SelectedTableView.recentPlayedTableView.rawValue:
            fetchVideoWithEntityName(recentPlayedEntityName, selectedPlaylistName: "")
            let deleteButton = UIBarButtonItem(image: SFSymbols.trush, style: .plain, target: self, action:#selector(rightButtonAction))
            self.navigationItem.rightBarButtonItem  = deleteButton
            if recentPlayedVideo.count == 0 {
                let alert = UIAlertController(title: "No Tracks Found", message: "Your recently played songs will be placed here after you play any song", preferredStyle: .alert)
                let libraryAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.selectedIndex = 2
                    self.tabBarController?.tabBar.isHidden = false
                }
                alert.addAction(libraryAction)
                present(alert, animated: true, completion: nil)
            }
        case SelectedTableView.playlistTableView.rawValue:
            guard let selectedPaylistName = UserDefaults.standard.object(forKey: "selectedPlaylistRowTitle") as? String else{return}
            saveSelectedMusicCoreDataEntity(selectedPaylistName)
            
            fetchVideoWithEntityName(playlistEntityName, selectedPlaylistName: selectedPaylistName)
            
            UserDefaults.standard.removeObject(forKey: "videoId")
            UserDefaults.standard.removeObject(forKey: "image")
            UserDefaults.standard.removeObject(forKey: "title")
            
            let deleteButton = UIBarButtonItem(image: SFSymbols.trush, style: .plain, target: self, action:#selector(rightButtonAction))
            self.navigationItem.rightBarButtonItem  = deleteButton
            if videoPlaylist.count == 0 {
                SettingsDetailView.sharedSettingsDetail.showPlaylistAlertView(title: "No Tracks Found", message: "Your songs will be placed here after you add any song", actionTitle: "OK", view: self)
            }else{
                UserDefaults.standard.set(videoPlaylist.count, forKey: "videoPlaylistCount")
            }
        case SelectedTableView.genreCollectionView.rawValue:
            self.showDescriptonLabelInGenreView()
            
            if isEmpty{
                DispatchQueue.global(qos: .background).async {
                    YouTubeVideoConnection.getYouTubeVideoInstace.getYouTubeVideo(genreType: self.selectedGenreTitle!, selectedViewController: "genreList") { (loadVideolist, error) in
                        if error != nil {
                            print(error?.localizedDescription as Any)
                        }else{
                            self.videoArray = loadVideolist!
                            for songIndex in 0..<self.videoArray.count{
                                let title =   self.videoArray[songIndex].videoTitle ?? ""
                                let image =  self.videoArray[songIndex].videoImageUrl ?? ""
                                let videoId =  self.videoArray[songIndex].videoId ?? ""
                                let genreTitle = self.videoArray[songIndex].genreTitle ?? ""
                                CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: title, videoImage: image, videoId: videoId, playlistName: "", coreDataEntityName:self.takeGenreName(genreTitle))
                            }
                            DispatchQueue.main.async {
                                self.selectedSectionTableView.reloadData()
                            }
                        }
                    }
                }
            }else{
                fetchVideoWithEntityNameGenre()
            }
        default:
            break
        }
    }
    
    
    
    func showDescriptonLabelInGenreView(){
        sectedTableViewTopNSLayoutConstraint.constant  += 75
        descriptionLabel = MusicTextLabel(frame: CGRect(x: 15, y: (navigationController?.navigationBar.frame.height)!, width: UIScreen.main.bounds.width, height: 65))
        descriptionLabel.font = UIFont(name: "Verdana", size: 14)
        let attributedString = NSMutableAttributedString(string: "Discover new music from \(selectedGenreTitle!) genre we think you'll like.Rereshed every Friday.")
        let paragraphStyle = NSMutableParagraphStyle()
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 4
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        descriptionLabel.attributedText = attributedString
        self.view.addSubview(descriptionLabel)
    }
    
    
    func ifSelectedSongIsExsistInDatabase(_ coreDataMananger: CoreDataVideoClass, _ ifAlreadyInDatabase: Bool) {
        if ifAlreadyInDatabase {
            let videoTitleProperty = UserDefaults.standard.object(forKey: "title") as? String
            SettingsDetailView.sharedSettingsDetail.showAlertView(title: "Please check your Playlist", message: "\(videoTitleProperty ?? "")  already exist in your list", actionTitle: "OK", view: self)
        }else{
            let videoTitleProperty = UserDefaults.standard.object(forKey: "title") as? String
            SettingsDetailView.sharedSettingsDetail.showAlertView(title:"\(videoTitleProperty ?? "")", message:"Successfuly added to the playlist", actionTitle: "OK", view: self)
        }
    }
    
    
    func saveSelectedMusicCoreDataEntity(_ selectedPlaylistRowTitle: String) {
        
        let videoIDProperty = UserDefaults.standard.object(forKey: "videoId") as? String
        let videoImageUrlProperty = UserDefaults.standard.object(forKey: "image") as? String
        let videoTitleProperty = UserDefaults.standard.object(forKey: "title") as? String
        
        if (videoIDProperty != nil) || (videoImageUrlProperty != nil) || (videoTitleProperty != nil) {
            coreDataConnectionManage.saveVideoWithEntityName(videoTitle: videoTitleProperty!, videoImage: videoImageUrlProperty!, videoId: videoIDProperty!, playlistName: selectedPlaylistRowTitle, coreDataEntityName: playlistEntityName)
            
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
            DispatchQueue.main.async {
                self?.selectedSectionTableView.reloadData()
            }
        }
        
        let actionNo = UIAlertAction(title: "NO", style: .default, handler: nil)
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteRecords() -> Void {
        var entityName = String()
        switch checkTableViewName {
        case SelectedTableView.libraryTableView.rawValue:
            entityName = myLibraryEntityName
            myLibraryList = []
        case SelectedTableView.recentPlayedTableView.rawValue:
            entityName = recentPlayedEntityName
            recentPlayedVideo = []
        case SelectedTableView.playlistTableView.rawValue:
            entityName =  playlistEntityName
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
            } else {
                
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
        self.navigationController?.navigationBar.isHidden = false
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
    
    func fetchVideoWithEntityNameGenre(){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: self.takeGenreName(selectedGenreTitle!), searchBarText: "", playlistName: "") { [weak self]  (result) in
            
            switch result {
            case .success(let videoList):
                self?.videoArray.append(contentsOf: videoList)
                DispatchQueue.main.async {
                    self?.selectedSectionTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            
            
        }
    }
    
    
    func fetchVideoWithEntityName(_ entityName: String,selectedPlaylistName: String){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: entityName, searchBarText: "", playlistName: selectedPlaylistName) { [weak self] (result) in
            
            guard let self = self else{ return}
            switch entityName {
            case topHitsEntityName:
                switch result {
                case .success(let videoList):
                    self.topHitsLists.append(contentsOf: videoList)
//                    self.defaults.setValue(self.topHitsLists.count, forKey: "topHitsCount")
                case .failure(let error):
                    print(error)
                }
            case myLibraryEntityName:
                switch result {
                case .success(let videoList):
                    self.myLibraryList.append(contentsOf: videoList)
                case .failure(let error):
                    print(error)
                }
            case recentPlayedEntityName:
                switch result {
                case .success(let videoList):
                    self.recentPlayedVideo.append(contentsOf: videoList)
                case .failure(let error):
                    print(error)
                }
            case playlistEntityName:
                switch result {
                case .success(let videoList):
                    self.videoPlaylist.append(contentsOf: videoList)
                case .failure(let error):
                    print(error)
                }
            default:
                break
                
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
        case SelectedTableView.genreCollectionView.rawValue:
            numberOfRowsInSection = videoArray.count
        default:
            break
        }
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var selectedTableViewCell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: selectedTableViewCellIdentifier, for: indexPath) as? SelectedSectionTableViewCell
        switch checkTableViewName {
        case SelectedTableView.topHitsTableView.rawValue:
            DispatchQueue.main.async { [self] in
                cell?.configureSelectedVideoCell(self.topHitsLists[indexPath.row])
                
            }
            cell?.addToFavoriteButton.tag = indexPath.row;
            cell?.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
            
            selectedTableViewCell = cell!
        case SelectedTableView.libraryTableView.rawValue:
            DispatchQueue.main.async {
                cell?.configureSelectedVideoCell(self.myLibraryList[indexPath.row])
                
            }
            cell?.addToFavoriteButton.isHidden = true
            selectedTableViewCell = cell!
            
        case SelectedTableView.recentPlayedTableView.rawValue:
            
            DispatchQueue.main.async {
                cell!.configureSelectedVideoCell(self.recentPlayedVideo[indexPath.row])
                
            }
            cell!.addToFavoriteButton.tag = indexPath.row;
            cell?.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
            selectedTableViewCell = cell!
        case SelectedTableView.playlistTableView.rawValue:
            
            DispatchQueue.main.async {
                cell?.configureSelectedVideoCell(self.videoPlaylist[indexPath.row])
                
            }
            cell?.addToFavoriteButton.isHidden = true
            selectedTableViewCell = cell!
        case SelectedTableView.genreCollectionView.rawValue:
            DispatchQueue.main.async {
                cell?.configureSelectedVideoCell(self.videoArray[indexPath.row])
            }
            cell?.addToFavoriteButton.tag = indexPath.row
            cell?.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
            selectedTableViewCell = cell!
        default:
            break
        }
        return selectedTableViewCell
    }
    
    
    @objc func addToMyLibraryButton(sender: UIButton){
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        self.selectedSectionTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        let selectedCell = self.selectedSectionTableView.cellForRow(at: selectedIndex) as! SelectedSectionTableViewCell
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myLibraryEntityName)
        let predicate = NSPredicate(format: "title == %@", selectedCell.videoTitle as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        let alert = UIAlertController(title: "\(selectedCell.videoTitle)", message: "", preferredStyle: .actionSheet)
        let addMyLibraryAction = UIAlertAction(title: "Add to MyLibrary", style: .default) { [weak self](action) in
            do{
                let count = try context?.count(for: request)
                if(count == 0){
                    let entity = NSEntityDescription.entity(forEntityName: myLibraryEntityName, in: context!)
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(selectedCell.videoTitle, forKey: "title")
                    newEntity.setValue(selectedCell.imageViewUrl, forKey: "image")
                    newEntity.setValue(selectedCell.videoID, forKey: "videoId")
                    try context?.save()
                    print("data has been saved ")
                    let selectedImageViewUrl = selectedCell.imageViewUrl
                    AlertView.instance.showAlert(title: "\(selectedCell.videoTitle)", message:"Successfuly added to MyLibrary list", alertType: .success, videoImage: selectedImageViewUrl)
                } else{
                    // at least one matching object exists
                    let alert = UIAlertController(title: "Please check your Library", message: "This song is already exist in your library list", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                }
            }catch{
                print("error")
            }
        }
        let addPlaylistAction = UIAlertAction(title: "Add to Playlist", style: .default) { (action) in
            UserDefaults.standard.set(selectedCell.videoID, forKey:"videoId")
            UserDefaults.standard.set(selectedCell.imageViewUrl, forKey:"image")
            UserDefaults.standard.set(selectedCell.videoTitle, forKey:"title")
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.selectedIndex = 2
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
            case SelectedTableView.genreCollectionView.rawValue:
                videoArray.remove(at: indexPath.row)
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
        case SelectedTableView.genreCollectionView.rawValue:
            entityName = self.takeGenreName(selectedGenreTitle!)
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
        switch checkTableViewName {
        case SelectedTableView.libraryTableView.rawValue:
            
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
        case SelectedTableView.topHitsTableView.rawValue:
            
            let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.videoTitle, videoImage: selectedCell.imageViewUrl, videoId: selectedCell.videoID, playlistName: "", coreDataEntityName: recentPlayedEntityName)
            
        case SelectedTableView.recentPlayedTableView.rawValue:
            
            
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
        case SelectedTableView.playlistTableView.rawValue:
            
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
        case SelectedTableView.genreCollectionView.rawValue:
            
            let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
            self.getSelectedMusicRowAndPlayVideoPlayer(indexPath)
            
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.videoTitle, videoImage: selectedCell.imageViewUrl, videoId: selectedCell.videoID, playlistName: "", coreDataEntityName: recentPlayedEntityName)
        default:
            break
        }
    }
    
    
    func getSelectedMusicRowAndPlayVideoPlayer(_ indexPath: IndexPath){
        VideoPlayer.callVideoPlayer.cardViewController.view = nil
        let selectedCell = self.selectedSectionTableView.cellForRow(at: indexPath) as! SelectedSectionTableViewCell
        
        VideoPlayer.callVideoPlayer.webView.pauseVideo()
        VideoPlayer.callVideoPlayer.superViewController = self
        
        VideoPlayer.callVideoPlayer.videoPalyerClass(genreVideoID: selectedCell.videoID, videoImageName: selectedCell.imageViewUrl, superView: self, selectedVideoTitle: selectedCell.topHitLabelText.text!)
        DispatchQueue.main.async {
            self.selectedSectionTableView.reloadData()
        }
    }
}


