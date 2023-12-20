//
//	ActivitiesRealm.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import Foundation
import RealmSwift

class ActivitiesRealm: Object {
    
    @Persisted var activitiesData: List<ActivityDataRealm>
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> ActivitiesRealm	{
        let this = ActivitiesRealm()
        if let dataArray = dictionary["data"] as? [[String:Any]]{
            var dataItems = List<ActivityDataRealm>()
            for dic in dataArray{
                let value = ActivityDataRealm.fromDictionary(dictionary: dic)
                dataItems.append(value)
            }
            this.activitiesData = dataItems
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        var dictionaryElements = [[String:Any]]()
        for i in 0 ..< activitiesData.count {
            let dataElement = activitiesData[i]
            dictionaryElements.append(dataElement.toDictionary())
        }
        dictionary["data"] = dictionaryElements
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        activitiesData = aDecoder.decodeObject(forKey: "data") as? List<ActivityDataRealm> ?? List<ActivityDataRealm>()
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(activitiesData, forKey: "data")
    }
    
}
