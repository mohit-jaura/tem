//
//	Graph.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift


class UserReportGraphRealm: Object {

	@Persisted var userReportDataRealm: UserReportDataRealm!
    @Persisted var date: String!
    @Persisted var score: Double?


    
    override init() {
        super.init()
    }
    
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	class func fromDictionary(dictionary: [String:Any]) -> UserReportGraphRealm	{
		let this = UserReportGraphRealm()
		if let userReportDataRealmData = dictionary["userReportDataRealm"] as? [String:Any]{
            this.userReportDataRealm = UserReportDataRealm.fromDictionary(dictionary: userReportDataRealmData)
		}
		if let dateValue = dictionary["date"] as? String{
			this.date = dateValue
		}
		if let scoreValue = dictionary["score"] as? Double{
			this.score = scoreValue
		}
		return this
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if userReportDataRealm != nil{
			dictionary["userReportDataRealm"] = userReportDataRealm.toDictionary()
		}
		if date != nil{
			dictionary["date"] = date
		}
		dictionary["score"] = score
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         userReportDataRealm = aDecoder.decodeObject(forKey: "userReportDataRealm") as? UserReportDataRealm
         date = aDecoder.decodeObject(forKey: "date") as? String
         score = aDecoder.decodeObject(forKey: "score") as? Double

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if userReportDataRealm != nil{
			aCoder.encode(userReportDataRealm, forKey: "userReportDataRealm")
		}
		if date != nil{
			aCoder.encode(date, forKey: "date")
		}
         score = aCoder.decodeObject(forKey: "score") as? Double

	}

}
