//
//  MyLibraryViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/24/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class MyLibraryViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var mainLibraryTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupNavBar()
        self.mainLibraryTableView.delegate = self
        self.mainLibraryTableView.dataSource = self
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
        return 1
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
            //            cell.titleLabel.text = "My Library"
            //            cell.imageLabel.image = UIImage(systemName: "tray.and.arrow.down.fill")
            return cell
        }else {
            return MainLibrariMusciTableViewCell()
        }
    }
    
    
}
