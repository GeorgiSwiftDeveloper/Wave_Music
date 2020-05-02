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
    func updateSearchResults(for searchController: UISearchController) {
        print("F")
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var mainLibraryTableView: UITableView!
    @IBOutlet weak var topMusicTableView: UITableView!
    
    var myLibraryListArray = [MyLibraryMusicData]()
    var topHitsArray = [Video]()
    var getYouTubeData  = YouTubeVideoConnection()
    var webView = WKYTPlayerView()
    
    var topHits = true
    var myLibrary = true
    var genreVideoID: String?
    var sectionButton = UIButton()
    
    var playButton = UIButton()
    var musicLabelText = UILabel()
    var checkIfPaused = Bool()
    
    var isEntityIsEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    
    let cardHeight:CGFloat = 850
    
    let cardHandleAreaHeight:CGFloat = 190
    
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
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
        }
        
        mainLibraryTableView.reloadData()
    }
    
    func setupCard(sellectedCell: TopHitsTableViewCell) {
//        visualEffectView = UIVisualEffectView()
//        visualEffectView.frame = self.view.frame
//        self.view.addSubview(visualEffectView)
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        cardViewController.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.addChild(cardViewController)
        
        self.view.addSubview(cardViewController.view)
        
          cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
        self.webView = WKYTPlayerView(frame: CGRect(x: 0, y: 45, width: UIScreen.main.bounds.width, height: 220))
        self.cardViewController.view.addSubview(self.webView)
        let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                              "origin": "https://www.youtube.com"]
        self.webView.load(withVideoId: genreVideoID!, playerVars: playerVars)
        
        self.webView.delegate = self
        self.webView.isHidden = true
        
        self.musicLabelText.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.musicLabelText.numberOfLines = 0
        self.musicLabelText.textAlignment = .center
        self.cardViewController.view.addSubview(self.musicLabelText)

        
        
        self.playButton.addTarget(self, action: #selector(self.playAndPauseButtonAction(sender:)), for: .touchUpInside)
        self.cardViewController.view.addSubview(self.playButton)
        
        checkIfPaused = true
        if checkIfPaused == false {
                  webView.pauseVideo()
                   self.playButton.setImage(UIImage(named: "btn-play"), for: .normal)
                   
                  checkIfPaused = true
              }else{
                  webView.playVideo()
                  self.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
                  checkIfPaused = false
              }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyLibraryViewController.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MyLibraryViewController.handleCardPan(recognizer:)))
        
        cardViewController.headerView.addGestureRecognizer(tapGestureRecognizer)
        sellectedCell.addGestureRecognizer(panGestureRecognizer)
           
           
       }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        webView.playVideo();
    }
    
    
    
    

       @objc
       func handleCardTap(recognzier:UITapGestureRecognizer) {
           switch recognzier.state {
           case .ended:
               animateTransitionIfNeeded(state: nextState, duration: 0.9)
           default:
               break
           }
       }
    
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.cardViewController.headerView)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                    self.cardViewController.headerView.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
                    
                    self.playButton.frame = CGRect(x: self.cardViewController.view.center.x - 30, y: 400, width: 60, height: 60)
                    self.musicLabelText.frame = CGRect(x: 0, y: Int(self.cardViewController.view.center.y) - 180, width: Int(UIScreen.main.bounds.width), height: 50)
                    
                    
                    
                    self.musicLabelText.numberOfLines = 0
                    self.musicLabelText.textAlignment = .center
                    self.navigationController?.navigationBar.isHidden = true
                    self.webView.isHidden = false
               
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                      self.cardViewController.headerView.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
                    
                    self.playButton.frame = CGRect(x: self.cardViewController.view.frame.size.width - self.playButton.frame.size.width - 10, y: 48, width: 50, height: 50)
                    self.musicLabelText.frame = CGRect(x: 5, y: 50, width: Int(UIScreen.main.bounds.width - 70), height: 50)


                    self.musicLabelText.numberOfLines = 0
                    self.musicLabelText.textAlignment = .left
                    self.musicLabelText.font = UIFont(name: "Verdana", size: 12)
                    
                    self.webView.isHidden = true

                    self.navigationController?.navigationBar.isHidden = false
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    break
//                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    break
//                    self.visualEffectView.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
        }
    }
    
    
    @objc func playAndPauseButtonAction(sender: UIButton){
        if checkIfPaused == false {
            webView.pauseVideo()
             self.playButton.setImage(UIImage(named: "btn-play"), for: .normal)
             
            checkIfPaused = true
        }else{
            webView.playVideo()
            self.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
            checkIfPaused = false
        }
    }
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
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
                let fetchResult = try context?.fetch(request) as? [MyLibraryMusicData]
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
                myLibraryListArray.append(data as! MyLibraryMusicData)
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
            if  let nc = segue.destination as? TopHitsMusicViewController {
                nc.navigationItem.title = "Top Tracks"
                nc.checkTable = false
            }
        }else if segue.identifier == "MyLibraryMusic" {
            if  let nc = segue.destination as? TopHitsMusicViewController {
                nc.navigationItem.title = "My Library"
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
            let selectedVideoId = myLibraryListArray[indexPath.row]
            var videoId = Video()
            videoId.videoId = selectedVideoId.videoId!
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loadVideoVC") as! YouTubeViewController
            nextViewController.checkMyLibraryIsSelected = true
            nextViewController.genreVideoID = videoId
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated: true, completion: nil)
        case topMusicTableView:
            let selectedVideoId = topHitsArray[indexPath.row]
            webView.load(withVideoId: "")
            let sellectedCell = self.topMusicTableView.cellForRow(at: indexPath) as! TopHitsTableViewCell
            genreVideoID = selectedVideoId.videoId
            self.setupCard(sellectedCell: sellectedCell)
            self.musicLabelText.text = selectedVideoId.videoTitle
            self.playButton.frame = CGRect(x: self.cardViewController.view.center.x + 130, y: 48, width: 50, height: 50)
            self.musicLabelText.frame = CGRect(x: 5, y: 50, width: Int(UIScreen.main.bounds.width - 70), height: 50)


            self.musicLabelText.numberOfLines = 0
            self.musicLabelText.textAlignment = .left
            self.musicLabelText.font = UIFont(name: "Verdana", size: 12)
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
            removePostRow(atIndexPath: indexPath)
            myLibraryListArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    func removePostRow(atIndexPath indexPath: IndexPath) {
        context?.delete(myLibraryListArray[indexPath.row])
        do{
            try context?.save()
            if myLibraryListArray.count <= 4 {
                sectionButton.isHidden = true
            }
        }catch {
            print("Could not remove post \(error.localizedDescription)")
        }
    }
    
    
}
