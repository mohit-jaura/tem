//
//  WatchSyncManager.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-04-13.
//

import Foundation
import WatchConnectivity

protocol WatchiOSSessionManagerDelegate: AnyObject {
    func didReceiveDistanceValueFromCounterpartApp(distance: Double, activityId: String?)
}

class Watch_iOS_SessionManager : NSObject, WCSessionDelegate {
    
    // 1: Singleton
    static let shared = Watch_iOS_SessionManager()
    
    // 2: Property to manage session
    var session = WCSession.default
    weak var delegate: WatchiOSSessionManagerDelegate?
    
    override init() {
        super.init()
        
        // 3: Start and activate session if it's supported
              if isSuported() {
            session.delegate = self
            session.activate()
            print("Session-\(session)")
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    func isReachable() -> Bool {
        return session.isReachable
    }
    
    func isWatchAppInstalled()->Bool{
       return session.isWatchAppInstalled
    }
    
    func sendMessage(message: [String : Any],
                     replyHandler: (([String : Any]) -> Void)? = nil,
                     errorHandler: ((NSError) -> Void)? = nil)
    {
        session.sendMessage(message, replyHandler: { (result) in
            print(result)
        }, errorHandler: { (error) in
            print(error)
        })
    }
    
    func updateApplicationContext(data: [String: Any]) {
        do {
            try session.updateApplicationContext(data)
        } catch (let error) {
            print("error in updateApplicationContext:-------- \(error)")
        }
    }
    
    // MARK: - WCSessionDelegate
    
    // 4: Required protocols
    
    // a
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    // b
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    // c
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        // Reactivate session
        /**
         * This is to re-activate the session on the phone when the user has switched from one
         * paired watch to second paired one. Calling it like this assumes that you have no other
         * threads/part of your code that needs to be given time before the switch occurs.
         */
        self.session.activate()
    }
    
    /// Observer to receive messages from watch and we be able to response it
    ///
    /// - Parameters:
    ///   - session: session
    ///   - message: message received
    ///   - replyHandler: response handler
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as? String == MessageKeys.distanceFromCounterpart {
            if let distance = message["totalDistance"] as? Double {
               let activityId = message["activityProgressId"] as? String
                self.delegate?.didReceiveDistanceValueFromCounterpartApp(distance: distance, activityId: activityId)
            }
            replyHandler(["true": "1"])
        }
        else if message["request"] as? String == "loginInfo" {
            //get the login information from iPhone
            if let _ = UserManager.getCurrentUser() {
                let headerInfo = DeviceInfo.shared.getHeaderContent(true)
                //pass this information to the watch app
                replyHandler([MessageKeys.loginHeaders: headerInfo])
            } else {
                //user is not logged in
                replyHandler(["loggedIn": false])
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard UserManager.isUserLoggedIn() else {return}
        if let keyValue = applicationContext["request"] as? String {
            if keyValue == MessageKeys.createdNewActivityOnWatch {
                //new activity created on watch
                //update the defaults
                if let progressData = applicationContext[MessageKeys.inProgressActivityData] as? Data {
                    var context: [String: Any] = [:]
                    context["activityProgressData"] = progressData
                    if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
                    }else{
                        Defaults.shared.set(value: true, forKey: .isActivity)
                    }
                    Defaults.shared.set(value: progressData, forKey: .userActivityInProgress)
                    if let activityData = applicationContext[MessageKeys.userActivityData] as? Data {
                        Defaults.shared.set(value: activityData, forKey: .userActivityData)
                    }
                    if let addiitonalActivityData = applicationContext[MessageKeys.additionalActivityAdded] as? Data {
                        self.additionalActivityAdded(data: addiitonalActivityData, context: context)
                    }
                }
            }
            /*else if keyValue == MessageKeys.updateActivityData {
                
                //check if the activity is in progress, then only update
                guard let isInProgress = Defaults.shared.get(forKey: .isActivity) as? Bool,
                    isInProgress == true else {return}
                
                //when the activity information is changed in progress screen
                if let data = applicationContext[MessageKeys.inProgressActivityData] as? Data {
                    Defaults.shared.set(value: data, forKey: .sharedActivityInProgress)
                    if let activityData = applicationContext[MessageKeys.userActivityData] as? Data {
                        Defaults.shared.set(value: activityData, forKey: .userActivityData)
                    }
                }
            } */
            else if keyValue == MessageKeys.activityStoppedOnWatch {
                self.activityStoppedOnWatchApp(applicationContext: applicationContext)
            } else if keyValue == MessageKeys.activityStateChangedOnWatch {
                //either it is paused or resumed
                Defaults.shared.remove(.isActivityRemoved)

                if let data = applicationContext["data"] as? Data {
                    var decodedData = InProgressActivityState()
                    do {
                        decodedData = try JSONDecoder().decode(InProgressActivityState.self, from: data)
                    } catch {}
                    if let progressData = ActivityProgressData.currentActivityInfo() {
                        progressData.totalTime = decodedData.totalTime
                        progressData.duration = decodedData.duration
                        progressData.elapsed = decodedData.elapsed
                        progressData.isPlaying = decodedData.isPlaying
                        progressData.saveEncodedInformation()
                    }
                    NotificationCenter.default.post(name: Notification.Name.activityInfoUpdated, object: self, userInfo: ["data": decodedData])
                }
            } else if keyValue == MessageKeys.updateNewDates {
                if let data = applicationContext[MessageKeys.userActivityDates] as? Data {
                    //DeSerialize Custom Object
                    if let activityDates = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AccessDictionary] {
                        UserManager.saveUseractivityDates(data: activityDates)
                    }
                }
            } else if keyValue == MessageKeys.workoutSessionFailedInWatch {
                if let activityId = applicationContext["activityId"] as? String,
                    activityId != "" {
                    let userInfo = ["activityId": activityId]
                    NotificationCenter.default.post(name: Notification.Name.workoutFailed, object: nil, userInfo: userInfo)
                }
                Defaults.shared.remove(.isActivity)
                Defaults.shared.remove(.userActivityInProgress)
                Defaults.shared.removeActivityPaceValues()
                Defaults.shared.remove(.userActivityData)
                Defaults.shared.remove(.combinedActivities)
            }
        }
    }
    
    private func activityStoppedOnWatchApp(applicationContext: [String : Any]) {
        if let data = applicationContext[MessageKeys.completedActivityDataFromOtherDevice] as? Data {
            var decodedData = [CompletedActivityData]()
            do {
                decodedData = try JSONDecoder().decode([CompletedActivityData].self, from: data)
            } catch {
                
            }
            NotificationCenter.default.post(name: Notification.Name.activityHasBeenStoppedOnDevice, object: self, userInfo: ["data": decodedData])
        }
        Defaults.shared.remove(.isActivity)
        Defaults.shared.remove(.userActivityInProgress)
        Defaults.shared.removeActivityPaceValues()
        Defaults.shared.remove(.userActivityData)
        Defaults.shared.remove(.combinedActivities)
    }
    
    func getActivityProgressObject(_ selectedActivity : ActivityData) -> ActivityProgressData {
        let objActivityProgressData:ActivityProgressData = ActivityProgressData()
        objActivityProgressData.activity = selectedActivity
        objActivityProgressData.createdAt = Date()
        objActivityProgressData.elapsed = 0
        objActivityProgressData.startTime = 0
        objActivityProgressData.saveEncodedInformation()
        return objActivityProgressData
    }
    
    private func additionalActivityAdded(data: Data, context: [String: Any]) {
        Defaults.shared.set(value: data, forKey: .combinedActivities)
        appDelegate.stopLocation()
        //show alert
        NotificationCenter.default.post(name: Notification.Name.additionalActivityAddedOnWatchApp, object: nil)
        if let tabbar = Utility.getCurrentViewController() as? TabBarViewController,
            let navigation = tabbar.viewControllers?.last,
            let visibleController = navigation.children.last as? ActivityProgressController {
            let alert = UIAlertController(title: nil, message: "New activity is added on watch TĒM app.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: AppMessages.AlertTitles.Ok, style: .default) { (action) in
                self.redirectToNewActivityScreenFrom(visibleController: visibleController)
            }
            DispatchQueue.main.async {
                alert.addAction(alertAction)
                visibleController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func redirectToNewActivityScreenFrom(visibleController: UIViewController) {
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            
            let selectedVC: ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
            if let data = ActivityProgressData.currentActivityInfo(){
                let progressData = data
                
                if let isPlaying = data.isPlaying,
                    isPlaying {
                    let difference = Date().timeIntervalSinceReferenceDate - (data.startTime ?? Date().timeIntervalSinceReferenceDate)
                    progressData.elapsed = difference
                    print("elapsed time is \(difference)")
                }
                if let activityType = data.activity?.activityType,
                    let type = ActivityMetric(rawValue: activityType),
                    type == .distance{
                    appDelegate.initalizeLocation()
                }
                UserManager.removeStatsOfAtivityData()
                selectedVC.activityData = progressData//data
            }
            selectedVC.isTabbarChild = true
            selectedVC.isFromDashBoard = true
            visibleController.navigationController?.viewControllers = [selectedVC]
        }
    }
}
