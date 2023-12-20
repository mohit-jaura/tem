//
//  TagInfo+CoreDataClass.swift
//  TemApp
//
//  Created by shilpa on 19/12/19.
//

import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {
}

extension Tag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var postId: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var profilePic: String?
    @NSManaged public var pointX: NSNumber?
    @NSManaged public var pointY: NSNumber?
    
    
    override func saveDetailsInDB(object: Any) {
        let tag = object as! UserTag
        self.id = tag.id
        self.text = tag.text
        self.postId = tag.postId
        self.firstName = tag.firstName
        self.lastName = tag.lastName
        self.profilePic = tag.profilePic
        self.pointX = tag.centerX as NSNumber?
        self.pointY = tag.centerY as NSNumber?
    }
}
