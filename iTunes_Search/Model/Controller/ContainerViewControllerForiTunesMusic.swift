//
//  ContainerViewControllerForiTunesMusic.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/13/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

protocol CancelContainerViewDelegate {
    func cancelContainerVeiw(cancel: Bool)
}
class ContainerViewControllerForiTunesMusic: UIViewController {

  
    @IBOutlet weak var selectedMusicImageView: UIImageView!
    @IBOutlet weak var selectedSingerName: UILabel!
    @IBOutlet weak var selectedSongName: UILabel!
    
var filterListVC: iTunesMusicViewController!
    
    var delegateCon: CancelContainerViewDelegate?
    
    var s = String()
    var se = String()
    var i = UIImage()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
          NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("getValue"), object: nil)
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
         let name = UserDefaults.standard.string(forKey: "artist")
          let song = UserDefaults.standard.string(forKey: "song")
          let image = UserDefaults.standard.string(forKey: "image")
         
        self.selectedSingerName.text = name
        self.selectedSongName.text = song
        if image != "" {
                 self.selectedMusicImageView.image = UIImage(data: NSData(contentsOf: URL(string:image!)!)! as Data)
                 }
//        self.selectedMusicImageView.image = image as! UIImage
     }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegateCon?.cancelContainerVeiw(cancel: true)
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
