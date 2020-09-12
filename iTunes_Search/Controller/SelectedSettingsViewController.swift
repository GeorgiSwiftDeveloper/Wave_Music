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
            numberOfRowsInSection = 3
        case 7:
            numberOfRowsInSection = 2
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
        switch selectedSettingsIndex {
        case 0:
            
            break
        case 1:
            switch indexPath.row {
            case 0:
                cell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                timerPickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220)
                timerPickerView.backgroundColor = UIColor.white
                timerPickerView.datePickerMode = UIDatePicker.Mode.countDownTimer
                cell.addSubview(timerPickerView)
            default:
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
            
            break
            
        case 7:
            
            break
        case 9:
            break
            
        default:
            break
        }
        return cell
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
        let selectedCell = self.tableView.cellForRow(at: tableView.indexPathForSelectedRow!)
        selectedCell?.selectionStyle  = .none
    }
    
}
