//
//  Notification.swift
//  Noah
//
//  Created by Harpreet_kaur on 21/03/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class Notifications: Codable {
    static var sharedInstance = Notifications()
    
    var id:String?
    var reference_id:String?
    var createdAt:String?
    var message:String?
    var from:String?
    var to:String?
    var is_read:Int?
    var type:Int?
    var userImage:String?
    var chatGroupId: String?
   var goalChallengeImage: String? // will show goal or challenge image when type is equal to 8 
    var fName: String?
    var lName: String?
    var fullName: String { //not decodable
        if let first = fName, let last = lName {
            return first + " " + last
        }
        if lName == nil {
            return fName ?? ""
        }
        return ""
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reference_id
        case createdAt = "created_at"
        case message
        case from
        case to
        case is_read
        case type
        case userImage
        case chatGroupId = "group_id"
        case goalChallengeImage = "goalchllangeimage"
        case fName = "first_name"
        case lName = "last_name"
    }
}
