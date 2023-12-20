//
//  HomePageViewController.swift
//  TemApp
//
//  Created by Sourav on 4/19/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//
//    HomePageViewController.reachabilityManager?.stopListening()
import UIKit
import Alamofire
import SideMenu
import SSNeumorphicView
import FirebaseCrashlytics

enum BottomTiles: Int, CaseIterable{
    case notifications = 0 ,  foodTrek,  temTv,  goalsAndChallenge,products
}

enum ApiLoadingState {
    case isLoading, isLoaded, hasError(error: String)
}

class HomePageViewController: DIBaseController , PhoneContactProtocol {

    // MARK: Variables.
    enum CollectionCell : Int, CaseIterable{
        case health = 0 , social
    }
    private enum PageAction: Int, CaseIterable {
        case goalsAndChallenges = 1,reports

        var title: String {
            switch self {
            case .reports:
                return "REPORTS".localized
            case .goalsAndChallenges:
                return "GOALS & \nCHALLENGES".localized
            }
        }
    }
    var activityScoreChanged = true
    private var pendingGoalsCount = 0
    private var completedGoals: [GroupActivity]?
    private var timer: Timer?
    private var challengeId:String = ""
    static var reachabilityManager: NetworkReachabilityManager?
    private var last30thDayDate: Date?
    private var last30DaysSleepTime: Double?
    static var totalShortcutsAdded: Int = 0
    private var isHealthKitAuthorized = false
    var isShortcutsRefreshed = true
    /// this will hold the ids of the goals which are uploading to server
    private var currentUploadingGoalIds: [String]?
    private var navBar: NavigationBar!
    private var currentPage: Int = 1
    private var currentPageAction: PageAction = .goalsAndChallenges
    private var lastSavedActivityScore: Double? = 0 {
        didSet {
            self.updateScoreOnHealthCell(score: lastSavedActivityScore)
            centralCollectionView.reloadData()
        }
    }
    private var activityAccountabilityScore: Double = 0.0
    var a: Int?

    private var myLeaderboard: MyLeaderboard?
    private var pageLoadingStates = [ApiLoadingState]()
    private var hasAddedTraingularShadows = false
    private var isShadowAddedToButton = false
    var weekDays: [WeekDays] = [WeekDays]()

    var tiles = [SeeAllModel]()
    // MARK: IBOulets.
    // MARK: IBOutlets for the goal screenshot view
    @IBOutlet weak var progressDisplayView: GoalProgressDisplayView!
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var goalDescriptionLabel: UILabel!
    @IBOutlet weak var goalStatusAndTematesCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityDurationLabel: UILabel!
    @IBOutlet weak var activityStartDateLabel: UILabel!
    @IBOutlet weak var screenshotView: UIView!
    @IBOutlet var pageControl: [UIButton]!
    @IBOutlet var firstMiddleButton: UIButton!
    @IBOutlet var secondMiddleButton: UIButton!
    @IBOutlet var outerShadowView: SSNeumorphicView!
    @IBOutlet var searchShadowView: SSNeumorphicView!
    @IBOutlet weak var innerShadowView: SSNeumorphicView!
    //New Outlets
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var viewFeedButton: UIButton!
    @IBOutlet weak var centralCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    var journalsList:[JournalList] = [JournalList]()
    var isDataLoadedFromServer = false
    @IBOutlet weak var badgeCountLAbel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    // MARK: IBAction


    // MARK: App Life Cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
        self.setScreenshotViewLayout()
        self.hitAllApiInConcurrent()
        self.addGoalCompleteObserver()
        self.addNetworkReachabilityObserver()
        //setting the user information to the firebase
        Reach().monitorReachabilityChanges()
        enableLocationForActivity()
        healthConnect()
    }

    func noificationForUpdateScore() {
        NotificationCenter.default.addObserver(self,selector: #selector(self.activityScoreChangedMethod),name: NSNotification.Name(rawValue:"activityScoreChanged"),object: nil)
    }
    @objc func activityScoreChangedMethod() {
        activityScoreChanged = true
    }
    func healthConnect() {
        HealthKit.instance?.requestAuthorization {
            DispatchQueue.main.async {
                if HealthKit.instance?.askedForSyncEnable == false {
                    self.askForHealthSyncEnable()
                }
                if User.sharedInstance.isFromSignUp {
                    User.sharedInstance.isFromSignUp = false
                    self.showTutorial()
                }
                self.syncPhoneNumberContacts()
            }
        }
    }
    func hitAllApiInConcurrent() {
        let operationQueue: OperationQueue = OperationQueue()
        let blockOperation2 = BlockOperation()
        let blockOperation3 = BlockOperation()
        let blockOperation4 = BlockOperation()
        let blockOperation5 = BlockOperation()
        let blockOperation6 = BlockOperation()

        blockOperation2.addExecutionBlock {
            self.openStream()
        }
        blockOperation3.addExecutionBlock {
            ChatManager().updateCurrentUserInfoToDatabase()
        }
        blockOperation4.addExecutionBlock {
            self.checkForNewAppUpdate()
        }
        blockOperation5.addExecutionBlock {
            self.apiToGetCaraousel()

        }
        blockOperation6.addExecutionBlock {
            self.updateBadgeView()

        }

        operationQueue.maxConcurrentOperationCount  = 5
        operationQueue.addOperations([blockOperation2,blockOperation3,blockOperation4,blockOperation5, blockOperation6], waitUntilFinished: false)

    }
    func notificationInitialise() {
        NotificationCenter.default.addObserver(self,selector: #selector(self.healthKitAuthorized),name: NSNotification.Name(rawValue:healthKitAutorized),object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.stopStepsUpdateTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deallocateTimer), name: Notification.Name.stopStepsUpdateTimer, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.handleWillEnterForGroundObserver),name: UIApplication.willEnterForegroundNotification,object: nil)
        //check internet connection countinously
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)


    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func openStream() {
        DispatchQueue.main.async {
            if  let affiId = Stream.affiliateID,  Stream.isComingFromInActiveApp {
                Stream.connect.toServer(affiId,true,self)
            } else {
                Stream.isComingFromInActiveApp = false
                Stream.affiliateID = nil
            }
        }
    }
    @IBAction func notificationTapped(_ sender: UIButton) {
        let selectedVC:NotificationsController = UIStoryboard(storyboard: .notification).initVC()
        selectedVC.updateNotificationsCountHandler = { [weak self] in
            self?.updateBadgeView()
        }
        selectedVC.screenFrom = .dashboard
        self.navigationController?.pushViewController(selectedVC, animated: true)
    }

    @IBAction func firstButtonTapped(sender: UIButton) {
        if currentPage == sender.tag{
            let feedVC: FeedAndCalendarController = UIStoryboard(storyboard: .dashboard).initVC()
            feedVC.screenFrom = .event
            self.navigationController?.pushViewController(feedVC, animated: true)
        } else{
            let createProfileVC:ReportViewController = UIStoryboard(storyboard: .reports).initVC()
            self.navigationController?.pushViewController(createProfileVC, animated: true)
        }
    }
    @IBAction func pageControlTapped(sender: UIButton) {
        self.shiftPageControl(at: sender.tag, isPageControlTapped: true)
    }

    @IBAction func seeAllTapped(_ sender: UIButton) {
        let seeAllVC: SeeAllVC = UIStoryboard(storyboard: .dashboard).initVC()
        seeAllVC.challengeId = self.challengeId
        seeAllVC.selectedContent = .myContent
        seeAllVC.updateNotificationsCountHandler = { [weak self] in
            self?.updateBadgeView()
        }
        self.navigationController?.pushViewController(seeAllVC, animated: true)
    }
    func setTitles(index: Int){
        if let action = PageAction(rawValue: currentPage) {
            switch action {
            case .reports:
                firstMiddleButton.setTitle("REPORTS", for: .normal)
                secondMiddleButton.setTitle("MESSAGES & \n      TĒMS", for: .normal)
            case .goalsAndChallenges: firstMiddleButton.setTitle("CALENDAR", for: .normal)
                secondMiddleButton.setTitle("ADD/TRACK \n   ACTIVITY", for: .normal)
            }
        }
    }
    @IBAction func secondButtonTapped(sender: UIButton) {
        if currentPage == sender.tag {
            let temsVC: ChatListingViewController = UIStoryboard(storyboard: .chatListing).initVC()
            self.navigationController?.pushViewController(temsVC, animated: true)
        } else{
            let selectedVC:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
            selectedVC.isFromDashBoard = false
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }

    }

    @IBAction func profileAction(sender: UIButton) {
        let profileVc: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        self.navigationController?.pushViewController(profileVc, animated: true)
    }

    @IBAction func searchAction(sender: UIButton) {
        let globalSearchVC: SearchViewController = UIStoryboard(storyboard: .search).initVC()
        self.navigationController?.pushViewController(globalSearchVC, animated: true)
    }
    @IBAction func feedsCalendarAction(sender: UIButton) {
        let feedVC: FeedAndCalendarController = UIStoryboard(storyboard: .dashboard).initVC()
        feedVC.screenFrom = .newsFeeds
        self.navigationController?.pushViewController(feedVC, animated: true)
    }
    func addActivityScore() {
        if let lastScore  = UserManager.getUserActivityReport().totalActivityScore?.value {
            _ = CollectionCell.allCases.map { (Cell) -> CollectionCell in
                self.pageLoadingStates.append(Cell == .health ? .isLoaded : .isLoading)
                return Cell
            }
        } else {
            _ = CollectionCell.allCases.map { (Cell) -> CollectionCell in
                self.pageLoadingStates.append(ApiLoadingState.isLoading)
                return Cell
            }
            centralCollectionView.reloadData()
        }
    }

    func showTutorial() {
        //To check total user profile
        AnalyticsManager.logEventWith(event: Constant.EventName.totalUserProfile,parameter: [
            "isNewProfile" : true
        ])
        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: false, completion: nil)
    }

    func askForHealthSyncEnable() {
        self.showAlert(withTitle: "", message: "Would you like to enable automatic Health activities syncing? You can configure it later in Profile & Temates -> Account -> Link Apps", okayTitle: "Yes", cancelTitle: "No", okCall: {
            self.showLoader()
            HealthKit.instance?.setAskedForSyncEnable()
            HealthKit.instance?.enableSyncWithHealthKit { (success, error) in
                DispatchQueue.main.async {
                    self.hideLoader()
                    if success {
                        // do nothing
                    }
                    else {
                        //self.showAlert(withError: DIError(title: "", message: "Error occured when subscribing to Health", code: .unknown))
                    }
                }
            }
        }, cancelCall: {
            HealthKit.instance?.setAskedForSyncEnable()
        })
    }

    func enableLocationForActivity(){
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            if let data = ActivityProgressData.currentActivityInfo(){
                if let isPlaying = data.isPlaying,
                   isPlaying {
                    //activity is in playing state
                    appDelegate.initalizeLocation()
                    appDelegate.startLocation()
                }
            }
        }
    }

    func setTimer() {
        if self.timer == nil {
            DispatchQueue.main.async {
                print("is main thread: \(Thread.isMainThread)")
                self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.fetchUserSteps), userInfo: nil, repeats: true)
            }
        }
    }

    @objc private func deallocateTimer() {
        self.timer?.invalidate()
        self.timer = nil
        //HealthKit.instance?.stopObservingStepsCount()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.stopStepsUpdateTimer, object: nil)
    }

    @objc func fetchUserSteps() {
        if let stepsLastFetchTime = Defaults.shared.get(forKey: .stepsLastFetchTime) as? Date {
            let endDate = Date()
            //fetch the updated steps from this time to the current date
            HealthKit.instance?.getStepsForTimePeriod(startDate: stepsLastFetchTime, endDate: endDate, completion: { (value, error) in
                if value != 0 {
                    self.updateStepsToServer(stepsCount: value, startDate: stepsLastFetchTime, endDate: endDate)
                }
            })
        } else {
            let currentDate = Date()
            Defaults.shared.set(value: currentDate, forKey: .stepsLastFetchTime)
            //            self.setTimer()
        }
    }

    private func updateStepsToServer(stepsCount: Double, startDate: Date, endDate: Date) {
        let startDateTimeStamp = startDate.timestampInMilliseconds
        let params: Parameters = ["steps": stepsCount, "startDate": startDateTimeStamp]
        DIWebLayerActivityAPI().updateStepsOfUser(parameters: params, success: { (_) in
            Defaults.shared.set(value: endDate, forKey: .stepsLastFetchTime)
            //self.setTimer()
        }) { (_) in

        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if isShadowAddedToButton == false { isShadowAddedToButton = true }
        self.addBadgeObserver()
        if isHealthKitAuthorized {
            self.getLast30DaysSleep()
        }
    //    self.perform(#selector(getCompletedGoals), with: self, afterDelay: 2.0)
        concurrentApiHitWillAppear()
        Stream.connect.getAllStreamers()
    }
    func concurrentApiHitWillAppear() {
        let operationQueue: OperationQueue = OperationQueue()
        let blockOperation = BlockOperation()
        let blockOperation2 = BlockOperation()
        let blockOperation3 = BlockOperation()
        let blockOperation4 = BlockOperation()
        blockOperation.addExecutionBlock {
            self.getActivityLog()
        }

        blockOperation3.addExecutionBlock {
            self.getUserLeaderboard()
        }

        operationQueue.maxConcurrentOperationCount  = 5
        operationQueue.addOperations([blockOperation,blockOperation2,blockOperation3], waitUntilFinished: false)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeBadgeObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    func setOutershadows(view:SSNeumorphicView){
        view.viewDepthType = .outerShadow
        view.viewNeumorphicCornerRadius = view.frame.width/2
        view.viewNeumorphicMainColor = UIColor.blakishGray.cgColor

        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.15).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor

    }

    func viewsInitialise() {
        let url = UserManager.getCurrentUser()?.profilePicUrl ?? ""
        profileButton.kf.setBackgroundImage(with: URL(string: url), for: .normal, placeholder: UIImage(named: "user"), options: nil, progressBlock: nil)
        self.badgeView.isHidden = true
        outerShadowView.viewNeumorphicCornerRadius = self.outerShadowView.frame.width/2
       innerShadowView.viewNeumorphicCornerRadius = self.innerShadowView.frame.width/2
        setOutershadows(view: outerShadowView)
      setOutershadows(view: searchShadowView)

        self.innerShadowView.viewDepthType = .innerShadow
        innerShadowView.viewNeumorphicCornerRadius = self.innerShadowView.frame.width/2
        self.innerShadowView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        self.innerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.innerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
    }
    func tableCollInitilise() {
        centralCollectionView.registerNibsForCollectionView(nibNames: [HealthCollectionCell.reuseIdentifier, ProfileCollectionCell.reuseIdentifier, CalendarCollectionCell.reuseIdentifier, SocialCollectionCell.reuseIdentifier])

    }
    func initialize(){
        viewsInitialise()
        notificationInitialise()
        saveUserOnFirebase()
        tableCollInitilise()
        self.addActivityScore()
    }
    func apiToGetCaraousel() {
        let carousal = MyContentCarousal()
        carousal.getContentCarousal(type: .homeScreen) {[weak self] response, error in
            DispatchQueue.main.async {

                self?.isDataLoadedFromServer = true
            if error != nil{
                return
            }
                guard let tiles = response else { return }
                self?.tiles = tiles
                self?.bottomCollectionView.reloadData()
            }
        }
    }
    private func getUnreadCountFromServer() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount {[weak self] (count,id) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.challengeId = id ?? ""
                Defaults.shared.set(value: count, forKey: .unreadNotificationCount)
                self.updateBadgeOnReadNotification()
                UIApplication.shared.applicationIconBadgeNumber = count ?? 0
            }
        }
    }

    @objc func updateBadgeView() {
        self.getUnreadCountFromServer()
    }

    @objc func updateBadgeOnReadNotification() {
     //   bottomCollectionView.reloadData()
        DispatchQueue.main.async {
            if let value = Defaults.shared.get(forKey: .unreadNotificationCount) as? Int,
                value > 0 {
                self.badgeView.isHidden = false
                self.badgeCountLAbel.text = "\(value)"
            } else {
                self.badgeView.isHidden = true
            }
        }
    }

    @objc func handleWillEnterForGroundObserver() {
        if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String , deviceType == HealthAppType.fitbit.title {
            //  self.objHealthKitInterface = HealthKitInterface()
        }
    }

    //Adding Network Reachability observer
    func addNetworkReachabilityObserver() {
        HomePageViewController.reachabilityManager = NetworkReachabilityManager()

        HomePageViewController.reachabilityManager?.startListening()
        HomePageViewController.reachabilityManager?.listener = { _ in
            if let isNetworkReachable = HomePageViewController.reachabilityManager?.isReachable,
               isNetworkReachable == true {
                //Internet Available, sync the offline saved un-uploaded posts to server
                print("************* internet available ************")
                //cancel all the uploading tasks, if any
                //                AWSBucketMangaer.bucketInstance.cancelAllTasks()
                OfflineSync.shared.processOfflinePosts()
            } else {
                //Internet Not Available"
            }
        }
    }

    func addGoalCompleteObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.goalCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goalCompleted), name: Notification.Name.goalCompleted, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.goalAsPostUpload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goalUploadedAsPost(notification:)), name: Notification.Name.goalAsPostUpload, object: nil)
    }

    ///remove the id from the array
    @objc func goalUploadedAsPost(notification: Notification) {
        if let post = notification.object as? Post,
           let id = post.activityId {
            if let currentIds = self.currentUploadingGoalIds,
               !currentIds.isEmpty {
                if let firstIndex = currentIds.firstIndex(where: {$0 == id}) {
                    if firstIndex < currentIds.count {
                        self.currentUploadingGoalIds?.remove(at: firstIndex)
                    }
                }
            }
        }
    }

    @objc func goalCompleted(notification: Notification) {
        if let userInfo = notification.userInfo,
           let goal = userInfo["goal"] as? GroupActivity {
            let uploadStatusInBackground = userInfo["backgroundUpload"] as? Bool ?? false
            self.uploadGoalAsPost(goal: goal, index: 100, uploadInBackground: uploadStatusInBackground)
        }
    }

    private func syncPhoneNumberContacts() {
        guard isConnectedToNetwork() else {
            return
        }
        let contactsArr = self.fetchContacts(filter: .phoneNumber, shouldShowAlertForPermission: false)
        var phoneNumberArr:[String] = []
        if (contactsArr.count > 0) {
            for contacts in contactsArr {
                phoneNumberArr.append(contacts.phoneNumber.first?.removeSpecialCharacters ?? "")
            }
            var param = PhoneContactsKey()
            param.valuesArray = phoneNumberArr
            DIWebLayerNetworkAPI().syncContacts(parameters: param.getDictionary(), success: { (response) in
            }) { (error) in
                self.showAlert(message:error.message)
            }
        }
    }

    // MARK: App Update
    private func checkForNewAppUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            AppManager().checkNewUpdate(success: {[weak self] (status) in
                switch status {
                case .available(let type):
                    DispatchQueue.main.async {
                        self?.showUpdateAlert(type: type)
                    }
                default:
                    break
                }
            }) { (_) in

            }
        }
    }

    /// show update pop up for different types
    /// - Parameter type: normal and forced
    private func showUpdateAlert(type: AppUpdateType) {
        if let presented = self.presentedViewController {
            presented.dismiss(animated: true, completion: nil)
        }
        switch type {
        case .normal:
            self.showAlert(withTitle: AppMessages.AppUpdate.updateAvailableTitle, message: AppMessages.AppUpdate.newUpdate, okayTitle: AppMessages.AppUpdate.update, cancelTitle: AppMessages.AppUpdate.cancel, okCall: {
                self.redirectToAppStore()
            }) {

            }
        case .forceUpdate:
            self.showAlert(withTitle: AppMessages.AppUpdate.updateAvailableTitle, message: AppMessages.AppUpdate.newUpdate, okayTitle: AppMessages.AppUpdate.update, okCall: {
                self.redirectToAppStore()
            })
        }
    }

    /// redirect to app store
    private func redirectToAppStore() {
        if let url = URL(string: AppMessages.AppUpdate.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: Add Badge obsrevers
    private func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeOnReadNotification), name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeView), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }

    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }

    // MARK: Get user score api
    private func getActivityLog() {
        if self.isConnectedToNetwork() {
            DIWebLayerReportsAPI().getUserReport(isFullReport: false, success: {[weak self] (activityReport, _, _, _, _)  in
                guard let self = self else {return}
                UserManager.saveUserActivityReport(activityReport: activityReport)
                self.pageLoadingStates[CollectionCell.health.rawValue] = .isLoaded
                if self.lastSavedActivityScore == nil || self.lastSavedActivityScore != activityReport.totalActivityScore?.value {
                    self.lastSavedActivityScore = activityReport.totalActivityScore?.value
                }
            }) { (error) in
                self.pageLoadingStates[CollectionCell.health.rawValue] = .hasError(error: error.message ?? "")
                self.updateScoreOnHealthCell(score: self.lastSavedActivityScore)
                self.centralCollectionView.reloadData()
            }
        } else {
            let lastScore = self.lastSavedActivityScore
            self.lastSavedActivityScore = lastScore
        }
    }

    private func updateScoreOnHealthCell(score: Double?) {
        if let cell = self.centralCollectionView.cellForItem(at: IndexPath(item: CollectionCell.health.rawValue, section: 0)) as? HealthCollectionCell {
            cell.setScore(value: score, withAnimation: true)
            cell.setViewStateFor(loadingState: self.pageLoadingStates[CollectionCell.health.rawValue])
        }
    }

    func saveUserOnFirebase(){
        if let id = User.sharedInstance.id{
            LoginFirebaseUser.signIn(email: id, password: id) { (finished, error) in
                if (finished == nil) {
                    DILog.print(items: "Login on Firebase is Giving error\(error)")
                    return
                }
                //To update the profile pic(Avatar with fName & lName) of existing users
                if UserManager.getCurrentUser()?.profilePicUrl == ""{
                    self.uploadImageOnFirebase(completion: { (imgUrl) in
                        if (imgUrl != nil) {
                            self.updateProfileOnServer(imageURl: imgUrl)
                            User.sharedInstance.profilePicUrl = imgUrl
                            UserManager.saveCurrentUser(user: User.sharedInstance)

                        } else {
                            self.showAlert(withTitle: "Warning", message: "firebase error occured")
                        }
                    })
                }

            }
        }
    }

    func updateProfileOnServer(imageURl: String?){
        DIWebLayerUserAPI().uplodaProfileData(parameters: getParameterKey(image: imageURl), success: { (message) in
        }) { (error) in
            self.showAlert(withError: error)
        }
    }

    //This Fucntion will return param to create profile....
    private func getParameterKey(image: String?) -> Parameters {
        var param = CreateProfile()
        param.location = UserManager.getCurrentUser()?.address ?? Address()
        param.userName =  ""

        param.firstName = UserManager.getCurrentUser()?.firstName ?? ""
        param.lastName = UserManager.getCurrentUser()?.lastName ?? ""

        param.imgUrl = image ?? ""
        if UserManager.getCurrentUser()?.dateOfBirth?.toInt() == 0 {
            if let date = UserManager.getCurrentUser()?.dateOfBirth?.toDate(dateFormat: .preDefined) {
                param.dateOfBirth = "\(date.timeStamp)"
            }
        } else {
            param.dateOfBirth =  UserManager.getCurrentUser()?.dateOfBirth ?? ""
        }
        param.gender =  UserManager.getCurrentUser()?.gender ?? 0
        param.lat =  UserManager.getCurrentUser()?.address?.lat ?? 0.0
        param.long =  UserManager.getCurrentUser()?.address?.lng ?? 0.0
        param.gymLocation =  UserManager.getCurrentUser()?.gymAddress ?? Address()
        DILog.print(items: "parameters for Create Profile:- \(param.getDictionary() ?? [:])")
        return param.getDictionary() ?? [:]
    }
    func uploadImageOnFirebase(completion:@escaping (_ imageUrl: String?) ->()){
        var image: UIImage?
        if(User.sharedInstance.id != nil) {

            if UserManager.getCurrentUser()?.profilePicUrl == ""{
                let lblNameInitialize = UILabel()
                lblNameInitialize.font = UIFont(name: UIFont.avenirNextBold, size: 32)
                lblNameInitialize.frame.size = CGSize(width: 100, height: 100)
                lblNameInitialize.textColor = UIColor.white
                if let fname = UserManager.getCurrentUser()?.firstName, let lname = UserManager.getCurrentUser()?.lastName, let firstName = fname.first?.uppercased(), let lastName = lname.first?.uppercased(){

                    lblNameInitialize.text = firstName + lastName
                }
                lblNameInitialize.textAlignment = NSTextAlignment.center
                lblNameInitialize.backgroundColor = UIColor.random()
                UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
                lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

            }

            //Check will set a new profile image name on firebase, if uploading on first time, but in update time, it will use old imagename and reupload on firebase
            if (User.sharedInstance.firebaseProfileImageName == nil) || (User.sharedInstance.firebaseProfileImageName == "") {
                User.sharedInstance.firebaseProfileImageName = (User.sharedInstance.id)!
            }
            let firImageName = (User.sharedInstance.firebaseProfileImageName ?? "") + Utility.shared.getFileNameWithDate()
            guard let data = image?.jpegData(compressionQuality: 0.5) else {
                return
            }
            UploadMedia.shared.configureDataToUpload(type: .awsBucket, data: data, withName: firImageName, mimeType: "image/jpeg", mediaObj: Media())
            UploadMedia.shared.uploadImage(success: { (url, media) in
                completion(url)
            }) { (error) in
                self.hideLoader()
                DILog.print(items: error.message ?? "")
                self.showAlert(message: error.message ?? "")
            }
        }
    }

    //Get leaderboard api
    private func getUserLeaderboard() {
        DIWebLayerUserAPI().getLeaderboard(page: 1, searchString: nil) { [weak self] (leaderboard) in
            guard let self = self else {return}
            DispatchQueue.main.async {
            self.pageLoadingStates[CollectionCell.social.rawValue] = .isLoaded
            self.myLeaderboard = leaderboard
                self.updateLeaderboardCell()
            }
        } failure: { (error) in
            self.pageLoadingStates[CollectionCell.social.rawValue] = .hasError(error: error.message ?? "")
            DispatchQueue.main.async {
                self.updateLeaderboardCell()
            }
        }
    }

    private func updateLeaderboardCell() {
        if let cell = self.centralCollectionView.cellForItem(at: IndexPath(item: CollectionCell.social.rawValue, section: 0)) as? SocialCollectionCell {
            cell.leaderboard = self.myLeaderboard
            cell.setViewStateFor(loadingState: self.pageLoadingStates[CollectionCell.social.rawValue])
        }
    }

    // MARK: Handle Page Control
    private func shiftPageControl(at index: Int, isPageControlTapped: Bool) {
        for pageButton in pageControl {
            if pageButton.tag == index {
                pageButton.isSelected = true
                if isPageControlTapped,
                   currentPage != pageButton.tag {
                    swipeToPageAt(newIndex: pageButton.tag)
                }
                currentPage = pageButton.tag
            } else {
                pageButton.isSelected = false
            }
        }
        if let pageAction = PageAction(rawValue: index) {
            currentPageAction = pageAction
            setTitles(index: index)
        }
    }

    private func swipeToPageAt(newIndex: Int) {
        let indexPath = IndexPath(item: newIndex - 1, section: 0)
        self.centralCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    // MARK: Sleep time helpers
    @objc func healthKitAuthorized() {
        self.isHealthKitAuthorized = true
        self.getLast30DaysSleep()
        //        HealthKit.instance?.observeStepsData(completion: { (_) in
        //            self.fetchUserSteps()
        //        })
        self.setTimer()
    }

    private func updateSleepTimeToServer(last30days: Double, lastToLast30Days: Double?) {
        DIWebLayerReportsAPI().updateSleepTime(last30DaysTime: last30days, lastToLast30DaysTime: lastToLast30Days) { (success) in
            if success {
            }
        }
    }

    //get the sleep data from health kit for the previous 30 days
    private func getLastToLast30DaysSleep() {
        if let last30thDayDate = last30thDayDate {
            let userRegistrationDate = User.sharedInstance.createdAt?.toDate() ?? Date()
            var dateBack30Days = Calendar.current.date(byAdding: .day, value: -30, to: last30thDayDate) ?? Date()
            if userRegistrationDate > dateBack30Days {
                dateBack30Days = userRegistrationDate
            }
            self.fetchSleepTimeFromExternalSources(startDate: dateBack30Days, endDate: last30thDayDate) { (value) in
                if let last30DaySleepTime = self.last30DaysSleepTime {
                    self.updateSleepTimeToServer(last30days: last30DaySleepTime, lastToLast30Days: value)
                }
            }
        }
    }

    func getLast30DaysSleep() {
        let userRegistrationDate = User.sharedInstance.createdAt?.toDate() ?? Date()
        let currentDate = Date()
        var dateBack30Days = Calendar.current.date(byAdding: .day, value: -30, to: currentDate) ?? Date()
        if userRegistrationDate > dateBack30Days {
            //there will be no data for previous 30 days for the user
            dateBack30Days = userRegistrationDate
            self.last30thDayDate = nil
        } else {
            self.last30thDayDate = dateBack30Days
        }
        self.fetchSleepTimeFromExternalSources(startDate: dateBack30Days, endDate: currentDate) { (value) in
            self.last30DaysSleepTime = value
            if self.last30thDayDate == nil {
                //update the sleep time to server
                self.updateSleepTimeToServer(last30days: value, lastToLast30Days: nil)
            } else {
                self.getLastToLast30DaysSleep()
            }
        }
    }

    func fetchSleepTimeFromExternalSources(startDate: Date, endDate: Date, completion: @escaping(_ sleepTimeInMinutes: Double) -> Void) {
        if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String , deviceType == HealthAppType.fitbit.title {
            guard FitbitAuthHandler.getToken() != nil else {
                return
            }
            //fetch from fitbit
            //            let apiUrl = "https://api.fitbit.com/1.2/user/-/sleep/date/2019-06-30/2019-07-06.json"
            let startDateFormatted = startDate.toString(inFormat: .fitbitDate) ?? ""
            let endDateFormatted = endDate.toString(inFormat: .fitbitDate) ?? ""
            let apiUrl = "https://api.fitbit.com/1.2/user/-/sleep/date/\(startDateFormatted)/\(endDateFormatted).json"
            let token = FitbitAuthHandler.getToken()
            let manager = FitbitAPIManager.shared()
            manager?.requestGET(apiUrl, token: token, success: { responseObject in
                if let response = responseObject {
                    if let data = response["sleep"] as? [Parameters] {
                        var value : Double = 0.0
                        for (_,sample) in data.enumerated()  {
                            value += sample["duration"] as? Double ?? 0.0
                        }
                        completion(value)
                    }
                }
            }, failure:  { _ in

            })
        } else {
            //fetch from healthApp
            HealthKit.instance?.retrieveSleepAnalysis(startDate: startDate, endDate: endDate) { (doubleValue, _) in
                //                print("sleep value for last 30 days: \(doubleValue)")
                completion(doubleValue)
            }
        }
    }

    func getSleepTimeFromFitbit() {
        let apiUrl = "https://api.fitbit.com/1.2/user/-/sleep/date/2019-06-30/2019-07-06.json"
        let token = FitbitAuthHandler.getToken()
        let manager = FitbitAPIManager.shared()
        manager?.requestGET(apiUrl, token: token, success: { responseObject in
            if let response = responseObject {
                if let data = response["sleep"] as? [Parameters] {
                    var value : Double = 0.0
                    for (_,sample) in data.enumerated()  {
                        value += sample["duration"] as? Double ?? 0.0
                        self.showAlert(message:"\(value)")
                    }
                    self.showAlert(message:"\(value)")
                }
            }
        }, failure:  { _ in

        })
    }
    // MARK: Calendar Helper function
    func getWeeklyDaysOfCalendar(){

        DIWebLayerEvent().getweeklyDays( success: {[weak self] response in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.weekDays = response
                self.centralCollectionView.reloadData()
            }
        }, failure: { error in
            self.showAlert( message: error?.message, okayTitle: "Ok")
        })
    }

}//Class.....

extension HomePageViewController: DashboardRedirectionDelegate {
    func didClickOnHoneyCombView(sender: UIButton) {
        let selectedIndex = sender.tag
        if let selectedView = DashboardRedirection(rawValue: selectedIndex) {

            switch selectedView {
            case .calendar:
                break
            case .activity:
                self.checkIsActivityRunning()
            case .challenge:
                let selectedVC:ChallangeDashBoardController = UIStoryboard(storyboard: .challenge).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .tems:
                let chatListingController: ChatListingViewController = UIStoryboard(storyboard: .chatListing).initVC()
                chatListingController.screenFrom = .dashboard
                self.navigationController?.pushViewController(chatListingController, animated: true)
            case .goals_challenge:
                let selectedVC:ChallangeDashBoardController = UIStoryboard(storyboard: .challenge).initVC()
                //  selectedVC.isFromChallenge = false
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .myProfile:
                let networkVC:ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                networkVC.isComingFromDashboard = false
                self.navigationController?.pushViewController(networkVC, animated: true)
            case .post:
                //self.showYPPhotoGallery()
                self.showYPPhotoGallery(showCrop: false)
            case .activityLog:
                let activityLogController: ActivityMetricsViewController = UIStoryboard(storyboard: .reports).initVC()
                self.navigationController?.pushViewController(activityLogController, animated: true)
            case .leaderboard:
                let leaderboardController: LeaderboardViewController = UIStoryboard(storyboard: .dashboard).initVC()
                self.navigationController?.pushViewController(leaderboardController, animated: true)
            case .shortcut:
                guard isConnectedToNetwork() else {
                    return
                }
                if let button = sender as? HoneyCombButton,
                   let data = button.elements?.first as? HomeScreenShortcut,
                   let type = data.type {
                    switch type {
                    case .tem:
                        self.pushToChatScreen(id: data.id, name: data.name)
                    case .goal:
                        self.pushToGoalDetailScreen(id: data.id, name: data.name)
                    case .challenge:
                        self.pushToChallengeDetailScreen(id: data.id)
                    }
                }
            }
        }
    }

    /// Push chatview on stack
    ///
    /// - Parameter:
    ///   - id: chatroom id
    ///   - name: goal name
    private func pushToChatScreen(id: String?, name: String?) {
        let chatViewController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        chatViewController.chatRoomId = id
        chatViewController.chatName = name
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }

    /// push goal detail on navigation stack
    ///
    /// - Parameters:
    ///   - id: goal id
    ///   - name: goal name
    private func pushToGoalDetailScreen(id: String?, name: String?) {
        let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
        goalDetailController.goalId = id
        goalDetailController.selectedGoalName = name
        self.navigationController?.pushViewController(goalDetailController, animated: true)
    }

    /// push challenge detail screen on navigation stack
    ///
    /// - Parameter id: challenge id
    private func pushToChallengeDetailScreen(id: String?) {
        let challengeDetailController: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
        challengeDetailController.challengeId = id
        self.navigationController?.pushViewController(challengeDetailController, animated: true)
    }

    func checkIsActivityRunning() {
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
            let selectedVC:ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
            if let data = ActivityProgressData.currentActivityInfo(){
                selectedVC.activityData = data
            }
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }else{
            let selectedVC:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
            selectedVC.isFromDashBoard = false
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
}




// MARK: helpers for goal screenshot
extension HomePageViewController {
    ///these are the helper functions to set the screenshot view content of a goal
    @objc func getCompletedGoals() {
        DIWebLayerGoals().getCompletedGoals(completion: { (goals) in
            //            print("got completed goals -----------------> \(goals.count)")
            if !goals.isEmpty {
                self.completedGoals = goals
                self.processCompletedGoals(goals: goals, uploadInBackground: true)
            }

            //            for (index, goal) in goals.enumerated() {
            //                self.uploadGoalAsPost(goal: goal, index: index, uploadInBackground: true)
            //            }


        }) { (_) in
            //print("error in api: \(error.message)")
        }
    }

    func processCompletedGoals(goals: [GroupActivity], uploadInBackground: Bool) {
        if pendingGoalsCount < goals.count {
            self.uploadGoalAsPost(goal: goals[pendingGoalsCount], index: pendingGoalsCount, uploadInBackground: true)
        }
    }

    func uploadGoalAsPost(goal: GroupActivity, index: Int, uploadInBackground: Bool) {
        self.initializeDataWith(goal: goal)
        self.screenshotView.isHidden = false

        guard uploadInBackground == true else {
            if let _ = self.screenshotView.screenshot(),
               let screenshot = self.screenshotView.screenshot() {
                self.screenshotView.isHidden = true
                let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()
                createPostVC.type = .goal
                createPostVC.screenshot = screenshot
                createPostVC.isFromActivityLog = true
                self.navigationController?.pushViewController(createPostVC, animated: true)
            }
            return
        }

        //if there is already this goal id uploading, then skip the next process
        if let currentIds = self.currentUploadingGoalIds,
           let thisGoalId = goal.id,
           currentIds.contains(thisGoalId) {
            //skip
            return
        }

        let post = Post()
        if self.currentUploadingGoalIds == nil {
            self.currentUploadingGoalIds = []
        }
        self.currentUploadingGoalIds?.append(goal.id ?? "")
        if let user = UserManager.getCurrentUser() {
            let postOwner = Friends()
            post.user = Friends()
            postOwner.profilePic = user.profilePicUrl
            postOwner.firstName = user.firstName
            postOwner.lastName = user.lastName
            postOwner.id = user.id
            postOwner.userName = user.userName
            post.user = postOwner
        }
        //post.caption = "post: \(index)"
        post.address = Address()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let _ = self.screenshotView.screenshot(),
               let screenshot = self.screenshotView.screenshot() {
                self.screenshotView.isHidden = true
                post.media = [Media]()
                let media = Media()
                media.image = screenshot
                media.type = MediaType.photo
                media.ext = MediaType.photo.mediaExt
                media.data = screenshot.jpegData(compressionQuality: 0.5)
                media.height = Double(screenshot.size.height)
                media.mimeType = Constant.MimeType.image
                post.type = .goal
                post.activityId = goal.id

                //add the media object
                post.media?.append(media)
                let offlineSync = OfflineSync()
                offlineSync.post = post
                offlineSync.UploadMediaToFireBase() { (_) in
                    // do nothing ?
                }
                //increment counter
                self.pendingGoalsCount += 1
                if let completedGoals = self.completedGoals {
                    self.processCompletedGoals(goals: completedGoals, uploadInBackground: true)
                }
            }
        }

    }

    func setScreenshotViewLayout() {
        self.progressDisplayView.setViewsLayoutForGoalScreenshotView()
        self.activityIconImageView.setImageColor(color: UIColor.appThemeColor)
        self.view.layoutIfNeeded()
    }

    func initializeDataWith(goal: GroupActivity) {
        //self.goal = goal
        self.goalNameLabel.text = goal.name
        self.goalDescriptionLabel.text = goal.description
        goal.setActivityLabelAndImage(activityNameLabel, activityIconImageView)
        self.activityIconImageView.setImageColor(color: UIColor.appThemeColor)
        self.updateTimeInView(goal: goal)

        self.activityDurationLabel.text = "Length | \(goal.duration ?? "NA")"
        self.activityStartDateLabel.text = "Start Date | \(goal.startDate?.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? "NA")"
        self.setGoalStatus(goal: goal)

        //updating percentage
        self.progressDisplayView.setBezierProperties(padding: 4.0, focusSize: 6.0, lineWidth: 2.0)
        self.progressDisplayView.completionPercentage = goal.completionPercentage
        self.progressDisplayView.achievedValue = goal.currentAchievedValue
        if let metric = goal.target?.first?.matric {
            self.progressDisplayView.metric = Metrics(rawValue: metric)
        }
        self.progressDisplayView.updateCompletionPercentage()
        self.progressDisplayView.updateProgressInstant()
    }

    private func setGoalStatus(goal: GroupActivity) {
        var goalStatus = ""
        let tematesCount = goal.membersCount ?? 0
        if let status = goal.status {
            switch status {
            case .open:
                goalStatus = AppMessages.GroupActivityMessages.goalInProgress
            case .completed:
                if let goalPercent = goal.completionPercentage,
                   goalPercent >= 100 {
                    goalStatus = AppMessages.GroupActivityMessages.goalAchieved
                } else {
                    goalStatus = AppMessages.GroupActivityMessages.goalIncomplete
                }
            default:
                break
            }
        }
        self.goalStatusAndTematesCountLabel.text = goalStatus + " | " + "\(tematesCount) Tēmates"
    }

    func updateTimeInView(goal: GroupActivity) {
        self.timeLabel.text = goal.remainingTime()
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}


extension Notification.Name {
    static let homeViewRefresh = Notification.Name(
        rawValue: "homeViewRefresh")
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension HomePageViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.bottomCollectionView {
            if isDataLoadedFromServer {
                return tiles.count
            } else {
                return  5
            }

        } else {
            return CollectionCell.allCases.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.bottomCollectionView {
            guard  let cell: HomeCollectionCell = bottomCollectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionCell.reuseIdentifier, for: indexPath) as? HomeCollectionCell  else{
                return UICollectionViewCell()
            }
            if isDataLoadedFromServer {

            if let image = tiles[indexPath.row].image, let url = URL(string: image){
                cell.imageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "ImagePlaceHolder"))
            }
//            if let unreadCount = UserManager.getCurrentUser()?.unreadNotiCount{
//                if tiles[indexPath.row].id ?? "1" == "1" && unreadCount > 0{
//
//                    cell.badgeView.isHidden = false
//                    cell.badgeCountLAbel.text = "\(unreadCount)"
//                } else{
//                    cell.badgeView.isHidden = true
//                }
//            }
            } else {
                cell.imageView.image = #imageLiteral(resourceName: "ImagePlaceHolder")
            }

            return cell
        }
        else{
            if let currentCell = CollectionCell(rawValue: indexPath.item){
                switch currentCell {

                case .health:
                    guard  let cell: HealthCollectionCell = centralCollectionView.dequeueReusableCell(withReuseIdentifier: HealthCollectionCell.reuseIdentifier, for: indexPath) as? HealthCollectionCell  else{
                        return UICollectionViewCell()
                    }

                    cell.setLinesView()
                    switch self.pageLoadingStates[currentCell.rawValue] {
                    case .isLoaded:
                        print("")
                        cell.setScore(value: lastSavedActivityScore, withAnimation: false)
                    default:
                        cell.setViewStateFor(loadingState: pageLoadingStates[currentCell.rawValue])
                    }
                    return cell
                case .social:
                    guard  let cell: SocialCollectionCell = centralCollectionView.dequeueReusableCell(withReuseIdentifier: SocialCollectionCell.reuseIdentifier, for: indexPath) as? SocialCollectionCell  else{
                        return UICollectionViewCell()
                    }
                    cell.delegate = self
                    cell.initializeData()
                    switch self.pageLoadingStates[currentCell.rawValue] {
                    case .isLoaded:
                        cell.leaderboard = self.myLeaderboard
                        cell.setViewStateFor(loadingState: self.pageLoadingStates[CollectionCell.social.rawValue])
                    default:
                        cell.setViewStateFor(loadingState: pageLoadingStates[currentCell.rawValue])
                    }
                    return cell
                }
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.bottomCollectionView && isDataLoadedFromServer {
            let tileType = tiles[indexPath.row].id ?? "1"
            let tile = TileType(rawValue: Int(tileType) ?? 1)
            switch tile {
            case .whatsNew:
                let selectedVC:NotificationsController = UIStoryboard(storyboard: .notification).initVC()
                    selectedVC.screenFrom = .dashboard
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .foodTrek:
                let foodTrekListingVC:FoodTrekListingVC = UIStoryboard(storyboard: .foodTrek).initVC()
                self.navigationController?.pushViewController(foodTrekListingVC, animated: true)
            case .temTv:
                let selectedVC:TemTvViewController = UIStoryboard(storyboard: .temTv).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .goalsAndChallenges:
                let selectedVC:ChallangeDashBoardController = UIStoryboard(storyboard: .challenge).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .temStore:
                let selectedVC = loadVC(.ProductListingViewController) as! ProductListingViewController
                if let nav = UIApplication.topViewController()?.navigationController {
                    NavigTO.navigateTo?.navigation = nav
                    nav.pushViewController(selectedVC, animated: true)
                }
            case .contentMarket:
                let seeAllVC: SeeAllVC = UIStoryboard(storyboard: .dashboard).initVC()
                seeAllVC.challengeId = self.challengeId
                seeAllVC.selectedContent = .contentMarket
                    seeAllVC.updateNotificationsCountHandler = { [weak self] in
                        self?.updateBadgeView()
                    }
                self.navigationController?.pushViewController(seeAllVC, animated: true)
                case .coachingTools:
                    let journeyVC: MyJourneyViewController = UIStoryboard(storyboard: .coachingTools).initVC()
                    self.navigationController?.pushViewController(journeyVC, animated: true)
                default:
                    break
            }
        }
    }


    @objc func onClickedActivityButton(_ sender: Any?) {
        let createProfileVC:ReportViewController = UIStoryboard(storyboard: .reports).initVC()
        self.navigationController?.pushViewController(createProfileVC, animated: true)
    }
}


// MARK: UICollectionViewDelegateFlowLayout
extension HomePageViewController: UICollectionViewDelegateFlowLayout{



    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if collectionView == self.bottomCollectionView {
            if Constant.DeviceType.IS_IPHONE_6 || Constant.DeviceType.IS_IPHONE_4_OR_LESS || Constant.DeviceType.IS_IPHONE_6P {
                return CGSize(width: bottomCollectionView.frame.width / 1.5 + 10, height: bottomCollectionView.frame.height)
            }
            return CGSize(width: bottomCollectionView.frame.width / 1.5 + 10, height: bottomCollectionView.frame.height)

      }
        else {
            let itemWidth = centralCollectionView.bounds.width
            let itemHeight = centralCollectionView.bounds.height
            return CGSize(width: itemWidth, height: itemHeight)

        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == bottomCollectionView{
            return CGFloat(5)
        }
        else {
            return CGFloat(0)
        }
    }
}

// MARK: SocialCollectionCellDelegate
extension HomePageViewController: SocialCollectionCellDelegate {
    func didTapOnViewLeaderboard() {
        let leaderboardVC: LeaderboardViewController = UIStoryboard(storyboard: .dashboard).initVC()
        leaderboardVC.delegate = self
        self.navigationController?.pushViewController(leaderboardVC, animated: true)
    }

    func didTapOnNewPost() {
        let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()

        createPostVC.isForCreatePost = true
        self.navigationController?.pushViewController(createPostVC, animated: true)
    }

    func didTapOnViewFeed() {
        let feedsVC: FeedsViewController = UIStoryboard(storyboard: .post).initVC()
        self.navigationController?.pushViewController(feedsVC, animated: true)
    }
}

// MARK: UIScrollViewDelegate
extension HomePageViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == centralCollectionView {
            let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
            self.currentPage = index + 1 //adding 1 because the index will have values like 0, 1, 2...
            self.shiftPageControl(at: self.currentPage, isPageControlTapped: false)
        }
    }
}


// MARK: HomeLeaderboardViewDelegate
extension HomePageViewController: HomeLeaderboardViewDelegate {
    func updateNewMembersInLeaderboard(leaderboard: MyLeaderboard?) {
        self.myLeaderboard = leaderboard
        _ = self.myLeaderboard?.addedTemates?.removeFirst()
        self.pageLoadingStates[CollectionCell.social.rawValue] = .isLoaded
        self.updateLeaderboardCell()
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

