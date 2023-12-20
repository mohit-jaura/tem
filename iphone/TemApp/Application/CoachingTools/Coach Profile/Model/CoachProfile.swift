//
//  CoachProfile.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct CoachProfile: Codable {
    let coachName, description: String
   // let maxClients, connectedClients: Int
    let id: String
    let image: String
    let coachType: [Int]
    let services: [Service]

    enum CodingKeys: String, CodingKey {
        case coachName,coachType, description//, maxClients, connectedClients
        case id = "_id"
        case image = "coachProfile"
        case services
    }
}

struct Service: Codable {
    let name: String
    let monthlyCost: Int
    let description, frequencyName, id: String
    let maxClients: Int?
    let connectedClients: Int?
    let isSubscribed: Int/* if isSubscribed = 0   ---> Hire
                          if isSubscribed = 1 ----> Cancel
                          if isSubscribed = 2  ----> Cancelled */

    enum CodingKeys: String, CodingKey {
        case name, description, frequencyName
        case id = "_id"
        case monthlyCost = "cost"
        case isSubscribed
        case maxClients = "MaxClients"
        case connectedClients
    }
}
