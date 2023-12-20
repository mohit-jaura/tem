//
//  DataClass.swift
//  VIZU
//
//  Created by dhiraj on 13/11/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

class DataClass: Codable {
    let friends, others: [Friends]
}

enum FriendStatus: Int, Codable {
    case other = 0
    case requestSent = 1
    case connected = 2  // friends with each other
    case requestReceived = 3
    case blocked = 4
    
    var title: String {
        switch self {
        case .blocked :
            return "Unblock".localized
        case .connected:
            return "Connected".localized
        case .requestSent:
            return "Request Pending".localized
        case .requestReceived:
            return "Accept".localized
        case .other:
            return "Send Request".localized
        }
    }
}
class ActivityCount: Codable{
    var score : CGFloat?
    var scoreFlag : Int?
    enum CodingKeys: String, CodingKey {
        case score = "score"
        case scoreFlag = "scoreFlag"
    }
}

class Friends: Codable {
    var user_id: String? //this id is used for the member in a chat room
    var email: String?
    var id, firstName, userName, lastName, location, profilePic: String?
    var address:Address?
    var status: Int? //this will also hold the value of member in the chatroom whether the user can chat in this chatroom or not
    var points,rank,priority: Int?
    var isFriend:Int?
    var likedOn : String?
    var inviteAccepted : Int?
    var userId : String?
    var accountabilityMission : String?
    var isCompanyAccount:Int?
    var fullName: String { //not decodable
        if let first = firstName, let last = lastName {
            return first + " " + last
        }
        if lastName == nil {
            return firstName ?? ""
        }
        return ""
    }
    var goalAndChallengeCount:Int?
    
    var feedsCount: Int?
    var tematesCount: Int?
    var temsCount: Int?
    var isPrivate: CustomBool?
    var friendStatus: FriendStatus?
    var gym: Address?
    var gymName: String?
    var foodTrekContentExists: Bool? //this holds the status whether the user add any food trek activity or not (0=not added / 1=added)
    var chatRoomId: String?
    var adminId: String? //this will hold the chat group admin id in case of the group chat particpants
    var memberExist: CustomBool? //this holds the status whether the user already exists in the listing to be added
    
    /*
     This will have values 0, 1
     0:- Current user has already reminded this user once in a day
     1:- Current user can remind this user
     */
    var canRemind: CustomBool?
    var activityCount : ActivityCount?
    var chatRooms: [ChatRoom]? //contain the information of all the chat rooms of this particular user
    var isDeleted: CustomBool?//0 if chat is deleted by the user, 1 if chat is not deleted by the user
    var accountabilityScore: Double?
    
    //in case of challenge leaderboard, this would contain the group information
    var groupTitle: String?
    var groupIcon: String?
    var isAdded: Int?
    var averageDistance: Int?
    var averageDuration: Double?
    var totalActivityiesCount: Int?
    var totalActivityTime: Double?
    var totalActivityDistance: Int?
    var image: String?
    var isSubscriptionPurchased: Int?
    var admintype: Int?
    
    enum CodingKeys: String, CodingKey {
        case isAdded = "is_added"
        case email = "email"
        case user_id = "user_id"
        case isCompanyAccount
        case id = "_id", firstName = "first_name", lastName="last_name" , userName = "username"
        case profilePic = "profile_pic"
        case points
        case address
        case priority
        case rank
        case status
        case activityCount = "activityCount"
        case isFriend = "is_friend"
        case likedOn = "liked_on"
        case feedsCount = "feed_posted"
        case tematesCount = "number_of_temmates"
        case temsCount = "number_of_tems"
        case isPrivate = "is_private"
        case friendStatus = "friend_status"
        case gym = "gym"
        case gymName = "gym_name"
        case canRemind = "reminder_status"
        case inviteAccepted = "inviteAccepted"
        case userId = "userId"
        case chatRoomId = "chat_room_id"
        case adminId = "admin"
        case memberExist = "member_exist"
        case isDeleted = "is_deleted"
        case accountabilityScore = "score"
        case goalAndChallengeCount = "goalAndChallengeCount"
        case accountabilityMission = "accountabilityMission"
        case groupTitle = "group_title"
        case groupIcon = "image"
        case foodTrekContentExists
        case totalActivityiesCount = "totalActivities"
        case totalActivityTime = "averageDuration"
        case totalActivityDistance = "averageDistance"
        case isSubscriptionPurchased = "subscription_plan_active"
        case admintype = "admintype"
    }
    
    public class func modelsFromDictionaryArray(array:[Parameters]) -> [Friends]
    {
        var friendsArray:[Friends] = []
        for item in array
        {
            friendsArray.append(Friends(dictionary: item)!)
        }
        return friendsArray
    }
    public init?(_ user:User?) {
        
    }
    
    public init?(dictionary: Parameters) {
        id = dictionary["_id"] as? String
        address = Address(json: dictionary["address"] as? Parameters ?? [:])
        firstName = dictionary["first_name"] as? String
        lastName = dictionary["last_name"] as? String
        friendStatus = FriendStatus(rawValue: dictionary["friend_status"] as? Int ?? 0)
        isFriend = dictionary["is_friend"] as? Int
        profilePic = dictionary["profile_pic"] as? String
        accountabilityMission = dictionary["accountabilityMission"] as? String
    }
    
    func updateFriendStatus(statusValue: FriendStatus,isFriend: Int) {
        self.friendStatus = statusValue
        self.isFriend = isFriend
    }
    init() {
        
    }
    
    func toGroupActivityTem() -> GroupActivityTem {
        var tem = GroupActivityTem()
        tem.id = id
        tem.name = groupTitle
        return tem
    }
}
