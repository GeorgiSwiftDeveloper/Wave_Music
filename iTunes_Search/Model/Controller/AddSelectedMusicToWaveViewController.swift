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
        backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigationItem.setLeftBarButton(backButton, animated: false)
        
        self.playlistTableView.delegate = self
        self.playlistTableView.dataSource = self
        
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


}

extension AddSelectedMusicToWaveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "addToLibraryCell", for: indexPath) as? MyLibraryTableViewCell {
            cell.titleLabel.text = "My Library"
            cell.imageLabel.image = UIImage(systemName: "tray.and.arrow.down.fill")
                   return cell
               }else {
                   return MyLibraryTableViewCell()
               }
    }
    
    
}
