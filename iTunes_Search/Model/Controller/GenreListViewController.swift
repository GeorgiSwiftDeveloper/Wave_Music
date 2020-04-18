//
//  GenreListViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import YouTubePlayer

//let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
class GenreListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var topGenreLabelText: UILabel!
    
    @IBOutlet weak var genreTableView: UITableView!
    var genreTitle: GenreModel?
    var videoArray = [Video]()
    var getYouTubeData  = YouTubeVideoConnection()
    var arrrayInt = Int()
    var checkifDataIsEmpty = true
    
    var entityName = String()
    
    var isEmpty: Bool {
        switch genreTitle?.genreTitle {
        case "Rap":
            entityName = "YouTubeDataModel"
        case "Hip-Hop":
            entityName = "YouTubeHipHopData"
        case "Pop":
            entityName = "YouTubePopData"
        case "Rock":
            entityName = "YouTubeRockData"
        case "R&B":
            entityName = "YouTubeRBData"
        case "Dance":
            entityName = "YouTubeDanceData"
        case "Electronic":
            entityName = "YouTubeElectronicData"
        case "Jazz":
            entityName = "YouTubeJazzData"
        case "Instrumental":
            entityName = "YouTubeInstrumentalData"
        case "Blues":
            entityName = "YouTubeBluesData"
        default:
            break
        }
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let count  = try context?.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        topGenreLabelText.text  = "Top \(genreTitle!.genreTitle) Song's"
        genreTableView.delegate = self
        genreTableView.dataSource = self
//        print(genreTitle?.genreTitle)
        if isEmpty{
            self.getYouTubeData.getFeedVideos(genreType: self.genreTitle!.genreTitle) { (loadVideolist, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }else{
                    DispatchQueue.main.async{
                        self.videoArray = loadVideolist!
                        for songIndex in 0..<self.videoArray.count{
                            let title =   self.videoArray[songIndex].videoTitle
                            let description =  self.videoArray[songIndex].videoDescription
                            let image =  self.videoArray[songIndex].videoImageUrl
                            let playlistId = self.videoArray[songIndex].videoPlaylistId
                            let videoId =  self.videoArray[songIndex].videoId
                            
                            self.saveItems(title: title, description: description, image: image, videoId: videoId, playlistId: playlistId,genreTitle: self.genreTitle!.genreTitle)
                            
                        }
                        self.genreTableView.reloadData()
                    }
                }
            }
        }else{
            self.fetchFromCoreData { (videoList, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }else{
                    if videoList != nil {
                        self.videoArray.append(videoList!)
                        self.genreTableView.reloadData()
                    }
                }
            }
            
        }
    }
    
    func saveItems(title:String,description:String,image:String,videoId:String,playlistId:String,genreTitle: String) {
        switch genreTitle {
        case "Rap":
            entityName = "YouTubeDataModel"
        case "Hip-Hop":
            entityName = "YouTubeHipHopData"
        case "Pop":
            entityName = "YouTubePopData"
        case "Rock":
            entityName = "YouTubeRockData"
        case "R&B":
            entityName = "YouTubeRBData"
        case "Dance":
            entityName = "YouTubeDanceData"
        case "Electronic":
            entityName = "YouTubeElectronicData"
        case "Jazz":
            entityName = "YouTubeJazzData"
        case "Instrumental":
            entityName = "YouTubeInstrumentalData"
        case "Blues":
            entityName = "YouTubeBluesData"
        default:
            break
        }
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context!)
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        newEntity.setValue(title, forKey: "title")
        newEntity.setValue(image, forKey: "image")
        newEntity.setValue(videoId, forKey: "videoId")
        newEntity.setValue(description, forKey: "songDescription")
        newEntity.setValue(playlistId, forKey: "playListId")
        do {
            try context?.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func fetchFromCoreData(loadVideoList: @escaping(_ returnVideoList: Video?, _ returnError: Error? ) -> ()){
        switch genreTitle?.genreTitle {
        case "Rap":
            entityName = "YouTubeDataModel"
        case "Hip-Hop":
            entityName = "YouTubeHipHopData"
        case "Pop":
            entityName = "YouTubePopData"
        case "Rock":
            entityName = "YouTubeRockData"
        case "R&B":
            entityName = "YouTubeRBData"
        case "Dance":
            entityName = "YouTubeDanceData"
        case "Electronic":
            entityName = "YouTubeElectronicData"
        case "Jazz":
            entityName = "YouTubeJazzData"
        case "Instrumental":
            entityName = "YouTubeInstrumentalData"
        case "Blues":
            entityName = "YouTubeBluesData"
        default:
            break
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as! String
                let image = data.value(forKey: "image") as! String
                let videoId = data.value(forKey: "videoId") as! String
                let songDescription = data.value(forKey: "songDescription") as! String
                let playlistId = data.value(forKey: "playListId") as! String
                let fetchedVideoList = Video(videoId: videoId, videoTitle: title, videoDescription: songDescription, videoPlaylistId: playlistId, videoImageUrl: image)
                loadVideoList(fetchedVideoList,nil)
            }
            
        } catch {
            loadVideoList(nil,error)
            print("Failed")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath) as? GenreVideoTableViewCell {
            cell.configureGenreCell(videoArray[indexPath.row])
            return cell
        }else {
            return GenreVideoTableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//           let selectedIndexRow = tableView.indexPathForSelectedRow
//        let selectedCell = self.genreTableView.cellForRow(at: selectedIndexRow!) as! GenreVideoTabletiewCell
        let selectedVideoId = videoArray[indexPath.row]
           print(selectedVideoId.videoId)
        self.performSegue(withIdentifier: "youTubeSegue", sender: selectedVideoId)
//           selectedIndex = indexPath.row
//           tableView.reloadData()
           
//           //        self.startAnimatePlayer()
//           selectedSong = favoriteAlbum[indexPath.row].previewUrl!
//           self.containerViewController.isHidden = false
//
//           UserDefaults.standard.set(selectedCell.artist, forKey: "artist")
//           UserDefaults.standard.set(selectedCell.title, forKey: "title")
//           UserDefaults.standard.set(selectedCell.artworkURL, forKey: "image")
//           UserDefaults.standard.set(audioPlayer.volume, forKey: "volume")
//           NotificationCenter.default.post(name: Notification.Name("getValueFromSelectedRow"), object: nil)
//           let thickness: CGFloat = 3.0
//           let topBorder = CALayer()
//           topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.containerViewController.frame.size.width, height: thickness)
//           topBorder.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7027655291)
//           containerViewController.layer.addSublayer(topBorder)
       }
    
    
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "youTubeSegue" {
              let genreVC = segue.destination as! YouTubeViewController
                genreVC.genreTitle  = sender as? Video
            }
        }
    
}
