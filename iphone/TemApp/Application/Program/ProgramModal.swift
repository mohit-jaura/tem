//
//  ProgramModal.swift
//  TemApp
//
//  Created by PrabSharan on 13/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation

struct ProgramAllDataModal : Codable {
    let message : String?
    let status : Int?
    let data : ProgramDataModal?

    enum CodingKeys: String, CodingKey {

        case message = "message"
        case status = "status"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent(ProgramDataModal.self, forKey: .data)
    }

}


struct ProgramDataModal : Codable {
    let programName : String?
    let programDuration : Int?
    let status : Int?
    var programs : [Programs]?
    let _id : String?
    let user_id : String?
    let isStarted: Int? // 1 will indicate the program has been started and 0 means program is ot started yet
    enum CodingKeys: String, CodingKey {

        case programName = "programName"
        case programDuration = "programDuration"
        case status = "status"
        case programs = "programEvents"
        case _id = "_id"
        case user_id = "user_id"
        case isStarted
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        programName = try values.decodeIfPresent(String.self, forKey: .programName)
        programDuration = try values.decodeIfPresent(Int.self, forKey: .programDuration)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        programs = try values.decodeIfPresent([Programs].self, forKey: .programs)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        user_id = try values.decodeIfPresent(String.self, forKey: .user_id)
        isStarted = try values.decode(Int.self, forKey: .isStarted)
    }

}
struct Programs : Codable {
    var isOpened : Bool? = false
    let event_name : String?
    let description : String?
    let duration : Int?
    let location : Locations?
    let lat : String?
    let lng : String?
    let eventType : Int?
    let visibility : String?
    let membersLimit : String?
    let rounds : [EventRounds]?
    let eventMedia : [SavedURls]?
    let activityAddOn : [ActivityAddOns]?
    let isStarted: Int?
    
    enum CodingKeys: String, CodingKey {
        case isOpened = "isOpened"
        case event_name = "title"
        case description = "description"
        case duration = "duration"
        case location = "location"
        case lat = "lat"
        case lng = "lng"
        case eventType = "eventType"
        case visibility = "visibility"
        case membersLimit = "membersLimit"
        case rounds = "rounds"
        case eventMedia = "eventMedia"
        case activityAddOn = "activityAddOn"
        case isStarted
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        event_name = try values.decodeIfPresent(String.self, forKey: .event_name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        duration = try values.decodeIfPresent(Int.self, forKey: .duration)
        location = try values.decodeIfPresent(Locations.self, forKey: .location)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        lng = try values.decodeIfPresent(String.self, forKey: .lng)
        eventType = try values.decodeIfPresent(Int.self, forKey: .eventType)
        visibility = try values.decodeIfPresent(String.self, forKey: .visibility)
        membersLimit = try values.decodeIfPresent(String.self, forKey: .membersLimit)
        rounds = try values.decodeIfPresent([EventRounds].self, forKey: .rounds)
        eventMedia = try values.decodeIfPresent([SavedURls].self, forKey: .eventMedia)
        activityAddOn = try values.decodeIfPresent([ActivityAddOns].self, forKey: .activityAddOn)
        isStarted = try values.decodeIfPresent(Int.self, forKey: .isStarted)
    }

}

