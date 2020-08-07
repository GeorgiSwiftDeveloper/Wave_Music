//
//  UISliderModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 8/7/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import  UIKit
 

class MusicVolumeSlider: UISlider {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMusicVolumeSlider()
    }
    
    required init?(coder: NSCoder) {fatalError("init has not been imlemented")}

    
    private func  configureMusicVolumeSlider() {
        minimumValue  = 0
        maximumValue = 100
        setValue(80, animated: true)
        isContinuous = true
        tintColor = UIColor.white
    }
}
