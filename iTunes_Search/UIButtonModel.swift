//
//  UIButtonModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 8/7/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import UIKit


class MusicPlayerButton: UIButton {

    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
     fatalError("init has not been imlemented")
    }
    
    
    convenience init(image: String) {
        self.init(frame: .zero)
        configureMusicPlayerButton(image: image)
    }
    
    
    private func configureMusicPlayerButton(image: String) {
        self.setImage(UIImage(named: image), for: .normal)
    }
}
