//
//  AppDelegate.swift
//  TemApp
//
//  Created by Sourav on 2/7/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import GooglePlaces
import FirebaseDynamicLinks
//import Fabric
//import Crashlytics
import AVKit
import IQKeyboardManagerSwift
//import Instabug
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var foregroundEnterTime: Date?
    var backgroundEnterTime: Date?
    
    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var locationList: [CLLocation] = []
    var didFindLocation = false
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var bgtimer : Timer?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initiate WCSession and check sesssion supported or not
        if !Watch_iOS_SessionManager.shared.isSuported() {
            print("WCSession not supported (i.e. on iPad).")
        }

        //This Function will call to implement:---
        //It is implemented in Extension
        self.clearKeychainOnFirstInstall()

        //setting default mute status to true initially
        if Defaults.shared.get(forKey: .muteStatus) == nil {
            Defaults.shared.set(value: true, forKey: .muteStatus)
        }

        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(StreamAudienceVC.self)

        appIntializerAfterLaunch(application: application)

        GMSPlacesClient.provideAPIKey(Constant.ApiKeys.google)//Client

        //Facebook......
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions:launchOptions)


        // setting this audio session to mix with others so that other audio sessions(from other apps like music apps) donot get paused
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
        
        if (Defaults.shared.get(forKey: .healthApp) as? String) == nil {
            Defaults.shared.set(value: HealthAppType.healthKit.title , forKey: .healthApp)
        }
        
        if (launchOptions?[UIApplication.LaunchOptionsKey.location]) != nil {
            initalizeLocation()
            startLocation()
        }

        if HealthKit.instance?.healthSyncEnabled == true {
            HealthKit.instance?.startObservingWorkoutsWithBackgroundDelivery { (_, _) in
                print(">>> Background receiving of workouts triggered")
            }
        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(60)
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in

                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            })
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        accessLocationInBackground()
        // disconnectSocket()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func accessLocationInBackground(){
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            if let data = ActivityProgressData.currentActivityInfo(){
                if let isPlaying = data.isPlaying,isPlaying{
                    doBackgroundTask()
                }
            }
        }
    }
    
    func doBackgroundTask() {
        DispatchQueue.main.async {
            self.StartupdateLocation()
            self.bgtimer = Timer.scheduledTimer(timeInterval:10, target: self, selector: #selector(self.bgtimer(_:)), userInfo: nil, repeats: true)
            if let timer = self.bgtimer{
                RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
            }
        }
    }

    func StartupdateLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    @objc func bgtimer(_ timer:Timer!){
        sleep(2)
        print("updateLocation----->",timer.fireDate)
        self.updateLocation()
    }

    func updateLocation() {
        self.locationManager.startUpdatingLocation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        self.foregroundEnterTime = Date()
        NotificationCenter.default.post(name: Notification.Name.applicationEnteredFromBackground, object: nil)
        if let visibleController = Utility.getCurrentViewController() as? LeftSideMenuController {
            visibleController.getUpdatedUnreadNotiCount()
        }
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil, userInfo: nil)
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            if let data = ActivityProgressData.currentActivityInfo(){
                if let isPlaying = data.isPlaying,isPlaying{
                    if self.bgtimer != nil{
                        self.bgtimer?.invalidate()
                        self.bgtimer = nil
                    }
                }
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //connectSocket()
        application.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        self.saveContext(succes: {
            
        }, fail: { (_) in
            
        })
    }

    // MARK: Dynamic link handling
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
            guard error == nil else {
                return
            }
            if let dynamicLink = dynamiclink {
                self.handleDynamicLink(dynamicLink: dynamicLink)
            }
        }
        return handled
    }
    
    func handleDynamicLink(dynamicLink: DynamicLink) {
        if let url = dynamicLink.url {
            if let postId = url.valueOf("post_id") {
                //redirect to post detail screen
                self.handleDynamicLinkOfPost(postId: postId)
            } else if let affiliateMarketId = url.valueOf("id") {
                self.handleDynamicLinkOfAffiliate(marketPlaceId: affiliateMarketId)
            }
        }
    }
    
    func handleDynamicLinkOfPost(postId: String) {
        if UserManager.getCurrentUser() != nil {
            self.redirectToPostDetails(withPostId: postId)
        } else {
            //save deeplink information
            let deepLinkInfo = DeepLinkInfo(postId: postId)
            self.saveDeepLinkInfo(info: deepLinkInfo)
        }
    }

    func handleDynamicLinkOfAffiliate(marketPlaceId: String) {
        if UserManager.getCurrentUser() != nil {
            self.redirectToAffiliateLandingPage(marketPlaceId: marketPlaceId)
        } else {
            //save deeplink information
            let deepLinkInfo = DeepLinkInfo(affiliateMarketPlaceId: marketPlaceId)
            self.saveDeepLinkInfo(info: deepLinkInfo)
        }
    }
    /// saving the deep link information in user defaults
    func saveDeepLinkInfo(info: DeepLinkInfo) {
        if let encodedData = try? JSONEncoder().encode(info) {
            Defaults.shared.set(value: encodedData, forKey: DefaultKey.deeplinkInfo)
        }
    }
    
    /// getting the deep link information, if any, from user defaults
    func deepLinkInfo() -> DeepLinkInfo? {
        if let data = Defaults.shared.get(forKey: .deeplinkInfo) as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(DeepLinkInfo.self, from: data) {
                Defaults.shared.remove(.deeplinkInfo)
                return decodedData
            }
        }
        return nil
    }

    func saveDeepLinkRedirection(value: Bool) {
        Defaults.shared.set(value: value, forKey: .isDeepLinkPage)
    }

    func getDeepLinkRedirectionStatus() -> Bool {
        guard let isDeepLinkPage = Defaults.shared.get(forKey: .isDeepLinkPage) as? Bool else {
            return false
        }
        return isDeepLinkPage
    }
    
    //redirect to screen
    func redirectToPostDetails(withPostId id: String) {
        if let topController = Utility.getCurrentViewController()  {
            if let postcontroller = topController  as? PostDetailController,
                let postId = postcontroller.postId,
                postId == id {
                postcontroller.refreshView()
                return
            }
            if topController is CreateProfileViewController || topController is SelectInterestViewController {
                //save deeplink information
                let deepLinkInfo = DeepLinkInfo(postId: id)
                self.saveDeepLinkInfo(info: deepLinkInfo)
                return
            }
            let postDetailsVC: PostDetailController = UIStoryboard(storyboard: .profile).initVC()
            postDetailsVC.postId = id
            DispatchQueue.main.async {
                self.saveDeepLinkRedirection(value: true)
                let homePageVC: HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
                self.setNavigationToRoot(viewContoller: homePageVC)
                Utility.getCurrentViewController()?.navigationController?.pushViewController(postDetailsVC, animated: true)
            }
        }
    }

    func redirectToAffiliateLandingPage(marketPlaceId: String) {
        if let topController = Utility.getCurrentViewController()  {
            if let affiliateLandingcontroller = topController as? AffiliateLandingViewController {
                let marketPlaceID = affiliateLandingcontroller.marketPlaceId
                if marketPlaceID == marketPlaceID {
                    return
                }
            }
            if topController is CreateProfileViewController || topController is SelectInterestViewController {
                //save deeplink information
                let deepLinkInfo = DeepLinkInfo(affiliateMarketPlaceId: marketPlaceId)
                self.saveDeepLinkInfo(info: deepLinkInfo)
                return
            }
            let affiliateLandingVC: AffiliateLandingViewController = UIStoryboard(storyboard: .contentMarket).initVC()
            affiliateLandingVC.marketPlaceId = marketPlaceId
            DispatchQueue.main.async {
                self.saveDeepLinkRedirection(value: true)
                let homePageVC: HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
                self.setNavigationToRoot(viewContoller: homePageVC)
                Utility.getCurrentViewController()?.navigationController?.pushViewController(affiliateLandingVC, animated: true)
            }
        }
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let topController = UIApplication.topViewController() {
            if topController.isKind(of: StreamAudienceVC.self) {
                return .all
            }
            return .portrait
        }
        return .portrait
    }

    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jqsoftware.MyLog" in the application's documents Application Support directory.
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //        print("applicationDocumentsDirectory : \(urls.last)")
        return urls[urls.count - 1] as NSURL
        
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "TemApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("TemApp.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            // Replace this with code to handle the error appropriately.
            
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()
        }
        return coordinator
        
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
        
    }()
    
    @available(iOS 10.0, *)
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        /*
         
         The persistent container for the application. This implementation
         
         creates and returns a container, having loaded the store for the
         
         application to it. This property is optional since there are legitimate
         
         error conditions that could cause the creation of the store to fail.
         
         */
        
        let container = NSPersistentContainer(name: "TemApp")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            
            if let error = error as NSError? {
                
                // Replace this implementation with code to handle the error appropriately.
                
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 
                 Typical reasons for an error here include:
                 
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 
                 * The device is out of space.
                 
                 * The store could not be migrated to the current model version.
                 
                 Check the error message to determine what the actual problem was.
                 
                 */
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
                
            }
            
        })
        
        return container
        
    }()
    
    
    // MARK: - Core Data Saving support
    
    
    
    func saveContext (succes: () -> (), fail: (NSError) -> ()) {
        
        if #available(iOS 10.0, *) {
            
            let context = persistentContainer.viewContext
            if context.hasChanges {
                
                do {
                    
                    try context.save()
                    succes()
                    
                } catch {
                    
                    // Replace this implementation with code to handle the error appropriately.
                    
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    let nserror = error as NSError
                    DILog.print(items: nserror)
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
            }
            
            
        } else {
            
            
            
            let context = self.managedObjectContext
            if (context?.hasChanges)! {
                
                do {
                    
                    try context?.save()
                    succes()
                    
                } catch {
                    
                    // Replace this implementation with code to handle the error appropriately.
                    
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    let nserror = error as NSError
                    
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    
                }
                
            }
            
            
            // Fallback on earlier versions
            
        }
        
    }
    
    func initalizeLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            distance = Measurement(value: 0, unit: UnitLength.meters)
            didFindLocation = false
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
            if #available(iOS 11.0, *) {
                locationManager.showsBackgroundLocationIndicator = true
            } else {
                // Fallback on earlier versions
            }
            //            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 1
            locationManager.activityType = .fitness
        }
    }
    
    func startLocation(){
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        //        self.locationManager.stopMonitoringSignificantLocationChanges()
        //        self.locationManager.startMonitoringSignificantLocationChanges() // re-register for significant location change
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
    }
    
    func stopLocation(){
        locationManager.stopUpdatingLocation()
        //        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

class OrientationManager {
    static var landscapeSupported: Bool = false
    static func setOrientation(_ orientation: UIInterfaceOrientation) {
            let orientationValue = orientation.rawValue
            UIDevice.current.setValue(orientationValue, forKey: "orientation")
            landscapeSupported = orientation.isLandscape
        }
}

extension AppDelegate:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            //            manager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("distance---->\(manager.location)")
        DispatchQueue.main.async {
            print("UIApplication.shared.backgroundTimeRemaining",UIApplication.shared.backgroundTimeRemaining)
        }
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            locationList.append(newLocation)
        }
    }
    
    func setUpGeofenceForJob(_ location :CLLocationCoordinate2D) {
        print("Geofence location----->",location)
        let geofenceRegionCenter = CLLocationCoordinate2DMake(location.latitude, location.longitude) 
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 10, identifier: "PlayaGrande") 
        geofenceRegion.notifyOnExit = true
        geofenceRegion.notifyOnEntry = true
        self.locationManager.startMonitoring(for: geofenceRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //        alertUserOnArrival(region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //        alertUserOnLeaving(region: region)
        didFindLocation = false
    }
    
    /// this will notify when the device will pass a certain region
    /// - Parameter region: CLRegion
    func alertUserOnLeaving(region:CLRegion){
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "You forgot to checkout"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
    }
    
    /// This will notify when the device will enter a region
    /// - Parameter region: CLRegion
    func alertUserOnArrival(region:CLRegion){
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "Welcome Please checkin"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
}
