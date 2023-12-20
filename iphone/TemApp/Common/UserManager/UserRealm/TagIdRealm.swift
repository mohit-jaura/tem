//
//	TagId.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import RealmSwift

class TagIdRealm: Object {
    
    @Persisted var userRealm: UserRealm!
    @Persisted var id: String?
    @Persisted var tagDate: Int?
    @Persisted var text: String?
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> TagIdRealm	{
        let this = TagIdRealm()
        if let userRealmData = dictionary["userRealm"] as? [String:Any]{
            this.userRealm = UserRealm.fromDictionary(dictionary: userRealmData)
        }
        if let idValue = dictionary["_id"] as? String{
            this.id = idValue
        }
        if let tagDateValue = dictionary["tag_date"] as? Int{
            this.tagDate = tagDateValue
        }
        if let textValue = dictionary["text"] as? String{
            this.text = textValue
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
        dictionary["tag_date"] = tagDate
        if text != nil{
            dictionary["text"] = text
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
        tagDate = aDecoder.decodeObject(forKey: "tag_date") as? Int
        text = aDecoder.decodeObject(forKey: "text") as? String
        
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
        if id != nil{
            aCoder.encode(id, forKey: "_id")
        }
        tagDate = aCoder.decodeObject(forKey: "tag_date") as? Int
        if text != nil{
            aCoder.encode(text, forKey: "text")
        }
        
    }
    
}
