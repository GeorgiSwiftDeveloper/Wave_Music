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
                    
                    let returnRadioList = RadioModel(name: name, streamURL: streamURL, imageURL: imageURL, desc: desc, longDesc: longDesc)
                    listOfRadioStation.append(returnRadioList)
                }
                loadStationList(listOfRadioStation,nil)
            } catch {
                loadStationList(nil,error)
            }
        }
    }
    
}
