//
//	Addres.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import RealmSwift

class AddresRealm: Object {
    
    @Persisted var userRealm: UserRealm!
    @Persisted var city: String?
    @Persisted var country: String?
    @Persisted var line: String?
    @Persisted var pincode: String?
    @Persisted var state: String?
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> AddresRealm	{
        let this = AddresRealm()
        if let userRealmData = dictionary["userRealm"] as? [String:Any]{
            this.userRealm = UserRealm.fromDictionary(dictionary: userRealmData)
        }
        if let cityValue = dictionary["city"] as? String{
            this.city = cityValue
        }
        if let countryValue = dictionary["country"] as? String{
            this.country = countryValue
        }
        if let lineValue = dictionary["line"] as? String{
            this.line = lineValue
        }
        if let pincodeValue = dictionary["pincode"] as? String{
            this.pincode = pincodeValue
        }
        if let stateValue = dictionary["state"] as? String{
            this.state = stateValue
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
        if city != nil{
            dictionary["city"] = city
        }
        if country != nil{
            dictionary["country"] = country
        }
        if line != nil{
            dictionary["line"] = line
        }
        if pincode != nil{
            dictionary["pincode"] = pincode
        }
        if state != nil{
            dictionary["state"] = state
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
        city = aDecoder.decodeObject(forKey: "city") as? String
        country = aDecoder.decodeObject(forKey: "country") as? String
        line = aDecoder.decodeObject(forKey: "line") as? String
        pincode = aDecoder.decodeObject(forKey: "pincode") as? String
        state = aDecoder.decodeObject(forKey: "state") as? String
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
        if city != nil{
            aCoder.encode(city, forKey: "city")
        }
        if country != nil{
            aCoder.encode(country, forKey: "country")
        }
        if line != nil{
            aCoder.encode(line, forKey: "line")
        }
        if pincode != nil{
            aCoder.encode(pincode, forKey: "pincode")
        }
        if state != nil{
            aCoder.encode(state, forKey: "state")
        }
    }
}
