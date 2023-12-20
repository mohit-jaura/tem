//
//  ActivityProgressController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 30/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import HealthKit
import SSNeumorphicView

typealias AccessTuple = (startDate: Date, endDate: Date,distance:Double)
typealias AccessDictionary = [String: Date]
typealias AccessDistance = [String: Double]

let startDateKey = "startDateKey"
let endDateKey = "endDateKey"
let distanceKey = "distanceKey"

 // MARK: Varaibles
/// Holds the cases for how the activity progress stopped
///
/// - activityTerminated: indicates that the activity was stopped by pressing stop button
/// - newActivityAdded: indicates that the activity was stopped by adding another activity
/// - none: default option which indicates in progress
enum ActivityPauseState {
    case activityTerminated, newActivityAdded, none
}

class ActivityProgressController: DIBaseController {
    
     // MARK: Properties
    var rightInset: CGFloat = 7
    //    var fitbitAuthHandler: FitbitAuthHandler? = nil
    var activityDates:[AccessTuple] = [AccessTuple]()
    var healthAppType:HealthAppType = .healthKit
    weak var timer: Timer?
    weak var distanceTimer : Timer?
    weak var caloriesTimer: Timer?
    private var startTime: Double = 0
    private var time: Double = 0
    private var elapsed: Double = 0
    private var isPlaying: Bool = false
    var count:Int = 0
    var writeDataCounter = 0
    // var objHealthKitInterface:HealthKitInterface? = nil
    var activityData:ActivityProgressData = ActivityProgressData()
    // var activityData:ActivityData = ActivityData()
    var startDate:Date?
    var totalTime:Double?
    var distance:Double = 0.0
    var totalSteps:Double = 0.0
    var totalCalories:Double = 0.0
    var totalDistance:Double = 0.0
    var tempDistance:Double = 0.0
    var timeIntervel:AccessTuple = (Date(),Date(),0)
    var isFromDashBoard:Bool = false
    var selctedActivityId: Int?
    var categoryType: ActivityCategoryType.RawValue = ActivityCategoryType.mentalStrength.rawValue
    var activityPausedDueToAlert = false
    private var activityTypesArray: [ActivityCategory]? //this will hold the list of activity types which the user can choose to create an additional activity
    private var additionalActivity: ActivityData?
    
    var activityPausedState: ActivityPauseState = .none
    private var newProgressIdFromServer: String?
    var isTabbarChild = false
    
    var navBar: NavigationBar?
    private var addedNewActivityOnWatch = false
    var stopAnimation: Bool = false
    private let playIconImage = UIImage(named: "play")
    private let pauseIconImage = UIImage(named: "pauseGreen")
    
    // this is being used in the in-progress mile calculation
    var singleMileCount: Int = 1
    var lastMileCount: Int = 0
    var lastMileCompletedTime: Double = 0
    var avgMile: Double = 0
    var isDistanceTypeActivity: Bool = true
    var totalDisplayedDistance: Double = 0
    var activitiesArray = [[String: Any]]()
    var screenFrom = Constant.ScreenFrom.activity
    var eventID = ""
    private var currentActivityId: String?
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    var isOnlyTimeBoundActivity: Bool {
        return (self.activityData.activity?.name == "Focus Time" ||  self.activityData.activity?.name == "Meditation")
    }
     // MARK: IBOutlets
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var metricValueLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    //    @IBOutlet weak var honeyCombView: ActivityProgressHoneyCombView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var shadowView: SSNeumorphicView! {
        didSet {
            shadowView.viewDepthType = .innerShadow
            shadowView.viewNeumorphicMainColor = viewBackgroundColor.cgColor
            self.shadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            self.shadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(1).cgColor
            shadowView.viewNeumorphicCornerRadius = 9
            shadowView.viewNeumorphicShadowRadius = 3
            shadowView.borderWidth = 0
        }
    }
    @IBOutlet weak var checklistMEnuButton: UIButton!
    @IBOutlet weak var outerView: UIView!
    
    //  @IBOutlet weak var rotatingHoneyCombView: UIView!
    // @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var inProgressMileView: UIView!
    @IBOutlet weak var inProgressMileLabel: UILabel!
    @IBOutlet weak var averageMileView: UIView!
    @IBOutlet weak var averageMileLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var caloriesView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    //    @IBOutlet weak var speedoMeterView: UIView!
    //    @IBOutlet weak var speedLabel: UILabel!
    
     // MARK: IBActions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if let isPlaying = self.activityData.isPlaying {
            //if it is in playing state,-> pause
            if isPlaying {
                self.playPauseButton.setTitle("RESUME", for: .normal)
                //  self.playPauseButton.setImage(playIconImage, for: .normal)
                self.stopAnimation = true
                self.stopViewRotation()
            } else {
                appDelegate.distance = Measurement(value: 0, unit: UnitLength.meters)
                self.playPauseButton.setTitle("PAUSE", for: .normal)
                //    self.playPauseButton.setImage(pauseIconImage, for: .normal)
                self.stopAnimation = false
                self.startViewRotation()
            }
        } else {
            self.playPauseButton.setTitle("RESUME", for: .normal)
            // self.playPauseButton.setImage(playIconImage, for: .normal)
            self.stopAnimation = true
            self.stopViewRotation()
        }
        self.stopAndStartActivity()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        self.pauseActivityBeforeShowingAlert()
        self.showAlert(withTitle: "", message: "Add Activity?", okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okStyle: .default, okCall: {
            /*if let activityTypesArray = self.activityTypesArray,
             !activityTypesArray.isEmpty {
             self.showNewActivitiesList(activities: activityTypesArray)
             } else {
             //fetch the list from server
             self.getActivitiesFromBackend()
             } */
            
            self.activityPausedState = .newActivityAdded
            self.fetchCurrentActivityFinalData()
            
        }, cancelCall: {
            //resume the activity again
            self.resumeActivityOnAlertDismiss()
        })
    }
    @IBAction func checklistTapped(_ sender: UIButton) {
        let checkListSideMenu:RoundChecklistSideMenuViewController = UIStoryboard(storyboard: .createevent).initVC()
        checkListSideMenu.eventId = self.eventID
      self.navigationController?.present(checkListSideMenu, animated: true)
    }
    
     // MARK: ViewLifeCycle Functions.
     // MARK: viewDidLoad..
    
    var activityStartTime:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        Watch_iOS_SessionManager.shared.delegate = self
        self.addConnectivityObserver()
        initUI()
    }
    
     // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addBadgeObserver()
        self.updateBadge()
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: false, controller: self)
        }
        self.navigationController?.navigationBar.isHidden = true
        self.handleActivityState()
        self.getUnreadCount()
        self.checkAlreadyRunningActivity()
    }
    func getDateTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    func checkAlreadyRunningActivity() {
        guard addedNewActivityOnWatch else {
            return
        }
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            
            let selectedVC: ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
            if let data = ActivityProgressData.currentActivityInfo() {
                let progressData = data
                
                if let isPlaying = data.isPlaying,
                   isPlaying {
                    let difference = Date().timeIntervalSinceReferenceDate - (data.startTime ?? Date().timeIntervalSinceReferenceDate)
                    progressData.elapsed = difference
                }
                selectedVC.activityData = progressData//data
            }
            selectedVC.isTabbarChild = isTabbarChild
            selectedVC.isFromDashBoard = true
            addedNewActivityOnWatch = false
            self.navigationController?.viewControllers = [selectedVC]
        }
    }
    
    deinit {
        print("deinit of progress screen")
        self.removeConnectivityObserver()
    }
    
     // MARK: ViewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeBadgeObserver()
        self.invalidateTimer()
        self.stopAnimation = true
        self.stopViewRotation()
    }
    
     // MARK: Notification observers
    private func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUnreadCount), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    //add connectivity observersse
    private func addConnectivityObserver() {
        self.removeConnectivityObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(workoutFailedOnWatchApp(notification:)), name: Notification.Name.workoutFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityInfoUpdated(notification:)), name: Notification.Name.activityInfoUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityStoppedOnWatchApp(notification:)), name: Notification.Name.activityHasBeenStoppedOnDevice, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(additionalActivityAddedOnWatchApp), name: Notification.Name.additionalActivityAddedOnWatchApp, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveDatesDataWhenAppKill), name: UIApplication.willTerminateNotification, object: nil)
        
    }
    
    private func removeConnectivityObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.activityInfoUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.activityHasBeenStoppedOnDevice, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.additionalActivityAddedOnWatchApp, object: nil)
    }
    
    @objc func additionalActivityAddedOnWatchApp() {
        self.addedNewActivityOnWatch = true
    }
    
    @objc func workoutFailedOnWatchApp(notification: Notification) {
        if let userInfo = notification.userInfo,
           let activityId = userInfo["activityId"] as? String,
           let currentId = self.currentActivityId {
            if activityId == currentId {
                //if this is the same activity that was failed
                let selectedVC:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
                selectedVC.isFromDashBoard = self.isFromDashBoard
                selectedVC.isTabbarChild = self.isTabbarChild
                DispatchQueue.main.async {
                    if self.isTabbarChild {
                        self.navigationController?.viewControllers = [selectedVC]
                    } else {
                        if let activityController = self.navigationController?.viewControllers.first {
                            self.navigationController?.popToViewController(activityController, animated: true)
                        }
                    }
                }
            }
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
                self.durationLabel.text = data.duration
            }
            
            self.activityData.isPlaying = data.isPlaying
            self.isPlaying = data.isPlaying ?? true
            self.activityData.saveEncodedInformation()
            if let playingState = data.isPlaying {
                if playingState == true {
                    //activity is playing on other device
                    DispatchQueue.main.async {
                        self.stopAnimation = false
                        self.startViewRotation()
                        self.playPauseButton.setTitle("PAUSE", for: .normal)
                        //    self.playPauseButton.setImage(self.pauseIconImage, for: .normal)
                        self.start()
                    }
                } else {
                    //activity is paused on other device
                    DispatchQueue.main.async {
                        self.playPauseButton.setTitle("RESUME", for: .normal)
                        //self.playPauseButton.setImage(self.playIconImage, for: .normal)
                        self.stopAnimation = true
                        self.stopViewRotation()
                    }
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
        }
    }
    
    /// navigate to activity summary screen if the respective activity is stopped on watch
    /// - Parameter notification: notifcation info
    @objc func activityStoppedOnWatchApp(notification: Notification) {
        //navigate to activity summary screen
        if let userInfo = notification.userInfo,
           let data = userInfo["data"] as? [CompletedActivityData] {
            //first two elements are the additional activities and the last is the current activity on self
            self.pauseActivityBeforeShowingAlert()
            appDelegate.stopLocation()
            if let currentData = data.last {
                //last element and this would be the current activity information
                self.totalTime = currentData.timeSpent
                self.totalCalories = currentData.calories ?? 0
                self.totalDistance = currentData.distanceCovered ?? 0
                self.totalSteps = currentData.steps ?? 0
            }
            self.navigateToActivitySummaryViewController(completeActivityData: data)
        }
    }
    
     // MARK: Custom Functions.
     // MARK: Function to set initial data and UIDesign properties.
    func initUI() {
        if screenFrom == .event {
            checklistMEnuButton.isHidden = false
        } else {
            checklistMEnuButton.isHidden = true
        }
        self.activityStartTime = self.getDateTime()
        //Only show for distance type activity
        self.setPaceValues()
        //       self.inProgressMileView.isHidden = true
        //        self.averageMileView.isHidden = true
        
        self.checkForCombinedActivitiesCount()
        self.setActivityDisplayInfo()
        self.configureConfiguration()
        self.setData()
        //self.speedoMeterView.isHidden = true
        
        if let selectedActivityType = self.activityData.activity?.selectedActivityType {
            if (selectedActivityType == ActivityMetric.distance.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == ActivityMetric.none) {
                //              self.inProgressMileView.isHidden = true
                //                self.averageMileView.isHidden = true
                self.distanceView.isHidden = false
            }
            //            if let type = self.activityData.activity?.id {
            //                switch type {
            //                case 5: // for OutDoor cycle
            //                    self.speedoMeterView.isHidden = false
            //                default:
            //                    self.speedoMeterView.isHidden = true
            //                }
            //            } else {
            //                self.speedoMeterView.isHidden = true
            //
            //            }
        }
        
        if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String , deviceType == HealthAppType.fitbit.title {
            //  self.fitbitAuthHandler = FitbitAuthHandler(self)
            //self.getSleepTimeFromFitbit()
            if FitbitAuthHandler.getToken() == nil {
                FitbitAuthHandler.shareManager()?.loadVars()
                FitbitAuthHandler.shareManager()?.login(self)
                NotificationCenter.default.addObserver(self,selector: #selector(self.handleFitbitDataNotification),name: NSNotification.Name(rawValue:FitbitNotification),object: nil)
            } else {
                self.handleFitBitData()
            }
        } else {
            //    self.objHealthKitInterface = HealthKitInterface()
            //            if ActivityType(rawValue: self.activityData.activity?.activityType ?? 3) == .duration {
            //                self.distanceView.isHidden = true
            //                self.stackViewHeightConstraint.constant = 60
            //            }
            NotificationCenter.default.addObserver(self,selector: #selector(self.handleHealthKitData),name: NSNotification.Name(rawValue:healthKitAutorized),object: nil)
        }
        if isFromDashBoard {
            categoryType = activityData.categoryType
        }
    }
    
     // MARK: Helper functions
    private func setActivityDisplayInfo() {
        self.activityNameLabel.text = self.activityData.activity?.name?.uppercased()
    }
    
    /// start the view rotation
    private func startViewRotation() {
        //set icon to play
        if !self.stopAnimation {
            self.playPauseButton.setTitle("PAUSE", for: .normal)
            //   self.playPauseButton.setImage(pauseIconImage, for: .normal)
        }
        /*    UIView.transition(with: self.rotatingHoneyCombView, duration: 1.0, options: [.transitionFlipFromLeft], animations: {
         }) { (true) in
         if !self.stopAnimation {
         self.startViewRotation()
         }
         }*/
    }
    
    /// stop the view rotation
    private func stopViewRotation() {
        //set icon to pause
        self.playPauseButton.setTitle("RESUME", for: .normal)
        // self.playPauseButton.setImage(playIconImage, for: .normal)
        
        //        self.stopAnimation = true
        /*   rotatingHoneyCombView.layer.removeAllAnimations()
         rotatingHoneyCombView.layer.sublayers?.forEach({ (layer) in
         layer.removeAllAnimations()
         })*/
    }
    
     // MARK: Watch connectivity
    /// call this function to send the dates in watch app
    func updateActivityDatesToWatchApp(data: [AccessDictionary]) {
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data)
//        let dict: [String: Any] = [MessageKeys.userActivityDates: encodedData,
//                                   "request": MessageKeys.updateNewDates]
        //  Watch_iOS_SessionManager.shared.updateApplicationContext(data: dict)
    }
    
    private func checkForCombinedActivitiesCount() {
        if let activities = CombinedActivity.currentActivityInfo(),
           activities.count == 2 { //maximum of 3 combined activities can be performed at a time.
            //hide the add button on top
            //            self.addButton.isHidden = true
            self.addButton.isUserInteractionEnabled = false
            // self.addButton.setImage(UIImage(named: "newDisabled")!, for: .normal)
        }
    }
    
    @objc func handleHealthKitData(notification: NSNotification) {
        self.setTimer()
        if let selectedActivityType = self.activityData.activity?.selectedActivityType {
            if (selectedActivityType == ActivityMetric.distance.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == ActivityMetric.none) {
                self.distanceView.isHidden = false
            } else {
                if checkPermissionForDistance() {
                    self.getInitialDistance()
                    self.getDistance()
                } else {
                    self.metricValueLabel.text = "0.0"
                }
            }
        }
        
    }
    
    @objc func handleFitbitDataNotification(notification: NSNotification) {
        self.setTimer()
        self.handleFitBitData()
    }
    
    func handleFitBitData() {
        if let selectedActivityType = self.activityData.activity?.selectedActivityType {
            if (selectedActivityType == ActivityMetric.distance.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == ActivityMetric.none) {
                self.distanceView.isHidden = false
            } else {
                self.getInitialDistanceFromFibit()
                self.getDistanceFromFitbit()
            }
        }
    }
    
    func setData() {
        //        TravelDistanceManager.shared.initalize()
        self.activityDates = self.deserializeDictionary(dictionary: UserManager.getUserActivityDates() ?? [AccessDictionary](), distanceDict: UserManager.getUserActivityDistance() ?? [AccessDistance]())
        self.currentActivityId = "\(String(describing: self.activityData.activity?.id))"
        self.startDate = self.activityData.createdAt
        self.elapsed = self.activityData.elapsed ?? 0
        self.startTime = self.activityData.startTime ?? 0
        self.time = self.activityData.time ?? 0
        self.totalTime = self.activityData.totalTime ?? 0
        let listOfDistance = self.activityDates.map({$0.distance})
        self.distance = listOfDistance.reduce(0, +)
        if self.isDistanceTypeActivity {
            self.metricValueLabel.text = "\(self.distance.rounded(toPlaces: 2))"
        } else {
            self.metricValueLabel.text = "--"
        }
  //      self.metricValueLabel.text = "\(self.distance.rounded(toPlaces: 2))"
        durationLabel.text = self.activityData.duration
        self.totalCalories = calculateCalories(calories: nil, duration: self.totalTime, metValue: self.activityData.activity?.metValue) ?? 0
        self.caloriesLabel.text = "\(totalCalories.rounded(toPlaces: 2))"
        setUpDistanceView()
        setAverageAndInProgressMile(distance: self.distance, totalTime: self.totalTime ?? 0)
    }
    
    /// setup the distance view: for duration activities, this will be nil
    private func setUpDistanceView() {
        if let selectedActivityType = self.activityData.activity?.selectedActivityType {
            if (selectedActivityType == ActivityMetric.distance.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == .duration) || (selectedActivityType == ActivityMetric.duration.rawValue && ActivityMetric(rawValue: self.activityData.activity?.activityType ?? 3) == ActivityMetric.none) {
                //               self.inProgressMileView.isHidden = true
                //                self.averageMileView.isHidden = true
                self.distanceView.isHidden = false
                self.isDistanceTypeActivity = false
                //                distanceGroup.setHidden(true)
            }
        }
    }
    
    func handleActivityState() {
        if let isPlayingState =  self.activityData.isPlaying {
            if isPlayingState {
                self.timeIntervel.startDate = self.activityData.currentPeriodStartingDate ?? Date()
                self.stopAnimation = false
                self.startViewRotation()
                self.start(changeStartTime: false)
            } else {
                self.stopViewRotation()
            }
        } else {
            self.activityData.isPlaying = true
            self.startDate = Date()
            self.activityData.saveEncodedInformation()
            self.saveDataToDefaults()
            self.runTimer()
        }
    }
    
    func configureConfiguration() {
        /*     if isTabbarChild {
         self.navBar = configureNavigtion(onView: navigationBarView, title: "", leftButtonAction: .menuWhite)
         
         } else {
         self.navBar = configureNavigtion(onView: navigationBarView, title: "", leftButtonAction:.backWhite)
         }*/
    }
    
     // MARK: This method call initializes the timer. It specifies the timeInterval (how often the a method will be called) and the selector (the method being called).
    func runTimer() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }
    
     // MARK: Function to start timer.
    func start(changeStartTime:Bool = true) {
        if let activityType = self.activityData.activity?.selectedActivityType,
           let type = ActivityMetric(rawValue: activityType),
           type == .distance {
            appDelegate.startLocation()
        }
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
            if self.checkPermissionForDistance() {
                if distanceTimer == nil {
                    distanceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getDistance), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    func checkPermissionForDistance() -> Bool {
        return true
    }
    func checkPermissionForSteps() -> Bool {
        return true
        //Not working
        /*
         let authorizationStatus = HealthKit.instance?.healthKitDataStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!)
         switch authorizationStatus {
         case .sharingAuthorized?:
         print("sharing authorized")
         return true
         case .sharingDenied?: print("sharing denied")
         return false
         default: print("not determined")
         return false
         }
         */
        
    }
    
    func checkPermissionForCalories() -> Bool {
        return true
        //Not working
        /*
         let authorizationStatus = HealthKit.instance?.healthKitDataStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!)
         switch authorizationStatus {
         case .sharingAuthorized?:
         print("sharing authorized")
         return true
         case .sharingDenied?: print("sharing denied")
         return false
         default: print("not determined")
         return false
         }
         */
    }
    
    //getunread count of notifcations
    @objc func getUnreadCount() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count, _) in
            self.navBar?.displayBadge(unreadCount: count)
        }
    }
    
    @objc func updateBadge() {
        self.navBar?.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
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
    
     // MARK: Add New Activity
    private func getActivitiesFromBackend() {
        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerActivityAPI().getUserActivity( success: { (activities) in
                self.hideLoader()
                /*//removing the current activity from the list
                 self.activityTypesArray = activities.filter({ (activityData) -> Bool in
                 return activityData.id != self.activityData.activity?.id
                 }) */
                self.activityTypesArray = activities
                self.showNewActivitiesList(activities: activities[0].type)
            },failure: { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            })
        }
    }
    
    func createNewUserActivityOnServer() {
        //self.showLoader()
        var params = CreateActivity()
        params.activityId = additionalActivity?.id ?? 0
        if let type = additionalActivity?.activityType,
           let typeValue = ActivityMetric(rawValue: type) {
            params.activityType = typeValue
        } else {
            params.activityType = ActivityMetric.none
        }
        DIWebLayerActivityAPI().createActivity(parameters: params.getDictionary(), success: { (data) in
            //self.hideLoader()
            //            //removing last activity data from defaults
            //            UserManager.removeAtivityData()
            //            self.saveAdditionalActivityData()
            //            Defaults.shared.set(value: true, forKey: .isActivity)
            //            self.additionalActivity?.actvivityProgressId = data["_id"] as? String ?? ""
            //            self.navigateToActivityProgressScreen()
            self.newProgressIdFromServer = data["_id"] as? String ?? ""
            self.fetchCurrentActivityFinalData()
            NotificationCenter.default.post(name: NSNotification.Name("activityScoreChanged"), object: nil)
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        })
    }
    
    func newUserActivityCreatedSuccessfully() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //            print("hideloader")
            self.hideLoader()
        }
        //removing last activity data from defaults
        UserManager.removeAtivityData()
        self.additionalActivity?.activityProgressId = self.newProgressIdFromServer
        self.saveAdditionalActivityData()
        Defaults.shared.set(value: true, forKey: .isActivity)
        self.newProgressIdFromServer = nil
        self.navigateToActivityProgressScreen()
        
    }
    
    /// call this function to send the on-going activity information to the watch app
    func updateActivityCreateStatusToWatchApp(combinedActivityData: Data) {
        let activityProgressInfo = self.getActivityProgressObject()
        activityProgressInfo.startTime = Date().timeIntervalSinceReferenceDate
        activityProgressInfo.isPlaying = true
        do {
            let data = try JSONEncoder().encode(activityProgressInfo)
            let infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
                                                 "request": MessageKeys.createdNewActivityOnPhone,
                                                 MessageKeys.additionalActivityAdded: combinedActivityData]
            Watch_iOS_SessionManager.shared.updateApplicationContext(data: infoDictToPass)
        } catch {
            return
        }
    }
    
    private func showNewActivitiesList(activities: [ActivityData]) {
        DispatchQueue.main.async {
            self.showSelectionModal(array: activities, type: .additionalActivity)
        }
    }
    
    private func navigateToActivityProgressScreen() {
        let activityProgressController: ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
        activityProgressController.activityData = getActivityProgressObject()
        activityProgressController.isTabbarChild = self.isTabbarChild
        //activityProgressController.isFromDashBoard = self.isFromDashBoard
        DispatchQueue.main.async {
            //self.navigationController?.pushViewController(activityProgressController, animated: true)
            if self.isTabbarChild {
                self.navigationController?.viewControllers = [activityProgressController]
            } else {
                //page child
                if let firstController = self.navigationController?.viewControllers.first {
                    self.navigationController?.viewControllers = [firstController, activityProgressController]
                }
            }

            //self.removeCurrentControllerFromStack()
        }
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
                self.updateActivityCreateStatusToWatchApp(combinedActivityData: encodedData)
            }
        }
    }
    
    private func getActivityProgressObject() -> ActivityProgressData {
        let activityProgressData: ActivityProgressData = ActivityProgressData()
        activityProgressData.activity = self.additionalActivity
        activityProgressData.createdAt = Date()
        activityProgressData.elapsed = 0
        activityProgressData.startTime = 0
        activityProgressData.categoryType = self.categoryType
        activityProgressData.saveEncodedInformation()
        return activityProgressData
    }
    
     // MARK: Function to stop timer.
    func stop() {
        //        self.distance += self.tempDistance
        self.saveDatesData()
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        self.activityData.elapsed = elapsed
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        self.timer?.invalidate()
        self.distanceTimer?.invalidate()
        self.caloriesTimer?.invalidate()
        // Set Start/Stop button to false
        isPlaying = false
    }
    
    func stopSimpleTimerOnly() {
        self.saveDatesData()
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        self.activityData.elapsed = elapsed
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        self.timer?.invalidate()
        isPlaying = false
    }
    
    @objc func saveDatesData() {
        self.timeIntervel.endDate = Date()
        self.timeIntervel.distance = self.tempDistance
        self.activityDates.append(self.timeIntervel)
        let dataToSave = self.serializeTuple(tuples:  self.activityDates)
        let distanceToSave = self.serializeDistanceTuple(tuples: self.activityDates)
        UserManager.saveUseractivityDates(data: dataToSave)
        UserManager.saveUseractivityDistance(data:distanceToSave)
        self.updateActivityDatesToWatchApp(data: dataToSave)
    }
    @objc func saveDatesDataWhenAppKill() {
        stopAndStartActivity()
        //        let content = UNMutableNotificationContent()
        //        content.title = "Hello"
        //        content.body = "\(self.tempDistance),\(UserManager.getUserActivityDistance())"
        //        content.sound = UNNotificationSound.default
        //        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        //        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
        //        // Schedule the notification.
        //        let center = UNUserNotificationCenter.current()
        //        center.add(request)
    }
    
     // MARK: Function to get
    @objc func updateCounter() {
        //        print("timer working")
        // Calculate total time since timer started in seconds
        //        print("startTime in timer is ---------------- \(startTime)")
        //        print("current time is ------------- \(Date().timeIntervalSinceReferenceDate)")
        time = Date().timeIntervalSinceReferenceDate - startTime
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
        durationLabel.text = "\(strHours):\(strMinutes):\(strSeconds)"
        self.activityData.duration = durationLabel.text
        self.activityData.time = time
        self.activityData.categoryType = self.categoryType
        self.activityData.totalTime = self.totalTime
        let result = (self.metricValueLabel.text ?? "").filter("0123456789.".contains)
        
        if let distance = Double(result) {
            self.activityData.distance = distance
        }
        //        print("saving start time in defaults =========== \(self.activityData.startTime)")
        self.activityData.saveEncodedInformation()
    }
    
    /// set the updated calories count
    @objc func updateCaloriesCount() {
        //calculate calories
        print("Tme---->\(time)")
        self.totalCalories = calculateCalories(calories: nil, duration: self.totalTime, metValue: self.activityData.activity?.metValue) ?? 0
        self.caloriesLabel.text = "\(totalCalories.rounded(toPlaces: 2))"
    }
    
     // MARK: Method wil be use to invalidate the timer.
    private func invalidateTimer() {
        self.distanceTimer?.invalidate()
        self.timer?.invalidate()
        self.caloriesTimer?.invalidate()
    }
    
    func createActivitySummaryObject(steps:Double,calories:Double, isFromCounterpartApp: Bool? = false) -> UserActivity {
        let objUserActivity = UserActivity()
        objUserActivity.image = self.activityData.activity?.image ?? ""
        objUserActivity.name = self.activityData.activity?.name ?? ""
        objUserActivity.steps = steps
        if isFromCounterpartApp != nil {
            //this is called when activity is stopped on watch
            objUserActivity.calories = calories
        } else {
            objUserActivity.calories = self.calculateCalories(calories: calories, duration: self.totalTime, metValue: self.activityData.activity?.metValue)
        }
        objUserActivity.distance = self.totalDistance
        objUserActivity.duration = self.durationLabel.text?.trim
        objUserActivity.timeSpent = self.totalTime
        objUserActivity.type = self.activityData.activity?.activityType
        objUserActivity.selectedActivityType = self.activityData.activity?.selectedActivityType
        return objUserActivity
    }
    
    //returns the activity object for Summary
    func activitySummaryFor(activity: CombinedActivity) -> UserActivity {
        let summary = UserActivity()
        if let activityInfo = activity.activityData?.activity {
            summary.name = activityInfo.name
            summary.type = activityInfo.activityType
            summary.selectedActivityType = activityInfo.selectedActivityType
            summary.image = activityInfo.image
        }
        summary.steps = activity.steps
        summary.calories = self.calculateCalories(calories: activity.calories, duration: activity.duration, metValue: activity.activityData?.activity?.metValue)
        summary.distance = activity.distance
        summary.timeSpent = activity.duration
        summary.endTimestamp = Double(Date().timeStamp)
        return summary
    }
    @IBAction func stopResumeTapped(_ sender: UIButton) {
        outerView.isHidden = false
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        outerView.isHidden = true
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if isFromDashBoard{
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomePageViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        if !self.isConnectedToNetwork() {
            AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet)
            //self.showAlert(message:AppMessages.AlertTitles.noInternet)
            return
        }
        self.pauseActivityBeforeShowingAlert()
        //ask for user confirmation before stopping the activity
        self.showAlert(withTitle: "", message: AppMessages.GroupActivityMessages.sureToStopActivity, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
            self.activityPausedState = .activityTerminated
            //self.distance += self.tempDistance
            //self.saveDatesData()
            //self.invalidateTimer()
            //self.honeyCombView.stopViewRotation()
            
            //Initial
            /*self.showLoader()
             self.activityData.currentPeriodStartingDate = Date()
             self.activityData.saveEncodedInformation()
             self.count = 0
             self.getDataForTimeInterval()
             */
            appDelegate.stopLocation()
            //New
//            self.showLoader()
            self.activityData.saveEncodedInformation()//-----Newly added
            self.fetchCurrentActivityFinalData()
            
        }, cancelCall: {
            //            if let isPlaying = self.activityData.isPlaying {
            //                if !isPlaying {
            //                    //resume animation and start timer again
            //                    self.start(changeStartTime: false)
            //                    self.honeyCombView.restartAnimation()
            //                }
            //            }
            self.resumeActivityOnAlertDismiss()
        })
        
        /* self.distance += self.tempDistance
         self.saveDatesData()
         self.invalidateTimer()
         self.honeyCombView.stopViewRotation()
         self.showLoader()
         self.activityData.currentPeriodStartingDate = Date()
         self.activityData.saveEncodedInformation()
         self.count = 0
         self.getDataForTimeInterval() */
    }
    
    private func fetchCurrentActivityFinalData() {
        self.activityData.currentPeriodStartingDate = Date()
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        self.count = 0
        self.getDataForTimeInterval()
    }
    
    ///pause the activity before presenting the alert on screen
    private func pauseActivityBeforeShowingAlert() {
        if let isPlaying = self.activityData.isPlaying {
            if isPlaying {
                self.activityPausedDueToAlert = true
                /* self.stopSimpleTimerOnly()
                 self.honeyCombView.stopViewRotation() */
                //                self.honeyCombView.stopViewRotation()
                self.stopAnimation = true
                self.stopViewRotation()
                self.stopAndStartActivity()
            } else {
                self.activityPausedDueToAlert = false
            }
        }
    }
    
    ///resume the activity after the alert is dismissed on its negative action
    private func resumeActivityOnAlertDismiss() {
        if self.activityPausedDueToAlert == true {
            //if this was paused due to the alert presented on screen, resume this activity again
            self.activityData.isPlaying = true
            self.stopAnimation = false
            self.startViewRotation()
            //            self.stopAnimation = false
            //            self.honeyCombView.restartAnimation()
            //self.stopAndStartActivity()
            self.activityData.saveEncodedInformation()
            self.saveDataToDefaults()
            self.runTimer()
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
    
    func serializeDistanceTuple(tuples: [AccessTuple]) -> [AccessDistance] {
        var array : [AccessDistance] = [AccessDistance]()
        for (_,data) in tuples.enumerated() {
            array.append([
                distanceKey : data.distance
            ])
        }
        return array
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
}

extension ActivityProgressController : ActivityProgressDelegate {
    func stopAndStartActivity() {
        if let state = self.activityData.isPlaying {
            self.activityData.isPlaying = !state
            if state {
                appDelegate.stopLocation()
            } else {
                if let activityType = self.activityData.activity?.selectedActivityType,
                   let type = ActivityMetric(rawValue: activityType),
                   type == .distance {
                    appDelegate.startLocation()
                }
                //TravelDistanceManager.shared.start()
            }
        } else {
            self.activityData.isPlaying = false
        }
        
        self.activityData.saveEncodedInformation()
        self.saveDataToDefaults()
        self.runTimer()
        
        //update to watch app
        self.changeActivityStateOnWatchApp()
    }
    
    private func changeActivityStateOnWatchApp() {
        var inprogressState = InProgressActivityState()
        inprogressState.totalTime = self.totalTime
        inprogressState.duration = self.activityData.duration
        inprogressState.elapsed = self.activityData.elapsed
        inprogressState.isPlaying = self.activityData.isPlaying
        inprogressState.stateChangeTime = Date().timeIntervalSinceReferenceDate
        do {
            let encodedData = try JSONEncoder().encode(inprogressState)
            let data: [String: Any] = ["request": MessageKeys.activityStateChangedOnPhone,
                                       "data": encodedData]
            Watch_iOS_SessionManager.shared.updateApplicationContext(data: data)
        } catch { }
    }
    
    /// update the activity complete status to watch app
    /// - Parameter params: this will hold the current activity data
    /// - Parameter additionalActivitiesData: this will hold the additional activities data
    func updateToWatch(params: Parameters, additionalActivitiesData: [CombinedActivity]?) {
        var data: [String: Any] = ["request": MessageKeys.activityStoppedOnPhone]
        
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
            if let activityData = additionalActivitiesData {
                let encodedCombinedActivityData = try JSONEncoder().encode(activityData)
                data[MessageKeys.additionalActivityDataFromOtherDevice] = encodedCombinedActivityData
            }
            data[MessageKeys.completedActivityDataFromOtherDevice] = encodedData
        } catch {
            //
        }
        Watch_iOS_SessionManager.shared.updateApplicationContext(data: data)
    }
    
    private func saveDataToDefaults() {
        //        print("SAVE DATA TO DEFAULTS")
        do {
            let data =  try JSONEncoder().encode(self.activityData)
            let userActivityData = try JSONEncoder().encode(self.activityData.activity)
            
            //in iPhone app
            Defaults.shared.set(value: data, forKey: .userActivityInProgress)
            
            //in watch
        //    let infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
//                                                 "request": MessageKeys.updateActivityData,
//                                                 MessageKeys.userActivityData: userActivityData]
            // Watch_iOS_SessionManager.shared.updateApplicationContext(data: infoDictToPass)
        } catch (_) {
            //            print(error)
        }
    }
}

