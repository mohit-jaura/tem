//
//  PlaceDetailModal.swift
//  VIZU
//
//  Created by shubam on 28/09/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation
enum CustomBool: Int, Codable {
    case no = 0
    case yes = 1
    
    func toggle() -> CustomBool {
        switch self {
        case .no:
            return .yes
        default:
            return .no
        }
    }
}

struct PlaceDetailModal {
    var id : String?
    var coordinates : [Double]?
    var isOpen : Int?
    //let expiry_time : Int?
    //let dummy : Int?
    //let timezone : String?
    //let timings : [[Timings]]?
    //let cuisine : [String]?
    let url : String?
    var phone : String?
    //let price_tier : Int?
    var address : [String]?
    //let city : String?
    //let country : [String]?
    var description : String?
    var images : [String]?
    //let yelpRating : Double?
    var title : String?
    //let reference_id : String?
    //let type : [Int]?
    //let distance : Double?
    var is_favourite : CustomBool?
    var is_notifyme_enable : Int?
//    var is_open : CustomBool?
    var questions: [Question]?
    var days:Days?
    var forsqaureRating:Double?
    var story : String?
    var myStory : String?
    var is_user_checked_in : Int?
    var checkincount : Int?
    
    
    //custom initializer
    init(fromJson json: Parameters) {
        self.id = json["_id"] as? String
        self.phone = json["phone"] as? String ?? ""
        self.url = json["url"] as? String ?? ""
        self.description = json["description"] as? String
        self.forsqaureRating = json["rating"] as? Double ?? 0.0
        self.title = json["title"] as? String
        self.story = json["story"] as? String
        self.myStory = json["my_story"] as? String
        self.isOpen = json["is_open"] as? Int
        if let questionsSuperData = json["questions"] as? [Parameters] {
            self.questions = [Question]()
            for questionData in questionsSuperData {
                if let question = questionData["question"] as? Parameters {
                    self.questions?.append(Question(fromDict: question))
                }
            }
        }
        if let checkIncount = json["checkincount"] as? Int{
            self.checkincount = checkIncount
        }
        
        if let isNotifyme = json["is_notifyme_enable"] as? Int{
            self.is_notifyme_enable = isNotifyme
        }
        if let isFavourite = json["is_favourite"] as? Int,
            let isFavCustomValue = CustomBool(rawValue: isFavourite) {
            self.is_favourite = isFavCustomValue
        }
        
        if let isUserCheckIn = json["is_user_checked_in"] as? Int{
            self.is_user_checked_in = isUserCheckIn
        }
        
        if let images = json["image"] as? [String] {
            self.images = [String]()
            self.images = images
        }
        if let address = json["address"] as? [String] {
            self.address = [String]()
            self.address = address
        }
        if let coordinates = json["coordinates"] as? [Double] {
            self.coordinates = [Double]()
            self.coordinates = coordinates
        }
        
        self.days = Days(dict: json)
     
        
    }
}

struct Days {
    
    var daysDict:[Int:[Timings]] = [Int:[Timings]]()
    
    init(dict:Parameters) {
        
        if let timings = dict["timings"] as? [[Parameters]] {
            
            for (index,timing) in timings.enumerated() {
                if timing.count > 0 {
                    var arrTiming:[Timings] = [Timings]()
                    for value  in timing {
                        let objTiming = Timings(dict: value)
                        arrTiming.append(objTiming)
                    }
                    
                    daysDict[index] = arrTiming
                }
            }
        }
    }
    
}

struct Timings {
    
    let start : String?
    let end : String?
    
    init(dict:Parameters) {
        
        self.start = dict["start"] as? String
        self.end = dict["end"] as? String
    }
}

/// Questions model
class Question: SerializableArray {
    var id: String?
    var subject: String?
    var type: Int?
    var answers: [Answer]?
    var category: Int?
    var isSelected = false
    var isOpen = false
    //custom init
    required init(fromDict data: Parameters) {
        self.id = data["_id"] as? String
        self.subject = data["subject"] as? String
        self.category = data["category"] as? Int
        self.type = data["type"] as? Int
        if let answers = data["answer"] as? [Parameters] {
            self.answers = [Answer]()
            self.answers = answers.toModelArray()
        }
    }
}

struct Answer: SerializableArray {
    
    //custom init
    init?(fromDict dict: Parameters) {
        self.id = dict["id"] as? String
        self.title = dict["answer"] as? String
        self.count = dict["count"] as? Int ?? 0
        self.type = dict["type"] as? Int ?? 0
        self.duration = dict["duration"] as? Double ?? 0
    }
    
    var id: String?
    var title: String?
    var count: Int?
    var type:Int?
    var duration:Double?
}
