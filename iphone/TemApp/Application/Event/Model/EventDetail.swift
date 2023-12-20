//
//  EventDetail.swift
//  TemApp
//
//  Created by dhiraj on 16/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

struct EventRounds:Codable{
    var id: String?
    var roundName: String?
    var tasks: [EventRoundsTasks]?
    
    enum CodingKeys: String,CodingKey{
        case id = "_id"
        case roundName = "round_name"
        case tasks = "tasks"
    }

    func getRounds() -> Rounds{
        let tasks = tasks?.map({ eventTask in
            return Tasks(task_name: eventTask.taskName, file: eventTask.file, fileType: eventTask.fileType, taskId: eventTask.id)
        })
        let round = Rounds(tasks: tasks, round_name: roundName, roundId: id)
        return round
    }
}

struct EventRoundsTasks:Codable{
    var id: String?
    var taskName: String?
    var file: String?
    var fileType: Int?
    
    enum CodingKeys: String,CodingKey{
        case id = "_id"
        case taskName = "task_name"
        case file = "file"
        case fileType = "fileType"
    }
}

struct EventDetail: Codable {
    var programId: String?
    var programEventId: String?
    var isProgramEvent: Int? // 1 means event belongs to Program and 0 means normal event
    let totalCount: Int?
    let rootUpdatedFor: String?
    var id: String?
    let title: String?
    let description: String?
    let location: Locations?
    var members: [Members]?
    let userId: String?
    let sDateTime: String?
    let eDateTime: String?
    let reccurEvent: Int?
    let eventReminder: Bool?
    let acceptedCount: Int?
    let declinedCount: Int?
    let pendingCount: Int?
    var endsOn: EndsOnValue?
    let eventType: EventType?
    let startTime: String?
    let name: String?
    var showingDate: Date?
    let duration :String?
    var dateNumber = 0
    var isEditable: Int?
    var activityAddOn:[ActivityAddOns]?
    var visibility: EventVisibility?
    var isUserWaitingToJoin: Bool? = false
    var media: [SavedURls]?
    var members_add_number: Members_add_number?
    var rounds:[EventRounds]?
    var isPaid:Bool? // 0 is for false and 1 is for true
    var payableAmount: Int?
    let endTime: String?
    let endDate: ActivityDate?
    var startDate: ActivityDate?
    var isSameDayEvent:Bool?
    var currentRecurringDay: Int?
    var startsOn: String?
    
    var eventStartDate : Date {
            if let date = startDate?.date as? String {
                return getCombinedDateTime(date:date)
            } else {
                if let timestamp = startDate?.date as? Int{
                    return timestamp.timestampInMillisecondsToDate
                }
            }
            return Date()
    }
    var eventEndDate : Date {
            if let date = endDate?.date as? String {
                return  getCombinedDateTime(date:date)
            } else {
                if let timestamp = endDate?.date as? Int{
                    return timestamp.timestampInMillisecondsToDate
                }
            }
            return Date()
        }

    func getCombinedDateTime(date:String) -> Date{
        let dateFormatter = Utility.timeZoneDateFormatter(format: .utcDate, timeZone: deviceTimezone)
        let sDate = dateFormatter.date(from: date) ?? Date()
        return sDate
    }
    
    enum CodingKeys: String, CodingKey {
        case programId
        case programEventId
        case isProgramEvent
        case totalCount
        case id = "_id"
        case activityAddOn
        case duration
        case title
        case description
        case location
        case userId
        case sDateTime
        case eDateTime
        case reccurEvent
        case eventReminder
        case acceptedCount
        case declinedCount
        case pendingCount
        case endsOn
        case eventType
        case members
        case endDate
        case endTime
        case startDate
        case startTime
        case name
        case rootUpdatedFor
        case isEditable
        case visibility
        case isUserWaitingToJoin
        case media = "eventMedia"
        case members_add_number
        case rounds
        case isPaid
        case payableAmount
        case currentRecurringDay = "uniqueKey"
        case startsOn
    }
}

struct Members_add_number:Codable{
    var count:Int?
    var signupsheet:String?
    
    enum CodingKeys: String,CodingKey{
        case count,signupsheet
    }
}

enum EventType : Int, Codable, CaseIterable {
    case regular = 1
    case goals = 2
    case challenges = 3
    case signupSheet = 4
    
    static var supported: [EventType] = [.regular, .signupSheet]
    
    func getImages() -> (blue: UIImage, white: UIImage) {
        switch self {
        case .regular: return (#imageLiteral(resourceName: "actBig"), #imageLiteral(resourceName: "activityWhite"))
        case .challenges: return (#imageLiteral(resourceName: "challenges"), #imageLiteral(resourceName: "challengesWhite"))
        case .goals: return (#imageLiteral(resourceName: "goals"), #imageLiteral(resourceName: "goalsWhite"))
        case .signupSheet: if #available(iOS 13.0, *) {
            return (#imageLiteral(resourceName: "TaskStroke").withTintColor(.blue), #imageLiteral(resourceName: "TaskStroke").withTintColor(.white))
        } else {
            return (#imageLiteral(resourceName: "TaskStroke"), #imageLiteral(resourceName: "TaskStroke"))
        }
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .regular: return "Regular event"
        case .challenges: return "" // no support in creating events
        case .goals: return "" // no support in creating events
        case .signupSheet: return "Signup Sheet"
        }
    }
}

enum SignUpSheetType: Int, CaseIterable{
    case count = 0
    case unlimited = 1
    
    static var supported: [SignUpSheetType] = [.count, .unlimited]
    
    var title:String{
        switch self {
        case .count:
            return "Count"
        case .unlimited:
            return "Unlimited"
        }
    }
}

struct Locations : Codable {
    let lastUsedAt : String?
    let _id : String?
    let location : String?
    let lat : Double?
    let long : Double?
    
    enum CodingKeys: String, CodingKey {
        case lastUsedAt = "lastUsedAt"
        case _id = "_id"
        case location = "location"
        case lat = "lat"
        case long = "long"
    }
}

struct Members : Codable {
    let _id : String?
    let userId : String?
    let memberType : Int?
    let inviteAccepted : Int?
    let first_name : String?
    let last_name : String?
    let profile_pic : String?
    let memberId : String?
    
    var fullName: String { //not decodable
        if let first = first_name, let last = last_name {
            return first + " " + last
        }
        if last_name == nil {
            return first_name ?? ""
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case _id = "_id"
        case userId = "userId"
        case memberType = "memberType"
        case inviteAccepted = "inviteAccepted"
        case first_name = "first_name"
        case last_name = "last_name"
        case profile_pic = "profile_pic"
        case memberId = "id"
    }
}

enum EndsOnValue: Codable {
    case int(Int), string(String)
    
    init(from decoder: Decoder) throws {
        
        //Check each case
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        throw IdError.missingValue
    }
    
    enum IdError:Error { // If no case matched
        case missingValue
    }
    
    var any:Any{
        get{
            switch self {
            case .int(let value):
                return value
            case .string(let value):
                return value
            }
        }
    }
}

enum ActivityDate: Encodable, Decodable {
    case int(Int), string(String)
    
    init(from string: String) {
        self = .string(string)
    }
    
    init(from decoder: Decoder) throws {
        
        //Check each case
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        throw IdError.missingValue
    }

    enum IdError:Error { // If no case matched
        case missingValue
    }
    
    var date:Any{
        get{
            switch self {
            case .int(let value):
                return value
            case .string(let value):
                return value
            }
        }
    }
}

enum EventVisibility: String, Codable, CaseIterable {
    case personal = "private"
    case temates = "temates"
    case open = "public"
    
    var name: String {
        switch self {
        case .personal:
            return "Private"
        case .temates:
            return "Tēmates"
        case .open:
            return "Public"
        }
    }
}
