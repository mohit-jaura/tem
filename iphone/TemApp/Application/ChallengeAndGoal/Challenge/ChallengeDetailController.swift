//
//  ChallengeDetailController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SSNeumorphicView

protocol ChallengeDelegate: AnyObject {
    func checkActivityStatus(activityId:String)
}

class ChallengeDetailController: DIBaseController {
    weak var delegate: ChallengeDelegate?
    var showMetrics = false
    var showMetricIndexPath: IndexPath?
    
    let networkLayer = DIWebLayerActivityAPI()
    private var foregroundObserver: NSObjectProtocol?
    
    var challengeId: String?
    var challenge: GroupActivity?
    
    private var currentTab: ChallengeDetailTab = .info
    private var currentPage: Int = 1
    private var noMorePages = false
    private var timer: Timer?
    internal var isAddedAsShortcutOnHomeScreen = CustomBool.no
    private var refreshScreen: Bool = false
    
    @IBOutlet weak var screenshotView: UIView!
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityIcon: UIImageView!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var leaderboard: UIView!
    @IBOutlet weak var leaderImage: UIImageView!
    @IBOutlet weak var leaderName: UILabel!
    @IBOutlet weak var leaderRank: UILabel!
    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var currentUserRank: UILabel!
    @IBOutlet weak var currentUserMetricsValue: UILabel!
    @IBOutlet weak var challengeStartDate: UILabel!
    @IBOutlet weak var challengeDuration: UILabel!
    @IBOutlet weak var tematesCount: UILabel!
    @IBOutlet weak var challengeMetrics: UILabel!
    var selectedDate:Date?
    @IBOutlet weak var navigationBarLineView: SSNeumorphicView! {
        didSet{
            navigationBarLineView.viewDepthType = .outerShadow
            navigationBarLineView.viewNeumorphicMainColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
            navigationBarLineView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            navigationBarLineView.viewNeumorphicDarkShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
            navigationBarLineView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    private var pageController: ChallengeDetailPageController?
    var joinHandler: OnlySuccess?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotificationObservers()
        initUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if self.refreshScreen {
            self.refreshScreen = false
        }
        self.refresh()
        self.createTimer()
        self.pageController = (self.children.first as! ChallengeDetailPageController)
        self.pageController?.challengeId = self.challengeId
        pageController?.selectChallengeDetailPageDelegate = self
        self.pageController?.joinHandler = { [weak self] in
            if let joinHandler = self?.joinHandler {
                joinHandler()
            }
        }
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main, using: { (_) in
            self.refresh()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cancelTimer()
        self.removeNotificationObservers()
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    deinit {
        if self.challenge?.openToPublic == false {
            self.delegate?.checkActivityStatus(activityId: self.challenge?.id ?? "0")
        }
    }
    
    // MARK: Custom Functions.
    private func initUI() {
        editButton.isHidden = true
        editImageView.isHidden = true
        if let currentType = self.challenge?.status {
            switch currentType {
            case .open, .upcoming:
                if let ownerId = self.challenge?.challengeCreatorId,
                   let currentUserId = UserManager.getCurrentUser()?.id,
                   currentUserId == ownerId {
                    editImageView.isHidden = false
                    editButton.isHidden = false
                }else{
                    editButton.isHidden = true
                    editImageView.isHidden = true
                }
            case .completed:
                break
            }
        }
    }
    
    @IBAction func editTapped(_ sender: UIButton) {
        let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
        controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
        controller.isType = false
        if let groupDetail = challenge?.groupDetail {
            controller.selectedGroup = groupDetail.toCustomChatGroup()
        }
        let members = self.challenge?.members?.filter({ (member) -> Bool in
            if member.id != UserManager.getCurrentUser()?.id ?? "" {
                return member.type ?? .temate == ActivityMemberType.temate
            }
            return false
        }).map({$0.toCustomUserType()})
        controller.selectedFriends = members
        controller.isEditingCurrentActivity = true
        let groupActivityInfo = self.challenge
        
        if let type = challenge?.activityMembersType {
            if type == .temVsTem {
                let filteredType1 = self.challenge?.teamsArray?.filter({ (leaderboard) -> Bool in
                    return leaderboard.teamType == 1
                })
                if let filtered = filteredType1,
                   !filtered.isEmpty {
                    let tem1 = filtered.first?.leaderboardMember?.toGroupActivityTem()
                    groupActivityInfo?.tem1 = tem1
                    groupActivityInfo?.tem1?.teamType = 1
                } else {
                    let tem1 = self.challenge?.teamsArray?.first?.leaderboardMember?.toGroupActivityTem()
                    groupActivityInfo?.tem1 = tem1
                }
                //tem2
                let filteredType2 = self.challenge?.teamsArray?.filter({ (leaderboard) -> Bool in
                    return leaderboard.teamType == 2
                })
                if let filtered2 = filteredType2,
                   !filtered2.isEmpty {
                    let tem2 = filtered2.first?.leaderboardMember?.toGroupActivityTem()
                    groupActivityInfo?.tem2 = tem2
                    groupActivityInfo?.tem2?.teamType = 2
                } else {
                    let tem2 = self.challenge?.teamsArray?.last?.leaderboardMember?.toGroupActivityTem()
                    groupActivityInfo?.tem2 = tem2
                }
            } else if type == .individualVsTem {
                controller.selectedGroup = self.challenge?.teamsArray?.first?.leaderboardMember?.toGroupActivityTem().toChatRoomType()
            }
        }
        controller.groupActivityInfo = groupActivityInfo
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func backTapped(_ sender: UIButton) {
      self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func infoTabTapped(_ sender: UIButton) {
    }
    
    @IBAction func fundraisingTabTapped(_ sender: Any) {
    }
    
    func swipeNewController(forPage page: ChallengeDetailTab, animated: Bool? = true) {
        if let pageController = self.pageController {
            pageController.setCurrentVisibleControllerAt(page: page, animated: animated!)
        }
    }
    
    private func changeNavigationForCurrentPage() {
    }
    private func setShareButtonOnNavigationBar() {
        if let currentType = self.challenge?.status {
            switch currentType {
            case .open, .completed:
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "postShare"), for: .normal)
                button.tintColor = UIColor.textBlackColor
                button.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
                button.addTarget(self, action: #selector(shareTapped(sender:)), for: .touchUpInside)
                let rightBarButtonItem = UIBarButtonItem(customView: button)
                rightBarButtonItem.tintColor = UIColor.textBlackColor
                self.navigationItem.rightBarButtonItem = rightBarButtonItem
            default:
                break
            }
        }
    }
    
    private func setEditButtonOnNavigationBar() {
        if let currentType = self.challenge?.status {
            switch currentType {
            case .open, .upcoming:
                if let barItems = self.navigationItem.rightBarButtonItems,
                   barItems.contains(where: {$0.tag == 1004}) {
                    return
                }
                if let ownerId = self.challenge?.challengeCreatorId,
                   let currentUserId = UserManager.getCurrentUser()?.id,
                   currentUserId == ownerId {
                    let button = UIButton(type: .system)
                    button.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
                    button.tintColor = UIColor.textBlackColor
                    button.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
                    button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
                    let rightBarButtonItem = UIBarButtonItem(customView: button)
                    rightBarButtonItem.tintColor = UIColor.textBlackColor
                    rightBarButtonItem.tag = 1004
                    if self.navigationItem.rightBarButtonItems == nil {
                        self.navigationItem.rightBarButtonItems = []
                    }
                    self.navigationItem.rightBarButtonItems?.append(rightBarButtonItem)
                }
            default:
                break
            }
        }
    }
    
    @objc func shareTapped(sender: UIBarButtonItem) {
        self.shareChallengeToNewsFeed()
    }

    @objc func updateShortcutButtonTapped(sender: UIBarButtonItem) {
    }
    
    private func checkIfAddedOnHomeScreen() {
        guard let id = self.challengeId else {
            return
        }
        DIWebLayerUserAPI().getHomeScreenStatus(type: .challenge, id: id, completion: { (status) in
            guard let statusValue = CustomBool(rawValue: status) else {
                return
            }

        }) { (_) in
        }
    }
    
    private func use(challenge: GroupActivity) {
        self.createTimer()
        
        if let pageController = self.pageController {
            var tabs: [ChallengeDetailTab] = [.info]
            if challenge.fundraising != nil {
                tabs.append(.fundraising)
            }
            pageController.initialize(tabs, challenge, self)
        }
        self.updateTabBar(challenge)
        
        if !self.refreshScreen {
            initUI()
        }
        self.refreshScreen = false
        self.setDataInShareView()
    }
    
    private func updateTabBar(_ challenge: GroupActivity) {
    }
    
    // MARK: Notification Observers Helpers
    private func addNotificationObservers() {
        self.removeNotificationObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(challengeEdited), name: Notification.Name.challengeEdited, object: nil)
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.challengeEdited, object: nil)
    }
    
    @objc func challengeEdited() {
        self.refresh()
        self.refreshScreen = true
    }
    
    // MARK: Helper functions
    private func createTimer() {
        if let currentChallenge = self.challenge,
           let status = currentChallenge.status,
           status == .completed {
            //if this is the completed or past challenge, we don't need to create the timer here
            return
        }
        if timer == nil {
            self.tickTimer()
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
        self.remainingTime.text = self.challenge?.remainingTime()
        self.pageController?.handleTick()
    }
    
    // MARK: Share challenge
    private func setDataInShareView() {
        guard let challenge = challenge else {
            return
        }
        self.challengeName.text = challenge.name
        challenge.setActivityLabelAndImage(activityName, activityIcon)
        self.activityIcon.setImageColor(color: UIColor.appThemeColor)
        self.challengeStartDate.text = challenge.startDate?.timestampInMillisecondsToDate.displayDate()
        self.tematesCount.text = "\(challenge.membersCount ?? 0)"
        self.challengeMetrics.text = challenge.metricsFormattedString()
        self.challengeDuration.text = challenge.duration
        self.leaderName.text = challenge.leader?.fullName
        self.leaderImage.image = #imageLiteral(resourceName: "user-dummy")
        if let leaderImage = challenge.leader?.profilePic,
           let url = URL(string: leaderImage) {
            self.leaderImage.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }
        if let currentUser = UserManager.getCurrentUser() {
            if let image = currentUser.profilePicUrl,
               let url = URL(string: image) {
                self.currentUserImage.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }
        }
        self.setMetricsInfoOnScreenshotView()
        let rank = challenge.myScore?.first?.rank ?? 0
        self.currentUserRank.text = "Rank \(rank)"
    }
    
    //set metrics information
    private func setMetricsInfoOnScreenshotView() {
        guard let selectedMetrics = self.challenge?.selectedMetrics else {
            return
        }
        var displayString = ""
        var concatString = ", "
        for (index, metric) in selectedMetrics.enumerated() {
            if let metricValue = Metrics(rawValue: metric) {
                let text = metricsTextFor(metric: metricValue)
                if index == selectedMetrics.count - 1 {
                    concatString = ""
                }
                displayString += "\(text)\(concatString)"
            }
        }
        self.currentUserMetricsValue.text = displayString
    }
    
    /// this function is returning the metric text appending with the value of that metric corresponding to the current user
    ///
    /// - Parameter metric: current metric
    /// - Returns: display text
    private func metricsTextFor(metric: Metrics) -> String {
        guard let myScore = self.challenge?.myScore?.first else {
            return ""
        }
        switch metric {
        case .steps:
            if let steps = myScore.steps?.toInt() {
                return "\(steps) \(metric.title)"
            }
        case .calories:
            if let calories = myScore.calories {
                return "\(calories.rounded(toPlaces: 2)) \(metric.title)"
            }
        case .distance:
            if let distance = myScore.distance {
                return "\(distance.rounded(toPlaces: 2)) Miles \(metric.title)"
            }
        case .totalActivites:
            if let totalAct = myScore.totalActivities?.toInt() {
                return "\(totalAct) \(metric.title)"
            }
        case .totalActivityTime:
            if let totalTime = myScore.totalTime?.toInt() {
                let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTime)
                
                let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                return "\(displayTime) \(metric.title )"
            }
        default:
            break
        }
        return ""
    }
    
    private func shareChallengeToNewsFeed() {
        if let screenshot = self.screenshotView.screenshot() {
            let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()
            createPostVC.type = .challenge
            createPostVC.screenshot = screenshot
            createPostVC.isFromActivityLog = true
            self.navigationController?.pushViewController(createPostVC, animated: true)
        }
    }
}

// MARK: ShortCutButtonConfigurable, AddToHomeScreenViewable
extension ChallengeDetailController: ShortCutButtonConfigurable, AddToHomeScreenViewable {
    func updateToHomeScreenShortcut(sender: UIButton) {
        self.onClickOfShortcut()
    }
    
    func addOrRemoveFromHomeScreen() {
        if isConnectedToNetwork() {
            self.showLoader()
            var params = HomeScreenShortcut()
            params.type = .challenge
            params.id = self.challengeId ?? ""
            params.name = self.challenge?.name ?? ""
            if isAddedAsShortcutOnHomeScreen == .yes{
                params.status = .no
            } else {
                params.status = .yes
            }
            DIWebLayerUserAPI().updateToHomeScreen(parameters: params.json(), completion: { (_) in
                self.hideLoader()
                self.updateShortCutView()
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "")
            }
        }
    }
}

extension ChallengeDetailController : RefreshGNCEventDelegate {
    func refresh() {
        noMorePages = false
        currentPage = 1
        loadChallenge()
    }
    
    func nextPage() {
        if !noMorePages {
            currentPage += 1
            loadChallenge()
        }
    }
    
    private func loadChallenge() {
        guard Reachability.isConnectedToNetwork() else {
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
            return
        }
        guard let id = self.challengeId else {
            return
        }
        networkLayer.getChallengeDetailsBy(id: id, page: currentPage) { (challenge, _) in
            if self.currentPage > 1 {
                // if this is not the first page, just append the leaderboard members data to the challenge
                if let scoreboard = challenge.leaderboardArray {
                    if let type = challenge.activityMembersType {
                        if type == .individualVsTem {
                            self.challenge?.scoreboardForTemVsInd?.append(contentsOf: scoreboard)
                        } else if type == .temVsTem {
                            self.challenge?.teamsArray?.append(contentsOf: scoreboard)
                        } else {
                            self.challenge?.scoreboard?.append(contentsOf: scoreboard)
                        }
                    } else {
                        self.challenge?.scoreboard?.append(contentsOf: scoreboard)
                    }
                }
            } else {
                challenge.type = .challenge
                self.challenge = challenge
            }
            self.challenge?.type = .challenge
            
            self.use(challenge: challenge)
        } failure: { (error) in
            if let message = error.message {
                self.showAlert(message: message)
            }
        }
    }
}

extension ChallengeDetailController : SelectChallengeDetailPageDelegate {
    func select(page: ChallengeDetailTab) {
        self.currentTab = page
        self.changeNavigationForCurrentPage()
    }
}
