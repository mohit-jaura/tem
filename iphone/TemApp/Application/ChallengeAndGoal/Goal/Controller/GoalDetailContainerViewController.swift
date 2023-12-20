//
//  GoalDetailContainerViewController.swift
//  TemApp
//
//  Created by shilpa on 13/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SSNeumorphicView
protocol RefreshGNCEventDelegate {
    func refresh()
    func nextPage()
}

protocol UpdateGNCEventInfoProtocol {
    func use(_ event: GroupActivity)
}

protocol UpdateByTimerProtocol {
    func handleTick()
}

class GoalDetailContainerViewController: DIBaseController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var chatterHeight: NSLayoutConstraint!
    @IBOutlet weak var metricNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fundraisingLabel: UILabel!
    @IBOutlet weak var goalProgressDisplayView: GoalProgressDisplayView!
    @IBOutlet weak var tableBackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backShadowView: SSNeumorphicView!{
        didSet{
            backShadowView.setOuterDarkShadow()
            backShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    @IBOutlet weak var tableBackView: SSNeumorphicView!{
        didSet{
            tableBackView.setOuterDarkShadow()
            tableBackView.viewDepthType = .innerShadow
            tableBackView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var descriptionBackView: SSNeumorphicView!{
        didSet{
            descriptionBackView.setOuterDarkShadow()
            descriptionBackView.viewDepthType = .innerShadow
            descriptionBackView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    @IBOutlet weak var infoView1: UIView!
    @IBOutlet weak var infoShadowView:SSNeumorphicView!{
        didSet{
            infoShadowView.setOuterDarkShadow()
            infoShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var honeyCombImageView:UIImageView!{
        didSet{
            setImageShape()
        }
    }
    private var activityChatView: ActivityDetailChatTableViewCell?
    @IBOutlet weak var honeyCombShapeView:UIView!
    @IBOutlet weak var chatter: UIView!
    @IBOutlet weak var activityNameShadowView:SSNeumorphicView!{
        didSet{
            activityNameShadowView.setOuterDarkShadow()
            activityNameShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var tematesShadowView:SSNeumorphicView!{
        didSet{
            tematesShadowView.setOuterDarkShadow()
            tematesShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    func setImageShape(){
        let path = UIBezierPath(rect: honeyCombImageView.bounds, sides: 6, lineWidth: 5, cornerRadius: 0)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        honeyCombImageView.layer.mask = mask
    }
    
    @IBOutlet weak var donateShadowView:SSNeumorphicView!{
        didSet{
            donateShadowView.setOuterDarkShadow()
            donateShadowView.viewNeumorphicMainColor = UIColor(red: 3.0 / 255.0, green: 246.0 / 255.0, blue: 240.0 / 255.0, alpha: 0.92).cgColor
        }
    }
    
    @IBOutlet weak var activityNameLbl:UILabel!
    
    @IBOutlet weak var tematesLbl:UILabel!
    
    @IBOutlet weak var durationLbl:UILabel!
    
    
    weak var delegate: ChallengeDelegate?
    private var currentTab: GoalDetailTab = .progress
    var isComingFromNotification = false
    public var selectedGoalName: String?
    
    var isAddedAsShortcutOnHomeScreen: CustomBool = .no
    private let chatManager = ChatManager()
    /// dictionary which will store the userids as key and respective user information as value
    var userInfo: [String: Any] = [:]
    var userInfoListener: ListenerRegistration?
    var messagesArray: [Message]?
    let messagesLimit = 5
    private var timer: Timer?
    
    public var goalId: String?
    private var goal: GroupActivity?
    
    private var currentPage: Int = 1
    private var noMorePages = false
    private var goalModel: GoalModel
    private var foregroundObserver: NSObjectProtocol?
    var activeGoalsJoinHandler: OnlySuccess?
    // MARK: IBOutlets
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var progressTab: UIView!
    @IBOutlet weak var progressLine: UIView!
    @IBOutlet weak var fundraisingTab: UIView!
    @IBOutlet weak var fundraisingLine: UIView!
    @IBOutlet weak var tematesTab: UIView!
    @IBOutlet weak var tematesLine: UIView!
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var screenshotView: UIView!
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var goalDescLabel: UILabel!
    @IBOutlet weak var goalStatusAndTematesCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var goalDurationLabel: UILabel!
    @IBOutlet weak var goalStartDateLabel: UILabel!
    @IBOutlet weak var progressDisplayView: GoalProgressDisplayView!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    private var pageController: GoalDetailPageViewController?
    
    required init?(coder: NSCoder) {
        self.goalModel = GoalModel()
        super.init(coder: coder)
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUserInterface()
        self.tableView.registerNibs(nibNames: [LeaderboardTableCell.reuseIdentifier])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pageController = (self.children.first as! GoalDetailPageViewController)
        self.pageController?.goalId = self.goalId
        pageController?.selectGoalDetailPageDelegate = self
        self.navigationController?.setTransparentNavigationBar()
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main, using: { (_) in
            self.refresh()
        })
        self.refresh()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.chatManager.messageListener?.remove()
        self.userInfoListener?.remove()
        if self.goal?.openToPublic == false {
            self.delegate?.checkActivityStatus(activityId: self.goal?.id ?? "0")
        }
        self.cancelTimer()
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Initializer
    private func createUserInterface() {
        self.tabBar.isHidden = true
        self.setScreenshotViewLayout()
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = true
    }
    
    private func setNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(customView: self.getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.goal(type: nil).title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setTransparentNavigationBar()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: IBActions
    
    @IBAction func temmatesTapped() {
        let expendedVC: EventDetailsExpendedViewController = UIStoryboard(storyboard: .calendar).initVC()
        expendedVC.activityDetail = self.goal
        self.navigationController?.pushViewController(expendedVC, animated: true)
    }
    @IBAction func progressTabTapped(_ sender: UIButton) {
        guard currentTab != .progress else {
            return
        }
        self.currentTab = .progress
        self.changeNavigationForCurrentPage()
        self.swipeNewController(forPage: .progress)
    }
    
    @IBAction func fundraisingTabTapped(_ sender: Any) {
        guard currentTab != .fundraising else {
            return
        }
        self.currentTab = .fundraising
        self.changeNavigationForCurrentPage()
        self.swipeNewController(forPage: .fundraising)
    }
    
    @IBAction func tematesTabTapped(_ sender: UIButton) {
        guard currentTab != .temates else {
            return
        }
        self.currentTab = .temates
        self.changeNavigationForCurrentPage()
        self.swipeNewController(forPage: .temates)
    }
    
    // MARK: Chat Helpers
    private func listenToThisChatRoom() {
        guard let roomId = self.goal?.id else {
            return
        }
        self.chatManager.listenToChatRoom(withId: roomId, fromTime: nil, isPublicRoom: true, fetchLatestFirst: false, completion: {[weak self] (messages) in
            self?.setMessagesData(messages: messages)
        }) { (_) in
        }
    }
    
    private func setMessagesData(messages: [Message]) {
        if messagesArray == nil {
            messagesArray = []
        }
        for message in messages {
            if message.id == nil { //for an empty message, skip the process
                continue
            }
            //first check if the message is updated or new
            if let updationTime = message.updatedAt, let creationTime = message.time, updationTime != creationTime {
                //that means the message was updated
                let indexOfMessage = self.messagesArray?.firstIndex { (msg) -> Bool in
                    return msg.id == message.id
                }
                if let index = indexOfMessage {
                    //update at index
                    self.messagesArray?[index] = message
                } else {
                    self.updateMessageInArray(message: message, newMessagesCount: messages.count)
                }
            } else {
                let isContained = self.messagesArray?.contains { (msg) -> Bool in
                    return msg.id == message.id
                }
                if let isContained = isContained {
                    //if it is already contained, do not add it to the list
                    if !isContained {
                        self.updateMessageInArray(message: message, newMessagesCount: messages.count)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.reloadChatterView()
        }
    }
    
    private func getUserInfo() {
        self.messagesArray?.forEach({ (message) in
            guard let senderId = message.senderId else {
                return
            }
            self.getMessageSenderInformation(senderId: senderId)
        })
    }
    
    /// fetch the user information from firestore for sender id in each message
    /// - Parameter senderId: user id
    func getMessageSenderInformation(senderId: String?) {
        if senderId == UserManager.getCurrentUser()?.id {
            return
        }
        guard let userId = senderId,
              !userId.isEmpty else {
            return
        }
        //first check if the userInfo dictionary already contains this id
        if self.userInfo[userId] != nil {
            return
        }
        self.userInfoListener = chatManager.getUserInformationFrom(userId: userId, completion: {[weak self] (chatMember) in
            if let id = chatMember.user_id {
                self?.userInfo[id] = chatMember
            }
            self?.reloadChatterView()
        }, failure: { (_) in
        })
    }
    
    private func reloadChatterView() {
        if let messages = self.messagesArray {
            self.activityChatView?.userInfo = userInfo
            self.activityChatView?.initializeWith(messages: messages)
        }
    }
    
    /// add or update message in the respective array
    /// - Parameter message: new message
    private func updateMessageInArray(message: Message, newMessagesCount: Int) {
        if message.type! == .image || message.type! == .video {
            if let uploadingStatus = message.mediaUploadingStatus {
                switch uploadingStatus {
                    case .isUploading, .uploadingError:
                        if message.senderId == UserManager.getCurrentUser()?.id {
                            //this message was sent by me, hence it is to be shown on screen
                            self.messagesArray?.append(message)
                        }
                    case .isUploaded:
                        self.messagesArray?.append(message)
                }
            }
        } else {
            //this means this was a text message
            self.messagesArray?.append(message)
        }
        self.removeExtraMessagesFromArray()
        self.getUserInfo()
    }
    
    /// maintains the array limit equals to that of the limit set
    private func removeExtraMessagesFromArray() {
        if let count = self.messagesArray?.count,
           count > messagesLimit {
            self.messagesArray?.removeFirst()
        }
    }
    
    // MARK: Screenshot view helpers
    func setScreenshotViewLayout() {
        self.progressDisplayView.setViewsLayoutForGoalScreenshotView()
        self.goalProgressDisplayView.setViewsLayoutForOpenGoalView1()
        self.view.layoutIfNeeded()
    }
    
    // MARK: IBActions..
    @IBAction func joinTapped(_ sender: UIButton) {
        guard self.isConnectedToNetwork() else {
            return
        }
        if let goalId = self.goal?.id {
            self.showLoader()
            let params = JoinActivityApiKey().toDict()
            DIWebLayerGoals().joinGoal(id: goalId, parameters: params, completion: { [weak self](result) in
                NotificationCenter.default.post(name: Notification.Name.activityJoined, object: nil, userInfo: ["id": goalId])
                self?.hideLoader()
                self?.goal?.isActivityJoined = result
                if let membersCount = self?.goal?.membersCount {
                    self?.goal?.membersCount = membersCount + 1
                }
                self?.setJoinGoalStatus(activity: self?.goal ?? GroupActivity())
                self?.setChatterViewDisplay()
                if let activeGoalsJoinHandler = self?.activeGoalsJoinHandler {
                    activeGoalsJoinHandler()
                }
            }) { (error) in
                self.hideLoader()
                self.showAlert(withError: error, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: nil, okCall: {
                    self.navigationController?.popViewController(animated: true)
                }, cancelCall: {
                    
                })
            }
        }
        
    }
    
    /// set the chatter view visibility
    private func setChatterViewDisplay() {
        if let isOpened = self.goal?.openToPublic,
           !isOpened,
           let isJoined = self.goal?.isActivityJoined,
           isJoined == false {
            //only joinees can view and chat
            self.chatterHeight.constant = 0
            return
        }
        self.chatterHeight.constant = 255
    }
    
    private func setJoinGoalStatus(activity: GroupActivity) {
        self.joinButton.isHidden = true
        if let status = activity.status,
           let joinedStatus = activity.isActivityJoined {
            switch status {
                case .open:
                    if joinedStatus == false {
                        self.joinButton.isHidden = false
                    }
                case .upcoming:
                    self.joinButton.isHidden = false
                    if joinedStatus == true {
                        self.joinButton.isUserInteractionEnabled = false
                        self.joinButton.setTitle(AppMessages.GroupActivityMessages.joined, for: .normal)
                    } else {
                        self.joinButton.isUserInteractionEnabled = true
                        self.joinButton.setTitle(AppMessages.GroupActivityMessages.joinTitle, for: .normal)
                    }
                default:
                    break
            }
        }
    }
    
    
    private func use(goal: GroupActivity) {
        self.descriptionTextView.text = goal.description
        self.goalNameLabel.text = goal.name
        self.goalDescLabel.text = goal.description
        goal.setActivityLabelAndImage(activityNameLabel, activityIconImageView)
        activityIconImageView.tintColor = UIColor.white
        if let ownerId = self.goal?.goalCreatorId,
           let currentUserId = UserManager.getCurrentUser()?.id,
           currentUserId == ownerId {
            editButton.isHidden = false
            editImageView.isHidden = false
        }else{
            editButton.isHidden = true
            editImageView.isHidden = true
        }

        self.updateTimeInView(goal: goal)
        donateButton.isHidden = goal.status == .completed
        self.createTimer()
        if let imageUrl = self.goal?.image,
           let url = URL(string: imageUrl) {
            self.honeyCombImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }else{
            self.honeyCombImageView.image = UIImage(named: "placeholder")
        }
        
        self.selectedGoalName = goal.name
        if goal.fundraising != nil {
            donateButton.isHidden = false
            donateShadowView.isHidden = false
        } else {
            donateButton.isHidden = true
            donateShadowView.isHidden = true
        }
        self.updateTabBar()
        switch goal.status{
            case .open:
                self.durationLbl.text = "\(goal.remainingTime())"
            case .completed:
                self.durationLbl.text = "Expired"
            case .upcoming:
                self.durationLbl.text = "\(goal.remainingTime())"
            case .none:
                break
        }
        self.goalDurationLabel.text = "Length | \(goal.duration ?? "NA")"
        self.goalStartDateLabel.text = "Start Date | \(goal.startDate?.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? "NA")"
        self.setGoalStatus(goal: goal)
        setJoinGoalStatus(activity: goal)
        //updating percentage
        self.progressDisplayView.setBezierProperties(padding: 4.0, focusSize: 6.0, lineWidth: 2.0)
        self.progressDisplayView.completionPercentage = goal.completionPercentage
        self.progressDisplayView.achievedValue = goal.currentAchievedValue
        if let metric = goal.target?.first?.matric {
            let value = Metrics(rawValue: metric)
            self.metricNameLabel.text = "METRIC: \(Int(goal.target?.first?.value ?? 0.0)) \(value?.title ?? "")"
        }
        statusLabel.text = "\(Int(goal.completionPercentage ?? 0))% Complete"
        let collectedAmount = goal.fundraising?.collectedAmount ?? 0
        let totalAmount = goal.fundraising?.goalAmount ?? 0
        self.fundraisingLabel.text = "FUNDRAISING GOAL: $\(collectedAmount) of $\(totalAmount)"
        self.progressDisplayView.updateCompletionPercentage()
        self.progressDisplayView.updateProgressInstant()
        if goal.openToPublic == true || goal.isActivityJoined == true {
            self.listenToThisChatRoom()
        }
        //New Goal View
        self.goalProgressDisplayView.setBezierProperties(padding: 4.0, focusSize: 6.0, lineWidth: 3.0)
        self.goalProgressDisplayView.completionPercentage = goal.completionPercentage
        self.goalProgressDisplayView.achievedValue = goal.currentAchievedValue
        if let metric = goal.target?.first?.matric,
           let metricParam = Metrics(rawValue: metric) {
            self.goalProgressDisplayView.metric = metricParam
        }
        self.goalProgressDisplayView.updateCompletionPercentage()
        self.goalProgressDisplayView.updateProgressInstant()
        tableView.reloadData()
    }
    
    private func calculateDuration(startDate:Int,endDate:Int) -> String {
        let startDate = startDate.timestampInMillisecondsToDate
        let endDate = endDate.timestampInMillisecondsToDate
        
        let startDateString = startDate.toString(inFormat: .displayDate)
        let endDateString = endDate.toString(inFormat: .displayDate)
        
        let diff = Calendar.current.dateComponents([.day], from: startDateString?.toDate(dateFormat: .displayDate) ?? Date(), to: endDateString?.toDate(dateFormat: .displayDate) ?? Date())
        let days = diff.day
        return days ?? 0 <= 1 ? "\(days ?? 0) Day Left" : "\(days ?? 0) Days Left"
    }
    
    @IBAction func startDonation(_ sender: Any) {
        if let event = self.goal {
            DIWebLayerGoals().startDonation(event: event) { (response) in
                if let completed = response.completed, completed {
                    self.showAlert(withTitle: AppMessages.Fundraising.title, message: AppMessages.Fundraising.fundraisingFinished)
                }
                else if let link = response.link, let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            } failure: { (error) in
                self.showAlert(message: error.message ?? "")
            }
            
        }
    }
    
    private func updateTabBar() {
        if let goal = self.goal {
            if goal.status != .upcoming {
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "postShare"), for: .normal)
                button.tintColor = UIColor.textBlackColor
                button.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
                button.addTarget(self, action: #selector(rightBarButtonTapped(button:)), for: .touchUpInside)
                let rightBarButtonItem = UIBarButtonItem(customView: button)
                rightBarButtonItem.tintColor = UIColor.textBlackColor
                self.navigationItem.rightBarButtonItem = rightBarButtonItem
            }
            if let goalType = self.goal?.status {
                if goalType == .open || goalType == .upcoming {
                    if let barItems = self.navigationItem.rightBarButtonItems, barItems.contains(where: {$0.tag == 1004}) {
                        return
                    }
                    if let ownerId = self.goal?.goalCreatorId,
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
                }
            }
            self.tabBar.isHidden = false
            self.fundraisingTab.isHidden = goal.fundraising == nil
        }
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
        self.goalStatusAndTematesCountLabel.text = "\(goal.getTematesLabel())"
    }
    
    func updateTimeInView(goal: GroupActivity) {
        if let startDate = goal.startDate,
           let formattedStartDate = startDate.timestampInMillisecondsToDate.displayDate(),
           let endDate = goal.endDate {
            self.timeLabel.text = "Duration: \(formattedStartDate + " - " + (endDate.timestampInMillisecondsToDate.displayDate() ?? ""))"
        }
    }
    
    private func createTimer() {
        if let goal = self.goal, let status = goal.status, status == .completed {
            self.cancelTimer()
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
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func tickTimer() {
        self.pageController?.handleTick()
    }
    
    // MARK: Api Calls
    private func checkIfAddedOnHomeScreen() {
        guard let id = self.goalId else {
            return
        }
        DIWebLayerUserAPI().getHomeScreenStatus(type: .goal, id: id, completion: { (status) in
            guard let statusValue = CustomBool(rawValue: status) else {
                return
            }
            self.isAddedAsShortcutOnHomeScreen = statusValue
            self.setNavigationItems(statusValue: statusValue)
        }) { (_) in
        }
    }
    
    // MARK: Helpers
    /// call when the right bar button of the navigation bar is tapped
    ///
    /// - Parameter button: UIbarbutton item
    @objc func rightBarButtonTapped(button: UIBarButtonItem) {
        if let goal = self.goal {
            let userInfo: [String: Any] = ["goal": goal, "backgroundUpload": false]
            NotificationCenter.default.post(name: Notification.Name.goalCompleted, object: self, userInfo: userInfo)
        }
    }
    
    @IBAction func editTappedNew() {
        let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
        controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createGoal)
        controller.isEditingCurrentActivity = true
        controller.isType = true
        controller.groupActivityInfo = self.goal
        controller.groupActivityInfo?.selectedMetrics = []
        if let metric = goal?.target?.first?.matric {
            controller.groupActivityInfo?.selectedMetrics?.append(metric)
        }
        if let groupDetail = goal?.groupDetail {
            controller.selectedGroup = groupDetail.toCustomChatGroup()
        }
        let members = self.goal?.members?.filter({ (member) -> Bool in
            if member.id != UserManager.getCurrentUser()?.id ?? "" {
                return member.type ?? .temate == ActivityMemberType.temate
            }
            return false
        }).map({$0.toCustomUserType()})
        controller.selectedFriends = members
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func editTapped() {
        let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
        controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createGoal)
        controller.isEditingCurrentActivity = true
        controller.isType = true
        controller.groupActivityInfo = self.goal
        controller.groupActivityInfo?.selectedMetrics = []
        if let metric = goal?.target?.first?.matric {
            controller.groupActivityInfo?.selectedMetrics?.append(metric)
        }
        if let groupDetail = goal?.groupDetail {
            controller.selectedGroup = groupDetail.toCustomChatGroup()
        }
        let members = self.goal?.members?.filter({ (member) -> Bool in
            if member.id != UserManager.getCurrentUser()?.id ?? "" {
                return member.type ?? .temate == ActivityMemberType.temate
            }
            return false
        }).map({$0.toCustomUserType()})
        controller.selectedFriends = members
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func swipeNewController(forPage page: GoalDetailTab, animated: Bool? = true) {
        if let pageController = self.pageController {
            pageController.setCurrentVisibleControllerAt(page: page, animated: animated!)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addChatterView()
    }
    private func addChatterView() {
        guard self.activityChatView == nil else {
            return
        }
        let chatterView = ActivityDetailChatTableViewCell.loadNib()
        chatterView?.frame.size.width = self.view.frame.size.width - 20
        if let view = chatterView as? ActivityDetailChatTableViewCell {
            self.activityChatView = view
            self.chatter.addSubview(chatterView!)
            chatterView?.layoutIfNeeded()
            self.chatter.layoutIfNeeded()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToChatScreen))
        self.activityChatView?.chatBubbleButton.addTarget(self, action: #selector(pushToChatScreen), for: .touchUpInside)
        self.chatter.addGestureRecognizer(tapGesture)
    }
    
    private func addShadowTo(view: UIView) {
        view.borderColor = ViewDecorator.viewBorderColor
        view.borderWidth = ViewDecorator.viewBorderWidth
        view.cornerRadius = 15.0
        view.cornerRadius = 15.0
        view.layer.masksToBounds = true
        view.layer.shadowColor = ViewDecorator.viewShadowColor
        view.layer.shadowOpacity = ViewDecorator.viewShadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        view.layer.shadowRadius = 15.0
    }
    
    @objc func pushToChatScreen() {
        guard let goalId = self.goal?.id else {
            return
        }
        let chatViewController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        chatViewController.delegate = self
        chatViewController.isGroupActivityChatMuted = self.goal?.isChatNotificationsMuted
        chatViewController.chatRoomId = goalId
        chatViewController.chatName = self.goal?.name
        chatViewController.screenType = .groupActivityChat
        chatViewController.isActivityJoined = self.goal?.isActivityJoined
        chatViewController.chatWindowType = .chatInGoal
        if let imageUrl = self.goal?.image,
           let url = URL(string: imageUrl){
            chatViewController.chatImageURL = url
        }else{
            chatViewController.chatImage = UIImage(named: "user-dummy")
        }
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    private func changeNavigationForCurrentPage() {
        if self.currentTab == .progress {
            self.progressLine.backgroundColor = UIColor.appCyanColor
            self.fundraisingLine.backgroundColor = UIColor.clear
            self.tematesLine.backgroundColor = UIColor.clear
        }
        else if self.currentTab == .fundraising {
            self.progressLine.backgroundColor = UIColor.clear
            self.fundraisingLine.backgroundColor = UIColor.appCyanColor
            self.tematesLine.backgroundColor = UIColor.clear
        }
        else {
            self.progressLine.backgroundColor = UIColor.clear
            self.fundraisingLine.backgroundColor = UIColor.clear
            self.tematesLine.backgroundColor = UIColor.appCyanColor
        }
    }
}

// MARK: AddToHomeScreenViewable, ShortCutButtonConfigurable
extension GoalDetailContainerViewController: AddToHomeScreenViewable, ShortCutButtonConfigurable {
    func addOrRemoveFromHomeScreen() {
        if isConnectedToNetwork() {
            self.showLoader()
            var params = HomeScreenShortcut()
            params.type = .goal
            params.id = self.goalId ?? ""
            params.name = self.selectedGoalName ?? ""
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
    
    func updateToHomeScreenShortcut(sender: UIButton) {
        self.onClickOfShortcut()
    }
}

extension GoalDetailContainerViewController : RefreshGNCEventDelegate {
    func refresh() {
        noMorePages = false
        currentPage = 1
        loadGoal()
    }
    
    func nextPage() {
        if !noMorePages {
            currentPage += 1
            loadGoal()
        }
    }
    
    private func loadGoal() {
        if let goalId = goalId {
            goalModel.loadGoal(goalId, currentPage) { (goal) in
                if let scores = goal.scoreboard {
                    self.noMorePages = scores.count == 0
                    if self.currentPage == 1 {
                        goal.type = .goal
                        self.goal = goal
                    } else {
                        self.goal?.scoreboard?.append(contentsOf: scores)
                    }
                    if let goal = self.goal {
                        self.use(goal: goal)
                    }
                }
            } failure: { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "")
            }
        }
    }
}

extension GoalDetailContainerViewController : SelectGoalDetailPageDelegate {
    func select(page: GoalDetailTab) {
        self.currentTab = page
        self.changeNavigationForCurrentPage()
    }
}

extension GoalDetailContainerViewController: GroupActivityChatDelegate {
    func updateMuteStatusInGroupActivity(newValue: CustomBool) {
        self.goal?.isChatNotificationsMuted = newValue
    }
}

extension GoalDetailContainerViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goal?.scoreboard?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableCell.reuseIdentifier, for: indexPath) as! LeaderboardTableCell
        if let goalInfo = self.goal,
           let scoreboard = goalInfo.scoreboard {
            cell.hideAnimation()
            cell.configureData(atIndexPath: indexPath, scoreboard: scoreboard[indexPath.row], activityInfo: goalInfo)
        }
        tableBackViewHeight.constant = CGFloat((self.goal?.scoreboard?.count ?? 2) * 80)
        return cell
    }
}
