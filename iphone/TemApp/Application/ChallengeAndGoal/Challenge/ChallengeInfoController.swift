//
//  ChallengeInfoController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import FirebaseFirestore
import SSNeumorphicView
enum ChallengeInfoSections: Int, CaseIterable {
    case details = 0
    case position = 1
    case information = 2
    case chatter = 3
    case leaderboard = 4
    case metrics
}

class ChallengeInfoController : DIBaseController {
    var refresh: RefreshGNCEventDelegate?
    var challengeId: String?
    var challenge: GroupActivity?

    @IBOutlet weak var table: UITableView!
    private var refreshControl: UIRefreshControl?

    private var messagesArray: [Message]?
    private var userInfo: [String: Any] = [:]
    private let chatManager = ChatManager()
    private var userInfoListener: ListenerRegistration?
    private let messagesLimit = 5
    private let networkLayer = DIWebLayerActivityAPI()
    var totalOpenedMetricsCount = 0
    var joinHandler: OnlySuccess?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.isSkeletonable = true
        table.estimatedRowHeight = 100
        table.estimatedSectionHeaderHeight = 140.0
        table.registerNibs(nibNames: [ActivityInformationTableCell.reuseIdentifier, ActivityPositionsTableCell.reuseIdentifier, ChallengeLeaderboardTableCell.reuseIdentifier, UpcomingChallengeJoinTableViewCell.reuseIdentifier, ActivityDetailChatTableViewCell.reuseIdentifier,ActivityDetailTableCell.reuseIdentifier])
        table.registerHeaderFooter(nibNames: [BlankFooterView.reuseIdentifier])
        addPullToRefresh()
        self.listenToThisChatRoom()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.chatManager.messageListener?.remove()
        self.userInfoListener?.remove()
    }

    private func addPullToRefresh() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        table.refreshControl = refreshControl
    }
    
    @objc func onPullToRefresh(sender: UIRefreshControl){
        refresh?.refresh()
    }

    // MARK: Chat Helpers
    func listenToThisChatRoom() {
        guard let roomId = self.challengeId else {
            return
        }
        self.chatManager.listenToChatRoom(withId: roomId, fromTime: nil, isPublicRoom: true, fetchLatestFirst: false, completion: { (messages) in
            self.setMessagesData(messages: messages)
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
            self.table.reloadData()
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
        let indexPath = IndexPath(row: 0, section: ChallengeInfoSections.chatter.rawValue)
        if let cell = table.cellForRow(at: indexPath) as? ActivityDetailChatTableViewCell {
            cell.userInfo = self.userInfo
            cell.tableView.reloadData()
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
}

extension ChallengeInfoController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ChallengeInfoSections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = ChallengeInfoSections(rawValue: section) {
            switch currentSection {
            case .details:
                if self.challenge != nil {
                    return 1
                }
            case .information:
                if self.challenge != nil {
                    return 1
                }
            case .position:
                if let challenge = self.challenge {
                    if challenge.status != .upcoming {
                        return 1
                    }
                }
                return 1
            case .leaderboard:
                if let challenge = self.challenge {
                    if challenge.status != .upcoming {
                        return 1
                    }
                }
            case .metrics:
                if let challenge = self.challenge,
                   challenge.status == .upcoming {
                    return 0
                }
                return 0
            case .chatter:
                if self.challenge == nil {
                    return 0
                }
                if let isOpened = self.challenge?.openToPublic,
                   !isOpened,
                   let isJoined = self.challenge?.isActivityJoined,
                   isJoined == false {
                    //only joinees can view and chat
                    return 0
                }
                return 1
            }
        }
        return 0
    }
    
    private func addShadowTo(view: UIView,mainView: UIView,radius: CGFloat = 15.0) {
        mainView.borderColor = ViewDecorator.viewBorderColor
        mainView.borderWidth = ViewDecorator.viewBorderWidth
        mainView.cornerRadius = radius
        view.cornerRadius = radius
        view.layer.masksToBounds = true
        view.layer.shadowColor = ViewDecorator.viewShadowColor
        view.layer.shadowOpacity = ViewDecorator.viewShadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        view.layer.shadowRadius = radius
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = ChallengeInfoSections(rawValue: indexPath.section) {
            switch currentSection {
            case .details:
                guard let cell:ActivityDetailTableCell = tableView.dequeueReusableCell(withIdentifier: ActivityDetailTableCell.reuseIdentifier, for: indexPath) as? ActivityDetailTableCell else {
                    return UITableViewCell()
                }
                cell.temmatesDelegate = self
                cell.delegate = self
                if let challengeInformation = self.challenge {
                    cell.initializCell(challenge: challengeInformation)
                }
                return cell
            case .information:
                guard let cell:ActivityInformationTableCell = tableView.dequeueReusableCell(withIdentifier: ActivityInformationTableCell.reuseIdentifier, for: indexPath) as? ActivityInformationTableCell else {
                    return UITableViewCell()
                }
                if let challengeInformation = self.challenge {
                    cell.setChallengeInformation(activity: challengeInformation, indexPath: indexPath)
                    cell.setStartEndDateInformation(activity: challengeInformation)
                    cell.setMetricsInfo(forActivity: challengeInformation)
                }
                cell.setViewForDeatil()
                cell.emptyViewHeightConstraint.constant = 5
                return cell
            case .position:
                guard let cell: ActivityPositionsTableCell = tableView.dequeueReusableCell(withIdentifier: ActivityPositionsTableCell.reuseIdentifier, for: indexPath) as? ActivityPositionsTableCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                if let challenge = self.challenge {
                    cell.setData(activity: challenge, indexPath: indexPath)
                }
                cell.emptyViewHeightConstraint.constant = 5
                return cell
            case .chatter:
                return cellForChatterView(tableView, cellForRowAt: indexPath)
            case .leaderboard:
                guard let cell:ChallengeLeaderboardTableCell = tableView.dequeueReusableCell(withIdentifier: ChallengeLeaderboardTableCell.reuseIdentifier, for: indexPath) as? ChallengeLeaderboardTableCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                if let activityInfo = self.challenge{
                    cell.challenge = activityInfo
                }
                
                totalOpenedMetricsCount = challenge?.totalOpenedMetricsViews ?? 0
                cell.shadowViewHeight.constant = CGFloat(((self.challenge?.scoreboard?.count ?? 0) * 80) + totalOpenedMetricsCount * 275) // 275 is the height for matrics view
                return cell
            case .metrics:
                if let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingChallengeJoinTableViewCell.reuseIdentifier, for: indexPath) as? UpcomingChallengeJoinTableViewCell {
                    cell.delegate = self
                    if let activity = self.challenge {
                        cell.initializeWith(activity: activity)
                    }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }

    //returns the cell for chatter view of tableview
    private func cellForChatterView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ActivityDetailChatTableViewCell.reuseIdentifier, for: indexPath) as? ActivityDetailChatTableViewCell {
            if let messages = self.messagesArray {
                cell.initializeWith(messages: messages)
                cell.setUserInformation(userInfo: userInfo)
            }
            cell.emptyviewHeightConstraint.constant = 5
            cell.chatBubbleButton.addTarget(self, action: #selector(pushToChatScreen), for: .touchUpInside)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToChatScreen))
            tapGesture.numberOfTapsRequired = 1
            cell.tableView.addGestureRecognizer(tapGesture)
            return cell
        }
        return UITableViewCell()
    }

    @objc func pushToChatScreen() {
        guard let challengeId = self.challenge?.id else {
                return
        }
        let chatViewController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        chatViewController.delegate = self
        chatViewController.chatRoomId = challengeId
        chatViewController.chatName = self.challenge?.name
        chatViewController.isGroupActivityChatMuted = self.challenge?.isChatNotificationsMuted ?? .no
        chatViewController.screenType = .groupActivityChat
        chatViewController.isActivityJoined = self.challenge?.isActivityJoined
        chatViewController.chatWindowType = .chatInChallenge
        if let imageUrl = self.challenge?.image,
           let url = URL(string: imageUrl){
            chatViewController.chatImageURL = url
        }else{
            chatViewController.chatImage = UIImage(named: "user-dummy")
        }
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ActivityInformationTableCell {
            challenge?.setActivityImage(cell.activityImageView)
        }
        if let cell = cell as? ChallengeLeaderboardTableCell {
            if let activityInfo = self.challenge,
               let scoreboard = activityInfo.leaderboardArray {
                if indexPath.row == scoreboard.count - 1 { //last row
                } else {
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentSection = ChallengeInfoSections(rawValue: indexPath.section) {
            if currentSection == .chatter {
                self.pushToChatScreen()
            }
        }
    }

}

// MARK: SkeletonTableViewDataSource
extension ChallengeInfoController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if let currentSection = ChallengeInfoSections(rawValue: indexPath.section) {
            switch currentSection {
            case .details:
                return ActivityDetailTableCell.reuseIdentifier
            case .information:
                return ActivityInformationTableCell.reuseIdentifier
            case .position:
                return ActivityPositionsTableCell.reuseIdentifier
            case .leaderboard:
                return ChallengeLeaderboardTableCell.reuseIdentifier
            case .chatter:
                return ActivityDetailChatTableViewCell.reuseIdentifier
            default:
                break
            }
        }
        return ""
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = ChallengeInfoSections(rawValue: section) {
            switch currentSection {
            case .details:
                return 1
            case .information:
                return 1
            case .position:
                return 1
            case .leaderboard:
                return 5
            case .metrics, .chatter:
                return 0
            }
        }
        return 0
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return ChallengeInfoSections.allCases.count
    }
}

extension ChallengeInfoController : ChallengeJoinTableCellDelegate {
    func didClickOnJoin(sender: UIButton) {
        if self.isConnectedToNetwork(),
            let challengeId = self.challengeId {
            self.showLoader()
            let params = JoinActivityApiKey().toDict()
            self.networkLayer.joinActivity(id: challengeId, parameters: params, completion: {(_) in
                NotificationCenter.default.post(name: Notification.Name.activityJoined, object: nil, userInfo: ["id": challengeId])
                self.hideLoader()
                self.refresh?.refresh()
                if let joinHandler = self.joinHandler {
                    joinHandler()
                }
            }) {(error) in
                self.hideLoader()
                if let error = error.message {
                    self.showAlert(withTitle: "", message: error, okayTitle: AppMessages.AlertTitles.Ok, okStyle: .default, okCall: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
}

extension ChallengeInfoController : GroupActivityChatDelegate {
    func updateMuteStatusInGroupActivity(newValue: CustomBool) {
        self.challenge?.isChatNotificationsMuted = newValue
    }
}

extension ChallengeInfoController : UpdateGNCEventInfoProtocol {
    func use(_ event: GroupActivity) {
        challenge = event
        self.refreshControl?.endRefreshing()
        self.table.hideSkeleton()
        self.table.tableFooterView = self.table.emptyFooterView()
        self.table.reloadData()
    }
}

extension ChallengeInfoController : UpdateByTimerProtocol {
    func handleTick() {
        guard let visibleRowsIndexPaths = table.indexPathsForVisibleRows else {
            return
        }
        for indexPath in visibleRowsIndexPaths {
            if let cell = table.cellForRow(at: indexPath) as? ActivityInformationTableCell {
                if let challengeInfo = self.challenge {
                    cell.updateRemainingTimeForActivity()
                }
            }
        }
    }
}

extension ChallengeInfoController : ActivityDetailTableCellDelegate{
    func donateButtonTapped() {
        if let event = self.challenge {
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
}

extension ChallengeInfoController: ShowTemmatesDelegate{
    func showTemmatesList() {
        let expendedVC: EventDetailsExpendedViewController = UIStoryboard(storyboard: .calendar).initVC()
        expendedVC.activityDetail = self.challenge
        self.navigationController?.pushViewController(expendedVC, animated: true)
    }
}

extension ChallengeInfoController: ChallengeLeaderboardTableCellDelegate {
    func didTapOnUserInformation(atRow row: Int, section: Int) {
        if let scoreboard = self.challenge?.leaderboardArray,
           row < scoreboard.count {
            if let groupTitle = scoreboard[row].leaderboardMember?.groupTitle,
               !groupTitle.isEmpty {
                //this is a group
            } else {
                let profileDashboardVC: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                if let userId = scoreboard[row].leaderboardMember?.id {
                    if userId != (UserManager.getCurrentUser()?.id ?? "") { //this is not the logged in user
                        profileDashboardVC.otherUserId = userId
                    }
                    self.navigationController?.pushViewController(profileDashboardVC, animated: true)
                }
            }
        }
    }
    
    func didTapOnArrowButton(sender: UIButton, totalOpenedMetricViews: Int) {
       // self.totalOpenedMetricsCount = totalOpenedMetricViews
        if let type = self.challenge?.activityMembersType {
            switch type {
            case .individualVsTem:
                self.challenge?.scoreboardForTemVsInd?[sender.tag].isOpened.toggle()
                if let value = self.challenge?.scoreboard?[sender.tag].isOpened{
                    if value{
                        self.challenge?.totalOpenedMetricsViews += 1
                    }else{
                        self.challenge?.totalOpenedMetricsViews -= 1
                    }
                }
            case .temVsTem:
                self.challenge?.teamsArray?[sender.tag].isOpened.toggle()
                if let value = self.challenge?.scoreboard?[sender.tag].isOpened{
                    if value{
                        self.challenge?.totalOpenedMetricsViews += 1
                    }else{
                        self.challenge?.totalOpenedMetricsViews -= 1
                    }
                }
            default:
             
                self.challenge?.scoreboard?[sender.tag].isOpened.toggle()
                if let value = self.challenge?.scoreboard?[sender.tag].isOpened{
                    if value{
                        self.challenge?.totalOpenedMetricsViews += 1
                    }else{
                        self.challenge?.totalOpenedMetricsViews -= 1
                    }
                }
            }
        } else {
            self.challenge?.scoreboard?[sender.tag].isOpened.toggle()
            if let value = self.challenge?.scoreboard?[sender.tag].isOpened{
                if value{
                    self.challenge?.totalOpenedMetricsViews += 1
                }else{
                    self.challenge?.totalOpenedMetricsViews -= 1
                }
            }
        }
        self.table.reloadData()
    }
}

