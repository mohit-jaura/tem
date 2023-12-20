//
//	Height.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import RealmSwift

class HeightRealm: Object {
    
    @Persisted var userRealm: UserRealm!
    @Persisted var feet: Int?
    @Persisted var inch: Int?
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> HeightRealm	{
        let this = HeightRealm()
        if let userRealmData = dictionary["userRealm"] as? [String:Any]{
            this.userRealm = UserRealm.fromDictionary(dictionary: userRealmData)
        }
        if let feetValue = dictionary["feet"] as? Int{
            this.feet = feetValue
        }
        if let inchValue = dictionary["inch"] as? Int{
            this.inch = inchValue
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
        dictionary["feet"] = feet
        dictionary["inch"] = inch
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        userRealm = aDecoder.decodeObject(forKey: "userRealm") as? UserRealm
        feet = aDecoder.decodeObject(forKey: "feet") as? Int
        inch = aDecoder.decodeObject(forKey: "inch") as? Int
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if userRealm != nil{
            aCoder.encode(userRealm, forKey: "userRealm")
        }
        feet = aCoder.decodeObject(forKey: "feet") as? Int
        inch = aCoder.decodeObject(forKey: "inch") as? Int
        
    }
    
}
