//
//  RadioConnection.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import UIKit


class RadioConnection {
    
    func readJSONFromFile(fileName: String, loadFunctionComplete: @escaping (_ returnStockValue: RadioModel?, _ error: Error?) -> ())
    {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json"){
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
//                json = try? JSONSerialization.jsonObject(with: data)
                let  jsson = try JSONDecoder().decode(RadioModel.self, from: data)
                print(jsson.longDesc)
                    loadFunctionComplete(jsson,nil)
            } catch {
                // Handle error here
                 loadFunctionComplete(nil,error)
            }
        }
    }
}
