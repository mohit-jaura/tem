//
//  ActivityAddOnsModal.swift
//  TemApp
//
//  Created by PrabSharan on 27/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation


class TimePicker {
    class func presentPicker(_ parent:DIBaseController?,completion:@escaping H_M_S_Competion) {
        let VC = loadVC(.AddTimePickerVC) as! AddTimePickerVC
        VC.modalTransitionStyle = .coverVertical
        VC.modalPresentationStyle = .overCurrentContext
        VC.doneButton = completion
        parent?.present(VC, animated: true, completion: nil)
    }
}
struct ActivityAddOnWithCount {
    let count :Int?
    let name:String?
}
struct EventActivitiesDataModal: Codable{
    var status: Int?
    var message: String?
    var data:[ActivityData]?
    var url:String?
    enum CodingKeys:String,CodingKey{
        case status = "status"
        case message = "message"
        case data = "data"
        case url = "url"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent([ActivityData].self, forKey: .data)
        url = try values.decodeIfPresent(String.self, forKey: .url)

    }
}
struct ActivityAddOns : Codable {
    let category_id : Int?
    let category_name : String?
    let activity_id : Int?
    let activity_name : String?
    var time : Int?
    var isManadatory : Int?
    var visibleTime:String?
    var oldTime:Int?
    var met:Double?
    var image:String?
    var category_type: Int?
    var oldVisibleTime:String?
    var isBinary: Int?  // this type of activities  doest not contain distance and time. It will only logged in the app. // 1 for false and 0 for true
    var isNutritionCategory: Bool = false

    enum CodingKeys: String, CodingKey {
        case category_type
        case category_id = "category_id"
        case category_name = "category_name"
        case activity_id = "activity_id"
        case activity_name = "activity_name"
        case time = "time"
        case met = "met"
        case image = "image"
        case isManadatory = "isMandatory"
        case isBinary
    }
    init(_ category_id:Int?,_ category_name:String?,_ activity_id:Int?,_ activity_name : String?,_ time : Int?,_ isManadatory : Int?,_ image:String?,_ met:Double?, _ isBinary: Int? ) {
        self.category_id = category_id
        self.category_name = category_name
        self.activity_id = activity_id
        self.activity_name = activity_name
        self.time = time
        self.met = met
        self.image = image
        self.isBinary = isBinary
        self.isManadatory = isManadatory
        let (h,m,s) = Utility.shared.secondsToHoursMinutesSeconds(seconds: time ?? 0)
        self.visibleTime = "\(h)h \(m)m \(s)s"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category_id = try values.decodeIfPresent(Int.self, forKey: .category_id)
        category_name = try values.decodeIfPresent(String.self, forKey: .category_name)
        
        met = try values.decodeIfPresent(Double.self, forKey: .met)
        image = try values.decodeIfPresent(String.self, forKey: .image)

        
        activity_id = try values.decodeIfPresent(Int.self, forKey: .activity_id)
        activity_name = try values.decodeIfPresent(String.self, forKey: .activity_name)
        time = try values.decodeIfPresent(Int.self, forKey: .time)
        isManadatory = try values.decodeIfPresent(Int.self, forKey: .isManadatory)
    }
    static func inDic(_ activityArr:[ActivityAddOns]?) -> [[String:Any]]? {
        var dic :[[String:Any]] = []

        for i in 0..<(activityArr?.count ?? 0) {
            var params : [String:Any] = [:]
            params[CodingKeys.time.rawValue] = activityArr?[i].time
            params[CodingKeys.category_id.rawValue] = activityArr?[i].category_id
            params[CodingKeys.category_name.rawValue] = activityArr?[i].category_name
            params[CodingKeys.activity_id.rawValue] = activityArr?[i].activity_id
            params[CodingKeys.activity_name.rawValue] = activityArr?[i].activity_name
            params[CodingKeys.isManadatory.rawValue] = activityArr?[i].isManadatory
            params[CodingKeys.met.rawValue] = activityArr?[i].met
            params[CodingKeys.image.rawValue] = activityArr?[i].image
            if activityArr?[i].isBinary == nil{
                params[CodingKeys.isBinary.rawValue] = true
            } else{
                params[CodingKeys.isBinary.rawValue] = activityArr?[i].isBinary
            }
            dic.append(params)
        }
        return dic
    }

}

struct EventActStartDataModal : Codable {
    let message : String?
    let status : Int?
    let data : EventActStarted?

    enum CodingKeys: String, CodingKey {

        case message = "message"
        case status = "status"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent(EventActStarted.self, forKey: .data)
    }

}
struct EventActStarted : Codable {
    let activityType : Int?
    let isScheduled : Int?
    let activityTarget : String?
    let activityId : Int?
    let activityName : String?
    let rating : Int?
    let date : Int?
    let activityImage : String?
    let categoryType : String?
    let timeSpent : Int?
    let distanceCovered : Int?
    let status : Int?
    let sleep : Int?
    let calories : Int?
    let steps : Int?
    let durationId : Int?
    let distanceId : Int?
    let origin : String?
    let _id : String?
    let startDate : Int?
    let userId : String?
    let created_at : String?
    let updatedAt : String?
    let __v : Int?
    let externalTypes : ExternalActivityTypes?

    enum CodingKeys: String, CodingKey {

        case activityType = "activityType"
        case isScheduled = "isScheduled"
        case activityTarget = "activityTarget"
        case activityId = "activityId"
        case activityName = "activityName"
        case rating = "rating"
        case date = "date"
        case activityImage = "activityImage"
        case categoryType = "categoryType"
        case timeSpent = "timeSpent"
        case distanceCovered = "distanceCovered"
        case status = "status"
        case sleep = "sleep"
        case calories = "calories"
        case steps = "steps"
        case durationId = "durationId"
        case distanceId = "distanceId"
        case origin = "origin"
        case _id = "_id"
        case startDate = "startDate"
        case userId = "userId"
        case created_at = "created_at"
        case updatedAt = "updatedAt"
        case __v = "__v"
        case externalTypes = "externalTypes"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        activityType = try values.decodeIfPresent(Int.self, forKey: .activityType)
        isScheduled = try values.decodeIfPresent(Int.self, forKey: .isScheduled)
        activityTarget = try values.decodeIfPresent(String.self, forKey: .activityTarget)
        activityId = try values.decodeIfPresent(Int.self, forKey: .activityId)
        activityName = try values.decodeIfPresent(String.self, forKey: .activityName)
        rating = try values.decodeIfPresent(Int.self, forKey: .rating)
        date = try values.decodeIfPresent(Int.self, forKey: .date)
        activityImage = try values.decodeIfPresent(String.self, forKey: .activityImage)
        categoryType = try values.decodeIfPresent(String.self, forKey: .categoryType)
        timeSpent = try values.decodeIfPresent(Int.self, forKey: .timeSpent)
        distanceCovered = try values.decodeIfPresent(Int.self, forKey: .distanceCovered)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        sleep = try values.decodeIfPresent(Int.self, forKey: .sleep)
        calories = try values.decodeIfPresent(Int.self, forKey: .calories)
        steps = try values.decodeIfPresent(Int.self, forKey: .steps)
        durationId = try values.decodeIfPresent(Int.self, forKey: .durationId)
        distanceId = try values.decodeIfPresent(Int.self, forKey: .distanceId)
        origin = try values.decodeIfPresent(String.self, forKey: .origin)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        startDate = try values.decodeIfPresent(Int.self, forKey: .startDate)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        __v = try values.decodeIfPresent(Int.self, forKey: .__v)
        externalTypes = try values.decodeIfPresent(ExternalActivityTypes.self, forKey: .externalTypes)
    }

}
