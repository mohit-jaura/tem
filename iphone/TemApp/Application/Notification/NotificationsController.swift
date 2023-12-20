//
//  NotificationsController.swift
//  Noah
//
//  Created by Harpreet_kaur on 21/03/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

class NotificationsController: DIBaseController {


    // MARK: Variables.
    var defaultPage:Int = 1
    var pageNumber:Int = 1
    var currentAddress:Address?
    var notificationRefreshControl: UIRefreshControl!
    var notifications = [Notifications]()
    var showLoader: Bool = true
    var updateNotificationsCountHandler: OnlySuccess?
    var screenFrom: Constant.ScreenFrom?
    var coachListVM = CoachViewModal()
    // MARK: IBOutlets.
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!


    // MARK: ViewLifeCycle.
    // MARK: ViewDidLoad.
    override func viewDidLoad(){
        super.viewDidLoad()
        initUI()
    }

    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        //  self.configureNavigation()
    }

    // MARK: PrivateFunction.
    // MARK: Function to set Navigation Bar.
    private func  initUI(){
        self.notificationTableView.estimatedRowHeight = 100.0
        self.notificationTableView.tableFooterView = UIView()
        self.addRefreshController()
        self.getInitialData()
        if screenFrom == .dashboard {
            filterButton.isHidden = true
        }
    }

    // MARK: Set Navigation
    func configureNavigation(){
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        let rightBarButton = UIBarButtonItem(customView: getMoreButton())

        self.setNavigationController(titleName: Constant.ScreenFrom.notification.title, leftBarButton: [leftBarButtonItem], rightBarButtom: [rightBarButton], backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func menuButtonTapped(_ sender: UIButton) {
        moreActions()
    }

    @IBAction func filterTapped(_ sender: UIButton) {
        getCoachList()
    }
    func getFilterNotifications(){
        if let list = coachListVM.coachList{
            self.showSelectionModal(array: list, type: .coachingTools)

        } else{
            showAlert(message: "No coach found!")
        }
    }
    override func handleSelection(index: Int, type: SheetDataType) {
        getNotifications(coachId: coachListVM.coachList?[index].id ?? "")
    }
    ///
    /// - Returns: It returns clear all notification button and you can use any where in child classes.
    func getMoreButton() -> UIButton {
        let buttonMore = UIButton(type: .custom)
        buttonMore.setTitle("", for: .normal)
        buttonMore.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        buttonMore.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //  buttonMore.titleLabel?.font = UIFont(name: UIFont.robotoMedium, size: 15)
        buttonMore.frame = CGRect(x: 0, y: 0, width: 40, height: 25)
        buttonMore.addTarget(self, action: #selector(self.moreActions), for: .touchUpInside)
        return buttonMore
    }


    // MARK: Function to get Intial Notification Data.
    private func getInitialData(){
        self.notificationTableView.showAnimatedSkeleton()
        self.notificationTableView.isUserInteractionEnabled = false
        getNotifications()
    }

    // MARK: AddRefreshController To TableView.
    private func addRefreshController(){
        notificationRefreshControl = UIRefreshControl()
        notificationRefreshControl.tintColor = appThemeColor
        notificationRefreshControl.addTarget(self, action: #selector(refreshNews(sender:)) , for: .valueChanged)
        notificationTableView.addSubview(notificationRefreshControl)
    }

    // MARK: Function To Refresh News Tableview Data.
    @objc func refreshNews(sender:AnyObject){
        pageNumber = 1
        defaultPage = 1
        getNotifications()
    }

    // MARK: Function to getnotifications.

    func getCoachList(){
        self.showLoader()
        coachListVM.getCoachList{[weak self] in
            if let error = self?.coachListVM.error{
                print(error.message)
            }
            if let _ = self?.coachListVM.coachList{
                self?.getFilterNotifications()
            }
            self?.hideLoader()
        }
    }

    func getNotifications(coachId: String = ""){
        if Utility.isInternetAvailable() {
            if showLoader {
                showLoader()
                showLoader = false // that will not show loader on every reloading
            }

            DIWebLayerNotificationsAPI().getNotifications(coachId: coachId, screenFrom: screenFrom, page: pageNumber, completion: { (data, pageLimit) in
                self.hideLoader()
                self.notificationTableView.isUserInteractionEnabled = true
                if self.pageNumber == 1{
                    self.notifications.removeAll()
                }
                self.notifications += data
                if data.count == pageLimit {
                    self.pageNumber += 1
                }
                if self.notifications.count <= 0 {
                    self.notificationTableView.showEmptyScreen("You have no new notifications.")
                }else{
                    self.notificationTableView.restore()
                }
                self.notificationRefreshControl.endRefreshing()

                self.notificationTableView.hideSkeleton()

                DispatchQueue.main.async {
                    self.notificationTableView.reloadData()
                    self.notificationTableView.tableFooterView = self.notificationTableView.emptyFooterView()
                }
            }) { (error) in
                self.hideLoader()
                self.showErrorOnView(message: error.message ?? "")
                self.notificationTableView.tableFooterView = UIView()
            }
        }else{
            self.hideLoader()
            self.showErrorOnView(message: AppMessages.AlertTitles.noInternet)
        }
    }

    // Add delete notifcation api call
    private func deleteNotifcationApiCall(id: String, index: Int) {
        if isConnectedToNetwork() {
            self.showLoader()
            let params: Parameters = ["id": id]
            DIWebLayerNotificationsAPI().deleteNotifcation(params: params, completion: { (_) in
                if let isRead = self.notifications[index].is_read, isRead == 0 {
                    if let updateNotificationsCountHandler = self.updateNotificationsCountHandler {
                        UserManager.updateUnreadCount(-)
                        updateNotificationsCountHandler()
                    }
                }
                self.completionAfterDeleteNotification(index: index)
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "Error")            }
        }
    }
    // MARK: Function to markAllReadNotifications.
    @objc private func markAllReadNotifications() {
        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerNotificationsAPI().markAllReadNotifcation(completion: { (_) in
                //self.getNotifications()
                //                cell.backgroundColor = .clear
                _ = self.notifications.map { (notification) -> Notifications in
                    notification.is_read = 1
                    return notification
                }
                if let updateNotificationsCountHandler = self.updateNotificationsCountHandler {
                    Defaults.shared.set(value: 0, forKey: .unreadNotificationCount)
                    updateNotificationsCountHandler()
                }
                DispatchQueue.main.async {
                    self.hideLoader()
                    self.notificationTableView.reloadData()
                }
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message)
            }
        }
    }
    var actionSheet: CustomBottomSheet?
    // MARK: Function to markAllReadNotifications.
    @objc private func moreActions() {
        let titleArray: [UserActions] = [.readAll, .clearAll, .cancel]
        let colorsArray: [UIColor] = [.gray, .gray, .gray]
        let customTitles: [String] = [AppMessages.Chat.readAll, AppMessages.Chat.clearAll, UserActions.cancel.title]
        self.actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: colorsArray, customTitles: customTitles, tag: 1)
        self.actionSheet?.delegate = self
    }
    @objc private func deleteAllNotifications() {

        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerNotificationsAPI().deleteAllNotifcation(completion: { (_) in
                self.hideLoader()
                self.notifications.removeAll()
                self.defaultPage = 1
                self.pageNumber = 1
                if let updateNotificationsCountHandler = self.updateNotificationsCountHandler {
                    Defaults.shared.set(value: 0, forKey: .unreadNotificationCount)
                    updateNotificationsCountHandler()
                }
                if self.notifications.count <= 0 {
                    self.notificationTableView.showEmptyScreen("You have no new notifications.")
                }
                self.notificationTableView.reloadData()

            }) { (error) in

            }
        }
    }


    private func completionAfterDeleteNotification(index: Int) {
        self.notifications.remove(at: index)
        if self.notifications.isEmpty {
            //refresh
            self.notifications.removeAll()
            self.defaultPage = 1
            self.pageNumber = 1
            self.getNotifications()
        } else {
            self.hideLoader()
            self.notificationTableView.reloadData()
        }
    }

    private func showErrorOnView(message: String) {
        self.notificationTableView.hideSkeleton()
        self.notificationRefreshControl.endRefreshing()
        if self.notifications.isEmpty {
            self.notificationTableView.showEmptyScreen(message)
        } else {
            self.showAlert(message:message)
        }
    }

    // MARK: Mark notification as read.
    func readNotification(id:String,index:Int) {
        if Utility.isInternetAvailable(){
            DIWebLayerNotificationsAPI().readNotification(id: id, completion: { (message) in
                print("read notification")
                if let updateNotificationsCountHandler = self.updateNotificationsCountHandler {
                    UserManager.updateUnreadCount(-)
                    updateNotificationsCountHandler()
                }
                NotificationCenter.default.post(name: Notification.Name.notificationChange, object: nil)
                //self.hideLoader()
                self.notifications[index].is_read = 1
                self.notificationTableView.reloadData()
            }) { (error) in
                self.hideLoader()
            }
        }
    }

    // MARK: Function to redirect the user to Next Screen.
    private func navigateToNext(index:Int) {
        let type = NotificationType(rawValue: "\(notifications[index].type ?? 0)") ?? .defaultType
        let id = notifications[index].reference_id ?? ""
        switch type {
            case .sentFriendRequest,.remindFriendRequest:
                let networkVC:NetworkViewController = UIStoryboard(storyboard: .network).initVC()
                self.navigationController?.pushViewController(networkVC, animated: true)
            case .acceptFriendRequest:
                let profileVC: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                profileVC.otherUserId = id
                self.navigationController?.pushViewController(profileVC, animated: true)
            case .stream:
                print("This is stream")
                if let id = notifications[index].from {
                    Stream.connect.toServer(id,true,self)
                }
            case .createPost :
                self.postDetailViewController(id: id)

            case .likePost :
                self.postDetailViewController(id: id,isUserActionsFromPushNotification: true)

            case .commentPost:
                self.postDetailViewController(id: id,isLikeNotification: false,isUserActionsFromPushNotification: true)

            case .createGoal:
                let controller: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                controller.goalId = id
                self.navigationController?.pushViewController(controller, animated: true)

            case .createChallenge:
                let controller: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                controller.challengeId = id
                self.navigationController?.pushViewController(controller, animated: true)

            case .event:
                let controller: EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
                controller.eventId = id
                self.navigationController?.pushViewController(controller, animated: true)

            case .newGroupAdded:
                if let groupId = notifications[index].chatGroupId {
                    let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
                    if let image = notifications[index].userImage, let url = URL(string: image) {
                        //                        chatController.chatImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
                        chatController.chatImageURL = url

                    }
                    else{
                        chatController.chatImage = UIImage(named: "user-dummy")
                    }
                    chatController.chatRoomId = groupId
                    self.navigationController?.pushViewController(chatController, animated: true)
                }
            case .message:
                let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
                if let image = notifications[index].userImage, let url = URL(string: image) {
                    //                    chatController.chatImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
                    chatController.chatImageURL = url
                }
                else{
                    chatController.chatImage = UIImage(named: "user-dummy")
                }
                chatController.chatRoomId = id
                self.navigationController?.pushViewController(chatController, animated: true)
            case .challengeChat:
                let controller: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                controller.challengeId = id
                self.navigationController?.pushViewController(controller, animated: false)
                self.pushToGroupActivityChat(id: id, type: .chatInChallenge)
             case .goalChat:
                 let controller: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                 controller.goalId = id
                 self.navigationController?.pushViewController(controller, animated: false)
                 self.pushToGroupActivityChat(id: id, type: .chatInGoal)
            case .todo:
                let activityDetailVC: ToDoActivityDetailViewController = UIStoryboard(storyboard: .todo).initVC()
                let toDoDetailViewModal = ToDoDetailViewModal(id: id){}
                activityDetailVC.viewModal = toDoDetailViewModal
            //    activityDetailVC.coachName = "\(notificat ions[index].fullName)"
                self.navigationController?.pushViewController(activityDetailVC, animated: true)
            case .dailyJourney:
                let journeyVC: MyJourneyViewController = UIStoryboard(storyboard: .coachingTools).initVC()
                self.navigationController?.pushViewController(journeyVC, animated: true)
            case .commentFoodTrek, .createFoodTrek:
                let commentsController: CommentsController = UIStoryboard(storyboard: .post).initVC()
                commentsController.postId = id
                commentsController.isFromFoodTrek = true
                self.navigationController?.pushViewController(commentsController, animated: true)
            case .likeFoodTrek:
                self.postDetailViewController(id: id,isUserActionsFromPushNotification: true, isFoodTrekPost: true)
            case .addToMyTodo:
                let todoVC:ToDoActivitiesListViewController = UIStoryboard(storyboard: .todo).initVC()
                self.navigationController?.pushViewController(todoVC, animated: true)
            default: break
        }
    }

    private func pushToGroupActivityChat(id: String, type: ChatWindowType) {
        let chatViewController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        chatViewController.chatRoomId = id
        chatViewController.chatName = type == .chatInChallenge ? "Challenge" : "Goal"
        chatViewController.isGroupActivityChatMuted = .no
        chatViewController.screenType = .groupActivityChat
        chatViewController.isActivityJoined = true
        chatViewController.chatWindowType = type
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }


    func postDetailViewController(id:String,isLikeNotification:Bool = true,isUserActionsFromPushNotification:Bool = false, isFoodTrekPost: Bool = false) {
        let posDetailcontroller : PostDetailController = UIStoryboard(storyboard: .profile).initVC()
        posDetailcontroller.postId = id
        posDetailcontroller.isLikeNotification = isLikeNotification
        posDetailcontroller.isFoodTrekPost = isFoodTrekPost
        posDetailcontroller.isUserActionsFromPushNotification = isUserActionsFromPushNotification
        self.navigationController?.pushViewController(posDetailcontroller, animated: !isUserActionsFromPushNotification)
    }

    // MARK: Function to set Navigation according to Notification Data.
    func setNavigation() {
        self.notifications.removeAll()
        initUI()
        self.notificationTableView.reloadData()
    }

}

// MARK: UITableViewDelegate&UITableViewDataSource.
extension NotificationsController:UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if notifications.count <= 0 {
        //            tableView.showEmptyScreen("No Data Found")
        //        }else{
        //            tableView.showEmptyScreen("")
        //        }
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:NotificationCell = notificationTableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseIdentifier, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.setData(data:notifications,index:indexPath.row, challengeImageType: notifications[indexPath.row].type ?? 0)
        if notifications[indexPath.row].is_read == 1 {
            //    cell.backgroundColor = .clear
            cell.configureView(isRead: true)
        } else {
            cell.configureView(isRead: false)
            //     cell.backgroundColor = UIColor.init(red: 215/255, green: 213/255, blue:  216/255, alpha: 1.0)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < notifications.count {
            if notifications[indexPath.row].is_read == 1{
                navigateToNext(index: indexPath.row)
            }else{
                if let notificationID = notifications[indexPath.row].id {
                    readNotification(id:notificationID,index:indexPath.row)
                    self.navigateToNext(index: indexPath.row)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSkeletonActive {
            cell.hideSkeleton()
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let cell = tableView.cellForRow(at: indexPath),
           cell.isSkeletonActive {
            return false
        }
        if !notifications.isEmpty,
           let _ = notifications[indexPath.row].id {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { _, index in
            if !self.notifications.isEmpty,
               let notiId = self.notifications[indexPath.row].id {
                self.showAlert(withTitle: "", message: AppMessages.NetworkMessages.deleteNotifcation, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {[weak self] in
                    self?.deleteNotifcationApiCall(id: notiId, index: indexPath.row)
                }) {
                }
            }
        }
        delete.backgroundColor = UIColor.appRed
        if !self.notifications.isEmpty {
            return [delete]
        }
        return nil
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == notificationTableView {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                if defaultPage < pageNumber {
                    defaultPage = pageNumber
                    self.notificationTableView.tableFooterView = Utility.getPagingSpinner()
                    getNotifications()
                }
            }
        }
    }
}

// MARK: SkeletonTableViewDataSource
extension NotificationsController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return NotificationCell.reuseIdentifier
    }

    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
extension NotificationsController: CustomBottomSheetDelegate {
    func customSheet(actionForItem action: UserActions) {
        actionSheet?.dismissSheet()
        // let tag = actionSheet?.tag ?? 0
        switch action {
        case .clearAll:
            self.deleteAllNotifications()
        case .readAll:
            self.markAllReadNotifications()
        default:
            print("Default")
        }
    }
}
