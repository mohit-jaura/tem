//
//  SocialMediaRealm.swift
//  TemApp
//
//  Created by Mohit Soni on 31/01/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation
import RealmSwift

class SocialMediaRealm: Object {
    
    @Persisted var userRealm: UserRealm!
    @Persisted var id: String?
    @Persisted var createdAt: String?
    @Persisted var firstName: String?
    @Persisted var lastName: String?
    @Persisted var snsId: String?
    @Persisted var snsType: Int?
    @Persisted var updatedAt: String?
    
    override init() {
        super.init()
    }
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> SocialMediaRealm{
        let this = SocialMediaRealm()
        if let userData = dictionary["userRealm"] as? [String:Any]{
            this.userRealm = UserRealm.fromDictionary(dictionary: userData)
        }
        if let idValue = dictionary["_id"] as? String{
            this.id = idValue
        }
        if let createdAtValue = dictionary["created_at"] as? String{
            this.createdAt = createdAtValue
        }
        if let firstNameValue = dictionary["first_name"] as? String{
            this.firstName = firstNameValue
        }
        if let lastNameValue = dictionary["last_name"] as? String{
            this.lastName = lastNameValue
        }
        if let snsIdValue = dictionary["sns_id"] as? String{
            this.snsId = snsIdValue
        }
        if let snsTypeValue = dictionary["sns_type"] as? Int{
            this.snsType = snsTypeValue
        }
        if let updatedAtValue = dictionary["updated_at"] as? String{
            this.updatedAt = updatedAtValue
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if userRealm != nil{
            dictionary["userRealm"] = userRealm.toDictionary()
        }
        if id != nil{
            dictionary["_id"] = id
        }
        if createdAt != nil{
            dictionary["created_at"] = createdAt
        }
        if firstName != nil{
            dictionary["first_name"] = firstName
        }
        if lastName != nil{
            dictionary["last_name"] = lastName
        }
        if snsId != nil{
            dictionary["sns_id"] = snsId
        }
        dictionary["sns_type"] = snsType
        if updatedAt != nil{
            dictionary["updated_at"] = updatedAt
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        userRealm = aDecoder.decodeObject(forKey: "userRealm") as? UserRealm
        id = aDecoder.decodeObject(forKey: "_id") as? String
        createdAt = aDecoder.decodeObject(forKey: "created_at") as? String
        firstName = aDecoder.decodeObject(forKey: "first_name") as? String
        lastName = aDecoder.decodeObject(forKey: "last_name") as? String
        snsId = aDecoder.decodeObject(forKey: "sns_id") as? String
        snsType = aDecoder.decodeObject(forKey: "sns_type") as? Int
        updatedAt = aDecoder.decodeObject(forKey: "updated_at") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if userRealm != nil{
            aCoder.encode(userRealm, forKey: "rootClass")
        }
        if id != nil{
            aCoder.encode(id, forKey: "_id")
        }
        if createdAt != nil{
            aCoder.encode(createdAt, forKey: "created_at")
        }
        if firstName != nil{
            aCoder.encode(firstName, forKey: "first_name")
        }
        if lastName != nil{
            aCoder.encode(lastName, forKey: "last_name")
        }
        if snsId != nil{
            aCoder.encode(snsId, forKey: "sns_id")
        }
        snsType = aCoder.decodeObject(forKey: "sns_type") as? Int
        if updatedAt != nil{
            aCoder.encode(updatedAt, forKey: "updated_at")
        }
    }
}
