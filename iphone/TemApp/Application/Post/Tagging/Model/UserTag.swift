//
//  UserTag.swift
//  TemApp
//
//  Created by shilpa on 19/12/19.
//

import UIKit

struct UserTag: Codable, SerializableArray {
    var id: String?
    var text: String?
    var postId: String?                 //not decodable
    var centerX: CGFloat?
    var centerY: CGFloat?
    var taggedUser: Friends? //not decodable
    var firstName: String?
    var lastName: String?
    var profilePic: String?
    
    var displayName: String { //not decodable
        if let first = firstName, let last = lastName {
            return first + " " + last
        }
        if lastName == nil {
            return firstName ?? ""
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id, text
        case centerX = "positionX"
        case centerY = "positionY"
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
    }
    
    init() {}
    
    init?(fromDict dict: [String : Any]) {
        self.id = dict["id"] as? String
        self.text = dict["text"] as? String
        if let x = dict["positionX"] as? Double {
            centerX = CGFloat(x)
        }
        if let y = dict["positionY"] as? Double {
            centerY = CGFloat(y)
        }
    }
    
    init(dict: Parameters) {
        self.id = dict["id"] as? String
        self.text = dict["text"] as? String
    }
    
    mutating func addNewUser(user: Friends) {
        self.taggedUser = user
    }
}

