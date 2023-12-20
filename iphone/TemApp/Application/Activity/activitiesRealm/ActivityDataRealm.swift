//
//	Data.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import Foundation
import RealmSwift

class ActivityDataRealm: Object {
    
    @Persisted var activitiesRealm: ActivitiesRealm?
    @Persisted var categoryName: String?
    @Persisted var categoryType: Int?
    @Persisted var activityType: List<ActivityTypeRealm>
    
    override init() {
        super.init()
    }
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> ActivityDataRealm	{
        let this = ActivityDataRealm()
        if let activitiesRealmData = dictionary["activitiesRealm"] as? [String:Any]{
            this.activitiesRealm = ActivitiesRealm.fromDictionary(dictionary: activitiesRealmData)
        }
        if let categoryNameValue = dictionary["category_name"] as? String{
            this.categoryName = categoryNameValue
        }
        if let categoryTypeValue = dictionary["category_type"] as? Int{
            this.categoryType = categoryTypeValue
        }
        if let typeArray = dictionary["type"] as? [[String:Any]]{
            var typeItems = List<ActivityTypeRealm>()
            for dic in typeArray{
                let value = ActivityTypeRealm.fromDictionary(dictionary: dic)
                typeItems.append(value)
            }
            this.activityType = typeItems
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if let activitiesRealm = activitiesRealm {
            dictionary["activitiesRealm"] = activitiesRealm.toDictionary()
        }
        dictionary["category_name"] = categoryName
        dictionary["category_type"] = categoryType
        if activityType.count > 0 {
            var dictionaryElements = [[String:Any]]()
            for i in 0 ..< activityType.count {
                let typeElement = activityType[i]
                dictionaryElements.append(typeElement.toDictionary())
                dictionary["type"] = dictionaryElements
            }
        }
        return dictionary
    }
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        activitiesRealm = aDecoder.decodeObject(forKey: "activitiesRealm") as? ActivitiesRealm
        categoryName = aDecoder.decodeObject(forKey: "category_name") as? String
        categoryType = aDecoder.decodeObject(forKey: "category_type") as? Int ?? 0
        activityType = aDecoder.decodeObject(forKey: "type") as? List<ActivityTypeRealm> ?? List<ActivityTypeRealm>()
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if activitiesRealm != nil{
            aCoder.encode(activitiesRealm, forKey: "activitiesRealm")
        }
        if categoryName != nil{
            aCoder.encode(categoryName, forKey: "category_name")
        }
        categoryType = aCoder.decodeObject(forKey: "category_type") as? Int
        if activityType != nil{
            aCoder.encode(activityType, forKey: "type")
        }
    }
}
