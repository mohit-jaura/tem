//
//  Message.swift
//  TemApp
//
//  Created by shilpa on 26/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

enum MessageType: Int, Codable {
    case text = 0
    case image
    case video
    case pdf
}

enum MediaUploadStatus: Int, Codable {
    case isUploaded = 0 //the media upload has succeded
    case isUploading = 1 //the media upload is in progress
    case uploadingError = 2 //there is an error in media uploading
}

/// this class will hold the Message
struct Message: Codable {
    var id: String?
    var text: String? //message string
    var time: Double?   //time of the message (creation time)
    var senderId: String? //this will contain the id of the sender
    var type: MessageType? //type of the message whether it is text, video or image
    var media: Media? //this will store the media information like its previewUrl, duration etc.
    var isRead: CustomBool? // 0 : for false, 1: for true
    var chatRoomId: String? // id of the chat room
    var mediaUploadingStatus: MediaUploadStatus?
    
    var updatedAt: Double? //time at which the message was updated
    var userIds: [String]? //these will be the userids of all the members in the chat room
    
    //user information to set from firestore
    var sender: Friends?
    var chatType: ChatType?
    var taggedUsers: [UserTag]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text, time, senderId, type, media, isRead
        case chatRoomId = "chat_room_id"
        case mediaUploadingStatus = "uploadingStatus"
        case updatedAt
        case userIds
        case chatType
        case taggedUsers
    }
}

