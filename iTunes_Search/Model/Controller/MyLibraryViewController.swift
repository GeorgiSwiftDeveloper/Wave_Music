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

class MyLibraryViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, WKNavigationDelegate, WKYTPlayerViewDelegate,CheckIfRowIsSelectedDelegate,CheckIfMusicRecordDeletedDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var myLibraryTableView: UITableView!
    @IBOutlet weak var artistsCollectionCell: UICollectionView!
    @IBOutlet weak var noTracksFoundView: UIView!
    
    var myLibraryListArray = [Video]()
    var webView = WKYTPlayerView()
    var selectTopHitsRow = Bool()
    var selectLibraryRow = Bool()
    var musicIndexpatRow = IndexPath()
    var topHits = true
    var myLibrary = true
    var youTubeVideoID = String()
    var youTubeVideoTitle = String()
    var checkTableViewName: String = ""
    var sectionButton = UIButton()
    var selectedIndex = Int()
    var videoSelected = Bool()
    var viewAllButton = UIButton()
    var videoPlayerClass = VideoPlayerClass()
    var checkIfRecentPlaylistIsEmpty = Bool()
    
    var artImageArray  = ["justinB","justinT","eminem","beyonce1","swift"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        setupNavBar()
        
        myLibraryTableView.alwaysBounceVertical = false
        
        self.myLibraryTableView.delegate = self
        self.myLibraryTableView.dataSource = self
        
        self.artistsCollectionCell.delegate = self
        self.artistsCollectionCell.dataSource = self
        
        artistsCollectionCell.layer.cornerRadius = 8.0
        artistsCollectionCell.layer.borderWidth = 2.0
        artistsCollectionCell.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
        artistsCollectionCell.layer.shadowRadius = 2
        artistsCollectionCell.layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        artistsCollectionCell.layer.shadowOffset = .zero
        artistsCollectionCell.layer.masksToBounds = true
        //        load()
    }
    
    //    func load(){
    //    let headers = [
    //        "x-rapidapi-host": "artist-info.p.rapidapi.com",
    //        "x-rapidapi-key": "37deb905abmsh1a5f867387ce07dp1357a1jsn4be46426c675"
    //    ]
    //
    //    let request = NSMutableURLRequest(url: NSURL(string: "https://artist-info.p.rapidapi.com/getArtistInfo?=Justin")! as URL,
    //                                            cachePolicy: .useProtocolCachePolicy,
    //                                        timeoutInterval: 10.0)
    //        request.httpMethod = "GET"
    //        request.allHTTPHeaderFields = headers
    //
    //        let session = URLSession.shared
    //        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
    //            if (error != nil) {
    //                print(error)
    //            } else {
    //                let httpResponse = response as? HTTPURLResponse
    //                if let data = data {
    //
    //                    do {
    //                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    //                        //                        let results = (json as! NSDictionary).object(forKey: "album") as? [Dictionary<String,AnyObject>]
    //                        //                        print(results?[0]["title"])
    //                        print(json)
    //                    } catch {
    //                        print(error)
    //                    }
    //                }
    //            }
    //        })
    //
    //        dataTask.resume()
    //
    
    //    }
    
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
        
        fetchVideoData()
        
        checkIfNoTracksFound()
    }
    
    func checkIfNoTracksFound () {
        if self.myLibraryListArray.count == 0  {
            self.noTracksFoundView.isHidden = false
        }else{
            self.noTracksFoundView.isHidden = true
        }
    }
    
    
    func fetchVideoData() {
        self.myLibraryListArray = []
        fetchVideoWithEntityName(myLibraryEntityName)
    }
    
    
    func fetchVideoWithEntityName(_ entityName: String){
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: entityName, searchBarText: "", playlistName: "") { (videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if videoList != nil {
                    switch entityName {
                    case myLibraryEntityName:
                        self.myLibraryListArray.append(videoList!)
                        if self.myLibraryListArray.count < 5 {
                            self.viewAllButton.isHidden = true
                        }else{
                            self.viewAllButton.isHidden = false
                        }
                        DispatchQueue.main.async {
                            self.myLibraryTableView.reloadData()
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
    
    
    func musicRecordDeletedDelegate(_ alertTitleName: String) {
        if alertTitleName == "My Library" {
            myLibraryListArray = []
            myLibraryTableView.reloadData()
        }else if alertTitleName == "RECENTLY PLAYED"{
            checkIfRecentPlaylistIsEmpty = true
//            recentPlayedCollectionCell.reloadData()
        }
    }
    
    
    func setupNavBar() {
        searchController.searchBar.placeholder = "Search Library"
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
        print("Search end editing")
        if searchBar.searchTextField.text?.isEmpty == true{
            self.myLibraryListArray = []
            fetchVideoWithEntityName(myLibraryEntityName)
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
            fetchVideoWithEntityName(myLibraryEntityName)
        }
    }
    
    func fetchSearchSong(_ searchBar: UISearchBar, searchText: String) {
        
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: myLibraryEntityName, searchBarText: searchBar.text!, playlistName: "") { (videoList, error) in
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
        return artImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let artCell = collectionView.dequeueReusableCell(withReuseIdentifier: "artists", for: indexPath) as! ArtistsCollectionViewCell
            artCell.configureArtistCell(artImageArray[indexPath.row])
            print(artImageArray[indexPath.row])
        return artCell
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
        
        return myLibraryListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  libraryMusicCell = (tableView.dequeueReusableCell(withIdentifier: "LibraryMusicCell", for: indexPath) as? MainLibrariMusciTableViewCell)!
        
        DispatchQueue.main.async {
            libraryMusicCell.configureGenreCell(self.myLibraryListArray[indexPath.row])
            
        }
        return libraryMusicCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var rowHeiight = 0
        rowHeiight = 55
        
        return CGFloat(rowHeiight)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        view.tintColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana-Bold", size: 18)!
        header.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if myLibraryListArray.count >= 4{
            viewAllButton.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 10, width: 100, height: 40)
            viewAllButton.tag = section
            viewAllButton.setTitle("View all", for: .normal)
            viewAllButton.titleLabel?.font =  UIFont(name: "Verdana-Bold", size: 10)
            viewAllButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            header.addSubview(viewAllButton)
            sectionButton = viewAllButton
            viewAllButton.addTarget(self, action: #selector(destinationMyLibraryVC), for: .touchUpInside)
        }
    }
    
    @objc func destinationMyLibraryVC(){
        checkTableViewName =  libraryTableView
        self.performSegue(withIdentifier: destinationToMyLibraryIdentifier, sender: checkTableViewName)
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
                nc.musicRecordDeletedDelegate = self
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
                nc.musicRecordDeletedDelegate = self
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
        
        //        for i in 0..<self.myLibraryListArray.count{
        //            self.youTubeVideoID.append(self.myLibraryListArray[i].videoId ?? "")
        //            self.youTubeVideoTitle.append(self.myLibraryListArray[i].videoTitle ?? "")
        //        }
        
        self.youTubeVideoID = selectedCell.videoID
        self.youTubeVideoTitle = selectedCell.musicTitleLabel.text!
        
        getSelectedLibraryVideo(indexPath)
        
        VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
        
        CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.musicTitleLabel.text!, videoImage: selectedCell.imageViewUrl, videoId: selectedCell.videoID, playlistName: "", coreDataEntityName: recentPlayedEntityName) { (checkIfLoadIsSuccessful, error, checkIfSongAlreadyInDatabase) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else{
                self.fetchVideoData()
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
            checkIfNoTracksFound()
            if myLibraryListArray.count <= 4 {
                sectionButton.isHidden = true
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    func removeSelectedVideoRow(atIndexPath indexPath: IndexPath) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myLibraryEntityName)
        let result = try? context?.fetch(request)
        let resultData = result as! [NSManagedObject]
        context?.delete(resultData[indexPath.row])
        do{
            try context?.save()
        }catch {
            print("Could not remove video from Database \(error.localizedDescription)")
        }
    }
}
