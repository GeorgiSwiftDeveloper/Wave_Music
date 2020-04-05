//
//  FavoriteSongsViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
class FavoriteSongsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

 


    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    var iTunesConnectionManager = iTunesMusicViewController()
    var recivieSelectedMusic = [AlbumModel]()
        var favoriteMusicArray = [SelectedAlbumModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.favoriteCollectionView.delegate = self
        self.favoriteCollectionView.dataSource = self
        self.favoriteCollectionView.reloadData()
        self.fetchRequest()
    }
    

    
 
     
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.fetchRequest()
           self.favoriteCollectionView.reloadData()
       }
       
       
    func fetchRequest() {
        let request:NSFetchRequest<SelectedAlbumModel> = SelectedAlbumModel.fetchRequest()
        do{
            favoriteMusicArray = try (context?.fetch(request))!
        }catch{
            print("error")
        }
        self.favoriteCollectionView.reloadData()
    }
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteMusicArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriiteSongsCell", for: indexPath) as? FavoriteSongsCollectionViewCell {
           cell.confiigurationCell(albums: favoriteMusicArray[indexPath.row])
                return cell
            }else {
                return FavoriteSongsCollectionViewCell()
            }
    }
    
    
}
