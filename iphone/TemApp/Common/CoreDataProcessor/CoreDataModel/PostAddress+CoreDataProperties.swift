//
//  SpotAddress+CoreDataProperties.swift
//
//  Created by Dhiraj on 21/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import CoreData


extension PostAddress {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostAddress> {
        return NSFetchRequest<PostAddress>(entityName: "PostAddress")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var postId: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var cordinates: [Double]?
    @NSManaged public var country: String?
    @NSManaged public var spot_rel: Postinfo?
    
    override func saveDetailsInDB(object: Any) {
        
        /* let postInfo = object as! Postinfo
        postId = postInfo.id
        id = "Add" + String(Utility.shared.currentTimeStamp())
        city = postInfo.address_rel?.city
        state = postInfo.address_rel?.state
        country = postInfo.address_rel?.country
        self.cordinates = postInfo.address_rel?.cordinates */
        
        let address = object as! Address
        id = "Add" + String(Utility.shared.currentTimeStamp())
        city = address.city
        state = address.state
        country = address.country
        
        // uncomment this code
        self.cordinates = []
        if let long = address.lng {
            self.cordinates?.append(long)
        }
        if let lat = address.lat {
            self.cordinates?.append(lat)
        }
    }
}
