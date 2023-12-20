//
//  ActivityContoller.swift
//  TemApp
//
//  Created by Harpreet_kaur on 19/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Foundation
import SSNeumorphicView

struct RatingData: Codable{
    var id: String?
    var rating: Int?
    
    enum CodingKeys: String,CodingKey {
        case id = "_id"
        case rating
    }
}
enum ActivityCategoryType: Int, CaseIterable {
    case mentalStrength = 1
    case physicalFitness = 2
    case nutritionAwareness = 3
    case sports = 4
    case lifestyle = 5
    
}

extension UIViewController {
    func removeCurrentControllerFromStack() {
        var allViewControllers = self.navigationController?.viewControllers
        allViewControllers = allViewControllers?.filter({ ($0) as AnyObject !== (self) as AnyObject })
        if let allViewControllers = allViewControllers {
            self.navigationController?.viewControllers = allViewControllers
        }
    }
    
    func redirectToActivityController() {
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool {
            if  isActivity == true {
                return
            }
        }
        let selectedVC:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
        selectedVC.isFromDashBoard = true
        self.navigationController?.pushViewController(selectedVC, animated: true)
        self.removeCurrentControllerFromStack()
    }
}

class ActivityContoller: DIBaseController {
    
    // MARK: Variables.
    private var refreshControl: UIRefreshControl?
    var allActivities:[ActivityCategory]?
    var activityArray:[ActivityData] = []
    var durationList:[MetricValue] = []
    var distanceList:[MetricValue] = []
    var metricArray:[ActivityMetric] = []
    var currentField:ActivityFields = .activity
    var objCreateActivity = CreateActivity()
    var selectedActivity:ActivityData = ActivityData()
    var isFromDashBoard:Bool = true
    var isPageViewChild: Bool = true
    var writeDataCounter = 0
    var isTabbarChild = false
    var screenFrom = Constant.ScreenFrom.activity
    var eventID:String?
    var performScheduledActivity = false
    final let accountbilityMissionPlaceholder:String = "Type your accountability mission here. This is your “why.” Why are you chosing to own your health and wellness journey?"
    private var navBar: NavigationBar?
    var isEditAble:Bool = false
    //for additional activity
    var combinedActivity: CombinedActivity?
    var activityState: ActivityPauseState = .none
    var combinedActivityEncodedData: Data?
    //    var activityState: ActivityPauseState = .none
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    var ratingData:RatingData?
    // MARK: IBOutlets.
    var activityCategoryDataType = -1
    var selectedRateActivityNumber:Int? = 0
    var selectedRatingImg = "selectActivity"
    let neumorphicShadow = NumorphicShadow()
    let activityViewModal = ActivitiesViewModal()
    var firstLoad: Bool = true
    @IBOutlet var ratingButtons: [UIButton]!
    
    @IBOutlet weak var physicalFitnessLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var sportsLabel: UILabel!
    @IBOutlet weak var lifestyleLabel: UILabel!

    @IBOutlet weak var accountabiltiyView: UIView!
    @IBOutlet weak var mentalStrengthLabel: UILabel!
    @IBOutlet weak var accountbilityMissionTextView: UITextView!
    @IBOutlet weak var mainView: SSNeumorphicView! 
    
    // MARK: ViewLifeCycle Functions.
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD")
//        getActivitiesFromRealm()
        initUI()
    }
    // MARK: Helper function
    func getGradientLayer(bounds : CGRect,colors: [Any]?) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors //
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addBadgeObserver()
        self.checkAlreadyRunningActivity()
        self.configureTabbar()
        self.getUnreadNotifcationsCount()
        self.navigationController?.navigationBar.isHidden = true
        self.getScheduledEventsStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeBadgeObserver()
    }
    @IBAction func saveRatingTapped(_ sender: UIButton) {
        if isEditAble {
            self.showLoader()
            self.callUpdateRatingAPI()
        } else {
            if selectedRateActivityNumber != nil{
                self.showLoader()
                self.saveRating()
            } else{
                self.showAlert(withTitle:AppMessages.RateDay.RatingMsg , message: AppMessages.RateDay.selectRating, okayTitle: AppMessages.CommanMessages.ok)
            }
        }
        
    }
    @IBAction func rateActivityButtonsTapped(_ sender: UIButton) {
        self.configureRateActivityLayouts(selectedButton: sender)
    }
    @IBAction func backButonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let addActivityVC: AddActivityViewController = UIStoryboard(storyboard: .activity).initVC()
        self.navigationController?.pushViewController(addActivityVC, animated: true)
    }
    @IBAction func activityFilterButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            activityCategoryDataType = ActivityCategoryType.physicalFitness.rawValue
            initiateApiCallsToGetData()
        case 2:
            activityCategoryDataType = ActivityCategoryType.nutritionAwareness.rawValue
            initiateApiCallsToGetData()
        case 3:
            activityCategoryDataType = ActivityCategoryType.sports.rawValue
            initiateApiCallsToGetData()
        case 4:
            activityCategoryDataType = ActivityCategoryType.lifestyle.rawValue
            initiateApiCallsToGetData()
        case 5:
            activityCategoryDataType = ActivityCategoryType.mentalStrength.rawValue
            initiateApiCallsToGetData()
        case 6:
            let activityMetricsController: JournalListingViewController = UIStoryboard(storyboard: .journal).initVC()
            self.navigationController?.pushViewController(activityMetricsController, animated: true)
        default:
            break
        }
        
    }
    func configureRateActivityLayouts(selectedButton: UIButton) {
        selectedButton.setImage(UIImage(named: selectedRatingImg), for: .normal)
        selectedRateActivityNumber = selectedButton.tag
        for button in ratingButtons{
            if button.tag != selectedButton.tag{
                button.setImage(UIImage(named: "Rate Your wellness unselect"), for: .normal)
            }
        }
    }
    
    func showNewActivitiesList(activities: [ActivityData]) {
        DispatchQueue.main.async {
            self.showSelectionModal(array: activities, type: .startActivity)
        }
    }
    
    override func handleSelection(index: Int, type: SheetDataType) {
        switch type {
        case .startActivity:
            startActivity(index: index)
        case .rateActivity:
            break
        default:
            break
        }
    }
    
    private func getActivitiesFromRealm() {
        activityViewModal.getAlreadySavedActivities()
        self.allActivities = activityViewModal.activityCategories
    }
    
    func startActivity(index: Int){
        
        if index < self.activityArray.count {
            self.selectedActivity = self.activityArray[index]
            self.selectedActivity.selectedActivityType = self.activityArray[index].activityType
            objCreateActivity.activityType = ActivityMetric.none //set it to open
            self.objCreateActivity.activityId = self.activityArray[index].id ?? 0
        }
        // Show start activity popup
        let popverVC: StartActivityViewController = UIStoryboard(storyboard: .activity).initVC()
        popverVC.startActivityDelegate = self
        popverVC.selectedActivity = self.selectedActivity
        popverVC.activityName = self.activityArray[index].name ?? ""
        popverVC.activityCategoryDataType = self.activityCategoryDataType
        popverVC.isBinary = self.activityArray[index].isBinary ?? 0 == 1
        if self.activityState == .newActivityAdded {
            popverVC.activityState = .newActivityAdded
            self.present(popverVC, animated: true, completion: nil)
            return
        }
        //  Defaults.shared.set(value: false, forKey: .isActivity)
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            self.showAlert(withTitle: "", message: AppMessages.GroupActivityMessages.runningActivity, okayTitle: AppMessages.CommanMessages.ok, okCall: {
                
            })
            return
        }
        self.present(popverVC, animated: true, completion: nil)
    }
    // MARK: WatchConnectivity
    /// call this function to send the on-going activity information to the watch app
    func updateActivityStatusToWatchApp() {
        let activityProgressInfo = self.getActivityProgressObject()
        activityProgressInfo.startTime = Date().timeIntervalSinceReferenceDate
        activityProgressInfo.isPlaying = true
        do {
            let data = try JSONEncoder().encode(activityProgressInfo)
            let infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
                                                 "request": MessageKeys.createdNewActivityOnPhone]
            Watch_iOS_SessionManager.shared.updateApplicationContext(data: infoDictToPass)
        } catch {
            return
        }
    }
    
    // MARK: Notification observers
    func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationBadge), name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUnreadNotifcationsCount), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    private func checkAlreadyRunningActivity() {
        if self.activityState == .newActivityAdded {
            return
        }
        //        guard isTabbarChild else {
        //            return
        //        }
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            
            let selectedVC: ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
            if let data = ActivityProgressData.currentActivityInfo() {
                let progressData = data
                
                if let isPlaying = data.isPlaying,
                   isPlaying {
                    let difference = Date().timeIntervalSinceReferenceDate - (data.startTime ?? Date().timeIntervalSinceReferenceDate)
                    progressData.elapsed = difference
                    print("elapsed time is \(difference)")
                }
                selectedVC.activityData = progressData//data
            }
            selectedVC.isTabbarChild = isTabbarChild
            selectedVC.isFromDashBoard = true
            self.navigationController?.pushViewController(selectedVC, animated: true)
       //     self.navigationController?.viewControllers = [selectedVC]
        }
    }
    
    // MARK: Custom Functions.
    // MARK: Function to set initial data and UIDesign properties.
    func initUI() {
       // addGradient()
       addTitleLabel()

        getRatingData()
        accountbilityMissionTextView.textColor = .white
        if UserManager.getCurrentUser()?.accountabilityMission != "" && UserManager.getCurrentUser()?.accountabilityMission != AppMessages.ProfileMessages.accountabilityPlaceholder{
            accountbilityMissionTextView.text = UserManager.getCurrentUser()?.accountabilityMission
        }
        if let ratingData = self.ratingData{
            self.configureViewForJournalUpdation(journalData: ratingData)
        }
        
        if self.activityState == .newActivityAdded {
            self.initiateApiCallsToGetData()
            return
        }
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool {
            if isActivity == false {
                self.initiateApiCallsToGetData()
            } else {
                if self.isTabbarChild == false {
                    self.initiateApiCallsToGetData()
                }
            }
        } else {
            self.initiateApiCallsToGetData()
        }
        
    }
    private func addTitleLabel(){
        let myLabel = UILabel()
        let labelTitle = "ACCOUNTABILITY MISSION"
        myLabel.text = "  " + labelTitle + "   "
        let font = UIFont(name: "Roboto-Medium", size: 14)
        let heightOfString = labelTitle.heightOfString(usingFont: font!)
        let x_cord = accountabiltiyView.frame.origin.x
        let y_cord = (accountabiltiyView.frame.origin.y ) - (heightOfString/2 + accountbilityMissionTextView.frame.height + 31)

        let widthofString = labelTitle.widthOfString(usingFont: font!)
        var widthOfLabel:CGFloat = widthofString - 20
        if widthofString > accountabiltiyView.frame.width {
            widthOfLabel = widthofString
        }
        myLabel.frame = CGRect(x: x_cord, y: y_cord, width: widthOfLabel, height: heightOfString)
        myLabel.backgroundColor = .black
        myLabel.textColor = #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1)
        myLabel.font = font
        myLabel.textAlignment = .left
        myLabel.sizeToFit()
        accountabiltiyView.addSubview(myLabel)
        accountabiltiyView.clipsToBounds = false
    }

    private func checkLastDateOfJournalUpdation(journalData:JournalList) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeStamp = journalData.date
        var journaldate = timeStamp.toDate
        let journalDateString = dateFormatter.string(from: journaldate)
        journaldate = dateFormatter.date(from: journalDateString) ?? Date()
        var todayDate = Date()
        let todayDateString = dateFormatter.string(from: todayDate)
        todayDate = dateFormatter.date(from: todayDateString) ?? Date()
        if journaldate == todayDate{
            return true
        }else{
            return false
        }
    }
    
    private func configureViewForJournalUpdation(journalData:RatingData) {
        for button in ratingButtons{
            if button.tag == selectedRateActivityNumber{
                button.setImage(UIImage(named: selectedRatingImg), for: .normal)
            }
            button.isUserInteractionEnabled = true
        }
    }
    
    private func configureViewForRatingDetails(data:RatingData) {
        selectedRateActivityNumber = data.rating
        for button in ratingButtons{
            if button.tag == selectedRateActivityNumber{
                button.setImage(UIImage(named: selectedRatingImg), for: .normal)
            }
        }
    }
    private func callUpdateRatingAPI() {
        var params:[String:Any] = [:]
        params["rating"] = selectedRateActivityNumber
        params["_id"] = self.ratingData?.id
        params["quote"] = ""
        DIWebLayerJournalAPI().updateJournal(parameters: params) { _ in
            self.hideLoader()
            self.showAlert(message: AppMessages.RateDay.ratingUpdated, okayTitle: AppMessages.CommanMessages.ok)
            self.getRatingData()
        } failure: { error in
            self.hideLoader()
            if let message = error.message {
                self.showAlert(message: message)
            }
        }
    }
    private func getRatingData(){
        DIWebLayerActivityAPI().getRating(completion: { data in
            if data.rating != nil{
                self.isEditAble = true
            }
            self.ratingData = data
            self.configureViewForRatingDetails(data: data)
            
        }, failure: { error in
            print(error.message)
        })
    }
    
    // MARK: AddRefreshController To TableView.
    private func addRefreshController() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(refreshControlAction(sender:)) , for: .valueChanged)
        
    }
    
    // MARK: Function To Refresh News Tableview Data.
    @objc func refreshControlAction(sender:AnyObject) {
        initiateApiCallsToGetData(true,showLoader: false)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            if  self.refreshControl?.isRefreshing == true {
                self.refreshControl?.endRefreshing()
            }
        })
    }
    func addGradient() {
        let gradient = getGradientLayer(bounds: accountbilityMissionTextView.bounds,colors: [UIColor(red: 0.97, green: 0.71, blue: 0.00, alpha: 1.00).cgColor,UIColor(red: 0.71, green: 0.13, blue: 0.88, alpha: 1.00).cgColor])
        accountbilityMissionTextView.textColor = GradientOnText().gradientColor(bounds: accountbilityMissionTextView.bounds, gradientLayer: gradient)
        
        accountbilityMissionTextView.isEditable = false
        accountbilityMissionTextView.isScrollEnabled = true
    }
    func configureView(isSelected: Bool, view: UIView) {
        let color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.addDoubleShadow(cornerRadius: 5, shadowRadius: 3, lightShadowColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor, darkShadowColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor, shadowBackgroundColor: color.cgColor)
    }
    
    func saveRating(){
        var paramerter:[String:Any] = [:]
        paramerter["rating"] = selectedRateActivityNumber
        paramerter["quote"] = ""
        DIWebLayerJournalAPI().createJournal(parameters: paramerter) { _ in
            self.hideLoader()
            self.getRatingData()
            self.showAlert(message: AppMessages.RateDay.ratingAdded, okayTitle: AppMessages.CommanMessages.ok)
        } failure: { error in
            self.hideLoader()
            if let message = error.message {
                self.showAlert(message: message)
            }
        }
    }
    func setOutershadows(view: SSNeumorphicView){
//        view.viewDepthType = .outerShadow
//        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
//        view.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
//        view.viewNeumorphicCornerRadius = 1.5
//        view.viewNeumorphicMainColor = UIColor.black.cgColor
//        view.viewNeumorphicShadowRadius = 1.5
        /*
        
        
         view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
         view.viewNeumorphicShadowOpacity = 0.2
         view.viewNeumorphicDarkShadowColor = UIColor.darkGray.cgColor*/
    }
    
    func initiateApiCallsToGetData(_ isReload:Bool = false,showLoader:Bool = true) {
        self.getActivitiesFromBackend(categoryType: activityCategoryDataType,reload:self.allActivities?.count == nil || isReload,showLoader: showLoader)
    }
    
    // MARK: Function to set navigation bar.
    
    private func configureTabbar() {
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: !self.isTabbarChild, controller: self)
        }
    }
    
    @objc func updateNotificationBadge() {
        self.navBar?.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
    }
    
    func addSwipeGesture() {
        
    }
    
    @objc func getUnreadNotifcationsCount() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count, _) in
            self.navBar?.displayBadge(unreadCount: count)
        }
    }
    
    // MARK: NavigationBar right buttons actions.
    override func navigationBar(_ navigationBar: NavigationBar, rightButtonTapped rightButton: UIButton) {
        switch navigationBar.rightAction[rightButton.tag] {
        case .addPost:
            //self.showYPPhotoGallery()
            self.showYPPhotoGallery(showCrop: false)
        case .search :
            let selectedVC:SearchViewController = UIStoryboard(storyboard: .search).initVC()
            self.navigationController?.pushViewController(selectedVC, animated: true)
        default:
            break
        }
    }
    
    override func navigationBar(_ navigationBar: NavigationBar, leftButtonTapped leftButton: UIButton) {
        switch navigationBar.leftAction {
        case .menu:
            self.presentSideMenu()
        case .back:
            self.navigationController?.popViewController(animated: true)
        default:
            if let tabBarController = self.navigationController?.findController(controller: TabBarViewController.self) {
                if (tabBarController.viewControllers?.first as? DashboardViewController) != nil {
                    self.navigationController?.popToViewController(tabBarController, animated: true)
                }
            }
        }
    }
}

// MARK: UITableViewDataSource
extension ActivityContoller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.reuseIdentifier, for: indexPath) as? ActivityTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.initializeWith(activityData: self.activityArray[indexPath.row], indexPath: indexPath)
        return cell
    }
}

// MARK: ActivityTableCellDelegate
extension ActivityContoller: ActivityTableCellDelegate {
    func didTapOnActivity(sender: UIButton) {
     /*   let index = sender.tag
        if index < self.activityArray.count {
            self.selectedActivity = self.activityArray[index]
            self.selectedActivity.selectedActivityType = self.activityArray[index].activityType
            objCreateActivity.activityType = ActivityMetric.none //set it to open
            self.objCreateActivity.activityId = self.activityArray[index].id ?? 0
        }
        // Show start activity popup
        let popverVC: StartActivityViewController = UIStoryboard(storyboard: .activity).initVC()
        popverVC.startActivityDelegate = self
        popverVC.selectedActivity = self.selectedActivity
        popverVC.activityName = self.activityArray[sender.tag].name ?? ""
        popverVC.activityCategoryDataType = self.activityCategoryDataType
        popverVC.isBinary = self.activityArray[sender.tag].isBinary ?? 0 == 1
        if self.activityState == .newActivityAdded {
            popverVC.activityState = .newActivityAdded
            self.present(popverVC, animated: true, completion: nil)
            return
        }
        //  Defaults.shared.set(value: false, forKey: .isActivity)
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            self.showAlert(withTitle: "", message: "You already have an activity in running state.To create new one you have to complete the current activity by Home -> Activity icon on bottom right of tabbar -> Activity Progress", okayTitle: "OK", okCall: {
                
            })
            return
        }
        self.present(popverVC, animated: true, completion: nil)*/
        
    }
}

extension ActivityContoller: StartActivityDelegate {
    func startActivity() {
        self.createUserActivity()
    }
}

