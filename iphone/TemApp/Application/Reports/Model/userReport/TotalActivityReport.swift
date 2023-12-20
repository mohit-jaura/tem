//
//	TotalActivityReport.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import RealmSwift

class TotalActivityReport: Object {
    
    @Persisted var activityAccountability: ReportsActivityAccountability!
    @Persisted var averageCalories: AverageCalory!
    @Persisted var averageDailySteps: ReportsActivityAccountability!
    @Persisted var averageDistance: AverageDistance!
    @Persisted var averageDuration: AverageDuration!
    @Persisted var averageSleep: ReportsActivityAccountability!
    @Persisted var goalCompletionRate: Float?
    @Persisted var totalActivities: ReportsActivityAccountability!
    @Persisted var totalActivityScore: AverageCalory!
    @Persisted var totalActivityTypes: ReportsActivityAccountability!
    @Persisted var totalAppScore: Float?
    @Persisted var userId: String!
    @Persisted var userReportDataRealm: UserReportDataRealm!
    
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> TotalActivityReport	{
        let this = TotalActivityReport()
        
        if let activityAccountabilityData = dictionary["activityAccountability"] as? [String:Any]{
            this.activityAccountability = ReportsActivityAccountability.fromDictionary(dictionary: activityAccountabilityData)
        }
        if let averageCaloriesData = dictionary["averageCalories"] as? [String:Any]{
            this.averageCalories = AverageCalory.fromDictionary(dictionary: averageCaloriesData)
        }
        if let averageDailyStepsData = dictionary["averageDailySteps"] as? [String:Any]{
            this.averageDailySteps = ReportsActivityAccountability.fromDictionary(dictionary: averageDailyStepsData)
        }
        if let averageDistanceData = dictionary["averageDistance"] as? [String:Any]{
            this.averageDistance = AverageDistance.fromDictionary(dictionary:averageDistanceData)
        }
        if let averageDurationData = dictionary["averageDuration"] as? [String:Any]{
            this.averageDuration = AverageDuration.fromDictionary(dictionary:averageDurationData)
        }
        if let averageSleepData = dictionary["averageSleep"] as? [String:Any]{
            this.averageSleep = ReportsActivityAccountability.fromDictionary(dictionary: averageSleepData)
        }
        if let goalCompletionRateValue = dictionary["goalCompletionRate"] as? Float{
            this.goalCompletionRate = goalCompletionRateValue
        }
        if let totalActivitiesData = dictionary["totalActivities"] as? [String:Any]{
            this.totalActivities = ReportsActivityAccountability.fromDictionary(dictionary: totalActivitiesData)
        }
        if let totalActivityScoreData = dictionary["totalActivityScore"] as? [String:Any]{
            this.totalActivityScore = AverageCalory.fromDictionary(dictionary:totalActivityScoreData)
        }
        if let totalActivityTypesData = dictionary["totalActivityTypes"] as? [String:Any]{
            this.totalActivityTypes = ReportsActivityAccountability.fromDictionary(dictionary: totalActivityTypesData)
        }
        if let totalAppScoreValue = dictionary["totalAppScore"] as? Float{
            this.totalAppScore = totalAppScoreValue
        }
        if let userIdValue = dictionary["userId"] as? String{
            this.userId = userIdValue
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if activityAccountability != nil{
            dictionary["activityAccountability"] = activityAccountability.toDictionary()
        }
        if averageCalories != nil{
            dictionary["averageCalories"] = averageCalories.toDictionary()
        }
        if averageDailySteps != nil{
            dictionary["averageDailySteps"] = averageDailySteps.toDictionary()
        }
        if averageDistance != nil{
            dictionary["averageDistance"] = averageDistance.toDictionary()
        }
        if averageDuration != nil{
            dictionary["averageDuration"] = averageDuration.toDictionary()
        }
        if averageSleep != nil{
            dictionary["averageSleep"] = averageSleep.toDictionary()
        }
        dictionary["goalCompletionRate"] = goalCompletionRate
        if totalActivities != nil{
            dictionary["totalActivities"] = totalActivities.toDictionary()
        }
        if totalActivityScore != nil{
            dictionary["totalActivityScore"] = totalActivityScore.toDictionary()
        }
        if totalActivityTypes != nil{
            dictionary["totalActivityTypes"] = totalActivityTypes.toDictionary()
        }
        dictionary["totalAppScore"] = totalAppScore
        if userId != nil{
            dictionary["userId"] = userId
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        activityAccountability = aDecoder.decodeObject(forKey: "activityAccountability") as? ReportsActivityAccountability
        averageCalories = aDecoder.decodeObject(forKey: "averageCalories") as? AverageCalory
        averageDailySteps = aDecoder.decodeObject(forKey: "averageDailySteps") as? ReportsActivityAccountability
        averageDistance = aDecoder.decodeObject(forKey: "averageDistance") as? AverageDistance
        averageDuration = aDecoder.decodeObject(forKey: "averageDuration") as? AverageDuration
        averageSleep = aDecoder.decodeObject(forKey: "averageSleep") as? ReportsActivityAccountability
        goalCompletionRate = aDecoder.decodeObject(forKey: "goalCompletionRate") as? Float
        totalActivities = aDecoder.decodeObject(forKey: "totalActivities") as? ReportsActivityAccountability
        totalActivityScore = aDecoder.decodeObject(forKey: "totalActivityScore") as? AverageCalory
        totalActivityTypes = aDecoder.decodeObject(forKey: "totalActivityTypes") as? ReportsActivityAccountability
        totalAppScore = aDecoder.decodeObject(forKey: "totalAppScore") as? Float
        userId = aDecoder.decodeObject(forKey: "userId") as? String
        
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
        if activityAccountability != nil{
            aCoder.encode(activityAccountability, forKey: "activityAccountability")
        }

        if averageCalories != nil{
            aCoder.encode(averageCalories, forKey: "averageCalories")
        }
        if averageDailySteps != nil{
            aCoder.encode(averageDailySteps, forKey: "averageDailySteps")
        }
        if averageDistance != nil{
            aCoder.encode(averageDistance, forKey: "averageDistance")
        }
        if averageDuration != nil{
            aCoder.encode(averageDuration, forKey: "averageDuration")
        }
        if averageSleep != nil{
            aCoder.encode(averageSleep, forKey: "averageSleep")
        }

        if totalActivityScore != nil{
            aCoder.encode(totalActivityScore, forKey: "totalActivityScore")
        }
        if totalActivityTypes != nil{
            aCoder.encode(totalActivityTypes, forKey: "totalActivityTypes")
        }
        totalAppScore = aCoder.decodeObject(forKey: "totalAppScore") as? Float
        if userId != nil{
            aCoder.encode(userId, forKey: "userId")
        }
        
    }
    
}
