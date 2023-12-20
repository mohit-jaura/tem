//
//  ChatManager.swift
//  TemApp
//
//  Created by shilpa on 26/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
/// This class will contain all the helpers related to the chat. This will include sending, receiving, fetching all the chats related to a user
class ChatManager {

    let chatsFirestoreRef = Firestore.firestore().collection("Chats")
    let usersFirestoreRef = Firestore.firestore().collection("Users")
    let liveSessionsFirestoreRef = Firestore.firestore().collection("live-chats")
    let storageReference = StorageReference()
    var streamJoinedListener: ListenerRegistration?
    
    var messageListener: ListenerRegistration?
    var userInfoListener: ListenerRegistration?
    var userChatStatusListener: ListenerRegistration?
    var chatsParentListener: ListenerRegistration?
    
    /// adds the message node to a chat room
    ///
    /// - Parameters:
    ///   - id: id of the chat room
    ///   - message: message object
    func addMessage(toChatRoomId id: String, message: Message, completion: @escaping (_ success: Bool, _ messageId: String?) -> Void) {
        //creating message object
        guard let messageData = message.json() else {
            return
        }
        chatsFirestoreRef.document(id).collection("messages").document(message.id ?? "").setData(messageData) { (error) in
            if error != nil {
            } else {
                if let msgId = messageData["id"] as? String {
                    completion(true, msgId)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    /// updates the message in a chat room
    ///
    /// - Parameters:
    ///   - roomId: id of the chat room
    ///   - message: message object
    func updateMessage(roomId: String, message: Message) {
        if let data = message.json(),
            let msgId = message.id {
            chatsFirestoreRef.document(roomId).collection("messages").document(msgId).updateData(data)
        }
    }

    func listenToChatRoom(withId id: String, fromTime: Double?, isPublicRoom: Bool? = false, fetchLatestFirst: Bool? = false, completion: @escaping (_ messages: [Message]) -> Void, failure: (_ error: Error) -> Void) {
        
        //check if there is an initial point to fetch data and add the filter
        var query: Query!
        if let fromTime = fromTime {
            query = chatsFirestoreRef.document(id).collection("messages").whereField("time", isGreaterThan: fromTime)
        } else {
            query = chatsFirestoreRef.document(id).collection("messages")
        }
        if fetchLatestFirst! {
            query = query.order(by: "time", descending: true)
        } else {
            query = query.order(by: "time")
        }
        messageListener = query.addSnapshotListener { (snapshot, error) in
            if error != nil {
            } else {
                let messages = snapshot?.documentChanges.map({ (document) -> Message in

                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.document.data(), options: .prettyPrinted)
                        let message = try JSONDecoder().decode(Message.self, from: jsonData)
                        if isPublicRoom! {
                            //if this is the public room, fetch all the messages of this chat room irrespective of current user as the member or not
                            return message
                        }
                        if let chatType = message.chatType,
                            chatType == .groupChat {
                            if message.userIds?.contains(UserManager.getCurrentUser()?.id ?? "") == true {
                                //this user is added in this chat room
                                return message
                            }
                        } else {
                            return message
                        }
                    } catch (_) {
                    }
                    return Message()
                })
                if let messagesArray = messages {
                    completion(messagesArray)
                }
            }
        }
    }
    
    /// set user information from the "Users" table in each message object
    ///
    /// - Parameters:
    ///   - messages: initial messages array
    ///   - completion: updated messages array on success
    ///   - failure: error if any failure occurs
    func setUserInformationIn(messages: [Message], completion: @escaping (_ updatedMessages: [Message]) -> Void, failure: (_ error: Error) -> Void) {

        var newMessages = messages
        for (index, message) in messages.enumerated() {
            if let senderId = message.senderId,
                senderId.isEmpty {
                continue
            }
            usersFirestoreRef.document(message.senderId ?? "").getDocument { (snapshot, error) in
                if let chatMember = snapshot?.data() { // as there would be only one object of user information under this node
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: chatMember, options: .prettyPrinted)
                        let member = try JSONDecoder().decode(Friends.self, from: jsonData)
                        newMessages[index].sender = member
                        let filteredArray = newMessages.filter({ (message) -> Bool in
                            return message.sender != nil
                        })
                        if filteredArray.count == newMessages.count {
                            //all the messages have been traversed
                            completion(newMessages)
                        }
                    } catch (_) {

                    }
                }
            }
        }
    }
    
    /// adds the user information like name, email, picture etc. to the database
    func updateCurrentUserInfoToDatabase() {
        guard let currentUser = UserManager.getCurrentUser(),
            let userId = currentUser.id else {
            return
        }
        let userInfo: [String: Any] = ["email": currentUser.email ?? "",
                                       "first_name": currentUser.firstName ?? "",
                                       "last_name": currentUser.lastName ?? "",
                                       "profile_pic": currentUser.profilePicUrl ?? "",
                                       "user_id": userId]
        usersFirestoreRef.document(userId).setData(userInfo)
    }
 
    /// this is observing each chat room id. This function will call if any new message is added in chat room.
    ///
    /// - Parameter roomId: chat room id
    func addObserverOnChatRoomToFetchLastMessage(roomId: String, completion: @escaping (_ lastMessage: Message?) -> Void, failure: (_ error: Error) -> Void) -> ListenerRegistration? {
        
        let handler = chatsFirestoreRef.document(roomId).collection("messages").order(by: "time", descending: true).addSnapshotListener { (snapshot, error) in
            guard error == nil,
                let documents = snapshot?.documents else {
                // Handle the error here
                return
            }
            if documents.isEmpty {
                completion(nil)
                return
            }
            for (index, document) in documents.enumerated() {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                    let message = try JSONDecoder().decode(Message.self, from: jsonData)
                    
                    /*first check if the message type is media or text,
                     if this is of media type (i.e. image or video), then check if the sender id is of current user or some other user
                     if this is of current user just return the message object. If this is of other user, check if the media uploading status is uploaded or uploading in progress . If this is upoaded, return the message object else traverse the documents for next message  and repeat the process */
                    
                    if let messageType = message.type {
                        switch messageType {
                        case .text:
                            if message.chatType == .groupChat {
                                if message.userIds?.contains(UserManager.getCurrentUser()?.id ?? "") == true {
                                    completion(message)
                                    return //return from the for loop
                                }
                            } else {
                                completion(message)
                                return //return from the for loop
                            }
                            case .image, .video, .pdf:
                            if message.senderId == UserManager.getCurrentUser()?.id {
                                completion(message)
                                return
                            } else {
                                if let mediaUploadingStatus = message.mediaUploadingStatus {
                                    if mediaUploadingStatus == .isUploaded {
                                        if message.chatType == .groupChat {
                                            if message.userIds?.contains(UserManager.getCurrentUser()?.id ?? "") == true {
                                                completion(message)
                                                return
                                            }
                                        } else {
                                            completion(message)
                                            return
                                        }
                                    }
                                }
                                if index == documents.count - 1 { //this is the last document to traverse
                                    if let mediaUploadingStatus = message.mediaUploadingStatus,
                                        mediaUploadingStatus != .isUploaded {
                                        completion(Message())
                                    }
                                }
                            }
                        }
                    }
                } catch (_) {
                }
            }
        }
        return handler
    }
    
    /// will notify if the new chat room was added
    func observeNewChatRoomAdded(completion: @escaping (_ chatInfo: ChatRoom, _ diffType: DocumentChangeType) -> Void) {
        self.chatsParentListener = self.chatsFirestoreRef.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach { diff in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: diff.document.data(), options: .prettyPrinted)
                    let chatInfo = try JSONDecoder().decode(ChatRoom.self, from: jsonData)
                    if let chatWindowType = chatInfo.chatWindowType {
                        if chatWindowType == .chatInGoal || chatWindowType == .chatInChallenge {
                            //then dont add the observer
                            return
                        }
                    }
                    chatInfo.chatRoomId = diff.document.documentID
                    completion(chatInfo, diff.type)
                } catch (_) {
                }
            }
        }
    }
    
    /// save the last seen time of user on the chat screen of a chat room id
    ///
    /// - Parameters:
    ///   - lastSeen: timestamp
    ///   - roomId: id of the chat room which the user is currently viewing
    func saveLastSeenOfUser(lastSeen: Double, forChatRoom roomId: String) {
        guard let userId = UserManager.getCurrentUser()?.id else {
            return
        }
        let data: [String: Any] = ["lastSeen": lastSeen]
        self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).setData(data, merge: true)
    }
    
    /// get the user information from the user id
    ///
    /// - Parameters:
    ///   - userId: user id
    ///   - completion: returns the user info
    ///   - failure: called if error occurs
    func getUserInformationFrom(userId: String, completion: @escaping (_ userInformation: Friends) -> Void, failure: @escaping (_ error: Error) -> Void) -> ListenerRegistration? {
        let handler = self.usersFirestoreRef.document(userId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                failure(error)
                return
            }
            if let chatMember = snapshot?.data() { // as there would be only one object of user information under this node
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: chatMember, options: .prettyPrinted)
                    let member = try JSONDecoder().decode(Friends.self, from: jsonData)
                    completion(member)
                } catch (_) {
                }
            }
        }
        return handler
    }
    
    /// save the time at which the user cleared all the messages in a particular chat room
    ///
    /// - Parameters:
    ///   - lastSeen: timestamp
    ///   - roomId: id of the chat room which the user is currently viewing
    func saveClearChatTimeOfUser(time: Double, forChatRoom roomId: String, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: String) -> Void) {
        //get current user id
        guard let userId = UserManager.getCurrentUser()?.id else {
            return
        }
        let data: [String: Any] = ["clearChatTime": time]
        self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).setData(data, merge: true) { (error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                completion(true)
            }
        }

    }
    
    /// save the user status in the respective chat room, whether he is the friend of other user or not
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - userId: id of the user
    ///   - status: user chat status
    func updateUserChatStatusInChatRoom(roomId: String, userId: String, status: ChatStatus) {
        guard !userId.isEmpty, !roomId.isEmpty else {
            return
        }
        let data: [String: Any] = ["chat_status": status.rawValue]
        self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).setData(data, merge: true)
    }
    
    /// save the user status in the respective chat room, whether he is the friend of other user or not
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - userId: id of the user
    ///   - status: user chat status
    func updateUserGroupChatStatusInChatRoom(roomId: String, userId: String, status: GroupChatStatus) {
        guard !userId.isEmpty, !roomId.isEmpty else {
            return
        }
        let data: [String: Any] = ["group_chat_status": status.rawValue]
        self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).setData(data, merge: true)
    }
    
    /// save the user on chat screen status in the respective chat room, whether he is on chat screen or not
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - status: user on screen status
    func updateUserOnScreenStatusInChatRoom(roomId: String, status: Bool) {
        //get current user id
        guard let userId = UserManager.getCurrentUser()?.id else {
            return
        }
        let data: [String: Any] = ["onChatScreen": status]
        self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).setData(data, merge: true)
        
    }
    
    func checkOnChatScreenStatusOfUser(roomId: String, completion: @escaping (_ roomId: String) -> Void) {
        //get current user id
        guard let userId = UserManager.getCurrentUser()?.id else {
            return
        }
        self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).addSnapshotListener { (snapshot, error) in
            guard error == nil else {
                return
            }
            if let onChatScreenStatus = snapshot?.data()?["onChatScreen"] as? Bool,
                onChatScreenStatus == true {
                if let documentId = snapshot?.documentID {
                    completion(documentId)
                }
            }
        }
    }
    
    /// save the isDeleted status of a chat room of the user
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - status: user on screen status
    func updateDeleteChatStatus(roomId: String, userId: String?, status: CustomBool) {
        //get current user id
        guard let userId = userId else {
            return
        }
        let data: [String: Any] = ["is_deleted": status.rawValue,
                                   "chat_room_id": roomId]
        self.chatsFirestoreRef.document(roomId).collection("chatMembersStatus").document(userId).setData(data, merge: true)
    }
    
    ///getting information of user status in a chat room i.e. isDeleted
    func getChatRoomMembersInformation(roomId: String, completion: @escaping (_ member: Friends?) -> Void) {
        //get current user id
        guard let userId = UserManager.getCurrentUser()?.id else {
            return
        }
        self.chatsFirestoreRef.document(roomId).collection("chatMembersStatus").document(userId).getDocument { (snapshot, error) in
            guard error == nil else {
                return
            }
            if let data = snapshot?.data() {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let member = try JSONDecoder().decode(Friends.self, from: jsonData)
                    member.user_id = snapshot?.documentID
                    completion(member)
                } catch (_) {
                }
            } else {
                completion(nil)
            }
        }
    }
    
    /// call this function to get the information of the user status in chat room. This will return the information like the last seen time of user in this chat room, user can chat etc.
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - completion: success block with the chat room info decoded as an object
    func getRoomInformationOfUser(roomId: String, completion: @escaping (_ roomInfo: ChatRoom?) -> Void) {
        //get current user id
        guard let userId = UserManager.getCurrentUser()?.id else {
            return
        }
        self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).getDocument { (snapshot, error) in
            guard error == nil else {
                return
            }
            if let document = snapshot?.data() {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document, options: .prettyPrinted)
                    let roomInfo = try JSONDecoder().decode(ChatRoom.self, from: jsonData)
                    completion(roomInfo)
                } catch (_) {
                }
            } else {
                completion(nil)
            }
        }
    }
    
    ///get the user chat status in chat room that whether he can chat in the room or not
    func getUserChatStatus(inRoom roomId: String, completion: @escaping (_ chatStatus: ChatStatus?, _ groupChatStatus: GroupChatStatus?) -> Void) {
        //get current user id
        guard let userId = UserManager.getCurrentUser()?.id else {
            return
        }
        self.userChatStatusListener = self.usersFirestoreRef.document(userId).collection("chatRooms").document(roomId).addSnapshotListener { (snapshot, error) in
            guard error == nil else {
                return
            }
            if let document = snapshot?.data() {
                var chatStatus: ChatStatus? = nil
                if let value = document["chat_status"] as? Int,
                   let status = ChatStatus(rawValue: value) {
                    chatStatus = status
                }
                var groupStatus: GroupChatStatus? = nil
                if let value = document["group_chat_status"] as? Int,
                   let status = GroupChatStatus(rawValue: value) {
                    groupStatus = status
                }
                completion(chatStatus, groupStatus)
            }
        }
    }
    
    func fetchUnreadCount(roomId: String, completion: @escaping (_ unreadCount: Int, _ chatRoomId: String?) -> Void) {
        //first fetch the last seen of user
        guard let currentUserId = UserManager.getCurrentUser()?.id else {
            return
        }
        self.usersFirestoreRef.document(currentUserId).collection("chatRooms").document(roomId).getDocument { (snapshot, error) in
            //get the last seen key value and fetch the message according to that
            var query: Query!
            var chatRoomId = roomId
            if let document = snapshot?.data(),
                let lastSeen = document["lastSeen"] as? Double,
                let documentId = snapshot?.documentID { //this would be the room id
                chatRoomId = documentId
                query = self.chatsFirestoreRef.document(documentId).collection("messages").whereField("time", isGreaterThan: lastSeen)
            } else {
                //if the user has not yet opened the chat screen for this room id till now, then get count of all messages
                query = self.chatsFirestoreRef.document(chatRoomId).collection("messages")
            }
            
            query.getDocuments(completion: { (snapshot, error) in
                guard error == nil else {
                    return
                }
                if let documents = snapshot?.documentChanges {
                    //filter the messages whose sender id is not the current user id
                    if !documents.isEmpty {
                        let filteredDocuments = documents.filter({ (snapshotDoc) -> Bool in
                            let document = snapshotDoc.document
                            if document.data()["senderId"] as? String != UserManager.getCurrentUser()?.id {
                                //first check if the message contains the user id of the current user, only then update the array, else skip
                                if let memberIds = document.data()["userIds"] as? [String],
                                    memberIds.contains(UserManager.getCurrentUser()?.id ?? "") == false {
                                    return false
                                }
                                if let msgType = document["type"] as? Int,
                                    let type = MessageType(rawValue: msgType) {
                                    switch type {
                                    case .text:
                                        return true
                                        case .image, .video, .pdf:
                                        return document.data()["uploadingStatus"] as? Int == MediaUploadStatus.isUploaded.rawValue
                                    }
                                }
                            }
                            return false
                        })
                        //this is to fetch the chat room id from the first message, this will be same across all the messages, so for best case, fetch from the object.first
                        if let chatId = filteredDocuments.first?.document.data()["chat_room_id"] as? String {
                            completion(filteredDocuments.count, chatId)
                        }
                    } else {
                        completion(0, chatRoomId)
                    }
                }
            })
        }
    }
    
    /// updates the chat room status like its type, chat_initiated, members in chat room
    func chatInitiatedForChatRoom(roomId: String, chatInfo: ChatRoom?) {
        var data: [String: Any] = ["chat_initiated": CustomBool.yes.rawValue,
                                   "type": chatInfo?.chatType?.rawValue ?? 1]
        if let chatType = chatInfo?.chatType {
            if chatType == .singleChat {
                data["group_title"] = chatInfo?.members?.first?.fullName
            } else {
                //for group chat
                data["group_title"] = chatInfo?.name ?? ""
            }
        }
        if let memberIds = chatInfo?.memberIds {
            var ids = memberIds
            ids.append(UserManager.getCurrentUser()?.id ?? "")
            data["memberIds"] = ids
        }
        self.chatsFirestoreRef.document(roomId).setData(data, merge: true)
    }
    
    /// get the members ids in a chat room, this needs to be done only for single chat. This information is obtained only one time and no listener gets attached
    func getChatRoomInformation(roomId: String, completion: @escaping (_ roomInfo: ChatRoom?) -> Void) {
        self.chatsFirestoreRef.document(roomId).getDocument { (snapshot, error) in
            guard error == nil else {
                return
            }
            if let document = snapshot?.data() {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document, options: .prettyPrinted)
                    let roomInfo = try JSONDecoder().decode(ChatRoom.self, from: jsonData)
                    roomInfo.chatRoomId = roomId
                    completion(roomInfo)
                } catch (_) {
                }
            } else {
                completion(nil)
            }
        }
    }
    
    ///updates the information like name, group icon etc to the database
    func updateChatRoomInformationToDatabase(roomId: String, groupInfo: ChatRoom) {
        var data: Parameters = ["group_title": groupInfo.name ?? "",
                                "image": groupInfo.icon ?? "",
                                "type": groupInfo.chatType?.rawValue ?? ChatType.singleChat.rawValue]
        var memberIds = groupInfo.members?.map({$0.user_id ?? ""})
        if memberIds == nil {
            memberIds = []
        }
        memberIds?.append(UserManager.getCurrentUser()?.id ?? "")
        if let ids = memberIds {
            data["memberIds"] = ids
        }
        if let creationTime = groupInfo.createdAt {
            data["created_at"] = creationTime
        }
        if let chatWindowType = groupInfo.chatWindowType {
            data["chatWindowType"] = chatWindowType.rawValue
        }
        self.chatsFirestoreRef.document(roomId).setData(data, merge: true)
    }
    
    ///update members to the chat room
    /// - Parameter:
    /// - roomId: chat room id to update
    /// - memberIds: ids of the members which are to be added to the chat room
    func addMembersToChatRoom(roomId: String, memberIds: [String]) {
        self.chatsFirestoreRef.document(roomId).updateData([
            "memberIds": memberIds//FieldValue.arrayUnion(memberIds)
            ])
    }
    
    func testAdd(roomId: String, value: [String]) {
        let doc = self.chatsFirestoreRef.document(roomId)
        doc.updateData([
            "memberIds": FieldValue.arrayUnion(value)
            ])
    }
    
    /// append new members to the already present member ids list on chat room
    /// - Parameter roomId: chat room id
    /// - Parameter memberIds: new member ids
    func appendMembersToChatRoom(roomId: String, memberIds: [String]) {
        let docRef = self.chatsFirestoreRef.document(roomId)
        docRef.updateData([
            "memberIds": FieldValue.arrayUnion(memberIds)
            ]
        )
    }
    
    ///get the name and icon information of a chat room for firestore database and adds listener on it to observe for real time changes
    func getChatRoomNameAndIcon(roomId: String, completion: @escaping (_ roomInfo: ChatRoom?) -> Void) -> ListenerRegistration {
        let handler = self.chatsFirestoreRef.document(roomId).addSnapshotListener { (snapshot, error) in
            guard error == nil else {
                return
            }
            if let document = snapshot?.data() {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document, options: .prettyPrinted)
                    let roomInfo = try JSONDecoder().decode(ChatRoom.self, from: jsonData)
                    roomInfo.chatRoomId = roomId
                    completion(roomInfo)
                } catch (_) {
                }
            } else {
                completion(nil)
            }
        }
        return handler
    }
    
    func getLiveSessionChats(sessionId: String, completion:@escaping (_ messages:[LiveSessionChat]?, _ error:Error?) -> Void){
        
        self.liveSessionsFirestoreRef.document(sessionId).collection("messages").order(by: "createdAt", descending: false).addSnapshotListener { snapShot, error in
            if error != nil{
                completion(nil,error)
            }else{
                if let documents = snapShot?.documents {
                    var data:[Parameters] = []
                    do{
                        for document in documents {
                            if document["message"] as! String != sessionId{
                                data.append(document.data())
                            }
                        }
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let messages = try JSONDecoder().decode([LiveSessionChat].self, from: jsonData)
                        completion(messages,nil)
                    }
                    catch (_){
                    }
                }
            }
        }
    }

    func writeJoinedCount(chatId:String){
        let timeStamp = Date().timeIntervalSince1970
        self.liveSessionsFirestoreRef.document(chatId).collection("liveStreamUsers").document("\(User.sharedInstance.id ?? "")").setData(["joinedAt":timeStamp])
    }
    
    func queryRecentlyJoinedMembers(_ chatID:String,completion: @escaping ((_ count:Int) -> ()) ){
        ///This is required to stop firing if view is not there
        streamJoinedListener?.remove()
        ///First callback whenever somebody joined or exit or changes his time
        streamJoinedListener = self.liveSessionsFirestoreRef.document(chatID).collection("liveStreamUsers").addSnapshotListener({ snapshot, error in
            if error == nil {
                ///Need a second query whenever a call back occures so that we can add recent modified date, and removing those who didn't update there recent time in 3 minutes
                let modifiedDate = (Calendar.current.date(byAdding: .second, value: Int(-StreamHelper.secForWriteDelay), to: Date())!).timeIntervalSince1970
                self.liveSessionsFirestoreRef.document(chatID).collection("liveStreamUsers").whereField("joinedAt", isGreaterThanOrEqualTo: modifiedDate).getDocuments(completion:{ snapshot, error in
                    if error == nil {
                        ///This call back shows counting
                        completion(snapshot?.count ?? 0)
                    }
                })
            }
        })
    }
    
    func removeRecentlyJoined(_ chatID:String) {
        self.liveSessionsFirestoreRef.document(chatID).collection("liveStreamUsers").document(User.sharedInstance.id ?? "").delete()
    }

    func addMessageToLiveSessionChat(sessionId:String,messageData:Parameters,completion:@escaping (_ error:Error?) -> Void){
        self.liveSessionsFirestoreRef.document(sessionId).collection("messages").addDocument(data: messageData) { error in
            if error != nil{
                completion(error)
            }else{
                completion(nil)
            }
        }
    }
}

//Firebase storage
extension ChatManager {
    
    func uploadDataToStorage(atPath path: String, roomId: String, messageId: String?, mimeType: String?, chatInfo: ChatRoom?, data: Data?, completion: @escaping (_ url: URL?, _ roomId: String, _ messageId: String?, _ chatInfo: ChatRoom?) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        let metadata = StorageMetadata()
        if let mimeType = mimeType {
            metadata.contentType = mimeType
            metadata.customMetadata = ["index": String(describing: index), "contentType": mimeType]
        }
        // Upload file and metadata to the object 'images/mountains.jpg'
        let dataPath = path + "\(UserManager.getCurrentUser()?.id ?? "")" + "\(Date().timeIntervalSince1970)"
        let imageReference = storageReference.child(dataPath)
        let uploadTask = imageReference.putData(data ?? Data(), metadata: metadata)
        
        uploadTask.observe(.progress) { (_) in
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            failure(snapshot.error)
        }
        
        uploadTask.observe(.success) { (_) in
            imageReference.downloadURL(completion: { (url, _) in
                completion(url, roomId, messageId, chatInfo)
            })
        }
    }
}

