//
//	AverageDistance.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import RealmSwift

class AverageDistance: Object {

    @Persisted var totalActivityReport: TotalActivityReport!
    @Persisted var flag: Int?
    @Persisted var unit: String!
    @Persisted var value: Double?

    override init() {
        super.init()
    }
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	class func fromDictionary(dictionary: [String:Any]) -> AverageDistance	{
		let this = AverageDistance()
		if let totalActivityReportData = dictionary["totalActivityReport"] as? [String:Any]{
			this.totalActivityReport = TotalActivityReport.fromDictionary(dictionary: totalActivityReportData)
		}
		if let flagValue = dictionary["flag"] as? Int{
			this.flag = flagValue
		}
		if let unitValue = dictionary["unit"] as? String{
			this.unit = unitValue
		}
		if let valueValue = dictionary["value"] as? Double{
			this.value = valueValue
		}
		return this
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if totalActivityReport != nil{
			dictionary["totalActivityReport"] = totalActivityReport.toDictionary()
		}
		dictionary["flag"] = flag
		if unit != nil{
			dictionary["unit"] = unit
		}
		dictionary["value"] = value
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         totalActivityReport = aDecoder.decodeObject(forKey: "totalActivityReport") as? TotalActivityReport
         flag = aDecoder.decodeObject(forKey: "flag") as? Int
         unit = aDecoder.decodeObject(forKey: "unit") as? String
         value = aDecoder.decodeObject(forKey: "value") as? Double

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if totalActivityReport != nil{
			aCoder.encode(totalActivityReport, forKey: "totalActivityReport")
		}
         flag = aCoder.decodeObject(forKey: "flag") as? Int
		if unit != nil{
			aCoder.encode(unit, forKey: "unit")
		}
         value = aCoder.decodeObject(forKey: "value") as? Double

	}

}
