//
//	HaisScoreReportRealm.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import RealmSwift

class HaisScoreReportRealm: Object {
    
    @Persisted var activityLogPointTotal: Double?
    @Persisted var biomarkerPillarScore: Double?
    @Persisted var nutritionScore: Double?
    @Persisted var sum: Double?
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> HaisScoreReportRealm	{
        let this = HaisScoreReportRealm()
        if let activityLogPointTotalValue = dictionary["activity_log_point_total"] as? Double{
            this.activityLogPointTotal = activityLogPointTotalValue
        }
        if let biomarkerPillarScoreValue = dictionary["biomarker_pillar_score"] as? Double{
            this.biomarkerPillarScore = biomarkerPillarScoreValue
        }
        if let nutritionScoreValue = dictionary["nutrition_score"] as? Double{
            this.nutritionScore = nutritionScoreValue
        }
        if let sumValue = dictionary["sum"] as? Double{
            this.sum = sumValue
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        dictionary["activity_log_point_total"] = activityLogPointTotal
        dictionary["biomarker_pillar_score"] = biomarkerPillarScore
        dictionary["nutrition_score"] = nutritionScore
        dictionary["sum"] = sum
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        activityLogPointTotal = aDecoder.decodeObject(forKey: "activity_log_point_total") as? Double
        biomarkerPillarScore = aDecoder.decodeObject(forKey: "biomarker_pillar_score") as? Double
        nutritionScore = aDecoder.decodeObject(forKey: "nutrition_score") as? Double
        sum = aDecoder.decodeObject(forKey: "sum") as? Double
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        activityLogPointTotal = aCoder.decodeObject(forKey: "activity_log_point_total") as? Double
        biomarkerPillarScore = aCoder.decodeObject(forKey: "biomarker_pillar_score") as? Double
        nutritionScore = aCoder.decodeObject(forKey: "nutrition_score") as? Double
        sum = aCoder.decodeObject(forKey: "sum") as? Double
    }
    
}
