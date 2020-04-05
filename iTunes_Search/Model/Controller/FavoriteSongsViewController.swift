//
//  FavoriteSongsViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class FavoriteSongsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, SelectedMusicDelegate {

 


    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    var iTunesConnectionManager = iTunesMusicViewController()
    var recivieSelectedMusic = [AlbumModel]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
         iTunesConnectionManager.selectedMusicDelegate = self
        self.favoriteCollectionView.delegate = self
        self.favoriteCollectionView.dataSource = self
        self.favoriteCollectionView.reloadData()
    }
    

    
     func selectedMusicObject(_ selected: [AlbumModel]) {
        recivieSelectedMusic = selected
        self.favoriteCollectionView.reloadData()
      }
     
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recivieSelectedMusic.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriiteSongsCell", for: indexPath) as? FavoriteSongsCollectionViewCell {
            cell.confiigurationCell(albums: recivieSelectedMusic[indexPath.row])
                return cell
            }else {
                return FavoriteSongsCollectionViewCell()
            }
    }
    
    
}
