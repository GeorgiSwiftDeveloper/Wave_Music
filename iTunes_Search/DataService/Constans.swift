//
//  Constans.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 6/30/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation

enum SelectedTableView: String {
    case  topHitsTableView = "TopHits"
    case  libraryTableView  = "MyLibrary"
    case  recentPlayedTableView = "RecentPlayed"
    case  playlistTableView = "Playlist"
}

var cardController = "CardViewController"

var selectedTableViewCellIdentifier = "selectedTableViewCell"
var genreTableViewCellIdentifier =  "genreCell"
var myLibraryTableViewCellIdentifier =  "LibraryMusicCell"
var destinationToMyLibraryIdentifier = "DestinationViewIdentifier"
var destinationToSelectedIdentifier = "IdentifirePlaylistNameVC"


var topHitsEntityName = "TopHitsModel"
var myLibraryEntityName = "MyLibraryMusicData"
var recentPlayedEntityName = "RecentPlayedMusicData"
var playlistEntityName = "PlaylistMusicData"

var genreTypeHits = "Hits"

