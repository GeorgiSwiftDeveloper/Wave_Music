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
    
    
    var iTunesConnectionManager = iTunesConnection()
    var selectedAlbumManager = FavoriteViewController()
    
    var favoriteAlbum = [AlbumModel]()
    var selectedAlbum = [AlbumModel]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iTunesConnectionManager.delegate = self
        searchTextField.delegate = self
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
            favoriteButton.isUserInteractionEnabled = true
            let alert = UIAlertController(title: "Favorite", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
                nextViewController.favoriteAlbum.append(contentsOf: self.favoriteAlbum)
                self.present(nextViewController, animated:true, completion:nil)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else{
            favoriteButton.isUserInteractionEnabled = false
        }
    }
}

extension iTunesMusicViewController: AlbumManagerDelegate, SelectedAlbumFromFavorites {
    
    func didUpdateAlbum(_ albumManager: iTunesConnection, album: [AlbumModel]) {
        
        DispatchQueue.main.async {
            let singerName = album[0].artist
            let titleLabel = album[0].title
            let genreLabel = album[0].genre
            let artWorkImage = UIImage(data: NSData(contentsOf: URL(string:album[0].artworkURL!)!)! as Data)
            
            self.singerNameLabel.text = singerName
            self.titleLabel.text = titleLabel
            self.genreLabel.text = genreLabel
            self.artWorkImageView.image = artWorkImage
            
            self.favoriteAlbum.append(contentsOf: album)
            
        }
    }

    
    func didFailWithError(error: Error) {
       
    }
    
    func selectedAlbum(album: AlbumModel) {
        self.selectedAlbum.append(album)
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
