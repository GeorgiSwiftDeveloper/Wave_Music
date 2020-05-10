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
    
    @IBOutlet weak var genreBottomNSLayoutConstraint: NSLayoutConstraint!
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
            genreListNSLayoutTopContraint.constant = 200
            countySelectedCollectionView.isHidden = false
            self.countySelectedCollectionView.reloadData()
        }else{
            genreListNSLayoutTopContraint.constant = 0
            countySelectedCollectionView.isHidden = true
        }
        let checkVideoIsPlaying = UserDefaults.standard.object(forKey: "checkVideoIsPlaying") as? Bool
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        if checkVideoIsPlaying == true{
              if pause == nil || pause == true{
                self.showVideoPlayer()
                self.genreBottomNSLayoutConstraint.constant = 170
                favoriteCollectionView.updateConstraints()
              }else{
                self.showVideoPlayerPause()
                self.genreBottomNSLayoutConstraint.constant = 170
                favoriteCollectionView.updateConstraints()
            }
        }
    }
    
    
    func showVideoPlayer(){
          VideoPlayerClass.callVideoPlayer.superViewController = self
          self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
          VideoPlayerClass.callVideoPlayer.webView.playVideo()
      }
      func showVideoPlayerPause(){
          VideoPlayerClass.callVideoPlayer.superViewController = self
          self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
          VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
      }
    
    

    
    
    override func viewDidDisappear(_ animated: Bool) {
         super .viewDidDisappear(animated)
         VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
         NotificationCenter.default.post(name: Notification.Name("not"), object: nil)
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
        
        let cell = UICollectionViewCell()
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
                       cell.selectedCountryName.text = "\(countrySelected!)\n Top Hits 2020"
                    
                    cell.selectedCountryImageView.layer.borderWidth = 3
                    cell.selectedCountryImageView.layer.masksToBounds = false
                    cell.selectedCountryImageView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
                    cell.selectedCountryImageView.layer.shadowOpacity = 3
                    cell.selectedCountryImageView.layer.shadowPath = UIBezierPath(rect:cell.selectedCountryImageView.bounds).cgPath
                    cell.selectedCountryImageView.layer.shadowRadius = 5
                    cell.selectedCountryImageView.layer.shadowOffset = .zero
                    cell.selectedCountryImageView.layer.cornerRadius = 10.0
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case favoriteCollectionView:
            let selectedGenreRow = GenreModelService.instance.getGenreArray()[indexPath.row]
            print(selectedGenreRow.genreTitle)
            
            
            self.performSegue(withIdentifier: "genrseListSegue", sender: selectedGenreRow)
        case countySelectedCollectionView:
            print("a")
        default:
            break
        }
    }
}
