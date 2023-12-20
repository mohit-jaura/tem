//
//  FbModal.swift
//  FriendSpire
//
//  Created by abhishek on 24/07/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

//Note *  This class modal used for repsponse come from Friendspire server

import UIKit

class UserId: Codable {
    
    var firstName : String?
    var id : String?
    var lastName : String?
    var userName:String?
    var picture : String?
    var isCompanyAccount : Int?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case id =  "_id"
        case userName = "username"
        case lastName = "last_name"
        case picture =  "profile_pic"
        case isCompanyAccount
    }
    
    init(dictionary: Parameters) {
        if let first = dictionary["first_name"] as? String {
            self.firstName = first
        }
        if let last = dictionary["last_name"] as? String {
            self.lastName = last
        }
        if let userId = dictionary["_id"] as? String {
            self.id = userId
        }
        if let userName = dictionary["username"] as? String {
            self.userName = userName
        }
    }
    
    init() {
        
    }

}
