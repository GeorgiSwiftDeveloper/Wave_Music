//
//  ViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
protocol SelectedMusicDelegate {
    func selectedMusicObject(_ selected: [AlbumModel])
}
let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

class iTunesMusicViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var favoriteMusicTableView: UITableView!
    @IBOutlet weak var containerViewController: UIView!
    
    var iTunesConnectionManager = iTunesConnection()
    var selectedAlbumManager = FavoriteViewController()
    var favoriteAlbum = [AlbumModel]()
    var lastObject = [AlbumModel]()
    var selectedMusic = [SelectedAlbumModel]()
    var selectedMusicDelegate: SelectedMusicDelegate?
    var selectedSong = String()
    
  
    var containerViewControler = ContainerViewControllerForiTunesMusic()
    
    var audioPlayer = AVPlayer()
    
    var checkIfAudioisPause = Bool()
    var selectedIndexPatArray =  [Int]()
    var selectedIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iTunesConnectionManager.delegate = self
        searchTextField.delegate = self
        self.favoriteMusicTableView.delegate = self
        self.favoriteMusicTableView.dataSource = self
        customizeUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifierCnacel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPause(notification:)), name: Notification.Name("NotificationIdentifierPauseSong"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlay(notification:)), name: Notification.Name("NotificationIdentifierPlaySong"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationVolume(notification:)), name: Notification.Name("NotificationIdentifierSongVolume"), object: nil)
    }
    
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.containerViewController.isHidden = true
        audioPlayer.pause()
    }
    
    @objc func methodOfReceivedNotificationPause(notification: Notification) {
        audioPlayer.pause()
    }
    
    @objc func methodOfReceivedNotificationPlay(notification: Notification) {
        do {
            guard let url = NSURL(string: selectedSong) else { return}
            playThis(url: url as URL)
        }
    }
    
    @objc func methodOfReceivedNotificationVolume(notification: Notification) {
        let volume = UserDefaults.standard.float(forKey: "volume")
        audioPlayer.volume = volume
    }
    
    func customizeUI(){
        containerViewController.isHidden = true
        searchTextField.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        searchTextField.layer.cornerRadius = 8.0
    }

    
    @IBAction func searchAction(_ sender: Any) {
        searchTextField.endEditing(true)
    }
     
}

extension iTunesMusicViewController: AlbumManagerDelegate {
    
    func didUpdateAlbum(_ albumManager: iTunesConnection, album: [AlbumModel]) {
        
        DispatchQueue.main.async {
            if  album.count != 0 {
               self.favoriteAlbum.append(contentsOf: album)
               self.favoriteAlbum[0].checkIfSelected = false
               self.favoriteMusicTableView.reloadData()
            }
        }
    }

    
    func didFailWithError(error: Error) {
       
    }

}

extension iTunesMusicViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let songName = searchTextField.text {
            self.favoriteAlbum = []
            iTunesConnectionManager.fetchiTunes(name: songName)
        }
        
        searchTextField.text = ""
        
    }
}
extension iTunesMusicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return favoriteAlbum.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchMusicCell", for: indexPath) as? FavoriteAlbumTableViewCell {
            
            if(indexPath.row == selectedIndex)
            {
                cell.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
                cell.singerNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                cell.songNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                cell.favoriteButton.addTarget(self, action: #selector(self.showFavoriteAlertFunction), for: .touchUpInside)
                    cell.favoriteButton.isHidden = false
            }
            else
            {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.singerNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.songNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.favoriteButton.isHidden = true
            }
//            cell.favoriteButton.tag = indexPath.row;
            cell.confiigurationCell(albums: self.favoriteAlbum[indexPath.row])
            return cell
        }else {
            return FavoriteAlbumTableViewCell()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexRow = tableView.indexPathForSelectedRow
        let selectedCell = self.favoriteMusicTableView.cellForRow(at: selectedIndexRow!) as! FavoriteAlbumTableViewCell
        selectedIndex = indexPath.row
        tableView.reloadData()
        audioPlayer.pause()
        if  let audio = favoriteAlbum[indexPath.row].previewUrl           {
            do {
                guard let url = NSURL(string: audio) else { return}
                playThis(url: url as URL)
            }
        }
        selectedCell.favoriteButton.tag = indexPath.row;
        
        selectedSong = favoriteAlbum[indexPath.row].previewUrl!
        self.containerViewController.isHidden = false
      
        UserDefaults.standard.set(selectedCell.artist, forKey: "artist")
        UserDefaults.standard.set(selectedCell.title, forKey: "title")
        UserDefaults.standard.set(selectedCell.artworkURL, forKey: "image")
        UserDefaults.standard.set(audioPlayer.volume, forKey: "volume")
        NotificationCenter.default.post(name: Notification.Name("getValueFromSelectedRow"), object: nil)
        let thickness: CGFloat = 3.0
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.containerViewController.frame.size.width, height: thickness)
        topBorder.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7027655291)
        containerViewController.layer.addSublayer(topBorder)
    }
    



    
    
    func playThis(url: URL)
       {
           do {
            let playerItem: AVPlayerItem = AVPlayerItem(url: url as URL)
               audioPlayer = AVPlayer(playerItem: playerItem)
               let playerLayer = AVPlayerLayer(player: audioPlayer)
               playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
               self.view.layer.addSublayer(playerLayer)
               audioPlayer.play()
           }
       }
    
    @objc func showFavoriteAlertFunction(sender: UIButton) {
        let alert = UIAlertController(title: "Do you want to add in your favorite list ?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            
            let selectedIndex = IndexPath(row: sender.tag, section: 0)
            self.favoriteMusicTableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
            let selectedCell = self.favoriteMusicTableView.cellForRow(at: selectedIndex) as! FavoriteAlbumTableViewCell
            let selectedMusic = AlbumModel(title: selectedCell.title, artist: selectedCell.artist, genre: selectedCell.genre, artworkURL: selectedCell.artworkURL, trackViewUrl: selectedCell.trackViewUrl, previewUrl: selectedCell.previewUrl, checkIfSelected: false)
            var selectedMusicArray = [AlbumModel]()
            selectedMusicArray.append(selectedMusic)
            let newCategory = SelectedAlbumModel(context: context!)
            
            newCategory.singerName = selectedCell.artist
            newCategory.songTitle = selectedCell.title
            newCategory.songImage = selectedCell.artworkURL
            self.selectedMusic.append(newCategory)
            
            self.saveItems()
        }
        
        let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (action) in
        }
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveItems() {
        do{
            try context?.save()
        }catch{
            print("Can't save items ")
        }
        
    }
          
}
