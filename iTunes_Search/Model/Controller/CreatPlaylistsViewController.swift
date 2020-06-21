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
    
    var selectedRowTitle: String?
    
    internal var _model: NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create the entity
        let entity = NSEntityDescription()
        entity.name = "DTCachedFile"
        // Assume that there is a correct
        // `CachedFile` managed object class.
        entity.managedObjectClassName = "DTCachedFile"
        
        // Create the attributes
        var properties = Array<NSAttributeDescription>()
        
        let remoteURLAttribute = NSAttributeDescription()
        remoteURLAttribute.name = "title"
        remoteURLAttribute.attributeType = .stringAttributeType
        remoteURLAttribute.isOptional = false
        //        remoteURLAttribute.isIndexed = true
        properties.append(remoteURLAttribute)
        
        let fileDataAttribute = NSAttributeDescription()
        fileDataAttribute.name = "image"
        fileDataAttribute.attributeType = .stringAttributeType
        fileDataAttribute.isOptional = false
        //        fileDataAttribute.allowsExternalBinaryDataStorage = true
        properties.append(fileDataAttribute)
        
        let lastAccessDateAttribute = NSAttributeDescription()
        lastAccessDateAttribute.name = "videoID"
        lastAccessDateAttribute.attributeType = .stringAttributeType
        lastAccessDateAttribute.isOptional = false
        properties.append(lastAccessDateAttribute)
        
        // Add attributes to entity
        entity.properties = properties
        
        // Add entity to model
        model.entities = [entity]
        
        // Done :]
        return model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
    }
    
    
    
    
}

extension CreatPlaylistsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createdPlaylistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? PlaylistsTableViewCell {
            if indexPath.row == 0 {
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
                    print(self.createdPlaylistArray.count)
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
            
            selectedRowTitle = createdPlaylistArray[indexPath.row]
            createCoreDataEntity(selectedRowTitle!)
            self.performSegue(withIdentifier: "IdentifireByPlaylistName", sender: selectedRowTitle)
        }
        
        
    }
    
    func createCoreDataEntity(_ entityNameIs: String) {
        let videoIDProperty = UserDefaults.standard.object(forKey: "videoId") as? String
        let videoImageUrlProperty = UserDefaults.standard.object(forKey: "image") as? String
        let videoTitleProperty = UserDefaults.standard.object(forKey: "title") as? String
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaylistMusicData")
        let predicate = NSPredicate(format: "title == %@", videoTitleProperty! as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1
        do{
            
            let entity = NSEntityDescription.entity(forEntityName:"PlaylistMusicData", in: context!)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            
            newEntity.setValue(videoTitleProperty, forKey: "title")
            newEntity.setValue(videoIDProperty, forKey: "videoId")
            newEntity.setValue(videoImageUrlProperty, forKey: "image")
            
            try context?.save()
            print("data has been saved ")
        }catch{
            print("error")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IdentifireByPlaylistName" {
            if let playlistDestVC = segue.destination as? SelectedSectionViewController{
                playlistDestVC.navigationItem.title = sender as? String
                playlistDestVC.checkTableViewName = "Playlist"
//                playlistDestVC.selectedPlaylistName = ("\(sender ?? "")Model")
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
            createdPlaylistArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    
}
