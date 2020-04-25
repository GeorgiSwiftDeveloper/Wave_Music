//
//  AddSelectedMusicToWaveViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/24/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class AddSelectedMusicToWaveViewController: UIViewController {

    @IBOutlet weak var selectedMusicImageView: UIImageView!
    @IBOutlet weak var selectedMusicTitle: UILabel!
    @IBOutlet weak var playlistTableView: UITableView!
    
    
    var selectedMusicImage = String()
    var selectedMusicLabel = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "Cencel", style: .plain, target: self, action: #selector(goBackAction))
        backButton.image = UIImage(named: "")
        navigationItem.setLeftBarButton(backButton, animated: false)
        let imageUrl = URL(string: selectedMusicImage)
              do{
                  let data:NSData = try NSData(contentsOf: imageUrl!)
                  selectedMusicImageView.image =  UIImage(data: data as Data)
                  
              }catch{
                  print("error")
              }
        self.selectedMusicTitle.text = selectedMusicLabel
        // Do any additional setup after loading the view.
    }
    
    @objc func goBackAction() {
        self.navigationController?.popViewController(animated: true)
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
