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

  
    
    var delegatee: CancelContainerViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegatee?.cancelContainerVeiw(cancel: true)
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
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
