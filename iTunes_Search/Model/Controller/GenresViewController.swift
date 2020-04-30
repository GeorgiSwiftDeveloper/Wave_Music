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
    @IBOutlet weak var countySelectedCollectionView: UICollectionView!
    
    var iTunesConnectionManager = iTunesMusicViewController()
    var containerViewController = ContainerViewControllerForiTunesMusic()
    var indexpath = Int()
    
    
    @IBOutlet weak var genreListNSLayoutTopContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favoriteCollectionView.delegate = self
        self.favoriteCollectionView.dataSource = self
        self.countySelectedCollectionView.delegate = self
        self.countySelectedCollectionView.dataSource = self
        self.favoriteCollectionView.reloadData()
        
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoriteCollectionView.reloadData()
  let countrySelected = UserDefaults.standard.string(forKey: "countrySelected")
        
        if countrySelected != "" {
            genreListNSLayoutTopContraint.constant = 300
            countySelectedCollectionView.isHidden = false
            self.countySelectedCollectionView.reloadData()
        }else{
            genreListNSLayoutTopContraint.constant = 0
            countySelectedCollectionView.isHidden = true
        }
    }
    
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "genrseListSegue" {
            let genreVC = segue.destination as! GenreListViewController
              genreVC.genreTitle  = sender as? GenreModel
          }
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberRows = 0
        switch collectionView {
        case favoriteCollectionView:
            numberRows = GenreModelService.instance.getGenreArray().count
        case countySelectedCollectionView:
            numberRows = 1
        default:
            break
        }
        return numberRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
          switch collectionView {
          case favoriteCollectionView:
           if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCollectionCell", for: indexPath) as? GenresCollectionViewCell {
                    cell.confiigurationCell(GenreModelService.instance.getGenreArray()[indexPath.row])
                 
                    return cell
                }else {
                    return GenresCollectionViewCell()
                }
          case countySelectedCollectionView:
                 if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "countryCollectionCell", for: indexPath) as? SelectedCoutryCollectionViewCell {
                      let countrySelected = UserDefaults.standard.string(forKey: "countrySelected")
                       cell.selectedCountryName.text = "\(countrySelected!) Top Hits"
                    
                    cell.selectedCountryImageView.layer.borderWidth = 2
                    cell.selectedCountryImageView.layer.masksToBounds = false
                    cell.selectedCountryImageView.layer.borderColor = #colorLiteral(red: 0.06832780689, green: 0.05848973244, blue: 0.1592237353, alpha: 0.823224214)
                    cell.selectedCountryImageView.layer.shadowOpacity = 2
                    cell.selectedCountryImageView.layer.shadowPath = UIBezierPath(rect:cell.selectedCountryImageView.bounds).cgPath
                    cell.selectedCountryImageView.layer.shadowRadius = 5
                    cell.selectedCountryImageView.layer.shadowOffset = .zero
                    cell.selectedCountryImageView.layer.cornerRadius = 8.0
                    cell.selectedCountryImageView.clipsToBounds = true
                       return cell
                   }else {
                       return SelectedCoutryCollectionViewCell()
                   }
          default:
              break
          }
          return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedGenreRow = GenreModelService.instance.getGenreArray()[indexPath.row]
//        print(selectedGenreRow.genreTitle)
//        
//        self.performSegue(withIdentifier: "genrseListSegue", sender: selectedGenreRow)
//        
//    }
}
