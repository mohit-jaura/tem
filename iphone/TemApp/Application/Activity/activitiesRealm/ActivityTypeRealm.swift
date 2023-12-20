//
//	Type.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import Foundation
import RealmSwift

class ActivityTypeRealm: Object {
    
    @Persisted var activityData: ActivityDataRealm!
    @Persisted var activityType: Int
    @Persisted var id: Int
    @Persisted var image: String!
    @Persisted var isBinary: Int
    @Persisted var met: Double
    @Persisted var name: String!
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> ActivityTypeRealm	{
        let this = ActivityTypeRealm()
        if let dataData = dictionary["data"] as? [String:Any]{
            this.activityData = ActivityDataRealm.fromDictionary(dictionary: dataData)
        }
        if let activityTypeValue = dictionary["activityType"] as? Int{
            this.activityType = activityTypeValue
        }
        if let idValue = dictionary["id"] as? Int{
            this.id = idValue
        }
        if let imageValue = dictionary["image"] as? String{
            this.image = imageValue
        }
        if let isBinaryValue = dictionary["isBinary"] as? Int{
            this.isBinary = isBinaryValue
        }
        if let metValue = dictionary["met"] as? Double{
            this.met = metValue
        }
        if let nameValue = dictionary["name"] as? String{
            this.name = nameValue
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if activityData != nil{
            dictionary["data"] = activityData.toDictionary()
        }
        dictionary["activityType"] = activityType
        dictionary["id"] = id
        if image != nil{
            dictionary["image"] = image
        }
        dictionary["isBinary"] = isBinary
        dictionary["met"] = met
        if name != nil{
            dictionary["name"] = name
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        activityData = aDecoder.decodeObject(forKey: "data") as? ActivityDataRealm
        activityType = aDecoder.decodeObject(forKey: "activityType") as? Int ?? 0
        id = aDecoder.decodeObject(forKey: "id") as? Int ?? 0
        image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
        isBinary = aDecoder.decodeObject(forKey: "isBinary") as? Int ?? 0
        met = aDecoder.decodeObject(forKey: "met") as? Double ?? 0.0
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if activityData != nil{
            aCoder.encode(activityData, forKey: "data")
        }
        activityType = aCoder.decodeObject(forKey: "activityType") as? Int ?? 0
        id = aCoder.decodeObject(forKey: "id") as? Int ?? 0
        if image != nil{
            aCoder.encode(image, forKey: "image")
        }
        isBinary = aCoder.decodeObject(forKey: "isBinary") as? Int ?? 0
        met = aCoder.decodeObject(forKey: "met") as? Double ?? 0.0
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
    }
}
