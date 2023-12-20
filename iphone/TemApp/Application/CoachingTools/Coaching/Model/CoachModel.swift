//
//  CoachModel.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct CoachList: Codable {
    let id, firstName, lastName: String?
    let profilePic: String?

    var fullName: String { //not decodable
        if let first = firstName, let last = lastName {
            return first + " " + last
        }
        if lastName == nil {
            return firstName ?? ""
        }
        return ""
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
    }
}
