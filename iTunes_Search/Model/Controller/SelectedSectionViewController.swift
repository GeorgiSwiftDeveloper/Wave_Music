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
    var checkTable = Bool()
    var videoSelected = false
    var checkVideoIsSelected = false
    var libraryIsSelected = false
    var topHitsIsSelected = false
    var genreVideoID: String?
    var webView = WKYTPlayerView()
    var selectedVideo: Video?
    var topHitsListHeight = 190
    var selectedIndex = Int()
    var searchIsSelected = Bool()
    
    weak var checDelegate: CheckIfRowIsSelectedDelegate?
    
    @IBOutlet weak var sellectedSectionTableView: UITableView!
    @IBOutlet weak var topHitsListNSBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var myLibraryListNSBottomLayout: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sellectedSectionTableView.delegate = self
        self.sellectedSectionTableView.dataSource = self
        if checkTable == false{
            fetchTopHitList()
            topHitsListNSBottomLayout.constant = 120
        }else{
            fetchMyLibraryList()
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
        if self.checkTable == false{
            self.topHitsListNSBottomLayout.constant = CGFloat(self.topHitsListHeight)
        }
        self.view.layoutIfNeeded()
    }
    
    func showVideoPlayerPause(){
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        if self.checkTable == false{
            self.topHitsListNSBottomLayout.constant = CGFloat(self.topHitsListHeight)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        searchisSelected()
        VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierSearchRowSelected(notification:)), name: Notification.Name("NotificationIdentifierSearchRowSelected"), object: nil)
        
    }
    
    @objc func NotificationIdentifierSearchRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkIfLibraryRowIsSelected")
        sellectedSectionTableView.reloadData()
        
    }
    
    
    @objc func NotificationIdentifierGenreRowSelected(notification: Notification) {
         UserDefaults.standard.set(false, forKey:"checkIfLibraryRowIsSelected")
         sellectedSectionTableView.reloadData()

     }
    
    
    func searchisSelected() {
        if searchIsSelected == true {
            UserDefaults.standard.set(false, forKey:"checkIfLibraryRowIsSelected")
            sellectedSectionTableView.reloadData()
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
                sellectedSectionTableView.reloadData()
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
                sellectedSectionTableView.reloadData()
            }
            
        } catch {
            print("Failed")
        }
    }
}

extension SelectedSectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        switch checkTable {
        case false:
            numberOfRowsInSection = topHitsLists.count
        case true:
            numberOfRowsInSection = myLibraryList.count
        }
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch checkTable {
        case false:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? SellectedSectionTableViewCell {
                var checkIfRowIsSelected = UserDefaults.standard.object(forKey: "checkIfLibraryRowIsSelected") as? Bool
                let saveTopHitsSelectedIndex = UserDefaults.standard.object(forKey: "saveTopHitsSelectedIndex") as? Int
                let checkIfAnotherViewControllerRowIsSelected = UserDefaults.standard.object(forKey: "checkIfAnotherViewControllerRowIsSelected") as? Bool
                if checkIfAnotherViewControllerRowIsSelected == true {
                    checkIfRowIsSelected = false
                }
                DispatchQueue.main.async {
                    if checkIfRowIsSelected == true{
                        if(indexPath.row == saveTopHitsSelectedIndex)
                        {
                            cell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                        }else{
                            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
                        }
                    }else{
                        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
                    }
                }
                cell.configureTopHitsCell(topHitsLists[indexPath.row])
                cell.addToFavoriteButton.tag = indexPath.row;
                cell.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
                return cell
            }else {
                return SellectedSectionTableViewCell()
            }
        case true:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? SellectedSectionTableViewCell {
                var checkIfLibraryRowIsSelected = UserDefaults.standard.object(forKey: "checkIfLibraryRowIsSelected") as? Bool
                let saveLibrarySelectedIndex = UserDefaults.standard.object(forKey: "saveLibrarySelectedIndex") as? Int
                let checkIfAnotherViewControllerRowIsSelected = UserDefaults.standard.object(forKey: "checkIfAnotherViewControllerRowIsSelected") as? Bool
                if checkIfAnotherViewControllerRowIsSelected == true {
                    checkIfLibraryRowIsSelected = false
                }
                DispatchQueue.main.async {
                    if checkIfLibraryRowIsSelected == true{
                        if(indexPath.row == saveLibrarySelectedIndex)
                        {
                            cell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                        }else{
                            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                            cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
                        }
                    }else{
                        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        cell.topHitLabelText.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
                    }
                }
                cell.configureMyLibraryCell(myLibraryList[indexPath.row])
                cell.addToFavoriteButton.isHidden = true
                return cell
            }else {
                return SellectedSectionTableViewCell()
            }
        }
    }
    
    @objc func addToMyLibraryButton(sender: UIButton) {
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        self.sellectedSectionTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        let selectedCell = self.sellectedSectionTableView.cellForRow(at: selectedIndex) as! SellectedSectionTableViewCell
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        let predicate = NSPredicate(format: "title == %@", selectedCell.topHitLabelText.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        do{
            let count = try context?.count(for: request)
            if(count == 0){
                // no matching object
                let entity = NSEntityDescription.entity(forEntityName: "MyLibraryMusicData", in: context!)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                newEntity.setValue(selectedCell.topHitLabelText.text!, forKey: "title")
                newEntity.setValue(selectedCell.videoImageUrl, forKey: "image")
                newEntity.setValue(selectedCell.videoID, forKey: "videoId")
                myLibraryList = []
                try context?.save()
                print("data has been saved ")
                let alert = UIAlertController(title: "\(selectedCell.topHitLabelText.text ?? "")) was successfully added to your Library list", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            else{
                // at least one matching object exists
                let alert = UIAlertController(title: "Please check your Library", message: "This song is already exist in your library list", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    
                }
                
                let libraryAction = UIAlertAction(title: "My Library", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.selectedIndex = 0
                    self.tabBarController?.tabBar.isHidden = false
                }
                
                alert.addAction(action)
                alert.addAction(libraryAction)
                present(alert, animated: true, completion: nil)
                
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == MainLibrariMusciTableViewCell.EditingStyle.delete{
            removeSelectedVideoRow(atIndexPath: indexPath)
            myLibraryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    func removeSelectedVideoRow(atIndexPath indexPath: IndexPath) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        let result = try? context?.fetch(request)
        let resultData = result as! [NSManagedObject]
        context?.delete(resultData[indexPath.row])
        do{
            try context?.save()
//            if myLibraryList.count <= 4 {
//                sectionButton.isHidden = true
//            }
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
        case true:
            DispatchQueue.main.async {
                let selectedVideo = self.myLibraryList[indexPath.row]
                let sellectedCell = self.sellectedSectionTableView.cellForRow(at: indexPath) as! SellectedSectionTableViewCell
                self.genreVideoID = selectedVideo.videoId
                self.getSelectedLibraryVideo(indexPath)
                self.webView.load(withVideoId: "")
                VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: sellectedCell, genreVideoID: self.genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: selectedVideo)
                
            }
        case false:
            DispatchQueue.main.async {
                self.topHitsListNSBottomLayout.constant = CGFloat(self.topHitsListHeight)
                self.selectedVideo = self.topHitsLists[indexPath.row]
                let selectedCell = self.sellectedSectionTableView.cellForRow(at: indexPath) as! SellectedSectionTableViewCell
                self.genreVideoID = self.selectedVideo?.videoId
                self.getSelectedTopHitsVideo(indexPath)
                self.webView.load(withVideoId: "")
                VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: self.selectedVideo!)
                
                FetchRecentPlayedVideo.fetchRecentPlayedVideo.saveRecentPlayedVideo(selectedCellTitleLabel: selectedCell.topHitLabelText.text!, selectedCellImageViewUrl: selectedCell.videoImageUrl, selectedCellVideoID: selectedCell.videoID) { (checkIfLoadIsSuccessful, error) in
                    if error != nil {
                        print(error)
                    }
                }
            }
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
        sellectedSectionTableView.reloadData()
    }
    
    
    func getSelectedTopHitsVideo(_ indexPath: IndexPath){
        UserDefaults.standard.set(true, forKey:"checkIfLibraryRowIsSelected")
        UserDefaults.standard.set(false, forKey:"checkIfAnotherViewControllerRowIsSelected")
        selectedIndex = indexPath.row
        UserDefaults.standard.set(selectedIndex, forKey:"saveTopHitsSelectedIndex")
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        VideoPlayerClass.callVideoPlayer.superViewController = self
        UserDefaults.standard.removeObject(forKey: "saveLibrarySelectedIndex")
        sellectedSectionTableView.reloadData()
      }
}


