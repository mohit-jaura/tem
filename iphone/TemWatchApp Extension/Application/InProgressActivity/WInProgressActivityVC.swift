//
//  WInProgressActivityVC.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-03-27.
//

import UIKit
import WatchKit
import WatchConnectivity

typealias AccessTuple = (startDate: Date, endDate: Date)
typealias AccessDictionary = [String: Date]
let startDateKey = "startDateKey"
let endDateKey = "endDateKey"

// MARK: Varaibles
/// Holds the cases for how the activity progress stopped
///
/// - activityTerminated: indicates that the activity was stopped by pressing stop button
/// - newActivityAdded: indicates that the activity was stopped by adding another activity
/// - none: default option which indicates in progress
enum ActivityPauseState {
    case activityTerminated, newActivityAdded, none
}

class WInProgressActivityVC: WKInterfaceController {
    
    // MARK: IBOutlets
    @IBOutlet weak var averageMileTextLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceGroup: WKInterfaceGroup!
    @IBOutlet weak var caloriesLabel: WKInterfaceLabel!
    @IBOutlet weak var durationLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateGroup: WKInterfaceGroup!
    @IBOutlet weak var inProgressTextLabel: WKInterfaceLabel!
    @IBOutlet weak var averageMileValueLabel: WKInterfaceLabel!
    @IBOutlet weak var inProgressValueLabel: WKInterfaceLabel!
    @IBOutlet weak var inProgressMileGroup: WKInterfaceGroup!
    @IBOutlet weak var averageMileGroup: WKInterfaceGroup!
    
    // MARK: Properties
    var contextDict = [String:Any]()
    var activityData = ActivityProgressData()
    fileprivate var elapsed: Double = 0
    fileprivate var startTime: Double = 0
    fileprivate var time: Double = 0
    fileprivate var isPlaying: Bool = false
    var count:Int = 0
    
    weak var timer: Timer?
    weak var distanceTimer : Timer?
    weak var caloriesTimer: Timer?
    weak var inProgressMileTimer: Timer?
    weak var watchSessionStateTimer: Timer?
    
    var durationLabelText = ""
    var startDate:Date?
    var totalTime:Double?
    var distance:Double = 0.0
    var totalSteps:Double = 0.0
    var totalCalories:Double = 0.0
    var totalDistance:Double = 0.0
    var tempDistance:Double = 0.0
    var heartRate: Double?
    var timeIntervel:AccessTuple = (Date(),Date())
    private var distanceFromSession: Double?
    
    var activityPausedState: ActivityPauseState = .none
    private var newProgressIdFromServer: String?
    
    var activityDates:[AccessTuple] = [AccessTuple]()
    
    var activityPausedDueToAlert = false
    
    var activityArray:[ActivityData] = []
    private var additionalActivity: ActivityData?
    private var averageHeartRate: Double?
    private var isDistanceTypeActivity: Bool = true
    
    // this is being used in the in-progress mile calculation
    private var singleMileCount: Int = 1
    private var lastMileCount: Int = 0
    private var lastMileCompletedTime: Double = 0
    private var avgMile: Double = 0
    private var activityId: Int?
    private var activityType: ActivityMetric?
    private var kitActivityType: UInt?
    private var createdDateTime: Date = Date()
    
    // MARK: View Life Cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setSizes()
        self.setPaceValues()
        self.addConnectivityObserver()
        WatchKitConnection.shared.delegate = self
        showLoader()
        
        if let conDict = context as? [String:Any] {
            if let arr = conDict["activityList"] as? [ActivityData] {
                self.activityArray = arr
            }
            
            //Fetching Last Start Activity Data
            if let lastActData = conDict["activityProgressData"] as? ActivityProgressData,
               let kit = lastActData.activity?.externalTypes?.HealthKit,
               let kitActivityType = UInt(kit) {
                WorkoutTracking.instance.delegate = self
                self.createdDateTime = lastActData.createdAt ?? Date()
                self.activityId = lastActData.activity?.id
                self.kitActivityType = kitActivityType
//                self.activityType = lastActData.activity?.activityType
                
                print("WORKOUT START COMMAND")
                WorkoutTracking.instance.startWorkout(activityId: lastActData.activity?.id ?? 1, startTime: lastActData.createdAt ?? Date(), kitActivityType: kitActivityType) { (success, error) in
                    if !success {
                        if error != nil {
                            //if there was some error in creating the session, return
                            self.errorInSession(error: "There was some error in creating workout. Please try again")
                            return
                        }
                    }
                }
                self.activityData = lastActData
                self.newProgressIdFromServer = "\(String(describing: lastActData.activity?.id))"
            }
            
            if (conDict["FromScreen"] as? String) != nil {
                //coming after adding additioal activity
            }
            self.contextDict = conDict
        }
        //self.watchSessionStateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.watchTimerState), userInfo: nil, repeats: true)
        self.setWatchStateTimer()
        self.checkForCombinedActivitiesCount()
        setData()
        self.handleActivityState()
    }
    
    func errorInSession(error: String) {
        watchSessionStateTimer?.invalidate()
        watchSessionStateTimer = nil
        let request = ["request": MessageKeys.workoutSessionFailedInWatch,
                       "activityId": newProgressIdFromServer ?? ""]
        WatchKitConnection.shared.updateApplicationContext(context: request)
        //if there was some error in creating the session, return
        Defaults.shared.remove(.isActivityWatchApp)
        Defaults.shared.remove(.sharedActivityInProgress)
        Defaults.shared.remove(.userActivityData)
        Defaults.shared.removeActivityPaceValues()
        Defaults.shared.remove(.sharedUserActivityDates)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showAlert(message: error, okTitle: "OK") {
                WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "WChooseActivityVC", context: [:] as AnyObject)])
            }
        }
    }
    
    private func setSizes() {
        switch WKInterfaceDevice.currentResolution() {
            case .Watch44mm:
                self.averageMileTextLabel.setRelativeWidth(0.4, withAdjustment: 0)
            case .Watch40mm:
                break
            default:
                break
        }
    }
    
    func setWatchStateTimer() {
        if self.watchSessionStateTimer == nil {
            self.watchSessionStateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.watchTimerState), userInfo: nil, repeats: true)
        }
    }
    
    private func setPaceValues() {
        if let avgMile = Defaults.shared.get(forKey: .avgMile) as? Double {
            self.avgMile = avgMile
        }
        if let value = Defaults.shared.get(forKey: .singleMileCount) as? Int {
            self.singleMileCount = value
        }
        if let value = Defaults.shared.get(forKey: .lastMileCount) as? Int {
            self.lastMileCount = value
        }
        if let value = Defaults.shared.get(forKey: .lastMileCompletedTime) as? Double {
            self.lastMileCompletedTime = value
        }
    }
    
    private func checkForCombinedActivitiesCount() {
        if let activities = CombinedActivity.currentActivityInfo(),
           activities.count == 2 { //maximum of 3 combined activities can be performed at a time.
            //hide the add button on top
            
        }
    }
    
    private func fetchCurrentActivityFinalData() {
        self.activityData.currentPeriodStartingDate = Date()
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        self.count = 0
        self.getDataForTimeInterval()
    }
    
    
    // MARK: This will call when activity will stop by the user.(To collect Steps and Calories)
    func getDataFromHealthKit(data:AccessTuple) {
        self.getStepsFromHealthKit(startDate: data.startDate, endDate: data.endDate) { (steps, distance, calories) in
            self.totalCalories += calories
            self.totalDistance += distance
            self.totalSteps += steps
            self.count += 1
            
            if self.count < self.activityDates.count {
                self.getDataForTimeInterval()
            }else{
                self.updateServerToStopActivity()
            }
        }
    }
    
    // MARK: Function to get Steps from HealthKit
    func getStepsFromHealthKit(startDate:Date,endDate:Date,completion: @escaping (_ steps:Double,_ distance:Double,_ calories:Double) -> Void) {
        HealthKit.instance?.getStepsForTimePeriod(startDate: startDate, endDate: endDate, completion: { (steps, error) in
            var stepsCount = steps
            if error != nil {
                stepsCount = 0
            }
            self.getCaloriesFromHealthKit(startDate: startDate, endDate: endDate, completion: { (distance,calories) in
                completion(stepsCount,distance,calories)
            })
        })
    }
    
    // MARK: Function to get Calories from HealthKit
    func getCaloriesFromHealthKit(startDate:Date,endDate:Date,completion: @escaping (_ distance:Double,_ calories:Double) -> Void) {
        HealthKit.instance?.activeEnergyBurnedForTimePeriod(startDate: startDate, endDate: endDate, completion: { (calories, error) in
            var caloriesValue = calories
            if error != nil {
                caloriesValue = 0
            }
            self.getDistanceFromHealthKit(startDate: startDate, endDate: endDate, completion: { (distance) in
                completion(distance,caloriesValue)
            })
        })
    }
    
    // MARK: This Function will be called after 2 seconds to collect distance covered by user.
    @objc func getDistanceFromHealthKit(startDate:Date,endDate:Date,completion: @escaping (Double) -> Void){
        HealthKit.instance?.getWalkingDistanceForTimePeriod(startDate:startDate, endDate: endDate, completion: { (distance, error) in
            if error != nil {
                completion(0.0)
                return
            }
            completion(distance)
        })
    }
    
    // MARK: Function to fetch Data one by one for each time periods.
    func getDataForTimeInterval() {
        //OLD
        /*if self.count < self.activityDates.count {
         let data  = self.activityDates[count]
         self.getDataFromHealthKit(data: data)
         }else{
         self.updateServerToStopActivity()
         } */
        //NEW
        self.updateServerToStopActivity()
    }
    
    // MARK: This function will update server that activity has been completed by user.
    func updateServerToStopActivity() {
        
        if self.activityPausedState == .newActivityAdded {
            //set the choose activity screen as the root controller
            let context: [String: Any] = ["additionalActivityAdded": true,
                                          "activityData": self.getActivityObjectToSave()]
            self.watchSessionStateTimer?.invalidate()
            self.watchSessionStateTimer = nil
            NotificationCenter.default.post(name: Notification.Name.watchActivityAddNewActivityFromInProgressScreen, object: nil, userInfo: context)
            return
        }
        
        var currentActivityParams = [String : Any]()
        
        currentActivityParams["activityId"] = self.activityData.activity?.activityProgressId
        currentActivityParams["calories"] = self.calculateCalories(calories: totalCalories, duration: totalTime, metValue: self.activityData.activity?.metValue)//self.totalCalories.rounded(toPlaces: 2)
        currentActivityParams["steps"] = self.totalSteps
        currentActivityParams["distanceCovered"] = self.calculateDistance(activity: self.activityData.activity, distance: self.totalDistance)
        currentActivityParams["status"] = 2//completed(ActivityStateStatus)
        currentActivityParams["timeSpent"] = self.totalTime ?? 0.0
        currentActivityParams["isScheduled"] = self.activityData.isScheduled
        
        var activitiesArray = [[String: Any]]()
        
        if let activities = CombinedActivity.currentActivityInfo() {
            for activity in activities {
                if activity.activityData?.activity != nil {
                    let params = paramsFor(activity: activity)
                    activitiesArray.append(params)
                }
            }
        }
        
        activitiesArray.append(currentActivityParams)
        
        let params: [String: Any] = ["activities": activitiesArray]
        //self.sendCompleteActivityRequest(params)
        //NEW:
        self.completeActivityApiRequest(params)
    }
    
    private func getActivityObjectToSave() -> CombinedActivity {
        let combinedActivity = CombinedActivity()
        combinedActivity.activityData = self.activityData
        combinedActivity.distance = self.totalDistance//self.distance
        combinedActivity.steps = self.totalSteps
        combinedActivity.calories = self.calculateCalories(calories: totalCalories, duration: totalTime, metValue: self.activityData.activity?.metValue)//self.totalCalories
        combinedActivity.duration = self.totalTime
        return combinedActivity
    }
    
    //calculate calories in watch app
    private func calculateCalories(calories: Double?, duration: Double?, metValue: Double?) -> Double? {
        let timeInSeconds = duration ?? 0
        let timeInHours: Double = timeInSeconds/3600
        return Utility.calculatedCaloriesFrom(metValue: metValue ?? 0, duration: timeInHours)
    }
    
    private func startLoader() {
        
    }
    
    private func hideLoader() {
        
    }
    
    private func completeActivityApiRequest(_ requestDict : [String : Any]) {
        self.startLoader()
        let currentDate = Date()
        ActivityNetworkLayer().completeActivity(parameters: requestDict, success: { (message) in
            self.hideLoader()
            NotificationCenter.default.post(name: Notification.Name.watchCompleteActivityApiSucceeded, object: nil)
            var caloriesValue = self.calculateCalories(calories: self.totalCalories, duration: self.totalTime, metValue: self.activityData.activity?.metValue)
            
            //last parameter would contain the current activity data
            if let params = requestDict["activities"] as? [Parameters],
               let firstActivity = params.last,
               let calories = firstActivity["calories"] as? Double {
                caloriesValue = calories
            }
            WorkoutTracking.instance.endWorkout(caloriesCalc: caloriesValue ?? 0, endDate: currentDate) { (success, error) in
            }
            self.updateToIphone(params: requestDict)
            if let reqDict = requestDict["activities"] as? [Parameters] {
                self.navigateToActivitySummaryViewController(completeActParams: reqDict)
            } else {
                self.navigateToActivitySummaryViewController()
            }
        }) { (error) in
            //- Handle error
            self.hideLoader()
            //self.showLoginAlert(error.message ?? "Something went wrong", isUserLoggedIn: true)
            //send notification to the interfcae controller at page 0
            NotificationCenter.default.post(name: Notification.Name.watchErrorInCompleteActivity, object: nil, userInfo: ["error": error.message ?? "Something went wrong"])
        }
    }
    
    /// update the activity complete status to iphone app
    private func updateToIphone(params: Parameters) {
        var data: [String: Any] = ["request": MessageKeys.activityStoppedOnWatch]
        
        guard let activities = params["activities"] as? [Parameters] else {return}
        
        ///last is giving the last and current in progress activity data, change it to manage multiple activities
        var finalActivitiesData = [CompletedActivityData]()
        
        for activityParams in activities {
            var activityMetrics = CompletedActivityData()
            
            if let distance = activityParams["distanceCovered"] as? Double {
                activityMetrics.distanceCovered = distance
            }
            if let calories = activityParams["calories"] as? Double {
                activityMetrics.calories = calories
            }
            if let time = activityParams["timeSpent"] as? Double {
                activityMetrics.timeSpent = time
            }
            finalActivitiesData.append(activityMetrics)
        }
        do {
            let encodedData = try JSONEncoder().encode(finalActivitiesData)
            data[MessageKeys.completedActivityDataFromOtherDevice] = encodedData
        } catch {
            //
        }
        WatchKitConnection.shared.updateApplicationContext(context: data)
    }
    
    func resetData() {
        self.totalDistance = 0
        self.totalSteps = 0
        self.totalCalories = 0
    }
    
    func paramsFor(activity: CombinedActivity) -> [String: Any] {
        var params = [String: Any]()
        params["activityId"] = activity.activityData?.activity?.activityProgressId
        params["steps"] = activity.steps
        params["status"] = 2//completed(ActivityStateStatus)
        params["distanceCovered"] = calculateDistance(activity: activity.activityData?.activity, distance: activity.distance)//activity.distance
        params["timeSpent"] = activity.duration
        params["calories"] = self.calculateCalories(calories: activity.calories, duration: activity.duration, metValue: activity.activityData?.activity?.metValue)//activity.calories
        params["isScheduled"] = activity.activityData?.isScheduled
        return params
    }
    
    private func getActivityProgressObject() -> ActivityProgressData {
        let activityProgressData: ActivityProgressData = ActivityProgressData()
        activityProgressData.activity = self.additionalActivity
        activityProgressData.createdAt = Date()
        activityProgressData.elapsed = 0
        activityProgressData.startTime = 0
        activityProgressData.saveEncodedInformation()
        self.saveDataToDefaults()
        return activityProgressData
    }
    
    
    private func saveAdditionalActivityData() {
        //saving to defaults
        let combinedActivity = CombinedActivity()
        combinedActivity.activityData = self.activityData
        combinedActivity.distance = self.distance
        combinedActivity.steps = self.totalSteps
        combinedActivity.calories = self.totalCalories
        combinedActivity.duration = self.totalTime
        
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
                Defaults.shared.set(value: encodedData, forKey: .combinedActivities)
            }
        }
    }
    
    func navigateToActivitySummaryViewController(completeActivityData: [CompletedActivityData]? = nil, completeActParams: [Parameters]? = nil) {
        self.invalidateTimer()
        self.watchSessionStateTimer?.invalidate()
        self.watchSessionStateTimer = nil
        Defaults.shared.remove(.isActivityWatchApp)
        Defaults.shared.remove(.sharedActivityInProgress)
        Defaults.shared.remove(.userActivityData)
        Defaults.shared.removeActivityPaceValues()
        Defaults.shared.remove(.sharedUserActivityDates)
        var activitySummaryData: [UserActivity] = [UserActivity]()
        let obj = self.createActivitySummaryObject(steps: self.totalSteps, calories: self.totalCalories)
        if completeActivityData != nil {
            obj.calories = completeActivityData?.last?.calories //last is the current activity
        }
        if let activityParams = completeActParams?.last {
            //last is the current activity
            obj.calories = activityParams["calories"] as? Double
        }
        if let activitiesData = CombinedActivity.currentActivityInfo(),
           !activitiesData.isEmpty {
            var summaryData = [UserActivity]()
            for (i, activityData) in activitiesData.enumerated() {
                let data = self.activitySummaryFor(activity: activityData)
                if let completeActData = completeActivityData ,
                   i < completeActData.count {
                    data.calories = completeActData[i].calories
                } else if let activityParams = completeActParams,
                          i < activityParams.count {
                    let value = activityParams[i]
                    data.calories = value["calories"] as? Double
                }
                summaryData.append(data)
            }
            summaryData.append(obj)
            activitySummaryData = summaryData
            //also remove the combined activities data
            Defaults.shared.remove(.combinedActivities)
        } else {
            activitySummaryData = [obj]
        }
        contextDict["ActivitySummaryData"] = activitySummaryData
        DispatchQueue.main.async {
            WKInterfaceController.reloadRootPageControllers(withNames: ["WCompleteActivityVC"], contexts: [self.contextDict], orientation: .horizontal, pageIndex: 0)
        }
    }
    
    //returns the activity object for Summary
    func activitySummaryFor(activity: CombinedActivity) -> UserActivity {
        let summary = UserActivity()
        if let activityInfo = activity.activityData?.activity {
            summary.name = activityInfo.name
            summary.type = activityInfo.activityType
            summary.image = activityInfo.image
            summary.selectedActivityType = activityInfo.selectedActivityType
        }
        summary.steps = activity.steps
        summary.calories = self.calculateCalories(calories: activity.calories, duration: activity.duration, metValue: activity.activityData?.activity?.metValue)//activity.calories
        summary.distance = activity.distance
        summary.timeSpent = activity.duration
        summary.heartRate = activity.heartRate
        return summary
    }
    
    /// calculate dsitance for distance activities only
    /// - Parameter activity: activity info
    /// - Parameter distance: parameters
    func calculateDistance(activity: ActivityData?, distance: Double?) -> Double? {
        //send distance only for distance activities
        if let selectedActivity = activity?.selectedActivityType,
           let activityType = activity?.activityType {
            if selectedActivity == ActivityMetric.distance.rawValue {
                if activityType == ActivityMetric.distance.rawValue || activityType == ActivityMetric.none.rawValue {
                    return distance
                }
            }
            return 0
        }
        return distance
    }
    
    func createActivitySummaryObject(steps:Double,calories:Double) -> UserActivity {
        let objUserActivity = UserActivity()
        objUserActivity.image = self.activityData.activity?.image ?? ""
        objUserActivity.name = self.activityData.activity?.name ?? ""
        objUserActivity.steps = steps
        objUserActivity.calories = self.calculateCalories(calories: calories, duration: self.totalTime, metValue: self.activityData.activity?.metValue)//calories
        objUserActivity.distance = self.totalDistance
        objUserActivity.duration = self.durationLabelText.trim
        objUserActivity.timeSpent = self.totalTime
        if let avgHeartRate = self.averageHeartRate,
           avgHeartRate != 0 {
            objUserActivity.heartRate = self.averageHeartRate
        } else {
            objUserActivity.heartRate = self.heartRate
        }
        objUserActivity.type = self.activityData.activity?.activityType
        objUserActivity.selectedActivityType = self.activityData.activity?.selectedActivityType
        return objUserActivity
    }
    
    func setData() {
        if let dates = self.contextDict["activityDates"] as? [AccessDictionary] {
            self.activityDates = self.deserializeDictionary(dictionary: dates)
        }
        self.startDate = self.activityData.createdAt
        self.elapsed = self.activityData.elapsed ?? 0
        self.startTime = self.activityData.startTime ?? 0
        self.time = self.activityData.time ?? 0
        self.totalTime = self.activityData.totalTime ?? 0
        if self.activityData.duration != nil {
            self.durationLabel.setText(self.activityData.duration)
            self.durationLabelText = self.activityData.duration ?? ""
        }
        self.updateCaloriesCount()
        self.setUpDistanceView()
    }
    
    /// set the updated calories count
    @objc func updateCaloriesCount() {
        //calculate calories
        self.totalCalories = calculateCalories(calories: nil, duration: self.totalTime, metValue: self.activityData.activity?.metValue) ?? 0
        self.caloriesLabel.setText("\(totalCalories.rounded(toPlaces: 2))")
    }
    
    @objc func watchTimerState() {
        //if the heart rate is nil after the interval, then restart the session
        if self.heartRate == nil, let kitActivityType = self.kitActivityType {
            //restart the activity
            WorkoutTracking.instance.discardWorkout { (success) in
                WorkoutTracking.instance.resetSessionVariables()
                WorkoutTracking.instance.startWorkout(activityId: self.activityId ?? 1, startTime: self.createdDateTime, kitActivityType: kitActivityType) { (success, error) in
                    if !success {
                        if error != nil {
                            //if there was some error in creating the session, return
                            self.errorInSession(error: "There was some error in creating workout. Please try again")
                            return
                        }
                    }
                }
            }
        }
    }
    
    @objc func calculateInProgressMile() {
        self.setInProgressMile(distance: self.totalDistance, totalTime: self.totalTime ?? 0)
    }
    
    /// setup the distance view: for duration activities, this will be nil
    private func setUpDistanceView() {
        if let selectedActivityType = self.activityData.activity?.selectedActivityType {
            if (selectedActivityType == ActivityMetric.distance.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == ActivityMetric.none) {
                self.isDistanceTypeActivity = false
                distanceGroup.setHidden(true)
                inProgressMileGroup.setHidden(true)
                averageMileGroup.setHidden(true)
            }
        }
    }
    
    func handleActivityState() {
        if let isPlayingState =  self.activityData.isPlaying {
            if isPlayingState {
                self.timeIntervel.startDate = self.activityData.currentPeriodStartingDate ?? Date()
                self.start(changeStartTime: false)
            }else{
                //                self.honeyCombView.isPlaying = false
                //                self.honeyCombView.stopViewRotation()
            }
        }else{
            self.activityData.isPlaying = true
            self.startDate = Date()
            self.activityData.saveEncodedInformation()
            self.saveDataToDefaults()
            self.runTimer()
        }
        self.changeStateOnActionsScreen()
    }
    
    // MARK: This method call initializes the timer. It specifies the timeInterval (how often the a method will be called) and the selector (the method being called).
    func runTimer(){
        if isPlaying {
            stop()
            //            self.changeActivityStateOnIPhoneApp()
        }else{
            start()
            //            self.changeActivityStateOnIPhoneApp()
        }
    }
    
    // MARK: Function to stop timer.
    func stop() {
        self.distance += self.tempDistance
        self.saveDatesData()
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        self.activityData.elapsed = elapsed
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        self.timer?.invalidate()
        self.distanceTimer?.invalidate()
        self.caloriesTimer?.invalidate()
        self.inProgressMileTimer?.invalidate()
        // Set Start/Stop button to false
        isPlaying = false
    }
    
    func saveDatesData(){
        self.timeIntervel.endDate = Date()
        self.activityDates.append(self.timeIntervel)
        //OLD
        //        saveDatesToUserManagerWithSession()
        
        //New
        let dataToSave = self.serializeTuple(tuples:  self.activityDates)
        do {
            //Serialize Custom Object
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: dataToSave, requiringSecureCoding: false)
            Defaults.shared.set(value: encodedData, forKey: .sharedUserActivityDates)
            let dict: [String: Any] = ["request": MessageKeys.updateNewDates,
                                       MessageKeys.userActivityDates: encodedData]
            //           FIXME: WatchKitConnection.shared.updateApplicationContext(context: dict)
        }
        catch {
        }
    }
    
    func serializeTuple(tuples: [AccessTuple]) -> [AccessDictionary] {
        var array : [AccessDictionary] = [AccessDictionary]()
        for (_,data) in tuples.enumerated() {
            array.append([
                startDateKey : data.startDate,
                endDateKey : data.endDate
            ])
        }
        return array
    }
    
    func deserializeDictionary(dictionary: [AccessDictionary]) -> [AccessTuple] {
        var array : [AccessTuple] = [AccessTuple]()
        for (_,data) in dictionary.enumerated() {
            array.append(AccessTuple(
                data[startDateKey] ?? Date(),
                data[endDateKey] ?? Date()
            ))
        }
        return array
    }
    
    
    // MARK: Function to start timer.
    func start(changeStartTime:Bool = true) {
        if changeStartTime {
            self.timeIntervel.startDate = Date()
            self.activityData.currentPeriodStartingDate = self.timeIntervel.startDate
            self.activityData.saveEncodedInformation()
            self.saveDataToDefaults()
            startTime = Date().timeIntervalSinceReferenceDate - elapsed
        }
        self.setTimer()
        self.activityData.startTime = startTime
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        isPlaying = true
    }
    
    func setTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.caloriesTimer = nil
        self.inProgressMileTimer = nil
        Timer.cancelPreviousPerformRequests(withTarget: self)
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        timer?.tolerance = 0.1
        self.caloriesTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateCaloriesCount), userInfo: nil, repeats: true)
        self.inProgressMileTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.calculateInProgressMile), userInfo: nil, repeats: true)
        
        //COMMENTED
        /*if self.checkPermissionForDistance() {
         if self.distanceTimer == nil {
         self.distanceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getDistance), userInfo: nil, repeats: true)
         }
         } */
        print("Timer1-\(String(describing: timer))")
    }
    
    /// This Function will be called after 2 seconds to collect distance covered by user.
    @objc func getDistance() {
        HealthKit.instance?.getWalkingDistanceForTimePeriod(startDate: self.activityData.currentPeriodStartingDate ?? Date(), endDate: Date(), completion: { (double, error) in
            if error == nil {
                self.tempDistance = double//Double(double).rounded(toPlaces: 2)
                let totalDistanceToDisplay = (self.distance + double).rounded(toPlaces: 2)
                DispatchQueue.main.async {
                    //- set new
                    //                    self.distanceLabel.setText("\(totalDistanceToDisplay) miles")
                    self.distanceLabel.setText("\(totalDistanceToDisplay)")
                }
            }else{
                DispatchQueue.main.async {
                    //- set new
                    //                    self.distanceLabel.setText("\(self.distance.rounded(toPlaces: 2)) miles")
                    self.distanceLabel.setText("\(self.distance.rounded(toPlaces: 2))")
                }
            }
        })
    }
    
    
    func checkPermissionForDistance() -> Bool {
        return true
    }
    
    // MARK: Function to get
    @objc func updateCounter() {
        //        print("update counter implementation ******************")
        //        print("timer working")
        // Calculate total time since timer started in seconds
        //        print("startTime in timer is ---------------- \(startTime)")
        //        print("current time is ------------- \(Date().timeIntervalSinceReferenceDate)")
        time = Date().timeIntervalSinceReferenceDate - startTime
        //        print("time calcualted: ============ \(time)")
        self.totalTime = time
        // Calculate minutes
        let hours = Int(time / 3600)
        time -= (TimeInterval(hours) * 3600)
        
        let minutes = Int(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        
        // Calculate seconds
        let seconds = Int(time)
        time -= TimeInterval(seconds)
        
        // Format time vars with leading zero
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        // Add time vars to relevant labels
        self.durationLabel.setText("\(strHours):\(strMinutes):\(strSeconds)")
        self.durationLabelText = "\(strHours):\(strMinutes):\(strSeconds)"
        //print("Duration -updateCounter- \(self.durationLabelText)")
        self.activityData.duration = "\(strHours):\(strMinutes):\(strSeconds)"
        self.activityData.time = time
        self.activityData.totalTime = self.totalTime
        self.activityData.saveEncodedInformation()
        //        self.saveDataToDefaults()
    }
    
    // MARK: Method wil be use to invalidate the timer.
    fileprivate func invalidateTimer() {
        if self.distanceTimer != nil {
            self.distanceTimer?.invalidate()
            self.distanceTimer = nil
        }
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        if self.caloriesTimer != nil {
            self.caloriesTimer?.invalidate()
            self.caloriesTimer = nil
        }
        if self.inProgressMileTimer != nil {
            self.inProgressMileTimer?.invalidate()
            self.inProgressMileTimer = nil
        }
    }
    
    ///pause the activity before presenting the alert on screen
    private func pauseActivityBeforeShowingAlert() {
        if let isPlaying = self.activityData.isPlaying {
            if isPlaying {
                self.activityPausedDueToAlert = true
                /* self.stopSimpleTimerOnly()
                 self.honeyCombView.stopViewRotation() */
                self.stopAndStartActivity()
            } else {
                self.activityPausedDueToAlert = false
            }
        }
    }
    
    func stopAndStartActivity() {
        if let state = self.activityData.isPlaying {
            self.activityData.isPlaying = !state
            if state == true {
                WorkoutTracking.instance.pauseWorkout()
            } else {
                WorkoutTracking.instance.resumeWorkout()
            }
        }else{
            self.activityData.isPlaying = false
        }
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        self.runTimer()
        self.changeActivityStateOnIPhoneApp()
    }
    
    ///resume the activity after the alert is dismissed on its negative action
    private func resumeActivityOnAlertDismiss() {
        if self.activityPausedDueToAlert == true {
            //if this was paused due to the alert presented on screen, resume this activity again
            self.activityData.isPlaying = true
            self.activityData.saveEncodedInformation()
            self.saveDataToDefaults()
            self.runTimer()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setWatchStateTimer()
    }
    
    deinit {
        print("DEINIT OF PROGRESS WATCH")
        self.watchSessionStateTimer?.invalidate()
        self.watchSessionStateTimer = nil
        self.removeConnectivityObserver()
    }
    
    // MARK: Connectivity/notification observers
    private func addConnectivityObserver() {
        self.removeConnectivityObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(workoutFailed(notification:)), name: Notification.Name.workoutFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopActivityNotificationCalled), name: Notification.Name.watchStopActivity, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dontStopActivityNotificationCalled), name: Notification.Name.watchDontStopActivity, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopButtonTappedOnFirstPageController), name: Notification.Name.watchActivityStopButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeActivityStateToPlayPlause), name: Notification.Name.watchActivityPausedTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityInfoUpdated(notification:)), name: Notification.Name.activityInfoUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityStoppedOnWatchApp(notification:)), name: Notification.Name.activityHasBeenStoppedOnDevice, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addNewActivity), name: Notification.Name.watchActivityAddNewButtonTapped, object: nil)
    }
    
    private func removeConnectivityObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.watchActivityAddNewButtonTapped, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.watchDontStopActivity, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.watchStopActivity, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.watchActivityStopButtonTapped, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.watchActivityPausedTapped, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.activityInfoUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.activityHasBeenStoppedOnDevice, object: nil)
    }
    
    /// play activity if paused and pause if it is playing
    @objc func changeActivityStateToPlayPlause() {
        //make this screen as the visible page
        self.becomeCurrentPage()
        self.stopAndStartActivity()
        self.changeStateOnActionsScreen()
    }
    
    @objc func stopActivityNotificationCalled() {
        Defaults.shared.set(value: false, forKey: .isActivity)
        self.activityPausedState = .activityTerminated
        self.fetchCurrentActivityFinalData()
    }
    
    @objc func dontStopActivityNotificationCalled() {
        self.resumeActivityOnAlertDismiss()
    }
    
    @objc func stopButtonTappedOnFirstPageController() {
        self.pauseActivityBeforeShowingAlert()
    }
    
    /// call this method to update icon on the actions screen on the basis of activity playing state
    private func changeStateOnActionsScreen() {
        var playingState = false
        if let state = self.activityData.isPlaying {
            playingState = state
            NotificationCenter.default.post(name: Notification.Name.watchActivityStateChanged, object: nil, userInfo: ["isPlaying": playingState])
        }
    }
    
    @objc func activityInfoUpdated(notification: Notification) {
        //handling for either the activity is paused or resumed
        if let userInfo = notification.userInfo,
           let data = userInfo["data"] as? InProgressActivityState {
            
            if let playingState = data.isPlaying {
                if playingState == false {
                    DispatchQueue.main.async {
                        self.invalidateTimer()
                    }
                }
            }
            
            self.totalTime = data.totalTime
            self.activityData.totalTime = data.totalTime
            self.activityData.duration = data.duration
            if let elapedTime = data.elapsed,
               elapedTime != 0 {
                let stateChangeTime = data.stateChangeTime ?? Date().timeIntervalSinceReferenceDate
                let difference = Date().timeIntervalSinceReferenceDate - stateChangeTime
                let cal = elapedTime + difference
                self.elapsed = cal//elapedTime
                self.activityData.elapsed = self.elapsed
            }
            
            DispatchQueue.main.async {
                self.durationLabel.setText(data.duration)
                if let duration = data.duration,
                   duration != "" {
                    self.durationLabelText = duration
                }
            }
            self.activityData.isPlaying = data.isPlaying
            self.isPlaying = data.isPlaying ?? true
            self.activityData.saveEncodedInformation()
            if let playingState = data.isPlaying {
                if playingState == true {
                    //activity is playing on other device
                    DispatchQueue.main.async {
                        self.start()
                    }
                } else {
                    //activity is paused on other device
                    self.stop()
                    if let elapedTime = data.elapsed,
                       elapedTime != 0 {
                        let stateChangeTime = data.stateChangeTime ?? Date().timeIntervalSinceReferenceDate
                        let difference = Date().timeIntervalSinceReferenceDate - stateChangeTime
                        let cal = elapedTime + difference
                        self.elapsed = cal//elapedTime
                        self.activityData.elapsed = elapsed
                        self.activityData.saveEncodedInformation()
                    }
                }
            }
            self.changeStateOnActionsScreen()
        }
    }
    
    /// navigate to activity summary screen if the respective activity is stopped on phone
    /// - Parameter notification: notifcation info
    @objc func activityStoppedOnWatchApp(notification: Notification) {
        //navigate to activity summary screen
        if let userInfo = notification.userInfo,
           let data = userInfo["data"] as? [CompletedActivityData] {
            //first two elements are the additional activities and the last is the current activity on self
            self.pauseActivityBeforeShowingAlert()
            if let currentData = data.last {
                //last element and this would be the current activity information
                self.totalTime = currentData.timeSpent
                self.totalCalories = currentData.calories ?? 0
                self.totalDistance = currentData.distanceCovered ?? 0
                self.totalSteps = currentData.steps ?? 0
            }
            WorkoutTracking.instance.endWorkout(caloriesCalc: data.last?.calories ?? 0, saveToHealthKit: false) { (success, error) in
            }
            self.navigateToActivitySummaryViewController(completeActivityData: data)
        }
    }
    
    @objc func addNewActivity() {
        //save the current activity in defaults and then create the new activity
        self.pauseActivityBeforeShowingAlert()
        self.activityPausedState = .newActivityAdded
        self.fetchCurrentActivityFinalData()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        //     print("Timer Invalidated From didDeactivate")
        //   self.invalidateTimer()
        
        //        hexGroup.stopAnimating()
        
    }
    
    @IBAction func pauseActitvityTapGestureAction(_ sender: Any) {
        //self.pauseActivityBeforeShowingAlert()
        self.stopAndStartActivity()
    }
    
    private func changeActivityStateOnIPhoneApp() {
        var inprogressState = InProgressActivityState()
        inprogressState.totalTime = self.totalTime
        inprogressState.duration = self.durationLabelText
        inprogressState.elapsed = self.activityData.elapsed
        inprogressState.isPlaying = self.activityData.isPlaying
        inprogressState.stateChangeTime = Date().timeIntervalSinceReferenceDate
        
        do {
            let encodedData = try JSONEncoder().encode(inprogressState)
            let data: [String: Any] = ["request": MessageKeys.activityStateChangedOnWatch,
                                       "data": encodedData]
            WatchKitConnection.shared.updateApplicationContext(context: data)
        } catch { }
    }
    
    /// workout was failed for some reason, redirect to home screen
    /// - Parameter notification: Notification object
    @objc func workoutFailed(notification: Notification) {
        if let userInfo = notification.userInfo,
           let error = userInfo["error"] as? String {
            self.errorInSession(error: error)
        }
    }
    
    // MARK: Stop activity action
    @IBAction func startButtonAction() {
        
        self.pauseActivityBeforeShowingAlert()
        let startAction = WKAlertAction(title: "YES", style: WKAlertActionStyle.default) {
            self.activityPausedState = .activityTerminated
            self.fetchCurrentActivityFinalData()
        }
        
        let noAction = WKAlertAction(title: "NO", style: WKAlertActionStyle.destructive) {
            self.resumeActivityOnAlertDismiss()
        }
        presentAlert(withTitle: "Stop Activity", message: "Are you sure you want to stop the current activity?", preferredStyle: WKAlertControllerStyle.alert, actions:[startAction,noAction])
    }
    
    @IBAction func newActivityButtonAction() {
        self.pauseActivityBeforeShowingAlert()
        let addAction = WKAlertAction(title: "YES", style: WKAlertActionStyle.default) {
            
            if self.activityArray.count > 0 {
                //1. Show Activity List
                // self.loadTableData()
            }
            else {
            }
            
            /*
             1. Show Activity List
             2, After select activity do this
             self.additionalActivity = array[index]
             self.additionalActivity?.selectedActivityType = array[index].activityType
             //for any additional type, setting the activity type to "None"
             self.additionalActivity?.activityType = ActivityType.none.rawValue
             self.activityPausedState = .newActivityAdded
             
             self.showLoader()
             self.createNewUserActivityOnServer()
             3. After creating New User Activity ->
             self.newProgressIdFromServer = data["_id"] as? String ?? ""
             self.fetchCurrentActivityFinalData()
             4. UpdateServerToStop
             5. newUserActivityCreatedSuccessfully
             */
        }
        
        let noAction = WKAlertAction(title: "NO", style: WKAlertActionStyle.destructive) {
            self.resumeActivityOnAlertDismiss()
        }
        presentAlert(withTitle: "", message: "Add Activity?", preferredStyle: WKAlertControllerStyle.alert, actions:[addAction,noAction])
    }
    
    //    private func loadTableData() {
    //
    //        topOuterGroup.setHidden(true)
    //        addActivityGroup.setHidden(true)
    //        durDistanceGroup.setHidden(true)
    //        tblView.setHidden(false)
    //        self.activityIndicatorImageView.stopAnimating()
    //        activityIndicatorGroup.setHidden(true)
    //
    //        tblView.setNumberOfRows(self.activityArray.count, withRowType: "WChooseActivityRow")
    //
    //        for(index,data) in self.activityArray.enumerated() {
    //            if let rowController = tblView.rowController(at: index) as? WChooseActivityRow {
    //                rowController.cellLabel.setText("\(String(describing: data.name ?? ""))")
    //                rowController.cellImageView.loadImage(url: data.image ?? "", forImageView: rowController.cellImageView)
    //            }
    //        }
    //    }
    
    //- set new
    /*override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
     
     topOuterGroup.setHidden(true)
     addActivityGroup.setHidden(true)
     durDistanceGroup.setHidden(true)
     tblView.setHidden(true)
     activityIndicatorGroup.setHidden(false)
     
     self.additionalActivity = self.activityArray[rowIndex]
     //for any additional type, setting the activity type to "None"
     self.additionalActivity?.activityType = ActivityType.none.rawValue
     self.activityPausedState = .newActivityAdded
     
     self.createNewUserActivityOnServer(rowIndex)
     } */
    
    fileprivate func showLoader() {
        DispatchQueue.main.async {
        }
    }
    
    private func saveDataToDefaults() {
        do {
            let data =  try JSONEncoder().encode(self.activityData)
            Defaults.shared.set(value: data, forKey: .sharedActivityInProgress)
        } catch (_) {
        }
    }
}

// MARK: Average and in-progress mile calculation
extension WInProgressActivityVC {
    /// set the average mile distance
    /// - Parameter distance: total distance
    /// - Parameter totalTime: total time in seconds
    func setAverageMile(distance: Double, totalTime: Double) {
        guard self.isDistanceTypeActivity else {
            return
        }
        //average mile calculation
        if totalTime != 0 && distance != 0 {
            let timeInSeconds = totalTime/distance //in seconds
            avgMile = timeInSeconds
            Defaults.shared.set(value: avgMile, forKey: .avgMile)
            //set average mile in label
            if timeInSeconds > 0 {
                let avgMileTime = Utility.formatToMinutesAndSecondsOfMiles(totalSeconds: timeInSeconds.toInt() ?? 0)
                DispatchQueue.main.async {
                    self.averageMileGroup.setHidden(false)
                    self.averageMileValueLabel.setText(avgMileTime)
                }
            }
        }
        if self.inProgressMileTimer == nil {
            //timer is paused
            self.setInProgressMile(distance: distance, totalTime: self.totalTime ?? 0)
        }
    }
    
    /// set in progress mile
    /// - Parameter distance: total distance till now
    /// - Parameter totalTime: total time elapsed
    func setInProgressMile(distance: Double, totalTime: Double) {
        guard self.isDistanceTypeActivity else {
            return
        }
        //average mile calculation
        if totalTime != 0 && distance != 0 {
            let timeInSeconds = totalTime/distance //in seconds
            avgMile = timeInSeconds
            Defaults.shared.set(value: avgMile, forKey: .avgMile)
        }
        //Inprogress mile calculation
        var currentMileDistance: Double = 0
        if distance > (Double(singleMileCount) + 1) {
            singleMileCount = Int(distance)
            lastMileCount = 0
        }
        //calculate last mile completion time
        //in case data for last mile is available use that otherwise calculate on the basis of average time
        
        if distance > 1 && ((distance - Double(lastMileCount)) > 2 || lastMileCount == 0) {
            lastMileCompletedTime = avgMile * Double(singleMileCount)
            lastMileCount = Int(distance)
            singleMileCount = Int(distance)
            singleMileCount += 1
        }
        
        if distance >= Double(singleMileCount) {
            lastMileCompletedTime = avgMile * Double(singleMileCount)
            currentMileDistance = distance - Double(singleMileCount)
            singleMileCount += 1
            lastMileCount = Int(distance)
            if currentMileDistance > 0 {
                let duration: Double = currentMileDistance*avgMile
                lastMileCompletedTime = lastMileCompletedTime - duration
            } else {
                lastMileCompletedTime = totalTime
            }
        }
        Defaults.shared.set(value: lastMileCompletedTime, forKey: .lastMileCompletedTime)
        Defaults.shared.set(value: singleMileCount, forKey: .singleMileCount)
        Defaults.shared.set(value: lastMileCount, forKey: .lastMileCount)
        let value = totalTime - lastMileCompletedTime
        if value > 0 {
            let formattedTime = Utility.formatToMinutesAndSecondsOfMiles(totalSeconds: value.toInt() ?? 0)
            DispatchQueue.main.async {
                self.inProgressMileGroup.setHidden(false)
                self.inProgressValueLabel.setText(formattedTime)
            }
        }
    }
    
    private func setDistanceOnView(distance: Double) {
        if self.totalDistance <= distance {
            self.totalDistance = distance
        }
        self.setAverageMile(distance: self.totalDistance.rounded(toPlaces: 2), totalTime: self.totalTime ?? 0)
        DispatchQueue.main.async {
            self.distanceLabel.setText("\(self.totalDistance.rounded(toPlaces: 2))")
        }
        let message: [String: Any] = [
            "request": MessageKeys.distanceFromCounterpart,
            "totalDistance": self.totalDistance,
            "activityProgressId": self.activityData.activity?.activityProgressId as Any
        ]
        WatchKitConnection.shared.sendMessage(message: message)
    }
}
//send message to iPhone

extension WInProgressActivityVC: WatchKitConnectionDelegate {
    func userLoggedInIphoneApp() {}
    
    func didReceiveDistanceFromCounterpartApp(distance: Double) {
        if distance > self.totalDistance {
            //show the iPhone distance
            self.totalDistance = distance
        }
    }
}

// MARK: WorkoutTrackingDelegate
extension WInProgressActivityVC: WorkoutTrackingDelegate {
    func didReceiveSwimmingDistance(distance: Double) {
        self.setDistanceOnView(distance: distance)
    }
    
    func didReceiveCyclingDistance(distance: Double) {
        self.setDistanceOnView(distance: distance)
    }
    
    func paused(string: String) {
        DispatchQueue.main.async {
            self.heartRateGroup.setHidden(false)
            self.heartRateLabel.setText(string)
        }
    }
    
    func didReceiveHeartRate(heartRate: Double, avgValue: Double) {
        if heartRate != 0 {
            self.heartRate = heartRate
        }
        if avgValue != 0 {
            self.averageHeartRate = avgValue
        }
        DispatchQueue.main.async {
            self.heartRateGroup.setHidden(false)
            let intCasted = self.heartRate?.toInt() ?? 0
            self.heartRateLabel.setText("\(intCasted)")
        }
    }
    
    func didReceiveActiveEnergy(calories: Double) {
        /*DispatchQueue.main.async {
         self.caloriesLabel.setText("\(calories)")
         } */
    }
    
    func didReceiveDistanceWalkingRunning(distance: Double) {
        self.setDistanceOnView(distance: distance)
    }
    
    func didReceiveSteps(steps: Double) {
        self.totalSteps = steps
    }
}
