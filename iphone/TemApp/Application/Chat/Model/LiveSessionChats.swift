//
//  LiveSessionChats.swift
//  TemApp
//
//  Created by Mohit Soni on 29/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation


struct LiveSessionChat:Codable{
    let chat_room_id:String?
    let id:String?
    let createdAt:Double?
    let userName:String?
    let userImage:String?
    let message:String?
    
    enum CodingKeys:String,CodingKey{
        case chat_room_id, id, createdAt, userName, userImage, message
    }
    
    func getDict() -> Parameters{
        let dict:[String:Any] = [
            CodingKeys.chat_room_id.rawValue : chat_room_id ?? "",
            CodingKeys.id.rawValue : id ?? "",
            CodingKeys.createdAt.rawValue : createdAt ?? 0.0,
            CodingKeys.userName.rawValue : userName ?? "",
            CodingKeys.userImage.rawValue : userImage ?? "",
            CodingKeys.message.rawValue : message ?? ""
        ]
        return dict
    }
}
