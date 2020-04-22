//
//  YouTubeViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/18/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import YouTubePlayer
import AVFoundation
import AVKit
import WebKit
import CoreData
class YouTubeViewController: UIViewController, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var genreTitle: Video?
    var genre: GenreModel?
    var youTubeVideoWebView: WKWebView!
    var getYouTubeData  = YouTubeVideoConnection()
    var videoArray = [Video]()
    
    var entityName = String()
    
    @IBOutlet weak var selectedyouTubeVideoTableView: UITableView!
    
    
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
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        youTubeVideoWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350), configuration: webConfiguration)
        self.view.addSubview(youTubeVideoWebView)
        
        loadYouTubeVideoUrl()
        
        selectedyouTubeVideoTableView.delegate = self
        selectedyouTubeVideoTableView.dataSource = self
        if isEmpty{
            self.getYouTubeData.getFeedVideos(genreType: self.genreTitle!.genreTitle, selectedViewController: self) { (loadVideolist, error) in
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
                            let channelId =  self.videoArray[songIndex].channelId
                            let genreTitle = self.videoArray[songIndex].genreTitle
                            
                            print(genreTitle)
                            
                            
                            self.saveItems(title: title, description: description, image: image, videoId: videoId, playlistId: playlistId,genreTitle: self.genreTitle!.genreTitle, channelId: channelId)
                            
                        }
                        self.selectedyouTubeVideoTableView.reloadData()
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
                        self.selectedyouTubeVideoTableView.reloadData()
                    }
                }
            }
            
        }
    }
    
    
    
    func saveItems(title:String,description:String,image:String,videoId:String,playlistId:String,genreTitle: String, channelId: String) {
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
        newEntity.setValue(channelId, forKey: "channelId")
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
                let channelId = data.value(forKey: "channelId") as! String
                let fetchedVideoList = Video(videoId: videoId, videoTitle: title, videoDescription: songDescription, videoPlaylistId: playlistId, videoImageUrl: image, channelId:channelId)
                loadVideoList(fetchedVideoList,nil)
            }
            
        } catch {
            loadVideoList(nil,error)
            print("Failed")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "youTubeCell", for: indexPath) as? YouTubeTableViewCell {
            cell.configureGenreCell(videoArray[indexPath.row])
            print(videoArray[indexPath.row].channelId)
            return cell
        }else {
            return YouTubeTableViewCell()
        }
    }
    
    
    func loadYouTubeVideoUrl(){
        let html =
            "<html>" +
                "<body style='margin: 0;'>" +
                "<script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>" +
                "<script type='text/javascript'> " +
                "   function onYouTubeIframeAPIReady() {" +
                "      ytplayer = new YT.Player('playerId',{events:{'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange}}) " +
                "   } " +
                "   function onPlayerReady(a) {" +
                "       window.location = 'br.com.tntstudios.youtubeplayer://state=6'; " +
                "   }" +
                "   function onPlayerStateChange(d) {" +
                "       window.location = 'br.com.tntstudios.youtubeplayer://state=' + d.data; " +
                "   }" +
                "</script>" +
                "<div style='justify-content: center; align-items: center; display: flex; height: 100%;'>" +
                "<iframe id='playerId' type='text/html' width='100%' height='100%' src='https://www.youtube.com/embed/\(genreTitle!.videoId)?" +
                "enablejsapi=1&rel=0&playsinline=1&autoplay=0&showinfo=0&modestbranding=1' frameborder='0'>" +
                "</div>" +
                "</body>" +
        "</html>"
        youTubeVideoWebView.loadHTMLString(html, baseURL: URL(string: "http://www.youtube.com"))
    }
}
