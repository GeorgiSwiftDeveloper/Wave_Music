//
//  UITextFieldModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 8/7/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import UIKit

class MusicTextLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMesucLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been imlemented")
    }
    
    
    convenience init(textTitle: String, textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
        self.text = textTitle
    }
    
    
    private func configureMesucLabel() {
        numberOfLines = 0
        font = UIFont(name: "Verdana-Bold", size: 12)
        textColor = .black
    }
}
