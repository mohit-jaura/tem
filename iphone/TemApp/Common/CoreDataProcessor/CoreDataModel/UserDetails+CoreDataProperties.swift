//
//  UserDetails+CoreDataProperties.swift
//  TemApp
//
//  Created by shilpa on 03/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import CoreData
extension UserDetail {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserDetail> {
        return NSFetchRequest<UserDetail>(entityName: Constant.CoreData.userEntity)
    }
    
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var profilePic: String?
    @NSManaged public var userName: String?
    @NSManaged public var id: String?
    @NSManaged public var postId: String?
    @NSManaged public var spot_rel: Postinfo?
    
    //save details
    override func saveDetailsInDB(object: Any) {
        let user: Friends = object as! Friends
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.profilePic = user.profilePic
        self.userName = user.userName
        self.id = user.id
    }
}
