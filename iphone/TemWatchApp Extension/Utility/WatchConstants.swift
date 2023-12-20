//
//  File.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-04-23.
//

import Foundation

struct AppMessage {
    static var NotLoggedIn = "Please log into the iPhone TĒM app"
    static var FetchIphoneAppVersion = "Fetching iOS App Version"
}

struct MessageKeys {
    static let logintoApp = "login"
    static let createdNewActivityOnPhone = "createdNewActivityOnPhone"
    static let createdNewActivityOnWatch = "createdNewActivityOnWatch"
    static let activityStoppedOnWatch = "activityStoppedOnWatch"
    static let activityStoppedOnPhone = "activityStoppedOnPhone"
    static let userWeightUpdated = "userWeightUpdated"
    static let updateNewDates = "updateNewDates"
    static let loginHeaders = "loginHeaders"
    static let userWeight = "userWeight"
    static let userGender = "userGender"
    static let logout = "logout"
    static let request = "request"

    static let inProgressActivityData = "inProgressActivityData"
    static let userActivityDates = "userActivityDates"
    static let userActivityData = "userActivityData"
    static let completedActivityDataFromOtherDevice = "timeSpent"
    static let activityStateChangedOnWatch = "activityStateChangedOnWatch"
    static let activityStateChangedOnPhone = "activityStateChangedOnPhone"

    static let updateActivityData = "updateActivityData"

    static let additionalActivityAdded = "additionalActivityAdded"
    static let additionalActivityDataFromOtherDevice = "additionalActivityDataFromOtherDevice"

    static let distanceFromCounterpart = "distanceFromCounterpart"
    static let workoutSessionFailedInWatch = "workoutSessionFailedInWatch"
}
struct WatchConstants {

    struct Subdomain {
        static let getUserReportScore = "reports"
        static let getActivities = "activity/healthactivity"
        static let durationListing = "activity/duration"
        static let distanceListing = "activity/distance"
        static let startUserActivity = "users/activity/start"
        static let completeUserActivity = "users/activity/complete"
    }

    struct Messages {
        static let loginToTheIphoneApp = "Please log into the iPhone TĒM app"
    }

    struct APIResponse {
        static let requestTimeOut = "requestTimeOut".localized
        static let internalServerError = "internalServerError".localized
        static let sessionExpired = "sessionExpired".localized
        static let clientError = "clientError".localized
        static let planExpired = "Plan Expired".localized
    }
}


