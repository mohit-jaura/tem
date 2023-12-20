//
//  UserDefault.swift
//  BaseProject
//
//  Created by Aj Mehra on 08/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation

enum DefaultKey: String {
    case user
    case userProfileData
    //case token
    case enableLog
    case cart
    case isActivity
    case userActivityInProgress
    case userActivityInProgressDates
    case userActivityInProgressDistance
    case userActivityData
    case userActivityAddOn
    case profileRightSideMenu
    // case rightMenuTitle
    case firstLaunch
    case categories
    case address
    case firstRun = "isFirstRun"
    case socialLoginInfo
    case gymAddress
    case interest
    case muteStatus
    case deeplinkInfo
    case fcmToken
    case healthApp
    case stepsLastFetchTime
    
    case combinedActivities
    case shortcuts
    case cartCount

    case userActivityScore
    case appHeaders
    case sharedActivityInProgress
    case sharedUserActivityDates
    case isActivityWatchApp
    case userWeight
    case isActivityRemoved
    case userGender
    
    case workoutStartedFromiPhoneActivity
    
    //for inprogress and average mile calcualtion
    case singleMileCount, lastMileCount, lastMileCompletedTime, avgMile
    
    case healthKitSyncEnabled
    case askedForHealthKitSyncEnable
    case lastHealthKitImportedIntervalEnd
    case orderId
    case programEvent
    case unreadNotificationCount
    case imageId
    case completedTasks
    case isDeepLinkPage
}

class Defaults {
    
    // MARK: SingleTon
    static let shared = Defaults()
    
    // MARK: Variables
    let userDefault = UserDefaults.standard
    
    // MARK: Setter
    func set(value:Any,  forKey key:DefaultKey) {
        userDefault.set(value, forKey: String(describing: key))
        userDefault.synchronize()
    }
    
    // MARK: Getter
    func get(forKey key:DefaultKey) -> Any? {
        return userDefault.object(forKey: String(describing: key))
    }
    
    func removeActivityPaceValues() {
        self.remove(.avgMile)
        self.remove(.singleMileCount)
        self.remove(.lastMileCount)
        self.remove(.lastMileCompletedTime)
    }

    // MARK: Methods
    func removeAll() {
        #if os(iOS)
        User.sharedInstance.resetUserInstance()
        #endif
        remove(.categories)
        let appDomain = Bundle.main.bundleIdentifier
        userDefault.removePersistentDomain(forName: appDomain!)
        userDefault.synchronize()
    }
    
    func remove(_ key:DefaultKey) {
        userDefault.removeObject(forKey: String(describing: key))
        userDefault.synchronize()
    }
    
}
