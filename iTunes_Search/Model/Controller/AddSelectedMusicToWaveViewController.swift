//
//  AddSelectedMusicToWaveViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/24/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

class AddSelectedMusicToWaveViewController: UIViewController {
    
    @IBOutlet weak var selectedMusicImageView: UIImageView!
    @IBOutlet weak var selectedMusicTitle: UILabel!
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    var selectedMusicData: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playlistTableView.delegate = self
        self.playlistTableView.dataSource = self
        customizeUI()
        let imageUrl = URL(string: selectedMusicData!.videoImageUrl)
        do{
            let data:NSData = try NSData(contentsOf: imageUrl!)
            selectedMusicImageView.image =  UIImage(data: data as Data)
            
        }catch{
            print("error")
        }
        self.selectedMusicTitle.text = selectedMusicData?.videoTitle
    }
    
    
    func customizeUI(){
        self.doneButton.isEnabled = true
        self.doneButton.alpha = 1;
        self.tabBarController?.tabBar.isHidden = true
        let backButton = UIBarButtonItem(title: "Cencel", style: .plain, target: self, action: #selector(goBackAction))
        backButton.image = UIImage(named: "")
        backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigationItem.setLeftBarButton(backButton, animated: false)
        doneButton.layer.cornerRadius = 9
        doneButton.layer.borderWidth = 2
        doneButton.layer.masksToBounds = false
        doneButton.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        doneButton.layer.shadowOpacity = 2
        doneButton.layer.shadowPath = UIBezierPath(rect: doneButton.bounds).cgPath
        doneButton.layer.shadowRadius = 6
        doneButton.layer.shadowOffset = .zero
        doneButton.clipsToBounds = true
    }
    
    @objc func goBackAction() {
        self.navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    
    
    @IBAction func addToMyLibrrary(_ sender: Any) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MiLibraryMusicData")
        let predicate = NSPredicate(format: "title == %@", selectedMusicData!.videoTitle as CVarArg)
        request.predicate = predicate
        request.fetchLimit = 1

        do{
            let count = try context?.count(for: request)
            if(count == 0){
            // no matching object
                let entity = NSEntityDescription.entity(forEntityName: "MiLibraryMusicData", in: context!)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                newEntity.setValue(selectedMusicData?.videoTitle, forKey: "title")
                newEntity.setValue(selectedMusicData?.videoImageUrl, forKey: "image")
                newEntity.setValue(selectedMusicData?.videoId, forKey: "videoId")
                
                try context?.save()
                           print("data has been saved ")
                           self.navigationController?.popViewController(animated: true)
                           self.tabBarController?.tabBar.isHidden = false
            }
            else{
            // at least one matching object exists
                let alert = UIAlertController(title: "Please check your Library", message: "This song is already exist in your library list", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    self.doneButton.isEnabled = false
                    self.doneButton.alpha = 0.75;
                }
                
                let libraryAction = UIAlertAction(title: "My Library", style: .default) { (action) in
                     self.navigationController?.popViewController(animated: true)
                     self.tabBarController?.selectedIndex = 0
                     self.tabBarController?.tabBar.isHidden = false
                }
                
                alert.addAction(action)
                alert.addAction(libraryAction)
                present(alert, animated: true, completion: nil)
                
            }
          }
        catch let error as NSError {
             print("Could not fetch \(error), \(error.userInfo)")
          }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexRow = tableView.indexPathForSelectedRow
        let selectedCell = self.playlistTableView.cellForRow(at: selectedIndexRow!) as! MyLibraryTableViewCell
        selectedCell.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        selectedCell.titleLabel.textColor = UIColor.white
        
    }
    
}
