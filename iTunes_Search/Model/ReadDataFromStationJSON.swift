//
//  ReadDataFromStationJSON.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation

class ReadDataFromStationJSONList {
    func readStationJSONList(fileName: String?, loadStationList: @escaping(_ returnStationList: PlacesResponse?, _ returnError: Error? ) -> ()){
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedRead)
                let radioJsonList = try JSONDecoder().decode(PlacesResponse.self, from: data)

//                print(radioJsonList.station[1].name)
                loadStationList(radioJsonList,nil)
            } catch {
                // Handle error here
                loadStationList(nil,error)
            }
        }
    }
    
}
