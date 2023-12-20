//
//  JourneyNote.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct JourneyNote: Decodable {
    let noteId: String?
    let message: String?
    var updatedAt: String?
    let senderId: String?
    let firstName: String?
    let lastName: String?
    let senderImage: String?

    enum CodingKeys: String, CodingKey {
        case noteId = "_id"
        case message = "message"
        case updatedAt = "updated_at"
        case senderId = "senderId"
        case firstName = "first_name"
        case lastName = "last_name"
        case senderImage = "profile_pic"
    }

}
