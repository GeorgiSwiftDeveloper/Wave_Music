//
//  CreatPlaylistsViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/30/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

class CreatPlaylistsViewController: UIViewController {
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    var createdPlaylistArray = ["New Playlist"]
    var selectedPlaylistRowTitle: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let musicPlaylist = UserDefaults.standard.object(forKey: "MusicPlaylist") as? [String] {
            createdPlaylistArray = musicPlaylist
        }
        self.playlistTableView.reloadData()
    }
    
    
    
    
}

extension CreatPlaylistsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createdPlaylistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? PlaylistsTableViewCell {
            if indexPath.row == 0 {
                cell.trackCountLabel.isHidden = true
                cell.playlistName.text = createdPlaylistArray[0]
                cell.playlistName.textColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 1)
                cell.playlistName.font = UIFont(name: "Verdana-Bold", size: 14.0)
                cell.playlistImage.image = UIImage(systemName: "list.bullet")
            }else{
                
                cell.playlistName.text = createdPlaylistArray[indexPath.row]
                cell.playlistName.textColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 1)
                cell.playlistName.font = UIFont(name: "Verdana", size: 12.0)
                cell.playlistName.textAlignment = .left
                cell.playlistImage.image = UIImage(systemName: "music.note.list")
                cell.playlistImage.tintColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            }
            return cell
        }else {
            return PlaylistsTableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            var playlistTxt = UITextField()
            let alert = UIAlertController(title: "New Playlist", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }
            let createPlaylistAction = UIAlertAction(title: "Create", style: .default) { (action) in
                let text = (alert.textFields?.first as! UITextField).text
                if text == ""{
                    print("data is empty")
                }else{
                    self.createdPlaylistArray.append(text!)
                    UserDefaults.standard.set(self.createdPlaylistArray, forKey:"MusicPlaylist")
                    self.playlistTableView.reloadData()
                }
            }
            
            alert.addAction(action)
            alert.addAction(createPlaylistAction)
            //Add text field
            alert.addTextField { (texfield) in
                playlistTxt = texfield
                playlistTxt.placeholder = "Enter  name for this playlist"
            }
            present(alert, animated: true, completion: nil)
        }else{
            
            selectedPlaylistRowTitle = createdPlaylistArray[indexPath.row]
            UserDefaults.standard.set(self.selectedPlaylistRowTitle, forKey:"selectedPlaylistRowTitle")
            saveSelectedMusicCoreDataEntity(selectedPlaylistRowTitle!)
            
            self.performSegue(withIdentifier: "IdentifireByPlaylistName", sender: selectedPlaylistRowTitle)
        }
        
        
    }
    
    func saveSelectedMusicCoreDataEntity(_ selectedPlaylistRowTitle: String) {
        let videoIDProperty = UserDefaults.standard.object(forKey: "videoId") as? String
        let videoImageUrlProperty = UserDefaults.standard.object(forKey: "image") as? String
        let videoTitleProperty = UserDefaults.standard.object(forKey: "title") as? String
        
        if (videoIDProperty != nil) || (videoImageUrlProperty != nil) || (videoTitleProperty != nil) {
            CoreDataVideoClass.coreDataVideoInstance.saveVideoWithEntityName(videoTitle: videoTitleProperty!, videoImage: videoImageUrlProperty!, videoId: videoIDProperty!, playlistName: selectedPlaylistRowTitle, coreDataEntityName: playlistEntityName) { (checkIfLoadIsSuccessful, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IdentifireByPlaylistName" {
            if let playlistDestVC = segue.destination as? SelectedSectionViewController{
                playlistDestVC.navigationItem.title = sender as? String
                playlistDestVC.checkTableViewName = "Playlist"
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row != 0{
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == PlaylistsTableViewCell.EditingStyle.delete{
//            removeSelectedVideoRow(atIndexPath: indexPath)
            createdPlaylistArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
//
//    func removeSelectedVideoRow(atIndexPath indexPath: IndexPath) {
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: playlistEntityName)
//        let result = try? context?.fetch(request)
//        let resultData = result as! [NSManagedObject]
//        context?.delete(resultData[indexPath.row])
//        do{
//            try context?.save()
//        }catch {
//            print("Could not remove video from Database \(error.localizedDescription)")
//        }
//    }

    
    
}
