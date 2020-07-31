//
//  ChooseCountryViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/28/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class ChooseCountryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var nextButton: UIButton!
    var countryArrray =  [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countryArrray.append(name)
        }
        
        pickerView.delegate  = self
        pickerView.dataSource = self
        updateUI()
        
  
    }
    
    func updateUI(){
        self.pickerView.setValue(UIColor.white, forKeyPath: "textColor")
        nextButton.layer.cornerRadius = 5
        nextButton.layer.borderWidth = 0.75
        nextButton.layer.masksToBounds = false
        nextButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        nextButton.layer.shadowOpacity = 2
        nextButton.layer.shadowPath = UIBezierPath(rect: nextButton.bounds).cgPath
        nextButton.layer.shadowRadius = 6
        nextButton.layer.shadowOffset = .zero
        nextButton.clipsToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          .lightContent
      }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArrray.count
        
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArrray[row]
    }
    
    
}
