//
//  GoalProgressViewController.swift
//  TemApp
//
//  Created by shilpa on 13/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class GoalProgressViewController: DIBaseController {
    var refresh: RefreshGNCEventDelegate?
    var goalId: String?
    var goal: GroupActivity?

    weak var goalDetailPageDelegate: GoalDetailPageControllerDelegate?
    private var refreshScreen = false
    private var activityChatView: ActivityDetailChatTableViewCell?

    @IBOutlet weak var scrollView: UIScrollView!
    private var refreshControl: UIRefreshControl?
    @IBOutlet weak var error: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var content: UIView!

    @IBOutlet weak var progressHoneycomb: GoalProgressHoneyCombView!
    @IBOutlet weak var progressHoneycombHeight: NSLayoutConstraint!

    @IBOutlet weak var chatter: UIView!
    @IBOutlet weak var chatterHeight: NSLayoutConstraint!

    @IBOutlet weak var goalInfoCard: UIView!
    @IBOutlet weak var goalInfo: UIView!
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var goalIcon: UIImageView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var tematesCount: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var goalDescription: UILabel!
    @IBOutlet weak var goalStatus: UILabel!
    @IBOutlet weak var goalStatusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var goalDetailHoneycomb: GoalDetailHoneyCombView!
    @IBOutlet weak var goalDetailHoneycombHeight: NSLayoutConstraint!
    
    @IBOutlet weak var joinButton: UIButton!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotificationObservers()
        createUserExperience()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        if self.refreshScreen {
            self.refreshScreen = false
            self.refresh?.refresh()
        }
        else {
            self.reloadView()
        }
        self.addShadowTo(view: goalInfoCard)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.handleTick()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotificationObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addChatterView()
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
    
    // MARK: Private Methods....
    
    private func createUserExperience() {
        self.content.isHidden = true
        self.error.isHidden = true
        activityName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAllActivities)))
        activityName.isUserInteractionEnabled = true
        addPullToRefresh()
    }
    
    @objc private func showAllActivities(_ sender: UITapGestureRecognizer) {
        if let activityTypes = self.goal?.activityTypes {
            self.showAlert(withTitle: "Activities", message: activityTypes.map({ x in x.activityName ?? "N/A" }).joined(separator: ", "))
        }
    }
    
    private func addPullToRefresh() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    @objc func onPullToRefresh(sender: UIRefreshControl) {
        self.refresh?.refresh()
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
    
    private func updateView(data: GroupActivity) {
        if let status = goal?.status {
            if status != .upcoming {
                self.progressHoneycombHeight.constant = 500
                self.progressHoneycomb.isHidden = false
                self.goalDetailHoneycombHeight.constant = 380
            } else {
                self.progressHoneycombHeight.constant = 180
                self.progressHoneycomb.isHidden = true
                var height: CGFloat = UIScreen.main.bounds.size.height - (40+64+150)//500//self.view.bounds.size.height - (200 + 160)
                height = self.view.frame.height - (30 + self.goalInfo.bounds.height)
                if height < 380 {
                    height = 380
                }
                self.goalDetailHoneycombHeight.constant = height
                self.goalDetailHoneycomb.heightOfFullView = height
            }
            self.goalDetailHoneycomb.createLayout()
            self.goalDetailHoneycomb.setGoalHoneyCombData(data: data)
        }
    }
    
    /// adds the ActivityDetailChat view in the parnet view
    private func addChatterView() {
        guard self.activityChatView == nil else {
            return
        }
        let chatterView = ActivityDetailChatTableViewCell.loadNib()
        chatterView?.frame = self.chatter.bounds
        chatterView?.frame.size.width = self.view.frame.size.width - 10
        if let view = chatterView as? ActivityDetailChatTableViewCell {
            self.activityChatView = view
            self.chatter.addSubview(chatterView!)
            chatterView?.layoutIfNeeded()
            self.chatter.layoutIfNeeded()
            self.addShadowTo(view: view.backView)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToChatScreen))
        self.activityChatView?.chatBubbleButton.addTarget(self, action: #selector(pushToChatScreen), for: .touchUpInside)
        self.chatter.addGestureRecognizer(tapGesture)
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
    
    /// reloads the chatter view with the new data loaded in parent container view
    /// - Parameter messages: array of new messages
    func reloadChatterViewWith(messages: [Message], userInfo: [String: Any]?) {
        self.activityChatView?.userInfo = userInfo
        self.activityChatView?.initializeWith(messages: messages)
    }
    
    private func reloadView() {
        guard let goal = self.goal else { return }
        
        self.refreshControl?.endRefreshing()
        self.content.isHidden = false
        self.setChatterViewDisplay()
        
        if let matricValue = goal.target?.first?.matric,
            let metric = Metrics(rawValue: matricValue),
            let totalScore = goal.currentAchievedValue,
            let percentComplete = goal.completionPercentage {
            self.progressHoneycomb.use(percent: percentComplete, achievedScore: totalScore, metric: metric)

        }
        self.goalName.text = goal.name ?? ""
        goal.setActivityLabelAndImage(activityName, goalIcon)

        self.tematesCount.text = goal.getTematesLabel()
        self.goalDescription.text = goal.description
        setJoinGoalStatus(activity: goal)
        if let status = self.goal?.status {
            switch status {
            case .completed:
                self.setCompletedGoalStatus(goalPercent: self.goal?.completionPercentage)
            default:
                self.goalStatusViewHeight.constant = 0
            }
        }
        DispatchQueue.main.async {
            self.updateView(data: goal)
            self.view.layoutIfNeeded()
        }
    }
    
    private func setCompletedGoalStatus(goalPercent: Double?) {
        self.remainingTime.text = ""
        self.goalStatusViewHeight.constant = 40.0
        if let percentCompletion = self.goal?.completionPercentage,
            percentCompletion >= 100 {
            //if percent completion is equal to or more than 100, then goal is achieved
            self.goalStatus.text = AppMessages.GroupActivityMessages.goalAchieved
        } else {
            self.goalStatus.text = AppMessages.GroupActivityMessages.goalIncomplete
        }
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
    
    private func displayErrorMessageViewWith(message: String) {
        self.content.isHidden = true
        self.scrollView.isHidden = true
        self.error.isHidden = false
        self.errorLabel.text = message
        
    }
    
    // MARK: Notification Observers Helpers
    private func addNotificationObservers() {
        self.removeNotificationObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(goalEdited), name: Notification.Name.goalEdited, object: nil)
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.goalEdited, object: nil)
    }
    
    @objc func goalEdited() {
        self.refreshScreen = true
    }
    
    // MARK: Share
    func shareGoal() {
        
    }
    
    // MARK: IBActions..
    @IBAction func joinTapped(_ sender: UIButton) {
        guard self.isConnectedToNetwork() else {
            return
        }
        if let goalId = self.goal?.id {
        self.showLoader()
        let params = JoinActivityApiKey().toDict()
            DIWebLayerGoals().joinGoal(id: goalId, parameters: params, completion: {(result) in
                NotificationCenter.default.post(name: Notification.Name.activityJoined, object: nil, userInfo: ["id": goalId])
                self.hideLoader()
                self.goal?.isActivityJoined = result
                if let membersCount = self.goal?.membersCount {
                    self.goal?.membersCount = membersCount + 1
                }
                self.setJoinGoalStatus(activity: self.goal!)
                self.setChatterViewDisplay()
            }) { (error) in
                self.hideLoader()
                self.showAlert(withError: error, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: nil, okCall: {
                    self.navigationController?.popViewController(animated: true)
                }, cancelCall: {
                    
                })
            }
        }
     
    }
    
}

extension GoalProgressViewController: GroupActivityChatDelegate {
    func updateMuteStatusInGroupActivity(newValue: CustomBool) {
        self.goal?.isChatNotificationsMuted = newValue
    }
}

extension GoalProgressViewController : UpdateGNCEventInfoProtocol {
    func use(_ event: GroupActivity) {
        self.goal = event
        self.reloadView()
    }
}

extension GoalProgressViewController : UpdateByTimerProtocol {
    func handleTick() {
        self.remainingTime.text = self.goal?.remainingTime()
    }
}
