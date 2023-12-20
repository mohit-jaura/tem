//
//  DIWebLayerChatApi.swift
//  TemApp
//
//  Created by shilpa on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

class DIWebLayerChatApi: DIWebLayer {
    
    /// initialize the chat when user starts to chat in a chat room
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - failure: completion called in case some error occurred
    func initiateChat(roomId: String, completion: @escaping (_ success: Bool) -> Void) {
        let params: Parameters = ["chat_room_id": roomId]
        call(method: .post, function: Constant.SubDomain.chatInit, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            completion(false)
        }
    }
    
    /// get the list of the chat rooms of the user
    ///
    /// - Parameter searchString: search text string, if any
   //http://3.95.242.175:3000/v1.6/chat/chatList?chattype=1
    func getChatList(searchString: String?,type: Int, subdomain: String, completion: @escaping (_ chatList: [ChatRoom]?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var baseUrl = (subdomain + "?type=\(type)")//
        if let searchString = searchString,
            !searchString.isEmpty {
            baseUrl += "?search_by=\(searchString)"
        }
        let url = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (chatLists) in
                    completion(chatLists)
                }, failure: { (error) in
                    failure(error)
                })
            } else {
                completion(nil)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    /// get the chat room information
    ///
    /// - Parameter id: chat room id
    func getChatInfo(forChatRoom id: String, completion: @escaping (_ chatInfo: ChatRoom) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let params: [String: Any] = ["chat_room_id": id]
        call(method: .post, function: Constant.SubDomain.chatInfo, parameters: params, success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data, success: { (chatInfo) in
                    completion(chatInfo)
                }, failure: { (error) in
                    DILog.print(items: "error in decoding: \(error)")
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func chatNotification(forChatRoom id: String, chatWindowType: ChatWindowType, message:String, taggedIds: [String]? = nil, completion: @escaping (_ message: String) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var params: [String: Any] = ["message": message]
        var apiPath = Constant.SubDomain.chatNotification
        switch chatWindowType {
        case .normalChat:
            params["chat_room_id"] = id
            apiPath = Constant.SubDomain.chatNotification
        case .chatInGoal:
            params["id"] = id
            apiPath = Constant.SubDomain.goalChatNotification
        case .chatInChallenge:
            params["id"] = id
            apiPath = Constant.SubDomain.challengeChatNotification
        }
        if let ids = taggedIds,
            !ids.isEmpty {
            params["taggedIds"] = ids
            params["type"] = 1 //type 1 for tagging
        }
        call(method: .post, function: apiPath, parameters: params, success: { (response) in
            if let status = response["status"] as? Int , status == 1 {
                completion(response["message"] as? String ?? "")
                return
            }
        }) { (error) in
            failure(error)
        }
    }
    /// delete chat on a chat room
    /// - Parameter id: chat room id
    func deleteChat(chatRoom id: String) {
        let params: [String: Any] = ["chat_room_id": id]
        call(method: .post, function: Constant.SubDomain.deleteChat, parameters: params, success: { (response) in
            
        }) { (_) in
            
        }
    }
    
    /// create chat group api call
    func createGroup(params: Parameters?, completion: @escaping (_ chatRoomId: String?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        call(method: .post, function: Constant.SubDomain.createGroup, parameters: params, success: { (response) in
            if let data = response["data"] as? Parameters,
                let roomId = data["group_id"] as? String {
                completion(roomId)
            } else {
                completion(nil)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    /// edit chat group api call
    func editGroup(params: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        call(method: .post, function: Constant.SubDomain.editGroup, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    /// delete participant api call
    func deleteGroupMember(params: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        call(method: .post, function: Constant.SubDomain.deleteParticipant, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    /// delete participant api call
    func joinGroup(params: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        call(method: .post, function: Constant.SubDomain.joinGroup, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    /// change the group chat admin
    func makeGroupAdmin(params: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        call(method: .post, function: Constant.SubDomain.makeGroupAdmin, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    /// mute or unmute the chat notifications
    func muteChatNotifications(params: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        call(method: .post, function: Constant.SubDomain.muteChatNotifications, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    /// get the members in a chat group
    func getChatGroupMembersList(groupId: String, completion: @escaping (_ members: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let subDomain = Constant.SubDomain.getGroupMembersListing + "?group_id=\(groupId)"
        call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (friends) in
                    completion(friends)
                }, failure: { (error) in
                    //decoding error
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    /// get the group leaderboard score
    func getGroupLeaderboard(groupId: String, completion: @escaping (_ members: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let subdomain = Constant.SubDomain.getGroupLeaderboard + "?group_id=\(groupId)"
        call(method: .get, function: subdomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (friends) in
                    completion(friends)
                }, failure: { (error) in
                    //decoding error
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    /// set user online status in a chat room
    /// - Parameter params: parameters
    /// - Parameter success: success block
    /// - Parameter failure: error block
    func setUserOnlineStatus(chatRoom: String, chatWindowType: ChatWindowType, status: CustomBool, success: @escaping (_ finished: Bool) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        var path = Constant.SubDomain.chatOnlineStatus
        var params: Parameters = ["status": status.rawValue]
        switch chatWindowType {
        case .normalChat:
            params["chat_room_id"] = chatRoom
            path = Constant.SubDomain.chatOnlineStatus
        case .chatInGoal:
            params["id"] = chatRoom
            path = Constant.SubDomain.goalOnlineStatus
        case .chatInChallenge:
            params["id"] = chatRoom
            path = Constant.SubDomain.challengeOnlineStatus
        }
        call(method: .put, function: path, parameters: params, success: { (response) in
            success(true)
        }) { (error) in
            failure(error)
        }
    }
    
    /// mute the challenge or goal chat notifications
    /// - Parameter roomId: challenge or goal id
    /// - Parameter chatWindowType: challenge or goal type
    /// - Parameter muteStatus: yes or no
    /// - Parameter completion: success
    /// - Parameter failure: failure
    func muteActivityChatNotification(roomId: String, chatWindowType: ChatWindowType, muteStatus: CustomBool, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let params: Parameters = ["id": roomId,
                                  "status": muteStatus.rawValue]
        var apiPath = Constant.SubDomain.muteGoalChat
        if chatWindowType == .chatInChallenge {
            apiPath = Constant.SubDomain.muteChallengeChat
        }
        call(method: .put, function: apiPath, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func getAffiliateGroupsList(id: String, completion: @escaping (_ members: [ChatRoom]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        
        let subDomain = "chat/affiliategrouplist?_id=\(id)"
        call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (friends) in
                    completion(friends)
                }, failure: { (error) in
                    //decoding error
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getPublicGroupsList( completion: @escaping (_ members: [ChatRoom]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        
        let subDomain = "chat/publicGroup"
        call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (friends) in
                    completion(friends)
                }, failure: { (error) in
                    //decoding error
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
}
