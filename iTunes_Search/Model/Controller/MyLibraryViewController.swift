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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBar()
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
