//
//  WChooseActivityVC.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-03-25.
//

import WatchKit
import Foundation

/// This class will hold the activities data until the app is in memory
class ActivityResponse {
    static let sharedInstance = ActivityResponse()
    var activityData: [ActivityData]?
    
    private init() {}
}

class WChooseActivityVC: WKInterfaceController {

    // MARK: IBOutlets
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var pickerGroup: WKInterfaceGroup!
    @IBOutlet weak var itemPicker: WKInterfacePicker!
    @IBOutlet weak var activityIndicatorGroup: WKInterfaceGroup!
    @IBOutlet weak var activityIndicatorImageView: WKInterfaceImage!
    
    // MARK: Properties
    private var activityArray:[ActivityData] = []
    private var durationList:[MetricValue] = []
    private var distanceList:[MetricValue] = []
    private var selectedActivity:ActivityData = ActivityData()

    private var selectedDistancePicker = false
    private var contextDict = [String:Any]()
    private var startActivityRequestDict = [String:Any]()
    private var activityState: ActivityPauseState = .none
    private var combinedActivity: CombinedActivity?
    private var combinedActivityEncodedData: Data?
    
    // MARK: Interface Life Cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("New Activity controller -------------")
        WatchKitConnection.shared.sessionStarted()
        NotificationCenter.default.addObserver(self, selector: #selector(selectro), name: Notification.Name("willEnterForeground"), object: nil)
        //if context != nil, means it is coming from inProgressActivity to add new activity
        if let conDict = context as? [String:Any] {
            self.contextDict = conDict
            if let isAdditionalActivity = contextDict["additionalActivityAdded"] as? Bool,
                isAdditionalActivity == true {
                self.activityState = .newActivityAdded
                //save the last activity data
                if let activityData = contextDict["activityData"] as? CombinedActivity {
                    self.combinedActivity = activityData
                }
            }
        }
        contextDict["isScheduled"] = NSNumber(value: false) //Default set for scheduled activity to NO
        
        pickerGroup.setHidden(true)
        itemPicker.setHidden(true)
        table.setHidden(true)
        activityIndicatorGroup.setHidden(false)
        activityIndicatorImageView.setImageNamed("Activity")
        activityIndicatorImageView.startAnimatingWithImages(in: NSRange(location: 0,
                                                                        length: 30), duration: 5, repeatCount: 0)
        self.checkIfUserIsLoggedIn()
        
        if self.activityState != .newActivityAdded {
            WorkoutTracking.instance.recoverActiveWorkoutSession()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("Will activate home screen")
        WatchKitConnection.shared.delegate = self
//        self.displayActivityOnWillActivate()

    }
    
    @objc func selectro() {
        self.displayActivityOnWillActivate()
    }
    
    deinit {
        print("deinit 111")
        NotificationCenter.default.removeObserver(self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.activityIndicatorImageView.stopAnimating()
    }
    
    // MARK: Table View Datasource
    private func loadTableData() {
        
        self.pickerGroup.setHidden(true)
        self.itemPicker.setHidden(true)
        self.activityIndicatorGroup.setHidden(true)
        self.table.setHidden(false)
        
        var rowTypes: [String] = self.activityArray.map { _ in "WChooseActivityRow" }
        rowTypes.append("AppVersionRow")
        table.setRowTypes(rowTypes)
        
        for(index,data) in self.activityArray.enumerated() {
            if let rowController = table.rowController(at: index) as? WChooseActivityRow {
                rowController.cellLabel.setText("\(String(describing: data.name ?? ""))")
            }
        }
        
        if let rowController = table.rowController(at: table.numberOfRows - 1) as? AppVersionRow {
            rowController.version.setText(BuildConfiguration.shared.appVersion)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex < activityArray.count {
            contextDict["SelectedActivity"] = self.activityArray[rowIndex].name ?? ""
            contextDict["SelectedActivityImage"] = self.activityArray[rowIndex].image ?? ""
            self.selectedActivity = self.activityArray[rowIndex]
            self.selectedActivity.selectedActivityType = self.activityArray[rowIndex].activityType
            self.startActivityRequestDict["activityId"] = self.activityArray[rowIndex].id ?? 0
            if let activityType = self.activityArray[rowIndex].activityType {
                self.startActivityRequestDict["activityType"] = activityType
            }
            self.contextDict["StartActivityRequest"] = self.startActivityRequestDict
            self.addNewActivity()
        }
    }
    
    // MARK: Helpers
    /// display in progress screen if the activity is in progress every time the screen activates
    private func displayActivityOnWillActivate() {
        if self.activityState == .newActivityAdded {
            return
        }
        if let data = Defaults.shared.get(forKey: .sharedActivityInProgress) {
            redirectToInProgressScreen(data: data)
        }
    }
    
    /// check if user is loged in the respective iphone app
    private func checkIfUserIsLoggedIn() {
        if let _ = Defaults.shared.get(forKey: .appHeaders) {
            HealthKit.instance?.requestAuthorization {
                self.checkTheAlreadyRunningActivity()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("is iPhone reachable : \(WatchKitConnection.shared.isReachable())")
                if WatchKitConnection.shared.isReachable() {
                    let request = ["request": "loginInfo"]
                    WatchKitConnection.shared.sendMessage(message: request, replyHandler: { (response) in
                        //got the response
                        if let headerInfo = response[MessageKeys.loginHeaders] as? [String: String] {
                            Defaults.shared.set(value: headerInfo, forKey: .appHeaders)
                            self.userLoggedInIphoneApp()
                        } else {
                            if let isLoggedIn = response["loggedIn"] as? Bool,
                                isLoggedIn == false {
                                self.showLoginAlert(WatchConstants.Messages.loginToTheIphoneApp, isUserLoggedIn: false)
                            }
                        }
                    }) { (error) in
                        self.showLoginAlert(WatchConstants.Messages.loginToTheIphoneApp, isUserLoggedIn: false)
                    }
                } else {
                    self.showLoginAlert(WatchConstants.Messages.loginToTheIphoneApp, isUserLoggedIn: false)
                }
            }
        }
    }
    
    private func startLoader(start: Bool, showTableAfterLoad: Bool) {
        if start {
            activityIndicatorGroup.setHidden(false)
            table.setHidden(true)
            activityIndicatorImageView.setHidden(false)
            activityIndicatorImageView.setImageNamed("Activity")
            activityIndicatorImageView.startAnimatingWithImages(in: NSRange(location: 0,
                                                                            length: 30), duration: 5, repeatCount: 0)
            
        } else {
            activityIndicatorGroup.setHidden(true)
            activityIndicatorImageView.stopAnimating()
            if showTableAfterLoad {
                table.setHidden(false)
            }
        }
    }
    
    /*SelectedPicker Values
     0 - Duration
     1 - Distance
    -1 - None
    */
    func showAlert() {
        let durationAction = WKAlertAction(title: "Duration", style: WKAlertActionStyle.default) {
            print("Duration")
            self.contextDict["SelectedPicker"] = "0"
            self.setPickerValues(self.durationList)
            if self.durationList.count > 0 {
                let data = self.durationList[0]
                self.startActivityRequestDict["durationId"] = data.id ?? 0
                self.startActivityRequestDict["activityTarget"] = "\(data.value ?? 0) \(data.unit ?? "")"
            }
            self.startActivityRequestDict["activityType"] = 2
            self.selectedActivity.activityType = 2
        }
        
        let distanceAction = WKAlertAction(title: "Distance", style: WKAlertActionStyle.default) {
            print("Distance")
            self.contextDict["SelectedPicker"] = "1"
            self.setPickerValues(self.distanceList)
            if self.distanceList.count > 0 {
                let data = self.distanceList[0]
                self.startActivityRequestDict["distanceId"] = data.id ?? 0
                self.startActivityRequestDict["activityTarget"] = "\(data.value ?? 0) \(data.unit ?? "")"
            }
            self.startActivityRequestDict["activityType"] = 1
            self.selectedActivity.activityType = 1

        }
        
        let noAction = WKAlertAction(title: "Open", style: WKAlertActionStyle.destructive) {
            print("None")
            self.contextDict["SelectedPicker"] = "-1"
            
            self.startActivityRequestDict["activityType"] = 3
            self.selectedActivity.activityType = 3
            
            self.pickerGroup.setHidden(true)
            self.itemPicker.setHidden(true)
            self.activityIndicatorGroup.setHidden(true)
            self.table.setHidden(false)
            self.contextDict["StartActivityRequest"] = self.startActivityRequestDict
            self.sendStartActivityRequest()
        }
        
        if ActivityMetric(rawValue:self.selectedActivity.activityType ?? 1) == .distance {
            presentAlert(withTitle: "", message: "Choose your Goal", preferredStyle: WKAlertControllerStyle.alert, actions:[durationAction,distanceAction,noAction])
        }else{
            presentAlert(withTitle: "", message: "Choose your Goal", preferredStyle: WKAlertControllerStyle.alert, actions:[durationAction,noAction])
        }
    }
    
    func setPickerValues(_ pickerArr : [MetricValue]) {
        pickerGroup.setHidden(false)
        itemPicker.setHidden(false)
        let pickerItems: [WKPickerItem] = pickerArr.map {
            let pickerItem = WKPickerItem()
            if $0.value == 0 {
                pickerItem.title = "\($0.unit ?? "")"
            }else if $0.value == 6 {
                pickerItem.title = "5+ \($0.unit ?? "")"
            }else if $0.value == 100 {
                pickerItem.title = "90+ \($0.unit ?? "")"
            }else{
                let finalValue = "\($0.value ?? 0)"
                pickerItem.title = "\(finalValue.replace(".0", replacement: "")) \($0.unit ?? "")"
            }
            return pickerItem
        }
        itemPicker.setItems(pickerItems)
    }
    
    @IBAction func pickerSelectedItemChanged(index: Int) {
        var data = MetricValue()
        if let type = self.startActivityRequestDict["activityType"] as? Int {
            switch type {
            case 1:
                if index < distanceList.count {
                    data = self.distanceList[index]
                    self.startActivityRequestDict["distanceId"] = data.id ?? 0
                    self.startActivityRequestDict["activityTarget"] = "\(data.value ?? 0) \(data.unit ?? "")"
                }
            case 2 :
                if index < durationList.count {
                    data = self.durationList[index]
                    self.startActivityRequestDict["durationId"] = data.id ?? 0
                    self.startActivityRequestDict["activityTarget"] = "\(data.value ?? 0) \(data.unit ?? "")"
                }
            default:
                break
            }
        }
    }
    
    @IBAction func pickerCancelButtonAction() {
        pickerGroup.setHidden(true)
        itemPicker.setHidden(true)
        activityIndicatorGroup.setHidden(true)
        table.setHidden(false)
    }
    
    @IBAction func pickerDoneButtonAction() {
        self.pickerGroup.setHidden(true)
        self.itemPicker.setHidden(true)
        activityIndicatorGroup.setHidden(true)
        self.table.setHidden(false)
        self.contextDict["StartActivityRequest"] = self.startActivityRequestDict
        self.sendStartActivityRequest()
    }
    
    private func presentStartActivityInterface() {
        self.contextDict["activityList"] = self.activityArray
        let context: [String: Any] = ["SelectedActivity": self.selectedActivity,
                       "startActivityRequestDict": self.startActivityRequestDict,
                       "contextDict": self.contextDict]
        self.pushController(withName: "StartActivityInterfaceController", context: context)
    }
    
    private func checkTheAlreadyRunningActivity() {
        if self.activityState == .newActivityAdded {
            self.getActivitiesListing()
            return
        }
        if let data = Defaults.shared.get(forKey: .sharedActivityInProgress) {
            redirectToInProgressScreen(data: data)
        } else {
            //call the api to get the activities listing
            self.getActivitiesListing()
        }
    }
    
    private func redirectToInProgressScreen(data: Any) {
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
    
    private func addNewActivity() {
        Defaults.shared.set(value: true, forKey: .isActivity)
        if self.activityState != .newActivityAdded {
            if let data = Defaults.shared.get(forKey: .sharedActivityInProgress) {
                self.redirectToInProgressScreen(data: data)
            } else {
                self.createNewActivityOnServer()
            }
        } else {
            self.createNewActivityOnServer()
        }
    }
    
    private func removeActivityData() {
        Defaults.shared.remove(.isActivityWatchApp)
        Defaults.shared.remove(.sharedActivityInProgress)
        Defaults.shared.removeActivityPaceValues()
        Defaults.shared.remove(.userActivityData)
        Defaults.shared.remove(.sharedUserActivityDates)
    }
    
    private func saveAdditionalActivityData() {
        //saving to defaults
        guard let combinedActivity = self.combinedActivity else {
            return
        }
        var activitiesArray = [CombinedActivity]()
        if let activities = CombinedActivity.currentActivityInfo() {
            var combinedActivities = activities
            combinedActivities.append(combinedActivity)
            activitiesArray = combinedActivities
        } else {
            activitiesArray.append(combinedActivity)
        }
        
        if !activitiesArray.isEmpty {
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(activitiesArray) {
                print("encoded data")
                self.combinedActivityEncodedData = encodedData
                Defaults.shared.set(value: encodedData, forKey: .combinedActivities)
                //self.updateActivityCreateStatusToPhoneApp(combinedActivityData: encodedData)
            }
        }
    }
    
    /// call this function to send the on-going activity information to the iPhone app
    func updateActivityCreateStatusToPhoneApp(combinedActivityData: Data) {
        let activityProgressInfo = self.getActivityProgressObject()
        activityProgressInfo.startTime = Date().timeIntervalSinceReferenceDate
        activityProgressInfo.isPlaying = true
        do {
            let data = try JSONEncoder().encode(activityProgressInfo)
            let infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
                                                 "request": MessageKeys.createdNewActivityOnWatch,
                                                 MessageKeys.additionalActivityAdded: combinedActivityData]
            WatchKitConnection.shared.updateApplicationContext(context: infoDictToPass)
        } catch {
            return
        }
    }
    
    
    /// set the activity progress object data
    private func getActivityProgressObject() -> ActivityProgressData {
        let objActivityProgressData:ActivityProgressData = ActivityProgressData()
        objActivityProgressData.activity = self.selectedActivity
        objActivityProgressData.createdAt = Date()
        objActivityProgressData.elapsed = 0
        objActivityProgressData.startTime = 0
        do {
            let progressDataToSend = objActivityProgressData
            progressDataToSend.startTime = Date().timeIntervalSinceReferenceDate
            progressDataToSend.isPlaying = true
            let data =  try JSONEncoder().encode(objActivityProgressData)
            let userActivityData = try JSONEncoder().encode(objActivityProgressData.activity)
            //in watch app
            Defaults.shared.set(value: data, forKey: .sharedActivityInProgress)
            var infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
                                                 "request": MessageKeys.createdNewActivityOnWatch,
                                                 MessageKeys.userActivityData: userActivityData]
            if self.activityState == .newActivityAdded,
                let encodedCombinedData = self.combinedActivityEncodedData {
                infoDictToPass[MessageKeys.additionalActivityAdded] = encodedCombinedData
            }
            WatchKitConnection.shared.updateApplicationContext(context: infoDictToPass)
        } catch {
            
        }
        return objActivityProgressData
    }
    
    func sendStartActivityRequest() {
        presentStartActivityInterface()
    }
    
    // MARK: Api Calls
    private func getActivitiesListing() {
        guard ActivityResponse.sharedInstance.activityData == nil else {
            print("GOT VALUE IN STORED VARIABLE")
            self.activityArray = ActivityResponse.sharedInstance.activityData ?? []
            self.loadTableData()
            return
        }
        ActivityNetworkLayer().getActivitiesList(completion: { (activities, distances, duration) in
            self.startLoader(start: false, showTableAfterLoad: true)
            if let activityCount = activities?.count{
                for activityCount in 0..<activityCount{
                    if let activityData = activities?[activityCount].type{
                     self.activityArray = activityData
                    }
                }
            }
           
         //   self.activityArray = activities ?? []
            ActivityResponse.sharedInstance.activityData = self.activityArray
            self.distanceList = distances ?? []
            self.durationList = duration ?? []
            DispatchQueue.main.async {
                self.loadTableData()
            }
        }) { (error) in
            self.showAlert(message: error.message ?? "Something went wrong!") {
                //retry
                self.checkIfUserIsLoggedIn()
            }
        }
    }
    
    private func createNewActivityOnServer() {
        self.startLoader(start: true, showTableAfterLoad: false)
        ActivityNetworkLayer().createActivity(parameters: self.startActivityRequestDict, success: { (data) in
            self.removeActivityData()
            if self.activityState == .newActivityAdded {
                self.saveAdditionalActivityData()
            }
            self.selectedActivity.activityProgressId = data["_id"] as? String ?? ""
            var externalTypes : ExternalActivityTypes? = nil
            if let types = data["externalTypes"] as? Parameters {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: types, options: .prettyPrinted)
                    externalTypes = try JSONDecoder().decode(ExternalActivityTypes.self, from: jsonData)
                }
                catch (let error) {
                    DILog.print(items: error.localizedDescription)
                }
            }
            self.selectedActivity.externalTypes = externalTypes
            self.contextDict["selectedActivity"] = self.selectedActivity
            if self.activityState == .newActivityAdded {
                WorkoutTracking.instance.endWorkout(caloriesCalc: self.combinedActivity?.calories ?? 0) { (success, error) in
                    DispatchQueue.main.async {
                        self.startLoader(start: false, showTableAfterLoad: false)
                        if success {
                            Defaults.shared.set(value: true, forKey: .isActivityWatchApp)
                            let contextDict = ["activityProgressData": self.getActivityProgressObject()]
                            WKInterfaceController.reloadRootPageControllers(withNames: ["WActivityActionsInterfaceController", "WInProgressActivityVC", "PlayingViewInterfaceController"], contexts: [[:] as AnyObject, contextDict], orientation: .horizontal, pageIndex: 1)
                        } else {
                            //error alert
                            if let error = error {
                                self.showLoginAlert(error, isUserLoggedIn: true)
                            }
                        }
                    }
                }
            } else {
                self.startLoader(start: false, showTableAfterLoad: false)
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "CountdownInterfaceController", context: self.contextDict as AnyObject)])
                }
            }
        }) { (error) in
            self.startLoader(start: false, showTableAfterLoad: true)
            self.showLoginAlert(error.message ?? "Something went wrong! Please try again", isUserLoggedIn: true)
        }
    }
}

// MARK: WatchKitConnectionDelegate
extension WChooseActivityVC: WatchKitConnectionDelegate {
    func userLoggedInIphoneApp() {
        DispatchQueue.main.async {
            self.dismiss()
        }
        HealthKit.instance?.requestAuthorization {
            self.checkTheAlreadyRunningActivity()
        }
    }
}
