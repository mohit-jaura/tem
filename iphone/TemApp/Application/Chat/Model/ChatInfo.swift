//
//  ChatInfo.swift
//  TemApp
//
//  Created by shilpa on 26/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

enum ChatRoomType: Int, Codable {
    case single = 0 //for single chat
    case group //for group chat
}

enum RemoveMemberStatus: Int, Codable {
    case delete = 1
    case exit = 2
}

///Chat status
enum ChatStatus: Int, Codable {
    case blocked = 0
    case active = 1
    case unfriend = 2
    case blockedByAdmin = 3
    case profileDeleted = 4
}

enum GroupChatStatus: Int, Codable {
    case observer = -1 // the user is not part of the group, but is able to see info and messages
    case notPartOfGroup = 0 //in case the member was removed from group or he has exit from the group
    case active = 1
    case blocked = 2
}

/// Chat type - single or group
enum ChatType: Int, Codable {
    case singleChat = 1
    case groupChat = 2
}

enum ChatWindowType: Int, Codable {
    case normalChat = 0, chatInChallenge, chatInGoal
}

/// this holds the reference of a chat room information of a user
class ChatRoom: Codable {
    var chatRoomId: String?
    var chatStatus: ChatStatus?
    var groupChatStatus: GroupChatStatus?
    var chatInitiated: CustomBool?
    var chatType: ChatType?
    var members: [Friends]?
    var memberIds: [String]?
    var lastMessage: Message?

    var lastSeen: Double? //last seen time for a chat room
    var clearChatTime: Double? //time at which the user clears the chat in a chat room
    var unreadCount: Int?

    var name: String? //this will be the name of the other user in case of single chat and name of the group in case of group chat
    var isDeleted: CustomBool? //0 if chat is deleted by the user, 1 if chat is not deleted by the user
    var groupId: String?
    var interests: [Activity]?
    var editableByMembers: Bool?
    var visibility: GroupVisibility?
    var icon: String?
    var desc: String?
    var imagePath: String? //this will store the path of the image either on firebase or AWS bucket
    var admin: GroupAdmin?
    var membersCount: Int?
    var createdAt: Double?
    var isMuted: CustomBool?
    /// this will hold the type of chat eg. in challenge, or goal or normal
    var chatWindowType: ChatWindowType?
    /// this will hold the status whether the user has joined goal or challenge chat room
    var isJoined: CustomBool?

    var avgActivityScore: Double?

    var teamType: Int?
    var adminId: String?
    
    enum CodingKeys: String, CodingKey {
        case adminId = "admin"
        case chatRoomId = "chat_room_id"
        case chatStatus = "chat_status"
        case chatInitiated = "chat_initiated"
        case chatType = "type"
        case members
        case lastSeen
        case clearChatTime
        case memberIds
        case name = "group_title"
        case isDeleted = "is_deleted"
        case groupId = "group_id"
        case interests = "interests"
        case editableByMembers
        case visibility
        case icon = "image"
        case desc = "description"
        case imagePath
        case admin = "adminData"
        case membersCount = "members_count"
        case createdAt = "created_at"
        case isMuted = "is_mute"
        case groupChatStatus = "group_chat_status"
        case chatWindowType = "chatWindowType"
        case avgActivityScore = "avgScore"
    }
}

extension ChatRoom {
    ///return a new chatroom that is copy of the receiver
    func copy(with zone: NSZone? = nil) -> Any {
        let data = try? JSONEncoder().encode(self)
        if data != nil {
            let copy = try? JSONDecoder().decode(ChatRoom.self, from: data!)
            return copy ?? self
        }
        return ChatRoom()
    }
}

extension ChatRoom {
    // returns as: ["group_id": "abc"", "members": "12345"]
    func actionOnMemberApiJson(memberId: String?, status: RemoveMemberStatus?) -> Parameters {
        var dict: Parameters = [:]
        if let id = self.groupId {
            dict["group_id"] = id
        }
        if let memberId = memberId {
            dict["members"] = memberId
        }
        if let status = status {
            dict["status"] = status.rawValue
        }
        return dict
    }
    
    func joinGroupJson() -> Parameters {
        var dict: Parameters = [:]
        if let id = self.groupId {
            dict["groupId"] = id
        }
        return dict
    }

    func editGroupJson() -> ChatRoom {
        let edited = ChatRoom()
        edited.groupId = self.groupId
        edited.imagePath = self.imagePath
        edited.icon = self.icon
        edited.desc = self.desc
        edited.interests = self.interests
        edited.name = self.name
        edited.editableByMembers = self.editableByMembers
        edited.visibility = self.visibility
        return edited
    }

    func createGroupJson() -> ChatRoom {
        let chatGroup = ChatRoom()
        chatGroup.groupId = self.groupId
        chatGroup.imagePath = self.imagePath
        chatGroup.icon = self.icon
        chatGroup.desc = self.desc
        chatGroup.interests = self.interests
        chatGroup.name = self.name
        chatGroup.editableByMembers = self.editableByMembers
        chatGroup.visibility = self.visibility
        chatGroup.memberIds = self.memberIds
        return chatGroup
    }

    func editParticipantsJson() -> ChatRoom {
        let chatGroup = ChatRoom()
        chatGroup.groupId = self.groupId
        chatGroup.memberIds = self.memberIds
        return chatGroup
    }

    func toGroupActivityType() -> GroupActivityTem {
        var tem = GroupActivityTem()
        tem.id = self.groupId
        tem.name = self.name
        return tem
    }
}
