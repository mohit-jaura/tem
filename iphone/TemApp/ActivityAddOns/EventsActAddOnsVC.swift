//
//  EventsActAddOnsVC.swift
//  TemApp
//
//  Created by PrabSharan on 08/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity
import AFNetworking
class EventsActAddOnsVC: DIBaseController {
    var eventID:String?
    var count:Int = 0
    @IBOutlet weak var nameTrailingConst: NSLayoutConstraint!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var pauseStopButOut: UIButton!
    @IBOutlet weak var exitButOut: UIButton!
    @IBOutlet weak var skipButOut: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var programId = ""
    var programEventId = ""
    var selectedActivityIndex:Int?
    var allActivities : [ActivityData]?
    var breakTime:Int = 60
    var selectedActivity:ActivityData? {
        didSet {
            skipButOut.isHidden = selectedActivity?.isMandatory ?? 0 == 1
        }
    }
    var selectedActivityProgress = ActivityProgressData()
    var activityCategoryDataType = ActivityCategoryType.physicalFitness.rawValue
    var isOnlyTimeBoundActivity: Bool {
        return (self.selectedActivity?.name == "Focus Time" ||  self.selectedActivity?.name == "Meditation")
    }
    private var startTime: Double = 0
    private var time: Double = 0
    private var elapsed: Double = 0
    private var oldElapsedTime: Double = 0
    private var totalTime:Double?
    private var totalCalories:Double = 0.0
    private var timeIntervel:AccessTuple = (Date(),Date(),0)
    private var activityDates:[AccessTuple] = [AccessTuple]()
    private var totalDistance:Double = 0.0
    private var tempDistance:Double = 0.0
    private var totalSteps:Int = 0
    private var distance:Double = 0.0

    //Distance manage params
    // this is being used in the in-progress mile calculation
    private var singleMileCount: Int = 1
    private var lastMileCount: Int = 0
    private var lastMileCompletedTime: Double = 0
    private var avgMile: Double = 0
    private var isDistanceTypeActivity: Bool {
        return distanceActivityCheck()
    }
    private var totalDisplayedDistance: Double = 0
   

    weak var timer: Timer?
    weak var distanceTimer : Timer?
    weak var caloriesTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        initilaise()
    }
    func initilaise() {
         breakTime = 0
         nameLabelRotate()
        selectNewActivity()
        addConnectivityObserver()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.invalidateTimer()

    }
    
    // MARK: Distance & Watch related Code
    //add connectivity observersse
    private func addConnectivityObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(workoutFailedOnWatchApp(notification:)), name: Notification.Name.workoutFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityInfoUpdated(notification:)), name: Notification.Name.activityInfoUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityStoppedOnWatchApp(notification:)), name: Notification.Name.activityHasBeenStoppedOnDevice, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(saveDatesDataWhenAppKill), name: UIApplication.willTerminateNotification, object: nil)
        
        
    }
    func watchInitialise() {
        if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String , deviceType == HealthAppType.fitbit.title {
            if FitbitAuthHandler.getToken() == nil {
                FitbitAuthHandler.shareManager()?.loadVars()
                FitbitAuthHandler.shareManager()?.login(self)
                NotificationCenter.default.addObserver(self,selector: #selector(self.handleFitbitDataNotification),name: NSNotification.Name(rawValue:FitbitNotification),object: nil)
            } else {
                self.handleFitBitData()
            }
        } else {
            NotificationCenter.default.addObserver(self,selector: #selector(self.handleHealthKitData),name: NSNotification.Name(rawValue:healthKitAutorized),object: nil)
        }
    }
    @objc func handleHealthKitData(notification: NSNotification) {
        self.setTimer()
        if isDistanceTypeActivity {
                    self.getInitialDistance()
                    self.getDistance()
                }else{
                    self.distanceLabel.text = "0.0"
                }
            }
    
    @objc func saveDatesDataWhenAppKill(){
        stopCurrentActivity()
    }
    
    @objc func saveDatesData(){
        self.timeIntervel.endDate = Date()
        self.timeIntervel.distance = self.tempDistance
        self.activityDates.append(self.timeIntervel)
        self.saveDatesToDic(  self.activityDates)
        self.saveDicDistance( self.activityDates)
    }
    
  
    func distanceActivityCheck() -> Bool {
        
        if let selectActId = self.selectedActivityProgress.activity?.selectedActivityType,let activity = ActivityMetric(rawValue: selectActId) {
            
            return (activity == .distance)
            
    }
        return false
    }
    func saveDatesToDic(_ tuples: [AccessTuple]) {
        var array : [AccessDictionary] = [AccessDictionary]()
        for (_,data) in tuples.enumerated() {
            array.append([
                startDateKey : data.startDate,
                endDateKey : data.endDate
            ])
        }
        UserManager.saveEventActivityOnDates(eventID,array)
    }
    
    func saveDicDistance(_ tuples: [AccessTuple]) {
        var array : [AccessDistance] = [AccessDistance]()
        for (_,data) in tuples.enumerated() {
            array.append([
                distanceKey : data.distance,
            ])
        }
        UserManager.saveEventActivityOnaDistance(eventID,array)

    }
    
    func deserializeDictionary(dictionary: [AccessDictionary],distanceDict: [AccessDistance]) -> [AccessTuple] {
        var array : [AccessTuple] = [AccessTuple]()
        for (_,data) in dictionary.enumerated() {
            array.append(AccessTuple(
                data[startDateKey] ?? Date(),
                data[endDateKey] ?? Date(),
                0
            ))
        }
        for (index,data) in distanceDict.enumerated() {
            array[index].distance = data[distanceKey] ?? 0
        }
        
        return array
    }
    
    @objc func workoutFailedOnWatchApp(notification: Notification) {
        if let userInfo = notification.userInfo,
           let activityId = userInfo["activityId"] as? String {
            debugPrint("Activity \(activityId) failed, need to restart")
        }
        }
    
    @objc func activityInfoUpdated(notification: Notification) {
        //handling for either the activity is paused or resumed
        if let userInfo = notification.userInfo,
           let data = userInfo["data"] as? InProgressActivityState {
            stopAndStartActivity()
        }
    }
    
    /// navigate to activity summary screen if the respective activity is stopped on watch
    /// - Parameter notification: notifcation info
    @objc func activityStoppedOnWatchApp(notification: Notification) {
        //navigate to activity summary screen
        if let userInfo = notification.userInfo,
           let data = userInfo["data"] as? [CompletedActivityData] {
            if let currentData = data.last {
                self.totalDistance = currentData.distanceCovered ?? 0
                self.totalSteps = Int(currentData.steps ?? 0)
                self.stopCurrentActivity()
            }
        }
    }
    
    // MARK: Method wil be use to invalidate the timer.
    private func invalidateTimer() {
        self.distanceTimer?.invalidate()
        self.timer?.invalidate()
        self.caloriesTimer?.invalidate()
        self.timer = nil
        self.caloriesTimer = nil
        self.distanceTimer = nil
        saveToLocal()
    }
    
    func nameLabelRotate() {
        nameTrailingConst.constant = 7 - activityNameLabel.frame.width/2 + activityNameLabel.frame.height/2
        activityNameLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)

    }
    func resetTimeAlert() {
        alertOpt("The Rest time is 2 mins.Do you want to proceed", okayTitle: "Yes", cancelTitle: "No, Don't want to proceed", okCall: {
            self.breakTime = 60
        }, cancelCall: {
            self.breakTime = 0
        }, parent: self)
    }
    
    func selectNewActivity() {
        if let firstSkippedActIndex = allActivities?.firstIndex(where: { ActivityStatus(rawValue:  $0.status ?? 0) == .Started}) {
            if let activity = initialiseFromLocal() {
                selectedActivity = activity
                self.showMainViewIfActivityIsNotBinary()
                selectedActivityProgress.activity = selectedActivity
                selectedActivityIndex = firstSkippedActIndex
                self.activityNameLabel.text =   self.selectedActivity?.name?.capitalized
                
                selectedActivityProgress.elapsed = activity.timeSpent
                
                selectedActivityProgress.startTime = Date().timeIntervalSinceReferenceDate
                
                startTime = Date().timeIntervalSinceReferenceDate
                selectedActivityProgress.isPlaying = false
                updateCounter()
                updateCaloriesCount()
                showSelectedActivity()
            }
            
            
        } else if let firstNotStartedActivityIndex =  allActivities?.firstIndex(where: { ActivityStatus(rawValue:  $0.status ?? 0) == .NotStart}) {
            
            selectedActivityIndex = firstNotStartedActivityIndex
            selectedActivity = allActivities?[firstNotStartedActivityIndex]
            self.showMainViewIfActivityIsNotBinary()
            selectedActivityProgress.startTime = Date().timeIntervalSinceReferenceDate

            selectedActivityProgress.isPlaying = false

            self.activityNameLabel.text =   self.selectedActivity?.name?.capitalized
            
            showSelectedActivity()
            
        } else {
            self.invalidateTimer()
            DIWebLayerActivityAPI().completeProgramEvent(parameter: ["programId": programId, "programEventId": programEventId ], success: { msg in
                print(msg)
                
            }, failure: { error in
                print(error?.message)
                
            })
            if self.checkIsAllActivittiesAreBinary() {
                alertOpt("All activities are done", okayTitle: "Go back", okCall: {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }, parent: self)
            } else {
                alertOpt("All activities are done", okayTitle: "Go to Summary", cancelTitle: "Go back", okCall: {
                    DispatchQueue.main.async {
                        ActivityData.removeEventActivity(eventID: self.eventID)
                        self.goToSummeryScreen()
                    }
                }, cancelCall: {
                    //
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }, parent: self)
            }
            
        }
    }
    func goToSummeryScreen() {
        
        
        let selectedVC:ActivitySummaryViewController = UIStoryboard(storyboard: .activitysummary).initVC()
        
        selectedVC.isComingFromActivityEvent = true
        selectedVC.activityEventId = eventID ?? ""
        selectedVC.allActivities = allActivities
      //  self.navigationController?.pushViewController(selectedVC, animated: true)
            if let activityController = self.navigationController?.viewControllers.first {
                DispatchQueue.main.async {
                    self.navigationController?.viewControllers = [activityController, selectedVC]
                }
            }
        }
    
    func showSelectedActivity() {
        let actType = self.selectedActivity?.activityType ?? 2
        self.selectedActivity?.selectedActivityType = actType
        // Show start activity popup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let popverVC: StartActivityViewController = UIStoryboard(storyboard: .activity).initVC()
            popverVC.startActivityDelegate = self
            
           // popverVC.activityCategoryDataType = self.activityCategoryDataType
            if let activity = self.selectedActivity{
                popverVC.selectedActivity = activity
            }
            
            popverVC.activityOptional = self.selectedActivity?.isMandatory ?? 1 == 1 ? .NotOptional : .Optional
            popverVC.activityName =  self.selectedActivity?.name ?? ""
            popverVC.totalBreakTime = self.breakTime
            popverVC.isBinary = self.selectedActivity?.isBinary ?? 0  == 1
            popverVC.skipTapped = {
                DispatchQueue.main.async {
                    self.skipEventActivityApi()
                }
            }
            popverVC.exitTapped = {
                DispatchQueue.main.async {
                    self.exitFromEvent()
                }
            }
            self.present(popverVC, animated: true, completion: nil)
        }
    }
    
    func initialiseAfterStart() {
        if let activityType = self.selectedActivity?.activityType,
           let type = ActivityMetric(rawValue: activityType),
           type == .distance{
            appDelegate.initalizeLocation()
        }
    }
    private func showMainViewIfActivityIsNotBinary() {
        if selectedActivity?.isBinary ?? 0 == 0 {
            DispatchQueue.main.async {
                self.mainView.isHidden = false
            }
        }
    }
    
    private func checkIsAllActivittiesAreBinary() -> Bool {
        let binaryActivities = allActivities?.filter({ activity in
            return activity.isBinary ?? 0 == 1
        })
        return binaryActivities?.count ?? 0 > 0 ? true : false
    }
    // MARK: Start Event Activity Api
    func startEventActivityApi() {
        
        let apiInfo =  EndPoint.StrEventAct(type: selectedActivity?.activityType, id: selectedActivity?.id, eventID: eventID, eventActId: selectedActivity?.eventactivityid)
        
        DIWebLayerActivityAPI().startEventActivityAddOn(endPoint: apiInfo.url,parent: self, params: apiInfo.params, completion: {[weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .Success( let data,_):
                  if let allData = data as? EventActStarted {
                        self?.selectedActivity?.activityProgressId = allData._id
                        self?.selectedActivity?.externalTypes = allData.externalTypes
                        self?.initialiseProgress()
                        //We need to start time and start activity
                    }
                case .NoDataFound:break
                case .Failure(let err):
                    self?.alertOpt(err)
                }
            }
            
        })
    
        }
    
    func completeACtivityLog(){
        var activityLogData:[String:Any] = [:]
        activityLogData["steps"] = "0.0"
        activityLogData["rating"] = 1
        activityLogData["categoryType"] = "3"
        activityLogData["distanceCovered"] = 0.0
        activityLogData["timeSpent"] = 0.0
        activityLogData["calories"] = 0.0
        
        activityLogData["duration"] =  "00:00:00"
        activityLogData["activityImage"] = self.selectedActivity?.image//string
        activityLogData["status"] = 2
        activityLogData["activityType"] = 0
        activityLogData["distance"] = "0.0"
        activityLogData["activityName"] = self.selectedActivity?.name
        if let act = self.selectedActivity?.activity_id{
            print(act)
        } else{
            print(self.selectedActivity?.activity_id)
        }
        activityLogData["activityId"] = self.selectedActivity?.activity_id ?? 0//string
        activityLogData["date"] = Date().timeStamp
        
        let params3: [String: Any] = ["activities": [activityLogData]]
        DIWebLayerActivityAPI().completeActivity(parameters: params3, success: { (_) in
            self.hideLoader()
            self.alertOpt("Activity has been logged sucessfully!") {
                self.nextActivity()
            }

        }, failure: { (msg) in
            self.showAlert(withTitle: msg.message ?? "", okayTitle: "Ok")
            self.hideLoader()
        })
}
    
    
    func skipEventActivityApi() {
        
        let apiInfo =  EndPoint.SkipActivity(eventID: eventID, activity: selectedActivity?.eventactivityid)
        
        DIWebLayerActivityAPI().skipEventActivityAddOn(endPoint: apiInfo.url,parent: self, params: apiInfo.params, completion: {[weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .Success( let msg):
                    debugPrint(msg)
                    self?.nextActivity(.Skip)
                case .Failure(let err):
                    self?.alertOpt(err)
                }
            }
            
        })
    
        }
    
    func paramsForCompleteAct() ->  [String:Any] {
        
        let listOfDistance = self.activityDates.map({$0.distance})
        self.totalDistance = listOfDistance.reduce(0, +)
       // var colories =
      //  self.totalCalories = 0
        for value in self.activityDates{
            let dateDifference = value.endDate.timeIntervalSince(value.startDate)
            let calories = HealthKit.instance?.calculateCalories(duration: dateDifference, metValue: self.selectedActivityProgress.activity?.metValue ?? 0) ?? 0
            self.totalCalories += calories
        }
        
        var actParams = CompeleteActivityData()
        
        actParams.activityId = self.selectedActivityProgress.activity?.activityProgressId
        
        actParams.calories = self.calculateCalories(calories: totalCalories, duration: totalTime, metValue: self.selectedActivityProgress.activity?.metValue)
        
        actParams.steps = Double(self.totalSteps)
        
        actParams.distanceCovered = self.calculateDistance(activity: self.selectedActivityProgress.activity, distance: self.totalDistance)
        actParams.status = .completed
        actParams.timeSpent = self.totalTime ?? 0.0
        actParams.isScheduledActivity = self.selectedActivityProgress.isScheduled
        actParams.eventId =  eventID
        actParams.eventactivityid = selectedActivity?.eventactivityid
                
        var dic:[String:Any] = actParams.getDictionary() ?? [:]
        dic["date"] = Date().timeStamp

        let params: [String: Any] = ["activities": [dic]]
        return params

    }
    
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
    
    func completeEventActivityApi() {
                
        DIWebLayerActivityAPI().completeEventActivityAddOn(endPoint: EndPoint.CompEventAct.url,parent: self, params: paramsForCompleteAct(), completion: {[weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .Success( let msg):
                    print(msg)
                    self?.nextActivity()
                case .Failure(let err):
                    self?.alertOpt(err)
                }
            }
            
        })
    
        }
    
    func initialiseProgress() {
        initialiseAfterStart()
        initialiseCurrentProgress()
        updateOnWatch()
        watchInitialise()
        statusChangedForSelectedActivity()
    }
    
    func statusChangedForSelectedActivity() {
        if let index = allActivities?.firstIndex(where: {$0.eventactivityid == selectedActivity?.eventactivityid}) {
            allActivities?[index].status = ActivityStatus.Started.rawValue
        }
    }
   
    
    func initialiseCurrentProgress() {
        
        guard let selectedActivity = selectedActivity else {return}
        selectedActivityProgress.activity = selectedActivity
        selectedActivityProgress.createdAt = Date()
        selectedActivityProgress.elapsed = 0
        selectedActivityProgress.startTime = Date().timeIntervalSinceReferenceDate
        startTime = Date().timeIntervalSinceReferenceDate
        selectedActivityProgress.isPlaying = true
        if selectedActivity.isBinary == 1 {
            /// Log binary
            self.alertOpt("Activity has been logged sucessfully!") {
                self.stopCurrentActivity()
        }
        } else {
            self.setTimer()
        }

         
    }
        
    func updateOnWatch() {
        do {
            let data =  try JSONEncoder().encode(selectedActivityProgress)
            
            let userActivityData = try JSONEncoder().encode(selectedActivity)
            //in watch app
            var dic: [String: Any] = [:]
            
            dic[MessageKeys.inProgressActivityData] =  data
            
            dic[MessageKeys.request] =  MessageKeys.createdNewActivityOnPhone
            
            dic[MessageKeys.userActivityData] =  userActivityData
            
            Watch_iOS_SessionManager.shared.updateApplicationContext(data: dic)
            
        } catch let error { print(error.localizedDescription) }
     }
    
    
    // MARK: All Actions
    
    @objc func handleFitbitDataNotification(notification: NSNotification) {
        self.setTimer()
        self.handleFitBitData()
    }
    
    func setTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        }
        if self.caloriesTimer == nil && !isOnlyTimeBoundActivity {
            self.caloriesTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateCaloriesCount), userInfo: nil, repeats: true)
        }
        if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String , deviceType == HealthAppType.fitbit.title {
            if FitbitAuthHandler.getToken() != nil {
                if distanceTimer == nil {
                    distanceTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(getDistanceFromFitbit), userInfo: nil, repeats: true)
                }
            }
        } else {
                if distanceTimer == nil {
                    distanceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getDistance), userInfo: nil, repeats: true)
            }
        }
    }
    @objc func getDistance() {
       
        DispatchQueue.main.async {
            let milesDistance = appDelegate.distance.converted(to: .miles).value.rounded(toPlaces: 2)
            self.tempDistance = milesDistance
 
            let totalDistanceToDisplay = (self.distance + milesDistance).rounded(toPlaces: 2)
            if totalDistanceToDisplay > self.totalDisplayedDistance {
                self.totalDisplayedDistance = totalDistanceToDisplay
            } else if  Watch_iOS_SessionManager.shared.isReachable() && Watch_iOS_SessionManager.shared.isWatchAppInstalled() {
                self.tempDistance = self.totalDisplayedDistance
            }
            let message: [String: Any] = ["request": MessageKeys.distanceFromCounterpart,
                                          "totalDistance": self.totalDisplayedDistance]
            Watch_iOS_SessionManager.shared.sendMessage(message: message, replyHandler: nil, errorHandler: nil)
                        
            let paceDistance =  Measurement(value: self.totalDisplayedDistance, unit: UnitLength.miles)
            let formattedPace = self.pace(distance: paceDistance,
                                          seconds: self.elapsed.toInt() ?? 0,
                                          outputUnit: UnitSpeed.milesPerHour)
            if self.isDistanceTypeActivity{
                self.distanceLabel.text = "\(self.totalDisplayedDistance)"
            }else{
                self.distanceLabel.text = "--"
            }
            
        }
        
    }
    
    func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit] // 1
        formatter.unitStyle = .short
        let newDistance = distance.converted(to: .meters)
        let speedMagnitude = seconds != 0 ? newDistance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        //        print("speed.converted(to: outputUnit)",speed.converted(to: outputUnit).value.rounded(toPlaces: 2))
        return "\(speed.converted(to: outputUnit).value.rounded(toPlaces: 2))"
        //        return formatter.string(from: speed.converted(to: outputUnit))
    }
    @objc func updateCounter() {
        let diffTime = Date().timeIntervalSinceReferenceDate - startTime
        // Calculate minutes
       
        elapsed = oldElapsedTime + diffTime
                
        self.selectedActivityProgress.time = elapsed
        
        self.totalTime = elapsed
        
        checkIfActivityIsTimeBound()

        self.selectedActivityProgress.totalTime = elapsed
        
        durationLabel.text = Utility.shared.secondsToStringTime(seconds: Int(elapsed))
        
        self.selectedActivityProgress.duration = durationLabel.text


        let result = (self.distanceLabel.text ?? "").filter("0123456789.".contains)
        
        if let distance = Double(result) {
            self.selectedActivityProgress.distance = distance
        }
    }
    func checkIfActivityIsTimeBound() {
        if let timeLimit = selectedActivityProgress.activity?.timeLimit,timeLimit > 0 {
            if self.totalTime ?? 0 >= Double(timeLimit) {
                //Stop Activity now
                stopCurrentActivity()
            }
        }
    }
    
    /// set the updated calories count
    @objc func updateCaloriesCount() {
        //calculate calories
        print("Tme---->\(elapsed)")
        self.totalCalories = calculateCalories(calories: nil, duration: self.totalTime, metValue: self.selectedActivityProgress.activity?.metValue) ?? 0
        self.caloriesLabel.text = "\(totalCalories.rounded(toPlaces: 2))"
    }
    //check if user has any linked device on "Link devices" screen, if not, then if the calories count is zero then calculate it
    func calculateCalories(calories: Double?, duration: Double?, metValue: Double?) -> Double? {
        let timeInSeconds = duration ?? 0
        let timeInHours = timeInSeconds/3600
        return Utility.calculatedCaloriesFrom(metValue: metValue ?? 0, duration: timeInHours)
    }
    
    
    func handleFitBitData() {
        if let selectedActivityTypeId = self.selectedActivityProgress.activity?.activityType,let activity = ActivityMetric(rawValue: selectedActivityTypeId) {
            
            if activity == .distance {
                self.getInitialDistanceFromFibit()
                self.getDistanceFromFitbit()
            }
        }
    }
    
    // MARK: Function to get distance from FitBit for Saved Dates(stop and resume time).
    
    @objc func getInitialDistanceFromFibit() {
        if count < self.activityDates.count {
            
            let data  = self.activityDates[count]
            self.getCompleteUrl(resourcePath: FitBitResourcePath.distance.path, startDate: data.startDate, endDate: data.endDate) { (value) in
                let result = value*0.621371
                self.distance += result.rounded(toPlaces: 2) //Double(result).rounded(toPlaces: 2)
                self.distanceLabel.text = "\(self.distance.rounded(toPlaces: 2))"
                self.count += 1
                if self.count < self.activityDates.count {
                    self.getInitialDistanceFromFibit()
                }
            }
        }else{
            self.distanceLabel.text = "0.0"
        }
    }
    // MARK: Function to get distance from HealthKit for Saved Dates(stop and resume time).
    
    @objc func getInitialDistance() {
        if self.count < self.activityDates.count{
            let data  = self.activityDates[count]
            HealthKit.instance?.getWalkingDistanceForTimePeriod(startDate: data.startDate, endDate: data.startDate, completion: { (double, error) in
                if error == nil {
                    self.distance += double
                    self.distanceLabel.text = "\(self.distance.rounded(toPlaces: 2))"
                }else{
                    self.distanceLabel.text = "0.0"
                }
                self.count += 1
                if self.count < self.activityDates.count {
                    self.getInitialDistance()
                }
            })
        }else{
            DispatchQueue.main.async {
                self.distanceLabel.text = "0.0"
            }
        }
    }
    
    // MARK: This Function will be called after 3 minutes to collect distance covered by user.
    @objc func getDistanceFromFitbit() {
        self.getCompleteUrl(resourcePath: FitBitResourcePath.distance.path, startDate: self.selectedActivityProgress.currentPeriodStartingDate ??  Date() , endDate: Date()) { (double) in
            let result = (double*0.621371).rounded(toPlaces: 2)
            self.tempDistance = result //Double(result).rounded(toPlaces: 2)
            self.distanceLabel.text = "\(Double(self.distance+result))"
        }
    }
    
    // MARK: Function to create FitBit Api URL.(Fitbit does not return result for 3 days according to time that is why we have to collect data for each day according to time selected by user.)
    
    @objc func getCompleteUrl(resourcePath:String,startDate:Date,endDate:Date,completion: @escaping (Double) -> Void) {
        let fitbitURL = "https://api.fitbit.com/1/user/-/\(resourcePath)/date/"
        let dayDifference = Utility.getDaysDifference(firstDate: startDate, secondDate: endDate)
        if dayDifference == 0 {
            let apiUrl = "\(fitbitURL)\(startDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/\(startDate.UTCToLocalString(inFormat: .fitbitTime))/\(endDate.UTCToLocalString(inFormat: .fitbitTime)).json"
            self.fetchData(resourcePath: resourcePath,url: apiUrl){ (value) in
                completion(value)
            }
        }else{
            var totalResponse = 0.0
            var firstDate = startDate
            var apiUrl = ""
            firstDate = firstDate.dayAfter
            for i in 1...dayDifference {
                switch i {
                case 1:
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/\(firstDate.UTCToLocalString(inFormat: .fitbitTime))/24:00.json"
                    firstDate = firstDate.dayAfter
                case dayDifference :
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/00:00/\(endDate.UTCToLocalString(inFormat: .fitbitTime)).json"
                default:
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/00:00/\(endDate.UTCToLocalString(inFormat: .fitbitTime)).json"
                }
                firstDate = firstDate.dayAfter
                self.fetchData(resourcePath: resourcePath, url: apiUrl){ (value) in
                    totalResponse += value
                }
            }
            completion(totalResponse)
        }
    }
    
    // MARK: This function will communicate with FitBit Apis.
    func fetchData(resourcePath:String,url:String,completion: @escaping (Double) -> Void) {
        let token = FitbitAuthHandler.getToken()
        let manager = FitbitAPIManager.shared()
        manager?.requestGET(url, token: token, success: { responseObject in
            if let response = responseObject {
                if let data = response["\(resourcePath.replace("/", replacement: "-"))"] as? [Parameters] {
                    let valueDict = data[0]
                    if let value = (valueDict["value"] as? String)?.toDouble() {
                        completion(value)
                    }else{
                        completion(0.0)
                    }
                }
            }
        }, failure:  { error in
            if let response = error {
                self.handleFitBitError(error: response)
            }
        })
    }
    
    // MARK: This function will handle error created by FitBit Apis.
    func handleFitBitError(error:Error) {
        self.hideLoader()
        let errorData = error._userInfo?[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
        var errorResponse: [AnyHashable : Any]? = nil
        do {
            if let errorData = errorData {
                errorResponse = try JSONSerialization.jsonObject(with: errorData, options: .allowFragments) as? [AnyHashable : Any]
            }
        } catch {
        }
        let errors = errorResponse?["errors"] as? [Any]
        let errorType = (errors?[0] as? NSObject)?.value(forKey: "errorType") as? String
        //   self.showAlert(message:"\(errorType)")
//        print("errorTypeerrorTypeerrorType \(String(describing: errorType))")
        if (errorType == fInvalid_Client) || (errorType == fExpied_Token) || (errorType == fInvalid_Token) || (errorType == fInvalid_Request) {
            // To perform login if token is expired
            //            self.showAlert(withTitle: "FiBit Login", message: "You must login to FitBit, After login Tem can fetch your health data from fitbit App", okayTitle: "Login", cancelTitle: "Cancel", okStyle: .default, okCall: {
            FitbitAuthHandler.shareManager()?.loadVars()
            FitbitAuthHandler.shareManager()?.login(self)
            //            }) {
            //            }
        }else{
            //  self.showAlert(message:errorType)
        }
    }
    // MARK: Function to fetch Data one by one for each time periods.
    func getDataForTimeInterval() {
        if self.count < self.activityDates.count {
            let data  = self.activityDates[count]
            if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String , deviceType == HealthAppType.fitbit.title {
                self.getStepsAndCaloriesFromFitbit(data: data)
            }else{
                self.getDataFromHealthKit(data: data)
            }
        }
    }
    
    // MARK: This will call when activity will stop by the user.(To collect Steps and Calories)
    func getStepsAndCaloriesFromFitbit(data:AccessTuple) {
        self.getCompleteUrl(resourcePath: FitBitResourcePath.distance.path, startDate: data.startDate, endDate: data.endDate) { (value) in
            let result = value*0.621371
            self.totalDistance += result.rounded(toPlaces: 2)
            self.getCompleteUrl(resourcePath: FitBitResourcePath.steps.path, startDate: data.startDate, endDate: data.endDate) { (value) in
                self.totalSteps += Int(value)
                self.getCompleteUrl(resourcePath: FitBitResourcePath.calories.path, startDate: data.startDate, endDate: data.endDate) { (value) in
                    self.totalCalories += value.rounded(toPlaces: 2)
                    self.count += 1
                    if self.count < self.activityDates.count {
                        self.getDataForTimeInterval()
                    }else{
                        self.totalCalories = self.totalCalories.rounded(toPlaces: 2)
                    }
                }
            }
        }
    }
    
    // MARK: This will call when activity will stop by the user.(To collect Steps and Calories)
    func getDataFromHealthKit(data:AccessTuple) {
        self.getStepsFromHealthKit(startDate: data.startDate, endDate: data.endDate) { (steps, distance, calories) in
            self.totalSteps += Int(steps)
            self.count += 1
            if self.count < self.activityDates.count {
                self.getDataForTimeInterval()
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
      
    
    @IBAction func exitAction(_ sender: Any) {
        debugPrint("Exit Action")
        alertExitFromEvent()
        
    }
    func exitFromEvent() {
        stop()
        saveToLocal()
        self.navigationController?.popViewController(animated: true)
    }
    func alertExitFromEvent() {
    
        alertOpt("Do you want to exit from this event", okayTitle: "Yes", cancelTitle: "No", okCall: {
            //Start next one
            self.dismiss(animated: true) {
                self.exitFromEvent()
            }
            //Start next one
            
            
        }, cancelCall: nil, parent: self)
    }
    
    func saveToLocal() {
        selectedActivity?.timeSpent = elapsed
        selectedActivity?.calories = totalCalories
        selectedActivity?.steps = Double(totalSteps)
        selectedActivity?.distanceCovered = totalDistance
        selectedActivityProgress.activity = selectedActivity
        selectedActivity?.saveActivity(eventID)
    }
    func initialiseFromLocal() -> ActivityData? {
        if let activity = ActivityData.getCurrentActivity(eventID) {
            totalCalories = activity.calories ?? 0.0
            totalTime = activity.timeSpent ?? 0
            elapsed =   0
            oldElapsedTime = activity.timeSpent ?? 0
            totalDistance  = activity.distanceCovered ?? 0
            totalSteps  = Int(activity.steps ?? 0.0)
            
            return activity

        }else {
            if let firstStatedActIndex = allActivities?.firstIndex(where: { ActivityStatus(rawValue:  $0.status ?? 0) == .Started}) {
                
                selectedActivityIndex = firstStatedActIndex
                
                selectedActivity = allActivities?[firstStatedActIndex]
                
                self.activityNameLabel.text =   self.selectedActivity?.name?.capitalized
                
                showSelectedActivity()
        }
    }
        return nil
    }
    @IBAction func skipButAction(_ sender: Any) {
        debugPrint("skip Action")
        alertOpt("Do you want to skip this activity", okayTitle: "Yes", cancelTitle: "No", okCall: {
            
            //Start next one
            self.skipEventActivityApi()
            
            debugPrint("Start next activity")
        }, cancelCall: nil, parent: self)
    }
  
    @IBAction func playPauseAction(_ sender: Any) {
        
        let isPlaying = self.selectedActivityProgress.isPlaying ?? false

        let VC = loadVC(.ResumeStopController) as! ResumeStopController
        VC.isPlaying = isPlaying
        VC.stopActivity = {
            DispatchQueue.main.async {
                self.stopCurrentActivity()
            }
        }
        VC.pauseResume = { (callBackIsPlaying) in
            let title  = callBackIsPlaying ? "PAUSE/STOP" : "PAUSE/STOP"
            self.pauseStopButOut.setTitle(title, for: .normal)
            self.stopAndStartActivity(callBackIsPlaying)

        }
        self.present(VC, animated: true, completion: nil)

        }
    
    @IBAction func checklistTapped(_ sender: UIButton) {
        let checkListSideMenu:RoundChecklistSideMenuViewController = UIStoryboard(storyboard: .createevent).initVC()
        checkListSideMenu.eventId = self.eventID ?? ""
      self.navigationController?.present(checkListSideMenu, animated: true)
    }
    
    func stopCurrentActivity() {
       stop()
       completeEventActivityApi()
    }
    //Api hit for complete activity
    
    func nextActivity(_ status:ActivityStatus? = .Completed) {
        if let index = allActivities?.firstIndex(where: {$0.eventactivityid == selectedActivity?.eventactivityid}) {
            invalidateTimer()
            
            
            allActivities?[index].status = status?.rawValue ?? 1
            
            allActivities?[index].activityStatus = status
            
            resetAll()
            selectNewActivity()
        }
    }

    func resetAll() {
        if let index = selectedActivityIndex {
            
            let listOfDistance = self.activityDates.map({$0.distance})
            
            self.totalDistance = listOfDistance.reduce(0, +)
                        
            for value in self.activityDates{
                
                let dateDifference = value.endDate.timeIntervalSince(value.startDate)
                let calories = HealthKit.instance?.calculateCalories(duration: dateDifference, metValue: self.selectedActivityProgress.activity?.metValue ?? 0) ?? 0
                self.totalCalories += calories
            }
            
            
            allActivities?[index].calories  = totalCalories
            
            allActivities?[index].distanceCovered  = totalDistance
            
            allActivities?[index].steps  = Double(totalSteps)
            
            allActivities?[index].timeSpent  = elapsed
        }
        count = 0
        oldElapsedTime = 0
        breakTime = 60
        caloriesLabel.text = "0"
        distanceLabel.text  = "--"
        durationLabel.text = "00:00:00"
        startTime = 0
        activityDates.removeAll()
        UserManager.removeActAddOnDatesDistance(eventID)
        time = 0
        elapsed = 0
        totalTime = 0
        totalCalories = 0
        totalDistance = 0
        distance = 0
        ActivityData.removeEventActivity(eventID: eventID)
        timeIntervel = (Date(),Date(),0)
        activityDates = []
        totalDistance = 0
        tempDistance = 0
        totalSteps = 0
    }
    
    func stopAndStartActivity(_ forcePlayPause:Bool? = nil) {
        let isOldPlaying = self.selectedActivityProgress.isPlaying  ?? false
        self.selectedActivityProgress.isPlaying = forcePlayPause ?? !isOldPlaying
        if !(self.selectedActivityProgress.isPlaying ?? false) {
            appDelegate.stopLocation()
            stop()
        }else {
            reStart()
            if let activityType = self.selectedActivityProgress.activity?.selectedActivityType,
               let type = ActivityMetric(rawValue: activityType),
               type == .distance{
                appDelegate.startLocation()
        }
        }
        
       self.changeActivityStateOnWatchApp()
    }
        
        
        private func changeActivityStateOnWatchApp() {
            var inprogressState = InProgressActivityState()
            inprogressState.totalTime = self.totalTime
            inprogressState.duration = self.selectedActivityProgress.duration
            inprogressState.elapsed = self.selectedActivityProgress.elapsed
            inprogressState.isPlaying = self.selectedActivityProgress.isPlaying
            inprogressState.stateChangeTime = Date().timeIntervalSinceReferenceDate
            do {
                let encodedData = try JSONEncoder().encode(inprogressState)
                let data: [String: Any] = ["request": MessageKeys.activityStateChangedOnPhone,
                                           "data": encodedData]
                Watch_iOS_SessionManager.shared.updateApplicationContext(data: data)
            } catch let error{debugPrint(error.localizedDescription) }
        }
        
        
        
        // MARK: Function to Start/Stop timer.
        func reStart(changeStartTime:Bool = true) {
            if let activityType = self.selectedActivityProgress.activity?.selectedActivityType,
               let type = ActivityMetric(rawValue: activityType),
               type == .distance{
                appDelegate.startLocation()
            }
            if changeStartTime {
                self.timeIntervel.startDate = Date()
                self.selectedActivityProgress.currentPeriodStartingDate = Date()
                startTime = Date().timeIntervalSinceReferenceDate - elapsed
            }
            self.setTimer()
            self.selectedActivityProgress.startTime = startTime
        }
        
        func stop() {
            self.saveDatesData()
            self.selectedActivityProgress.elapsed = elapsed
            self.timer?.invalidate()
            self.distanceTimer?.invalidate()
            self.caloriesTimer?.invalidate()
            
        }

}
extension EventsActAddOnsVC:StartActivityDelegate {
    func startActivity() {
        debugPrint("Start Activity")
        startEventActivityApi()
    }
}
