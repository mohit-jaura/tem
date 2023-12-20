//
//  CalendarModal.swift
//  TemApp
//
//  Created by PrabSharan on 29/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
enum ComparisonSign {
    case LessThan
    case EqualThan
    case GreaterThan
}
struct CalendarEventsModal : Codable {
    let message : String?
    let status : Int?
    var data : [EventDetail]?

    enum CodingKeys: String, CodingKey {

        case message = "message"
        case status = "status"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent([EventDetail].self, forKey: .data)
    }
}
struct CalendarEvents: Codable {
    let _id : String?
    let startDate : ActivityDate?
    let endDate : ActivityDate?
    let title : String?
    let eventType : Int?
    var isSameDayEvent:Bool?
    var isEventFoundAfterComparison:Bool?
    var eventStartDate : Date {
        get {
            if let date = startDate?.date as? String {
                return getCombinedDateTime(date:date)
            } else {
                if let timestamp = startDate?.date as? Int{
                    return timestamp.timestampInMillisecondsToDate
                }
            }
            return Date()
        }
    }
    var eventEndDate : Date {
        get {
            if let date = endDate?.date as? String {
                return  getCombinedDateTime(date:date)
            } else {
                if let timestamp = endDate?.date as? Int{
                    return timestamp.timestampInMillisecondsToDate
                }
            }
            return Date()
        }
    }
    func getCombinedDateTime(date:String) -> Date {
        let dateFormatter = Utility.timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone)
        let sDate = dateFormatter.date(from: date) ?? Date()
        return sDate
    }
    enum CodingKeys: String, CodingKey {
        case _id
        case startDate
        case endDate
        case title
        case eventType
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        startDate = try values.decodeIfPresent(ActivityDate.self, forKey: .startDate)
        endDate = try values.decodeIfPresent(ActivityDate.self, forKey: .endDate)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        eventType = try values.decodeIfPresent(Int.self, forKey: .eventType)
    }

}
