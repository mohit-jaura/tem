//
//  ReportModel.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-04-27.
//

import Foundation
/*
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
        case averageTotalActivityScore = "totalAppScore"
    }
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
    
/*
    /// color of the view respective to the flag
    var color: UIColor {
        switch self {
        case .lowStats:
            return UIColor.appRed
        case .highStats:
            return UIColor.appGreen
        case .sameStats:
            return UIColor.gray
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
 */
}
 */
