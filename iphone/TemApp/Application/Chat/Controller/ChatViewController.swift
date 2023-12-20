//
//  ChatViewController.swift
//  TemApp
//
//  Created by shilpa on 23/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import AVKit
import Lightbox
import SideMenu
import FirebaseFirestore
import SafariServices
import SSNeumorphicView
import UniformTypeIdentifiers
import MobileCoreServices

class ChatViewController: DIBaseController, URLTappableProtocol {
    
    // MARK: Variables.
    private var muteButton: UIButton?
    var screenType: Constant.ScreenFrom = .chat
    private var selectedFriends:[Friends]?
    private var actionSheet = CustomBottomSheet()
    var chatRoomId: String?
    var messages = [Message]()
    private var chatInfo: ChatRoom?
    let chatManager = ChatManager()
    //this will be the member name in case of single chat and group name in case of group chat
    var chatName: String?
    var chatImage: UIImage?
    var chatImageURL: URL?
    private var selectedIndexPath: IndexPath?
    var groupNameListener: ListenerRegistration?
    let sideMenu = SideMenuManager()
    
    //Api layers
    let chatNetworkLayer =  DIWebLayerChatApi()
    let friendNetworkLayer = NetworkConnectionManager()
    
    /// this will hold the members in a chat room except the current user
    private var chatMembers = [Friends]()
    let placeholderText = "Message.."
    private var rightSideMenuController: GroupInfoSideMenuViewController?
    
    var isAddedAsShortcutOnHomeScreen: CustomBool = .no
    private var viewHasLoadedInitially = true
    private var tagUsersListController: TagUsersListViewController?
    private var currentTaggedInMessage: [UserTag]?
    private var currentTaggedIds: [String]?
    
    //for goal/challenge chat
    var activityMembers: [ActivityMember]?
    var chatWindowType: ChatWindowType = .normalChat
    var isActivityJoined: Bool?
    var isGroupActivityChatMuted: CustomBool?
    
    /// dictionary which will store the userids as key and respective user information as value
    private var userInfo: [String: Any] = [:]
    var canAlwaysChat: Bool = false // used to chat with affiliate and admin if he is not added as a temate.
    var chatNotInitiatedWithAffiliate: Bool = false
    var isOurTemSelected: Bool = false
    var joinHandler: BoolCompletion?
    weak var delegate: GroupActivityChatDelegate?
    var activeTemsJoinHandler: OnlySuccess?
    // MARK: IBOutlets
    @IBOutlet weak var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.appThemeDarkGrayColor.withAlphaComponent(1).cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    
    @IBOutlet weak var messageShadowView: SSNeumorphicView! {
        didSet {
            messageShadowView.viewDepthType = .innerShadow
            messageShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            messageShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            messageShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            messageShadowView.viewNeumorphicShadowOpacity = 0.8
            messageShadowView.viewNeumorphicCornerRadius = messageShadowView.frame.height / 2
        }
    }
    
    @IBOutlet weak var joinGradientView:GradientDashedLineCircularView!{
        didSet{
            joinGradientView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1),UIColor.cyan.withAlphaComponent(0.5), UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.25, y: 0.5)))
            joinGradientView.instanceWidth = 2.0
            joinGradientView.instanceHeight = 6.0
            joinGradientView.extraInstanceCount = 1
            joinGradientView.lineColor = UIColor.gray
            joinGradientView.updateGradientLocation(newLocations: [NSNumber(value: 0.35),NSNumber(value: 0.60),NSNumber(value: 0.89),NSNumber(value: 0.99)], addAnimation: false)
        }
    }
    @IBOutlet weak var joinShadowView:SSNeumorphicView!{
        didSet{
            joinShadowView.viewDepthType = .outerShadow
            joinShadowView.viewNeumorphicMainColor =  UIColor.appThemeDarkGrayColor.cgColor
            joinShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
            joinShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            joinShadowView.viewNeumorphicCornerRadius = joinShadowView.frame.height / 2
            joinShadowView.viewNeumorphicShadowRadius = 5
            joinShadowView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
        }
    }
    @IBOutlet weak var joinView:UIView!
    
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var messageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: IQTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var disableChatView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var messageViewContainerView: UIView!
    @IBOutlet weak var tagListContainerView: UIView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var grouupChatMenuButton: UIButton!
    @IBOutlet weak var singleChatButton: UIButton!
    // MARK: IBActions
    
    @IBAction func groupChatMenu(_ sender: UIButton){
        if let rightSideMenu = sideMenu.rightMenuNavigationController {
            rightSideMenuController?.groupInfo = self.chatInfo
            self.present(rightSideMenu, animated: true, completion: nil)
        }
    }
    
    @IBAction func joinButtonTapped(_ sender:UIButton){
        self.joinGroupApiCall()
    }
    
    @IBAction func menuTapped(_ sender: UIButton) {
        openUserActionList()
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func attachmentButtonTapped(_ sender: UIButton) {
        if let chatInfo = self.chatInfo,
           let type = chatInfo.chatType {
            switch type {
            case .singleChat:
                    self.presentActionSheet()
            case .groupChat:
                if self.chatWindowType == .chatInChallenge || self.chatWindowType == .chatInGoal {
                    self.showYPPhotoGallery(showCrop: false)
                } else {
                    self.presentActionSheet()
                }
            }
        }
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        if self.isConnectedToNetwork(),
           !messageTextView.text.isEmpty,
           let chatId = self.chatRoomId {
            var message = Message()
            message.text = messageTextView.text.trim
            message.type = .text
            message.isRead = CustomBool.no
            message.senderId = UserManager.getCurrentUser()?.id
            message.chatRoomId = chatId
            message.id = UUID().uuidString //unique id
            message.time = Date().timeIntervalSince1970
            message.taggedUsers = self.currentTaggedInMessage
            message.mediaUploadingStatus = .isUploaded //setting it to 0 by default for text messages
            self.currentTaggedInMessage = nil //reset the list
            
            if chatInfo?.chatType == .groupChat,
               chatWindowType == .normalChat {
                message.userIds = self.chatInfo?.memberIds
            }
            message.chatType = self.chatInfo?.chatType
            
            self.initiateChatToServer()
            self.updateChatActiveStatus()
            self.messageTextView.text = ""
            self.setSendButtonConfiguration(enableStatus: false)
            chatManager.addMessage(toChatRoomId: chatId, message: message) {[weak self] (finished,_) in
                self?.tagUsersListController?.resetTagList()
                if finished {
                    self?.sendMessagePushNotification(message: message.text ?? "", taggedIds: self?.currentTaggedIds)
                }
            }
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.placeholder = placeholderText
        messageTextView.textColor = UIColor.white
        // Do any additional setup after loading the view.
        self.initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setIQKeyboardManager(toEnable: false)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.addKeyboardNotificationObservers()
        //configureNavigation()
        self.navigationController?.navigationBar.isHidden = true
        self.initializeChat()
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: true, controller: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        if let roomId = self.chatRoomId {
            //update off screen chat status of the user
            chatManager.updateUserOnScreenStatusInChatRoom(roomId: roomId, status: false)
            self.updateUserOnlineStatus(status: .no)
        }
        self.saveUserLastSeen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardNotificationObservers()
        self.setIQKeyboardManager(toEnable: true)
        self.removeChatListeners()
    }
    
    private func removeChatListeners() {
        chatManager.userInfoListener?.remove()
        chatManager.messageListener?.remove()
        chatManager.userChatStatusListener?.remove()
        self.groupNameListener?.remove()
    }
    
    // MARK: Initializer
    private func initUI() {
        grouupChatMenuButton.addDoubleShadowToButton(cornerRadius: grouupChatMenuButton.frame.height / 2, shadowRadius: grouupChatMenuButton.frame.height / 2, lightShadowColor:  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1), darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3), shadowBackgroundColor: UIColor.appThemeDarkGrayColor)
        chatNameLabel.text = self.chatName
        chatImageView.image = self.chatImage
        self.messageTextView.addDoneButtonOnKeyboard()
        self.disableMessageInterface(errorMessage: "")
        self.setSendButtonConfiguration(enableStatus: false)
        //register table cells xibs
        self.tableView.registerNibs(nibNames: [SenderTextMessageTableViewCell.reuseIdentifier, MyTextMessageTableViewCell.reuseIdentifier, SenderMediaMessageTableViewCell.reuseIdentifier, MyMediaMessageTableViewCell.reuseIdentifier])
        if let imageLink = chatImageURL {
            chatImageView.kf.setImage(with: imageLink, placeholder:#imageLiteral(resourceName: "user-dummy"))
        } else {
            if chatInfo?.chatType == .singleChat {
                chatImageView.image = #imageLiteral(resourceName: "user-dummy")
            } else {
                chatImageView.image = #imageLiteral(resourceName: "grp-image")
            }
        }
        self.setTagListController()
    }
    
    private func setTagListController() {
        self.tagUsersListController = UIStoryboard(storyboard: .post).initVC()
        if self.chatWindowType == .normalChat {
            tagUsersListController?.listType = .groupChatTagging
        } else if chatWindowType == .chatInGoal {
            tagUsersListController?.listType = .goalChatTagging
        } else if chatWindowType == .chatInChallenge {
            tagUsersListController?.listType = .challengeChatTagging
        }
        tagUsersListController?.delegate = self
        self.addChild(tagUsersListController!)
        tagUsersListController?.view.frame = self.tagListContainerView.bounds
        self.tagListContainerView.addSubview(tagUsersListController?.view ?? UIView())
        tagUsersListController?.didMove(toParent: self)
        tagUsersListController?.screenFrom = .chat
        self.tagListContainerView.isHidden = true
    }
    
    func initializeChat() {
        if let roomId = self.chatRoomId {
            showLoader()
            //update on screen chat status of the user
            chatManager.updateUserOnScreenStatusInChatRoom(roomId: roomId, status: true)
            self.updateUserOnlineStatus(status: .yes)
        }
        if self.screenType == .groupActivityChat {
            //for g/c chat
            self.getChatRoomInfoForActivityChat(completion: nil)
        } else {
            self.getChatInfo()
        }
    }
    
    // MARK: Refresh chat on notification click.
    func refreshChat() {
        removeChatListeners()
        self.messages.removeAll()
        self.initializeChat()
    }
    
    func listenToThisChatRoom() {
        guard let roomId = self.chatRoomId else {
            return
        }
        self.chatManager.listenToChatRoom(withId: roomId, fromTime: nil, isPublicRoom: true, fetchLatestFirst: false, completion: { (messages) in
            self.showData(messages: messages)
        }) { (_) in
        }
    }
    
    ///listen to current chat room
    func listenToCurrentChatRoom() {
        let isPublicRoom = self.chatWindowType == .normalChat ? false : true
        if let roomId = self.chatRoomId,
           let chatType = self.chatInfo?.chatType {
            //fetching the initial time from which the chat is to be loaded
            chatManager.getRoomInformationOfUser(roomId: roomId) {[weak self] (roomInfo) in
                self?.chatInfo?.clearChatTime = roomInfo?.clearChatTime
                self?.chatManager.listenToChatRoom(withId: roomId, fromTime: self?.chatInfo?.clearChatTime, isPublicRoom: isPublicRoom, completion: {[weak self] (messages) in
                    DispatchQueue.main.async {
                        self?.hideLoader()
                        self?.showData(messages: messages)
                        //if the user can not chat in this chat room -> then remove the message listener else skip this step
                        if chatType == .singleChat {
                            if let chatStatus = self?.chatInfo?.chatStatus,
                               chatStatus != .active {
                                self?.removeNewMessageListener()
                            }
                        } else {
                            if let chatStatus = self?.chatInfo?.groupChatStatus,
                               chatStatus != .active {
                                self?.removeNewMessageListener()
                            }
                        }
                    }
                }) { (_) in
                    
                }
            }
            self.updateUserChatStatus(roomId: roomId, chatType: chatType)
            self.observeUserChatStatus()
        }
    }
    
    /// save last seen time of user on this screen
    func saveUserLastSeen() {
        guard let roomId = self.chatRoomId else {
            return
        }
        let currentTime = Date().timeIntervalSince1970
        chatManager.saveLastSeenOfUser(lastSeen: currentTime, forChatRoom: roomId)
    }
    
    // MARK: Configure Navigation Bar
    private func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.style = .gray
        let rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        rightBarButtonItem.tintColor = UIColor.textBlackColor
        activityIndicator.startAnimating()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setDefaultNavigationBar()
    }
    
    /// change the navigation item title
    ///
    /// - Parameter title: title text
    private func setNavigationWith(title: String) {
        self.chatNameLabel.text = title.firstUppercased
      //  self.navigationItem.title = title
    }
    
    ///set the right bar button item for single chat
    private func configureRightBarItemForSingleChat() {
        let rightBarButtonItem = UIBarButtonItem(customView: getDotsButton())
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureRightBarMuteButtonItemForActivityChat() {
        if let isJoined = self.isActivityJoined,
           isJoined {
            var icon = "speaker-filled-audio-tool"
            if let isMuted = self.chatInfo?.isMuted {
                icon = isMuted == .yes  ? "volume-off-indicator" : "speaker-filled-audio-tool"
            }
            let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: icon), style: .plain, target: self, action: #selector(self.muteIconTapped(sender:)))
            rightBarButtonItem.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    ///set the right bar button item for group chat
    private func configureRightBarItemForGroupChat() {
        let groupIcon = UIButton(type: .custom)
        groupIcon.setImage(#imageLiteral(resourceName: "grp-imageSmall"), for: .normal)
        groupIcon.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        groupIcon.addTarget(self, action: #selector(groupIconTapped(sender:)), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: groupIcon)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        if viewHasLoadedInitially {
            //this is done in order to call this api only once
            self.checkIfAddedOnHomeScreen()
        }
    }
    
    /// action of right bar button in case of group chat
    @objc func groupIconTapped(sender: UIBarButtonItem) {
        //to tem side menu screen
        if let rightSideMenu = sideMenu.rightMenuNavigationController {
            rightSideMenuController?.groupInfo = self.chatInfo
            self.present(rightSideMenu, animated: true, completion: nil)
        }
    }
    
    func getDotsButton() -> UIButton {
        let buttonBack = UIButton(type: .custom)
        buttonBack.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        buttonBack.tintColor = UIColor.textBlackColor
        buttonBack.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        buttonBack.addTarget(self, action: #selector(self.openUserActionList), for: .touchUpInside)
        return buttonBack
    }
    
    /// Used to pop to previous controller.
    @objc func openUserActionList(){
        self.messageTextView.resignFirstResponder()
        if self.chatWindowType == .chatInChallenge || chatWindowType == .chatInGoal {
            actionSheet = Utility.presentActionSheet(titleArray: [.clearChat, .muteGroup, .cancel], titleColorArray: [.gray,.gray, .gray], tag: 0,section: 0)
            actionSheet.delegate = self
            return
        }
        guard let chatStatus = self.chatInfo?.chatStatus else {
            return
        }
        switch chatStatus {
        case .unfriend:
            //only show block and clear chat options
            actionSheet = Utility.presentActionSheet(titleArray: [.block,.clearChat, .cancel], titleColorArray: [.gray,.gray, .gray], tag: 0,section: 0)
        case .blocked:
            actionSheet = Utility.presentActionSheet(titleArray: [.clearChat, .cancel], titleColorArray: [.gray,.gray], tag: 0,section: 0)
        case .active:
            actionSheet = Utility.presentActionSheet(titleArray: [.unfriend,.block,.clearChat, .cancel], titleColorArray: [.gray,.gray,.gray, .gray], tag: 0,section: 0)
        default:
            actionSheet = Utility.presentActionSheet(titleArray: [.clearChat, .cancel], titleColorArray: [.gray,.gray], tag: 0,section: 0)
        }
        actionSheet.delegate = self
    }
    
    func presentActionSheet() {
        self.messageTextView.resignFirstResponder()
        if let chatInfo = self.chatInfo,
           let type = chatInfo.chatType {
            switch type {
                case .singleChat:
                    actionSheet = Utility.presentActionSheet(titleArray: [.addMedia, .pdf, .cancel], titleColorArray: [.gray, .gray, .gray], tag: 0)
                case .groupChat:
                    if self.chatWindowType == .chatInChallenge || self.chatWindowType == .chatInGoal {
                        break
                    } else {
                        actionSheet = Utility.presentActionSheet(titleArray: [.addTemates, .addMedia, .pdf, .createEvent, .challenge, .goal, .cancel], titleColorArray: [.gray, .gray, .gray, .gray, .gray, .gray, .gray], tag: 0)
                    }
            }
        }
        actionSheet.delegate = self
    }
    
    func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }

    @objc private func muteIconTapped(sender: UIBarButtonItem) {
        self.muteChatNotification()
    }
    
    // MARK: Side menu configuration
    ///configure the right side menu for this screen
    func initRightSideMenu() {
        guard rightSideMenuController == nil else {
            return
        }
        let sideMenuStoryboard = UIStoryboard(name: UIStoryboard.Storyboard.sidemenu.filename, bundle: nil)
        if let viewcontroller : SideMenuNavigationController = sideMenuStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController {
            let sideMenuVC: GroupInfoSideMenuViewController = UIStoryboard(storyboard: .chat).initVC()
            sideMenu.rightMenuNavigationController = viewcontroller
            viewcontroller.viewControllers = [sideMenuVC]
            self.rightSideMenuController = sideMenuVC
            sideMenuVC.delegate = self
            sideMenuVC.groupInfo = self.chatInfo
            viewcontroller.settings.presentationStyle = .menuSlideIn
            viewcontroller.settings.statusBarEndAlpha = 0
            viewcontroller.settings.presentationStyle.onTopShadowRadius = 5.0
            viewcontroller.settings.presentationStyle.onTopShadowOpacity = 0.5
            viewcontroller.settings.presentationStyle.onTopShadowColor = .gray
            viewcontroller.settings.menuWidth = self.view.frame.width - 60
        }
    }
    
    // MARK: keyboard observers
    override func keyboardDisplayedWithHeight(value: CGRect) {
        var verticalSafeAreaInset : CGFloat = 0.0
        if #available(iOS 11.0, *) {
            verticalSafeAreaInset = self.view.safeAreaInsets.bottom
        } else {
            verticalSafeAreaInset = 0.0
        }
        self.messageViewBottomConstraint.constant = (value.height-verticalSafeAreaInset)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func keyboardHide(height: CGFloat) {
        self.messageViewBottomConstraint.constant = -1
    }
    
    // MARK: Api Calls
    func getChatInfo(completion: ((_ success: Bool) -> Void)? = nil) {
        guard let roomId = self.chatRoomId else {
            hideLoader(); return
        }
        self.chatNetworkLayer.getChatInfo(forChatRoom: roomId, completion: {[weak self] (chatInfo) in
            DispatchQueue.main.async {
                if let wkSelf = self {
                    wkSelf.hideLoader()
                    wkSelf.tableView.restore()
                    wkSelf.chatInfo = chatInfo
                    wkSelf.tagUsersListController?.id = chatInfo.groupId
                    self?.listenToCurrentChatRoom()
                    if wkSelf.chatImageURL == nil {
                        if chatInfo.chatType == .singleChat {
                            wkSelf.chatImageView.image = #imageLiteral(resourceName: "user-dummy")
                        } else {
                            wkSelf.chatImageView.image = #imageLiteral(resourceName: "grp-image")
                        }
                    }

                    wkSelf.updateMessageDisplayOnChatStatus()
                    if let members = chatInfo.members {
                        wkSelf.chatMembers.append(contentsOf: members)
                        let memberIds = wkSelf.chatInfo?.members?.filter({$0.status == 1}).map({$0.user_id ?? ""})
                        //store the memberids
                        self?.chatInfo?.memberIds = memberIds

                        //for single chat, display on navigation the name of the other member with whom the chat is initiated and for group chat, display the group title
                        if let chatType = chatInfo.chatType {
                            if chatType == .singleChat {
                                self?.grouupChatMenuButton.isHidden = true
                                self?.singleChatButton.isHidden = false
                                if let userName = chatInfo.members?.first?.fullName {
                                }
                            } else {
                                //for group
                                self?.grouupChatMenuButton.isHidden = false
                                self?.singleChatButton.isHidden = true
                                self?.getChatRoomName()
                                self?.initRightSideMenu()
                            }
                        }
                        wkSelf.getEachChatMemberInfo()
                    }
                    if let completion = completion {
                        completion(true)
                    }
                }
            }
        }) {[weak self] (error) in
                DispatchQueue.main.async {
                    if let wkSelf = self {
                        wkSelf.hideLoader()
                        wkSelf.navigationItem.rightBarButtonItem = nil
                        if wkSelf.messages.isEmpty {
                            wkSelf.tableView.showEmptyScreen(error.message ?? "")
                        }
                    }
            }
        }
        //If room id not found than loader won't hide so added 3 sec delay and hide loader
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.hideLoader()
        })
    }
    
    /// This will initialize the chat room for a goal or challenge.
    private func getChatRoomInfoForActivityChat(completion: ((_ success: Bool) -> Void)? = nil) {
        guard let roomId = self.chatRoomId else {
            return
        }
        self.tableView.restore()
        self.chatInfo = ChatRoom()
        self.chatInfo?.chatRoomId = roomId
        self.chatInfo?.isMuted = self.isGroupActivityChatMuted ?? .no
        if let isActivityJoined = self.isActivityJoined {
            if isActivityJoined {
                self.chatInfo?.groupChatStatus = .active
            } else {
                self.chatInfo?.groupChatStatus = .notPartOfGroup
            }
        } else {
            self.chatInfo?.groupChatStatus = .notPartOfGroup
        }
        
        self.chatInfo?.chatType = .groupChat
        self.chatInfo?.chatWindowType = self.chatWindowType
        self.tagUsersListController?.id = roomId
        self.listenToCurrentChatRoom()
        self.getChatRoomName()
        self.updateMessageDisplayOnChatStatus()
        //configure navigation bar item
        self.configureRightBarMuteButtonItemForActivityChat()
    }
    
    //Unfriend user
    private func unfriendUser() {
        self.showAlert(withTitle: "", message: AppMessages.NetworkMessages.removeFriend, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
            if self.isConnectedToNetwork(),
               let userId = self.chatInfo?.members?.first?.user_id {
                var params: FriendRequest = FriendRequest()
                params.friendId = userId
                self.showLoader()
                self.friendNetworkLayer.deleteFriend(params: params.getDictionary() ?? [:], success: {[weak self] (_) in
                    self?.hideLoader()
                    self?.chatManager.messageListener?.remove()
                    self?.disableMessageInterface(errorMessage: AppMessages.Chat.unfriendCannotChat)
                }, failure: {[weak self] (error) in
                    self?.hideLoader()
                    self?.showAlert(message: error.message ?? "Error")
                })
            }
        }) {
        }
    }
    
    //BLock user
    private func blockUser() {
        self.showAlert(withTitle: "", message: UserActions.block.message, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
            if self.isConnectedToNetwork(),
               let userId = self.chatInfo?.members?.first?.user_id {
                var params: BlockUser = BlockUser()
                params.friendId = userId
                self.showLoader()
                self.friendNetworkLayer.blockUser(params: params.getDictionary() ?? [:], success: {[weak self] (_) in
                    self?.hideLoader()
                    self?.chatManager.messageListener?.remove()
                    self?.disableMessageInterface(errorMessage: AppMessages.Chat.blockedCannotChat)
                }, failure: {[weak self] (error) in
                    self?.hideLoader()
                    self?.showAlert(message: error.message ?? "Error")
                })
            }
        }) {
        }
    }
    
    private func addGroupParticipants(memberIds: [String]) {
        guard let groupInfo = self.chatInfo?.copy() as? ChatRoom else {
            return
        }
        if groupInfo.memberIds == nil {
            groupInfo.memberIds = []
        }
        groupInfo.memberIds?.append(contentsOf: memberIds)
        let params = groupInfo.editParticipantsJson().json()
        self.chatNetworkLayer.editGroup(params: params, completion: {[weak self] (finished) in
            self?.chatInfo?.memberIds?.append(contentsOf: memberIds)
            self?.updateNewMembersChatStatusInRoom()
            self?.updateMembersInChatRoom()
            self?.getChatInfo(completion: {[weak self] (_) in
                self?.hideLoader()
            })
        }) {[weak self] (error) in
            self?.hideLoader()
            if let msg = error.message {
                self?.showAlert(message: msg)
            }
        }
    }
    
    private func checkIfAddedOnHomeScreen() {
        guard let id = self.chatRoomId else {
            return
        }
        DIWebLayerUserAPI().getHomeScreenStatus(type: .tem, id: id, completion: { (status) in
            guard let statusValue = CustomBool(rawValue: status) else {
                return
            }
            self.viewHasLoadedInitially = false
            self.isAddedAsShortcutOnHomeScreen = statusValue
            self.setNavigationItems(statusValue: statusValue)
        }) { (_) in
        }
    }
    
    //Clear User Chat
    func clearChat() {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        //save the clear chat time for this user in his chat room id
        if let roomId = self.chatRoomId {
            let time = Date().timeIntervalSince1970
            self.chatManager.saveClearChatTimeOfUser(time: time, forChatRoom: roomId, completion: {[weak self] (_) in
                self?.hideLoader()
                NotificationCenter.default.post(name: Notification.Name.chatCleared, object: self, userInfo: ["chatRoomId": roomId])
                //fetch the messages from the firestore again
                self?.chatInfo?.clearChatTime = time
                //remove listener first and then get the new data
                self?.removeNewMessageListener()
                self?.messages.removeAll()
                self?.listenToCurrentChatRoom()
            }) {[weak self] (error) in
                self?.showAlert(message: error)
            }
        }
    }
    
    func initiateChatToServer() {
        guard chatInfo?.chatType == .singleChat else {
            return
        }
        if self.chatNotInitiatedWithAffiliate {
            self.chatInfo?.chatInitiated = CustomBool.no
            self.chatNotInitiatedWithAffiliate = false
        }
        if self.chatInfo?.chatInitiated == CustomBool.no,
           let roomId = self.chatRoomId {
            //update to server
            self.chatNetworkLayer.initiateChat(roomId: roomId) {[weak self] (_) in
                self?.chatManager.chatInitiatedForChatRoom(roomId: roomId, chatInfo: self?.chatInfo)
                self?.chatInfo?.chatInitiated = CustomBool.yes
            }
        }
    }
    
    ///if the chat room was deleted for this user, update
    func updateChatActiveStatus() {
        if let chatType = self.chatInfo?.chatType {
            switch chatType {
            case .singleChat:
                guard let roomId = chatInfo?.chatRoomId else {
                    return
                }
                //check the status of me for chat room
                if chatInfo?.isDeleted == CustomBool.yes {
                    self.chatManager.updateDeleteChatStatus(roomId: roomId, userId: UserManager.getCurrentUser()?.id, status: .no)
                }
                //update for the other member in chat also
                if let otherMember = self.chatInfo?.members?.filter(({$0.user_id != UserManager.getCurrentUser()?.id})),
                   otherMember.first?.isDeleted == CustomBool.yes,
                   let memberId = otherMember.first?.user_id {
                    self.chatManager.updateDeleteChatStatus(roomId: roomId, userId: memberId, status: .no)
                }
            default:
                break
            }
        }
    }
    
    //message is the text here. for video: it would be Video and for image it would be Photo
    func sendMessagePushNotification(message: String, taggedIds: [String]? = nil) {
        guard let roomId = chatRoomId else {
            return
        }
        //reset current tagged ids
        self.currentTaggedIds = nil
        self.chatNetworkLayer.chatNotification(forChatRoom: roomId, chatWindowType: self.chatWindowType, message: message, taggedIds: taggedIds, completion: { (_) in
        }, failure: { (error) in
            self.showAlert(message:error.message)
        })
    }
    
    /// update user online status in a chat room
    /// - Parameter status: 0 for inactive , 1 for active
    private func updateUserOnlineStatus(status: CustomBool) {
        guard let chatRoomId = self.chatRoomId else {
            return
        }
        self.chatNetworkLayer.setUserOnlineStatus(chatRoom: chatRoomId, chatWindowType: self.chatWindowType, status: status, success: { (_) in
            
        }) { (_) in
            
        }
    }
    
    /// mute group activity chat notifications api call
    private func muteChatNotification() {
        if isConnectedToNetwork() {
            self.showLoader()
            self.chatNetworkLayer.muteActivityChatNotification(roomId: self.chatRoomId ?? "", chatWindowType: self.chatWindowType, muteStatus: self.chatInfo?.isMuted?.toggle() ?? .yes, completion: {[weak self] (_) in
                self?.hideLoader()
                if let muteStatus = self?.chatInfo?.isMuted {
                    self?.chatInfo?.isMuted = muteStatus.toggle()
                    self?.delegate?.updateMuteStatusInGroupActivity(newValue: muteStatus.toggle())
                }
                self?.configureRightBarMuteButtonItemForActivityChat()
            }) {[weak self] (error) in
                self?.hideLoader()
                if let msg = error.message {
                    self?.showAlert(message: msg)
                }
            }
        }
    }
    
    // MARK: Data source
    func showData(messages: [Message]) {
        
        for message in messages {
            if message.id == nil { //for an empty message, skip the process
                continue
            }
            //first check if the message is updated or new
            if let updationTime = message.updatedAt,
               let creationTime = message.time,
               updationTime != creationTime {
                
                //that means the message was updated
                let indexOfMessage = self.messages.firstIndex { (msg) -> Bool in
                    return msg.id == message.id
                }
                if let index = indexOfMessage {
                    //update at index
                    self.messages[index] = message
                } else {
                    if message.type! == .image || message.type! == .video {
                        if let uploadingStatus = message.mediaUploadingStatus {
                            switch uploadingStatus {
                            case .isUploading, .uploadingError:
                                if message.senderId == UserManager.getCurrentUser()?.id {
                                    //this message was sent by me, hence it is to be shown on screen
                                    //append in array
                                    self.messages.append(message)
                                }
                            case .isUploaded:
                                //append in array
                                self.messages.append(message)
                            }
                        }
                    } else {
                        //this means this was a text message
                        //append in array
                        self.messages.append(message)
                    }
                }
            } else {
                let isContained = self.messages.contains { (msg) -> Bool in
                    return msg.id == message.id
                }
                //if it is already contained, do not add it to the list
                if !isContained {
                    if message.type! == .image || message.type! == .video {
                        if let uploadingStatus = message.mediaUploadingStatus {
                            switch uploadingStatus {
                            case .isUploading, .uploadingError:
                                if message.senderId == UserManager.getCurrentUser()?.id {
                                    //this message was sent by me, hence it is to be shown on screen
                                    //append in array
                                    self.messages.append(message)
                                }
                            case .isUploaded:
                                //append in array
                                self.messages.append(message)
                            }
                        }
                    } else {
                        self.messages.append(message)
                    }
                }
            }
            if self.chatWindowType != .normalChat {
                self.getMessageSenderInformation(senderId: message.senderId)
            }
        }
        
        //self.messages.append(contentsOf: messages)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollTableToBottom()
        }
    }
    
    func scrollTableToBottom() {
        if self.messages.count > 0 {
            if self.selectedIndexPath != nil {
                //if there is this selected index, then donot scroll the table, keep it at the position it was before
                self.selectedIndexPath = nil
                return
            }
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    /// this method is responsible for UI display whether the user can type the message or not.
    ///
    /// - Returns: true: if user can chat, false otherwise
    func updateMessageDisplayOnChatStatus() {
        guard let chatType = self.chatInfo?.chatType else {
            return
        }
        switch chatType {
        case .singleChat:
            if let chatStatus = self.chatInfo?.chatStatus {
                switch chatStatus {
                case .active:
                    messageViewContainerView.borderWidth = 1
                    self.disableChatView.isHidden = true
                case .blocked:
                    self.disableMessageInterface(errorMessage: AppMessages.Chat.blockedCannotChat)
                case .blockedByAdmin, .profileDeleted:
                    self.disableMessageInterface(errorMessage: AppMessages.Chat.cannotChatInThisRoom)
                case .unfriend:
                    self.disableMessageInterface(errorMessage: AppMessages.Chat.unfriendCannotChat)
                }
            }
        default:
            if let groupChatStatus = self.chatInfo?.groupChatStatus {
                switch groupChatStatus {
                case .active:
                    messageViewContainerView.borderWidth = 1
                    self.disableChatView.isHidden = true
                default:
                    var message = AppMessages.Chat.cannotMessageInGroup
                    if self.chatWindowType == .chatInChallenge {
                        self.navigationItem.rightBarButtonItem = nil
                        message = AppMessages.Chat.cannotMessageInChallenge
                    } else if self.chatWindowType == .chatInGoal {
                        self.navigationItem.rightBarButtonItem = nil
                        message = AppMessages.Chat.cannotMessageInGoal
                    }
                    self.setJoinButtonState()
                    self.disableMessageInterface(errorMessage: message)
                }
            }
        }
    }
    
    func getChatRoomMemberIds() -> [String] {
        if let memberIds = self.chatInfo?.memberIds {
            return memberIds
        }
        let memberIds = self.chatInfo?.members?.map({$0.user_id ?? ""})
        self.chatInfo?.memberIds = []
        self.chatInfo?.memberIds?.append(contentsOf: memberIds ?? [])
        return chatInfo?.memberIds ?? []
    }
    
    private func removeNewMessageListener() {
        if let listener = self.chatManager.messageListener {
            listener.remove()
            chatManager.messageListener = nil
        }
    }
    
    // MARK: helpers for chat room members
    func getEachChatMemberInfo() {
         _ = self.chatMembers.map { (chatMember) -> Friends in
            if let userId = chatMember.user_id {
                _ = chatManager.getUserInformationFrom(userId: userId, completion: {[weak self] (chatMember) in
                    //update the chat members array
                    if let index  = self?.chatMembers.firstIndex(where: { $0.user_id == chatMember.user_id }) {
                        self?.chatMembers[index] = chatMember
                    }
                    //set navigation title in case of single chat and skip for group
                    if let chatType = self?.chatInfo?.chatType,
                       chatType == .singleChat {
                    }
                    self?.tableView.reloadData()
                }, failure: { (_) in
                })
            }
            return chatMember
        }
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
        _ = chatManager.getUserInformationFrom(userId: userId, completion: {[weak self] (chatMember) in
            if let id = chatMember.user_id {
                self?.userInfo[id] = chatMember
            }
            self?.reloadUserInfoInVisibleTableCells()
        }, failure: { (_) in
        })
    }
    
    /// reload the visible table cell rows
    private func reloadUserInfoInVisibleTableCells() {
        self.tableView.visibleCells.forEach { (cell) in
            if let textCell = cell as? SenderTextMessageTableViewCell {
                if let senderId = textCell.message?.senderId,
                   let userInfo = userInfo[senderId] as? Friends {
                    textCell.setUserInformation(member: userInfo)
                }
            } else if let mediaCell = cell as? SenderMediaMessageTableViewCell {
                if let senderId = mediaCell.message?.senderId,
                   let userInfo = userInfo[senderId] as? Friends {
                    mediaCell.setUserInformation(member: userInfo)
                }
            }
        }
    }
    
    /// get and observer the change in group name
    func getChatRoomName() {
        guard let roomId = self.chatRoomId else {
            return
        }
        self.groupNameListener = chatManager.getChatRoomNameAndIcon(roomId: roomId, completion: { (room) in
            var defaultTitle = ""
            if self.chatWindowType == .chatInChallenge {
                defaultTitle = self.chatName ?? "Challenge"
            } else if self.chatWindowType == .chatInGoal {
                defaultTitle = self.chatName ?? "Goal"
            }
            if self.chatWindowType == .normalChat {
                //update the members
                self.chatInfo?.memberIds = room?.memberIds
                //if the message listener is nil for this chatroom and the user is added in this chat room, add the message listener again
                if self.chatManager.messageListener == nil,
                   room?.memberIds?.contains(UserManager.getCurrentUser()?.id ?? "") == true {
                    self.listenToCurrentChatRoom()
                }
                //update the new name to shortcut
                if self.isAddedAsShortcutOnHomeScreen == .yes,
                   Reachability.isConnectedToNetwork() {
                    var params = self.parametersOfShortcutUpdate()
                    params.status = .yes
                    DIWebLayerUserAPI().updateToHomeScreen(parameters: params.json(), completion: { (_) in
                    }) { (_) in
                    }
                }
            }
        })
    }
    
    ///listen to a user chat status and update the UI accordingly
    func observeUserChatStatus() {
        self.chatManager.userChatStatusListener?.remove()
        guard let roomId = self.chatRoomId else {
            return
        }
        self.chatManager.getUserChatStatus(inRoom: roomId) { (chatStatus, groupChatStatus) in
            if chatStatus != nil {
                if self.canAlwaysChat && (chatStatus != .blocked && chatStatus != .blockedByAdmin ) {
                    self.chatInfo?.chatStatus = .active // always set chat status to active if user is chatting with affiliate or admin, only if user is not blocked
                } else {
                    self.chatInfo?.chatStatus = chatStatus
                }
            }
            if groupChatStatus != nil {
                self.chatInfo?.groupChatStatus = groupChatStatus
            }
            self.updateMessageDisplayOnChatStatus()
        }
    }
    private func sendPdf(data: Data) {
        guard let roomId = chatRoomId else {
            return
        }
        var message = Message()
        message.isRead = CustomBool.no
        message.senderId = UserManager.getCurrentUser()?.id
        message.chatRoomId = roomId
        message.mediaUploadingStatus = .isUploading
        message.id = UUID().uuidString
        message.time = Date().timeIntervalSince1970
        message.updatedAt = message.time
        message.type = .pdf
        if chatInfo?.chatType == .groupChat {
            if self.screenType == .groupActivityChat {
                message.userIds = [UserManager.getCurrentUser()?.id ?? ""]
            } else {
                message.userIds = self.chatInfo?.memberIds
            }
        }
        message.chatType = self.chatInfo?.chatType
        let media = Media()
        media.data =  data
        media.mimeType = Constant.MimeType.pdf
        
        self.initiateChatToServer()
        self.updateChatActiveStatus()
        chatManager.addMessage(toChatRoomId: roomId, message: message) {[weak self] (finished, messageId) in
            guard finished else {
                return
            }
            message.media = Media()
            self?.chatManager.uploadDataToStorage(atPath: roomId + Utility.shared.getFileNameWithDate(), roomId: roomId, messageId: messageId, mimeType: Constant.MimeType.pdf, chatInfo: self?.chatInfo, data: data, completion: { (url, roomId, _, _) in
                message.media?.url = url?.absoluteString
                message.mediaUploadingStatus = .isUploaded
                message.updatedAt = Date().timeIntervalSince1970 //update the time of the message
                if self?.groupNameListener == nil {
                    //user is not on this screen
                    ChatManager().getChatRoomInformation(roomId: roomId) { (room) in
                        if room?.chatType == .groupChat {
                            message.userIds = room?.memberIds
                        }
                        message.updatedAt = Date().timeIntervalSince1970
                        ChatManager().updateMessage(roomId: roomId, message: message)
                        self?.sendMessagePushNotification(message: "Pdf")
                    }
                } else {
                    ChatManager().updateMessage(roomId: roomId, message: message)
                    self?.sendMessagePushNotification(message: "Pdf")
                }
            }, failure: { (_) in
                message.mediaUploadingStatus = .uploadingError
                ChatManager().updateMessage(roomId: roomId, message: message)
            })
        }
    }

    override func handleAfterMediaSelection(withMedia items: [YPMediaItem], isPresentingFromCreatePost: Bool, isFromFoodTrek:Bool = false) {
        guard isConnectedToNetwork() else {
            return
        }
        guard let roomId = chatRoomId else {
            return
        }
        let imagePath = roomId
        for item in items {
            //compose message
            var message = Message()
            message.isRead = CustomBool.no
            message.senderId = UserManager.getCurrentUser()?.id
            message.chatRoomId = roomId
            message.mediaUploadingStatus = .isUploading
            message.id = UUID().uuidString
            message.time = Date().timeIntervalSince1970
            message.updatedAt = message.time
            
            //initially adding the current user id here
            if chatInfo?.chatType == .groupChat {
                if self.screenType == .groupActivityChat {
                    message.userIds = [UserManager.getCurrentUser()?.id ?? ""]
                } else {
                    message.userIds = self.chatInfo?.memberIds
                }
            }
            message.chatType = self.chatInfo?.chatType
            
            self.initiateChatToServer()
            self.updateChatActiveStatus()
            switch item {
            case .photo(let photo):
                message.type = .image
                chatManager.addMessage(toChatRoomId: roomId, message: message) {[weak self] (finished, messageId) in
                    guard finished else {
                        return
                    }
                    message.media = Media()
                    message.media?.imageRatio = photo.image.getImageRatio()
                    self?.chatManager.uploadDataToStorage(atPath: imagePath, roomId: roomId, messageId: messageId, mimeType: Constant.MimeType.image, chatInfo: self?.chatInfo, data: photo.image.jpegData(compressionQuality: 0.5), completion: { (url, roomId, _, _) in
                        message.media?.url = url?.absoluteString
                        message.mediaUploadingStatus = .isUploaded
                        message.updatedAt = Date().timeIntervalSince1970 //update the time of the message
                        if self?.groupNameListener == nil {
                            //user is not on this screen
                            ChatManager().getChatRoomInformation(roomId: roomId) { (room) in
                                if room?.chatType == .groupChat {
                                    message.userIds = room?.memberIds
                                }
                                message.updatedAt = Date().timeIntervalSince1970
                                ChatManager().updateMessage(roomId: roomId, message: message)
                                self?.sendMessagePushNotification(message: "Photo")
                            }
                        } else {
                            ChatManager().updateMessage(roomId: roomId, message: message)
                            self?.sendMessagePushNotification(message: "Photo")
                        }
                    }, failure: { (_) in
                        message.mediaUploadingStatus = .uploadingError
                        ChatManager().updateMessage(roomId: roomId, message: message)
                    })
                }
            case .video(let video):
                message.type = .video
                chatManager.addMessage(toChatRoomId: roomId, message: message) {[weak self] (finished, _) in
                    guard finished else {
                        return
                    }
                    message.media = Media()
                    message.media?.imageRatio = video.thumbnail.getImageRatio()
                    self?.uploadVideoThumbnail(video: video, message: message)
                }
            }
        }
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    ///upload the video thumbnail and then upload the video to firebase storage
    func uploadVideoThumbnail(video: YPMediaVideo, message: Message) {
        var newMessage = message
        guard let roomId = self.chatRoomId else {
            return
        }
        //upload the video thumbnail
        self.chatManager.uploadDataToStorage(atPath: roomId, roomId: roomId, messageId: message.id, mimeType: Constant.MimeType.image, chatInfo: chatInfo, data: video.thumbnail.jpegData(compressionQuality: 0.5), completion: {[weak self] (url, roomId, messageId, chatInfo) in
            newMessage.media?.previewImageUrl = url?.absoluteString
            newMessage.mediaUploadingStatus = .isUploading
            //upload the video data
            do {
                let data = try Data(contentsOf: video.url)
                self?.chatManager.uploadDataToStorage(atPath: roomId, roomId: roomId, messageId: messageId, mimeType: Constant.MimeType.video, chatInfo: chatInfo, data: data, completion: {[weak self] (url, roomId, _, _) in
                    newMessage.media?.url = url?.absoluteString
                    newMessage.mediaUploadingStatus = .isUploaded
                    newMessage.updatedAt = Date().timeIntervalSince1970 //update the time of the message
                    if self?.groupNameListener == nil {
                        //user is not on this screen
                        ChatManager().getChatRoomInformation(roomId: roomId) { (room) in
                            if room?.chatType == .groupChat {
                                newMessage.userIds = room?.memberIds
                            }
                            newMessage.updatedAt = Date().timeIntervalSince1970
                            ChatManager().updateMessage(roomId: roomId, message: newMessage)
                            self?.sendMessagePushNotification(message: "Video")
                        }
                    } else {
                        ChatManager().updateMessage(roomId: roomId, message: newMessage)
                        self?.sendMessagePushNotification(message: "Video")
                    }
                }, failure: { (_) in
                    newMessage.mediaUploadingStatus = .uploadingError
                    ChatManager().updateMessage(roomId: roomId, message: newMessage)
                })
            } catch(_) {
                
            }
        }, failure: { (_) in
            newMessage.mediaUploadingStatus = .uploadingError
            ChatManager().updateMessage(roomId: roomId, message: newMessage)
        })
    }
    
    private func disableMessageInterface(errorMessage: String) {
        if errorMessage.isEmpty {
            messageViewContainerView.borderWidth = 0
        } else {
            messageViewContainerView.borderWidth = 1
        }
        self.disableChatView.isHidden = false
        self.errorLabel.text = errorMessage
    }
    
    private func setJoinButtonState(){
        if let groupVisibility = self.chatInfo?.visibility, let joinedStatus = self.chatInfo?.groupChatStatus{
            if groupVisibility == .open && (joinedStatus == .observer ){
                self.joinView.isHidden = false
            }else{
                self.joinView.isHidden = true
            }
        }else{
            self.joinView.isHidden = true
        }
    }
    
    private func setSendButtonConfiguration(enableStatus status: Bool) {
        var titleColor: UIColor?
        if status == false {
            //disable
            titleColor = UIColor(red: 148/255, green: 199/255, blue: 240/255, alpha: 1.0)
        } else {
            //for enable
            titleColor = UIColor.appThemeColor
        }
        self.sendButton.setTitleColor(titleColor, for: .normal)
        self.sendButton.isUserInteractionEnabled = status
    }
    
    ///updates the chat status (group chatstatus in case of group chat) to the firestore
    private func updateUserChatStatus(roomId: String, chatType: ChatType) {
        if let currentUserId = UserManager.getCurrentUser()?.id {
            if chatType == .singleChat {
                //for single chat
                if let newChatStatus = chatInfo?.chatStatus {
                    self.chatManager.updateUserChatStatusInChatRoom(roomId: roomId, userId: currentUserId, status: newChatStatus)
                }
            } else { //group chat
                if let newChatStatus = chatInfo?.groupChatStatus {
                    self.chatManager.updateUserGroupChatStatusInChatRoom(roomId: roomId, userId: currentUserId, status: newChatStatus)
                }
            }
        }
    }
    
    ///update the status of each member in chat room
    private func updateNewMembersChatStatusInRoom() {
        if let selected = self.selectedFriends,
           let roomId = self.chatInfo?.chatRoomId {
            _ = selected.map { (member) -> Friends in
                ChatManager().updateUserGroupChatStatusInChatRoom(roomId: roomId, userId: member.id ?? "", status: .active)
                return member
            }
        }
    }
    
    private func updateChatStatusInRoom(_ status: GroupChatStatus) {
        guard let roomId = self.chatInfo?.chatRoomId,
              let userId = UserManager.getCurrentUser()?.id else {
                  return
              }
        ChatManager().updateUserGroupChatStatusInChatRoom(roomId: roomId, userId: userId, status: status)
    }
    
    private func updateMembersInChatRoom() {
        if let memberIds = self.chatInfo?.memberIds,
           let roomId = chatInfo?.chatRoomId {
            ChatManager().addMembersToChatRoom(roomId: roomId, memberIds: memberIds)
        }
    }
    
    // MARK: Screen redirections
    private func pushToCreateEventScreen() {
        let createEventScreen: CreateEventViewController = UIStoryboard(storyboard: .createevent).initVC()
        createEventScreen.selectedGroup = self.chatInfo
        createEventScreen.screenFrom = .createGroupEvent
        self.navigationController?.pushViewController(createEventScreen, animated: true)
    }
    
    private func pushToCreateChallengeScreen() {
        let createChallengeVC: CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
        createChallengeVC.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
        //pass data
        createChallengeVC.screenFrom = .createGroupChallenge
        createChallengeVC.isType = false
        createChallengeVC.selectedGroup = self.chatInfo
        self.navigationController?.pushViewController(createChallengeVC, animated: true)
    }
    
    private func pushToCreateGoalScreen() {
        let createGoalVC: CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
        createGoalVC.presenter = CreateGoalOrChallengePresenter(forScreenType: .createGoal)
        //pass data
        createGoalVC.screenFrom = .createGroupChallenge
        createGoalVC.isType = true
        createGoalVC.selectedGroup = self.chatInfo
        self.navigationController?.pushViewController(createGoalVC, animated: true)
    }
    
    private func pushToAddTematesScreen() {
        let inviteFrndVC:InviteFriendController = UIStoryboard(storyboard: .challenge).initVC()
        inviteFrndVC.screenFrom = .addGroupParticipants
        inviteFrndVC.chatGroupId = self.chatInfo?.chatRoomId
        inviteFrndVC.delegate = self
        navigationController?.pushViewController(inviteFrndVC, animated: true)
    }
    
    public func joinGroupApiCall(groupId: String = "", isFromContentMarket: Bool = false) {
        if self.isConnectedToNetwork() {
        
            let params: Parameters?
            if isFromContentMarket && groupId != "" {
                chatInfo?.groupId = groupId
                params = ["groupId": groupId]
                
            }else{
                self.showLoader()
                params = self.chatInfo?.joinGroupJson()
            }
            self.chatNetworkLayer.joinGroup(params: params, completion: {[weak self] (_) in
                self?.hideLoader()
                //remove value at this index from array both from the searched array list and the main list array
                if let membersCount = self?.chatInfo?.membersCount {
                    self?.chatInfo?.membersCount = membersCount + 1
                }
                if let userId = UserManager.getCurrentUser()?.id {
                    self?.chatInfo?.memberIds?.append(userId)
                }
                let newStatus = GroupChatStatus.active
                self?.updateChatStatusInRoom(newStatus)
                self?.updateMembersInChatRoom()
                self?.chatInfo?.groupChatStatus = newStatus
                self?.setJoinButtonState()
                if let joinHandler = self?.joinHandler, let isOurTemSelected = self?.isOurTemSelected {
                    joinHandler(isOurTemSelected)
                }
                if let activeTemsJoinHandler = self?.activeTemsJoinHandler {
                    activeTemsJoinHandler()
                }
                NotificationCenter.default.post(name: Notification.Name.joinedGroup, object: self, userInfo: [ChatRoom.CodingKeys.chatRoomId: self?.chatInfo?.chatRoomId ?? ""])
                //
                self?.dismiss(animated: true, completion: nil)
            }) {[weak self] (error) in
                self?.hideLoader()
                if let msg = error.message {
                    self?.showAlert(message: msg)
                }
            }
        }
    }
}

// MARK: CustomBottomSheetDelegate
extension ChatViewController : CustomBottomSheetDelegate {
    func customSheet(actionForItem action: UserActions) {
        self.actionSheet.dismissSheet()
        switch action {
        case .unfriend:
            self.unfriendUser()
        case .clearChat:
            self.clearChat()
        case .block:
            self.blockUser()
        case .addMedia:
            self.showYPPhotoGallery(showCrop: false)
        case .createEvent:
            self.pushToCreateEventScreen()
        case .challenge:
            self.pushToCreateChallengeScreen()
        case .goal:
            self.pushToCreateGoalScreen()
        case .addTemates:
            self.pushToAddTematesScreen()
        case .pdf:
            openDocumentPicker()
        default:
            break
        }
    }
}

// MARK: Present full screen previews of images
extension ChatViewController {
    private func presentFullScreenImageOnScreen(urlString: String?) {
        
        DispatchQueue.main.async {
            guard let url = urlString,
                  let url = URL(string: url) else {
                      return
                  }
            OrientationManager.landscapeSupported = true
            let images = [LightboxImage(imageURL: url)]
            let controller = LightboxController(images: images, startIndex: 0)
            controller.dismissalDelegate = self
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
        
    }
}

// MARK: UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let senderId = self.messages[indexPath.row].senderId,
           let currentUserId = UserManager.getCurrentUser()?.id {
            if senderId == currentUserId {
                //this is the message from the current user
                return self.tableViewCellForMyMessage(indexPath: indexPath)
            } else {
                //this is the message from the other user
                return self.tableViewCellForOtherUserMessage(indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
    
    /// will return the table cell of the message of current user according to the message type i.e text, video or image
    func tableViewCellForMyMessage(indexPath: IndexPath) -> UITableViewCell {
        if let type = self.messages[indexPath.row].type {
            switch type {
            case .text:
                let cell: MyTextMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: MyTextMessageTableViewCell.reuseIdentifier, for: indexPath) as! MyTextMessageTableViewCell
                cell.delegate = self
                cell.backgroundColor = .clear
                cell.messageLabel.row = indexPath.row
                cell.messageLabel.section = indexPath.section
                cell.initializeWith(message: self.messages[indexPath.row], chatType: self.chatInfo?.chatType ?? .singleChat)
                return cell
            default:
                let cell: MyMediaMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: MyMediaMessageTableViewCell.reuseIdentifier, for: indexPath) as! MyMediaMessageTableViewCell
                cell.delegate = self
                cell.backgroundColor = .clear
                cell.initializeWith(message: self.messages[indexPath.row], indexPath: indexPath)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    /// will return the table cell of the message of other user according to the message type i.e text, video or image
    func tableViewCellForOtherUserMessage(indexPath: IndexPath) -> UITableViewCell {
        if let type = self.messages[indexPath.row].type {
            switch type {
            case .text:
                let cell: SenderTextMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: SenderTextMessageTableViewCell.reuseIdentifier, for: indexPath) as! SenderTextMessageTableViewCell
                cell.delegate = self
                cell.backgroundColor = .clear
                cell.messageLabel.row = indexPath.row
                cell.messageLabel.section = indexPath.section
                cell.initializeWith(message: self.messages[indexPath.row], chatType: self.chatInfo?.chatType ?? .singleChat)
                if self.chatWindowType == .normalChat {
                    if let senderId = self.messages[indexPath.row].senderId,
                       let filtered = self.chatMembers.first(where: {$0.user_id == senderId}) {
                        cell.setUserInformation(member: filtered)
                    }
                } else {
                    if let senderId = self.messages[indexPath.row].senderId,
                       let filtered = userInfo[senderId] as? Friends {
                        cell.setUserInformation(member: filtered)
                    }
                }
                return cell
            default:
                let cell: SenderMediaMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: SenderMediaMessageTableViewCell.reuseIdentifier, for: indexPath) as! SenderMediaMessageTableViewCell
                cell.delegate = self
                cell.backgroundColor = .clear
                cell.initializeWith(message: self.messages[indexPath.row], indexPath: indexPath)
                if self.chatWindowType == .normalChat {
                    if let senderId = self.messages[indexPath.row].senderId,
                       let filtered = self.chatMembers.first(where: {$0.user_id == senderId}) {
                        cell.setUserInformation(member: filtered)
                    }
                } else {
                    if let senderId = self.messages[indexPath.row].senderId,
                       let filtered = userInfo[senderId] as? Friends {
                        cell.setUserInformation(member: filtered)
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MyTextMessageTableViewCell {
            cell.addDropShadow()
        }
        if let cell = cell as? SenderTextMessageTableViewCell {
            cell.addDropShadow()
        }
        if let cell = cell as? SenderMediaMessageTableViewCell {
            cell.addDropShadow()
        }
        if let cell = cell as? MyMediaMessageTableViewCell {
            cell.addDropShadow()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let type = self.messages[indexPath.row].type {
            switch type {
            case .text :
                return UITableView.automaticDimension
            case .image, .video:
                if let senderId = self.messages[indexPath.row].senderId,
                   let currentUserId = UserManager.getCurrentUser()?.id {
                    if senderId == currentUserId {
                        //this is the message from the current user
                        if let imageRatio = self.messages[indexPath.row].media?.imageRatio {
                            return ((tableView.frame.width - 100) / imageRatio) + 15
                        } else {
                            return 140.0
                        }
                    } else {
                        //this is the message from the other user
                        if let imageRatio = self.messages[indexPath.row].media?.imageRatio {
                            return ((tableView.frame.width - 140) / imageRatio) + 15
                        }
                    }
                }
                case .pdf:
                    return 250.0
            }
        }
        return UITableView.automaticDimension
    }
}

// MARK: TagUsersListViewDelegate
extension ChatViewController: TagUsersListViewDelegate {
    func didChangeTagListingTableContentSize(newSize: CGFloat) {
        self.containerViewHeightConstraint.constant = newSize
        tagUsersListController?.view.frame = self.tagListContainerView.bounds
        self.tagListContainerView.layoutIfNeeded()
    }
    
    func didChangeTaggedList(taggedList: [TaggingModel]) {
        self.currentTaggedInMessage = taggedList.map({ $0.toUserTagModel() })
        self.currentTaggedIds = taggedList.map({ return $0.id })
    }
    
    func didChangeTaggableList(isEmpty: Bool) {
        self.tagListContainerView.isHidden = isEmpty
    }
    
    func didSelectUserFromTagList(tagText: String, userId: String) {
        Tagging.sharedInstance.updateTaggedList(allText: messageTextView.text, tagText: tagText, id: userId)
    }
    
    func updateAttributedTextOnTagSelect(attributedValue: (NSMutableAttributedString, NSRange)) {
        self.messageTextView.attributedText = attributedValue.0
        self.messageTextView.selectedRange = attributedValue.1
    }
}

// MARK: GroupInfoSideMenuDelegate
extension ChatViewController: GroupInfoSideMenuDelegate {
    func didTapOnClearGroupMessages() {
        self.clearChat()
    }
}

// MARK: ChatMediaMessagesTableCellDelegate
extension ChatViewController: ChatMediaMessagesTableCellDelegate {
    func openPdf(indexPath: IndexPath) {
        if let url = self.messages[indexPath.row].media?.url {
            self.selectedIndexPath = indexPath
            let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
            selectedVC.urlString = url
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
    
    func playVideo(indexPath: IndexPath) {
        if let media = self.messages[indexPath.row].media {
            guard let urlString = media.url,
                  let videoURL = URL(string: urlString) else {
                      return
                  }
            self.selectedIndexPath = indexPath
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    func openFullImageAt(indexPath: IndexPath) {
        if let url = self.messages[indexPath.row].media?.url {
            self.selectedIndexPath = indexPath
            self.presentFullScreenImageOnScreen(urlString: url)
        }
    }
}

extension ChatViewController: LightboxControllerDismissalDelegate {
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        OrientationManager.landscapeSupported = false
        let value = UIInterfaceOrientationMask.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}

// MARK: UITextViewDelegate
//Adjust the height of textview according to content.
extension ChatViewController :UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        //Tagging
        //tagging text view if changed
        if let chatType = self.chatInfo?.chatType,
           chatType == .groupChat {
            Tagging.sharedInstance.tagging(textView: textView)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.scrollTableToBottom()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let chatType = self.chatInfo?.chatType,
           chatType == .groupChat {
            Tagging.sharedInstance.tagging(textView: textView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.messageTextViewHeightConstraint.constant = textView.contentSize.height
        if self.messageTextViewHeightConstraint.constant > 70 {
            self.messageTextViewHeightConstraint.constant = 70
        }
        if let chatType = self.chatInfo?.chatType,
           chatType == .groupChat {
            Tagging.sharedInstance.updateTaggedList(range: range, textCount: text.utf16.count)
        }
        var hidebutton = false
        if (textView.text.count == 1 && text.count == 0) {
            hidebutton = true
        }
        if (textView.text.count + text.count) >= 1 && (hidebutton == false){
            //enable send button
            self.setSendButtonConfiguration(enableStatus: true)
        }else{
            //disable send button
            self.setSendButtonConfiguration(enableStatus: false)
        }
        return true
    }
}

// MARK: TextMessageTableCellDelegate
extension ChatViewController: TextMessageTableCellDelegate {
    func didTapOnUrlOnMessageAt(row: Int, section: Int, url: URL) {
        let indexPath = IndexPath(row: row, section: section)
        selectedIndexPath = indexPath
        self.pushToSafariVCOnUrlTap(url: url)
    }
    
    func didTapOnTagOnMessageAt(row: Int, section: Int, tagText: String) {
        if tagText == "all"{
        }else{
           
            if let taggedIds = self.messages[row].taggedUsers {
                let currentTagged = taggedIds.filter({$0.text == tagText})
                if let userId = currentTagged.first?.id {
                    let indexPath = IndexPath(row: row, section: section)
                    selectedIndexPath = indexPath
                    let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                    if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                        profileController.otherUserId = userId
                    }
                    self.navigationController?.pushViewController(profileController, animated: true)
                }
            }
        }
    }
}

// MARK: InviteFriendControllerViewDelegate
extension ChatViewController: InviteFriendControllerViewDelegate {
    func didSelectTemates(members: [Friends]) {
        self.selectedFriends = members
        self.showLoader(message: "Adding participants")
        var memberIds: [String] = []
        for (_, member) in members.enumerated() {
            if let memberId = member.id {
                memberIds.append(memberId)
            }
        }
        //edit group api call
        self.addGroupParticipants(memberIds: memberIds)
    }
}

// MARK: ShortCutButtonConfigurable, AddToHomeScreenViewable
extension ChatViewController: ShortCutButtonConfigurable, AddToHomeScreenViewable {
    func updateToHomeScreenShortcut(sender: UIButton) {
        self.onClickOfShortcut()
    }
    
    func addOrRemoveFromHomeScreen() {
        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerUserAPI().updateToHomeScreen(parameters: parametersOfShortcutUpdate().json(), completion: { (_) in
                self.hideLoader()
                self.updateShortCutView()
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "")
            }
        }
    }
    
    private func parametersOfShortcutUpdate() -> HomeScreenShortcut {
        var params = HomeScreenShortcut()
        params.type = .tem
        params.id = self.chatRoomId ?? ""
        params.name = self.chatInfo?.name
        if isAddedAsShortcutOnHomeScreen == .yes{
            params.status = .no
        } else {
            params.status = .yes
        }
        return params
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            var documentData = Data()
            for url in urls {
                documentData = try Data(contentsOf: url)
            }
            sendPdf(data: documentData)
        } catch {
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
