//
//  DesignView.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 7/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import  UIKit


@IBDesignable
class DesignView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var shadowColor : UIColor? = UIColor.black
    @IBInspectable var shadowOfSetWidth: Int = 0
    @IBInspectable var shadowOfSetHeight: Int =  1
    
    @IBInspectable var shadowOpacity: Float = 0.2
    
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOfSetWidth, height: shadowOfSetHeight)
        
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = shadowOpacity
    }
    
    
}
