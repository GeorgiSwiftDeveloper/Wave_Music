//
//  ActivityIndicator.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 7/25/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import  UIKit

class ActivityIndecator {
    
    
    static var activitySharedInstace =  ActivityIndecator()
    
    
    
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    let activityLabelView = UILabel()
    
    
    func activityIndecator(_ view: UIView, _ tableView: UITableView) {
        activityIndicatorView.frame = CGRect(x: view.frame.width / 2 - 20, y: -100, width: 50, height: 50)
        activityLabelView.frame = CGRect(x: view.frame.width / 2 - 85, y: -60, width: 200, height: 50)
        activityLabelView.text  =  "Uploading music information..."
        activityLabelView.font = UIFont.init(name: "Verdana", size: 12)
        activityIndicatorView.color = #colorLiteral(red: 0.06852825731, green: 0.05823112279, blue: 0.1604561806, alpha: 0.8180118865)
        activityLabelView.textColor = UIColor.lightGray
        tableView.addSubview(activityLabelView)
        tableView.addSubview(activityIndicatorView)
    }
    
    
     
}
