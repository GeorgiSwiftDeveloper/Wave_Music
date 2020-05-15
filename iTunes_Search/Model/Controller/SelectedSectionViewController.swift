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
    var genreVideoID: String?
    var webView = WKYTPlayerView()
    var selectedVideo: Video?
    var topHitsListHeight = 190
    
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
        VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
        self.navigationController?.navigationBar.isHidden = false
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
                cell.configureTopHitsCell(topHitsLists[indexPath.row])
                cell.addToFavoriteButton.tag = indexPath.row;
                cell.addToFavoriteButton.addTarget(self, action: #selector(addToMyLibraryButton(sender:)), for: .touchUpInside)
                return cell
            }else {
                return SellectedSectionTableViewCell()
            }
        case true:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "topHitsCell", for: indexPath) as? SellectedSectionTableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checDelegate?.checkIfRowIsSelectedDelegate(true)
        switch checkTable {
        case true:
            VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
            let selectedVideo = myLibraryList[indexPath.row]
            webView.load(withVideoId: "")
            let sellectedCell = self.sellectedSectionTableView.cellForRow(at: indexPath) as! SellectedSectionTableViewCell
            genreVideoID = selectedVideo.videoId
//            UserDefaults.standard.set(true, forKey:"selectedFromSectionVideo")
            VideoPlayerClass.callVideoPlayer.superViewController = self
            VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: sellectedCell, genreVideoID: genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: selectedVideo)
        case false:
            VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
            topHitsListNSBottomLayout.constant = CGFloat(topHitsListHeight)
            selectedVideo = topHitsLists[indexPath.row]
            webView.load(withVideoId: "")
            let sellectedCell = self.sellectedSectionTableView.cellForRow(at: indexPath) as! SellectedSectionTableViewCell
            genreVideoID = selectedVideo?.videoId
//            UserDefaults.standard.set(true, forKey:"selectedFromSectionVideo")
            VideoPlayerClass.callVideoPlayer.superViewController = self
            VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: sellectedCell, genreVideoID: genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: selectedVideo!)
        }
    }
}
