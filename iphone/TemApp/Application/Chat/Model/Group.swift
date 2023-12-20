//
//  Group.swift
//  TemApp
//
//  Created by shilpa on 12/09/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

enum GroupVisibility: String, Codable, CaseIterable {
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

/// this class will hold the information about the group admin
struct GroupAdmin: Codable {
    var firstName: String?
    var lastName: String?
    var userId: String?
    
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
        case firstName = "first_name"
        case lastName = "last_name"
        case userId = "user_id"
    }
}
