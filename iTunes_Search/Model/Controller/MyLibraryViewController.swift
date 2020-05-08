//
//  MyLibraryViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/24/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import  YoutubePlayer_in_WKWebView
class MyLibraryViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, WKNavigationDelegate, WKYTPlayerViewDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var mainLibraryTableView: UITableView!
    @IBOutlet weak var topMusicTableView: UITableView!
    @IBOutlet weak var myLibraryNSBottomLayout: NSLayoutConstraint!
    
    var myLibraryListArray = [Video]()
    var topHitsArray = [Video]()
    var getYouTubeData  = YouTubeVideoConnection()
    var webView = WKYTPlayerView()
    
    var topHits = true
    var myLibrary = true
    var genreVideoID: String?
    var sectionButton = UIButton()
    
    var videoSelected = Bool()
    var isEntityIsEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    var videoPlayerClass = VideoPlayerClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        UserDefaults.standard.removeObject(forKey: "selectedFromSectionVideo")
        UserDefaults.standard.removeObject(forKey: "pause")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.synchronize()
        setupNavBar()
        mainLibraryTableView.alwaysBounceVertical = false
        self.mainLibraryTableView.delegate = self
        self.mainLibraryTableView.dataSource = self
        self.topMusicTableView.delegate = self
        self.topMusicTableView.dataSource = self
        
        getYouTubeResluts()
    }
    
    
    func getYouTubeResluts(){
        if isEntityIsEmpty{
            self.getYouTubeData.getFeedVideos(genreType: "Hits", selectedViewController: "MyLibraryViewController") { (loadVideolist, error) in
                if error != nil  {
                    print("erorr")
                }else{
                    DispatchQueue.main.async{
                        self.topHitsArray = loadVideolist!
                        for songIndex in 0..<self.topHitsArray.count{
                            let title =   self.topHitsArray[songIndex].videoTitle
                            let description =  self.topHitsArray[songIndex].videoDescription
                            let image =  self.topHitsArray[songIndex].videoImageUrl
                            let playlistId = self.topHitsArray[songIndex].videoPlaylistId
                            let videoId =  self.topHitsArray[songIndex].videoId
                            let channelId =  self.topHitsArray[songIndex].channelId
                            
                            self.saveItems(title: title, description: description, image: image, videoId: videoId, playlistId: playlistId,genreTitle: "Hits", channelId: channelId)
                            self.topMusicTableView.reloadData()
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
                        self.topHitsArray.append(videoList!)
                        self.topMusicTableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        DispatchQueue.main.async {
            self.myLibraryListArray = []
            self.fetchMyLibraryList()
            self.mainLibraryTableView.reloadData()
            let ifSelectedTopHit = UserDefaults.standard.object(forKey: "selectedFromSectionVideo") as? Bool
            let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
            if self.videoSelected == true {
                if pause == nil || pause == true{
                    self.showVideoPlayer()
                }else{
                    self.showVideoPlayerPause()
                }
            }
            if ifSelectedTopHit == true{
                if pause == nil  || pause == true {
                    self.showVideoPlayer()
                }else{
                    self.showVideoPlayerPause()
                }
            }
        }
    }
    
    
       override func viewDidAppear(_ animated: Bool) {
           super .viewDidAppear(animated)
         NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("not"), object: nil)
       
       }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
             self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
                VideoPlayerClass.callVideoPlayer.webView.playVideo()
     }
       
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        VideoPlayerClass.callVideoPlayer.superViewController?.removeFromParent()
        VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
         self.navigationController?.navigationBar.isHidden = false
    }
    
    func showVideoPlayer(){
        VideoPlayerClass.callVideoPlayer.superViewController = self
        self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
        VideoPlayerClass.callVideoPlayer.webView.playVideo()
    }
    func showVideoPlayerPause(){
        VideoPlayerClass.callVideoPlayer.superViewController = self
        self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
    }
    
    func fetchFromCoreData(loadVideoList: @escaping(_ returnVideoList: Video?, _ returnError: Error? ) -> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
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
    
    func saveItems(title:String,description:String,image:String,videoId:String,playlistId:String,genreTitle: String, channelId: String) {
        let entity = NSEntityDescription.entity(forEntityName: "TopHitsModel", in: context!)
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
    
    
    func setupNavBar() {
        searchController.searchBar.placeholder = "search My Library"
        searchController.searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.isHidden = false
        searchController.hidesNavigationBarDuringPresentation = true
        self.definesPresentationContext = true
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("search end editing.")
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == false{
            fetchSearchSong(searchBar, searchText: searchText)
        }else{
            myLibraryListArray = []
            fetchMyLibraryList()
            
        }
    }
    
    
    func fetchSearchSong(_ searchBar: UISearchBar, searchText: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        let predicate = NSPredicate(format: "title contains[c]%@", searchBar.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try context?.count(for: request)
            if(count == 0){
                // no matching object
                print("no match")
            }else{
                let fetchResult = try context?.fetch(request) as? [Video]
                myLibraryListArray = []
                myLibraryListArray = fetchResult!
                mainLibraryTableView.reloadData()
                print("match")
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
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
                
                
                myLibraryListArray.append(videoList)
                mainLibraryTableView.reloadData()
            }
            
        } catch {
            print("Failed")
        }
    }
    
    
    
}

extension MyLibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleName = ""
        switch tableView {
        case mainLibraryTableView:
            titleName = "My Library"
        case topMusicTableView:
            titleName = "Top Hit's"
        default:
            break
        }
        return titleName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 1
        switch tableView {
        case mainLibraryTableView:
            numberOfRowsInSection = myLibraryListArray.count
        case topMusicTableView:
            numberOfRowsInSection = topHitsArray.count
        default:
            break
        }
        return numberOfRowsInSection
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var rowHeiight = 0
        switch tableView {
        case topMusicTableView:
            rowHeiight = 65
        case mainLibraryTableView:
            rowHeiight = 40
        default:
            break
        }
        return CGFloat(rowHeiight)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana-Bold", size: 20)!
        header.textLabel?.textColor = #colorLiteral(red: 0.06852825731, green: 0.05823112279, blue: 0.1604561806, alpha: 0.8180118865)
        if tableView == topMusicTableView{
            let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 100, y: 10, width: 100, height: 40))
            button.tag = section
            button.setTitle("See more", for: .normal)
            button.titleLabel?.font =  UIFont(name: "Verdana", size: 14)
            button.setTitleColor(#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), for: .normal)
            header.addSubview(button)
            button.addTarget(self, action: #selector(destinationTopHitsVC), for: .touchUpInside)
        }else{
            if myLibraryListArray.count >= 4{
                let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 100, y: 10, width: 100, height: 40))
                button.tag = section
                button.setTitle("See more", for: .normal)
                button.titleLabel?.font =  UIFont(name: "Verdana", size: 14)
                button.setTitleColor(#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), for: .normal)
                header.addSubview(button)
                sectionButton = button
                button.addTarget(self, action: #selector(destinationMyLibraryVC), for: .touchUpInside)
            }
        }
    }
    
    
    @objc func destinationTopHitsVC(){
        self.performSegue(withIdentifier: "TopHitsMusic", sender: nil)
    }
    
    
    @objc func destinationMyLibraryVC(){
        self.performSegue(withIdentifier: "MyLibraryMusic", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TopHitsMusic" {
            if  let nc = segue.destination as? SellectedSectionViewController {
                nc.navigationItem.title = "Top Tracks"
                if videoSelected == true{
                    nc.videoSelected = true
                }
                nc.checkTable = false
            }
        }else if segue.identifier == "MyLibraryMusic" {
            if  let nc = segue.destination as? SellectedSectionViewController {
                nc.navigationItem.title = "My Library"
                if videoSelected == true{
                    nc.videoSelected = true
                }
                nc.checkTable = true
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case mainLibraryTableView:
            let  libraryMusicCell = (tableView.dequeueReusableCell(withIdentifier: "LibraryMusicCell", for: indexPath) as? MainLibrariMusciTableViewCell)!
            libraryMusicCell.configureGenreCell(myLibraryListArray[indexPath.row])
            cell = libraryMusicCell
        case topMusicTableView:
            let  topHitsMusicCell = (tableView.dequeueReusableCell(withIdentifier: "TopHitsTableViewCell", for: indexPath) as? TopHitsTableViewCell)!
            topHitsMusicCell.configureGenreCell(topHitsArray[indexPath.row])
            topHitsMusicCell.addToFavoriteButton.tag = indexPath.row;
            topHitsMusicCell.addToFavoriteButton.addTarget(self, action: #selector(addToFavoriteTapped), for: .touchUpInside)
            cell = topHitsMusicCell
        default:
            break
        }
        return cell
    }
    
    @objc func addToFavoriteTapped(sender: UIButton){
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        self.topMusicTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        let selectedCell = self.topMusicTableView.cellForRow(at: selectedIndex) as! TopHitsTableViewCell
        
        print(selectedCell.videoImageUrl)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        let predicate = NSPredicate(format: "title == %@", selectedCell.topHitSongTitle.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try context?.count(for: request)
            if(count == 0){
                // no matching object
                let entity = NSEntityDescription.entity(forEntityName: "MyLibraryMusicData", in: context!)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                newEntity.setValue(selectedCell.topHitSongTitle.text, forKey: "title")
                newEntity.setValue(selectedCell.videoImageUrl, forKey: "image")
                newEntity.setValue(selectedCell.videoID, forKey: "videoId")
                myLibraryListArray = []
                try context?.save()
                print("data has been saved ")
                self.fetchMyLibraryList()
            }
            else{
                // at least one matching object exists
                let alert = UIAlertController(title: "Please check your Library", message: "This song is already exist in your library list", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
                }
                
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case mainLibraryTableView:
            self.myLibraryNSBottomLayout.constant = 175
            let selectedVideoId = myLibraryListArray[indexPath.row]
            webView.load(withVideoId: "")
            let selectedCell = self.topMusicTableView.cellForRow(at: indexPath) as! TopHitsTableViewCell
            genreVideoID = selectedVideoId.videoId
            videoSelected = true
//            VideoPlayerClass.callVideoPlayer.superViewController = self
            VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: selectedVideoId)
        case topMusicTableView:
            self.myLibraryNSBottomLayout.constant = 175
            let selectedVideoId = topHitsArray[indexPath.row]
            webView.load(withVideoId: "")
            let selectedCell = self.topMusicTableView.cellForRow(at: indexPath) as! TopHitsTableViewCell
            genreVideoID = selectedVideoId.videoId
            videoSelected = true
//            VideoPlayerClass.callVideoPlayer.superViewController = self
            VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: selectedVideoId)
            
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == topMusicTableView{
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == MainLibrariMusciTableViewCell.EditingStyle.delete{
            removeSelectedVideoRow(atIndexPath: indexPath)
            myLibraryListArray.remove(at: indexPath.row)
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
            if myLibraryListArray.count <= 4 {
                sectionButton.isHidden = true
            }
        }catch {
            print("Could not remove video \(error.localizedDescription)")
        }
    }
    
    
}
