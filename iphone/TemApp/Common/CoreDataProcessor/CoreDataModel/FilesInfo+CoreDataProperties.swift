//
//  FilesInfo+CoreDataProperties.swift
//
//  Created by Dhiraj on 21/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import CoreData


extension FilesInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FilesInfo> {
        return NSFetchRequest<FilesInfo>(entityName: "FilesInfo")
    }

    @NSManaged public var id: String?
    @NSManaged public var isuploaded: Bool
    @NSManaged public var postId: String?
    @NSManaged public var type: String?
    @NSManaged public var name: String?

    @NSManaged public var firebaseurl: String?
    @NSManaged public var previewurl: String?
    @NSManaged public var spot_rel: Postinfo?
    @NSManaged public var height: NSNumber?
    @NSManaged public var tag_rel: NSSet?

    override func saveDetailsInDB(object: Any) {

        let media:Media = object as! Media
        postId = media.postId
        name = media.name
        id = "File_" + getAutoIncremenet(objectId: self.objectID)
        isuploaded = false
        if let value = media.height as NSNumber? {
            height = value
        } else {
            print("could not save media height in core data")
        }

        if media.type == MediaType.photo {
            type = "photo"
        } else if media.type == MediaType.video {
            type = "video"
        }

        previewurl = media.previewImageUrl
        firebaseurl = media.url
    }

    @objc(addTag_relObject:)
    @NSManaged public func addToTag_rel(_ value: Tag)
    
    @objc(removeTag_relObject:)
    @NSManaged public func removeFromTag_rel(_ value: Tag)
    
    @objc(addTag_rel:)
    @NSManaged public func addToTag_rel(_ values: NSOrderedSet)
    
    @objc(removeTag_rel:)
    @NSManaged public func removeFromTag_rel(_ values: NSOrderedSet)
}
