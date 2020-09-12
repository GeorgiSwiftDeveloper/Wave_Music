//
//  ShowSettingsDetailView.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 9/11/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import UIKit
import SafariServices


class SettingsDetailView {
    
    static let sharedSettingsDetail  = SettingsDetailView()
    
    func showAlertView(message: String, actionTitle: String,view: UIViewController) {
        let alert = UIAlertController(title: "Contact us", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        
        alert.addAction(action)
        view.present(alert, animated: true, completion: nil)
    }
    
    func showSafariVC(for url: String,view: UIViewController){
        guard let url = URL(string: url) else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        view.present(safariVC, animated: true, completion: nil)
    }
    
    func openInstagramApp(username: String) {
        let Username =  username // Your Instagram Username here
        let appURL = URL(string: "instagram://user?username=\(Username)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            let webURL = URL(string: "https://instagram.com/\(Username)")!
            application.open(webURL)
        }
    }
}
