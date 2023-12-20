//
//  Utility.swift
//  BaseProject
//
//  Created by MAC on 02/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration
import NVActivityIndicatorView
import Alamofire
import SideMenu

//import DrawerController
//import NHNetworkTime

@objc public class Utility: NSObject {
    
    static let shared = Utility()
  //  var activityContainer:UIView = UIView()
    var textFld : UITextField?
    var rightButton : UIButton?
    
    class func enableNetworkLog(value:Bool = true){
        Defaults.shared.set(value: value, forKey: .enableLog)
    }
    
    struct Months {
        static let arr = ["January","February","March","April","May","June","July",
                          "August","September","October","November","December"]
        
        static func getIndex(_ str:String) -> Int?{
            return arr.firstIndex(where:{$0.uppercased() == str})
        }
        static func actionType(_ prevSelMonth:Int, _ index:Int) -> GoToCalendar? {
            if index < prevSelMonth {
                return .PreMonth
            }else if index > prevSelMonth {
                return .NextMonth
            }
            return nil
        }
    }
    class func getHeadings() {
        PostManager.shared.getReportHeadings(success: { (data) in
            Constant.reportHeadings = data
        }) { (_) in
        }
    }
    
    class func showAlert(withTitle title: String = "", message:String? = nil, okayTitle:String = AppMessages.AlertTitles.Ok , cancelTitle:String? = nil , okCall:@escaping () -> ()  = {  }, cancelCall: @escaping () -> () = {  }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okayTitle, style: .default, handler: { (action) in
            okCall()
        }))
        if cancelTitle != nil {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                cancelCall()
            }))
        }
        alert.show()
    }
    
    class func getCurrentTimeZoneIdentifier() -> String{
        return TimeZone.current.identifier
    }
    static   let categories: [Category] = [Category(type: 1, name: "Mental Strength & Conditions"),
                                           Category(type: 2, name: "Physical Fitness"),
                                           Category(type: 3, name: "Nutrition Awareness"),
                                           Category(type: 5, name: "lifestyle"),
                                           Category(type: 4, name: "Sports")]
    
    
    func setEyeButton(_ txtFld : UITextField){
        Utility.shared.rightButton = nil
        Utility.shared.textFld = nil
        Utility.shared.rightButton = UIButton(type: .custom)
        Utility.shared.rightButton?.frame = CGRect(x:0, y:0, width:45, height:30)
        txtFld.rightViewMode = .always
        txtFld.rightView =  Utility.shared.rightButton
        txtFld.isSecureTextEntry = true
        Utility.shared.rightButton?.setImage(#imageLiteral(resourceName: "eye-close"), for: .normal)
        Utility.shared.rightButton?.setImage(#imageLiteral(resourceName: "eye"), for: .selected)
        Utility.shared.textFld = txtFld
        Utility.shared.rightButton?.addTarget(self, action: #selector(hideShowTextField), for: .touchUpInside)
    }
    
    /// convert the seconds to minutes and seconds and format it to show the average and in progress miles distance
    /// - Parameter totalSeconds: total time in seconds
    class func formatToMinutesAndSecondsOfMiles(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        //format the minutes value with the leading zeroes
        var formattedMinutes = "\(minutes)"
        var formattedSeconds = "\(seconds)"
        if minutes == 0 {
            formattedMinutes = "00"
        } else if minutes < 10 {
            formattedMinutes = "0\(minutes)"
        }
        if seconds == 0 {
            formattedSeconds = "00"
        } else if seconds < 10 {
            formattedSeconds = "0\(seconds)"
        }
        let timeFormatted = "\(formattedMinutes)" + "'" + "\(formattedSeconds)" + "\""
        return timeFormatted
    }
    
    //This method is used to cancel all alamofire requests.
    class func cancelAllRequest(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    class func showPopupOnTopViewController(withTitle title: String? = "", message:String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { (action) in
        }))
        let controller = UIApplication.topViewController()
        controller?.present(alert, animated: true, completion: nil)
        // present(alert, animated: true, completion: nil)
    }
    
    @objc public class func presentFitBitController(url:String) {
        if UIApplication.topViewController() as? FitBitLogin != nil {
        }else{
            let selectedVC:FitBitLogin = UIStoryboard(storyboard: .challenge).initVC()
            selectedVC.urlString = url
            UIApplication.topViewController()?.navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
    
    @objc public class func removeFitBitController() {
        UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
    }
    
    class func getDaysDifference(firstDate:Date,secondDate:Date) -> Int {
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        //        let date1 = calendar.startOfDay(for: firstDate)
        //        let date2 = calendar.startOfDay(for: secondDate)
        //
        let components = calendar.dateComponents([.day], from: firstDate, to: secondDate)
        return components.day ?? 0
    }
    class func getMinutesDifference(firstDate:Date,secondDate:Date) -> Int {
        //        let calendar = Calendar.current
        //
        //        // Replace the hour (time) of both dates with 00:00
        ////        let date1 = calendar.startOfDay(for: firstDate)
        ////        let date2 = calendar.startOfDay(for: secondDate)
        //
        //        let components = calendar.dateComponents([.hour,.minute], from: firstDate, to: secondDate)
        return Int(secondDate.timeIntervalSince(firstDate)/60)
    }
    
    class func userLogoutPopup(withTitle title: String? = "", message:String? = nil) {
        NotificationCenter.default.post(name: Notification.Name.removeFirestoreListeners, object: nil)
        NotificationCenter.default.post(name: Notification.Name.stopStepsUpdateTimer, object: nil)
        SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { (action) in
            UserManager.logout()
            let loginVC:LoginViewController = UIStoryboard(storyboard: .main).initVC()
            appDelegate.setNavigationToRoot(viewContoller: loginVC)
        }))
        let controller = UIApplication.shared.keyWindow?.rootViewController//UIApplication.topViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            controller?.present(alert, animated: true, completion: nil)
        }
        
        // present(alert, animated: true, completion: nil)
    }
    
    //actionSheet.delegate = self
    class func presentActionSheet(titleArray:[UserActions],titleColorArray:[UIColor], customTitles: [String] = [], tag:Int,section:Int = 0) -> CustomBottomSheet {
        let controller = UIApplication.topViewController() ?? UIViewController()
        let window = UIApplication.shared.keyWindow
        var actionSheet = CustomBottomSheet()
        actionSheet = CustomBottomSheet(frame: controller.view.frame)
        actionSheet.actionTitle = titleArray
        actionSheet.colors = titleColorArray
        if !customTitles.isEmpty {
            actionSheet.customTitles = customTitles
        }
        actionSheet.tag = tag
        actionSheet.section = section
        actionSheet.setupViewElements()
        window?.addSubview(actionSheet)
        return actionSheet
    }
    
    
    @objc func hideShowTextField(){
        Utility.shared.textFld?.isSecureTextEntry.toggle()
        Utility.shared.rightButton?.isSelected = !(Utility.shared.textFld?.isSecureTextEntry ?? false)
    }
    
    class func getUserName(firstName:String,lastName:String,userName:String) -> String {
        var name = ""
        if userName != "" {
            name = userName
        }else{
            if firstName != "" {
                name = "\(firstName) \(lastName)".trim
            }
        }
        return name
    }
    class func getAddress(userAddress:Address) -> String {
        var address = ""
        let city = userAddress.city ?? ""
        let state = userAddress.state ?? ""
        
        if city != "" {
            address += city
        }
        if state != "" {
            address = address + ", " + state
        }
        return address.trim
    }
    
    class func currentDate() -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        return myStringafd
        
    }
    
    
    
    
    class func startOfMonth(inFormat format: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = format.format
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        let startOfMonth = Calendar.current.date(from: comp)!
        print(dateFormatter.string(from: startOfMonth))
        return startOfMonth
    }
    /*func startServerTimeSync (){
     NHNetworkClock.shared().synchronize()
     }
     func isServerTimeSync() -> Bool {
     return NHNetworkClock.shared().isSynchronized
     } */
    
    //Check network connectivity.
    class func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    class func utcDateFormatter(dateFormat:String) -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = NSTimeZone.init(abbreviation: "UTC")! as TimeZone
        return formatter
    }
    class  func timeZoneDateFormatter(format:Constant.DateFormates,timeZone:TimeZone? = NSTimeZone.local) -> DateFormatter {
        let formatter = dateFormatter(format:format)
        formatter.timeZone = timeZone
        return formatter
    }
    func dateFormatter(format:Constant.DateFormates) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter
    }
    
    class func getPagingSpinner() -> UIActivityIndicatorView {
        let pagingSpinner = UIActivityIndicatorView(style: .gray)
        pagingSpinner.startAnimating()
        pagingSpinner.color = appThemeColor
        pagingSpinner.hidesWhenStopped = true
        pagingSpinner.tag = 100
        return pagingSpinner
    }
    
    func currentTimeStamp() ->   Int64{
        let timestamp = (Date().timeIntervalSince1970) * 1000
        let currentTimestamp: Int64 = Int64(timestamp)
        return currentTimestamp
    }
    /*class  func checkVersionUpdate() {
     SpotManager.shared.checkVersionUpdate(success: { (data) in
     let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
     let currentVersion = "\(data["ios_version"] as? NSNumber ?? 0)"
     if appVersion == currentVersion {
     }else{
     let alertcontroller = UIAlertController(title: "New version available!", message: "Please, update app to new version.", preferredStyle: .alert)
     let action = UIAlertAction(title: "UPDATE", style: .default, handler: { (action) in
     let url = URL(string:"https://itunes.apple.com/us/app/spottales/id1254416033?ls=1&mt=8")
     if #available(iOS 10.0, *) {
     UIApplication.shared.open(url!, options: [:], completionHandler: nil)
     } else {
     
     }
     })
     alertcontroller.addAction(action)
     UIApplication.shared.keyWindow?.rootViewController?.present(alertcontroller, animated: true, completion: nil)
     }
     }) { (error) in
     }
     } */
    
    /*func isInternetAvailable() -> Bool {
     var zeroAddress = sockaddr_in()
     zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
     zeroAddress.sin_family = sa_family_t(AF_INET)
     guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
     $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
     SCNetworkReachabilityCreateWithAddress(nil, $0)
     }
     }) else {
     return false
     }
     
     var flags: SCNetworkReachabilityFlags = []
     if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
     return false
     }
     
     let isReachable = flags.contains(.reachable)
     let needsConnection = flags.contains(.connectionRequired)
     
     return (isReachable && !needsConnection)
     } */
    
    func getFileNameWithDate() -> String {
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date())
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        return myStringafd
    }
    
    /*func openLocationSetting() {
     Utility.showAlert(withTitle: appName, message: ErrorMessage.SpottaleLocation.EmptyLocation.message, okayTitle: "Settings".localized, cancelTitle: "Cancel", okCall: {
     UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
     }, cancelCall: {
     
     })
     } */
    
    
//    func showLoader12() {
//        activityContainer = UIView(frame: UIScreen.main.bounds)
//        let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40), color: .white, padding: 0)
//        activityContainer.restorationIdentifier = "loader"
//        activityContainer.tag = 102017
//        activityIndicatorView.center = activityContainer.center
//        activityContainer.backgroundColor = .black
//        activityContainer.alpha = 0.5
//        activityIndicatorView.startAnimating()
//        activityContainer.addSubview(activityIndicatorView)
//        UIApplication.shared.keyWindow!.addSubview(activityContainer)
//    }
    
    
//    func hideLoader12() {
//        activityContainer.removeFromSuperview()
//    }
    
    // Returns the most recently presented UIViewController (visible)
    class func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    // Returns the navigation controller if it exists
    class func getNavigationController() -> UINavigationController? {
        
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {
            
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    func currentPageNumberFor(currentRequestsCount: Int, paginationLimit: Int) -> Int {
        //        var num = (Double(self.arrSentRquest.count)/5.0).rounded(.up)
        let num = currentRequestsCount / paginationLimit
        return num
    }
    
    class func getImageByEventType(_ eventType:EventType) -> UIImage{
        switch eventType {
        case .regular: return #imageLiteral(resourceName: "actBig")
        case .challenges: return #imageLiteral(resourceName: "challenges")
        case .goals: return #imageLiteral(resourceName: "goals")
        case .signupSheet: return #imageLiteral(resourceName: "actBig")
        }
    }
    
    //-- Get number of weeks from calendar
    class func numberOfWeeksInMonth(_ date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        let weekRange = calendar.range(of: .weekOfMonth,
                                       in: .month,
                                       for: date)
        
        return weekRange!.count
    }
    
    class func dateFormatter(format:Constant.DateFormates) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter
    }
    
    //    class func timeZoneDateFormatter(format:Constant.DateFormates,timeZone:TimeZone? = NSTimeZone.local) -> DateFormatter {
    //        let formatter = dateFormatter(format:format)
    //        formatter.timeZone = timeZone
    //        return formatter
    //    }
    
    class func orderedViewControllers() -> [UIViewController] {
        return [Utility.viewController(type: .homePage),
                Utility.viewController(type: .feeds),
                Utility.viewController(type: .report),
                Utility.viewController(type: .network),
                Utility.viewController(type: .activity)]
    }
    
    class func orderedViewsControllers() -> [UIViewController] {
        return [Utility.viewController(type: .homePage),
                Utility.viewController(type: .feeds),
                Utility.viewController(type: .report),
                Utility.viewController(type: .network),
                Utility.viewController(type: .activityProgress)]
    }
    
    // MARK: Private methods.....
    class func viewController(type:DashboardController) -> UIViewController {
        switch type {
        case .activity:
            let controller:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
            return controller
        case .homePage:
            let controller:HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
            return controller
        case .network:
            let controller:TemsViewController = UIStoryboard(storyboard: .dashboard).initVC()
            return controller
        case .feeds:
            let controller:FeedsViewController = UIStoryboard(storyboard: .post).initVC()
            return controller
        case .report:
            let controller:ReportViewController = UIStoryboard(storyboard: .reports).initVC()
            return controller
        case .activityProgress:
            let controller:ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
            return controller
        }
    }
    
    /// calculates the calories from the formula
    /// - Parameter metValue: met value of the respective activity
    /// - Parameter duration: duration in hours
    class func calculatedCaloriesFrom(metValue: Double, duration: Double) -> Double {
        let genderValue = UserManager.getCurrentUser()?.gender ?? 0
        let gender = Gender(rawValue: genderValue) ?? .none
        var weight: Double = Double(UserManager.getCurrentUser()?.weight ?? 0)
        if weight == 0 {
            weight = Double(gender.defaultWeight)
        }
        let caloriesCalculated = (weight/2.205) * metValue * duration
        return caloriesCalculated
    }
    
    
}

extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFrom(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFrom(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFrom(controller: visibleVC, animated: animated, completion: completion)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFrom(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion)
            }
        }
    }
}

extension Utility {
    /// call this function to convert the seconds to hours, minutes and seconds format
    ///
    /// - Parameter seconds: total seconds
    /// - Returns: (hours, minutes, seconds)
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func secondsToStringTime(seconds : Int) -> String {
        let time =  secondsToHoursMinutesSeconds(seconds: seconds)
        return formattedTimeWithLeadingZeros(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
    }
    func formattedTimeWithLeadingZeros(hours: Int, minutes: Int, seconds: Int) -> String {
        // Format time vars with leading zero
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let displayTime = "\(strHours):\(strMinutes):\(strSeconds)"
        return displayTime
    }
    func minutesToHoursAndMinutes (minutes : Int) -> String {
        let hours = (minutes % 60)
        let leftMins = minutes % 60
        return "\(hours): \(leftMins)"
    }
}

extension TimeZone {
    
    func offsetFromUTC() -> String
    {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }
    
    func offsetInHours() -> String
    {
        
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return tz_hr
    }
}
