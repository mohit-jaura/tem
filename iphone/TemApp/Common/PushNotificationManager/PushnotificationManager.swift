//
//  PushnotificationManager.swift
//  TemApp
//
//  Created by Sourav on 2/7/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications
import FirebaseMessaging
import SideMenu
import UIKit


extension AppDelegate:UNUserNotificationCenterDelegate,MessagingDelegate {
    
    // MARK: Firebase Noification
    func registerForFirebaseNotification(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in })
        }else{
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        //Get firebase token from here
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let token = token {
                    self.updateNewDeviceTokenToServer(token: token)
                }
            }
        }
    }

    @objc func tokenRefreshNotification(_ notification: Notification) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let token = token {
                print("Remote instance ID token: \(token)")
                self.updateNewDeviceTokenToServer(token: token)
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.updateNewDeviceTokenToServer(token: fcmToken ?? "")
    }
    
    func updateNewDeviceTokenToServer(token: String) {
        Defaults.shared.set(value: token, forKey: DefaultKey.fcmToken)
        if let authToken = UserManager.getCurrentUser()?.oauthToken,
           !authToken.isEmpty {
            //update the new device token to the server
            let params: Parameters = ["device_token": token]
            print("update device token: \(token)")
            //            if let oldToken = Messaging.messaging().fcmToken {
            //                if oldToken == token {
            //                    return
            //                }
            //            }
            DIWebLayerUserAPI().updateDeviceToken(parameters: params)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DILog.print(items: error)
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Notification comes")
        DILog.print(items: userInfo)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DILog.print(items: "Notification \(userInfo)")
        //handling silent notification
        if let type = userInfo["type"] as? String {
            switch type {
            case NotificationType.silentGoalCompleted.rawValue:
                let data = (userInfo["sent_data"] as? String)?.convertStringToDictionary()
                if let goalId = data?["id"] as? String {
                    DIWebLayerGoals().getGoalDetailsBy(id: goalId, page: 1, completion: { (goal, page) in
                        let notiInfo: Parameters = ["goal": goal, "backgroundUpload": true]
                        NotificationCenter.default.post(name: Notification.Name.goalCompleted, object: self, userInfo: notiInfo)
                    }) { (error) in
                        print("error in fetching goal")
                    }
                }
            default:
                break
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let token = token {
                self.updateNewDeviceTokenToServer(token: token)
            }
        }
    }
    // This Fucntion will call after click on notification....
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        SplashViewController.isSplash = false
        NotificationCenter.default.post(name: Notification.Name("goalCompleted"), object: nil)
        NSLog("Did receive response: step1")
        print("didReceive Notification called")
        User.sharedInstance = UserManager.getCurrentUser() ?? User()
        if let notification = response.notification.request.content.userInfo  as? NSDictionary{
            //  NotificationManager.shared.filterNotifications(notificationDict: notification)
            DILog.print(items: "notificaition \(notification)")
            self.handleNotificationAction(notification: notification)
        }
        completionHandler()
    }
    func postAfterADelay(_ affId:String) {
        if let topView = UIApplication.topViewController() as? DIBaseController {
            topView.showLoader()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                topView.hideLoader()
                Stream.connect.toServer(affId,true,topView)
            }
            )}
    }

    // MARK: Read notification Api
    func readNotification(notificationId: String) {
        if Utility.isInternetAvailable(){
            DIWebLayerNotificationsAPI().readNotification(id: notificationId, completion: { (message) in
                NotificationCenter.default.post(name: Notification.Name.notificationChange, object: nil)
            }) { (error) in
                // error handler
            }
        }
    }
    /// call this method to handle the notification redirections
    func handleNotificationAction(notification: NSDictionary) {
        let data = (notification["sent_data"] as? String)?.convertStringToDictionary()
        let id = data?["id"] as? String ?? ""
        if let type = notification["type"] as? String,UserManager.isUserLoggedIn() {
            self.readNotification(notificationId: id)
            if let notificationType = NotificationType(rawValue: type) {
                switch notificationType {
                case .stream:
                    guard let affiliateID = data?["affiliate_id"] as? String else { return }
                    let state = UIApplication.shared.applicationState
                    print("Affiliate ID\(affiliateID) app state \(state)")
                    
                    if state == .inactive {
                        Stream.isComingFromInActiveApp = true
                        SplashViewController.isSplash = true
                        Stream.affiliateID = affiliateID
                        postAfterADelay(affiliateID)
                    } else {
                        navigateToTopVC(affiliateID)
                        Stream.isComingFromInActiveApp = false
                    }
                case .acceptFriendRequest:
                    NavigateTo.userProfileViewController(userId: id)
                case .sentFriendRequest, .remindFriendRequest:
                    NavigateTo.networkViewController()
                case .createPost :
                    NavigateTo.postDetailViewController(id: id)
                case .likePost :
                    UserDefaults().setValue(Constant.ScreenSize.SCREEN_WIDTH, forKey: "Height")
                    NavigateTo.postDetailViewController(id: id,isUserActionsFromPushNotification: true)
                case .commentPost:
                    NavigateTo.postDetailViewController(id: id,isLikeNotification: false,isUserActionsFromPushNotification: true)
                case .createGoal:
                    NavigateTo.redirectToGoalDetail(id: id)
                case .createChallenge:
                    NavigateTo.redirectToChallengeDetail(id: id)
                case .event:
                    NavigateTo.redirectToEventDetail(id:id)
                case .message, .newGroupAdded:
                    let roomId = data?["chat_room_id"] as? String ?? ""
                    let name = data?["name"] as? String ?? ""
                    NavigateTo.redirectToChatScreen(room_id: roomId, chat_name: name)
                case .challengeChat:
                    let roomId = data?["chat_room_id"] as? String ?? ""
                    NavigateTo.redirectToChallengeDetail(id: roomId)
                case .goalChat:
                    let roomId = data?["chat_room_id"] as? String ?? ""
                    NavigateTo.redirectToGoalDetail(id: roomId)
                case .commentFoodTrek, .createFoodTrek:
                    NavigateTo.foodTrekComments(id: id)
                case .likeFoodTrek:
                    NavigateTo.postDetailViewController(id: id,isUserActionsFromPushNotification: true, isFoodTrekPost: true)
                case .todo:
                    NavigateTo.redirectToToDoDetail(id: id)
                case .addToMyTodo:
                    NavigateTo.redirectToToDoList()
                default : break
                }
            }
        }
    }
    func navigateToTopVC(_ affID:String) {
        if let topView = UIApplication.topViewController() as? DIBaseController{
            Stream.connect.toServer(affID,true,topView)
            
        }
    }
    
    //This Fucntion will call after getting the notification....
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present notification called")
        let notification = notification.request.content.userInfo
        if let visibleController = Utility.getCurrentViewController() {
            var chatController: ChatViewController?
            
            if visibleController is ChatViewController {
                chatController = visibleController as? ChatViewController
            } else if let visibleTabBarController = visibleController as? TabBarViewController {
                if let chatNavigation = visibleTabBarController.viewControllers?[3] as? UINavigationController,
                   let chatVC = chatNavigation.viewControllers.last as? ChatViewController {
                    chatController = chatVC
                }
            }
            let data = (notification["sent_data"] as? String)?.convertStringToDictionary()
            if let type = notification["type"] as? String,
               let notificationType = NotificationType(rawValue: type) {
                switch notificationType {
                case .message:
                    let notificationRoomId = data?["chat_room_id"] as? String
                    let currentVisibleChatRoomId = chatController?.chatRoomId
                    if notificationRoomId == currentVisibleChatRoomId {
                        //donot present the notification alert to the user as the user is already on the chat screen for this chat room
                        completionHandler([])
                    }
                case .stream:
                    guard let affiliateID = data?["affiliate_id"] as? String else { return }
                    print("Affiliate ID \(affiliateID)")
                    //print(data)
                    // let name = data?["name"] as? String
                    let profileImg = notification["profile"] as? String
                    let isAdmin = notification["isAdmin"] as? Int ?? 0 == 1
                    let textMsg = notification["body"] as? String
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        Stream.connect.getAllStreamers()
                    })
                default:
                    UserManager.updateUnreadCount(+)
                    NotificationCenter.default.post(name: Notification.Name.notificationChange, object: nil)
                    if let controller = visibleController as? LeftSideMenuController {
                        controller.reloadData()
                    }
                }
            }
        }
        DILog.print(items: "notificaition willPresent \(notification)")
        completionHandler([.alert, .sound])
    }
    
} //Extension.......


//For the Notification
enum NotificationType: String {
    case defaultType = "0"
    case createPost = "1"
    case sentFriendRequest = "2"
    case acceptFriendRequest = "3"
    case likePost = "5"
    case remindFriendRequest = "6"
    case commentPost = "7"
    case createChallenge = "8"
    case createGoal = "9"
    case silentGoalCompleted = "10"
    case event = "11"
    case message = "12"
    case newGroupAdded = "13"
    case challengeChat = "16"
    case goalChat = "17"
    case commentFoodTrek = "21"
    case stream = "50"
    case todo = "22"
    case dailyJourney = "23"
    case likeFoodTrek = "24"
    case addToMyTodo = "25"
    case createFoodTrek = "26"
}

class NavigateTo {
    class func networkViewController() {
        let controller:NetworkViewController = UIStoryboard(storyboard: .network).initVC()
        if let visibleController = Utility.getCurrentViewController() {
            if visibleController is NetworkViewController {
                    return
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    class func foodTrekComments(id: String) {
        let controller:CommentsController = UIStoryboard(storyboard: .post).initVC()
        controller.postId = id
        controller.isFromFoodTrek = true
        if let visibleController = Utility.getCurrentViewController() {
            if visibleController is CommentsController {
                visibleController.navigationController?.popToRootViewController(animated: false)
                if let homeVC = Utility.getCurrentViewController() {
                    homeVC.navigationController?.pushViewController(controller, animated: true)
                }
                return
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    class func userProfileViewController(userId:String) {
        let controller: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        controller.otherUserId = userId
        if let visibleController = Utility.getCurrentViewController() {
            if let controller = visibleController as? ProfileDashboardController {
                if controller.otherUserId ?? "" == userId {
                    controller.handleNotification()
                    return
                }
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    class func redirectToGoalDetail(id:String){
        let controller: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
        controller.goalId = id
        SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
        if let visibleController = Utility.getCurrentViewController() {
            if let controller = visibleController as? GoalDetailContainerViewController {
                if controller.goalId ?? "" == id {
                    let notification = Notification(name: NSNotification.Name(refreshGoalData), object: nil, userInfo: nil)
                    NotificationCenter.default.post(notification)
                    return
                }
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    class func redirectToEventDetail(id:String){
        let controller: EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
        controller.eventId = id
        if let visibleController = Utility.getCurrentViewController() {
            if let controller = visibleController as? EventDetailViewController {
                if controller.eventId == id {
                    controller.getEventDetail()
                    return
                }
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    class func redirectToChatScreen(room_id:String,chat_name:String){
        let controller: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        controller.chatRoomId = room_id
        controller.chatName = chat_name
        if let visibleController = Utility.getCurrentViewController() {
            if let visibleVC = visibleController as? ChatViewController {
                if visibleVC.chatRoomId == room_id {
                    return
                }else{
                    //controller.refreshChat()
                    //remove the current visible chat screen from stack so that large number of screens donot get overloaded on the stack
                    visibleController.navigationController?.pushViewController(controller, animated: true)
                    visibleVC.removeCurrentControllerFromStack()
                    return
                }
            }
            if let visibleTabBarController = visibleController as? TabBarViewController,
               let chatNavigation = visibleTabBarController.viewControllers?[3] as? UINavigationController,
               let chatController = chatNavigation.viewControllers.last as? ChatViewController {
                if chatController.chatRoomId != room_id {
                    visibleController.navigationController?.pushViewController(controller, animated: true)
                    chatController.removeCurrentControllerFromStack()
                    return
                }
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    class func redirectToChallengeDetail(id:String) {
        let controller: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
        controller.challengeId = id
        SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
        if let visibleController = Utility.getCurrentViewController() {
            if let controller = visibleController as? ChallengeDetailController {
                if controller.challengeId ?? "" == id {
                    controller.refresh()
                    return
                }
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }

    class func redirectToToDoDetail(id: String) {
        let controller: ToDoActivityDetailViewController = UIStoryboard(storyboard: .todo).initVC()
        let toDoDetailViewModal = ToDoDetailViewModal(id: id){}
        controller.viewModal = toDoDetailViewModal
        controller.screenFrom = .notification
        SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
        if let visibleController = Utility.getCurrentViewController() {
            if let controller = visibleController as? ToDoActivityDetailViewController {
                if controller.viewModal.modal?.affiliateId ?? "" == id {
                    return
                }
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }

    class func redirectToToDoList() {
        let controller: ToDoActivitiesListViewController = UIStoryboard(storyboard: .todo).initVC()
        SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
        if let visibleController = Utility.getCurrentViewController() {
            if let controller = visibleController as? ToDoActivitiesListViewController {
                return
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: controller)
                return
            }
            visibleController.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    class func postDetailViewController(id:String,isLikeNotification:Bool = true,isUserActionsFromPushNotification:Bool = false, isFoodTrekPost: Bool = false) {
        let posDetailcontroller : PostDetailController = UIStoryboard(storyboard: .profile).initVC()
        posDetailcontroller.postId = id
        posDetailcontroller.isLikeNotification = isLikeNotification
        posDetailcontroller.isFoodTrekPost = isFoodTrekPost
        posDetailcontroller.isUserActionsFromPushNotification = isUserActionsFromPushNotification
        let notification = Notification(name: NSNotification.Name(refreshPostData), object: nil, userInfo: [
            "postId": id , "isLikeNotification" : isLikeNotification
        ])
        NotificationCenter.default.post(notification)
        if let visibleController = Utility.getCurrentViewController() {
            if let controller = visibleController as? PostDetailController {
                if controller.postId == id || controller.post?.id == id {
                    controller.postId = id
                    controller.isLikeNotification = isLikeNotification
                    posDetailcontroller.isFoodTrekPost = isFoodTrekPost
                    controller.isUserActionsFromPushNotification = isUserActionsFromPushNotification
                    controller.handleRedirectionOfPush()
                    //  controller.fetchPostDetails()
                    return
                }
            }else if let controller = visibleController as? CommentsController {
                if controller.postId == id {
                    controller.refreshDataOnPush()
                    return
                }
            }else if let controller = visibleController as? UsersListingViewController {
                if controller.presenter?.id == id {
                    controller.fetchNewData()
                    return
                }
            }
            if visibleController is SplashViewController {
                appDelegate.setNavigationToRootWithHome(viewContoller: posDetailcontroller)
                return
            }
            visibleController.navigationController?.pushViewController(posDetailcontroller, animated: true)
            return
        }
    }
}
