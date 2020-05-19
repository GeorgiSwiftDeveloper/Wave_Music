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
class MyLibraryViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, WKNavigationDelegate, WKYTPlayerViewDelegate,CheckIfRowIsSelectedDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var myLibraryTableView: UITableView!
    @IBOutlet weak var myLibraryNSBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var topHitsCollectionCell: UICollectionView!
    @IBOutlet weak var recentPlayedCollectionCell: UICollectionView!
    
    var myLibraryListArray = [Video]()
    var topHitsArray = [Video]()
    var getYouTubeData  = YouTubeVideoConnection()
    var webView = WKYTPlayerView()
    var selectTopHitsRow = Bool()
    var selectLibraryRow = Bool()
    var musicIndexpatRow = IndexPath()
    var topHits = true
    var myLibrary = true
    var genreVideoID: String?
    var sectionButton = UIButton()
    var selectedIndex = Int()
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
        UserDefaults.standard.removeObject(forKey: "checkIfMyLibraryViewControllerRowIsSelected")
        //        UserDefaults.standard.removeObject(forKey: "saveTopHitsSelectedIndex")
        UserDefaults.standard.removeObject(forKey: "saveLibrarySelectedIndex")
        UserDefaults.standard.removeObject(forKey: "saveGenreSelectedIndex")
        UserDefaults.standard.removeObject(forKey: "checkIfSearchRowIsSelected")
        UserDefaults.standard.removeObject(forKey: "checkGenreRowIsSelected")
        UserDefaults.standard.removeObject(forKey: "selectedSearch")
        UserDefaults.standard.removeObject(forKey: "pause")
        UserDefaults.standard.synchronize()
        
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
    
    func checkIfRowIsSelectedDelegate(_ checkIf: Bool) {
        if checkIf == true{
            DispatchQueue.main.async {
                self.selectLibraryRow = true
                self.selectTopHitsRow = true
                self.myLibraryTableView.reloadData()
            }
        }
    }
    
    func getYouTubeResults(){
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
                        self.topHitsCollectionCell.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierSearchRowSelected(notification:)), name: Notification.Name("NotificationIdentifierSearchRowSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierGenreRowSelected(notification:)), name: Notification.Name("NotificationIdentifierGenreRowSelected"), object: nil)
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
        self.fetchMyLibraryList()
        self.myLibraryTableView.reloadData()
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
        UserDefaults.standard.set(false, forKey:"checkIfMyLibraryViewControllerRowIsSelected")
        myLibraryTableView.reloadData()
    }
    
    @objc func NotificationIdentifierGenreRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkIfMyLibraryViewControllerRowIsSelected")
        myLibraryTableView.reloadData()
        
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
        if searchBar.searchTextField.text?.isEmpty == true{
            myLibraryListArray = []
            fetchMyLibraryList()
            myLibraryTableView.reloadData()
        }
        
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
            //            let count = try context?.count(for: request)
            //            if(count == 0){
            //                // no matching object
            //                print("no match")
            //            }else{
            let fetchResult = try context?.fetch(request) as! [NSManagedObject]
            //            print(fetchResult.count)
            for result in fetchResult {
                let videoId = result.value(forKey: "videoId") as? String ?? ""
                let title = result.value(forKey: "title") as? String ?? ""
                let songDescription = result.value(forKey: "songDescription") as? String ?? ""
                let playListId = result.value(forKey: "playListId") as? String ?? ""
                let image = result.value(forKey: "image") as? String ?? ""
                let genreTitle = result.value(forKey: "genreTitle") as? String ?? ""
                let videoList = Video(videoId: videoId, videoTitle: title , videoDescription: songDescription , videoPlaylistId: playListId, videoImageUrl: image , channelId:"", genreTitle: genreTitle)
                myLibraryListArray = []
                myLibraryListArray.append(videoList)
                
                myLibraryTableView.reloadData()
            }
            print("match")
        }
            // }
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
                myLibraryTableView.reloadData()
            }
            
        } catch {
            print("Failed")
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
            cell.collectionImageView.layer.cornerRadius = 7.0
            cell.collectionImageView.layer.borderWidth = 1.0
            cell.collectionImageView.layer.shadowRadius = 3
            cell.collectionImageView.layer.shadowOffset = .zero
            cell.collectionImageView.layer.borderWidth = 4
            cell.collectionImageView.layer.masksToBounds = false
            cell.collectionImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            cell.collectionImageView.layer.shadowOpacity = 2
            cell.collectionImageView.layer.masksToBounds = true
            cell.cellTitleLabel.text = "TOP HIT'S"
            let imageUrl1 = URL(string: topHitsArray[0].videoImageUrl)
            let imageUrl2 = URL(string: topHitsArray[1].videoImageUrl)
            let imageUrl3 = URL(string: topHitsArray[2].videoImageUrl)
            let imageUrl4 = URL(string: topHitsArray[3].videoImageUrl)
            
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
            collectionCell = cell
        case recentPlayedCollectionCell:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentCell", for: indexPath) as! RecentPlayedCollectionViewCell
            cell.collectionImageView.layer.cornerRadius = 7.0
            cell.collectionImageView.layer.borderWidth = 1.0
            cell.collectionImageView.layer.shadowColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.collectionImageView.layer.shadowRadius = 3
            cell.collectionImageView.layer.shadowOffset = .zero
            cell.collectionImageView.layer.borderWidth = 4
            cell.collectionImageView.layer.masksToBounds = false
            cell.collectionImageView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            cell.collectionImageView.layer.shadowOpacity = 2
            cell.collectionImageView.layer.masksToBounds = true
            cell.cellTitleLabel.text = "RECENTLY PLAYED"
            let imageUrl1 = URL(string: topHitsArray[0].videoImageUrl)
            let imageUrl2 = URL(string: topHitsArray[1].videoImageUrl)
            let imageUrl3 = URL(string: topHitsArray[2].videoImageUrl)
            let imageUrl4 = URL(string: topHitsArray[3].videoImageUrl)
            
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
            collectionCell = cell
            
        default:
            break
        }
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case topHitsCollectionCell:
            destinationTopHitsMusicVC()
        default:
            break
        }
//        self.performSegue(withIdentifier: "TopHitsMusic", sender: nil)
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
        let checkIfMyLibraryViewControllerRowIsSelected = UserDefaults.standard.object(forKey: "checkIfMyLibraryViewControllerRowIsSelected") as? Bool
        musicIndexpatRow = indexPath
        DispatchQueue.main.async {
            if checkIfMyLibraryViewControllerRowIsSelected == true{
                if(indexPath.row == self.selectedIndex)
                {
                    if self.selectLibraryRow == false{
                        libraryMusicCell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
                        libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                    }else{
                        libraryMusicCell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
                    }
                }
                else
                {
                    libraryMusicCell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
                }
            }else{
                libraryMusicCell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                libraryMusicCell.musicTitleLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
            }
        }
        
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
    
    @objc func destinationMyLibraryVC(){
        self.performSegue(withIdentifier: "MyLibraryMusic", sender: nil)
    }
    
    
        func destinationTopHitsMusicVC(){
           self.performSegue(withIdentifier: "TopHitsMusic", sender: nil)
       }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TopHitsMusic" {
            if  let nc = segue.destination as? SelectedSectionViewController {
                nc.navigationItem.title = "Top Tracks"
                if videoSelected == true{
                    nc.videoSelected = true
                    nc.checDelegate = self
                }
                let selectedSearch = UserDefaults.standard.object(forKey: "selectedSearch") as? Bool
                if selectedSearch == true {
                    nc.searchIsSelected = true
                }
                UserDefaults.standard.set(false, forKey:"selectedSearch")
                nc.checkTable = false
                nc.checDelegate = self
            }
        }else
            if segue.identifier == "MyLibraryMusic" {
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
                nc.checkTable = true
                nc.checDelegate = self
            }
        }
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierMyLibraryRowSelected"), object: nil)
        UserDefaults.standard.set(false, forKey:"selectedSearch")
        UserDefaults.standard.set(true, forKey:"selectedmyLybrary")
        self.selectLibraryRow = false
        let selectedVideoId = self.myLibraryListArray[indexPath.row]
        let selectedCell = self.myLibraryTableView.cellForRow(at: indexPath) as! MainLibrariMusciTableViewCell
        self.genreVideoID = selectedVideoId.videoId
        getSelectedLibraryVideo(indexPath)
        self.webView.load(withVideoId: "")
        VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.genreVideoID!, superView: self, ifCellIsSelected: true, selectedVideo: selectedVideoId)
        
        
        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
//        let predicate = NSPredicate(format: "title == %@", selectedCell.musicTitleLabel.text! as CVarArg)
//        request.predicate = predicate
//        request.fetchLimit = 1
//        do{
//            let count = try context?.count(for: request)
//            if(count == 0){
//                // no matching object
//                let entity = NSEntityDescription.entity(forEntityName: "MyLibraryMusicData", in: context!)
//                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
//                newEntity.setValue(selectedCell.musicTitleLabel.text!, forKey: "title")
//                newEntity.setValue(selectedCell.imageViewUrl, forKey: "image")
//                newEntity.setValue(selectedCell.videoID, forKey: "videoId")
//                //                    myLibraryList = []
//                try context?.save()
//                print("data has been saved ")
//            }
//        }catch{
//            print("error")
//        }
        
    }
    
    
    
    func getSelectedLibraryVideo(_ indexPath: IndexPath){
        UserDefaults.standard.set(true, forKey:"checkIfMyLibraryViewControllerRowIsSelected")
        UserDefaults.standard.set(true, forKey:"checkIfAnotherViewControllerRowIsSelected")
        selectedIndex = indexPath.row
        selectTopHitsRow = true
        self.myLibraryNSBottomLayout.constant = 155
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
