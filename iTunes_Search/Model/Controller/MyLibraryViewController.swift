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
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var mainLibraryTableView: UITableView!
    
    var myLibraryListArray = [Video]()
    
    var selec = GenreModel(genreImage: "", genreTitle: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavBar()
//        fetchMyLibraryList()
        mainLibraryTableView.alwaysBounceVertical = false
        self.mainLibraryTableView.delegate = self
        self.mainLibraryTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        DispatchQueue.main.async {
            self.myLibraryListArray = []
            self.fetchMyLibraryList()
          }
    }
    

    
    
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.obscuresBackgroundDuringPresentation  = false
        searchController.searchBar.placeholder = "Search"
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
        searchBar.text = ""
        searchController.isActive = false
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        print("update search results ... called here")
    }
    
    
    func fetchMyLibraryList(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MiLibraryMusicData")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as! String
                let image = data.value(forKey: "image") as! String
                let videoId = data.value(forKey: "videoId") as! String
                
                let fetchedVideoList = Video(videoId: videoId, videoTitle: title, videoDescription: "", videoPlaylistId: "", videoImageUrl: image, channelId: "", genreTitle: "")
                myLibraryListArray.append(fetchedVideoList)
                mainLibraryTableView.reloadData()
            }
            
        } catch {
            print("Failed")
        }
    }
    
    
    
}

extension MyLibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        if section == 0 {
    //            return "Playlists"
    //        } else {
    //            return ""
    //        }
    //    }
    //
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myLibraryListArray.count
    }
    //
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 65
    //    }
    //
    //    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    //    {
    //        view.tintColor = UIColor.white
    //        let header = view as! UITableViewHeaderFooterView
    //        header.textLabel?.font = UIFont(name: "Verdana-Bold", size: 22)!
    //        header.textLabel?.textColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
    //    }
    
    //    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
    //        view.tintColor = UIColor.red
    //        let header = view as! UITableViewHeaderFooterView
    //        header.textLabel?.textColor = UIColor.white
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryMusicCell", for: indexPath) as? MainLibrariMusciTableViewCell {
            cell.configureGenreCell(myLibraryListArray[indexPath.row])
            return cell
        }else {
            return MainLibrariMusciTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideoId = myLibraryListArray[indexPath.row]
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loadVideoVC") as! YouTubeViewController
         nextViewController.checkMyLibraryIsSelected = true
        nextViewController.genreVideoID = selectedVideoId
         self.present(nextViewController, animated: true, completion: nil)

         }
      

    
    
}
