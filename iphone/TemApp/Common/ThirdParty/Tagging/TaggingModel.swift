//
//  TaggingModel.swift
//  Tagging
//
//  Created by DongHeeKang on 2018. 6. 17..
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation

public struct TaggingModel {
    public var text: String
    public var range: NSRange
    public var id: String

    func getDictonary() -> [String:String] {
        let dict:[String:String] = ["id":id,"text":text]
        
        return dict
    }
    
    func toUserTagModel() -> UserTag {
        var userTag = UserTag()
        userTag.id = self.id
        userTag.text = self.text
        return userTag
    }
}

