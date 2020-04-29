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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
           return countryArray.count
           
           
       }
       
       
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return countryArray[row]
       }
    

    @IBAction func nextButtonAction(_ sender: UIButton) {
        if let tabbar = (storyboard?.instantiateViewController(withIdentifier: "myTabbarControllerID") as? UITabBarController) {
            tabbar.modalPresentationStyle = .fullScreen
             self.present(tabbar, animated: true, completion: nil)
         }
    }
    

}
