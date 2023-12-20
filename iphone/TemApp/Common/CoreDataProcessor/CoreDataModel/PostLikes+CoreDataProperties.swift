//
//  PostLikes+CoreDataProperties.swift
//  TemApp
//
//  Created by shilpa on 16/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import CoreData

extension LikesInfo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikesInfo> {
        return NSFetchRequest<LikesInfo>(entityName: "LikesInfo")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var profilePic: String?
    
    override func saveDetailsInDB(object: Any) {
        let like = object as! Likes
        self.id = like.id
        self.profilePic = like.profilePic
    }
}
