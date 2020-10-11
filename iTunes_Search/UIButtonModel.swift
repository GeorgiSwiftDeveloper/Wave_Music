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
    
    
    func configureMusicPlayerButton(image: String) {
        self.setImage(UIImage(named: image)?.withTintColor(.black), for: .normal)
    }
    
}

class AddToFavoriteButton: MusicPlayerButton {
    
    convenience init(image: String, color: UIColor) {
        self.init(frame: .zero)
        configureMusicAddButton(image: image, color: color)
    }
    
    func configureMusicAddButton(image: String, color: UIColor) {
        setImage(UIImage(systemName: image)?.withTintColor(.black), for: .normal)
        updateUI()
    }
    
    func updateUI() {
        imageView?.tintColor = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
        imageView?.clipsToBounds = true
    }
    
}


//class SharePlayedMusicButton: AddToFavoriteButton {
//    
//    override func configureMusicAddButton(image: String) {
//        setImage(UIImage(systemName: image)?.withTintColor(.black), for: .normal)
//        updateUI()
//    }
//    
//}
