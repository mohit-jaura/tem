//
//  Leaderboard.swift
//  TemApp
//
//  Created by shilpa on 29/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

/*
 This class contains the information about the leaderboard of a challenge or a goal.
 This will contain the person's information, his rank and his metrics
 */
struct Leaderboard: Codable {
    var rank: Int?
    var steps: Double?
    var calories: Double?
    var totalActivities: Double?
    var totalTime: Double?
    var distance: Double?
    var leaderboardMember: Friends?
    var score: Double?
    var isOpened = false //not encodable
    
    var teamType: Int? // this is to track for tem vs tem
    
    enum CodingKeys: String, CodingKey {
        case rank, steps, calories,score
        case totalActivities = "totalActivites"
        case totalTime = "timeSpent"
        case leaderboardMember = "userInfo"
        case distance = "distanceCovered"
        case teamType = "teamType"
    }
    
    func toGroupDetail() -> ActivityGroupDetail {
        var groupDetail = ActivityGroupDetail()
        groupDetail.id = self.leaderboardMember?.id
        groupDetail.title = self.leaderboardMember?.groupTitle
        return groupDetail
    }
}

struct FoodTrekModel: Codable {
    var image: String?
    var text: String?
    var trek: Int?
    var status:Bool = false
    var date:Int?
    var on_treak:String?
    var _id:String
    var likes:[FoodTrekLikeModel]
    var likes_count: Int?
    var postTagIds: [UserTag]?
    var captionTagIds: [UserTag]?
    
   enum CodingKeys: String, CodingKey {
       case image, text, trek, date, _id,likes,on_treak,likes_count,postTagIds, captionTagIds
   }
}
struct FoodTrekLikeModel: Codable {
   var user_id: String?
   
   enum CodingKeys: String, CodingKey {
       case user_id
   }
}
