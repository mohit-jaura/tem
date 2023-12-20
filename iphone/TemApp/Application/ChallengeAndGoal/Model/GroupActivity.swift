//
//  GroupActivity.swift
//  TemApp
//
//  Created by shilpa on 27/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

/// Group activity type
enum GroupActivityType: Int, Codable {
    case challenge = 1
    case goal = 2
    case weightGoal = 3
    case healthGoal = 4
}

/// This will hold the goal target metric with its respective value
struct GoalTarget: Codable {
    var matric: Int?
    var value: Double?
}

/// This would hold the type in case of challenge, it could be individual vs individual, individual vs tem or tem vs tem
enum ActivityMembersType: Int, Codable {
    case individual = 1
    case individualVsTem = 2
    case temVsTem = 3
}

struct GroupActivityTem: Codable {
    var id: String?
    var name: String?
    var teamType: Int? //1 for team1 and 2 for team2
    
    func toChatRoomType() -> ChatRoom {
        let room = ChatRoom()
        room.groupId = self.id
        room.name = self.name
        return room
    }
}

/*
 This class holds the reference to the activities that are performed with or against other members.
 This will either include a challenge or a goal
 Challenge - Will be performed against each other
 Goal - Will be performed together
 */
class GroupActivity: Codable {
    var id: String?
    var name: String?
    var description: String?
    var startDateToDisplay: String? // not encodable and decodable, use just for display purpose
    var startDate: Int?
    var image:String?
    var endDate: Int?
    var duration: String?
    var selectedMetrics: [Int]?
    var type: GroupActivityType?
    var status: Constant.UserActivityType?
    var members: [ActivityMember]?
    var membersCount: Int?
    var isActivityJoined: Bool?
    var leader: ActivityLeader?
    var isPerPersonGoal: Bool?
    var target: [GoalTarget]?
    var doNotParticipate: Bool? = true // for CompanyAccount only
    var isPublic: Bool? = false
    var openToPublic: Bool? = false
    var scoreboard: [Leaderboard]?
    var completionPercentage: Double?
    var myScore: [Leaderboard]?
    var currentAchievedValue: Double?
    
    var anyActivity: Bool?
    var activityTypes: [ActivityType]?
    
    //not encodable and decodable
    var activities = [ActivityData]()
    var durationList = [String]()
    var challengeCreatorId: String?
    var goalCreatorId: String?
    
    var challengeId: String?
    var goalId: String?
    var groupDetail: ActivityGroupDetail?
    var isChatNotificationsMuted: CustomBool?
    var totalOpenedMetricsViews = 0 // Not decodable
    
    var activityMembersType: ActivityMembersType?
    //individual vs tem challenge
    var selectedTem: GroupActivityTem?
    
    //tem vs tem challenge
    var tem1: GroupActivityTem?
    var tem2: GroupActivityTem?
    var tems: [GroupActivityTem]?
    
    var scoreboardForTemVsInd: [Leaderboard]?
    var teamsArray: [Leaderboard]?
    
    var fundraising: GNCFundraising?
    
    /// this array will hold the leaderboard according to type
    var leaderboardArray: [Leaderboard]? {
        if let type = self.activityMembersType {
            switch type {
            case .individualVsTem:
                return scoreboardForTemVsInd
            case .temVsTem:
                return teamsArray
            default:
                return scoreboard
            }
        }
        return scoreboard
    }
    
    // these keya are used for weight goal
    var currentHealthValue: Int?
    var startWeight: Double?
    var endWeight: Double?
    var frequency: Int?

    var currentHealthUnits: Int?
    var goalHelathUnits: Int?
    var healthInfoType: Int?

    enum CodingKeys: String, CodingKey {
        case name, description, startDate, duration
        case selectedMetrics = "matric"
        case type = "gncType"
        case members = "members"
        case id = "_id"
        case leader
        case status
        case endDate
        case image
        case isActivityJoined = "isJoined"
        case target
        case isPublic
        case openToPublic = "isOpen"
        case membersCount = "memberCount"
        case scoreboard = "membersScore"
        case completionPercentage = "scorePercentage"
        case myScore
        case currentAchievedValue = "totalScore"
        case challengeCreatorId = "challengeCreatedBy"
        case goalCreatorId = "goalCreatedBy"
        case challengeId = "challenge_id"
        case goalId = "goal_id"
        case groupDetail
        case isChatNotificationsMuted = "is_mute"
        case tems = "tem"
        case activityMembersType = "type"
        case scoreboardForTemVsInd = "scoreBoard"
        case teamsArray = "teams"
        case doNotParticipate
        case fundraising
        case anyActivity
        case activityTypes
        case isPerPersonGoal
        case currentHealthValue
        case frequency = "frequency"
        case startWeight = "weight"
        case endWeight = "goal_weight"
        case currentHealthUnits, goalHelathUnits, healthInfoType
    }
    
    /// returns the metrics concatenated to display
    func metricsFormattedString() -> String {
        var metricsText = ""
        var concatString = ", "
        if let metrics = self.selectedMetrics {
            for (index, metric) in metrics.enumerated() {
                if let metricValue = Metrics(rawValue: metric) {
                    let text = metricValue.measuringText + " " + metricValue.title
                    if index == metrics.count - 1 {
                        concatString = ""
                    }
                    metricsText += "\(text)\(concatString)"
                }
            }
        }
        return metricsText
    }
    
    /// calculate the remaining or start time for an activity according to the start or the end date
    func remainingTime() -> String {
        if let status = self.status {
            switch status {
            case .open:
                guard let date = self.endDate else {
                    return ""
                }
                let timeRemaining = date.timestampInMillisecondsToDate.timeIntervalSince(Date())
                if timeRemaining < 0 {  //less than
                    return "Expired".localized
                }
                if let IntTime = timeRemaining.toInt(),
                   IntTime == 0 {
                    return "Expired".localized
                }
                let formattedRemaingTime = timeRemaining.timeRemainingFormatted()
                return formattedRemaingTime + " Remaining".localized
            case .upcoming:
                guard let date = self.startDate else {
                    return ""
                }
                let timeRemaining = date.timestampInMillisecondsToDate.timeIntervalSince(Date())
                if timeRemaining < 0 {  //less than
                    return "Started".localized
                }
                if let IntTime = timeRemaining.toInt(),
                   IntTime == 0 {
                    return "Started".localized
                }
                let formattedRemaingTime = timeRemaining.timeRemainingFormatted()
                return "Starting in " + formattedRemaingTime
            case .completed:
                if let startDate = self.startDate,
                   let formattedStartDate = startDate.timestampInMillisecondsToDate.displayDate(),
                   let endDate = self.endDate {
                    return formattedStartDate + " - " + (endDate.timestampInMillisecondsToDate.displayDate() ?? "")
                }
            }
        }
        return ""
    }
    
    func setActivityLabelAndImage(_ label: UILabel, _ image: UIImageView) {
        setActivityLabel(label)
        setActivityImage(image)
    }
    
    func setActivityLabel(_ label: UILabel) {
        var activityText: String
        if anyActivity == true {
            activityText = "Any"
        } else if let activityTypes = activityTypes, !activityTypes.isEmpty {
            let displayLimit = min(activityTypes.count, 2)
            let displayedActivityTypes = activityTypes.prefix(upTo: displayLimit)
            let hiddenActivityTypes = activityTypes.dropFirst(displayLimit)
            activityText = displayedActivityTypes.map({ x in x.activityName ?? "N/A" }).joined(separator: ", ")
            if !hiddenActivityTypes.isEmpty {
                activityText = "\(activityText) and \(hiddenActivityTypes.count) more"
            }
        } else {
            activityText = "N/A"
        }
        label.text = "ACTIVITY: \(activityText)"
    }
    
    func setActivityImage(_ image: UIImageView) {
        if anyActivity == true {
            image.image = #imageLiteral(resourceName: "achievement")
            image.setImageColor(color: UIColor.appThemeColor)
        } else if let activityTypes = activityTypes, !activityTypes.isEmpty, let firstActivity = activityTypes.first {
            if let logo = firstActivity.logo, let url = URL(string: logo) {
                image.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (_) in
                    image.setImageColor(color: UIColor.appThemeColor)
                }
            }
        } else {
            image.image = #imageLiteral(resourceName: "achievement")
            image.setImageColor(color: UIColor.appThemeColor)
        }
    }
    
    func getTematesLabel() -> String {
        let count = membersCount ?? 0
        var text: String = "\(count == 1 ? "TĒMATE" : "TĒMATES") | \(count)"
        if isPerPersonGoal == true,
           let matrictype = target?.first?.matric,
           let unit = Metrics(rawValue: matrictype),
           let value = target?.first?.value {
            text = "\(text) \n\(unit.formatValue(value)) per person"
        }
        return text
    }
}

enum ActivityMemberType: Int, Codable {
    case temate = 1    // my friend
    case tem = 2       // my chat group
    case temVsTem = 3
}

/// This will hold the members who are invited for the challenge or goal or any group activity
struct ActivityMember: Codable {
    var id: String?
    var type: ActivityMemberType?
    var groupId: String?
    var userInfo: Friends?
    var inviteAccepted: Int?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type = "memberType"
        case groupId = "groupId"
        case userInfo
        case inviteAccepted = "inviteAccepted"
        case name = "name"
    }
    
    func toCustomUserType(forChat: Bool? = false) -> Friends {
        let user = Friends()
        user.id = self.id
        user.user_id = self.id
        user.firstName = self.userInfo?.firstName
        user.lastName = self.userInfo?.lastName
        user.inviteAccepted = self.inviteAccepted
        if forChat! {
            user.status = 1 //setting it to 1 by default as all the members in challenge or goal who have joined it, will be able to chat in the g/c
        }
        return user
    }
}

/// Challenge or Goal group detail
struct ActivityGroupDetail: Codable {
    var id: String?
    var title: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title = "group_title"
    }
    
    func toCustomChatGroup() -> ChatRoom {
        let chatRoom = ChatRoom()
        chatRoom.groupId = id
        chatRoom.name = title
        return chatRoom
    }
}

struct ActivityLeader: Codable {
    var id: String?
    var address: Address?
    var firstName: String?
    var lastName: String?
    var profilePic: String?
    var groupName: String? // this will contain the group name if it is tem vs tem challenge or tem vs individual challenge
    
    var fullName: String {
        if let first = firstName,
           let last = lastName {
            return first + " " + last
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case address
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
        case groupName = "name"
    }
}

struct GNCFundraising: Codable {
    var destination: GNCFundraisingDestination?
    var goalAmount: Decimal?
    var collectedAmount: Decimal?
    
    enum CodingKeys: String, CodingKey {
        case destination
        case goalAmount
        case collectedAmount
    }
}

enum GNCFundraisingDestination: String, Codable, CaseIterable {
    case fundraiser = "self"
    case tem = "tem"
    
    func description() -> String {
        if (self == .fundraiser) {
            return "Self"
        } else if (self == .tem) {
            return "TĒM Up Foundation"
        }
        return ""
    }
}

class StartDonationResponse: Codable {
    var link: String?
    var completed: Bool?
    
    enum CodingKeys: String, CodingKey {
        case link
        case completed
    }
}

class ActivityType : Codable {
    var type: Int?
    var activityName: String?
    var logo: String?
    
    enum CodingKeys : String, CodingKey {
        case type
        case activityName
        case logo
    }
    
    init(_ from: ActivityData) {
        self.type = from.id
        self.activityName = from.name
        self.logo = from.image
    }
}

class CreateGoalOrChallengeDTO : Encodable {
    var challengeId: String?
    var goalId: String?
    var image:String?
    var name: String?
    var description: String?
    var startDate: Int?
    var doNotParticipate: Bool?
    var isPublic: Bool?
    var openToPublic: Bool?
    var duration: String?
    var activityMembersType: ActivityMembersType?
    var tem1: GroupActivityTem?
    var tem2: GroupActivityTem?
    var tems: [GroupActivityTem]?
    
    var anyActivity: Bool?
    var activityTypes: [Int]?
    var isPerPersonGoal: Bool
    
    var selectedMetrics: [Int]?
    var members:[ActivityMember]?
    var target: [GoalTarget]?
    var fundraising: GNCFundraising?
    
    init(event: GroupActivity, type: Constant.ScreenFrom) {
        self.name = event.name
        self.image = event.image
        self.description = event.description
        self.startDate = event.startDate
        self.doNotParticipate = event.doNotParticipate
        self.isPublic = event.isPublic
        self.openToPublic = event.openToPublic
        self.duration = event.duration
        self.anyActivity = event.anyActivity
        self.activityTypes = event.activityTypes?.map({ activityType in activityType.type! })
        self.selectedMetrics = event.selectedMetrics
        self.members = event.members
        self.target = event.target
        self.fundraising = event.fundraising
        self.isPerPersonGoal = event.isPerPersonGoal ?? false
        if type == .createGoal {
            if let id = event.id {
                self.goalId = id
            }
        } else if type == .createChallenge {
            if let id = event.id {
                self.challengeId = id
            }
            if let membersType = event.activityMembersType {
                self.activityMembersType = membersType
                switch membersType {
                case .individual:
                    self.members = event.members
                case .temVsTem:
                    self.openToPublic = false
                    self.members = nil
                    self.tems = []
                    if let tem1 = event.tem1 {
                        self.tems?.append(tem1)
                    }
                    if let tem2 = event.tem2 {
                        self.tems?.append(tem2)
                    }
                case .individualVsTem:
                    self.openToPublic = false
                    self.tems = []
                    if let selected = event.selectedTem {
                        self.tems?.append(selected)
                    }
                    self.members = event.members?.filter({ (member) -> Bool in
                        if let memberType = member.type,
                           memberType == .temate {
                            return true
                        }
                        return false
                    })
                }
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description, startDate, duration
        case selectedMetrics = "matric"
        case members = "members"
        case target
        case isPublic
        case openToPublic = "isOpen"
        case challengeId = "challenge_id"
        case goalId = "goal_id"
        case tems = "tem"
        case image
        case activityMembersType = "type"
        case doNotParticipate
        case fundraising
        case anyActivity
        case activityTypes
        case isPerPersonGoal
    }
}
