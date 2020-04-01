//
//  ViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var artWorkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var urlForSong: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var saveToFavorites: UILabel!
    
    
    var iTunesConnectionManager = iTunesConnection()
    var selectedAlbumManager = FavoriteViewController()
    
    var favoriteAlbum = [AlbumModel]()
    var selectedAlbum = [AlbumModel]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         iTunesConnectionManager.delegate = self
        searchTextField.delegate = self
        
    }
    @IBAction func searchButtonAction(_ sender: Any) {
         searchTextField.endEditing(true)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                   let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
                   nextViewController.favoriteAlbum.append(contentsOf: self.favoriteAlbum)
                   self.present(nextViewController, animated:true, completion:nil)
        self.favoriteButton.setTitle("", for: .normal)
    }
    
    @IBAction func searchAction(_ sender: Any) {
         searchTextField.endEditing(true)
        self.favoriteButton.isUserInteractionEnabled = true
        self.saveToFavorites.text = "Save to Favorites"
        self.favoriteButton.setTitle("", for: .normal)
        self.favoriteButton.setTitle("", for: .normal)
    }
    
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Favorite", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.favoriteButton.setTitle("This song added to your favorite list ", for: .normal)
            self.saveToFavorites.text = ""
            self.favoriteButton.isUserInteractionEnabled = false
            self.favoriteButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
            nextViewController.favoriteAlbum.append(contentsOf: self.favoriteAlbum)
            self.present(nextViewController, animated:true, completion:nil)
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: AlbumManagerDelegate, SelectedAlbumFromFavorites {
    
    func didUpdateAlbum(_ albumManager: iTunesConnection, album: [AlbumModel]) {
        
        DispatchQueue.main.async {
            let singerName = album[0].artist
            let titleLabel = album[0].title
            let genreLabel = album[0].genre
            let artWorkImage = UIImage(data: NSData(contentsOf: URL(string:album[0].artworkURL!)!)! as Data)
            let urlForSong = album[0].trackViewUrl
            
            self.singerNameLabel.text = singerName
            self.titleLabel.text = titleLabel
            self.genreLabel.text = genreLabel
            self.artWorkImageView.image = artWorkImage
            self.urlForSong.text = urlForSong
            
            self.favoriteAlbum.append(contentsOf: album)
            
        }
    }

    
    func didFailWithError(error: Error) {
       
    }
    
    func selectedAlbum(album: AlbumModel) {
        self.selectedAlbum.append(album)
    }
}

extension ViewController: UITextFieldDelegate {
    
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
