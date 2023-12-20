//
//  ChatListingViewController.swift
//  TemApp
//
//  Created by shilpa on 10/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SSNeumorphicView

class ChatListingViewController: DIBaseController {
    
    // MARK: Properties
    private let chatNetworkLayer = DIWebLayerChatApi()
    private var chatList: [ChatRoom]?
    var screenFrom: Constant.ScreenFrom?
    var isTabbarChild = false
    let grayishColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
    let currentViewColor = #colorLiteral(red: 0.2445946932, green: 0.5110557079, blue: 0.8628123403, alpha: 1)
    //the chatlist array filtered on basis of search results
    private var filteredChatList: [ChatRoom]?
    private let chatManager = ChatManager()
    private var isSearchActive = false
    private var searchText = ""
    private var searchViewHeightValue: CGFloat = 50.0
    private var shouldShowLoader: Bool = true
    private var isScreenFromGlobalSearch: Bool {
        if let screenFrom = self.screenFrom,
           screenFrom == .searchAppUsers {
            return true
        }
        return false
    }
    
    //Firestore listener handlers dictionary, these will be updated for each chat room
    private var listneresByChatRoomId: [String: ListenerRegistration?] = [:]
    private var listenersForUserInformationUpdate: [String: ListenerRegistration] = [:]
    private var lsitenersForChatRoomInfo: [String: ListenerRegistration] = [:]
    private var refreshControl: UIRefreshControl?
    private var navBar: NavigationBar?
    var isShadowAddedToButton = false
    var chatType = ChatType.singleChat.rawValue
    
    // MARK: IBOutlets
    @IBOutlet weak var navigationBarLineView: SSNeumorphicView! {
        didSet{
            navigationBarLineView.viewDepthType = .outerShadow
            navigationBarLineView.viewNeumorphicMainColor = grayishColor.cgColor
            navigationBarLineView.viewNeumorphicLightShadowColor = grayishColor.cgColor
            navigationBarLineView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            navigationBarLineView.viewNeumorphicCornerRadius = 0
        }
    }

    @IBOutlet weak var newTemButtonHeightconstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChatsMessageLabel: UILabel!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBottomCons: NSLayoutConstraint!
    @IBOutlet weak var searchTopConst: NSLayoutConstraint!
    @IBOutlet weak var topForNewBut: NSLayoutConstraint!

    @IBOutlet weak var temsBgView: SSNeumorphicView!{
        didSet{
            setShadow(view: temsBgView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
        }
    }
    @IBOutlet weak var msgBgView: SSNeumorphicView!{
        didSet{
            setShadow(view: msgBgView, mainColor: grayishColor, lightShadow: grayishColor, darkShadow: grayishColor)
        }
    }
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var initiateChatButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var temsButton: UIButton!
    @IBOutlet weak var newTemButton: SSNeumorphicButton!{
        didSet{
            newTemButton.btnNeumorphicCornerRadius = 23
            newTemButton.btnNeumorphicShadowRadius = 0.8
            newTemButton.btnDepthType = .outerShadow
            newTemButton.btnNeumorphicLayerMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
            newTemButton.btnNeumorphicShadowOpacity = 0.25
            newTemButton.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            newTemButton.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            newTemButton.btnNeumorphicLightShadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }

    
    @IBAction func newTemButtonTapped(_ sender: SSNeumorphicButton) {
        let createGroupVC: CreateGroupViewController = UIStoryboard(storyboard: .chat).initVC()
        self.navigationController?.pushViewController(createGroupVC, animated: true)
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func temsButtonTapped(_ sender: Any) {
        chatType =  ChatType.groupChat.rawValue
        getChatListing(searchText:nil)
        topForNewBut.constant = 20
        tableView.reloadData()
        newTemButton.isHidden = false
        configureView(selectedButton:temsButton, view: temsBgView, unselectedButton: messageButton, unSelectedView: msgBgView)
        newTemButtonHeightconstraint.constant = 46
        
    }
    @IBAction func messagesButtonTapped(_ sender: UIButton) {
        chatType = ChatType.singleChat.rawValue
        getChatListing(searchText:nil)
        tableView.reloadData()
        newTemButton.isHidden = true
        topForNewBut.constant = 0
        newTemButtonHeightconstraint.constant = 0
        configureView(selectedButton:messageButton, view: msgBgView, unselectedButton: temsButton, unSelectedView: temsBgView)
        
    }
    func configureView(selectedButton:UIButton, view: SSNeumorphicView, unselectedButton:UIButton, unSelectedView: SSNeumorphicView){
        setShadow(view: unSelectedView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
        selectedButton.setBackgroundColor(currentViewColor, forState: .normal)
        unselectedButton.setBackgroundColor(grayishColor, forState: .normal)
    }
    @IBAction func initiateChatButtonTapped(_ sender: UIButton) {
        let selectFriendController: SelectFriendViewController = UIStoryboard(storyboard: .chat).initVC()
        self.navigationController?.pushViewController(selectFriendController, animated: true)
    }
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        if self.searchViewHeight.constant == searchViewHeightValue {
            return
        }
        self.searchBar.text = nil
        self.searchViewHeight.constant += searchViewHeightValue
        self.searchTopConst.constant = 12
        self.searchBottomCons.constant = 12

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    // MARK: IBActions
    @IBAction func dismissSearchBar(_ sender: UIButton) {
        //dismiss the search bar
        if self.searchViewHeight.constant == 0 {
            return
        }
        self.searchBar.resignFirstResponder()
        self.resetSearchList()
        self.reloadTable()
        self.searchViewHeight.constant -= searchViewHeightValue
        self.searchTopConst.constant = 0
        self.searchBottomCons.constant = 5

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(chatCleared(notification:)), name: Notification.Name.chatCleared, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeListeners), name: Notification.Name.removeFirestoreListeners, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitedFromGroup(notification:)), name: Notification.Name.exitedFromGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(joinedGroup(notification:)), name: Notification.Name.joinedGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(groupDeleted(notification:)), name: Notification.Name.groupDeleted, object: nil)
        tableView.registerNibs(nibNames: [ChatListTableViewCell.reuseIdentifier])
        self.initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addBadgeObserver()
        self.configureTabbar()
        //   self.configureNavigation()
        self.getUnreadNotificationsCount()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setDefaultNavigationBar()
        if let parent = self.parent as? SearchViewController {
            parent.navigationController?.navigationBar.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeBadgeObserver()
    }
    
    deinit {
        self.removeListeners()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification observers
    func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeNotificationRead), name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUnreadNotificationsCount), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }

    private func setShadow(view: SSNeumorphicView, mainColor: UIColor,lightShadow:UIColor,darkShadow:UIColor){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = mainColor.cgColor
        view.viewNeumorphicLightShadowColor = lightShadow.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = darkShadow.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 0
    }
    // MARK: Initializer
    private func initialize() {
        backBtn.addDoubleShadowToButton(cornerRadius: backBtn.frame.height / 2, shadowRadius: 0.4, lightShadowColor: UIColor.white.withAlphaComponent(0.1).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor: grayishColor)
        if screenFrom == .affiliativeContent{
            chatType =  ChatType.groupChat.rawValue
            configureView(selectedButton:temsButton, view: temsBgView, unselectedButton: messageButton, unSelectedView: msgBgView)
            newTemButton.isHidden = false
            newTemButtonHeightconstraint.constant = 46
            topForNewBut.constant = 20
            tableView.reloadData()
        }else{
            topForNewBut.constant = 0
            newTemButton.isHidden = true
            newTemButtonHeightconstraint.constant = 0
        }
        self.searchTopConst.constant = 0
        self.searchBottomCons.constant = 5
        
        if isShadowAddedToButton == false{
            searchButton.addDoubleShadowToButton(cornerRadius: backBtn.frame.height / 2, shadowRadius: 0.4, lightShadowColor: UIColor.white.withAlphaComponent(0.1).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor: grayishColor)
            isShadowAddedToButton = true
        }
        if self.isScreenFromGlobalSearch {
            updateBadgeNotificationRead()
            self.navigationBarHeightConstraint.constant = 0
            self.navigationBarLineView.isHidden = true
            self.tableView.showEmptyScreen(AppMessages.GlobalSearch.noTems)
            return
        }
        self.addRefreshControl()
        self.tableView.showAnimatedSkeleton()
        self.getChatListing(searchText: nil)
    }
    
    // MARK: Add refresh control
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func onPullToRefresh(sender: UIRefreshControl) {
        self.getChatListing(searchText: searchText)
    }
    
    //configure the navigation bar and its properties
    private func configureNavigation() {
        if let screenFrom = self.screenFrom,
           screenFrom == .dashboard {
        }else{
            self.updateBadgeNotificationRead()
        }
    }
    
    //configure tab bar for this view
    private func configureTabbar() {
        if !self.isTabbarChild || self.screenFrom == .dashboard {
            if let tabBarController = self.tabBarController as? TabBarViewController {
                tabBarController.tabbarHandling(isHidden: true, controller: self)
            }
        } else {
            if let tabBarController = self.tabBarController as? TabBarViewController {
                tabBarController.tabbarHandling(isHidden: false, controller: self)
            }
        }
    }
    
    //    // MARK: NavigationBar right buttons actions.
    override func navigationBar(_ navigationBar: NavigationBar, rightButtonTapped rightButton: UIButton) {
        switch navigationBar.rightAction[rightButton.tag]  {
        case .startNewChat:
            let selectFriendController: SelectFriendViewController = UIStoryboard(storyboard: .chat).initVC()
            self.navigationController?.pushViewController(selectFriendController, animated: true)
        case .search :
            //show the search bar view
            if self.searchViewHeight.constant == searchViewHeightValue {
                return
            }
            self.searchBar.text = nil
            self.searchViewHeight.constant = self.searchViewHeight.constant + searchViewHeightValue
            self.searchTopConst.constant = 12
            self.searchBottomCons.constant = 12
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
    
    override func navigationBar(_ navigationBar: NavigationBar, leftButtonTapped leftButton: UIButton) {
        switch navigationBar.leftAction {
        case .menu:
            self.presentSideMenu()
        default:
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: Helpers

    @objc func updateBadgeNotificationRead() {
        self.navBar?.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
    }
    
    private func chatListArray() -> [ChatRoom]? {
        if isSearchActive {
            return sortChatListing(chats: self.filteredChatList)
        } else {
            return sortChatListing(chats: self.chatList)
        }
    }
    
    private func sortChatListing(chats:[ChatRoom]?) -> [ChatRoom]?{
        var sortedChats: [ChatRoom] = []
        var chatListWithMsg: [ChatRoom] = []
        var chatListWithoutMsg: [ChatRoom] = []
        
        guard let chats = chats else {
            return nil
        }
        chats.forEach({ chatInfo in
            if let message = chatInfo.lastMessage?.text, !message.isEmpty {
                chatListWithMsg.append(chatInfo)
            }else{
                chatListWithoutMsg.append(chatInfo)
            }
        })
        
        sortedChats = chatListWithMsg.sorted(by:{
            return $0.lastMessage?.time?.toDate ?? Date() > $1.lastMessage?.time?.toDate  ?? Date()
        })
        return sortedChats + chatListWithoutMsg
    }
    
    @objc func removeListeners() {
        //removing listeners registered in controller
        for (_, listener) in self.listneresByChatRoomId {
            listener?.remove()
        }
        for (_, listener) in self.listenersForUserInformationUpdate {
            listener.remove()
        }
        for (_, listener) in self.lsitenersForChatRoomInfo {
            listener.remove()
        }
        self.chatManager.chatsParentListener?.remove()
    }
    
    // MARK: Api call
    @objc func getUnreadNotificationsCount() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count,_) in
            self.navBar?.displayBadge(unreadCount: count)
        }
    }
    
    func getChatListing(searchText: String?) {
        if self.shouldShowLoader {
            self.showLoader()
            self.shouldShowLoader = false
        }
        guard Reachability.isConnectedToNetwork() else {
            self.showErrorOnViewWith(message: AppMessages.AlertTitles.noInternet)
            return
        }
        var subdomain = Constant.SubDomain.getChatListing
        if isScreenFromGlobalSearch {
            subdomain = Constant.SubDomain.searchTems
        }
        self.chatNetworkLayer.getChatList(searchString: searchText, type: chatType, subdomain: subdomain, completion: {[weak self] (chatList) in
            self?.hideLoader()
            if let list = chatList {
                self?.setDataSourceWith(data: list)
            } else {
                DispatchQueue.main.async {
                    self?.tableView.hideSkeleton()
                    self?.noChatsMessageLabel.isHidden = false
                }
            }
        }) {[weak self] (error) in
            self?.showErrorOnViewWith(message: error.message ?? "")
        }
    }
    
    func deleteChatOnServer(roomId: String) {
        self.chatNetworkLayer.deleteChat(chatRoom: roomId)
    }
    
    /// call this function to set the data source array to display on screen
    ///
    /// - Parameter data: array of chat lists
    private func setDataSourceWith(data: [ChatRoom]) {
        if self.chatList == nil {
            self.chatList = [ChatRoom]()
        }
        self.removeListeners()
        self.chatList?.removeAll()
        self.chatList?.append(contentsOf: data)
        
        self.observeForNewChatRooms()
        self.refreshControl?.endRefreshing()
        if let chatList = self.chatList,
           chatList.isEmpty {
            self.tableView.hideSkeleton()
            
            if !isScreenFromGlobalSearch {
                //if there is not chat list of the user, display the message on screen
                self.noChatsMessageLabel.isHidden = false
            } else {
                self.showErrorOnViewWith(message: AppMessages.GlobalSearch.noTems)
            }
            if let parent = self.parent as? SearchViewController {
            }
            self.tableView.reloadData()
            // here add the observer for new chat id
            return
        } else {
            self.noChatsMessageLabel.isHidden = true
        }
        self.addObserverOnEachChatRoom(data: data)
        self.tableView.hideSkeleton()
    }
    
    private func addObserverOnEachChatRoom(data: [ChatRoom]) {
        for chatInfo in data {
            if let roomId = chatInfo.chatRoomId,
               !roomId.isEmpty {
                self.fetchLastMessage(roomId: roomId)
                if chatInfo.chatType == .groupChat {
                    self.observeForChangesInChatRoomInformation(roomId: roomId)
                }
                self.listenToOnChatScreenStatus(roomId: roomId)
            }
        }
    }
    
    private func removeObserverOnEachChatRoom(data: [ChatRoom]) {
        if let chatList = self.chatList,
           !chatList.isEmpty {
            self.removeListeners()
        }
    }
    
    private func listenToOnChatScreenStatus(roomId: String) {
        self.chatManager.checkOnChatScreenStatusOfUser(roomId: roomId) {[weak self] (chatRoomId) in
            //user is on chat view for this chat room, reset the unread count to zero for this chat room
            let chatInfo = self?.chatList?.filter({ (chatInfo) -> Bool in
                return chatInfo.chatRoomId == roomId
            })
            chatInfo?.first?.unreadCount = 0
            self?.tableView.reloadData()
        }
    }
    
    private func observeForNewChatRooms() {
        if isScreenFromGlobalSearch {
            return
        }
        self.chatManager.chatsParentListener?.remove()
        self.chatManager.observeNewChatRoomAdded {[weak self] (chatInfo, diffType) in
            guard let wkSelf = self,
                  let roomId = chatInfo.chatRoomId else {
                      return
                  }
            if diffType == .modified {
                //this is called when any of the member in a chat room is removed
                wkSelf.chatRoomModified(roomId: roomId, modifiedChatInfo: chatInfo)
                return
            }
            /*
             check if the room id is already present in the chatlist or not. If it is already present, just skip the process if this is not present in the chatList from server then check if the members of this chat room contains the current user id (means this is the chat room of the current logged in user) and then add the observer on this chat room id to fetch the last message.
             */
            guard (wkSelf.isAlreadyPresentInChatList(chatRoomId: roomId) == false && wkSelf.isCurrentUserPresentInChatRoom(chatInfo: chatInfo) == true) else {
                return
            }
            
            //getting user
            //for single chat:
            if chatInfo.chatType == .singleChat {
                let member = Friends()
                //this will always contain the two memberIds
                member.user_id = chatInfo.memberIds?.first(where: ( { $0 != UserManager.getCurrentUser()?.id } )) //this will always be the other user id
                chatInfo.members = []
                chatInfo.members?.append(member)
            }
            // for group chat
            chatInfo.isDeleted = CustomBool.no
            if self?.chatList?.isEmpty == true {
                self?.chatList = []
            }
            if chatInfo.chatType?.rawValue == self?.chatType{
                self?.chatList?.insert(chatInfo, at: 0)
            }
            self?.fetchLastMessage(roomId: roomId)
            self?.listenToOnChatScreenStatus(roomId: roomId)
        }
    }
    
    private func fetchLastMessage(roomId: String) {
        
        //remove observer if was already added on this room id
        if let listener = self.listneresByChatRoomId[roomId] {
            listener?.remove()
        }
        
        let handler = self.chatManager.addObserverOnChatRoomToFetchLastMessage(roomId: roomId, completion: {[weak self] (newMessage) in
            var message = newMessage
            //message will be nil in case when the new group is created and this handler is called
            // in this case, add a dummy message object with the time equals to the group created time
            if message == nil {
                message = Message()
                message?.chatRoomId = roomId
            }
            
            //we need to first check if that chat room id is present in this chat list as in the case of delete chat, that chatinfo gets removed from the chatList. If this is not present, just create a new chatInfo and append to the list
            if self?.isAlreadyPresentInChatList(chatRoomId: roomId) == false {
                let chatInfo = ChatRoom()
                chatInfo.chatRoomId = roomId
                if chatInfo.chatType?.rawValue == self?.chatType{
                    self?.chatList?.insert(chatInfo, at: 0)
                }
            }
            
            let filteredChat = self?.chatList?.filter({ (chatList) -> Bool in
                return chatList.chatRoomId == message?.chatRoomId
            })
            if filteredChat?.first?.chatType == .groupChat,
               filteredChat?.first?.groupChatStatus == nil {
                filteredChat?.first?.groupChatStatus = .active //this will be active, only then the execution has come to this point
            }
            //updating the last message to the chat room id
            self?.filterLastMessage(message: message, roomId: roomId, chatListInfo: filteredChat?.last)
            self?.fetchUnreadCount(forRoomId: roomId)
            if let chatType = filteredChat?.last?.chatType {
                if chatType == .singleChat {
                    //for single chat:
                    if let otherUser = filteredChat?.last?.members?.last,
                       let userId = otherUser.user_id {
                        //single chat will have one member only
                        self?.getChatUserInformation(userId: userId, chatInfo: filteredChat?.last)
                    } else {
                        //in case the members are not found, fetch ids from firestore database
                        self?.chatManager.getChatRoomInformation(roomId: roomId, completion: {[weak self] (roomInfo) in
                            if let memberId = roomInfo?.memberIds?.first(where: ({ $0 != UserManager.getCurrentUser()?.id })) { //this will be the member id of the other user
                                self?.getChatUserInformation(userId: memberId, chatInfo: roomInfo)
                            }
                        })
                    }
                } else {
                    //for group chat
                    self?.observeForChangesInChatRoomInformation(roomId: roomId)
                }
            }
            
            
        }, failure: { (_) in
            
        })
        //update in the listeners object
        self.listneresByChatRoomId[roomId] = handler
    }
    
    private func filterLastMessage(message: Message?, roomId: String, chatListInfo: ChatRoom?) {
        //get the user clear chat time from firestore database if any
        self.chatManager.getRoomInformationOfUser(roomId: roomId, completion: {[weak self] (chatInfo) in
            if let clearChatTime = chatInfo?.clearChatTime {
                if let messageTime = message?.time,
                   clearChatTime > messageTime {
                    var newMessage = Message()
                    newMessage.chatRoomId = roomId
                    newMessage.time = messageTime
                    newMessage.updatedAt = message?.updatedAt
                    chatListInfo?.lastMessage = newMessage
                    self?.sortChatOnTimeBasis()
                    return
                }
            }
            if message?.text != nil {
                if chatListInfo?.isDeleted == CustomBool.yes {
                    chatListInfo?.isDeleted = .no
                }
            }
            chatListInfo?.lastMessage = message
            if chatListInfo?.lastMessage?.time == nil {
                chatListInfo?.lastMessage?.time = chatListInfo?.createdAt
            }
            self?.sortChatOnTimeBasis()
        })
    }
    
    private func getChatUserInformation(userId: String, chatInfo: ChatRoom?) {
        if let listener = self.listenersForUserInformationUpdate[userId] {
            listener.remove()
        }
        let handler = self.chatManager.getUserInformationFrom(userId: userId, completion: {[weak self] (user) in
            //single chat will have one member only
            // to be changed for group chat
            if let filteredChatInfo = self?.chatList?.first(where: ({ $0.members?.first?.user_id == user.user_id })) {
                filteredChatInfo.name = user.fullName
                filteredChatInfo.members?[0] = user
                //if there is any update in the information, update in the tableview as well.
                self?.reloadTable()
            } else {
                // in case of new message after delete chat, the chatlist info of the chat room will not contain members
                let filteredChatInfo = self?.chatList?.first(where: ({ $0.chatRoomId == chatInfo?.chatRoomId }))
                filteredChatInfo?.chatType = chatInfo?.chatType
                filteredChatInfo?.name = chatInfo?.name
                filteredChatInfo?.members = []
                filteredChatInfo?.members?.append(user)
                
                //sort search list also
                self?.filterSearchListArray()
                
                self?.reloadTable()
            }
        }, failure: { (_) in
        })
        //update in the listeners object
        self.listenersForUserInformationUpdate[userId] = handler
    }
    
    ///fetch unread count on a chat room
    private func fetchUnreadCount(forRoomId id: String) {
        chatManager.fetchUnreadCount(roomId: id) {[weak self] (count, chatRoomId) in
            //checking if the visible controller is chat view with the same chatRoomId, if this is the same controller, donot update the unread count
            if let visibleController = self?.navigationController?.visibleViewController as? ChatViewController {
                if visibleController.chatRoomId == chatRoomId {
                    return
                }
            }
            
            if let index = self?.chatList?.firstIndex(where: ( { $0.chatRoomId == chatRoomId } )) {
                //index of the item matching the returned one
                self?.chatList?[index].unreadCount = count
                if let chatList = self?.chatList,
                   chatList.count > 0 {
                    //reload table row at this index
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = self?.tableView.cellForRow(at: indexPath) as? ChatListTableViewCell {
                        cell.updateUnreadCount(count: count)
                    }
                }
            }
        }
    }
    
    // WoRKING ON THIS
    private func chatRoomModified(roomId: String, modifiedChatInfo: ChatRoom) {
        guard let newMemberIds = modifiedChatInfo.memberIds else{
            return
        }
        //if members ids in the new chat room is not same as the member ids in the already saved chatroom
        //if current user is not present in the modified chatroom, then remove observers
        if !newMemberIds.contains((UserManager.getCurrentUser()?.id ?? "")) {
            if let listener = self.listneresByChatRoomId[roomId] {
                listener?.remove()
                listneresByChatRoomId.removeValue(forKey: roomId)
            }
        } else {
            //add listener again
            //check if the listener for this chat room is nil, if it is nil, add the listener
            if self.listneresByChatRoomId[roomId] == nil {
                if self.isAlreadyPresentInChatList(chatRoomId: roomId) == false {
                    let chatInfo = ChatRoom()
                    chatInfo.chatRoomId = roomId
                    chatInfo.chatType = modifiedChatInfo.chatType
                    chatInfo.isDeleted = .no
                    if self.chatList?.isEmpty == true {
                        self.chatList = []
                    }
                    if chatInfo.chatType?.rawValue == self.chatType{
                        self.chatList?.insert(chatInfo, at: 0)
                    }
                }
                self.fetchLastMessage(roomId: roomId)
            }
        }
    }
    
    /// delete chat at the passed index of chatlist
    private func deleteChat(chatInfo: ChatRoom?, atIndex index: Int) {
        if let chatType = chatInfo?.chatType {
            switch chatType {
            case .singleChat:
                let message = "Delete chat with \(chatInfo?.members?.first?.fullName ?? "")?"
                self.showAlert(withTitle: "", message: message, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {[weak self] in
                    self?.onDeleteChatCompletion(deleteIndex: index)
                }) {
                }
            case .groupChat:
                let message = "Delete group \"\(chatInfo?.name ?? "")\""
                self.showAlert(withTitle: "", message: message, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {[weak self] in
                    self?.onDeleteChatCompletion(deleteIndex: index)
                    NotificationCenter.default.post(name: Notification.Name.groupDeleted, object: self, userInfo: [ChatRoom.CodingKeys.chatRoomId: chatInfo?.chatRoomId ?? ""])
                }) {
                }
            }
        }
    }
    
    private func onDeleteChatCompletion(deleteIndex: Int) {
        guard let chatInfo = self.chatListArray(), let roomId = chatInfo[deleteIndex].chatRoomId else { return }
        self.deleteChatOnServer(roomId: roomId)
        self.updateUserLastSeenOnDeleteChat(forRoom: roomId)
        if isSearchActive{ self.filteredChatList?[deleteIndex].isDeleted = CustomBool.yes }
        if let indexInMainList = self.chatList?.firstIndex(where: ({$0.chatRoomId == roomId})) {
            self.chatList?[indexInMainList].isDeleted = CustomBool.yes
        }
        self.reloadTable()
    }
    
    /// this function updates the chat clear time and last seen on the firestore, so that the new messages are fetched from the time after chat deleted
    private func updateUserLastSeenOnDeleteChat(forRoom roomId: String) {
        //update user last seen time and clear chat time on firestore database.
        let time = Date().timeIntervalSince1970
        self.chatManager.saveLastSeenOfUser(lastSeen: time, forChatRoom: roomId)
        self.chatManager.updateDeleteChatStatus(roomId: roomId, userId: UserManager.getCurrentUser()?.id, status: .yes)
        self.chatManager.saveClearChatTimeOfUser(time: time, forChatRoom: roomId, completion: { (_) in
        }) { (_) in
        }
    }
    
    /// sort the chat list on the basis of time
    private func sortChatOnTimeBasis() {
        self.chatList?.sort(by: { (chatInfo1, chatInfo2) -> Bool in
            if let time1 = chatInfo1.lastMessage?.time,
               let time2 = chatInfo2.lastMessage?.time {
                return time1 > time2
            }
            return false
        })
        self.filterSearchListArray()
        self.reloadTable()
    }
    
    /// show error on screen to the user
    ///
    /// - Parameter message: error message
    private func showErrorOnViewWith(message: String) {
        self.noChatsMessageLabel.isHidden = true
        self.refreshControl?.endRefreshing()
        self.tableView.hideSkeleton()
        if self.chatList == nil || self.chatList?.isEmpty == true {
            self.tableView.showEmptyScreen(message)
        } else {
            self.showAlert(message: message)
        }
        if let parent = self.parent as? SearchViewController {
        }
    }
    
    /// this is to get the name and icon of the chat room and adds the observer which gets called anytime when the chat room information changes
    func observeForChangesInChatRoomInformation(roomId: String) {
        if self.lsitenersForChatRoomInfo[roomId] == nil {
            //if there was no listener of chat room info for this chat room id, then only add it
            let handler = self.chatManager.getChatRoomNameAndIcon(roomId: roomId, completion: { (room) in
                let currentChatItem = self.chatList?.first(where: ({$0.chatRoomId == room?.chatRoomId}))
                currentChatItem?.name = room?.name
                currentChatItem?.icon = room?.icon
                currentChatItem?.createdAt = room?.createdAt
                self.reloadTable()
            })
            self.lsitenersForChatRoomInfo[roomId] = handler
        }
    }
    
    // MARK: Helper functions
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
    
    private func reloadTable() {
        self.tableView.restore()
        self.tableView.reloadData()
        //check if all the entries in chatlist are deleted ones
        let filtered = self.chatList?.filter(({$0.isDeleted == CustomBool.no}))
        if let total = filtered,
           total.isEmpty {
            self.noChatsMessageLabel.isHidden = false
        } else {
            self.noChatsMessageLabel.isHidden = true
        }
    }
    
    //filter the search list array from the chat list on the basis of search text
    private func filterSearchListArray() {
        let filteredArray = self.chatList?.filter({ (chatInfo) -> Bool in
            //in case of single chat, the filtering will be done based on the first and last name, and in the case of group chat. the filtering will be done based on the group name
            if let chatType = chatInfo.chatType {
                if chatType == .singleChat {
                    let name = chatInfo.members?.first?.fullName ?? ""
                    return name.containsIgnoringCase(other: searchText)
                } else {
                    let name = chatInfo.name ?? ""
                    return name.containsIgnoringCase(other: searchText)
                }
            }
            return false
        })
        self.filteredChatList?.removeAll()
        if filteredArray != nil {
            self.filteredChatList?.append(contentsOf: filteredArray!)
        }
    }
    
    func updateArrayListOnDidSelectAt(indexPath: IndexPath) {
        if self.isSearchActive {
            self.filteredChatList?[indexPath.row].unreadCount = 0
            if let roomId = self.filteredChatList?[indexPath.row].chatRoomId {
                _ = self.chatList?.filter(({$0.chatRoomId == roomId})).map(({ (chatInfo) -> ChatRoom in
                    chatInfo.unreadCount = 0
                    return chatInfo
                }))
            }
        } else {
            self.chatList?[indexPath.row].unreadCount = 0
        }
    }
    
    // MARK: Notification Selectors
    @objc func chatCleared(notification: Notification) {
        if let userInfo = notification.userInfo,
           let roomId = userInfo["chatRoomId"] as? String {
            self.fetchLastMessage(roomId: roomId)
        }
    }
    
    @objc func exitedFromGroup(notification: Notification) {
        guard let info = notification.userInfo,
              let chatId = info[ChatRoom.CodingKeys.chatRoomId] as? String else {
                  return
              }
        var chatInfo: ChatRoom?
        if self.isSearchActive {
            chatInfo = self.filteredChatList?.first(where: { $0.chatRoomId == chatId })
        } else {
            chatInfo = self.chatList?.first(where: { $0.chatRoomId == chatId })
        }
        if chatInfo?.chatType == .groupChat {
            chatInfo?.groupChatStatus = .notPartOfGroup
        }
    }
    
    @objc func joinedGroup(notification: Notification) {
        guard let info = notification.userInfo,
              let chatId = info[ChatRoom.CodingKeys.chatRoomId] as? String else {
                  return
              }
        var chatInfo: ChatRoom?
        if self.isSearchActive {
            chatInfo = self.filteredChatList?.first(where: { $0.chatRoomId == chatId })
        } else {
            chatInfo = self.chatList?.first(where: { $0.chatRoomId == chatId })
        }
        if chatInfo?.chatType == .groupChat {
            chatInfo?.groupChatStatus = .active
        }
    }
    
    @objc func groupDeleted(notification: Notification) {
        guard let info = notification.userInfo,
              let chatId = info[ChatRoom.CodingKeys.chatRoomId] as? String else {
                  return
              }
        if self.isSearchActive {
            guard let index = filteredChatList?.firstIndex(where: {$0.chatRoomId == chatId}) else {return}
            self.filteredChatList?[index].isDeleted = CustomBool.yes
            if let indexInMainList = self.chatList?.firstIndex(where: ({$0.chatRoomId == chatId})) {
                self.chatList?[indexInMainList].isDeleted = CustomBool.yes
            }
            
        } else {
            guard let index = self.chatList?.firstIndex(where: {$0.chatRoomId == chatId}) else {return}
            self.chatList?[index].isDeleted = CustomBool.yes
        }
        self.reloadTable()
    }
}

// MARK: UISearchBarDelegate
extension ChatListingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.chatList != nil else {return}
        if let currentText = searchBar.text {
            if !currentText.isEmpty {
                self.isSearchActive = true
                
                if self.filteredChatList == nil {
                    self.filteredChatList = []
                }
                self.searchText = searchText
                self.filterSearchListArray()
                self.reloadTable()
                if let filterList = self.filteredChatList,
                   filterList.isEmpty {
                    //if filter results are empty, show background view of table
                    self.tableView.showEmptyScreen("No Results")
                    self.noChatsMessageLabel.isHidden = true
                } else {
                    self.tableView.restore()
                }
            } else {
                self.resetSearchList()
                self.reloadTable()
            }
        }
    }
    
    func resetSearchList() {
        self.isSearchActive = false
        self.searchText = ""
        self.filteredChatList?.removeAll()
        self.tableView.restore()
    }
}

// MARK: SkeletonTableViewDataSource
extension ChatListingViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return ChatListTableViewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

// MARK: UITableViewDataSource
extension ChatListingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatListArray()?.count ?? 0//self.chatList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reuseIdentifier, for: indexPath) as! ChatListTableViewCell
        if let chatInfo = self.chatListArray()?[indexPath.row] {
            cell.setData(chatInfo: chatInfo, atIndexPath: indexPath)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension ChatListingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chatListCount = self.chatListArray()?.count ?? 0
        if indexPath.row < chatListCount {
            if self.chatListArray()?[indexPath.row].isDeleted == CustomBool.yes {
                return 0.0001
            }
        }
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
        if isScreenFromGlobalSearch {
            return false
        }
        if self.chatListArray()?[indexPath.row].chatType == .groupChat {
            if self.chatListArray()?[indexPath.row].groupChatStatus != .active {
                return true
            }
        } else {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let chatInfo = self.chatListArray()?[indexPath.row] else {
            return nil
        }
        let deleteChat = UITableViewRowAction(style: .normal, title: "Delete Chat") { _, _ in
            if chatInfo.chatType == .groupChat {
                if chatInfo.groupChatStatus != .active {
                    self.deleteChat(chatInfo: chatInfo, atIndex: indexPath.row)
                }
            } else {
                //single chat delete
                self.deleteChat(chatInfo: chatInfo, atIndex: indexPath.row)
            }
        }
        deleteChat.backgroundColor = UIColor.appRed
        if chatInfo.chatType == .groupChat {
            if chatInfo.groupChatStatus != .active {
                deleteChat.title = "Delete Group"
            }
        }
        return [deleteChat]
    }
}

// MARK: GlobalSearchControllerDelegate
extension ChatListingViewController: GlobalSearchControllerDelegate {
    func parentControllerSearchTextDidChange(searchText: String) {
        if !searchText.isEmpty {
            self.searchText = searchText
            self.getChatListing(searchText: searchText)
        } else {
            //if empty
            self.searchText = ""
            self.removeListeners()
            self.chatList?.removeAll()
            self.tableView.showEmptyScreen(AppMessages.GlobalSearch.noTems)
            self.tableView.reloadData()
            if let parent = self.parent as? SearchViewController {
                //                parent.didFinishLoadingTemsOnOtherView()
            }
        }
    }
}
extension UIView {
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 1
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 2)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
}
