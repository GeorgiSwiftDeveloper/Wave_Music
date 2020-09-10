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



class MyLibraryViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, WKNavigationDelegate, WKYTPlayerViewDelegate,CheckIfRowIsSelectedDelegate,CheckIfMusicRecordDeletedDelegate  {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var myLibraryTableView: UITableView!
    @IBOutlet weak var noTracksFoundView: UIView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    
    @IBOutlet weak var indicatorView: UIView!
    
    var selectedGenreIndexRow = Int()
    
    var myLibraryListArray = [Video]()
    var webView = WKYTPlayerView()
    var selectTopHitsRow = Bool()
    var selectLibraryRow = Bool()
    
    
    var youTubeVideoID = String()
    var youTubeVideoTitle = String()
    var checkTableViewName: String = ""
    var sectionButton = UIButton()
    var videoSelected = Bool()
    var viewAllButton = UIButton()
    var videoPlayerClass = VideoPlayer()
    var checkIfRecentPlaylistIsEmpty = Bool()
    var selectedGenreRowTitleHolder = String()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        self.view.accessibilityIdentifier = "MyLibrary"
        
        setupSearchNavBar()
        
        self.myLibraryTableView.delegate = self
        self.myLibraryTableView.dataSource = self
        
        
        self.genreCollectionView.delegate = self
        self.genreCollectionView.dataSource = self
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
        
        fetchVideoData()
        
        checkIfNoTracksFound()
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
            } else  {
                
                self?.updatePlayerState(playerState)
            }
        })
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
        CoreDataVideoClass.coreDataVideoInstance.fetchVideoWithEntityName(coreDataEntityName: entityName, searchBarText: "", playlistName: "") { [weak self](videoList, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                if videoList != nil {
                    switch entityName {
                    case myLibraryEntityName:
                        
                        self?.myLibraryListArray.append(contentsOf: videoList!)
                        let libraryCount: Bool = (self?.myLibraryListArray.count)! <= 5 ? true : false
                        
                        self?.viewAllButton.isHidden = libraryCount
                        
                        DispatchQueue.main.async {
                            self?.myLibraryTableView.reloadData()
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
        VideoPlayer.callVideoPlayer.webView.playVideo()
    }
    func showVideoPlayerPause(){
        VideoPlayer.callVideoPlayer.webView.pauseVideo()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    
    
    
    func musicRecordDeletedDelegate(_ alertTitleName: String) {
        if alertTitleName == "My Library" {
            myLibraryListArray = []
            DispatchQueue.main.async {
                self.myLibraryTableView.reloadData()
            }
        }
    }
    
    func checkIfRowIsSelected(_ checkIf: Bool) {
        if checkIf == true{
            self.selectLibraryRow = true
            self.selectTopHitsRow = true
            DispatchQueue.main.async {
                self.myLibraryTableView.reloadData()
            }
        }
    }
    
    
    func setupSearchNavBar() {
        SearchController.sharedSearchControllerInstace.searchController(searchController, superViewController: self, navigationItem: self.navigationItem, searchPlaceholder: SearchPlaceholder.librarySearch)
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
            DispatchQueue.main.async {
                self.myLibraryTableView.reloadData()
            }
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
                self.myLibraryListArray.append(contentsOf: videoList!)
                DispatchQueue.main.async {
                    self.myLibraryTableView.reloadData()
                }
            }
        }
    }
    
}

extension MyLibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titleName =  "My Library"
        return titleName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myLibraryListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  libraryMusicCell = (tableView.dequeueReusableCell(withIdentifier: myLibraryTableViewCellIdentifier, for: indexPath) as? MainLibrariMusciTableViewCell)!
        
            libraryMusicCell.configureMyLibraryCell(self.myLibraryListArray[indexPath.row])
            
        return libraryMusicCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        view.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana-Bold", size: 18)!
        header.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let myLibraryCount: Bool = myLibraryListArray.count >= 3 ? true : false
        if  myLibraryCount == true{
            viewAllButton.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 10, width: 100, height: 40)
            viewAllButton.tag = section
            viewAllButton.setTitle("View all", for: .normal)
            viewAllButton.titleLabel?.font =  UIFont(name: "Verdana-Bold", size: 9)
            viewAllButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            header.addSubview(viewAllButton)
            sectionButton = viewAllButton
            viewAllButton.addTarget(self, action: #selector(destinationMyLibraryVC), for: .touchUpInside)
        }
    }
    
    @objc func destinationMyLibraryVC(){
        self.performSegue(withIdentifier: destinationToMyLibraryIdentifier, sender: SelectedTableView.libraryTableView.rawValue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  let nc = segue.destination as? SelectedSectionViewController {
            switch sender as? String {
            case SelectedTableView.libraryTableView.rawValue:
                nc.navigationItem.title = "My Library"
                
                let selectedSearch = UserDefaults.standard.object(forKey: "selectedSearch") as? Bool
                
                if selectedSearch == true {
                    nc.searchIsSelected = true
                }
                nc.checkTableViewName = sender as! String
                nc.ifRowIsSelectedDelegate = self
                nc.musicRecordDeletedDelegate = self
            case SelectedTableView.genreCollectionView.rawValue:
                nc.navigationItem.title = selectedGenreRowTitleHolder
                let selectedSearch = UserDefaults.standard.object(forKey: "selectedSearch") as? Bool
                if selectedSearch == true {
                    nc.searchIsSelected = true
                }
                
                let selectedmyLybrary = UserDefaults.standard.object(forKey: "selectedmyLybrary") as? Bool
                if selectedmyLybrary == true {
                    nc.selectedmyLybrary = true
                }
                nc.checkTableViewName = sender as! String
                nc.selectedGenreTitle  = selectedGenreRowTitleHolder
            default:
                break
            }
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectLibraryRow = false
        
        let selectedCell = self.myLibraryTableView.cellForRow(at: indexPath) as! MainLibrariMusciTableViewCell
        
        getSelectedLibraryVideo(indexPath)
        
        VideoPlayer.callVideoPlayer.videoPalyerClass(genreVideoID: selectedCell.videoID, index: indexPath.row, superView: self, ifCellIsSelected: true, selectedVideoTitle: selectedCell.musicTitleLabel.text!)
        
        CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: selectedCell.musicTitleLabel.text!, videoImage: selectedCell.imageViewUrl, videoId: selectedCell.videoID, playlistName: "", coreDataEntityName: recentPlayedEntityName) { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else{
                self.fetchVideoData()
            }
        }
        
        
    }
    
    
    
    func getSelectedLibraryVideo(_ indexPath: IndexPath){
        VideoPlayer.callVideoPlayer.cardViewController.view = nil
        selectTopHitsRow = true
        VideoPlayer.callVideoPlayer.webView.pauseVideo()
        videoSelected = true
        VideoPlayer.callVideoPlayer.superViewController = self
        
        DispatchQueue.main.async {
            self.myLibraryTableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == MainLibrariMusciTableViewCell.EditingStyle.delete{
            removeSelectedVideoRow(atIndexPath: indexPath)
            myLibraryListArray.remove(at: indexPath.row)
            checkIfNoTracksFound()
            let libraryCount: Bool = (self.myLibraryListArray.count) <= 4 ? true : false
            sectionButton.isHidden = libraryCount
            
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


extension MyLibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  GenreModelService.instance.getGenreArray().count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCollectionCell", for: indexPath) as? GenresCollectionViewCell {
                cell.confiigurationGenreCell(GenreModelService.instance.getGenreArray()[indexPath.row])
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 0.5
                cell.layer.cornerRadius = 6
                cell.layer.backgroundColor = UIColor.white.cgColor

            return cell
        }else {
            return GenresCollectionViewCell()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGenreRowTitle = GenreModelService.instance.getGenreArray()[indexPath.row]
        selectedGenreIndexRow = indexPath.row
        selectedGenreRowTitleHolder = selectedGenreRowTitle.genreTitle
        let selectedGenereCollectionIndex = UserDefaults.standard.object(forKey: "selectedGenereCollectionIndex") as? Int
        if selectedGenereCollectionIndex == selectedGenreIndexRow {
            UserDefaults.standard.set(true, forKey:"checkGenreRowIsSelected")
        }else{
            UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
        }
        self.performSegue(withIdentifier: destinationToMyLibraryIdentifier, sender: SelectedTableView.genreCollectionView.rawValue)
    }
}
