//
//  NetworkConnections.swift
//  TemApp
//
//  Created by dhiraj on 25/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

protocol NetworkConnection {
    func remindUserForSentRequest(params:Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ())
    func acceptRequest(params:Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ())
    func sendRequest(params: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ())
    func rejectRequest(params:Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ())
    func deleteRequest(params:Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ())
    func deleteFriend(params:Parameters,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ())
    func getFriendList(pageNo:Int, parameters: Parameters?, success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ())
    func getPendingRequestList(pageNo:Int,success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ())
    func getSentRequestList(pageNo:Int,success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ())
    func getFriendListFromSearch(text: String, parameters: Parameters?, pageNo: Int, success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ())
    func getNewGroupParticipantsList(pageNo:Int, searchText: String?, groupId: String?, success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ())
    func getTemsListing(searchString: String?, pageNo: Int, success: @escaping ([ChatRoom]) -> (), failure: @escaping (DIError) -> ())
    func getPublicTemsListing(searchString: String?, pageNo: Int, success: @escaping ([ChatRoom]) -> (), failure: @escaping (DIError) -> ())
}

class NetworkConnectionManager:NetworkConnection{
    
    func unBlockUser(params: Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().unBlockUser(parameters: params, success: { (response) in
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    func blockUser(params: Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().blockUser(parameters: params, success: { (response) in
            if let data = response["data"] as? Parameters {
                //update the status of user in his chat room
                if let roomId = data["chat_room_id"] as? String,
                    let friendId = params?["_id"] as? String {
                    let chatManager = ChatManager()
                    chatManager.updateUserChatStatusInChatRoom(roomId: roomId, userId: friendId, status: .blocked)
                    if let currentUserId = UserManager.getCurrentUser()?.id {
                        chatManager.updateUserChatStatusInChatRoom(roomId: roomId, userId: currentUserId, status: .blocked)
                    }
                }
            }
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    func acceptRequest(params: Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().acceptRequest(parameters: params, success: { (response) in
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    func deleteFriend(params: Parameters, success: @escaping (String) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().deleteFriend(parameters: params, success: { (response) in
            if let status = response["status"] as? Int , status == 1 {
                if let data = response["data"] as? Parameters {
                    //update the status of user in his chat room
                    if let roomId = data["chat_room_id"] as? String,
                        let friendId = params["friend_id"] as? String {
                        let chatManager = ChatManager()
                        chatManager.updateUserChatStatusInChatRoom(roomId: roomId, userId: friendId, status: .unfriend)
                        if let currentUserId = UserManager.getCurrentUser()?.id {
                            chatManager.updateUserChatStatusInChatRoom(roomId: roomId, userId: currentUserId, status: .unfriend)
                        }
                    }
                }
                if let message = response["message"] as? String {
                    success(message)
                    return
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func sendRequest(params: Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().sendFriendRequest(parameters: params, success: { (response) in
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    func remindUserForSentRequest(params: Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().remindRequest(parameters: params, success: { (response) in
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    func rejectRequest(params:Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().rejectRequest(parameters: params, success: { (response) in
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    func deleteRequest(params:Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().deleteRequest(parameters: params, success: { (response) in
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    func getPendingRequestList(pageNo:Int,success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ()) {
        DIWebLayerNetworkAPI().getPendingRequest(parameters: nil , page: pageNo.stringValue, success: { (data,count) in
            success(data,count)
        }) { (error) in
            failure(error)
        }
        
    }
    
    func getSentRequestList(pageNo:Int,success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ()) {
        DIWebLayerNetworkAPI().getSentRequest(parameters: nil , page: pageNo.stringValue, success: { (data,count) in
            success(data,count)
        }) { (error) in
            failure(error)
        }
    }
    
   
    
    
    func getFriendList(pageNo:Int, parameters: Parameters?, success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ()) {
        DIWebLayerNetworkAPI().getFriendList(parameters: parameters , page: pageNo.stringValue, success: { (data,count) in
            success(data,count)
        }) { (error) in
            failure(error)
        }
    }
    
    func getNewGroupParticipantsList(pageNo:Int, searchText: String?, groupId: String?, success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ()) {
        DIWebLayerNetworkAPI().getFriendList(subdomain: Constant.SubDomain.getChatFriendListing, parameters: nil, page: pageNo.stringValue, searchString: searchText, groupId: groupId ?? "", success: { (data, count) in
            success(data,count)
        }) { (error) in
            failure(error)
        }
    }
    
    /// api call to fetch the friend list from server from search text
    ///
    /// - Parameters:
    ///   - text: search text
    ///   - pageNo: page number
    ///   - success: success block
    ///   - failure: failuer block
    func getFriendListFromSearch(text: String, parameters: Parameters?, pageNo: Int, success: @escaping ([Friends], Int) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().getFriendList(parameters: parameters, page: pageNo.stringValue, searchString: text, success: { (data, count) in
            success(data,count)
        }) { (error) in
            failure(error)
        }
    }
    
    func getTemsListing(searchString: String?, pageNo: Int, success: @escaping ([ChatRoom]) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().getTemsList(searchString: searchString, page: pageNo.stringValue, success: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
    }
    
    func getPublicTemsListing(searchString: String?, pageNo: Int, success: @escaping ([ChatRoom]) -> (), failure: @escaping (DIError) -> ()) {
        DIWebLayerNetworkAPI().getPublicTemsList(searchString: searchString, page: pageNo.stringValue, success: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
    }
}
