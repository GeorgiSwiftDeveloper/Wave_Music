//
//  SelectedSettingsViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 9/11/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class SelectedSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var timerPickerView = UIDatePicker()
    var darkModeSwitchButton = UISwitch()
    
    
    
    let tableView: UITableView = UITableView()
    var selectedSettingsTitle:String?
    var selectedSettingsIndex: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let selectedTitle = selectedSettingsTitle{
            self.navigationItem.title =  selectedTitle
        }
        setupTableView()
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: selectedSettingsCellIdentifier)
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections: Int?
        switch selectedSettingsIndex {
        case 6:
            numberOfSections =  AskQuestionServer.instance.getquestionList().count
        default:
            numberOfSections = 1
        }
        
        return numberOfSections!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = Int()
        switch selectedSettingsIndex {
        case 0:
            numberOfRowsInSection = 4
        case 1:
            numberOfRowsInSection = 2
        case 2:
            numberOfRowsInSection = 1
        case 3:
            numberOfRowsInSection = 4
        case 4:
            numberOfRowsInSection = 1
        case 5:
            numberOfRowsInSection = 1
        case 6:
            numberOfRowsInSection = AskQuestionServer.instance.getquestionList()[section].questionDesc!.count
        case 7:
            numberOfRowsInSection = 3
        case 8:
            numberOfRowsInSection = 4
        case 9:
            numberOfRowsInSection = 4
        default:
            break
        }
        return numberOfRowsInSection
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: selectedSettingsCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.white
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        switch selectedSettingsIndex {
        case 0:
            
            break
        case 1:
            tableView.isScrollEnabled = false
            switch indexPath.row {
            case 0:
                timerPickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220)
                timerPickerView.backgroundColor = UIColor.white
                timerPickerView.datePickerMode = UIDatePicker.Mode.countDownTimer
                cell.addSubview(timerPickerView)
            default:
                cell.textLabel?.text = "Start"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor.red
                cell.separatorInset = .zero
                
            }
        case 2:
            cell.textLabel?.text = "Dark Mode"
            cell.addSubview(darkModeSwitchButton)
            darkModeSwitchButton.pinDarkModeUISwitchConstraint(to: cell)
            break
        case 5:
            
            
            break
        case 6:
            
            cell.textLabel?.text = AskQuestionServer.instance.getquestionList()[indexPath.section].questionDesc?[indexPath.row]
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            
        case 7:
           break
        case 9:
            break
            
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        view.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana-Bold", size: 15)!
        header.textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightForHeaderInSection: CGFloat?
        switch selectedSettingsIndex {
        case 6:
            heightForHeaderInSection =  45.0
        default:
            heightForHeaderInSection = 45.0
        }
        return heightForHeaderInSection!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleForHeaderInSection: String?
        switch selectedSettingsIndex {
        case 6:
            titleForHeaderInSection =  AskQuestionServer.instance.getquestionList()[section].sectionTitle
        default:
            titleForHeaderInSection = ""
        }
        return titleForHeaderInSection!
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRowAtIndex = CGFloat()
        switch selectedSettingsIndex {
        case 1:
            if indexPath.row == 0 {
                heightForRowAtIndex = 220.0
            }else{
                heightForRowAtIndex = 50
            }
        default:
            heightForRowAtIndex = 65
        }
        
        return heightForRowAtIndex
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch selectedSettingsIndex {
        case 6:
            switch (indexPath.section, indexPath.row) {
            case (0,0):
                SettingsDetailView.sharedSettingsDetail.showAlertView(title: AskQuestionServer.instance.getquestionList()[indexPath.section].sectionTitle!, message: "Wave does not allow caching or downloading due to YouTube restrictions", actionTitle: "OK", view: self)
            case (1,0):
                SettingsDetailView.sharedSettingsDetail.showAlertView(title: AskQuestionServer.instance.getquestionList()[indexPath.section].sectionTitle!, message: "You can add tracks to your playlist by taping + button on the right side of the playlist", actionTitle: "OK", view: self)
            case (1,1):
                SettingsDetailView.sharedSettingsDetail.showAlertView(title: AskQuestionServer.instance.getquestionList()[indexPath.section].sectionTitle!, message: "You can create a new playlist by visiting the Playlist tab and tap 'Create New Playlist'", actionTitle: "OK", view: self)
            case (1,2):
                SettingsDetailView.sharedSettingsDetail.showAlertView(title: AskQuestionServer.instance.getquestionList()[indexPath.section].sectionTitle!, message: "You can delete a playlist by swiping to the left side then tapping 'Delete Playlist'", actionTitle: "OK", view: self)
            case (2,0):
                SettingsDetailView.sharedSettingsDetail.showAlertView(title: AskQuestionServer.instance.getquestionList()[indexPath.section].sectionTitle!, message: "You can search or new tracks by tapping the Seatch tap then tapping the search bar at the top o the screen", actionTitle: "OK", view: self)
            case (3,0):
                SettingsDetailView.sharedSettingsDetail.showAlertView(title: AskQuestionServer.instance.getquestionList()[indexPath.section].sectionTitle!, message: "You can delete tracks by swiping to the left then tap 'Delete'. Note that some playlist do not allow tracks to be deleted, such as the Recently Added playlist.", actionTitle: "OK", view: self)
            case (3,1):
                SettingsDetailView.sharedSettingsDetail.showAlertView(title: AskQuestionServer.instance.getquestionList()[indexPath.section].sectionTitle!, message: "You can edit track inoramtion by swiipiing to the left on a track and then tapping 'Edit'", actionTitle: "OK", view: self)
            default:
                break
            }
        default:
            break
        }
    }
    
}
