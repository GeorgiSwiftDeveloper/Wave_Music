//
//  ReadDataFromStationJSON.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/6/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation

class ReadDataFromStationJSONList {
    func readStationJSONList(fileName: String?, loadStationList: @escaping(_ returnStationList: [RadioModel]?, _ returnError: Error? ) -> ()){
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
//            var stock = RadioModel(name: <#T##String#>, streamURL: <#T##String#>, imageURL: <#T##String#>, desc: <#T##String#>, longDesc: <#T##String#>)
            do {
                var listOfRadioStation = [RadioModel]()
                
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedRead)
                let radioJsonList = try JSONDecoder().decode(PlacesResponse.self, from: data)
                for i in 0..<radioJsonList.station.count{
                    let name = radioJsonList.station[i].name
                    let streamURL = radioJsonList.station[i].streamURL
                    let imageURL = radioJsonList.station[i].imageURL
                    let desc = radioJsonList.station[i].desc
                    let longDesc = radioJsonList.station[i].longDesc
                    
                     var returnRadioList = RadioModel(name: name, streamURL: streamURL, imageURL: imageURL, desc: desc, longDesc: longDesc)
                    listOfRadioStation.append(returnRadioList)
                }
//                print(radioJsonList.station[1].name)
                loadStationList(listOfRadioStation,nil)
            } catch {
                // Handle error here
                loadStationList(nil,error)
            }
        }
    }
    
}
