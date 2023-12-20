//
//  Comments.swift
//  TemApp
//
//  Created by Harpreet_kaur on 22/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

class Comments : Codable {
    
    var _id:String?
    var postId : String?
    var createdAt : String?
    var updatedAt : String?
    var comment : String?
    var isDeleted:Int?
    var userId : UserId?
    var taggedIds: [UserTag]?
    
    enum CodingKeys: String, CodingKey {
        case _id
        case postId =  "post_id"
        case createdAt =  "created_at"
        case updatedAt =  "updated_at"
        case comment
        case isDeleted = "is_deleted"
        case userId = "user_id"
        case taggedIds = "commentTagIds"
    }
    
    public class func modelsFromDictionaryArray(array:[Parameters]) -> [Comments] {
        var commentsArray: [Comments] = []
        for item in array
        {
            
            commentsArray.append(Comments(dictionary: item))
        }
        return commentsArray
    }
    
    init(dictionary: Parameters) {
        if let text = dictionary["comment"] as? String {
            self.comment = text
        }
        if let userInfo = dictionary["user_id"] as? Parameters {
            self.userId = UserId(dictionary: userInfo)
        }
    }
    
    init() {
    }
}
