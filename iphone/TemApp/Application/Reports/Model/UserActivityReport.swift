//
//  UserActivityReport.swift
//  TemApp
//
//  Created by shilpa on 24/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

/// This holds all the activities report of a user
struct UserActivityReport: Codable {
    var totalActivities: AverageStats?
    var averageDuration: AverageStats?
    var averageCalories: AverageStats?
    var typesOfActivities: ActivityTypes?
    var averageDistance: AverageStats?
    var averageDailySteps: AverageStats?
    var averageSleep: AverageStats?
    var totalActivityScore: AverageStats?
    var accountAccountability: AverageStats?
//    var activityAccountability:ActivityAccountability
    var averageTotalActivityScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalActivities = "totalActivities"
        case averageDuration = "averageDuration"
        case averageCalories = "averageCalories"
        case typesOfActivities = "activityTypes"
        case averageDistance = "averageDistance"
        case averageDailySteps = "averageDailySteps"
        case averageSleep = "averageSleep"
        case totalActivityScore = "totalActivityScore"
        case accountAccountability = "activityAccountability"
        
//        case activityAccountability = "activityAccountability"
        
        case averageTotalActivityScore = "totalAppScore"
    }
}
class Graph_: Codable {
       var date: String?
       var score: Double?
}
/// This structure holds the challenges and goals report of a user
struct GroupActivityReport: Codable {
    var total: Int?
    var completed: Int?
    var won: Int?
    var active: Int?
}

struct AverageStats: Codable {
    var value: Double?
    var unit: String?
    var flag: ReportFlag?
}

struct ActivityAccountability: Codable {
    var value: Double?
   
    
}

struct ActivityTypes: Codable {
    var count: Int?
    var flag: ReportFlag?
    
    enum CodingKeys: String, CodingKey {
        case count = "totalTypes"
        case flag
    }
}

/// Holds the status of the user stats of last 30 days to the last to last 30 days
enum ReportFlag: Int, Codable {
    case lowStats = -1 // current stats is lower than the last
    case sameStats = 0 // current stats is same to the last
    case highStats = 1 // current stats is higher than the last
    
    #if os(iOS)
    /// color of the view respective to the flag
    var color: UIColor {
        switch self {
        case .lowStats:
            return #colorLiteral(red: 0.862745098, green: 0.1098039216, blue: 0.0431372549, alpha: 1)            
        case .highStats:
            return #colorLiteral(red: 0.3568627451, green: 0.7098039216, blue: 0.01176470588, alpha: 1)
        case .sameStats:
            return UIColor.white
        }
    }
    
    var honeyCombIcon: UIImage? {
        switch self {
        case .lowStats:
            return UIImage(named: "redHoneycomb")
        case .highStats:
            return UIImage(named: "greenHoneycomb")
        case .sameStats:
            return UIImage(named: "grayHoneycomb")
        }
    }
    
    /// icon of the view respective to the flag
    var icon: UIImage? {
        switch self {
        case .lowStats:
            return UIImage(named: "down1")
        case .highStats, .sameStats:
            return UIImage(named: "upTilted")
        }
    }
    #endif
}
