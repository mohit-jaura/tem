//
//  ActivityModel.swift
//  TemApp
//
//  Created by Harpreet_kaur on 11/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
class UserActivity : Codable {
    var id : String?
    var name : String?
    var image : String?
    var duration : String?
    var distance : Double?
    var calories : Double?
    var steps : Double?
    var heartRate: Double?
    var type : Int?
    var createdAt:Date?
    var selectedActivityType: Int?
    var origin : String?
    var rating : Int?
    var timeSpent: Double?
//    var distanceCovered: Double?
    var startTimestamp: Double?
    var endTimestamp: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case image
        case duration
        case calories
        case steps
        case type = "activityType"
        case createdAt
        
        case timeSpent
        case distance = "distanceCovered"
        case selectedActivityType
        case startTimestamp = "startDate"
        case endTimestamp = "endDate"
        case origin
    }
}


public struct CustomDefaults {
    static let saveEventActivity = UserDefaults.standard
    static let eventDates = UserDefaults.standard
    static let eventDistByDate = UserDefaults.standard

}
enum ActivityMetric : Int {
    case distance = 1
    case duration = 2
    case none = 3
    
    var title:String {
        switch self {
        case .distance:
            return "Distance"
        case .duration:
            return "Duration"
        case .none:
            return "Open"//"None"
        }
    }
}

enum ActivityFields {
    case activity
    case metric
    case metricValue
}
struct ExternalActivityTypes: Codable {
    let GoogleFit: String
    let HealthKit: String
}

struct ActivityCategory: Codable{

    var name: String
    var type: [ActivityData]
    var categoryType: Int
    var selected:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case categoryType = "category_type"
        case name = "category_name"
        case type
    }
}
// MARK: Class.
// MARK: -Activity Data.
public enum ActivityStatus:Int,Codable, Equatable{
    case NotStart = 0
    case Started = 1
    case Completed = 2
    case Skip = 5
    
    public init(from decoder: Decoder) throws {
            guard let rawValue = try? decoder.singleValueContainer().decode(Int.self) else {
                self = .NotStart
                return
            }
            self = ActivityStatus(rawValue: rawValue) ?? .NotStart
        }
}
struct ActivityData : Codable {
    var id : Int?
    var selected:Bool = false
    var eventactivityid:String?
    var name : String?
    var selectedActivityType: Int? //this is the type of the activity selected. it would be either distance or duration
    var activityType:Int? //this is the activity goal. It can be distance, duration and none(Open)
    var image:String?
    var isMandatory:Int?
    var activityProgressId:String?
    var metValue: Double?
    var calories:Double?
    var status:Int?
    var distanceCovered:Double?
    var timeSpent:Double?
    var steps:Double?
    var timeLimit:Int?
    var externalTypes: ExternalActivityTypes?
    var activityStatus:ActivityStatus? = .NotStart
    var filterSelected: Bool? = false //not decodable and encodable
    var isBinary: Int?   // this type of activities  doest not contain distance and time. It will only logged in the app. // 1 for true and 0 for false
    var activity_id: String?
    var mainActivityId:String?
    
    enum CodingKeys: String, CodingKey {
        case  activity_id = "_id"
        case isBinary
        case id
        case mainActivityId
        case name
        case activityType
        case image
        case isMandatory = "isMandatory"
        case filterSelected
        case activityStatus
        case steps = "steps"
        case timeLimit = "time"
        case status = "status"
        case timeSpent = "timeSpent"
        case calories = "calories"
        case distanceCovered = "distanceCovered"
        case activityProgressId
        case metValue = "met"
        case eventactivityid = "eventactivityid"
        case selectedActivityType = "selectedActivityType"
        case externalTypes
    }
    
    
    ///save user to user defaults
    func saveEncodedInformation(_ eventID:String? = nil) {
        let encoder = JSONEncoder()
        let defaultKey = eventID != nil ? eventID ?? "" : DefaultKey.userActivityData.rawValue

        if let encodedData = try? encoder.encode(self) {
            UserDefaults.standard.set(encodedData, forKey: defaultKey)
            UserDefaults.standard.synchronize()
        }
    }
    func saveActivity(_ eventID:String?) {
        guard let eventID = eventID else {return}

        let encoder = JSONEncoder()

        if let encodedData = try? encoder.encode(self) {
            CustomDefaults.saveEventActivity.set(encodedData, forKey: eventID)
            CustomDefaults.saveEventActivity.synchronize()
        }

    }

    static func removeEventActivity(eventID:String?) {
        guard let eventID = eventID else {
            return
        }
        CustomDefaults.saveEventActivity.removeObject(forKey: eventID)
        CustomDefaults.saveEventActivity.synchronize()
    }
    
    ///get the saved user information
    static func currentActivityInfo(_ eventID:String? = nil) -> ActivityData? {
        let defaultKey = eventID != nil ? eventID ?? "" : DefaultKey.userActivityData.rawValue
        
        if let savedUser = UserDefaults.standard.value(forKey: defaultKey) as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(ActivityData.self, from: savedUser) {
                return decodedData
            }
        }
        return nil
    }
    static func getCurrentActivity(_ eventID:String? = nil) -> ActivityData? {
        guard let eventID = eventID else { return nil }
        
        if let savedUser = CustomDefaults.saveEventActivity.value(forKey: eventID) as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(ActivityData.self, from: savedUser) {
                return decodedData
            }
        }
        return nil
    }
}

class CombinedActivity: Codable {
    var activityData: ActivityProgressData? //this will contain the information about the activity performed
    var duration : Double?
    var distance : Double?
    var calories : Double?
    var steps : Double?
    var heartRate: Double?
    
    func saveEncodedInformation() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(self) {
            Defaults.shared.set(value: encodedData, forKey: .combinedActivities)
        }
    }
    
    static func currentActivityInfo() -> [CombinedActivity]? {
        if let data = Defaults.shared.get(forKey: .combinedActivities) as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([CombinedActivity].self, from: data) {
                return decodedData
            }
        }
        return nil
    }
}

// MARK: -Metric Value Data.
class MetricValue : Codable {
    var id : Int?
    var value : Double?
    var unit:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case value
        case unit
    }
}


enum ActivityStateStatus : Int {
    case completed = 2
    case started = 1
    case skip = 5
    case pending = 3
}


// MARK: Class.
// MARK: -Activity Data.
class ActivityProgressData : Codable {
    var activity : ActivityData?
    var elapsed : Double?
    var startTime:Double?
    var time:Double?
    var totalTime:Double?
    var isPlaying:Bool?
    var createdAt:Date?
    var duration:String?
    var currentPeriodStartingDate:Date?
    var isScheduled: Int?
    var distance : Double = 0
    var distanceFromCounterpart: Double = 0
    var categoryType: Int = 1
    
    ///save user to user defaults
    func saveEncodedInformation() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(self) {
            self.activity?.saveEncodedInformation()
            UserDefaults.standard.set(encodedData, forKey: DefaultKey.userActivityInProgress.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    func saveProgressData() {
        
    }
    
    ///get the saved user information
    static func currentActivityInfo() -> ActivityProgressData? {
        if let savedUser = UserDefaults.standard.value(forKey: DefaultKey.userActivityInProgress.rawValue) as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(ActivityProgressData.self, from: savedUser) {
                decodedData.activity = ActivityData.currentActivityInfo()
                return decodedData
            }
        }
        return nil
    }
}
