//
//	Gym.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import RealmSwift



class GymRealm: Object {
    
    @Persisted var userRealm: UserRealm!
    @Persisted var gymTypeMandatory: Int?
    @Persisted var location: List<Double>
    @Persisted var name: String?
    @Persisted var placeId: String?
    @Persisted var type: Int?
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> GymRealm	{
        let this = GymRealm()
        if let userRealmData = dictionary["userRealm"] as? [String:Any]{
            this.userRealm = UserRealm.fromDictionary(dictionary: userRealmData)
        }
        if let gymTypeMandatoryValue = dictionary["gym_type_mandatory"] as? Int{
            this.gymTypeMandatory = gymTypeMandatoryValue
        }
        if let locationArray = dictionary["location"] as? [Double]{
            var locationItems = List<Double>()
            for value in locationArray{
                locationItems.append(value)
            }
            this.location = locationItems
        }
        if let nameValue = dictionary["name"] as? String{
            this.name = nameValue
        }
        if let placeIdValue = dictionary["place_id"] as? String{
            this.placeId = placeIdValue
        }
        if let typeValue = dictionary["type"] as? Int{
            this.type = typeValue
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
        dictionary["gym_type_mandatory"] = gymTypeMandatory
        var dictionaryElements = [Double]()
        for i in 0 ..< location.count {
            let locationElement = location[i]
            dictionaryElements.append(locationElement)
        }
        dictionary["location"] = dictionaryElements
        if name != nil{
            dictionary["name"] = name
        }
        if placeId != nil{
            dictionary["place_id"] = placeId
        }
        dictionary["type"] = type
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        userRealm = aDecoder.decodeObject(forKey: "userRealm") as? UserRealm
        gymTypeMandatory = aDecoder.decodeObject(forKey: "gym_type_mandatory") as? Int
        location = aDecoder.decodeObject(forKey: "location") as? List<Double> ?? List<Double>()
        name = aDecoder.decodeObject(forKey: "name") as? String
        placeId = aDecoder.decodeObject(forKey: "place_id") as? String
        type = aDecoder.decodeObject(forKey: "type") as? Int
        
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
        gymTypeMandatory = aCoder.decodeObject(forKey: "gym_type_mandatory") as? Int
        aCoder.encode(location, forKey: "location")
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if placeId != nil{
            aCoder.encode(placeId, forKey: "place_id")
        }
        type = aCoder.decodeObject(forKey: "type") as? Int
        
    }
    
}
