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
class FavoriteSongsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var navigationForMusic: UINavigationItem!
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    
    var iTunesConnectionManager = iTunesMusicViewController()
    var containerViewController = ContainerViewControllerForiTunesMusic()
    var recivieSelectedMusic = [AlbumModel]()
    var favoriteMusicArray = [SelectedAlbumModel]()
   
    
    var audioPlayer = AVPlayer()


    var indexpath = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favoriteCollectionView.delegate = self
        self.favoriteCollectionView.dataSource = self
        self.favoriteCollectionView.reloadData()
//        self.fetchRequest()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.fetchRequest()
        self.favoriteCollectionView.reloadData()
    }
    
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "genrseListSegue" {
            let genreVC = segue.destination as! GenreListViewController
              genreVC.genreTitle  = sender as? GenreModel
          }
      }
    
    
//    func fetchRequest() {
//        let request:NSFetchRequest<SelectedAlbumModel> = SelectedAlbumModel.fetchRequest()
//        do{
//            favoriteMusicArray = try (context?.fetch(request))!
//        }catch{
//            print("error")
//        }
//        self.favoriteCollectionView.reloadData()
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataService.instance.getGenreArray().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriiteSongsCell", for: indexPath) as? FavoriteSongsCollectionViewCell {
            cell.confiigurationCell(DataService.instance.getGenreArray()[indexPath.row])
            cell.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 5.0
            return cell
        }else {
            return FavoriteSongsCollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        indexpath = indexPath.row
//        print(indexpath)
        let selectedGenreRow = DataService.instance.getGenreArray()[indexPath.row]
        print(selectedGenreRow.genreTitle)
        
        self.performSegue(withIdentifier: "genrseListSegue", sender: selectedGenreRow)
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierSelectedSong"), object: nil)
//
//
//        audioPlayer.pause()
//        if  let audio = favoriteMusicArray[indexPath.row].selectedSongUrl        {
//            do {
//                guard let url = NSURL(string: audio) else { return}
//                playThis(url: url as NSURL)
//            }
//        }
//    }
    
//    func playThis(url: NSURL)
//    {
//        do {
//            let playerItem: AVPlayerItem = AVPlayerItem(url: url as URL)
//            audioPlayer = AVPlayer(playerItem: playerItem)
//            let playerLayer = AVPlayerLayer(player: audioPlayer)
//            playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
//            self.view.layer.addSublayer(playerLayer)
//            audioPlayer.play()
//        } catch  {
//            print(error.localizedDescription)
//        }
//    }
    
    
    
    
    
}
