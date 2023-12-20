//
//  StatsModel.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct Stats: Codable {
    let totalActivityScore, activityAccountability, totalActivities: ActivityAccountability
    let foodTrack: FoodTrack?
    let activityCategory: [Activities]?

    enum CodingKeys: String, CodingKey {
        case totalActivityScore, activityAccountability, totalActivities
        case foodTrack = "FoodTrack"
        case activityCategory
    }
}

struct Activities: Codable {
    let category: String?
    let type: Int?
    let percantageValue: Double?
    let activity: [ActData]?

    enum CodingKeys: String, CodingKey {
        case type = "category_type"
        case category = "Category"
        case percantageValue, activity
    }
}

struct ActData: Codable {
    let name: String?
}

struct FoodTrack: Codable {
    let value: Int?
}
