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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
          NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("getValueFromSelectedRow"), object: nil)
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        let name = UserDefaults.standard.string(forKey: "artist")
        let song = UserDefaults.standard.string(forKey: "title")
        let image = UserDefaults.standard.string(forKey: "image")
        
        self.selectedSingerName.text = name
        self.selectedSongName.text = song
        if image != "" {
            self.selectedMusicImageView.image = UIImage(data: NSData(contentsOf: URL(string:image!)!)! as Data)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegateCon?.cancelContainerVeiw(cancel: true)
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
    }
  

}
