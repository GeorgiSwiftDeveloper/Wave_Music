//
//  ViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import  YoutubePlayer_in_WKWebView

let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

class SearchMusicViewController: UIViewController,UISearchControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating {
    
    @IBOutlet weak var searchMusicTableView: UITableView!
    @IBOutlet weak var hintView: UIView!
    
    var searchConnectionManager = SearchConnection()
    var searchMusicList = [Video]()
    var selectedMusic = [SelectedAlbumModel]()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    var checkIfEmptySearchText = Bool()
    
    var selectedIndex = Int()
    var webView = WKYTPlayerView()
    var youTubeVideoID = [String]()
    var youTubeVideoTitle =  [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchConnectionManager.delegate = self
        self.searchMusicTableView.delegate = self
        self.searchMusicTableView.dataSource = self
        setupNavBar()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierMyLibraryRowSelected(notification:)), name: Notification.Name("NotificationIdentifierMyLibraryRowSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierSelectionLibraryRowSelected(notification:)), name: Notification.Name("NotificationIdentifierSelectionLibraryRowSelected"), object: nil)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)  
    }
    
    @objc func NotificationIdentifierMyLibraryRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkIfSearchRowIsSelected")
        searchMusicTableView.reloadData()
        
    }
    
    @objc func NotificationIdentifierSelectionLibraryRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkIfSearchRowIsSelected")
        searchMusicTableView.reloadData()
    }
    
    @objc func NotificationIdentifierGenreRowSelected(notification: Notification) {
        UserDefaults.standard.set(false, forKey:"checkIfSearchRowIsSelected")
        searchMusicTableView.reloadData()
        
    }
    
    
    func setupNavBar() {
        searchController.obscuresBackgroundDuringPresentation  = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.isHidden = false
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("search end editing.")
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search end editing.")
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update search results ... called here")
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            let songName = searchBar.text
            searchConnectionManager.fetchYouTubeData(name: songName!)
            searchBar.text = ""
            searchController.isActive = false
        }
    }
}

extension SearchMusicViewController: AlbumManagerDelegate {
    func didUpdateAlbum(_ albumManager: SearchConnection, album: [Video]) {
        
        if  album.count != 0 {
            DispatchQueue.main.async {
                self.hintView.isHidden = true
                self.searchMusicTableView.isHidden = false
                self.searchMusicList = album
                     DispatchQueue.main.async {
                self.searchMusicTableView.reloadData()
                }
                
            }
        }
    }
    
    func didFailWithError(error: String) {
        print("\(error)")
    }
}

extension SearchMusicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMusicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchMusicCell", for: indexPath) as? SearchVideoTableViewCell {
//            let checkIfSearchRowIsSelected = UserDefaults.standard.object(forKey: "checkIfSearchRowIsSelected") as? Bool
//            DispatchQueue.main.async {
//                if checkIfSearchRowIsSelected == true{
//                    if(indexPath.row == self.selectedIndex)
//                    {
//                        cell.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 0.9465586656)
//                        cell.singerNameLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//                    }else{
//                        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                        cell.singerNameLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                    }
//                }else{
//                    cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                    cell.singerNameLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.0395433642, blue: 0.1333333333, alpha: 1)
//                }
//            }
            cell.configurationCell(albums: searchMusicList[indexPath.row])
            cell.favoriteButton.addTarget(self, action: #selector(addToFavoriteTapped), for: .touchUpInside)
            cell.favoriteButton.tag = indexPath.row;
            
            return cell
        }else {
            return SearchVideoTableViewCell()
        }
        
    }
    
    
    @objc func addToFavoriteTapped(sender: UIButton){
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        self.searchMusicTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        let selectedCell = self.searchMusicTableView.cellForRow(at: selectedIndex) as! SearchVideoTableViewCell
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLibraryMusicData")
        let predicate = NSPredicate(format: "title == %@", selectedCell.singerNameLabel.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        let alert = UIAlertController(title: "\(selectedCell.singerNameLabel.text ?? "")", message: "", preferredStyle: .actionSheet)
        let addMyLibraryAction = UIAlertAction(title: "Add to MyLibrary", style: .default) { (action) in
            do{
                let count = try context?.count(for: request)
                if(count == 0){
                    let entity = NSEntityDescription.entity(forEntityName: "MyLibraryMusicData", in: context!)
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(selectedCell.singerNameLabel.text, forKey: "title")
                    newEntity.setValue(selectedCell.videoImageUrl, forKey: "image")
                    newEntity.setValue(selectedCell.videoID, forKey: "videoId")
                    try context?.save()
                    print("data has been saved ")
                    let selectedImageViewUrl = selectedCell.videoImageUrl
                    AlertView.instance.showAlert(title: "\(selectedCell.singerNameLabel.text ?? "")", message: "Successfuly added to MyLibrary list", alertType: .success, videoImage: selectedImageViewUrl)
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(true, forKey:"checkIfSearchRowIsSelected")
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierSearchRowSelected"), object: nil)
        UserDefaults.standard.set(true, forKey:"selectedSearch")
        UserDefaults.standard.set(false, forKey:"selectedmyLybrary")
        let selectedIndexRow = tableView.indexPathForSelectedRow
        let selectedCell = self.searchMusicTableView.cellForRow(at: selectedIndexRow!) as! SearchVideoTableViewCell
        selectedIndex = indexPath.row
        webView.load(withVideoId: "")
        VideoPlayerClass.callVideoPlayer.superViewController = self
        for i in 0..<searchMusicList.count{
            self.youTubeVideoID.append(searchMusicList[i].videoId ?? "")
            self.youTubeVideoTitle.append(searchMusicList[i].videoTitle ?? "")
        }
        VideoPlayerClass.callVideoPlayer.videoPalyerClass(sellectedCell: selectedCell, genreVideoID: self.youTubeVideoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: self.youTubeVideoTitle)
        
        CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.singerNameLabel.text!, videoImage: selectedCell.videoImageUrl, videoId: selectedCell.videoID, coreDataEntityName: "RecentPlayedMusicData") { (checkIfLoadIsSuccessful, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        searchMusicTableView.reloadData()
    }
}
