//
//  MyLibraryViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/24/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

class MyLibraryViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("F")
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var mainLibraryTableView: UITableView!
    @IBOutlet weak var topMusicTableView: UITableView!
    
    var myLibraryListArray = [MiLibraryMusicData]()
    var topHitsArray = [Video]()
    var getYouTubeData  = YouTubeVideoConnection()
    
    
    
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
        
        
        setupNavBar()
        mainLibraryTableView.alwaysBounceVertical = false
        self.mainLibraryTableView.delegate = self
        self.mainLibraryTableView.dataSource = self
        self.topMusicTableView.delegate = self
        self.topMusicTableView.dataSource = self
        
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
    }
    
    
    func fetchFromCoreData(loadVideoList: @escaping(_ returnVideoList: Video?, _ returnError: Error? ) -> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TopHitsModel")
        //request.predicate = NSPredicate(format: "age = %@", "12")
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
        //        navigationController?.navigationBar.prefersLargeTitles = true
        //        searchController.obscuresBackgroundDuringPresentation  = false
        searchController.searchBar.placeholder = "My Library search"
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
        
//        myLibraryListArray = []
//        fetchMyLibraryList()
        searchBar.text = ""
        searchController.isActive = false
        
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MiLibraryMusicData")
        let predicate = NSPredicate(format: "title contains[c]%@", searchBar.text! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try context?.count(for: request)
            if(count == 0){
                // no matching object
                print("no match")
            }else{
                let fetchResult = try context?.fetch(request) as? [MiLibraryMusicData]
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MiLibraryMusicData")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                myLibraryListArray.append(data as! MiLibraryMusicData)
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
        return 65
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana-Bold", size: 20)!
        header.textLabel?.textColor = #colorLiteral(red: 0.06852825731, green: 0.05823112279, blue: 0.1604561806, alpha: 0.8180118865)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case mainLibraryTableView:
            let  libraryMusicCell = (tableView.dequeueReusableCell(withIdentifier: "LibraryMusicCell", for: indexPath) as? MainLibrariMusciTableViewCell)!
            libraryMusicCell.configureGenreCell(myLibraryListArray[indexPath.row])
            cell = libraryMusicCell
        case topMusicTableView:
            let  libraryMusicCell = (tableView.dequeueReusableCell(withIdentifier: "TopHitsTableViewCell", for: indexPath) as? TopHitsTableViewCell)!
            libraryMusicCell.configureGenreCell(topHitsArray[indexPath.row])
            cell = libraryMusicCell
        default:
            break
        }
        return cell
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
            self.present(nextViewController, animated: true, completion: nil)
        case topMusicTableView:
            let selectedVideoId = topHitsArray[indexPath.row]
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loadVideoVC") as! YouTubeViewController
            nextViewController.checkMyLibraryIsSelected = true
            nextViewController.genreVideoID = selectedVideoId
            self.present(nextViewController, animated: true, completion: nil)
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
            myLibraryListArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
}
