//
//  PostLikes.swift
//  TemApp
//
//  Created by Harpreet_kaur on 24/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
class PostLikes : Codable {
    var id, firstName, userName, lastName, location, profilePic: String?
    var userId : String?
    var statusWithMe:Int?
    var isFriend:Int?
    var likedOn : String?
    var address:Address?
    
    enum CodingKeys: String, CodingKey {
       case id = "_id", firstName = "first_name", lastName="last_name" , userName = "username", profilePic = "profile_pic"
        case userId =  "user_id"
        case statusWithMe = "statusWithMe"
        case isFriend = "is_friend"
        case likedOn = "liked_on"
        case address = "address"
    }
    
    class func getDictForLikeOrUnlikePost(postData:Post) -> (Parameters,Bool) {
        var dict = [String:Any]()
        dict["post_id"] = postData.id ?? ""
        if let likestatus = postData.isLikeByMe {
            dict["status"] = likestatus == 1 ? 2 : 1
        }else {
            dict["status"] = 1
        }
        var isDecrease = false
        if let status = dict["status"] as? Int , status == 2 {
            isDecrease = true
        }
        return (dict,isDecrease)
    }
}
