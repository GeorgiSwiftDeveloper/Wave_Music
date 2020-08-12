//
//  SearchControllerView.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 8/11/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import UIKit

enum SearchPlaceholder: String {
    case librarySearch = "Search Library"
    case youTubeSearch = "Search YouTube"
}

class SearchController: NSObject {
    
    static var sharedSearchControllerInstace = SearchController()
    
    func searchController(_ searchController: UISearchController, superViewController: UIViewController,navigationItem: UINavigationItem, searchPlaceholder: SearchPlaceholder)  {
         
        searchController.searchBar.placeholder =  searchPlaceholder.rawValue
        
        searchController.searchBar.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        searchController.searchBar.sizeToFit()
        searchController.delegate = superViewController as? UISearchControllerDelegate
        searchController.searchBar.delegate = superViewController as? UISearchBarDelegate
        searchController.searchBar.isHidden = false
        searchController.hidesNavigationBarDuringPresentation = true
        superViewController.definesPresentationContext = true
        navigationItem.searchController?.searchBar.delegate = superViewController as? UISearchBarDelegate
        navigationItem.searchController?.searchResultsUpdater = superViewController as? UISearchResultsUpdating
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

}

