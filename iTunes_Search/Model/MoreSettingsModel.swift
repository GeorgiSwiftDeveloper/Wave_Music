//
//  MoreSettingsModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 9/11/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation

class MoreModel: NSObject {
    var settingsImage: String
    var settingsName: String
    
    
    init(settingsImage: String, settingsName:String) {
        self.settingsImage = settingsImage
        self.settingsName = settingsName
    }
}


let settingsArray = [
    MoreModel(settingsImage: "arrow.counterclockwise.icloud.fill", settingsName: "Backup and Recover"),
    MoreModel(settingsImage: "alarm.fill", settingsName: "Sleep Timer"),
    MoreModel(settingsImage: "lightbulb.fill", settingsName: "Dark Mode"),
    MoreModel(settingsImage: "play.rectangle.fill", settingsName: "YouTube Login"),
    MoreModel(settingsImage: "camera.fill", settingsName: "Wave on Instagram"),
    MoreModel(settingsImage: "questionmark.square.fill", settingsName: "Help & Support"),
    MoreModel(settingsImage: "bubble.left.and.bubble.right.fill", settingsName: "Send Feedback"),
    MoreModel(settingsImage: "message.fill", settingsName: "Ask Question"),
    MoreModel(settingsImage: "person.2.fill", settingsName: "Contact Us"),
    MoreModel(settingsImage: "dollarsign.square.fill", settingsName: "Donation"),
]

func getSettingsListArray() -> [MoreModel] {
    return settingsArray
}



class AskQuestion: NSObject {
    var sectionTitle: String?
    var questionDesc: [String]?
    
    init(sectionTitle:String, questionDesc:[String]) {
        self.sectionTitle = sectionTitle
        self.questionDesc = questionDesc
    }
}


class AskQuestionServer {
    static let instance = AskQuestionServer()
    var a = [AskQuestion]()
    
    
    let questionArray = [
        AskQuestion(sectionTitle: "Downloading", questionDesc: ["Can I download or cache my music"]),
        AskQuestion(sectionTitle: "Paylists", questionDesc: ["How can I add track to my playlist","How can I create a news playlist","How can I delete a playlist"]),
        AskQuestion(sectionTitle: "Search", questionDesc: ["How can I search for new track"]),
        AskQuestion(sectionTitle: "Tracks", questionDesc: ["How can I delete tracks","How can I edit a track name or artist"])
    ]
    
    func getquestionList() -> [AskQuestion] {
        return questionArray
    }
}
