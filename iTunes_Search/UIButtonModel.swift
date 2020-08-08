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
        self.setImage(UIImage(named: image), for: .normal)
    }
    
}

class AddToFavoriteButton: MusicPlayerButton {
    
    convenience init(image: String, text: String) {
        self.init(frame: .zero)
        configureMusicAddButton(image: image,text: text)
    }
    
     func configureMusicAddButton(image: String, text: String) {
        setImage(UIImage(systemName: image), for: .normal)
        updateUI(text: text )
    }
    
    func updateUI(text: String) {
        imageView?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView?.clipsToBounds = true
        setTitle(text, for: .normal)
        titleLabel?.font = UIFont(name: "Helvetica Bold", size: 11)
    }
    
}


class SharePlayedMusicButton: AddToFavoriteButton {
    
    override func configureMusicAddButton(image: String,text: String) {
        setImage(UIImage(systemName: image), for: .normal)
        updateUI(text: text)
    }
    
}
