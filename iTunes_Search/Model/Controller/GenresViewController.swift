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
import YoutubePlayer_in_WKWebView
class GenresViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet weak var navigationForMusic: UINavigationItem!
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    @IBOutlet weak var countySelectedCollectionView: UICollectionView!
    var selectedGenreIndexRow = Int()
    var indexArray = [Int]()
    var indexpath = Int()
    var genreCollectionViewBottomHeight = 145
    
    @IBOutlet weak var genreListNSLayoutBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var genreListNSLayoutTopContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let countrySelected = UserDefaults.standard.string(forKey: "countrySelected")
        
        if countrySelected != "" {
            favoriteCollectionView.isScrollEnabled = true
            genreListNSLayoutTopContraint.constant = 200
            countySelectedCollectionView.isHidden = false
            self.countySelectedCollectionView.reloadData()
        }else{
            favoriteCollectionView.isScrollEnabled = false
            genreListNSLayoutTopContraint.constant = 0
            countySelectedCollectionView.isHidden = true
        }
        self.favoriteCollectionView.delegate = self
        self.favoriteCollectionView.dataSource = self
        self.countySelectedCollectionView.delegate = self
        self.countySelectedCollectionView.dataSource = self
        self.favoriteCollectionView.reloadData()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierGenreRowSelected(notification:)), name: Notification.Name("NotificationIdentifierGenreRowSelected"), object: nil)
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        switch pause {
        case true:
            VideoPlayerClass.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
            VideoPlayerClass.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
                if let error = error {
                    print("Error getting player state:" + error.localizedDescription)
                } else if let playerState = playerState as? WKYTPlayerState {
                    
                    self?.updatePlayerState(playerState)
                }
            })
        case false:
            VideoPlayerClass.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayerClass.callVideoPlayer.cardViewController.view)
            VideoPlayerClass.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
                if let error = error {
                    print("Error getting player state:" + error.localizedDescription)
                } else if let playerState = playerState as? WKYTPlayerState {
                    
                    self?.updatePlayerState(playerState)
                }
            })
        default:
            break
        }
    }
    
    func updatePlayerState(_ playerState: WKYTPlayerState){
        switch playerState {
        case .ended:
            self.showVideoPlayerPause()
        case .paused:
            self.showVideoPlayerPause()
            
        case .playing:
            self.showVideoPlayer()
        default:
            break
        }
    }
    
    
    func showVideoPlayer(){
        VideoPlayerClass.callVideoPlayer.webView.playVideo()
    }
    func showVideoPlayerPause(){
        VideoPlayerClass.callVideoPlayer.webView.pauseVideo()
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        VideoPlayerClass.callVideoPlayer.cardViewController.removeFromParent()
    }
    
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "genrseListSegue" {
            let genreVC = segue.destination as! GenreListViewController
            let selectedSearch = UserDefaults.standard.object(forKey: "selectedSearch") as? Bool
            if selectedSearch == true {
                genreVC.searchIsSelected = true
            }
            
            let selectedmyLybrary = UserDefaults.standard.object(forKey: "selectedmyLybrary") as? Bool
            if selectedmyLybrary == true {
                genreVC.selectedmyLybrary = true
            }
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
                UserDefaults.standard.set(indexPath.row, forKey:"selectedGenereCollectionIndex")
                indexArray.append(indexPath.row)
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
    
    @objc func NotificationIdentifierGenreRowSelected(notification: Notification) {
        UserDefaults.standard.set(selectedGenreIndexRow, forKey:"selectedGenereCollectionIndex")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case favoriteCollectionView:
            let selectedGenreRow = GenreModelService.instance.getGenreArray()[indexPath.row]
            selectedGenreIndexRow = indexPath.row
            
            let selectedGenereCollectionIndex = UserDefaults.standard.object(forKey: "selectedGenereCollectionIndex") as? Int
            if selectedGenereCollectionIndex == selectedGenreIndexRow {
                UserDefaults.standard.set(true, forKey:"checkGenreRowIsSelected")
            }else{
                UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
            }
            self.performSegue(withIdentifier: "genrseListSegue", sender: selectedGenreRow)
        case countySelectedCollectionView:
            let selectedGenreRow = GenreModelService.instance.getGenreArray()[indexPath.row]
            self.performSegue(withIdentifier: "genrseListSegue", sender: selectedGenreRow)
        default:
            break
        }
    }
}
