//
//  ChallangeDashBoardController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import SideMenu

enum ActivityTask:Int,CaseIterable {
    case all = 0
    case goal = 1
    case challenge = 2
    
    var title:String{
        switch self {
        case .all:
            return "All"
        case .challenge:
            return "Challenge"
        case .goal:
             return "Goal"
        }
    }
}

enum DashboardTitles : String {
    case futureChallenge_goal = "Pending"
    case pastChallenge_goal = "Past"
}

protocol ChallengeDashboardViewProtocol: AnyObject {
    func didCreateNewActivity(id: String)
}

class ChallangeDashBoardController: DIBaseController {
    
    enum ChallengeDashboardSection: Int, CaseIterable {
        case allListing = 0, openListing
    }
    
    enum ViewState {
        case isLoading(hasLoaded: Bool)
        case showError(error: String)
    }
    
    // MARK: Variables.
    var tableArray = [String]()
    var groupId: String?
    private var lastPage = 1
    private var currentPage = 1
    private var pageLimit = 0
    var dataArray: [GroupActivity]?
    var selectedSection:ActivityTask = .all
    ///timer to show the remaining time for an activity
    var timer: Timer?
    var viewState: ViewState = .isLoading(hasLoaded: false)
    private var reloadView = false // set to true when the view is to be reloaded
    var actionSheet: CustomBottomSheet?
    var pendingItemCount = 0 {
        didSet {
            upcomingLabel.text = "\(pendingItemCount)"
        }
    }
    
    // MARK: IBOutlets.
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var newGoalOrChallengeButton: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var newGoalOrChallengeButtonShadowView:SSNeumorphicView!{
        didSet{
            newGoalOrChallengeButtonShadowView.setOuterDarkShadow()
            newGoalOrChallengeButtonShadowView.viewNeumorphicCornerRadius = newGoalOrChallengeButtonShadowView.frame.height / 2
            newGoalOrChallengeButtonShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    @IBOutlet weak var newGoalOrChallengeButtonGradientView:GradientDashedLineCircularView!
    
    @IBOutlet weak var upcomingShadowView:SSNeumorphicView!{
        didSet{
            upcomingShadowView.setOuterDarkShadow()
            upcomingShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet var buttonsContainerViews: [UIView]!
    @IBOutlet var buttonsBackViews: [SSNeumorphicView]!
    @IBOutlet var buttonss: [UIButton]!
    @IBOutlet weak var pastShadowView:SSNeumorphicView!{
        didSet{
            pastShadowView.setOuterDarkShadow()
            pastShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var upcomingPastOuterShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: upcomingPastOuterShadowView, shadowType: .outerShadow, cornerRadius: 0, shadowRadius: 2)
        }
    }
    
    @IBOutlet weak var tableViewShadowView:SSNeumorphicView!{
        didSet{
            tableViewShadowView.setOuterDarkShadow()
            tableViewShadowView.viewDepthType = .innerShadow
            tableViewShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotificationObserver()
        tableView.registerNibs(nibNames: [
            OpenChallengeDashboardCell.reuseIdentifier,
            OpenGoalDashboardCell.reuseIdentifier,
            WeightGoalInfoTableViewCell.reuseIdentifier
        ])
        backBtn.addDoubleShadowToButton(cornerRadius: backBtn.frame.height / 2, shadowRadius: 0.4, lightShadowColor: UIColor.white.withAlphaComponent(0.1).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor: UIColor.appThemeDarkGrayColor)
        selectedSection = .all
        setButtonsUI()
        initializeData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
        if self.reloadView {
            self.currentPage = 1
            self.lastPage = 1
            self.reloadView = false
            initializeData()
        }
    }

    // MARK: IBActions.
    @IBAction func onClickUpComing(_ sender: UIButton) {
        var screenType = Constant.ScreenFrom.challenge(type: .open)
        switch selectedSection {
            case .all:
                screenType = .all(type: .upcoming)
            case .challenge:
                screenType = .challenge(type: .upcoming)
            case .goal:
                screenType = .goal(type: .upcoming)
        }
        self.topView.isHidden = false
        let menuWidth = self.view.frame.width - 80
        self.presentSideMenuWith(menuPresentMode: .menuSlideIn, screenType: screenType, groupId: self.groupId, menuWidth: menuWidth, shadowColor: .gray)
    }
    
    @IBAction func onClickPast(_ sender: UIButton) {
        var screenType = Constant.ScreenFrom.challenge(type: .open)
        switch selectedSection {
            case .all:
                screenType = .all(type: .completed)
            case .challenge:
                screenType = .challenge(type: .completed)
            case .goal:
                screenType = .goal(type: .completed)
        }
        self.topView.isHidden = false
        let menuWidth = self.view.frame.width - 80
        self.presentSideMenuWith(menuPresentMode: .menuSlideIn, screenType: screenType, groupId: self.groupId, menuWidth: menuWidth, shadowColor: .gray)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func newChallangeTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.moreActions()
        }
    }
    
    @IBAction func allBtnTapped(_ sender: UIButton){
        segementBarAction(sender.tag)
    }
    
    @IBAction func goalsBtnTapped(_ sender: UIButton){
        segementBarAction(sender.tag)
    }
    
    @IBAction func challengesBtnTapped(_ sender: UIButton){
        segementBarAction(sender.tag)
    }
    // MARK: initializer
    func initUI() {
        self.edgesForExtendedLayout = [UIRectEdge.bottom]
        self.navigationController?.navigationBar.isHidden = true
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: true, controller: self)
        }
        self.configureNavigation()
        self.setTableview()
    }
    func initializeData() {
        if Reachability.isConnectedToNetwork() {
            switch selectedSection {
            case .all:
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getAllGoalsChallengesListing), object: nil)
                self.perform(#selector(getAllGoalsChallengesListing), with: nil, afterDelay: 0.5)
            case .challenge:
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getOpenChallengesListing), object: nil)
                self.perform(#selector(getOpenChallengesListing), with: nil, afterDelay: 0.5)
            case.goal:
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getOpenGoals), object: nil)
                self.perform(#selector(getOpenGoals), with: nil, afterDelay: 0.5)
            }
        } else {
            if self.dataArray == nil {
                self.viewState = .showError(error: AppMessages.AlertTitles.noInternet)
            }
        }
        self.tableView.reloadData()
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.activityJoined, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityJoined(notification:)), name: Notification.Name.activityJoined, object: nil)
        switch selectedSection {
        case .all:
              NotificationCenter.default.addObserver(self, selector: #selector(activityEdited(notification:)), name: Notification.Name.challengeEdited, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(activityEdited(notification:)), name: Notification.Name.goalEdited, object: nil)
        case .challenge:
             NotificationCenter.default.addObserver(self, selector: #selector(activityEdited(notification:)), name: Notification.Name.challengeEdited, object: nil)
        case.goal:
            NotificationCenter.default.addObserver(self, selector: #selector(activityEdited(notification:)), name: Notification.Name.goalEdited, object: nil)
        }
    }
    
    @objc func activityJoined(notification: Notification) {
        if let userInfo = notification.userInfo,
            let activityId = userInfo["id"] as? String {
            if let index = self.dataArray?.firstIndex(where: {($0.id ?? "") == activityId}) {
                if let count = self.dataArray?[index].membersCount {
                    self.dataArray?[index].membersCount = count + 1
                }
                self.dataArray?[index].isActivityJoined = true
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func activityEdited(notification: Notification) {
        if let userInfo = notification.userInfo,
            let activityInfo = userInfo["groupActivity"] as? GroupActivity,
            let activityId = activityInfo.id {
            if let index = self.dataArray?.firstIndex(where: {($0.id ?? "") == activityId}) {
                //edit this particular goal or challenge detail
                self.dataArray?[index].activityTypes = activityInfo.activityTypes
                self.dataArray?[index].name = activityInfo.name
                self.dataArray?[index].membersCount = activityInfo.membersCount
                self.dataArray?[index].endDate = activityInfo.endDate
                self.dataArray?[index].completionPercentage = activityInfo.completionPercentage
                self.dataArray?[index].target = activityInfo.target
                self.tableView.reloadData()
            }
        }
    }
    
    func configureNavigation() {
        self.newGoalOrChallengeButton.layer.cornerRadius = self.newGoalOrChallengeButton.frame.width / 2
        if self.groupId != nil {
            self.newGoalOrChallengeButton.isHidden = true
        }
        newGoalOrChallengeButton.setTitle("NEW", for: .normal)
    }
    
    func setTableview() {
        self.tableView.estimatedRowHeight = 100
        tableArray = [DashboardTitles.futureChallenge_goal.rawValue,DashboardTitles.pastChallenge_goal.rawValue]
    }

    // MARK: Api Calls
    @objc private func getAllGoalsChallengesListing() {
        DIWebLayerGoals().getGoalsandChallenges(forType: .open, page: currentPage, completion: { (activities, pageLimit, pendingItemCount) in
            self.setDataSource(withData: activities, pageLimit: pageLimit, currentPage: self.currentPage)
            self.pendingItemCount = pendingItemCount ?? 0
        }) { (error) in
            self.showError(message: error.message ?? "")
        }
    }
    @objc private func getOpenChallengesListing() {
        DIWebLayerActivityAPI().getChallenges(forType: .open, groupId: self.groupId, page: currentPage, completion: { (activities, pageLimit, pendingItemCount) in
            self.setDataSource(withData: activities, pageLimit: pageLimit, currentPage: self.currentPage)
            self.pendingItemCount = pendingItemCount ?? 0
        }) { (error) in
            //handle error here
            self.showError(message: error.message ?? "")
        }
    }
    
    @objc private func getOpenGoals() {
        DIWebLayerGoals().getGoals(forType: .open, page: currentPage, completion: { (activities, pageLimit, pendingItemCount) in
            self.setDataSource(withData: activities, pageLimit: pageLimit, currentPage: self.currentPage)
            self.pendingItemCount = pendingItemCount ?? 0
        }) { (error) in
             self.showError(message: error.message ?? "")
        }
    }

    // MARK: Navigation
    func pushToChallengeDetail(index: Int) {
        if let id = self.dataArray?[index].id,
            isConnectedToNetwork() {
            let selectedVC:ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
            selectedVC.challengeId = id
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
    
    func pushToGoalDetails(index: Int) {
        if let id = self.dataArray?[index].id,
            self.isConnectedToNetwork() {
            let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
            goalDetailController.goalId = id
            goalDetailController.selectedGoalName = self.dataArray?[index].name
            self.navigationController?.pushViewController(goalDetailController, animated: true)
        }
    }
    
    // MARK: Helpers
    func reloadParentTableRow(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: ChallengeDashboardSection.openListing.rawValue)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    //set data source
    private func setDataSource(withData data: [GroupActivity], pageLimit: Int?, currentPage: Int) {
        if let limit = pageLimit {
            self.pageLimit = limit
        }
        if self.dataArray == nil {
            self.dataArray = []
        }
        if currentPage == 1 {
            //remove all data from first page
            self.dataArray?.removeAll()
        }
        self.dataArray?.append(contentsOf: data)
        if data.count >= (pageLimit ?? 15) {
            //increment page number in controller if data count is equal to the pagination limit
            self.currentPage += 1
        }
        self.viewState = .isLoading(hasLoaded: true)
        if let array = self.dataArray {
            if array.isEmpty {
                var message: String?
                switch selectedSection {
                case .all:
                    message = AppMessages.GroupActivityMessages.noOpenChallengesorgoal
                case .challenge:
                    message = AppMessages.GroupActivityMessages.noOpenChallenges
                case .goal:
                    message = AppMessages.GroupActivityMessages.noOpenGoals
                
                }
                self.viewState = .showError(error: message ?? AppMessages.GroupActivityMessages.noOpenChallengesorgoal)
            }
        }
        //calling this to update the data source in parent controller
        let isEmptyData = self.dataArray?.count == 0 ? true : false
        self.reloadViewAfterDataSet(isDataEmpty: isEmptyData)
    }
    
    private func showError(message: String) {
        if let dataArray = self.dataArray,
            dataArray.isEmpty {
            self.viewState = .showError(error: message)
            self.tableView.reloadData()
        } else if dataArray == nil {
            self.viewState = .showError(error: message)
            self.tableView.reloadData()
        }
    }
    
    func reloadViewAfterDataSet(isDataEmpty: Bool) {
        if !isDataEmpty {
            //create timer only if there is some data source
            self.createTimer()
        }
        self.tableView.hideSkeleton()
        self.tableView.tableFooterView = self.tableView.emptyFooterView()
        self.tableView.reloadData()
    }
    
    /// method to initialize timer
    private func createTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.timer = timer
        }
    }
    
    /// invalidates the timer
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// called each time the timer is triggered
    @objc func tickTimer() {
        guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else {
            return
        }
        for indexPath in visibleRowsIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? OpenChallengeDashboardCell {
                if let _ = self.dataArray?[indexPath.row] {
                    cell.updateRemainingTimeForActivity()
                }
            } else if let cell = tableView.cellForRow(at: indexPath) as? OpenGoalDashboardCell {
                if let _ = self.dataArray?[indexPath.row] {
                    cell.updateRemainingTimeForActivity()
                }
            }
        }
    }
    
    // MARK: SegmentBarAction.
    func segementBarAction(_ sender: Int) {
        self.dataArray?.removeAll()
        self.viewState = .isLoading(hasLoaded: false)
        selectedSection = ActivityTask(rawValue: sender) ?? .all
        setButtonsUI()
        self.currentPage = 1
        self.lastPage = 1
        self.reloadView = false
        initializeData()
     }
    
    // MARK: Function to markAllReadNotifications.
    func moreActions() {
        let titleArray: [UserActions] = [.createHealthGoal, .weightGoal, .createGoal, .createChallenge, .cancel]
        let colorsArray: [UIColor] = [.gray, .gray, .gray, .gray]
        let customTitles: [String] = [UserActions.createHealthGoal.title, UserActions.weightGoal.title, UserActions.goal.title, UserActions.challenge.title,UserActions.cancel.title]
        self.actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: colorsArray, customTitles: customTitles, tag: 1)
        self.actionSheet?.delegate = self
    }
    
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.appThemeDarkGrayColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 3, height: 3)
    }
    
    func createGradientView(view:GradientDashedLineCircularView){
        view.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        view.instanceWidth = 2.0
        view.instanceHeight = 7.0
        view.extraInstanceCount = 1
        view.lineColor = UIColor.gray
        view.updateGradientLocation(newLocations: [NSNumber(value: 0.00),NSNumber(value: 0.99)], addAnimation: false)
    }
    private func setContainerViews() {
        for view in buttonsContainerViews {
            view.cornerRadius = view.frame.height / 2
            if view.tag == selectedSection.rawValue {
                view.backgroundColor = UIColor.appCyanColor
            } else {
                view.backgroundColor = UIColor.appThemeDarkGrayColor
            }
        }
    }
    private func setShadowView() {
        for view in buttonsBackViews {
            view.setOuterDarkShadow()
            view.viewDepthType = .innerShadow
            view.viewNeumorphicCornerRadius = view.frame.height / 2
            if view.tag == selectedSection.rawValue {
                view.viewNeumorphicMainColor = UIColor.appCyanColor.cgColor
            } else {
                view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            }
        }
    }
    private func setButtonTitle() {
        for button in buttonss {
            button.cornerRadius = button.frame.height / 2
            if button.tag == selectedSection.rawValue {
                button.setTitleColor(.black, for: .normal)
            } else {
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
    private func setButtonsUI() {
        setContainerViews()
        setShadowView()
        setButtonTitle()
    }
}

// MARK: UIScrollViewDelegate
extension ChallangeDashBoardController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if lastPage < currentPage {
                lastPage = currentPage
                self.tableView.tableFooterView = Utility.getPagingSpinner()
                self.initializeData()
            }
        }
    }
}

// MARK: CreateGoalChallengeViewProtocol
extension ChallangeDashBoardController: CreateGoalChallengeViewProtocol {
    func didCreatedNewActivity() {
        if let dataArray = self.dataArray,
            dataArray.count >= 1 {
            let indexPath = IndexPath(row: 0, section: ChallengeDashboardSection.openListing.rawValue)
        }
        self.reloadView = true
    }
}
extension ChallangeDashBoardController: CustomBottomSheetDelegate {
    func customSheet(actionForItem action: UserActions) {
        DispatchQueue.main.async {
            self.actionSheet?.dismissSheet()
        }
        switch action {
        case .createGoal:
            let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
            controller.delegate = self
            controller.isType = true
            controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createGoal)
            self.navigationController?.pushViewController(controller, animated: true)
        case .createChallenge:
            let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
            controller.delegate = self
            controller.isType = false
            controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
            self.navigationController?.pushViewController(controller, animated: true)
        case .weightGoal:
            let weightGoalVC: WeightGoalTrackerViewController = UIStoryboard(storyboard: .weightgoaltracker).initVC()
                weightGoalVC.createGoalHandler = { [weak self] in
                    self?.initializeData()
                }
            weightGoalVC.isHealthGoalTapped = false
            self.navigationController?.pushViewController(weightGoalVC, animated: true)
        case .createHealthGoal:
            let healthGoalVC: WeightGoalTrackerViewController = UIStoryboard(storyboard: .weightgoaltracker).initVC()
            healthGoalVC.isHealthGoalTapped = true
            healthGoalVC.createGoalHandler = { [weak self] in
                self?.initializeData()
            }
            self.navigationController?.pushViewController(healthGoalVC, animated: true)
        default:
            break
        }
    }
}
