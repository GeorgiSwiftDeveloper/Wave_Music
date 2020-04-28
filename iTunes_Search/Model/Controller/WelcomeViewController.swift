//
//  WelcomeViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/27/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
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
    

    @IBAction func nextButtonAction(_ sender: UIButton) {
        if let tabbar = (storyboard?.instantiateViewController(withIdentifier: "myTabbarControllerID") as? UITabBarController) {
            tabbar.modalPresentationStyle = .fullScreen
             self.present(tabbar, animated: true, completion: nil)
         }
    }
    

}
