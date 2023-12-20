//
//  UserManager.swift
//  BaseProject
//
//  Created by Aj Mehra on 08/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import SideMenu

class UserManager: NSObject {
    
    static let realmUserManager: UserManagerRealm = UserManagerRealm()
    
    class func saveCurrentUser(user:User) {
        realmUserManager.saveCurrentUser(user: user)
        User.sharedInstance = user
    }
    
    class func saveUserLocation(address:Address) {
        if let user = getCurrentUser() {
            user.address = address
            saveCurrentUser(user: user)
            User.sharedInstance.address = address
        }
    }
    
    class func saveUserGymLocation(address:Address) {
        if let user = getCurrentUser() {
            user.gymAddress = address
            saveCurrentUser(user: user)
            User.sharedInstance.gymAddress = address
        }
    }
    
    class func saveUserInterests(interest:[String]) {
        if let user = getCurrentUser() {
            user.interests = interest
            saveCurrentUser(user: user)
            User.sharedInstance.interests = interest
        }
    }
    
    class func isUserLoggedIn() -> Bool {
        if getCurrentUser() != nil {
            return true
        } else {
            return false
        }
    }
    
    class func saveCartCount(value: Int) {
        Defaults.shared.set(value: value, forKey: .cartCount)
    }
    
    class func cartCount() -> Int {
        return Defaults.shared.get(forKey: .cartCount) as? Int ?? 0
    }
    
    class func resetCartCount() {
        Defaults.shared.remove(.cartCount)
    }
    
    class func updateCartCount() {
        if var count = Defaults.shared.get(forKey: .cartCount) as? Int {
            count += 1
            saveCartCount(value: count)
        } else {
            saveCartCount(value: 1)
        }
    }
    
    class func decrementCartCount() {
        if var count = Defaults.shared.get(forKey: .cartCount) as? Int {
            count -= 1
            saveCartCount(value: count >= 0 ? count : 0)
        } else {
            saveCartCount(value: 0)
        }
    }
    
    class func logout() {
        NotificationCenter.default.post(name: Notification.Name.removeFirestoreListeners, object: nil)
        NotificationCenter.default.post(name: Notification.Name.stopStepsUpdateTimer, object: nil)
        SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
        SideMenuManager.default.leftMenuNavigationController?.dismiss(animated: false, completion: nil)
        for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
            //remove all user defaults keys except these
            if key == DefaultKey.firstRun.rawValue || key == DefaultKey.muteStatus.rawValue || key == DefaultKey.healthApp.rawValue || key == "fitbit_token" || key == DefaultKey.fcmToken.rawValue {
                continue
            }
            UserDefaults.standard.removeObject(forKey: key)
        }
        realmUserManager.deleteAll()
        DIFirebaseImageManager.firebaseInstance.cancelAllTasks()
        //clear the user posts core data stack
        /*let fetchPredicate = NSPredicate(format: "isuploaded == %d",CustomBool.no.rawValue)
         CoreDataManager.shared.delete(entityName: Constant.CoreData.postEntity, fromContext: appDelegate.persistentContainer.viewContext, predicate: fetchPredicate) */
        HomePageViewController.reachabilityManager?.stopListening()
        CoreDataManager.shared.delete(entityName: Constant.CoreData.postEntity, fromContext: appDelegate.persistentContainer.viewContext)
        
        //This function will remove the Current access token ....
        FacebookManager.shared.removeFBSDKAcessToken()
        
        // Reset HealthHelper status
        HealthKit.instance?.reset()
    }
    
    class func removeAtivityData() {
        for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
            //remove all user defaults keys except these
            if key == DefaultKey.userActivityInProgress.rawValue || key == DefaultKey.isActivity.rawValue || key == DefaultKey.userActivityData.rawValue || key == DefaultKey.userActivityInProgressDates.rawValue || key == DefaultKey.userActivityInProgressDistance.rawValue{
                Defaults.shared.removeActivityPaceValues()
                UserDefaults.standard.removeObject(forKey: key)
            }else{
                continue
            }
            
        }
    }
    
    class func removeStatsOfAtivityData() {
        for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
            //remove all user defaults keys except these
            if key == DefaultKey.userActivityInProgressDates.rawValue || key == DefaultKey.userActivityInProgressDistance.rawValue{
                UserDefaults.standard.removeObject(forKey: key)
            }else{
                continue
            }
            
        }
    }
    
    
    class func getCurrentUser() -> User? {
        let user = realmUserManager.getCurrentUser()
        return user
    }
    
    /// increment or decrement unread count as per the + or - operator passed in as argument
    ///
    /// - Parameter operation: + for increment, - for decrement
    class func updateUnreadCount(_ operation: ((Int, Int) -> Int)) {
        if let count = Defaults.shared.get(forKey: .unreadNotificationCount) as? Int {
            var newCount = 0
            let result = operation(count, 1)
            if result > 0 {
                newCount = result
            }
            UIApplication.shared.applicationIconBadgeNumber = newCount
            Defaults.shared.set(value: newCount, forKey: .unreadNotificationCount)
            User.sharedInstance.unreadNotiCount = newCount
        }
    }
    
    class func getCurrentUserAddress() -> Address? {
        guard let user = getCurrentUser(), let address = user.address else {
            return nil
        }
        return address
    }
    
    class func getGymAddress() -> Address? {
        guard let user = getCurrentUser(), let address = user.gymAddress else {
            return nil
        }
        return address
    }
    
    class func getInterests() -> [String]? {
        guard let user = getCurrentUser() else {
            return nil
        }
        let interests = user.interests
        return interests
    }
    
    
    class func saveEventActivityOnDates(_ eventID:String?,_ data:[AccessDictionary]) {
        do {
            guard let eventID = eventID else {return}
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            
            CustomDefaults.eventDates.set(encodedData, forKey: eventID)
            CustomDefaults.eventDates.synchronize()
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    class func removeActAddOnDatesDistance(_ eventID:String?) {
        guard let eventID = eventID else {return}
        
        CustomDefaults.eventDates.removeObject(forKey: eventID)
        CustomDefaults.eventDates.synchronize()
        CustomDefaults.eventDistByDate.removeObject(forKey: eventID)
        CustomDefaults.eventDistByDate.synchronize()
    }
    
    class func saveEventActivityOnaDistance(_ eventID:String?,_ data:[AccessDistance]) {
        do {
            guard let eventID = eventID else {return}
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            CustomDefaults.eventDistByDate.set(encodedData, forKey: eventID)
            CustomDefaults.eventDistByDate.synchronize()
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    
    class func saveUseractivityDates(data:[AccessDictionary]) {
        do {
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            Defaults.shared.set(value: encodedData, forKey: .userActivityInProgressDates)
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    class func getUserActivityDates() -> [AccessDictionary]? {
        guard let activityDates = Defaults.shared.get(forKey: .userActivityInProgressDates) as? Data, let data =
                NSKeyedUnarchiver.unarchiveObject(with: activityDates) as? [AccessDictionary]  else {
            return nil
        }
        return data
    }
    
    
    class func saveUseractivityDistance(data:[AccessDistance]) {
        do {
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            Defaults.shared.set(value: encodedData, forKey: .userActivityInProgressDistance)
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    class func getUserActivityDistance() -> [AccessDistance]? {
        guard let activityDates = Defaults.shared.get(forKey: .userActivityInProgressDistance) as? Data, let data =
                NSKeyedUnarchiver.unarchiveObject(with: activityDates) as? [AccessDistance]  else {
            return nil
        }
        return data
    }
    
    
    class func saveUserActivityReport(activityReport:UserActivityReport) {
        UserDefaults.standard.save(customObject: activityReport, inKey: String(describing: DefaultKey.userActivityScore))
    }
    
    class func getUserActivityReport() -> UserActivityReport {
        guard let activityReport = UserDefaults.standard.retrieve(object: UserActivityReport.self, fromKey: String(describing: DefaultKey.userActivityScore)) else { return UserActivityReport() }
        return activityReport
    }
}
/*
 class UserManager: NSObject {
 
 class func saveCurrentUser(user:User) {
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user)
 Defaults.shared.set(value: encodedData, forKey: .user)
 User.sharedInstance = user
 saveUserLocation(address: user.address ?? Address())
 saveUserGymLocation(address: user.gymAddress ?? Address())
 saveUserInterests(interest: user.interests)
 
 let encodedGymData: Data = NSKeyedArchiver.archivedData(withRootObject: user.gymAddress ?? Address())
 Defaults.shared.set(value: encodedGymData, forKey: .gymAddress)
 User.sharedInstance.gymAddress = user.gymAddress
 }
 
 class func saveUserLocation(address:Address) {
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: address)
 Defaults.shared.set(value: encodedData, forKey: .address)
 User.sharedInstance.address = address
 print("user defaults save")
 }
 class func saveUserGymLocation(address:Address) {
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: address)
 Defaults.shared.set(value: encodedData, forKey: .gymAddress)
 User.sharedInstance.gymAddress = address
 print("user defaults save")
 }
 class func saveUserInterests(interest:[String]) {
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: interest)
 Defaults.shared.set(value: encodedData, forKey: .interest)
 User.sharedInstance.interests = interest
 print("user defaults save")
 }
 class func saveUseractivityDates(data:[AccessDictionary]) {
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data)
 Defaults.shared.set(value: encodedData, forKey: .userActivityInProgressDates)
 print("user defaults save")
 }
 class func saveEventActivityOnDates(_ eventID:String?,_ data:[AccessDictionary]) {
 guard let eventID = eventID else {return}
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data)
 
 CustomDefaults.eventDates.set(encodedData, forKey: eventID)
 CustomDefaults.eventDates.synchronize()
 
 }
 
 class func removeActAddOnDatesDistance(_ eventID:String?) {
 guard let eventID = eventID else {return}
 
 CustomDefaults.eventDates.removeObject(forKey: eventID)
 CustomDefaults.eventDates.synchronize()
 CustomDefaults.eventDistByDate.removeObject(forKey: eventID)
 CustomDefaults.eventDistByDate.synchronize()
 }
 
 class func saveEventActivityOnaDistance(_ eventID:String?,_ data:[AccessDistance]) {
 guard let eventID = eventID else {return}
 
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data)
 CustomDefaults.eventDistByDate.set(encodedData, forKey: eventID)
 CustomDefaults.eventDistByDate.synchronize()
 }
 
 class func saveUseractivityDistance(data:[AccessDistance]) {
 let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data)
 Defaults.shared.set(value: encodedData, forKey: .userActivityInProgressDistance)
 print("user defaults save")
 }
 
 class func isUserLoggedIn() -> Bool {
 if Defaults.shared.get(forKey: .user) != nil {
 return true
 } else {
 return false
 }
 }
 class func saveCartCount(value: Int) {
 Defaults.shared.set(value: value, forKey: .cartCount)
 }
 class func cartCount() -> Int {
 return Defaults.shared.get(forKey: .cartCount) as? Int ?? 0
 }
 
 class func resetCartCount() {
 Defaults.shared.remove(.cartCount)
 }
 
 class func updateCartCount() {
 if var count = Defaults.shared.get(forKey: .cartCount) as? Int {
 count += 1
 saveCartCount(value: count)
 } else {
 saveCartCount(value: 1)
 }
 }
 
 class func decrementCartCount() {
 if var count = Defaults.shared.get(forKey: .cartCount) as? Int {
 count -= 1
 saveCartCount(value: count >= 0 ? count : 0)
 } else {
 saveCartCount(value: 0)
 }
 }
 
 class func logout() {
 NotificationCenter.default.post(name: Notification.Name.removeFirestoreListeners, object: nil)
 NotificationCenter.default.post(name: Notification.Name.stopStepsUpdateTimer, object: nil)
 SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
 SideMenuManager.default.leftMenuNavigationController?.dismiss(animated: false, completion: nil)
 for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
 //remove all user defaults keys except these
 if key == DefaultKey.firstRun.rawValue || key == DefaultKey.muteStatus.rawValue || key == DefaultKey.healthApp.rawValue || key == "fitbit_token" || key == DefaultKey.fcmToken.rawValue {
 continue
 }
 UserDefaults.standard.removeObject(forKey: key)
 }
 DIFirebaseImageManager.firebaseInstance.cancelAllTasks()
 //clear the user posts core data stack
 /*let fetchPredicate = NSPredicate(format: "isuploaded == %d",CustomBool.no.rawValue)
  CoreDataManager.shared.delete(entityName: Constant.CoreData.postEntity, fromContext: appDelegate.persistentContainer.viewContext, predicate: fetchPredicate) */
 HomePageViewController.reachabilityManager?.stopListening()
 CoreDataManager.shared.delete(entityName: Constant.CoreData.postEntity, fromContext: appDelegate.persistentContainer.viewContext)
 
 //This function will remove the Current access token ....
 FacebookManager.shared.removeFBSDKAcessToken()
 
 // Reset HealthHelper status
 HealthKit.instance?.reset()
 }
 
 class func removeAtivityData() {
 for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
 //remove all user defaults keys except these
 if key == DefaultKey.userActivityInProgress.rawValue || key == DefaultKey.isActivity.rawValue || key == DefaultKey.userActivityData.rawValue || key == DefaultKey.userActivityInProgressDates.rawValue || key == DefaultKey.userActivityInProgressDistance.rawValue{
 Defaults.shared.removeActivityPaceValues()
 UserDefaults.standard.removeObject(forKey: key)
 }else{
 continue
 }
 
 }
 }
 
 class func removeStatsOfAtivityData() {
 for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
 //remove all user defaults keys except these
 if key == DefaultKey.userActivityInProgressDates.rawValue || key == DefaultKey.userActivityInProgressDistance.rawValue{
 UserDefaults.standard.removeObject(forKey: key)
 }else{
 continue
 }
 
 }
 }
 
 
 class func getCurrentUser() -> User? {
 
 guard let userData = Defaults.shared.get(forKey: .user) as? Data, let user =
 NSKeyedUnarchiver.unarchiveObject(with: userData) as? User  else {
 return nil
 }
 user.address = getCurrentUserAddress() ?? Address()
 user.gymAddress = getGymAddress() ?? Address()
 user.interests = getInterests() ?? [String]()
 return user
 }
 
 /// increment or decrement unread count as per the + or - operator passed in as argument
 ///
 /// - Parameter operation: + for increment, - for decrement
 class func updateUnreadCount(_ operation: ((Int, Int) -> Int)) {
 if let currentUser = UserManager.getCurrentUser(),
 let count = currentUser.unreadNotiCount {
 let result = operation(count, 1)
 if result < 0 {
 currentUser.unreadNotiCount = 0
 } else {
 currentUser.unreadNotiCount = result
 }
 UserManager.saveCurrentUser(user: currentUser)
 }
 }
 
 class func getCurrentUserAddress() -> Address? {
 
 guard let addressData = Defaults.shared.get(forKey: .address) as? Data, let address =
 NSKeyedUnarchiver.unarchiveObject(with: addressData) as? Address  else {
 return nil
 }
 return address
 }
 
 class func getGymAddress() -> Address? {
 
 guard let addressData = Defaults.shared.get(forKey: .gymAddress) as? Data, let address =
 NSKeyedUnarchiver.unarchiveObject(with: addressData) as? Address  else {
 return nil
 }
 return address
 }
 
 class func getInterests() -> [String]? {
 
 guard let interestData = Defaults.shared.get(forKey: .interest) as? Data, let interests =
 NSKeyedUnarchiver.unarchiveObject(with: interestData) as? [String]  else {
 return nil
 }
 return interests
 }
 
 
 class func getActivityAddOnaDates(_ eventID:String?) -> [AccessDictionary]? {
 
 guard let eventID = eventID else {return nil}
 guard let activityDates = CustomDefaults.eventDates.value(forKey: eventID) as? Data, let data =
 NSKeyedUnarchiver.unarchiveObject(with: activityDates) as? [AccessDictionary]  else {
 return nil
 }
 return data
 }
 
 class func getActivityAddOnDistance(_ eventID:String?) -> [AccessDistance]? {
 guard let eventID = eventID else {return nil}
 
 guard let activityDates = CustomDefaults.eventDistByDate.value(forKey: eventID) as? Data, let data =
 NSKeyedUnarchiver.unarchiveObject(with: activityDates) as? [AccessDistance]  else {
 return nil
 }
 return data
 }
 
 
 class func getUserActivityDates() -> [AccessDictionary]? {
 
 guard let activityDates = Defaults.shared.get(forKey: .userActivityInProgressDates) as? Data, let data =
 NSKeyedUnarchiver.unarchiveObject(with: activityDates) as? [AccessDictionary]  else {
 return nil
 }
 return data
 }
 
 class func getUserActivityDistance() -> [AccessDistance]? {
 
 guard let activityDates = Defaults.shared.get(forKey: .userActivityInProgressDistance) as? Data, let data =
 NSKeyedUnarchiver.unarchiveObject(with: activityDates) as? [AccessDistance]  else {
 return nil
 }
 return data
 }
 
 class func saveUserActivityReport(activityReport:UserActivityReport) {
 UserDefaults.standard.save(customObject: activityReport, inKey: String(describing: DefaultKey.userActivityScore))
 }
 
 class func getUserActivityReport() -> UserActivityReport {
 guard let activityReport = UserDefaults.standard.retrieve(object: UserActivityReport.self, fromKey: String(describing: DefaultKey.userActivityScore)) else { return UserActivityReport() }
 return activityReport
 }
 }
 */
