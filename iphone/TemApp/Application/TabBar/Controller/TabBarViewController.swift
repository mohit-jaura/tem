//
//  TabBarViewController.swift
//  TemApp
//
//  Created by Harpreet on 18/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Mute
import MediaPlayer
import Firebase

enum DashboardController:String {
    case homePage = "HomePageViewController", feeds = "FeedsViewController", report = "ReportViewController", network = "NetworkViewController", activity = "ActivityContoller" , activityProgress = "ActivityProgressController"
}

class TabBarViewController: UITabBarController {
    private var observerAdded: Bool?
    var topSafeArea: CGFloat = 0
    private var bottomSafeArea: CGFloat = 0
    let button = UIButton(type: .custom)
    
    //Chat initializers
    private var chatList: [ChatRoom]?
    private var chatNetworkLayer = DIWebLayerChatApi()
    private var chatManager = ChatManager()
    private var unreadChatCount = 0
    //Firestore listener handlers dictionary, these will be updated for each chat room
    var listneresByChatRoomId: [String: ListenerRegistration] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        for vc in self.viewControllers! {
            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        if let controller = (self.viewControllers?[3] as? UINavigationController)?.viewControllers.first as? ChatListingViewController {
            controller.isTabbarChild = true
        }
        if let controller = (self.viewControllers?[4] as? UINavigationController)?.viewControllers.first as? ActivityContoller {
            controller.isTabbarChild = true
        }
        
        clearTitles()
        self.listenVolumeButton()
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllListenersRegistered), name: Notification.Name.removeFirestoreListeners, object: nil)
        //        self.tabBar.items?[3].badgeValue = "5"
        intializer()
        self.getChatListing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func clearTitles() {
        guard let items = tabBar.items else { return }
        for (index, _) in items.enumerated(){
            tabBar.items![index].title = nil
        }
    }
    
    deinit {
        self.removeVolumeListeners()
        print("deinit of tabbar view")
    }
    
    // MARK: Private Methods.....
    
    //Intializer.....
    
    private func intializer() {
        //   self.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: -6, right: 0)
        disableTheDefaultCenterTbaBarButton() //To Call disable default middle button.....
//        setCenterTabBarButton()
    }
    
    //This Fucntion will disable the default middle button....
    private func disableTheDefaultCenterTbaBarButton() {
        if let arrayOfTabBarItems = self.tabBar.items as AnyObject as? NSArray,let
            tabBarItem = arrayOfTabBarItems[2] as? UITabBarItem {
            tabBarItem.isEnabled = false
        }
        
    }
    
    
    private func changeTheColorOfAllTabBarButtons() {
        self.selectedIndex = 2
    }
    
    //This Fucntion will override the tabbar middle button....
    
    private func setCenterTabBarButton() {
        
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first {
                let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                topSafeArea = safeFrame.minY
                bottomSafeArea = window.frame.maxY - safeFrame.maxY
            }
        }
        button.frame = CGRect(x: self.tabBar.center.x - 23 , y: self.tabBar.center.y - (40 + bottomSafeArea), width: 46, height: 52)
        button.setBackgroundImage(#imageLiteral(resourceName: "t-honeycomb"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        //Add Target on Button.....
        button.addTarget(self, action: #selector(redirectToActivityVC), for: .touchUpInside)
        button.tag = 98762
        // UIApplication.shared.keyWindow?.addSubview(button)
        self.view.insertSubview(button, aboveSubview: self.tabBar)
        
    }
    
    func tabbarHandling(isHidden:Bool = true,controller:UIViewController) {
        controller.tabBarController?.tabBar.isHidden = true
        button.isHidden = true
        
    }
    
    
    // MARK: Redirection....
    
    @objc private func redirectToActivityVC() {
        changeTheColorOfAllTabBarButtons()
    }
    
    // MARK: Output Volume Helpers
    /// observing the key path observers and get the respective value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constant.KeyPathObserver.outputVolume {
            let outputVolume = AVAudioSession.sharedInstance().outputVolume
            //if the output volume is 0 then change the mute status to false (mute the videos), else change it to true
            if outputVolume == 0.0 {
                updateDefaultsForSoundStatus(withValue: true)
            } else {
                updateDefaultsForSoundStatus(withValue: false)
            }
            self.outputVolumeChanged()
        }
    }
    
    /// add observer to listen the volume change notifications from the device
    func listenVolumeButton(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("error")
        }
        audioSession.addObserver(self, forKeyPath: Constant.KeyPathObserver.outputVolume,
                                 options: NSKeyValueObservingOptions.new, context: nil)
        self.observerAdded = true
        Mute.shared.alwaysNotify = false
        Mute.shared.notify = { [weak self] status in
            self?.updateDefaultsForSoundStatus(withValue: status)
            self?.outputVolumeChanged()
        }
    }
    
    func updateDefaultsForSoundStatus(withValue value: Bool) {
        Defaults.shared.set(value: value, forKey: .muteStatus)
    }
    
    func removeVolumeListeners() {
        if let observerdAdded = observerAdded,
            observerdAdded == true {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: Constant.KeyPathObserver.outputVolume)
            self.observerAdded = false
        }
    }
    
    func outputVolumeChanged() {
        NotificationCenter.default.post(name: Notification.Name.outputVolumeChanged, object: self, userInfo: nil)
    }
    
}//Class....

extension TabBarViewController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let controller = (self.viewControllers?[4] as? UINavigationController)?.viewControllers.first as? ActivityContoller {
            controller.isTabbarChild = true
        }
        if let controller = (self.viewControllers?[2] as? UINavigationController)?.viewControllers.first as? ReportViewController {
            controller.removePopOverIfAny()
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("controller ===========")
    }
}

// MARK: Fetch new messages count
extension TabBarViewController {
    // MARK: Api call
    func getChatListing() {
        guard Reachability.isConnectedToNetwork() else {
            return
        }
        self.chatNetworkLayer.getChatList(searchString: nil, type: 1, subdomain: Constant.SubDomain.getChatListing, completion: {[weak self] (chatList) in
            if let list = chatList {
                self?.setDataSourceWith(data: list)
            }
        }) { (_) in
            
        }
    }
    
    /// call this function to set the data source array
    ///
    /// - Parameter data: array of chat lists
    private func setDataSourceWith(data: [ChatRoom]) {
        if self.chatList == nil {
            self.chatList = [ChatRoom]()
        }
        self.chatList?.append(contentsOf: data)
        self.observeForNewChatRooms()
        self.addObserverOnEachChatRoom(data: data)
    }
    
    private func addObserverOnEachChatRoom(data: [ChatRoom]) {
        for chatInfo in data {
            if let roomId = chatInfo.chatRoomId,
                !roomId.isEmpty {
                self.fetchLastMessage(roomId: roomId)
                self.listenToOnChatScreenStatus(roomId: roomId)
            }
        }
    }
    
    @objc func removeAllListenersRegistered() {
        self.chatManager.chatsParentListener?.remove()
        for (_, value) in self.listneresByChatRoomId {
            value.remove()
        }
    }
    
    private func listenToOnChatScreenStatus(roomId: String) {
        self.chatManager.checkOnChatScreenStatusOfUser(roomId: roomId) {[weak self] (chatRoomId) in
            //user is on chat view for this chat room, reset the unread count to zero for this chat room
            self?.updateUnreadCount(forChatRoom: chatRoomId)
        }
    }
    
    private func observeForNewChatRooms() {
        self.chatManager.chatsParentListener?.remove()
        self.chatManager.observeNewChatRoomAdded {[weak self] (chatInfo, diffType) in
            guard let wkSelf = self,
                let roomId = chatInfo.chatRoomId else {
                    return
            }
            /*
             check if the room id is already present in the chatlist or not. If it is already present, just skip the process if this is not present in the chatList from server then check if the members of this chat room contains the current user id (means this is the chat room of the current logged in user) and then add the observer on this chat room id to fetch the last message.
             */
            guard (wkSelf.isAlreadyPresentInChatList(chatRoomId: roomId) == false && wkSelf.isCurrentUserPresentInChatRoom(chatInfo: chatInfo) == true) else {
                return
            }
            self?.chatList?.append(chatInfo)
            self?.fetchLastMessage(roomId: roomId)
            self?.listenToOnChatScreenStatus(roomId: roomId)
        }
    }
    
    ///check if the passed room id lies in the chat list data source array
    private func isAlreadyPresentInChatList(chatRoomId: String) -> Bool {
        let containValue = self.chatList?.contains(where: { (chatInfo) -> Bool in
            return chatInfo.chatRoomId == chatRoomId
        })
        if let value = containValue,
            value == true {
            return true
        }
        return false
    }
    
    ///check if the current logged in user is present in the members of chat room
    private func isCurrentUserPresentInChatRoom(chatInfo: ChatRoom) -> Bool {
        let containValue = chatInfo.memberIds?.contains(where: { (id) -> Bool in
            return id == UserManager.getCurrentUser()?.id
        })
        if let value = containValue,
            value == true {
            return true
        }
        return false
    }
    
    private func fetchLastMessage(roomId: String) {
        
        //remove observer if was already added on this room id
        if let listener = self.listneresByChatRoomId[roomId] {
            listener.remove()
        }
        
        let handler = self.chatManager.addObserverOnChatRoomToFetchLastMessage(roomId: roomId, completion: {[weak self] (message) in
            self?.fetchUnreadCount(forRoomId: roomId)
            }, failure: { (error) in
                
        })
        //update in the listeners object
        self.listneresByChatRoomId[roomId] = handler
    }
    
    ///fetch unread count on a chat room
    private func fetchUnreadCount(forRoomId id: String) {
        chatManager.fetchUnreadCount(roomId: id) {[weak self] (count, chatRoomId) in
            
            //checking if the visible controller is chat view with the same chatRoomId, if this is the same controller, donot update the unread count
            if let visibleController = self?.navigationController?.visibleViewController as? ChatViewController {
                if visibleController.chatRoomId == chatRoomId {
                    return
                }
            } else if let tabBarController = self?.navigationController?.visibleViewController as? TabBarViewController,
                let selectedViewController = tabBarController.selectedViewController as? UINavigationController,
                let chatController = selectedViewController.viewControllers.last as? ChatViewController {
                if chatController.chatRoomId == chatRoomId {
                    return
                }
            }
            
            if let index = self?.chatList?.firstIndex(where: ( { $0.chatRoomId == chatRoomId } )) {
                //index of the item matching the returned one
                self?.chatList?[index].unreadCount = count
                self?.displayUnreadCount()
            }
        }
    }
    
    /// display unread count on the tab bar item
    private func displayUnreadCount() {
        let filteredList = self.chatList?.filter({ (chatInfo) -> Bool in
            if let unreadCount = chatInfo.unreadCount {
                return unreadCount > 0
            }
            return false
        })
        if let filtereList = filteredList,
            !filtereList.isEmpty {
            self.unreadChatCount = filtereList.count
            self.setBadgeValue()
        } else {
            self.unreadChatCount = 0
            self.tabBar.items?[3].badgeValue = nil
        }
    }
    
    private func setBadgeValue() {
        if unreadChatCount > 0 {
            self.tabBar.items?[3].badgeValue = "\(self.unreadChatCount)"
        } else {
            self.tabBar.items?[3].badgeValue = nil
        }
    }
    
    /// update the unread count in a room
    func updateUnreadCount(forChatRoom roomId: String) {
        let chatInfo = self.chatList?.filter({ (chatInfo) -> Bool in
            return chatInfo.chatRoomId == roomId
        })
        if let unreadCount = chatInfo?.first?.unreadCount,
            unreadCount > 0 {
            chatInfo?.first?.unreadCount = 0
            if unreadChatCount > 0 {
                self.unreadChatCount -= 1
            } else {
                self.unreadChatCount = 0
            }
        }
        self.setBadgeValue()
    }
}
