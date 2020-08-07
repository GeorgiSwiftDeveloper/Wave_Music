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
    @IBOutlet weak var genreCollectionView: UICollectionView!
    
    var selectedGenreIndexRow = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.genreCollectionView.delegate = self
        self.genreCollectionView.dataSource = self

        collectionViewLayout()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pause = UserDefaults.standard.object(forKey: "pause") as? Bool
        switch pause {
        case true:
            VideoPlayer.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayer.callVideoPlayer.cardViewController.view)
            VideoPlayer.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
                if let error = error {
                    print("Error getting player state:" + error.localizedDescription)
                } else if let playerState = playerState as? WKYTPlayerState {
                    
                    self?.updatePlayerState(playerState)
                }
            })
        case false:
            VideoPlayer.callVideoPlayer.superViewController = self
            self.view.addSubview(VideoPlayer.callVideoPlayer.cardViewController.view)
            VideoPlayer.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
                if let error = error {
                    print("Error getting player state:" + error.localizedDescription)
                } else if let playerState = playerState as? WKYTPlayerState {
                    
                    self?.updatePlayerState(playerState)
                }
            })
        default:
            break
        }
         self.navigationController?.navigationBar.isHidden = true
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
        VideoPlayer.callVideoPlayer.webView.playVideo()
    }
    func showVideoPlayerPause(){
        VideoPlayer.callVideoPlayer.webView.pauseVideo()
    }
    
    func collectionViewLayout() {
        let layout = self.genreCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0,left: 5,bottom: 0,right: 5)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.genreCollectionView.frame.size.width - 20)/2, height: self.genreCollectionView.frame.size.height/3)
        
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        VideoPlayer.callVideoPlayer.cardViewController.removeFromParent()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  GenreModelService.instance.getGenreArray().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCollectionCell", for: indexPath) as? GenresCollectionViewCell {
                
                cell.confiigurationGenreCell(GenreModelService.instance.getGenreArray()[indexPath.row])
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 0.5
                cell.layer.cornerRadius = 6
                cell.layer.backgroundColor = UIColor.white.cgColor

                return cell
            }else {
                return GenresCollectionViewCell()
            }
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
            genreVC.genreModel  = sender as? GenreModel
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedGenreRow = GenreModelService.instance.getGenreArray()[indexPath.row]
            selectedGenreIndexRow = indexPath.row
            
            let selectedGenereCollectionIndex = UserDefaults.standard.object(forKey: "selectedGenereCollectionIndex") as? Int
            if selectedGenereCollectionIndex == selectedGenreIndexRow {
                UserDefaults.standard.set(true, forKey:"checkGenreRowIsSelected")
            }else{
                UserDefaults.standard.set(false, forKey:"checkGenreRowIsSelected")
            }
            
            self.performSegue(withIdentifier: "genrseListSegue", sender: selectedGenreRow)
    }
}
