//
//  ViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class iTunesMusicViewController: UIViewController {
    
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var artWorkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteMusicTableView: UITableView!
    
    var iTunesConnectionManager = iTunesConnection()
    var selectedAlbumManager = FavoriteViewController()
    
    var favoriteAlbum = [AlbumModel]()
   var lastObject = [AlbumModel]()
    
    
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
        self.favoriteButton.setTitle("", for: .normal)
        self.favoriteButton.setTitle("", for: .normal)
    }
    
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        if self.favoriteAlbum.count > 0{
            
            let alert = UIAlertController(title: "This song succesfuly added to your favorites", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                self.favoriteMusicTableView.reloadData()
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else{
            let erorrAlert = UIAlertController(title: "There is no music that we can add to your favorites, please search music ", message: nil, preferredStyle: .alert)
            let emptyAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            erorrAlert.addAction(emptyAction)
            present(erorrAlert, animated: true, completion: nil)
        }
    }
}

extension iTunesMusicViewController: AlbumManagerDelegate {
    
    func didUpdateAlbum(_ albumManager: iTunesConnection, album: [AlbumModel]) {
        
        DispatchQueue.main.async {
            let singerName = album[0].artist
            let titleLabel = album[0].title
            let genreLabel = album[0].genre
            if album[0].artworkURL != "" {
                let artWorkImage = UIImage(data: NSData(contentsOf: URL(string:album[0].artworkURL!)!)! as Data)
                 self.artWorkImageView.image = artWorkImage
            }else{
                 self.artWorkImageView.image = UIImage(named: "song-logo-png-")
            }
         
            
            self.singerNameLabel.text = singerName
            self.titleLabel.text = titleLabel
            self.genreLabel.text = genreLabel
            if  album.count != 0 {
               self.favoriteAlbum.append(contentsOf: album)

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as? FavoriteAlbumTableViewCell
        cell?.confiigurationCell(albums: favoriteAlbum[indexPath.row])
        
        return cell!
    }
    
      func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == UITableViewCell.EditingStyle.delete {
             favoriteAlbum.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
         }
     }
    
    
    
}
