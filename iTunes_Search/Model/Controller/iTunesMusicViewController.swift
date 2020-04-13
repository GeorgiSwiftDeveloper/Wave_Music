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
    
    var iTunesConnectionManager = iTunesConnection()
    var selectedAlbumManager = FavoriteViewController()
    
    var favoriteAlbum = [AlbumModel]()
    var lastObject = [AlbumModel]()
    var selectedMusic = [SelectedAlbumModel]()
    var selectedMusicDelegate: SelectedMusicDelegate?
    
    
    var audioPlayer = AVPlayer()
    var player = AVAudioPlayer()
    
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
    }
    
    func customizeUI(){
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
            }
            else
            {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.singerNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.songNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            cell.favoriteButton.tag = indexPath.row;
            cell.confiigurationCell(albums: self.favoriteAlbum[indexPath.row])
            cell.favoriteButton.addTarget(self, action: #selector(self.showFavoriteAlertFunction), for: .touchUpInside)
            return cell
        }else {
            return FavoriteAlbumTableViewCell()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedIndexRow = tableView.indexPathForSelectedRow
//        let selectedCell = self.favoriteMusicTableView.cellForRow(at: selectedIndexRow!) as! FavoriteAlbumTableViewCell
        selectedIndex = indexPath.row
        tableView.reloadData()
        audioPlayer.pause()
        if  let audio = favoriteAlbum[indexPath.row].previewUrl           {
            do {
                guard let url = NSURL(string: audio) else { return}
                playThis(url: url as URL)
            }
        }
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
