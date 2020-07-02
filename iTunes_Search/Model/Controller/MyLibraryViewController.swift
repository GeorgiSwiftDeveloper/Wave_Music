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
import AVFoundation
class MyLibraryViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, WKNavigationDelegate, WKYTPlayerViewDelegate,CheckIfRowIsSelectedDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var myLibraryTableView: UITableView!
    @IBOutlet weak var topHitsCollectionCell: UICollectionView!
    @IBOutlet weak var recentPlayedCollectionCell: UICollectionView!
    
    var myLibraryListArray = [Video]()
    var topHitsArray = [Video]()
    var recentPlayedVideo = [Video]()
    var webView = WKYTPlayerView()
    var selectTopHitsRow = Bool()
    var selectLibraryRow = Bool()
    var musicIndexpatRow = IndexPath()
    var topHits = true
    var myLibrary = true
    var youTubeVideoID = [String]()
    var youTubeVideoTitle = [String]()
    var checkTableViewName: String = ""
    var sectionButton = UIButton()
    var selectedIndex = Int()
    var videoSelected = Bool()
    var viewAllButton = UIButton()
    var videoPlayerClass = VideoPlayerClass()
    
    var recentPlayerArray = [Data]()
    
    var isEntityIsEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        setupNavBar()
        
        myLibraryTableView.alwaysBounceVertical = false
        
        self.myLibraryTableView.delegate = self
        self.myLibraryTableView.dataSource = self
        
        self.topHitsCollectionCell.delegate = self
        self.topHitsCollectionCell.dataSource = self
        
        self.recentPlayedCollectionCell.delegate = self
        self.recentPlayedCollectionCell.dataSource = self
        getYouTubeResults()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        switch event?.subtype {
        case .remoteControlTogglePlayPause:
            VideoPlayerClass.callVideoPlayer.webView.playVideo()
        case .remoteControlPlay:
            
            VideoPlayerClass.callVideoPlayer.webView.playVideo()
        case .remoteControlPause:
            VideoPlayerClass.callVideoPlayer.webView.playVideo()
        default:
            break;
        }
    }
    
    func checkIfRowIsSelected(_ checkIf: Bool) {
        if checkIf == true{
            DispatchQueue.main.async {
                self.selectLibraryRow = true
                self.selectTopHitsRow = true
                self.myLibraryTableView.reloadData()
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierSearchRowSelected(notification:)), name: Notification.Name("NotificationIdentifierSearchRowSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierGenreRowSelected(notification:)), name: Notification.Name("NotificationIdentifierGenreRowSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierRecentPlayedDeleteRecords(notification:)), name: Notification.Name("NotificationIdentifierRecentPlayedDeleteRecords"), object: nil)
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
        
        
        self.myLibraryListArray = []
        self.recentPlayedVideo = []
        fetchVideoWithEntityName("MyLibraryMusicData")
        fetchVideoWithEntityName("RecentPlayedMusicData")
        
        recentPlayerVideoImage(videoCount: recentPlayedVideo.count) { (imageDataArray) in
            self.recentPlayerArray = imageDataArray
            self.recentPlayedCollectionCell.reloadData()
            print(self.recentPlayerArray.count)
        }
    }
    
    func fetchVideoData() {
        self.myLibraryListArray = []
        self.recentPlayedVideo = []
        fetchVideoWithEntityName("MyLibraryMusicData")
        fetchVideoWithEntityName("RecentPlayedMusicData")
        
        recentPlayerVideoImage(videoCount: recentPlayedVideo.count) { (imageDataArray) in
            self.recentPlayerArray = imageDataArray
            self.recentPlayedCollectionCell.reloadData()
            print(self.recentPlayerArray.count)
        }
    }
    
    func getYouTubeResults(){
        if isEntityIsEmpty{
            YouTubeVideoConnection.getYouTubeVideoInstace.getYouTubeVideo(genreType: "Hits", selectedViewController: "MyLibraryViewController") { (loadVideolist, error) in
                if error != nil  {
                    print("erorr")
                }else{
                    DispatchQueue.main.async{
                        self.topHitsArray = loadVideolist!
                        for songIndex in 0..<self.topHitsArray.count{
                            let title =   self.topHitsArray[songIndex].videoTitle ?? ""
                            let description =  self.topHitsArray[songIndex].videoDescription ?? ""
                            let image =  self.topHitsArray[songIndex].videoImageUrl ?? ""
                            let playlistId = self.topHitsArray[songIndex].videoPlaylistId ?? ""
                            let videoId =  self.topHitsArray[songIndex].videoId ?? ""
                            let channelId =  self.topHitsArray[songIndex].channelId ?? ""
                            
                            self.saveItems(title: title, description: description, image: image, videoId: videoId, playlistId: playlistId,genreTitle: "Hits", channelId: channelId)
                            self.topHitsCollectionCell.reloadData()
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
                        DispatchQueue.main.async {
                            self.topHitsCollectionCell.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    
    
    func fetchVideoWithEntityName(_ entityName: String){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: entityName, searchBarText: "") { (videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if videoList != nil {
                    switch entityName {
                    case "MyLibraryMusicData":
                        self.myLibraryListArray.append(videoList!)
                        if self.myLibraryListArray.count < 5 {
                            self.viewAllButton.isHidden = true
                        }else{
                            self.viewAllButton.isHidden = false
                        }
                        DispatchQueue.main.async {
                            self.myLibraryTableView.reloadData()
                        }
                    case "RecentPlayedMusicData":
                        self.recentPlayedVideo.append(videoList!)
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
    }
    func showVideoPlayerPause(){
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    
    
    @objc func NotificationIdentifierSearchRowSelected(notification: Notification) {
        checkIfMyLibraryViewControllerRowIsSelected()
    }
    
    @objc func NotificationIdentifierGenreRowSelected(notification: Notification) {
        
        checkIfMyLibraryViewControllerRowIsSelected()
    }
    
    func  checkIfMyLibraryViewControllerRowIsSelected() {
        UserDefaults.standard.set(false, forKey:"checkIfMyLibraryViewControllerRowIsSelected")
        myLibraryTableView.reloadData()
    }
    
    
    @objc func NotificationIdentifierRecentPlayedDeleteRecords(notification: Notification) {
        recentPlayedVideo = []
        fetchVideoWithEntityName("RecentPlayedMusicData")
        recentPlayedCollectionCell.reloadData()
    }
    
    func fetchFromCoreData(loadVideoList: @escaping(_ returnVideoList: Video?, _ returnError: Error? ) -> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as? String ?? ""
                let image = data.value(forKey: "image") as? String ?? ""
                let videoId = data.value(forKey: "videoId") as? String ?? ""
                let songDescription = data.value(forKey: "songDescription") as? String ?? ""
                let playlistId = data.value(forKey: "playListId") as? String ?? ""
                let channelId = data.value(forKey: "channelId") as? String ?? ""
                let fetchedVideoList = Video(videoId: videoId, videoTitle: title, videoDescription: songDescription, videoPlaylistId: playlistId, videoImageUrl: image, channelId:channelId, genreTitle: "")
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
        if searchBar.searchTextField.text?.isEmpty == true{
            self.myLibraryListArray = []
            fetchVideoWithEntityName("MyLibraryMusicData")
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == false{
            fetchSearchSong(searchBar, searchText: searchText)
                     self.myLibraryTableView.reloadData()
        }
        else{
            self.myLibraryListArray = []
            fetchVideoWithEntityName("MyLibraryMusicData")
        }
    }
    
    
    func fetchSearchSong(_ searchBar: UISearchBar, searchText: String) {
        
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: "MyLibraryMusicData", searchBarText: searchBar.text!) { (videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else {
                self.myLibraryListArray = []
                self.myLibraryListArray.append(videoList!)
                
                self.myLibraryTableView.reloadData()
            }
        }
    }
    
    
    
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
                cell.imageView1.image = UIImage(named: "")
                cell.imageView2.image = UIImage(named: "")
                cell.imageView3.image = UIImage(named: "")
                cell.imageView4.image = UIImage(named: "")
            }
            collectionCell = cell
        case recentPlayedCollectionCell:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentCell", for: indexPath) as! RecentPlayedCollectionViewCell
            
            cell.cellTitleLabel.text = "RECENTLY PLAYED"
            cell.recentlyPlayedVideoCountLabel.text = "\(recentPlayedVideo.count) tracks"
            
            if recentPlayerArray.count != 0 {
                switch recentPlayerArray.count {
                case 1:
                    cell.imageView1.image =  UIImage(data: recentPlayerArray[0] as Data)
                case 2:
                    cell.imageView1.image =  UIImage(data: recentPlayerArray[0] as Data)
                    cell.imageView2.image =  UIImage(data: recentPlayerArray[1] as Data)
                case 3:
                    cell.imageView1.image =  UIImage(data: recentPlayerArray[0] as Data)
                    cell.imageView2.image =  UIImage(data: recentPlayerArray[1] as Data)
                    cell.imageView3.image =  UIImage(data: recentPlayerArray[2] as Data)
                case 4:
                    cell.imageView1.image =  UIImage(data: recentPlayerArray[0] as Data)
                    cell.imageView2.image =  UIImage(data: recentPlayerArray[1] as Data)
                    cell.imageView3.image =  UIImage(data: recentPlayerArray[2] as Data)
                    cell.imageView4.image =  UIImage(data: recentPlayerArray[3] as Data)
                    
                default:
                    cell.imageView1.image =  UIImage(data: recentPlayerArray[0] as Data)
                    cell.imageView2.image =  UIImage(data: recentPlayerArray[1] as Data)
                    cell.imageView3.image =  UIImage(data: recentPlayerArray[2] as Data)
                    cell.imageView4.image =  UIImage(data: recentPlayerArray[3] as Data)
                }
            }else{
                recentPlayedVideo = []
            }
            
            
            
            collectionCell = cell
            
        default:
            break
        }
        return collectionCell
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case topHitsCollectionCell:
            checkTableViewName =  topHitsTableView
            self.performSegue(withIdentifier: destinationViewIdentifier, sender: checkTableViewName)
        case recentPlayedCollectionCell:
            checkTableViewName =  recentPlayedTableView
            self.performSegue(withIdentifier: destinationViewIdentifier, sender: checkTableViewName)
        default:
            break
        }
    }
    
    
}

extension MyLibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleName = ""
        titleName = "My Library"
        return titleName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 1
        numberOfRowsInSection = myLibraryListArray.count
        return numberOfRowsInSection
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  libraryMusicCell = (tableView.dequeueReusableCell(withIdentifier: "LibraryMusicCell", for: indexPath) as? MainLibrariMusciTableViewCell)!
        //        let checkIfMyLibraryViewControllerRowIsSelected = UserDefaults.standard.object(forKey: "checkIfMyLibraryViewControllerRowIsSelected") as? Bool
        //        musicIndexpatRow = indexPath
        //        DispatchQueue.main.async {
        //            if checkIfMyLibraryViewControllerRowIsSelected == true{
        //                if(indexPath.row == self.selectedIndex)
        //                {
        //                    if self.selectLibraryRow == false{
        //                        libraryMusicCell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
        //                        libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        //                    }else{
        //                        libraryMusicCell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //                        libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
        //                    }
        //                }
        //                else
        //                {
        //                    libraryMusicCell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //                    libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
        //                }
        //            }else{
        //                libraryMusicCell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //                libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
        //            }
        //        }
        
        libraryMusicCell.configureGenreCell(myLibraryListArray[indexPath.row])
        return libraryMusicCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var rowHeiight = 0
        rowHeiight = 55
        
        return CGFloat(rowHeiight)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana-Bold", size: 20)!
        header.textLabel?.textColor = #colorLiteral(red: 0.06852825731, green: 0.05823112279, blue: 0.1604561806, alpha: 0.8180118865)
        if myLibraryListArray.count >= 4{
            viewAllButton.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 10, width: 100, height: 40)
            viewAllButton.tag = section
            viewAllButton.setTitle("View all", for: .normal)
            viewAllButton.titleLabel?.font =  UIFont(name: "Verdana", size: 14)
            viewAllButton.setTitleColor(#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), for: .normal)
            header.addSubview(viewAllButton)
            sectionButton = viewAllButton
            viewAllButton.addTarget(self, action: #selector(destinationMyLibraryVC), for: .touchUpInside)
        }
    }
    
    @objc func destinationMyLibraryVC(){
        checkTableViewName =  libraryTableView
        self.performSegue(withIdentifier: destinationViewIdentifier, sender: checkTableViewName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender as? String {
        case topHitsTableView:
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
        case libraryTableView:
            if  let nc = segue.destination as? SelectedSectionViewController {
                nc.navigationItem.title = "My Library"
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
            }
            
        case recentPlayedTableView:
            
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
            }
        default:
            break
        }
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierMyLibraryRowSelected"), object: nil)
        UserDefaults.standard.set(false, forKey:"selectedSearch")
        UserDefaults.standard.set(true, forKey:"selectedmyLybrary")
        
        self.selectLibraryRow = false
        
        let selectedCell = self.myLibraryTableView.cellForRow(at: indexPath) as! MainLibrariMusciTableViewCell
        
        self.webView.load(withVideoId: "")
        
        for i in 0..<self.myLibraryListArray.count{
            self.youTubeVideoID.append(self.myLibraryListArray[i].videoId ?? "")
            self.youTubeVideoTitle.append(self.myLibraryListArray[i].videoTitle ?? "")
        }
        getSelectedLibraryVideo(indexPath)
        
        VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
        
        CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.musicTitleLabel.text!, videoImage: selectedCell.imageViewUrl, videoId: selectedCell.videoID, coreDataEntityName: "RecentPlayedMusicData") { (checkIfLoadIsSuccessful, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if checkIfLoadIsSuccessful == true {
                    self.recentPlayedVideo = []
                    self.fetchVideoWithEntityName("RecentPlayedMusicData")
                    self.recentPlayedCollectionCell.reloadData()
                }
            }
        }
        
        
    }
    
    
    
    func getSelectedLibraryVideo(_ indexPath: IndexPath){
        UserDefaults.standard.set(true, forKey:"checkIfMyLibraryViewControllerRowIsSelected")
        UserDefaults.standard.set(true, forKey:"checkIfAnotherViewControllerRowIsSelected")
        selectedIndex = indexPath.row
        selectTopHitsRow = true
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
        videoSelected = true
        VideoPlayerClass.callVideoPlayer.superViewController = self
        myLibraryTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
