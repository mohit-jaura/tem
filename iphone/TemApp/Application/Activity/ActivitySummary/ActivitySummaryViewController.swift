//
//  ActivitySummaryViewController.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ActivitySummaryViewController: DIBaseController {
    
    // MARK: Variables.
    /// This is the view model which represents the user representation of the UserActivity
    private struct ActivityViewModel {
        var name: String?
        var image: String?
        var distOrTimMeasure: String?
        var calories: String?
        var duration: String?
        var imageUrl: URL?
        
        
        
        
        init(activity: UserActivity) {
            self.name = activity.name
            self.image = activity.image
            if let activityType = activity.type {
                
                let selectedActivityType = activity.selectedActivityType ?? 1
                if selectedActivityType == ActivityMetric.distance.rawValue {
                    if activityType == ActivityMetric.distance.rawValue || activityType == ActivityMetric.none.rawValue {
                        if let distance = activity.distance,
                            let duration = activity.timeSpent {
                            let timeInMinutes = duration/60
                            if distance > timeInMinutes {
                                //display distance
                                self.distOrTimMeasure = "\(distance.rounded(toPlaces: 2)) Miles"
                            } else {
                                self.distOrTimMeasure = "\(self.activityTime(activity: activity) ?? "") hrs"
                            }
                        }
                    } else {
                         self.distOrTimMeasure = "\(self.activityTime(activity: activity) ?? "") hrs"
                    }
                } else {
                     self.distOrTimMeasure = "\(self.activityTime(activity: activity) ?? "") hrs"
                }
            }
            self.duration = self.activityTime(activity: activity)
            self.calories = "\(activity.calories?.rounded(toPlaces: 2) ?? 0.0) Calories"
            if let url = URL(string: activity.image ?? "") {
                self.imageUrl = url
            }
        }
        
        func activityTime(activity: UserActivity) -> String? {
            if let time = activity.timeSpent?.toInt() {
                let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: time)
                let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                //self.distOrTimMeasure = "\(displayTime) hrs"
                return displayTime
            }
            return nil
        }
    }
    var params = [[String: Any]]()
    var isComingFromActivityEvent : Bool = false
    var categoryType: ActivityCategoryType.RawValue = ActivityCategoryType.mentalStrength.rawValue
    var rightInset: CGFloat = 7
    var activityId : Int?
    var selectedRateActivityNumber = 1
    var summaryData: [UserActivity] = [UserActivity]()
    var screenFrom: Constant.ScreenFrom = Constant.ScreenFrom.activity
    var isFromDashBoard:Bool = false // Indicates that the activity was added earlier or not
    var isTabbarChild = false
    var navBar: NavigationBar?
    
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    private var activityName: String {
        let test = summaryData.compactMap({$0.name}).joined(separator: ", ")
        return test
    }
    
    var activityLogAlreadyAdded:Bool = false
    var activityLogData:[String:Any] = [:]
    var allActivities : [ActivityData]?
    var activityEventId:String = ""

    // MARK: IBOutlets
    @IBOutlet weak var activityNewsFeedImageView: UIImageView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var newsFeedLogoImageView: UIImageView!
    @IBOutlet weak var activityNewsNameLabel: UILabel!
    @IBOutlet weak var activityNewsFeedStatusLabel: UILabel!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet var newsFeedView: UIView!
    @IBOutlet weak var activity1View: UIView!
    @IBOutlet weak var activity2View: UIView!
    @IBOutlet weak var activity3View: UIView!
    @IBOutlet weak var activity1NameLabel: UILabel!
    @IBOutlet weak var activity1DistOrTimeLabel: UILabel!
    @IBOutlet weak var activity1CalLabel: UILabel!
    @IBOutlet weak var activity2Label: UILabel!
    @IBOutlet weak var activity2TimeLabel: UILabel!
    @IBOutlet weak var activity2CalLabel: UILabel!
    @IBOutlet weak var activity3NameLabel: UILabel!
    @IBOutlet weak var activity3TimeLabel: UILabel!
    @IBOutlet weak var activity3CalLabel: UILabel!
    
    //Metrics data outlets
    @IBOutlet weak var totalTimeValueLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var caloriesValueLabel: UILabel!
    @IBOutlet weak var distanceTitleLabel: UILabel!
    
    //NEW Outlets
    @IBOutlet weak var distanceNewsFeedImageView: UIImageView!
    @IBOutlet weak var postActivityButton: UIButton!
    @IBOutlet weak var newActivityButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var summaryDistanceTitleLabel: UILabel!
    @IBOutlet weak var temLogoImageView: UIImageView!
    @IBOutlet weak var distanceImageView: UIImageView!
    @IBOutlet weak var summaryCaloriesLabel: UILabel!
    @IBOutlet weak var sumaryDistanceValueLabel: UILabel!
    @IBOutlet weak var hexagonsBackgroundView: UIView!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var rateActivityView: UIView!
    @IBOutlet weak var rateActivityCompleteButton: UIButton!
    @IBOutlet weak var badActivityButton: UIButton!
    @IBOutlet weak var poorActivityButton: UIButton!
    @IBOutlet weak var averageActivityButton: UIButton!
    @IBOutlet weak var goodActivityButton: UIButton!
    @IBOutlet weak var greatActivityButton: UIButton!
    @IBOutlet weak var activityLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shadowView: SSNeumorphicView!{
        didSet{
            shadowView.viewDepthType = .innerShadow
            shadowView.viewNeumorphicMainColor = viewBackgroundColor.cgColor
            self.shadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            self.shadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(1).cgColor
            shadowView.viewNeumorphicCornerRadius = 9
            shadowView.viewNeumorphicShadowRadius = 3
            shadowView.borderWidth = 0
        }
    }
    // MARK: IBActions
    @IBAction func menuTapped(_ sender:UIButton){
        let checkListSideMenu:RoundChecklistSideMenuViewController = UIStoryboard(storyboard: .createevent).initVC()
        checkListSideMenu.eventId = activityEventId
        self.navigationController?.present(checkListSideMenu, animated: true)
    }
    @IBAction func newActivityTapped(_ sender: UIButton) {
        let selectedVC:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
        selectedVC.isFromDashBoard = self.isFromDashBoard
        self.isFromDashBoard = false
        selectedVC.isTabbarChild = self.isTabbarChild
        if !activityLogAlreadyAdded{
            createActivitiesLog()
        }
        DispatchQueue.main.async {
            //self.navigationController?.pushViewController(selectedVC, animated: true)
            //self.removeCurrentControllerFromStack()
            if self.isTabbarChild {
                self.navigationController?.viewControllers = [selectedVC]
            } else {
                if let activityController = self.navigationController?.viewControllers.first {
                    self.navigationController?.popToViewController(activityController, animated: true)
                }
            }
        }
    }
    func rateActivity(){
        let params = RateActivity(id: activityId ?? 0, rating: selectedRateActivityNumber)
        guard Reachability.isConnectedToNetwork() else {
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
            return
        }
        showLoader()
        DIWebLayerActivityAPI().rateActivity(parameters: params.getDictionary(), success: { _ in
            self.hideLoader()
            
        }, failure: {error in
            print("\(error)")
            self.hideLoader()
        })
    }
    
    func createActivitiesLog(){
        if !isComingFromActivityEvent {
        activityLogData["steps"] = String(describing: summaryData[0].steps?.rounded(toPlaces:2) ?? 0.0)
        activityLogData["rating"] = selectedRateActivityNumber
        activityLogData["categoryType"] = String(describing: categoryType)
        activityLogData["distanceCovered"] = self.summaryData[0].distance
        activityLogData["timeSpent"] = self.summaryData[0].timeSpent
        activityLogData["calories"] = self.summaryData[0].calories
//        activityLogData["activityId"] = self.summaryData[0].id
//        activityLogData["activityType"] = self.summaryData[0].type
    //    let params = activityLogData
        showLoader()
            guard Reachability.isConnectedToNetwork() else {
                self.hideLoader()
                self.showAlert(message: AppMessages.AlertTitles.noInternet)
                return
            }
//     let params: [String: Any] = ["activities": [activityLogData]]
//        var params2: [String: Any] = [:]
////        params2["id"] = self.summaryData[0].id
//        params2["activityId"] = self.summaryData[0].id
//        params2["distanceCovered"] = self.summaryData[0].distance
//        params2["timeSpent"] = self.summaryData[0].timeSpent
//        params2["calories"] = self.summaryData[0].calories
//        params2["activityName"] = self.summaryData[0].name
        let params3: [String: Any] = ["activities": [self.activityLogData]]
        DIWebLayerActivityAPI().completeActivity(parameters: params3, success: { (_) in
                    self.hideLoader()
            self.activityLogAlreadyAdded = true
                }, failure: { (_) in
                    self.hideLoader()
                })
        }
    }
    
    
    @IBAction func rateActivityCompleteButton(_ sender: UIButton) {
       
            //API Call
           rateActivity()
          self.hideLoader()
            rateActivityView.isHidden = true
        if !activityLogAlreadyAdded{
            createActivitiesLog()
        }
    }
    @IBAction func rateActivityButtonsTapped(_ sender: UIButton) {
        rateActivityCompleteButton.isEnabled = true
        switch sender.tag{
        case 1:
            configureRateActivityLayouts(selectedButton: badActivityButton, unselectedButtons: [goodActivityButton,poorActivityButton,averageActivityButton,greatActivityButton])
        case 2:
            configureRateActivityLayouts(selectedButton: poorActivityButton, unselectedButtons: [goodActivityButton,badActivityButton,averageActivityButton,greatActivityButton])
        case 3:
            configureRateActivityLayouts(selectedButton: averageActivityButton, unselectedButtons: [goodActivityButton,poorActivityButton,badActivityButton,greatActivityButton])
        case 4:
            configureRateActivityLayouts(selectedButton: goodActivityButton, unselectedButtons: [badActivityButton,poorActivityButton,averageActivityButton,greatActivityButton])
        case 5:
            configureRateActivityLayouts(selectedButton: greatActivityButton, unselectedButtons: [goodActivityButton,poorActivityButton,averageActivityButton,badActivityButton])
        default:
            break
        }
        selectedRateActivityNumber = sender.tag
    }
    @IBAction func rateActivityTapped(_ sender: UIButton) {
        rateActivityView.isHidden = false
    }
    @IBAction func dismissRateActivityTapped(_ sender: UIButton) {
        self.rateActivityView.isHidden = true
    }
    @IBAction func shareActivityTapped(_ sender: UIButton) {
        self.shareActivity()
        if !activityLogAlreadyAdded && !isComingFromActivityEvent{
            createActivitiesLog()
        }
    }
    
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        if isFromDashBoard || isComingFromActivityEvent{
            let homePageVC:HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
            appDelegate.setNavigationToRoot(viewContoller: homePageVC)
        }else if screenFrom == .event{
            Defaults.shared.set(value: true, forKey: .programEvent)
            
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: EventDetailViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }else{
            appDelegate.popToRootViewController()
        }
     
        if !activityLogAlreadyAdded{
            createActivitiesLog()
        }
    }
    @IBAction func editTapped(_ sender: UIButton) {
        if summaryData.count == 1,
           let activity = summaryData.first {
            if (activity.origin != ActivityOrigin.TEM.rawValue) {
                self.showAlert(withTitle: "", message: AppMessages.GroupActivityMessages.editExternalActivity, okayTitle: "Yes", cancelTitle: "No", okCall:  {
                    self.openEditActivity(activity)
                })
            }
            else {
                self.openEditActivity(activity)
            }
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    func configureRateActivityLayouts(selectedButton: UIButton, unselectedButtons: [UIButton]){
        selectedButton.setImage(UIImage(named: "selectActivity"), for: .normal)
        for button in unselectedButtons{
            button.setImage(UIImage(named: "Rate Your wellness unselect"), for: .normal)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.addGradient()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isComingFromActivityEvent {
            self.addBadgeObserver()
            self.configureNavBar()
            self.getUnreadNotificationsCount()
            Defaults.shared.remove(.isActivityRemoved)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeBadgeObserver()
    }
    
    // MARK: Initializer
    private func configureNavBar() {
        editButton.isHidden = true
     //   if screenFrom != .event{
            if summaryData.count == 1 {
                //    rightButtons = [.editWhite]
                editButton.isHidden = false
            }
      //  }
        self.updateBadge()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func navigationBar(_ navigationBar: NavigationBar, leftButtonTapped leftButton: UIButton) {
        guard !isTabbarChild else {
            self.presentSideMenu()
            return
        }
        if let tabBarController = self.navigationController?.findController(controller: TabBarViewController.self) {
            if (tabBarController.viewControllers?.first as? DashboardViewController) != nil {
                self.navigationController?.popToViewController(tabBarController, animated: true)
            }
        } else {
            //pop to the last view controller
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func navigationBar(_ navigationBar: NavigationBar, rightButtonTapped rightButton: UIButton) {
        if summaryData.count == 1,
           let activity = summaryData.first {
            if (activity.origin != ActivityOrigin.TEM.rawValue) {
                self.showAlert(withTitle: "", message: AppMessages.GroupActivityMessages.editExternalActivity, okayTitle: "Yes", cancelTitle: "No", okCall:  {
                    self.openEditActivity(activity)
                })
            }
            else {
                self.openEditActivity(activity)
            }
        }
    }
    
    private func openEditActivity(_ activity: UserActivity) {
        let activityEditController: ActivityEditController = UIStoryboard(storyboard: .activityedit).initVC()
        activityEditController.activityData = activity
        activityEditController.categoryType = categoryType
        activityEditController.onUpdate = {
            self.setActivityDisplayData()
        }
        navigationController?.pushViewController(activityEditController, animated: true)
    }
    
    private func initUI() {
        if  isComingFromActivityEvent {
            initialiseEventActivityAddOn()
        }else {
            
            //hide the new activity button
            self.newActivityButton.isHidden = self.screenFrom == .totalActivities
        self.activityNameLabel.text = self.activityName.uppercased()
   //     self.activityIconImageView.image = #imageLiteral(resourceName: "activity")
        
        if summaryData.count == 1 {
            if let origin = self.summaryData.first?.origin,
               origin != ActivityOrigin.TEM.rawValue {
                originLabel?.text = origin
                originLabel?.isHidden = false
            }
            else {
                originLabel?.isHidden = true
                originLabel?.text = ""
            }
        }
        else {
            originLabel?.isHidden = true
            originLabel?.text = ""
        }
       // self.activityIconImageView.setImageColor(color: UIColor.white)
        self.setActivityDisplayData()
        self.setEachActivityDataInNewsFeedView()
        }
//        if screenFrom == .event{
//            editButton.isHidden = true
//            menuButton.isHidden = false
//        }else{
            editButton.isHidden = false
            menuButton.isHidden = true
    //    }
        
      //  (cornerRadius: searchButton.frame.height / 2, shadowRadius: searchButton.frame.height / 2, lightShadowColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3), shadowBackgroundColor: #colorLiteral(red: 0.2485005558, green: 0.5230822563, blue: 0.8664022088, alpha: 1))
        
        
            editButton.addDoubleShadowToButton(cornerRadius: editButton.frame.height / 2, shadowRadius: editButton.frame.height / 2, lightShadowColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4), darkShadowColor: #colorLiteral(red: 1, green:1, blue: 1, alpha: 0.4), shadowBackgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        

       
    }
    func isDistanceActivityFound() -> Bool{
        let completedActivities = allActivities?.filter({$0.status == ActivityStatus.Completed.rawValue})

       return  (completedActivities?.filter({$0.activityType == ActivityMetric.distance.rawValue || $0.activityType == ActivityMetric.none.rawValue}).count ?? 0) > 0

    }
    func initialiseEventActivityAddOn() {
        editButton.isHidden = true
        menuButton.isHidden = true
        newActivityButton.isHidden = true
        rateActivityCompleteButton.isHidden = true
        
        let completedActivities = allActivities?.filter({$0.status == ActivityStatus.Completed.rawValue})
        
        let isDistance = (completedActivities?.filter({$0.activityType == ActivityMetric.distance.rawValue || $0.activityType == ActivityMetric.none.rawValue}).count ?? 0) > 0
        
        let names:[String] = completedActivities?.map({return $0.name ?? ""}) ?? []
        let totalCalories = completedActivities?.map({return $0.calories ?? 0.0}).reduce(0.0, +)
        let totalDistance = completedActivities?.map({return $0.distanceCovered ?? 0.0}).reduce(0.0, +)
        let totalSteps = completedActivities?.map({return $0.steps ?? 0.0}).reduce(0.0, +)
        let totalTime = completedActivities?.map({return $0.timeSpent ?? 0.0}).reduce(0.0, +)
        
        debugPrint("Total time \(totalTime)")
        debugPrint("Total calories \(totalCalories)")
        debugPrint("All Names \(names.joined(separator: ","))")
        self.activityNameLabel.text = (names.joined(separator: ",")).uppercased()
        
        let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: Int(totalTime ?? 0))
        
        let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
        
        self.durationLabel.text = "\(displayTime)"
        
        self.summaryDistanceTitleLabel.text = "\((totalDistance ?? 0.0).rounded(toPlaces: 2))"
                
        self.summaryCaloriesLabel.text = "\((totalCalories ?? 0.0).rounded(toPlaces: 2))"
        
        //set total distance
        if isDistance {
            self.temLogoImageView.isHidden = true
        } else {
            self.summaryDistanceTitleLabel.isHidden = true
            self.sumaryDistanceValueLabel.isHidden = true
            distanceImageView.isHidden = true
            self.temLogoImageView.isHidden = true
        }
        setNewsFeedData()
    }

    //add gradient to the action buttons
    private func addGradient() {
    /*    let gradientColors = [UIColor(red: 11/255, green: 50/255, blue: 81/255, alpha: 1.0).cgColor, UIColor(red: 20/255, green: 95/255, blue: 153/255, alpha: 1.0).cgColor, UIColor.appThemeColor.cgColor, UIColor(red: 20/255, green: 95/255, blue: 153/255, alpha: 1.0).cgColor, UIColor(red: 11/255, green: 50/255, blue: 81/255, alpha: 1.0).cgColor]
        let locations: [NSNumber] = [0.0, 0.2, 0.6, 0.8]
        self.newActivityButton.applyGradient(inDirection: .leftToRight, colors: gradientColors, locations: locations)
        self.postActivityButton.applyGradient(inDirection: .leftToRight, colors: gradientColors, locations: locations)
        self.homeButton.applyGradient(inDirection: .leftToRight, colors: gradientColors, locations: locations)*/
    }
    
    // MARK: Api Call
    @objc func getUnreadNotificationsCount() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count,_) in
            self.navBar?.displayBadge(unreadCount: count)
        }
    }
    
    @objc func updateBadge() {
        self.navBar?.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
    }
    
    // MARK: Notification observers
    private func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUnreadNotificationsCount), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    // MARK: Helpers
    private func setActivityDisplayData() {
        //set total time
        let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: self.totalTime())
        
        let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
        self.durationLabel.text = "\(displayTime)"
        
        //set total calories
        self.summaryCaloriesLabel.text = "\(self.totalCalories().rounded(toPlaces: 2))"
        
        //set total distance
        if self.totalDistanceActivities().count > 0 {
            self.temLogoImageView.isHidden = true
            sumaryDistanceValueLabel.text = "\(self.totalDistance().rounded(toPlaces: 2))"
        } else {
            self.summaryDistanceTitleLabel.isHidden = true
            self.sumaryDistanceValueLabel.isHidden = true
            distanceImageView.isHidden = true
            self.temLogoImageView.isHidden = true
        }
    }
    
    private func shareActivity() {
        self.setNewsFeedData()
        if let screenshot = self.newsFeedView.screenshot() { // get screenshot
            let image = resizedImage(at: screenshot, for: CGSize(width:Constant.ScreenSize.IPHONE_MAX_WIDTH, height: screenshot.size.height+(screenshot.size.height*0.10)))
            let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()
            createPostVC.type = .activity
            createPostVC.isFromActivityLog = true
            createPostVC.screenshot = UIScreen.main.bounds.width < Constant.ScreenSize.IPHONE_MAX_WIDTH ? image : screenshot
            createPostVC.isComingFromActivity = true
            createPostVC.isFromDashBoard = true
            self.isFromDashBoard = false
            self.navigationController?.pushViewController(createPostVC, animated: true)
        }
    }
    
    
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (_) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// returns the total distance by adding distance in each UserActivity object
    ///
    /// - Returns: total distance
    private func totalDistance() -> Double {
        let distanceActivities = self.totalDistanceActivities()
        let distance = distanceActivities.compactMap({$0.distance}).reduce(0, {$0 + $1})
        return distance
    }
    
    /// return the total number of distance type activities
    private func totalDistanceActivities() -> [UserActivity] {
        let distanceActivities = self.summaryData.filter { (activity) -> Bool in
            //parent distance
            //goal: either distance or open
            let selectedActivityType = activity.selectedActivityType ?? 1
            if let type = activity.type {
                if selectedActivityType == ActivityMetric.distance.rawValue {
                    if type == ActivityMetric.distance.rawValue || type == ActivityMetric.none.rawValue {
                        return true
                    }
                }
            }
            return false
        }
        return distanceActivities
    }
    
    /// returns the total time by adding time in each UserActivity object
    ///
    /// - Returns: total time
    private func totalTime() -> Int {
        let time = self.summaryData.compactMap({$0.timeSpent?.toInt()}).reduce(0, {$0 + $1})
        return time
    }
    
    /// returns the total calories by adding calories in each UserActivity object
    ///
    /// - Returns: total calories
    private func totalCalories() -> Double {
        let total = self.summaryData.compactMap({$0.calories}).reduce(0, {$0 + $1})
        return total
    }
    
    // MARK: Screenshot view configuration
    //set news feed screenshot view data
    private func setNewsFeedData() {
        
        if self.summaryData.count > 1 || self.allActivities?.count ?? 0 > 1 {
            self.activityNewsNameLabel.text = "Other"
        } else {
            self.activityNewsNameLabel.text = isComingFromActivityEvent ? self.allActivities?.first?.name ?? "" : self.summaryData.first?.name ?? ""
        }
     /*  self.activityNewsFeedImageView.image = #imageLiteral(resourceName: "activity")
        if summaryData.count == 1 {
            if let imageUrl = URL(string:self.summaryData.first?.image ?? "") {
                self.activityNewsFeedImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "activity"), options: nil, progressBlock: nil) { (result) in
                    self.activityNewsFeedImageView.setImageColor(color: appThemeColor)
                }
            }
        }*/
        let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: self.totalTime())
        
        let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
        
        self.totalTimeValueLabel.text = isComingFromActivityEvent ? self.durationLabel.text : "\(displayTime)"
        
        self.caloriesValueLabel.text = isComingFromActivityEvent ? self.summaryCaloriesLabel.text : "\(self.totalCalories().rounded(toPlaces: 2))"

        
            if let activityType = self.summaryData.first?.type {
                if activityType == ActivityMetric.distance.rawValue || activityType == ActivityMetric.none.rawValue {
                    self.distanceValueLabel.text = "\(self.totalDistance().rounded(toPlaces: 2))"
                    self.newsFeedLogoImageView.isHidden = true
                    self.distanceTitleLabel.isHidden = false
                } else {
                    self.distanceValueLabel.isHidden = true
                    distanceNewsFeedImageView.isHidden = true
                    self.distanceTitleLabel.isHidden = true
                    self.newsFeedLogoImageView.isHidden = true
                }
            }else if isComingFromActivityEvent{
                self.distanceValueLabel.text = summaryDistanceTitleLabel.text
                if isDistanceActivityFound() {
                self.newsFeedLogoImageView.isHidden = true
                self.distanceTitleLabel.isHidden = false
            } else {
                self.distanceValueLabel.isHidden = true
                distanceNewsFeedImageView.isHidden = true
                self.distanceTitleLabel.isHidden = true
                self.newsFeedLogoImageView.isHidden = true
                
            }

       // self.activityNewsFeedImageView.setImageColor(color: appThemeColor)
        //self.setEachActivityDataInNewsFeedView()
    }
    }
    private func setEachActivityDataInNewsFeedView() {
        let count = isComingFromActivityEvent ? allActivities?.count : summaryData.count
        switch count {
        case 1:
            self.activity1View.isHidden = true
            self.activity2View.isHidden = true
            self.activity3View.isHidden = true
        case 2:
            self.setActivity1ScreenshotData()
            self.setActivity2ScreenshotData()
            self.activity3View.isHidden = true
        default:
            self.setActivity1ScreenshotData()
            self.setActivity2ScreenshotData()
            self.setActivity3ScreenshotData()
        }
    }
    
    //setting the data for the multiple activities for news feed
    private func setActivity1ScreenshotData() {
        if isComingFromActivityEvent {
            let first = allActivities?.first
            activity1NameLabel.text = first?.name
            activity1DistOrTimeLabel.text = distanceOrTime(first)
            activity1CalLabel.text = "\(first?.calories ?? 0.0)"

        }else {
            let viewModel = ActivityViewModel(activity: summaryData[0])
            activity1NameLabel.text = viewModel.name
            activity1DistOrTimeLabel.text = viewModel.distOrTimMeasure
            activity1CalLabel.text = viewModel.calories

        }
    }
    func distanceOrTime(_ activity:ActivityData?) -> String {
        if activity?.activityType == ActivityMetric.distance.rawValue || activity?.activityType == ActivityMetric.none.rawValue {
        
                    if let distance = activity?.distanceCovered,
                        let duration = activity?.timeSpent {
                        let timeInMinutes = duration/60
                        if distance > timeInMinutes {
                            //display distance
                            return "\(distance.rounded(toPlaces: 2)) Miles"
                        } else {
                            return "\(self.activityTime(activity) ?? "") hrs"
                        }
                    }
                } else {
                    return "\(self.activityTime( activity) ?? "") hrs"
                }
            return ""
            }
    
    func activityTime(_ activity:ActivityData?) -> String? {
        if let time = activity?.timeSpent?.toInt() {
            let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: time)
            let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
            //self.distOrTimMeasure = "\(displayTime) hrs"
            return displayTime
        }
        return ""
    }
    
    private func setActivity2ScreenshotData() {
        if isComingFromActivityEvent {
            if allActivities?.count ?? 0 > 1 {
                let sec = allActivities?[1]
                activity1NameLabel.text = sec?.name
                activity1DistOrTimeLabel.text = distanceOrTime(sec)
                activity1CalLabel.text = "\(sec?.calories ?? 0.0)"
            }
        }else {
            let viewModel = ActivityViewModel(activity: summaryData[1])
            activity2Label.text = viewModel.name
            activity2TimeLabel.text = viewModel.distOrTimMeasure
            activity2CalLabel.text = viewModel.calories

        }
    }
    
    private func setActivity3ScreenshotData() {
        if isComingFromActivityEvent {
            if allActivities?.count ?? 0 > 2 {
                let third = allActivities?[2]
                activity1NameLabel.text = third?.name
                activity1DistOrTimeLabel.text = distanceOrTime(third)
                activity1CalLabel.text = "\(third?.calories ?? 0.0)"
            }
        }else {
            let viewModel = ActivityViewModel(activity: summaryData[2])
            activity3NameLabel.text = viewModel.name
            activity3TimeLabel.text = viewModel.distOrTimMeasure
            activity3CalLabel.text = viewModel.calories

        }
    }
    
    private func setActivityDataAt(index: Int, nameLabel: UILabel, imageView: UIImageView, durationLabel: UILabel, calLabel: UILabel) {
        let viewModel = ActivityViewModel(activity: summaryData[index])
        nameLabel.text = viewModel.name
        calLabel.text = viewModel.calories
        durationLabel.text = viewModel.distOrTimMeasure//viewModel.duration
        imageView.image = #imageLiteral(resourceName: "activity")
        imageView.kf.setImage(with: viewModel.imageUrl, placeholder: #imageLiteral(resourceName: "activity"), options: nil, progressBlock: nil) { (_) in
            imageView.setImageColor(color: UIColor.textBlackColor)
        }
    }
}
