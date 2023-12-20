//
//  MyLeaderboard.swift
//  TemApp
//
//  Created by shilpa on 08/11/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

struct MyLeaderboard: Codable {
    var myRank: Friends?
    var leaderInformation: Friends?
    var addedTemates: [Friends]?
    
    enum CodingKeys: String, CodingKey {
        case myRank
        case leaderInformation = "topScoreMember"
        case addedTemates = "data"
    }
}
