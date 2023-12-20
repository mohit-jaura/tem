//
//  Event+DTO.swift
//  TemApp
//
//  Created by Egor Shulga on 29.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

struct CreateEvent {
    var title = ""
    var description = ""
    var location : Address = Address()
    var reccurEvent :RecurrenceType = .doesNotRepeat
    var eventReminder = true
    var sDateTime = ""
    var eDateTime = ""
    var members : [Friends] = []
    var endDate = ""
    var endsOn : EndsOnValue?
    var id = ""
    var updatedFor = ""
    var eventType: EventType = .regular
    var membersCapacity: Int?
    var updateAllEvents = 0
    var isEditEvent = false
    var groupId: String?
    var visibility: EventVisibility = .personal
    var media: [SavedURls] = []
    var activityAddOn:[[String:Any]] = []
    var signupSheetType: String?
    var membersCount: Int?
    var checkList:[Rounds] = []
    var amount: Int?
    
    func toCreateEventDict() -> Parameters {
        var memberParamList: [[String : Any]] = []
        for member in members {
            if member.user_id == UserManager.getCurrentUser()?.id {
                continue
            }
            var dict: [String: Any] = ["userId":member.user_id ?? ""]
            if let groupId = self.groupId {
                dict["groupId"] = groupId
                dict["memberType"] = ActivityMemberType.tem.rawValue
            } else {
                dict["memberType"] = ActivityMemberType.temate.rawValue
            }
            memberParamList.append(dict)
        }
        
        var mediaParamList: [[String : Any]] = []
        
        for med in media{
            var dict: [String: Any] = ["file":med.url ?? ""]
            dict[ "mediaType"] = med.mediaType
            mediaParamList.append(dict)
        }
        
        var rounds:[Parameters] = []
        
        for round in checkList {
            rounds.append(round.getDict())
        }
        var params : Parameters = [
            "activityAddOn":activityAddOn,
            "members": memberParamList,
            "eventMedia": mediaParamList,
            "title": title,
            "description": description,
            "location": [
                "location": location.formatted ?? "",
                "lat": location.lat ?? 0.0,
                "long": location.lng ?? 0.0
            ],
            
            "reccurEvent": reccurEvent.rawValue,
            "eventReminder": eventReminder,
            "startDate": sDateTime,
            "endDate": eDateTime,
            "endsOn": endsOn?.any ?? 0,
            "eventType": eventType.rawValue,
            "is_deleted": 0,
            "visibility": visibility.rawValue,
            "membersCapacity": membersCapacity as Any,
            "members_add_number": ["signupsheet": signupSheetType ?? "","count": membersCount ?? 0],
            "rounds": rounds
        ] as [String : Any]
        
        if let payableAmount = amount{
            params["payableAmount"] = payableAmount
        }
        return params
    }
    
    func toEditEventDict() -> Parameters {
        let editedMemberParamList  = members.map { (friend) in
            return ["userId":friend.user_id ?? "","memberType": 1,"inviteAccepted":friend.inviteAccepted ?? EventInvitationStatus.pending.rawValue]
        }
        var mediaParamList: [[String : Any]] = []
        
        for med in media{
            var dict: [String: Any] = ["file":med.url ?? ""]
            dict[ "mediaType"] = med.mediaType
            mediaParamList.append(dict)
        }
        
        var rounds:[Parameters] = []
        
        for round in checkList {
            rounds.append(round.getDict())
        }
        var params : Parameters = [
            "title": title,
            "description": description,
            "location": [
                "location": location.formatted ?? "",
                "lat": location.lat ?? 0.0,
                "long": location.lng ?? 0.0
            ],
            "members": editedMemberParamList,
            "eventMedia": mediaParamList,
            "reccurEvent": reccurEvent.rawValue,
            "eventReminder": eventReminder,
            "startDate": sDateTime,
            "endDate": eDateTime,
            "endsOn":endsOn?.any ?? 0,
            "notifUser": true,
            "_id":id,
            "userId":User.sharedInstance.id ?? "",
            "updatedFor" : updatedFor,
            "eventType": eventType.rawValue,
            "updateAllEvents" :updateAllEvents,
            "is_deleted":0,
            "visibility": visibility.rawValue,
            "members_add_number": ["signupsheet": signupSheetType ?? "","count": membersCount ?? 0],
            "rounds": rounds,
            "activityAddOn":activityAddOn
        ] as [String : Any]
        
        if let payableAmount = amount{
            params["payableAmount"] = payableAmount
        }
        return params
    }
}

struct JoinEvent {
    var eventId = ""
    var status :EventAcceptRejectStatus = .Accept
    
    func toDict() -> Parameters {
        let params : Parameters = [
            "eventId": eventId,
            "status": status.rawValue
        ] as [String : Any]
        return params
    }
}
