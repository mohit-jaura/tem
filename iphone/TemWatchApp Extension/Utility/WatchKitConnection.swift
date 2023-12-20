//
//  WatchKitConnection.swift
//  ElecDemo
//
//  Created by NhatHM on 8/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

protocol WatchKitConnectionDelegate: AnyObject {
    func userLoggedInIphoneApp()
    func testMessage()
    func didReceiveDistanceFromCounterpartApp(distance: Double)
}

extension WatchKitConnectionDelegate {
    func testMessage() {}
    func didReceiveDistanceFromCounterpartApp(distance: Double) {}
}

protocol WatchKitConnectionProtocol {
    func startSession()
    func sendMessage(message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((NSError) -> Void)?)
    
}

class WatchKitConnection: NSObject {
    static let shared = WatchKitConnection()
    weak var delegate: WatchKitConnectionDelegate?
    
    private override init() {
        super.init()
        // 3: Start and activate session if it's supported
        session?.delegate = self
        session?.activate()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    private var validSession: WCSession? {
#if os(iOS)
        if let session = session, session.isPaired, session.isWatchAppInstalled {
            return session
        }
#elseif os(watchOS)
            return session
#endif
    }
    
    private var validReachableSession: WCSession? {
        if let session = validSession, session.isReachable {
            return session
        }
        return nil
    }
    
    func sessionStarted() {
        //print("valid session: \(validSession)")
        //print("Reachable session: \(validReachableSession)")
    }
    
    func isReachable() -> Bool {
        print("is iPhone reachable: \(session?.isReachable)")
        return WCSession.default.isReachable
//        print("is iPhone app installed: \(session?.isCompanionAppInstalled)")
    }
}

extension WatchKitConnection: WatchKitConnectionProtocol {
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    func sendMessage(message: [String : Any],
                     replyHandler: (([String : Any]) -> Void)? = nil,
                     errorHandler: ((_ error: NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessage(message, replyHandler: { (result) in
            print("reply received: \(result)")
            print(result)
            replyHandler?(result)
        }, errorHandler: { (error) in
            print("error received: \(error)")
            print(error)
            errorHandler?(error as NSError)
        })
    }
    
    func updateApplicationContext(context: [String: Any]) {
        do {
            try self.session?.updateApplicationContext(context)
        } catch (let error) {
            print("error in sending data: \(error)")
        }
        
    }
}

extension WatchKitConnection: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Session send message received")
        if let keyValue = message["request"] as? String {
            if keyValue == MessageKeys.additionalActivityAdded {
                if let data = message[MessageKeys.inProgressActivityData] as? Data {
                    var context: [String: Any] = [:]
                    context["activityProgressData"] = data
                    if let data = message[MessageKeys.additionalActivityAdded] as? Data {
                        self.additionalActivityAdded(data: data, context: context)
                    }
                }
            }
            if keyValue == MessageKeys.distanceFromCounterpart {
                if let distance = message["totalDistance"] as? Double {
                    self.delegate?.didReceiveDistanceFromCounterpartApp(distance: distance)
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let keyValue = applicationContext["request"] as? String {
            if keyValue == MessageKeys.logintoApp {
                print("keyValue == MessageKeys.logintoApp")
                if let headers = applicationContext[MessageKeys.loginHeaders] {
                    self.updateLoginInformation(data: headers)
                }
                if let weight = applicationContext[MessageKeys.userWeight] as? Int {
                    self.updateUserWeight(data: weight)
                }
                if let gender = applicationContext[MessageKeys.userGender] as? Int {
                    self.updateUserGender(data: gender)
                }
            }
            guard let _ = Defaults.shared.get(forKey: .appHeaders) else {
                //return if user is not logged in
                return
            }
//            if keyValue == MessageKeys.createdNewActivityOnPhone || keyValue == MessageKeys.updateActivityData {
            if keyValue == MessageKeys.createdNewActivityOnPhone {
                Defaults.shared.set(value: true, forKey: .isActivityWatchApp)
                if let data = applicationContext[MessageKeys.inProgressActivityData] as? Data {
                    var context: [String: Any] = [:]
                    context["activityProgressData"] = data
                    
                    /*do {
                        let progressData = try JSONDecoder().decode(ActivityProgressData.self, from: data)
                        //start workout session on the apple watch app
                        Defaults.shared.set(value: true, forKey: .workoutStartedFromiPhoneActivity)
                        WorkoutTracking.shared.startWorkout(activityId: progressData.activity?.id ?? 1, startTime: progressData.createdAt ?? Date()) { (success, error) in
                            if !success && error == nil {
                                //Defaults.shared.set(value: false, forKey: .workoutStartedFromiPhoneActivity)
                                Defaults.shared.remove(.workoutStartedFromiPhoneActivity)
                            }
                        }
                    } catch {} */
                    
                    Defaults.shared.set(value: true, forKey: .isActivityWatchApp)
                    Defaults.shared.set(value: data, forKey: .sharedActivityInProgress)
                    if let activityData = applicationContext[MessageKeys.userActivityData] as? Data {
                        Defaults.shared.set(value: activityData, forKey: .userActivityData)
                    }
                    if let addiitonalActivityData = applicationContext[MessageKeys.additionalActivityAdded] as? Data {
                        self.additionalActivityAdded(data: addiitonalActivityData, context: context)
                    }
                }
            }
            else if keyValue == MessageKeys.updateNewDates {
                if let data = applicationContext[MessageKeys.userActivityDates] as? Data {
                    Defaults.shared.set(value: data, forKey: .sharedUserActivityDates)
                }
            } else if keyValue == MessageKeys.userWeightUpdated {
                if let weight = applicationContext[MessageKeys.userWeight] as? Int {
                    self.updateUserWeight(data: weight)
                }
                if let gender = applicationContext[MessageKeys.userGender] as? Int {
                    self.updateUserGender(data: gender)
                }
            } else if keyValue == MessageKeys.activityStoppedOnPhone {
                self.activityStoppedOnIphoneApp(applicationContext: applicationContext)
            } else if keyValue == MessageKeys.activityStateChangedOnPhone {
                print("Watch kit connection ------------> called")
                //either it is paused or resumed
                if let data = applicationContext["data"] as? Data {
                    var decodedData = InProgressActivityState()
                    do {
                        decodedData = try JSONDecoder().decode(InProgressActivityState.self, from: data)
                        if let progressData = Defaults.shared.get(forKey: .sharedActivityInProgress) as? Data {
                            let runActData = try JSONDecoder().decode(ActivityProgressData.self, from: progressData)
                            runActData.totalTime = decodedData.totalTime
                            runActData.duration = decodedData.duration
                            runActData.elapsed = decodedData.elapsed
                            runActData.isPlaying = decodedData.isPlaying
                            let encoded = try JSONEncoder().encode(runActData)
                            Defaults.shared.set(value: encoded, forKey: .sharedActivityInProgress)
                        }
                    } catch {}
                    NotificationCenter.default.post(name: Notification.Name.activityInfoUpdated, object: self, userInfo: ["data": decodedData])
                }
            } else if keyValue == MessageKeys.logout {
                //show login error message
                self.userLogoutFromIphoneApp()
            }
        }
    }
    
    private func activityStoppedOnIphoneApp(applicationContext: [String : Any]) {
        print("Activity stopped on iphone app")
        if let data = applicationContext[MessageKeys.completedActivityDataFromOtherDevice] as? Data {
            var decodedData = [CompletedActivityData]()
            do {
                decodedData = try JSONDecoder().decode([CompletedActivityData].self, from: data)
            } catch {
                
            }
            if let combinedActivityInfo = applicationContext[MessageKeys.additionalActivityDataFromOtherDevice] as? Data {
                Defaults.shared.set(value: combinedActivityInfo, forKey: .combinedActivities)
            }
            NotificationCenter.default.post(name: Notification.Name.activityHasBeenStoppedOnDevice, object: self, userInfo: ["data": decodedData])
        }
        Defaults.shared.remove(.isActivityWatchApp)
        Defaults.shared.remove(.sharedActivityInProgress)
        Defaults.shared.removeActivityPaceValues()
        Defaults.shared.remove(.userActivityData)
//        Defaults.shared.remove(.combinedActivities)
    }
    
    private func updateLoginInformation(data: Any?) {
        if let dict = data as? [String: Any] {
            //save the login headers in user defaults
            Defaults.shared.set(value: dict, forKey: DefaultKey.appHeaders)
            
            self.delegate?.userLoggedInIphoneApp()
            DispatchQueue.main.async {
                if let root = WKExtension.shared().rootInterfaceController {
                    root.dismiss()
                    //set the choose activity screen as the root view controller
                    WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "WChooseActivityVC", context: [:] as AnyObject)])
                }
            }
        }
    }
    
    private func userLogoutFromIphoneApp() {
        //check for running activity
        if let watchActivityInProgress = Defaults.shared.get(forKey: .isActivity) as? Bool, watchActivityInProgress  {
            Defaults.shared.remove(.isActivity)
            NotificationCenter.default.post(name: Notification.Name.watchStopActivity, object: nil)
        }
        Defaults.shared.remove(.isActivityWatchApp)
        Defaults.shared.remove(.sharedActivityInProgress)
        Defaults.shared.removeActivityPaceValues()
        Defaults.shared.remove(.appHeaders)
        Defaults.shared.remove(.userActivityData)
        Defaults.shared.remove(.sharedUserActivityDates)
        Defaults.shared.remove(.userWeight)
        Defaults.shared.remove(.userGender)
        Defaults.shared.remove(.combinedActivities)

        if let root = WKExtension.shared().rootInterfaceController {
            root.showLoginAlert(AppMessage.NotLoggedIn, isUserLoggedIn: false)
        }
    }
    
    /// update latest user weight from iphone in apple watch
    /// - Parameter data: weight value
    private func updateUserWeight(data: Int) {
        Defaults.shared.set(value: data, forKey: .userWeight)
    }
    
    private func updateUserGender(data: Int) {
        Defaults.shared.set(value: data, forKey: .userGender)
    }
    
    private func additionalActivityAdded(data: Data, context: [String: Any]) {
        Defaults.shared.set(value: data, forKey: .combinedActivities)
        //show alert
        if let root = WKExtension.shared().visibleInterfaceController {
//            DispatchQueue.main.async {
//                root.popToRootController()
//            }
            root.showAlert(message: "New activity is added on iPhone TĒM app.") {
                self.redirectToNewActivityScreen()
            }
        }
    }
    
    private func redirectToNewActivityScreen() {
        if let data = Defaults.shared.get(forKey: .sharedActivityInProgress) {
            var contextDict = [String: Any]()
            //there is already an activity in running state
            do {
                guard let data = data as? Data else {return}
                let runActData = try JSONDecoder().decode(ActivityProgressData.self, from: data)
                if let isPlaying = runActData.isPlaying,
                    isPlaying {
                    let difference = Date().timeIntervalSinceReferenceDate - (runActData.startTime ?? Date().timeIntervalSinceReferenceDate)
                    runActData.elapsed = difference
                    print("elapsed time is \(difference)")
                }
                contextDict["activityProgressData"] = runActData
                if let dates = Defaults.shared.get(forKey: .sharedUserActivityDates) as? Data {
                    let activityDates = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dates) as? [AccessDictionary]
                    contextDict["activityDates"] = activityDates
                }
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootPageControllers(withNames: ["WActivityActionsInterfaceController", "WInProgressActivityVC", "PlayingViewInterfaceController"], contexts: [[:] as AnyObject, contextDict], orientation: .horizontal, pageIndex: 1)
                }
            } catch(let error) {
                print("error: \(error)")
            }
        }
    }
}
