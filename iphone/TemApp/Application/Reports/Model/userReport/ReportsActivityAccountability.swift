//
//	ReportsActivityAccountability.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import RealmSwift


class ReportsActivityAccountability: Object {

    @Persisted var totalActivityReport: TotalActivityReport!
    @Persisted var flag: Int?
    @Persisted var value: Double?

    override init() {
        super.init()
    }
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	class func fromDictionary(dictionary: [String:Any]) -> ReportsActivityAccountability	{
		let this = ReportsActivityAccountability()
		if let totalActivityReportData = dictionary["totalActivityReport"] as? [String:Any]{
			this.totalActivityReport = TotalActivityReport.fromDictionary(dictionary: totalActivityReportData)
		}
		if let flagValue = dictionary["flag"] as? Int{
			this.flag = flagValue
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
         value = aCoder.decodeObject(forKey: "value") as? Double

	}

}
