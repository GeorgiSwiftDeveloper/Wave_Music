//
//  WelcomeViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/27/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    var countryArray = ["United States","Armenia","Argentina","Austria","Australia","Belgium","Bulgaria","Brazil","Canada","Germany","Spain","France","Georgia","India","Italy","Poland","Russia","Ukraine"]
    
    var valueSelected = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
              pickerView.delegate  = self
              pickerView.dataSource = self
              updateUI()
    }
    
    func updateUI(){
          self.pickerView.setValue(UIColor.white, forKeyPath: "textColor")
          nextButton.layer.cornerRadius = 8
//          nextButton.layer.borderWidth = 2
          nextButton.layer.masksToBounds = false
          nextButton.layer.shadowColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
          nextButton.layer.shadowOpacity = 3
          nextButton.layer.shadowPath = UIBezierPath(rect: nextButton.bounds).cgPath
          nextButton.layer.shadowRadius = 8
          nextButton.layer.shadowOffset = .zero
          nextButton.clipsToBounds = true
      }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    
    
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return countryArray.count
           
           
       }
       
       
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return countryArray[row]
       }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.valueSelected = countryArray[row] as String
     }
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: countryArray[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])

        return myTitle
    }
    

    @IBAction func nextButtonAction(_ sender: UIButton) {
        if let tabbar = (storyboard?.instantiateViewController(withIdentifier: "myTabbarControllerID") as? UITabBarController) {
            tabbar.modalPresentationStyle = .fullScreen
             UserDefaults.standard.set(valueSelected, forKey: "countrySelected")
             self.present(tabbar, animated: true, completion: nil)
            self.view.removeFromSuperview()
         }
    }
    

}
