//
//  FavoriteSongsViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/4/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
class GenresViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var navigationForMusic: UINavigationItem!
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    
    var iTunesConnectionManager = iTunesMusicViewController()
    var containerViewController = ContainerViewControllerForiTunesMusic()
    var indexpath = Int()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favoriteCollectionView.delegate = self
        self.favoriteCollectionView.dataSource = self
        self.favoriteCollectionView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoriteCollectionView.reloadData()
    }
    
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "genrseListSegue" {
            let genreVC = segue.destination as! GenreListViewController
              genreVC.genreTitle  = sender as? GenreModel
          }
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GenreModelService.instance.getGenreArray().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCollectionCell", for: indexPath) as? GenresCollectionViewCell {
            cell.confiigurationCell(GenreModelService.instance.getGenreArray()[indexPath.row])
            cell.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 5.0
            return cell
        }else {
            return GenresCollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGenreRow = GenreModelService.instance.getGenreArray()[indexPath.row]
        print(selectedGenreRow.genreTitle)
        
        self.performSegue(withIdentifier: "genrseListSegue", sender: selectedGenreRow)
        
    }
}
