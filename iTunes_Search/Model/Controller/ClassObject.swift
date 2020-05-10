//
//  ClassObject.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/10/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
protocol WriteValueBackDelegate:class {
    func writeValueBack(value: Bool)
}
class ClassObject: NSObject {
     weak var delegatea: WriteValueBackDelegate?
    
    override init() {
        delegatea?.writeValueBack(value: true)
    }
}
