//
//  ProfileDashboardController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 25/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//
//////////POST http://165.227.16.15/apifrontline-dev/api/all-property"

import UIKit
import MapKit
import Alamofire
import SideMenu
import IQKeyboardManagerSwift
import WMSegmentControl
import SSNeumorphicView
enum PostViewType:Int,CaseIterable {
    case grid = 0
    case list = 1
}
enum isSectionType {
    case isOpen
    case isClose
}

enum ProfileHeaderTitles:Int,CaseIterable {
    case profile = 0
    case accountSetting = 1
    case healthMeasures = 2
    case temates = 3
    case other = 4
    var title:String {
        switch self {
        case .profile:
            return "Profile"
        case .accountSetting:
            return "Account"
        case .healthMeasures:
            return "Health"
        case .temates:
            return "Tēmates"
        case .other:
            return "Other"
        }
    }
}

enum OtherProfileSection:Int,CaseIterable {
    case accountabilityMission = 0
    case posts = 1
    var title:String {
        switch self {
        case .accountabilityMission:
            return "Accountability Mission"
        case .posts:
            return "Posts"
        }
    }
}

enum ProfileSection:Int,CaseIterable {
    case profileInfo = 0
    case accountabilityMission = 1
    case posts = 2
    case seeYourProfile = 3
    
    var title:String {
        switch self {
        case .profileInfo:
            return "Profile Information".localized
        case .accountabilityMission:
            return "Accountability Mission".localized
        case .posts:
            return "Posts".localized
        case .seeYourProfile:
            return "See Your Profile".localized
        }
    }
}
enum AccountSettingSection:Int,CaseIterable {
    case account = 0
    case linkDevice = 1
    case linkApps = 2
    case notiifications = 3
    case privacy = 4
}

class ProfileDashboardController: DIBaseController,PhoneContactProtocol {
    //pushing
    
    var sectionOpenStatus = [isSectionType.isClose,isSectionType.isClose,isSectionType.isClose, isSectionType.isClose]
    let profileSectionTitleArray = [ProfileSection.profileInfo.title,ProfileSection.accountabilityMission.title,ProfileSection.posts.title, ProfileSection.seeYourProfile.title]
    // MARK: Variables.
    var selectedSection:ProfileHeaderTitles = .profile
    //var selectedRow:Int!
    var postCommentFullScreenVC: PostCommentAddTagContainerViewController?
    var keyboardHeight: CGFloat = 0
    private var minVideoPlaySize: CGFloat = 125.0
    private var previousPage:Int = 1
    private var currentPage:Int = 1
    var regiseterUser:User = User()
    var isComingFromDashboard = true
    var isGridView:Bool = true
    var freindsSuggestion = [Friends]()
    var userPosts:[Post] = [Post]()
    var collectionOffsets: [Int: CGPoint] = [:]
    var refreshControl: UIRefreshControl!
    //private var isReponse:Bool = false
    var actionSheet = CustomBottomSheet()
    var previousPageForSuggestedFriend:Int = 1
    var currentPageForSuggestedFriend:Int = 1
    var isRefresh = true
    var otherUserId: String?
    var userProfile: Friends?
    let networkManager = NetworkConnectionManager()
    var tableArray = [String]()
    var isEditProfileNavigate = false
    var haisView:HAISViewController = UIStoryboard(storyboard: .reports).initVC()
    let createProfileVC:EditProfile = UIStoryboard(storyboard: .main).initVC()
    let tematesVC:NetworkViewController = UIStoryboard(storyboard: .network).initVC()
    
    //    var keyboardVisible = false;
    //    var keyboardRect = CGRect();
    //    var selectedTextViewTag:Int!
    //    var textviewDisplayHeight:CGFloat!
    var haisViewheight = 1600
    //VGPlayer
    var player : VGPlayer!
    @IBOutlet var accountInfoContainerView: UIView!
    @IBOutlet var healthInfoContainerView: UIView!
    @IBOutlet var tematesInfoContainerView: UIView!
    @IBOutlet var myPostInfoContainerView: UIView!
    @IBOutlet var viewReportInfoContainerView: UIView!
    @IBOutlet var foodTrekContainerView: UIView!
    @IBOutlet var temWalletContainerView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var editNewImageView: UIImageView!
    @IBOutlet weak var accountInfoBtn: UIButton!
    
    @IBOutlet var myPostShadowView: SSNeumorphicView! {
        didSet {
            myPostShadowView.setOuterDarkShadow()
            myPostShadowView.viewNeumorphicCornerRadius = 12
        }
    }
    
    @IBOutlet var viewReportShadowView: SSNeumorphicView! {
        didSet {
            viewReportShadowView.setOuterDarkShadow()
            viewReportShadowView.viewNeumorphicCornerRadius = 12
        }
    }
    
    @IBOutlet var foodTrekShadowView: SSNeumorphicView! {
        didSet {
            foodTrekShadowView.setOuterDarkShadow()
            foodTrekShadowView.viewNeumorphicCornerRadius = 12
        }
    }
    @IBOutlet var temWalletShadowView: SSNeumorphicView! {
        didSet {
            temWalletShadowView.setOuterDarkShadow()
            temWalletShadowView.viewNeumorphicCornerRadius = 12
        }
    }
    
    @IBOutlet var accountInfoShadowView: SSNeumorphicView! {
        didSet {
            accountInfoShadowView.setOuterDarkShadow()
            accountInfoShadowView.viewNeumorphicCornerRadius = 12
        }
    }
    
    @IBOutlet var myHealthInfoShadowView: SSNeumorphicView! {
        didSet {
            myHealthInfoShadowView.setOuterDarkShadow()
            myHealthInfoShadowView.viewNeumorphicCornerRadius = 12
        }
    }
    

    @IBOutlet var myTematesInfoShadowView: SSNeumorphicView! {
        didSet {
            myTematesInfoShadowView.setOuterDarkShadow()
            myTematesInfoShadowView.viewNeumorphicCornerRadius = 12
        }
    }

    //Will keep track of the index paths of currently playing player view
    var currentPlayerIndex: (tableIndexPath: IndexPath?, collectionIndexPath: IndexPath?)?
    
    //will keep track of the index paths of last played player view
    var previousPlayerIndex: (tableIndexPath: IndexPath?, collectionIndexPath: IndexPath?)?
    
    //will keep track of the last url being played in the player view
    private var lastPlayingMediaUrl: String?
    
    //var tagUsersListController: TagUsersListViewController?
    var activeTextView: UITextView?
    var viewingMyOwnProfileAsOthers = false
    
    @IBOutlet weak var tagListContainerView: UIView!
    // MARK: IBOutlets.
    @IBOutlet weak var activityScoreImageView: UIImageView!
    @IBOutlet weak var goalsChallengesCountLbl: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var connectStackView: UIStackView!
    @IBOutlet weak var connectStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var countStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagListBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var connectionStatusButton: UIButton!
    @IBOutlet weak var countStackView: UIStackView!
    @IBOutlet weak var segmentTabView: UIStackView!
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var temNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tematesCountLabel: UILabel!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var tematesButton: UIButton!
    //    @IBOutlet weak var gridButton: UIButton!
    //    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var userbgImageView: UIImageView!
    //    @IBOutlet weak var gridListHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tematesLbl: UILabel!
    @IBOutlet weak var postLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var segmentTabViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navigationBarViewHeight: NSLayoutConstraint!
    var navigationBar: NavigationBar!
    var temHeight: CGFloat = 800
    @IBOutlet var outerShadowView: SSNeumorphicView!
    @IBOutlet var descriptionShadowView: SSNeumorphicView!
    @IBOutlet var accountbilityMissionTextView: UITextView!
    @IBOutlet weak var accountbilityMissionToggle:UIImageView!
    @IBOutlet weak var accountbilityMissionToggleShadowView:SSNeumorphicView! {
        didSet {
            accountbilityMissionToggleShadowView.cornerRadius = accountbilityMissionToggleShadowView.frame.height / 2
            accountbilityMissionToggleShadowView.viewNeumorphicMainColor = UIColor.white.cgColor
            accountbilityMissionToggleShadowView.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.3).cgColor
            accountbilityMissionToggleShadowView.viewNeumorphicLightShadowColor = UIColor(red: 255.0 / 255.0, green: 254.0 / 255.0, blue: 254.0 / 255.0, alpha: 0.3).cgColor
        }
    }
    @IBOutlet weak var temateRequestBtnShadowView:SSNeumorphicView! {
        didSet {
            temateRequestBtnShadowView.setOuterDarkShadow()
            temateRequestBtnShadowView.viewNeumorphicCornerRadius = 12
        }
    }
    
    @IBOutlet weak var temateRequestBtnGradientView:GradientDashedLineCircularView! {
        didSet {
            self.createGradientView(view: temateRequestBtnGradientView)
        }
    }
    var accountbilityMission:String = ""
    @IBOutlet weak var profileStatusLabel:UILabel!
    @IBOutlet weak var myPostsLabel:UILabel!
    @IBOutlet weak var myTematesButton:UIButton!
    @IBOutlet weak var accountInfoLabel:UILabel!
    @IBOutlet weak var healthInfoLabel:UILabel!
    @IBOutlet weak var tematesLabel:UILabel!
    @IBOutlet weak var temateRequestBtn:UIButton!
    @IBOutlet weak var temateRequestBtnLabel:UILabel!
    @IBOutlet weak var activityReportsViewHeight:NSLayoutConstraint!
    @IBOutlet weak var tematesRequestBtnViewHeight:NSLayoutConstraint!
    @IBOutlet weak var foodTrekViewTop:NSLayoutConstraint!
    
    @IBOutlet weak var myTematesTop: NSLayoutConstraint!
    @IBOutlet weak var temWalletHeight: NSLayoutConstraint!
    let accountInfo = "ACCOUNT INFO"
    let healthInfo = "MY HEALTH INFO"
    let myTemates = "MY TĒMATES  |"
    let myPosts = "MY POSTS"
    let viewPosts = "VIEW POSTS"
    let totalTemats = "TOTAL TĒMATES  |"
    let activeGoals = "ACTIVE PUBLIC TĒMS, GOALS & CHALLENGES  |"
    let startGoal = "START GOAL OR CHALLENEGE"
    let temateRequest = "TĒMATE\nREQUEST"
    let requestSent = "REQUEST\nSENT"
    let disconnect = "DISCONNECT"
    // MARK: ViewLifeCycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        regiseterUser = UserManager.getCurrentUser() ?? User()
        accountInfoContainerView.cornerRadius = 12
        descriptionShadowView.viewDepthType = .innerShadow
        descriptionShadowView.viewNeumorphicCornerRadius = 12
        outerShadowView.setOuterDarkShadow()
        outerShadowView.viewNeumorphicCornerRadius = self.outerShadowView.frame.width/2
        self.outerShadowView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        self.descriptionShadowView.viewNeumorphicMainColor = UIColor.white.cgColor
        self.descriptionShadowView.viewNeumorphicLightShadowColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.09).cgColor
        self.descriptionShadowView.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35).cgColor
        healthInfoContainerView.cornerRadius = 12
        tematesInfoContainerView.cornerRadius = 12
        myPostInfoContainerView.cornerRadius = 12
        viewReportInfoContainerView.cornerRadius = 12
        foodTrekContainerView.cornerRadius = 12
        temWalletContainerView.cornerRadius = 12
        setMyProfile()
        backBtn.addDoubleShadowToButton(cornerRadius: backBtn.frame.height / 2, shadowRadius: 0.4, lightShadowColor: UIColor.white.withAlphaComponent(0.1).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor: UIColor.newAppThemeColor)
        editBtn.addDoubleShadowToButton(cornerRadius: editBtn.frame.height / 2, shadowRadius: 0.4, lightShadowColor: UIColor.white.withAlphaComponent(0.1).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor: UIColor.newAppThemeColor)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData()
        self.navigationController?.navigationBar.isHidden = true
    }
    func setMyProfile() {
        if otherUserId == nil {
            self.setLoggedInUserUI()
            self.setLocationData()
        }
    }
    
    private func redirectToChatRoom(){
        if let adminType = userProfile?.admintype, adminType != 1 {
            self.getAffiliateChatRoomId(affiliateId: self.userProfile?.id ?? "")
        }
        else {
            if let chatRoomId = self.userProfile?.chatRoomId {
                if chatRoomId.count > 0{
                    self.initiateChatRoom(chatRoomId: chatRoomId)
                }
                else{
                    self.showAlert(withTitle: "", message: "You must be TĒMATES before messaging. Please request to be TĒMATES down below.",okayTitle: "OK", okStyle: .cancel) {
                        // ok action
                    } cancelCall: {
                        // cancel action
                    }
                }
            }
        }
    }
    private func initiateChatRoom(chatRoomId: String) {
        let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        chatController.chatRoomId = chatRoomId
        chatController.chatName = self.userProfile?.fullName
        chatController.chatNotInitiatedWithAffiliate = true
        if let adminType = userProfile?.admintype, adminType != 2 {
            chatController.canAlwaysChat = true
        }
        if let url = URL(string: self.userProfile?.profilePic ?? ""){
            chatController.chatImageURL = url
        }else{
            chatController.chatImageURL = URL(string: "")
        }
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    private func openChatRoom(affiliateId: String){
        if let chatRoomId = self.userProfile?.chatRoomId,!chatRoomId.isEmpty {
            self.initiateChatRoom(chatRoomId: chatRoomId)
        } else {
            self.getAffiliateChatRoomId(affiliateId: affiliateId)
        }
    }
    
    private func getAffiliateChatRoomId(affiliateId: String) {
        DIWebLayerContentMarket().getAffiliateChatId(affiliateId: affiliateId) { chatRoomId in
            self.initiateChatRoom(chatRoomId: chatRoomId)
        } failure: { error in
            print(error.message ?? "")
        }
    }
    private func redirectToEditProfile(){
        let createProfileVC:EditProfile = UIStoryboard(storyboard: .main).initVC()
        self.navigationController?.pushViewController(createProfileVC, animated: true)
    }
    
    private func redirectToAccountInfo(){
        let accountInfoVC:AccountController = UIStoryboard(storyboard: .profile).initVC()
        self.navigationController?.pushViewController(accountInfoVC, animated: true)
    }

    private func redirectToHealthInfo() {
        let healthInfoVC:MyHealthInfoViewController = UIStoryboard(storyboard: .profile).initVC()
        
        self.navigationController?.pushViewController(healthInfoVC, animated: true)
    }
    private func redirectToActiveTems(){
        let activeTemsVC: ActiveTemsAndGoalsViewController = UIStoryboard(storyboard: .profile).initVC()
        if let otherUserId = otherUserId {
            activeTemsVC.userId = otherUserId
        }
        self.navigationController?.pushViewController(activeTemsVC, animated: true)
    }
    
    @IBAction func onClickAccountInfo(_ sender:UIButton)  {
        if let _ = self.otherUserId {
            startNewGoalAndChallenge()
        } else {
            redirectToAccountInfo()
        }
    }
    
    @IBAction func onClickTemateRequest(_ sender:UIButton){
       friendButtonRequest()
    }
    
    @IBAction func onClickEdit(_ sender:UIButton)  {
        if let _ = self.otherUserId {
            redirectToChatRoom()
        } else {
            redirectToEditProfile()
        }
    }
    
    @IBAction func onClickHealth(_ sender:UIButton)  {
        if let _ = self.otherUserId {
            redirectToActiveTems()
        } else {
            redirectToHealthInfo()
        }
    }
    
    @IBAction func onClickMyTemmates(_ sender:UIButton)  {
        if viewingMyOwnProfileAsOthers {
            return
        }
        //check if current profile is of logged in user
        // if the user is viewing someone's other profile
        //otherUserId will be nil if logged in user profile is viewed
        if let userId = self.otherUserId {
            if let isPrivate = self.userProfile?.isPrivate,
                isPrivate == .yes {
                //user can't view the friends
                self.showAlert(message: "This user’s profile is private. That information is unavailable.")
                return
            }
            let friendsVC: UsersListingViewController = UIStoryboard(storyboard: .post).initVC()
            friendsVC.presenter = UsersListingPresenter(forScreenType: .othersTemates, id: userId)
            self.navigationController?.pushViewController(friendsVC, animated: true)
        } else {
            let tematesVC: NetworkViewController = UIStoryboard(storyboard: .network).initVC()
            tematesVC.isFromDashboard = false
            self.navigationController?.pushViewController(tematesVC, animated: true)
        }
    }
    
    @IBAction func onClickMyReport(_ sender:UIButton)  {
        let createProfileVC:ReportViewController = UIStoryboard(storyboard: .reports).initVC()
        self.navigationController?.pushViewController(createProfileVC, animated: true)
    }
    
    @IBAction func onClickFoodTrek(_ sender:UIButton)  {
        if let _ = self.otherUserId {
            let foodTrekListingVC:FoodTrekListingVC = UIStoryboard(storyboard: .foodTrek).initVC()
            foodTrekListingVC.isOtherUser = self.otherUserId == nil ? false : true
            foodTrekListingVC.userId = (self.otherUserId == nil ? "" : self.otherUserId) ?? ""
            guard let chatRoomId = self.userProfile?.chatRoomId else {
                return
            }
            foodTrekListingVC.chatRoomId = chatRoomId
            foodTrekListingVC.chatName = self.userProfile?.fullName
            if let url = URL(string: self.userProfile?.profilePic ?? ""){
                foodTrekListingVC.chatImageURL = url
            }else{
                foodTrekListingVC.chatImageURL = URL(string: "")
            }
           self.navigationController?.pushViewController(foodTrekListingVC, animated: true)
        } else {
            if let foodTrekAdded = self.userProfile?.foodTrekContentExists{
                if foodTrekAdded{
                    let foodTrekListingVC:FoodTrekListingVC = UIStoryboard(storyboard: .foodTrek).initVC()
                    self.navigationController?.pushViewController(foodTrekListingVC, animated: true)
                }
            }

        }
    }
    
    @IBAction func onClickTemWallet(_ sender:UIButton)  {
        let manageBillingVc: ManageBillingViewController = UIStoryboard(storyboard: .payment).initVC()
        self.navigationController?.pushViewController(manageBillingVc, animated: true)
    }
    
    deinit {
        removeNotificationObservers()
    }

    private func setIQKeyboard(enable: Bool) {
        IQKeyboardManager.shared.enable = enable
        IQKeyboardManager.shared.shouldResignOnTouchOutside = enable
    }

    private func setUpTagListContainer() {
        self.tagListContainerView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.listenVolumeButton()
        self.playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeBadgeObserver()
        //remove the player if currently playing in the view
        self.removePlayer()
        self.view.endEditing(true)
        //        NotificationCenter.default.removeObserver(self)
        removeNotificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setIQKeyboard(enable: true)
        self.removeKeyboardNotificationObservers()
        self.removeNotificationObservers()
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.outputVolumeChanged, object: nil)
        //self.removeVolumeListeners()
    }
    
    // MARK: Custom Function
    // MARK: Function to set Navigation Bar.
    private func initUI() {
        if #available(iOS 11.0, *) {
            userTableView.insetsContentViewsToSafeArea = false
        } else {
            // Fallback on earlier versions
        }
        
        locationImageView.isHidden = true
        //239,249,254
        DispatchQueue.main.async {
            let segmentBar = WMSegment()
            // segmentBar.type = .normal // normal (Default),imageOnTop, onlyImage
            // If you want round selector
            segmentBar.isRounded = true //By default false
            //Set titles of your segment
            segmentBar.buttonTitles = ProfileHeaderTitles.profile.title + "," + ProfileHeaderTitles.accountSetting.title + "," + ProfileHeaderTitles.healthMeasures.title + "," + ProfileHeaderTitles.temates.title
            // set text color for non - selected segment values
            segmentBar.textColor = .black
            segmentBar.backgroundColor = UIColor.appThemeLightColor
            // set text color for selected segment value
            segmentBar.selectorTextColor = .white
            segmentBar.clipsToBounds = true
            //set Color for selected segment
            segmentBar.selectorColor = UIColor.appThemeColor
            segmentBar.addTarget(self, action: #selector(self.segmentValueChange(_ :)) , for: .valueChanged)
            
            //set font for selcted segment value
            segmentBar.frame = CGRect(x:0, y: 0, width:self.segmentView.frame.size.width, height:35)
            self.segmentView.addSubview(segmentBar)
        }
        
        // MARK: SetUserTable.
        //        userTableView.tableHeaderView?.showSkeleton()
        userTableView.tableFooterView = UIView()
        self.userTableView.rowHeight = UITableView.automaticDimension
        self.userTableView.estimatedRowHeight = 300.0
        self.userTableView.estimatedSectionHeaderHeight = 140.0
        self.userTableView.register(UINib(nibName: PostTableCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: PostTableCell.reuseIdentifier)
        self.userTableView.register(UINib(nibName: "TableAccountViewCell", bundle: nil), forCellReuseIdentifier: "TableAccountViewCell")
        addRefreshController()
        self.userTableView.bounces = true
        
        if isComingFromDashboard {
            if self.otherUserId == nil {
                self.navigationBar = configureNavigtion(onView: navigationBarView, title: "", leftButtonAction: .back,isProfile: true)
            }else {
                self.navigationBar = configureNavigtion(onView: navigationBarView, title: "", leftButtonAction: .back, rightButtonAction: [.dot],isProfile: true)
            }
        }else{
            self.navigationBar = configureNavigtion(onView: navigationBarView, title: "", leftButtonAction: .back, rightButtonAction: [.filter,.search,.addPost],isProfile: true)
        }
        if self.navigationBar.leftAction == .menu {
            navigationBar.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
        }
        //        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
        
        if let _ = self.otherUserId,
            !viewingMyOwnProfileAsOthers {
            self.connectionStatusButton.isHidden = false
        }
        fetchUserData()
        sizeHeaderToFit()
        self.setUpTagListContainer()
    }
    @objc func outputVolumeChanged() {
        self.updateMuteButtonOnChangingSoundStatus()
        self.updatePlayerSoundStatus()
    }
    // MARK: Functions
    @objc func hideShowCell(sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag ?? 0
        if let profileSectionVal = ProfileSection(rawValue: tag),
            profileSectionVal == .seeYourProfile {
            DispatchQueue.main.async {
                let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                profileController.viewingMyOwnProfileAsOthers = true
                let userId = UserManager.getCurrentUser()?.id ?? ""
//                profileController.otherUserId = userId
                profileController.otherUserId = userId
                self.navigationController?.pushViewController(profileController, animated: true)
            }
            return
        }
        if sectionOpenStatus [sender.view?.tag ?? 0] == .isOpen {
            sectionOpenStatus[sender.view?.tag ?? 0] = .isClose
        } else {
            for value in sectionOpenStatus.enumerated(){
                if (sectionOpenStatus[value.offset] == .isOpen){
                    sectionOpenStatus[value.offset] = .isClose
                }
            }
            sectionOpenStatus[sender.view?.tag ?? 0] = .isOpen
        }
        UIView.transition(with: userTableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.userTableView.reloadData()
        }, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func moreTapped(_ sender: UIButton) {
        if self.userProfile?.friendStatus == .connected {
            actionSheet = Utility.presentActionSheet(titleArray: [.message,.unfriend,.block,.cancel], titleColorArray: [UIColor.black,UIColor.black,UIColor.red,UIColor.gray], tag: 0,section: 0)
        }else if self.userProfile?.friendStatus == .blocked {
            actionSheet = Utility.presentActionSheet(titleArray: [.unBlock,.cancel], titleColorArray: [UIColor.gray,UIColor.gray], tag: 0,section: 0)
        }else{
            actionSheet = Utility.presentActionSheet(titleArray: [.block,.cancel], titleColorArray: [UIColor.red,UIColor.gray], tag: 0,section: 0)
        }
        actionSheet.delegate = self
    }
    
    @IBAction func segmentValueChange(_ sender: WMSegment) {
        switch selectedSection{
        case .profile:
            checkAndUpdateProfileData(sender)
        case .healthMeasures:
            checkAndUpdateHealthData(sender)
        default:
            
            selectedSection = ProfileHeaderTitles(rawValue: sender.selectedSegmentIndex) ?? .profile
            if selectedSection == .healthMeasures{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    self.userTableView.reloadData()
                }
            }
            UIView.transition(with: self.userTableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.userTableView.reloadData()
            }, completion: nil)
        }
    }
    
    func checkAndUpdateProfileData(_ sender: WMSegment){
        var isEqual = true
        let editProfileObj = createProfileVC
        isEqual = editProfileObj.regiseterUser.equals(compareTo: User.sharedInstance)
        if isEqual{
            isEqual = !editProfileObj.isUserImageChanged
        }
        if !isEqual{
            showAlertIfProfileNotEqual(editProfile: editProfileObj, sender)
        }
        if isEqual {
            self.selectedSection = ProfileHeaderTitles(rawValue: sender.selectedSegmentIndex) ?? .profile
            self.userTableView.reloadData()
        }
    }
    
    func showAlertIfProfileNotEqual(editProfile:EditProfile,_ sender: WMSegment){
        self.showAlert(withTitle: "", message:"Are you want to update your profile?", okayTitle: "Yes".localized,cancelTitle: "No", okCall: {
            sender.setSelectedIndex(self.selectedSection.rawValue)
            editProfile.actionOnSubmitButton()
        }, cancelCall: {
            self.selectedSection = ProfileHeaderTitles(rawValue: sender.selectedSegmentIndex) ?? .profile
            self.userTableView.reloadData()
        })
    }
    
    func checkAndUpdateHealthData(_ sender: WMSegment){
        if haisView.submitButton.isUserInteractionEnabled {
            showAlertIfHealthNotEqual(haisVC: haisView, sender)
        } else {
            self.selectedSection = ProfileHeaderTitles(rawValue: sender.selectedSegmentIndex) ?? .profile
            self.userTableView.reloadData()
        }
        
    }
    
    func showAlertIfHealthNotEqual(haisVC:HAISViewController,_ sender: WMSegment){
        self.showAlert(withTitle: "", message:"Are you want to update your health measures?", okayTitle: "Yes".localized,cancelTitle: "No", okCall: {
            sender.setSelectedIndex(self.selectedSection.rawValue)
            haisVC.view.endEditing(true)
            haisVC.updateHealthData()
        }, cancelCall: {
            self.selectedSection = ProfileHeaderTitles(rawValue: sender.selectedSegmentIndex) ?? .profile
            self.userTableView.reloadData()
        })
    }
    
    func resetData() {
        for(index,_) in self.userPosts.enumerated() {
            self.userPosts[index].commentText = ""
        }
    }
    
    // MARK: Function to fetch user detail from server
    private func setLoggedInUserUI(){
        if let imageUrl = URL(string: self.regiseterUser.profilePicUrl ?? "") {
            self.userImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else {
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        userImageView.cornerRadius = self.userImageView.frame.width/2
        nameLabel.text = "\(self.regiseterUser.firstName ?? "") \(self.regiseterUser.lastName ?? "")".trim
        temNameLabel.text = "@\(self.regiseterUser.userName ?? "")"
        self.tematesCountLabel.text = "\(self.regiseterUser.tematesCount ?? 0)"
        editBtn.setImage(UIImage(named: ""), for: .normal)
        editNewImageView.isHidden = true
        editNewImageView.image = UIImage(named: "whiteiconedit")
        editBtn.setImage(UIImage(named: "whiteiconedit"), for: .normal)
        accountbilityMissionTextView.isEditable = true
        myTematesButton.isUserInteractionEnabled = true
        accountInfoLabel.text = "\(accountInfo)"
        healthInfoLabel.text = "\(healthInfo)"
        tematesLabel.text = "\(myTemates)"
        myPostsLabel.text = "\(myPosts)"
        activityReportsViewHeight.constant = 61
        myTematesTop.constant = 110
        temWalletHeight.constant = 61
        foodTrekViewTop.constant = 110
        tematesRequestBtnViewHeight.constant = 0
        accountbilityMissionToggle.isHidden = false
        accountbilityMissionToggleShadowView.isHidden = false
        goalsChallengesCountLbl.isHidden = true
        temWalletContainerView.isHidden = false
        temWalletShadowView.isHidden = false
    }
    private func setOtherUserUI(user:Friends){
        if let imageUrl = URL(string: user.profilePic ?? "") {
            self.userImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else {
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        userImageView.cornerRadius = self.userImageView.frame.width/2
        nameLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")".trim
        temNameLabel.text = "@\(user.userName ?? "")"
        self.tematesCountLabel.text = "\(user.tematesCount ?? 0)"
        editBtn.setImage(UIImage(named: "envelope-g"), for: .normal)
        editNewImageView.isHidden = true
        accountbilityMissionTextView.isEditable = false
        myTematesButton.isUserInteractionEnabled = true
        accountInfoLabel.text = startGoal
        healthInfoLabel.text = activeGoals
        tematesLabel.text = totalTemats
        myPostsLabel.text = viewPosts
        setOtherUserProfileStatus(user: user)
        activityReportsViewHeight.constant = 0
        myTematesTop.constant = 30
        temWalletHeight.constant = 0
        foodTrekViewTop.constant = 30
        accountbilityMissionToggle.isHidden = true
        accountbilityMissionToggleShadowView.isHidden = true
        goalsChallengesCountLbl.isHidden = false
        if let friendStatus = self.userProfile?.friendStatus, friendStatus == .connected{
            tematesRequestBtnViewHeight.constant = 61
            temateRequestBtnLabel.text =  disconnect
        } else if let friendStatus = self.userProfile?.friendStatus, friendStatus == .requestSent {
            tematesRequestBtnViewHeight.constant = 61
            temateRequestBtnLabel.text = requestSent
        } else {
            tematesRequestBtnViewHeight.constant = 61
            temateRequestBtnLabel.text = temateRequest
        }
        
        temWalletContainerView.isHidden = true
        temWalletShadowView.isHidden = true
    }
    
    private func setOtherUserProfileStatus(user: Friends) {
        profileStatusLabel.isHidden = false
        if user.isPrivate == .yes {
            profileStatusLabel.text = "Private Profile"
        } else {
            profileStatusLabel.text = "Public Profile"
        }
    }
    private func setUserProfileData(user:Friends){
        if self.otherUserId != nil {
            self.setOtherUserUI(user: user)
            self.setLocationData(user: user)
        } else {
            self.setLoggedInUserUI()
            self.setLocationData()
        }
        
        goalsChallengesCountLbl.text = "\(user.goalAndChallengeCount ?? 0)"
        self.tematesCountLabel.text = "\(user.tematesCount ?? 0)"
        self.accountbilityMissionTextView.delegate = self
        if user.accountabilityMission == "" || user.accountabilityMission?.isEmpty != false || user.accountabilityMission == AppMessages.ProfileMessages.accountabilityPlaceholder{
            self.accountbilityMissionTextView.text = AppMessages.ProfileMessages.accountabilityPlaceholder
            self.accountbilityMissionToggle.image = UIImage(named: "")
        }else{
            self.accountbilityMissionTextView.text = user.accountabilityMission
            self.accountbilityMissionToggle.image = UIImage(named: "Oval Copy 3")
        }
    }
    func fetchUserData() {
        if otherUserId != nil && userProfile == nil {
            self.showLoader()
        }
        let userId = viewingMyOwnProfileAsOthers == true ? nil : otherUserId
        DIWebLayerProfileAPI().getProfileDetails(page: previousPage, userId: userId, success: {[weak self] (posts, user, useractivity) in
            DispatchQueue.main.async {
                self?.hideLoader()
            if let user = user {
                self?.userProfile = user
                self?.setUserProfileData(user: user)
                self?.setLocationData(user: user)
                
                if self?.otherUserId == nil {
                    self?.updateCurrentUserTemates(count: user.tematesCount ?? 0)
                }
            }
            self?.isRefresh = true
            if let status = self?.userProfile?.friendStatus, status == .blocked {
                self?.postButton.isUserInteractionEnabled = false
                self?.tematesButton.isUserInteractionEnabled = false
                self?.setDataAfterApiSuccess(posts:[])
            }else{
                self?.setDataAfterApiSuccess(posts: posts)
            }
            }

        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    
    
    /// call to set the data source for the view
    private func setDataAfterApiSuccess(posts: [Post]) {
        if (self.previousPage == 1) {
            self.userPosts.removeAll()
            if (posts.count > 0) {
                self.userPosts = posts
            }
        } else {
            if (posts.count > 0) {
                self.userPosts.append(contentsOf: posts)
            }
        }
        if posts.count >= 15 {
            self.currentPage += 1
        }
    //    self.userTableView.tableFooterView = UIView()
   //     self.refreshControl.endRefreshing()
     //   self.setInitialData()
    }
    
    // MARK: Fetch User Suggestions.
    func getUserSuggestion(pagenumber:Int) {
        if let id = otherUserId , id != "" {
            return
        }
        DIWebLayerProfileAPI().getFriendSuggestion(page:pagenumber, success: { (data) in
            
            if (data.count > 0){
                if (pagenumber > 1) {
                    self.freindsSuggestion.append(contentsOf: data)
                } else {
                    self.freindsSuggestion.removeAll()
                    self.freindsSuggestion = data
                }
                if (data.count >= 15) {
                    self.currentPageForSuggestedFriend += 1
                }
                if !self.isEditProfileNavigate {
                    self.userTableView.reloadData()
                }
            }
        }) { (error) in
            self.showAlert(message:error.message)
        }
    }
    
    ///send friend request api call
    func sendFriendRequest() {
        //send request api call
        guard let id = self.otherUserId else {
            return
        }
        var params: FriendRequest = FriendRequest()
        params.friendId = id
        networkManager.sendRequest(params: params.getDictionary(), success: {[weak self] (response) in
            self?.userProfile?.friendStatus = .requestSent
            DispatchQueue.main.async {
                self?.temateRequestBtnLabel.text = self?.requestSent
            }
        }) {[weak self] (error) in
            self?.showAlert(message: error.message ?? "")
            DispatchQueue.main.async {
                self?.temateRequestBtnLabel.text = self?.temateRequest
            }
        }
    }
    
    //Delete friend and remove from friend list.
    func deleteFriend() {
        self.showAlert(withTitle: AppMessages.ProfileMessages.warning, message: AppMessages.NetworkMessages.removeFriend, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
            if !self.isConnectedToNetwork() {
                return
            }
            guard let id = self.otherUserId else {
                return
            }
            var params:FriendRequest = FriendRequest()
            params.friendId = id
            self.showLoader()
            self.networkManager.deleteFriend(params: params.getDictionary() ?? [:], success: { [weak self] (response) in
                self?.userProfile?.friendStatus = .other
                DispatchQueue.main.async {
                    self?.hideLoader()
                    self?.temateRequestBtnLabel.text = self?.temateRequest
                }
            }, failure: { [weak self] (error) in
                self?.showAlert(message: error.message ?? "")
                DispatchQueue.main.async {
                    self?.hideLoader()
                    self?.temateRequestBtnLabel.text = self?.disconnect
                }
            })
        })
    }
        
    //accept friend request api call
    func acceptFriendRequest() {
        guard let id = self.otherUserId else {
            return
        }
        var params: FriendRequest = FriendRequest()
        params.friendId = id
        networkManager.acceptRequest(params: params.getDictionary(), success: { [weak self] (response) in
            self?.userProfile?.friendStatus = .connected
            if let chatRoomId = response["chat_room_id"] as? String {
                self?.userProfile?.chatRoomId = chatRoomId
            }
            DispatchQueue.main.async {
                self?.fetchUserData()
            }
        }) {[weak self] (error) in
            self?.showAlert(message: error.message ?? "")
            DispatchQueue.main.async {
                self?.connectionStatusButton.isEnabled = true
            }
        }
    }
    
    //unblockUser request api call
    func unblockUser() {
        guard let id = self.otherUserId else {
            return
        }
        var params: BlockUser = BlockUser()
        params.friendId = id
        networkManager.unBlockUser(params: params.getDictionary(), success: { [weak self] (response) in
            self?.userProfile?.friendStatus = .other
            self?.fetchUserData()
            self?.postButton.isUserInteractionEnabled = true
            self?.tematesButton.isUserInteractionEnabled = true
            DispatchQueue.main.async {
              //  self?.updateConnectionStatusButtonView()
            }
        }) {[weak self] (error) in
            self?.showAlert(message: error.message ?? "")
            DispatchQueue.main.async {
                self?.connectionStatusButton.isEnabled = true
            }
        }
    }
    
    //blockUser request api call
    func blockUser(index: Int) {
        guard let id = self.otherUserId else {
            return
        }
        var params: BlockUser = BlockUser()
        params.friendId = id
        networkManager.blockUser(params: params.getDictionary(), success: { [weak self] (response) in
            self?.dotsButtonAction(indexPath: IndexPath(row: 0, section: 0) , type: .block)
        }) {[weak self] (error) in
            self?.showAlert(message: error.message ?? "")
            DispatchQueue.main.async {
                self?.connectionStatusButton.isEnabled = true
            }
        }
    }
    
    //delete post api call
    func deletePostAt(index: Int) {
        self.showLoader()
        let params = DeletePostApiKey(id: self.userPosts[index].id ?? "")
        PostManager.shared.deletepost(parameters: params.toDictionary(), success: { (message) in
            self.showAlert(message:message)
            self.dotsButtonAction(indexPath: IndexPath(row: index, section: 0) , type: .delete)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    // MARK: Set User Data.
    func setInitialData() {
        self.hideLoader()
       
        if let imageUrl = URL(string: self.userProfile?.profilePic ?? "") {
            self.userbgImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else {
            self.userbgImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        nameLabel.text = "\(self.userProfile?.firstName ?? "") \(self.userProfile?.lastName ?? "")".trim
        temNameLabel.text = self.userProfile?.userName ?? ""
        if self.userProfile?.address?.formatAddress() == "" || self.userProfile?.address?.formatAddress() == nil {
            locationImageView.isHidden = true
        } else {
            locationImageView.isHidden = false
        }
        self.setLocationData(user: self.userProfile ?? Friends())
        if let count = self.userProfile?.tematesCount {
            tematesCountLabel.text = "\(count)"
        }
        self.updatePostsCountOnView()

        sizeHeaderToFit(minusHeight: temNameLabel.text == "" ? 35 : 0)
        if !isEditProfileNavigate{
            self.userTableView.reloadData()
        }

        activityScoreImageView.image = nil
        if let acitvityScore =  self.userProfile?.activityCount?.scoreFlag{
            activityScoreImageView.image = acitvityScore <= -1 ?  #imageLiteral(resourceName: "down1.png"):#imageLiteral(resourceName: "upTilted.png")
        }
        if let goalChallengesCount = self.userProfile?.goalAndChallengeCount{
            self.goalsChallengesCountLbl.text = "\(goalChallengesCount)"
        }
        //DispatchQueue.main.async {
        self.updateConnectionStatusButtonView()
        self.pausePlayVideo()
        //}
    }
    
    // MARK: Method is using to set the location content.
    func setLocationData(user:Friends? = nil) {
        
        var addressObj: Address?
        
        if let user = user {
            addressObj = user.address
        } else {
            addressObj = regiseterUser.address
        }
        locationLabel.text = "\(addressObj?.city ?? "") \(addressObj?.state ?? "")".trim
        var address = ""
        
        let city = addressObj?.city ?? ""
        let state = addressObj?.state ?? ""
        let gymName =  ""
        
        if city != "" {
            address = city.trimmed
        }
        if state != "" {
            address = address + ", " + state.trimmed
        }
        if(gymName != ""){
            if(address == ""){
                address =  gymName
            }else{
                address = address + " | " + gymName
            }
        }
        
        locationLabel.text =  address
    }
    
    func updatePostsCountOnView() {
        if let count = self.userProfile?.feedsCount {
            // postsCountLabel.text = "\(count )"
            //  postLbl.text = "posts"
        }
    }
    
    
    //This Function will calculate the height of the Grid collection View Cell
    
    func getUserPostCollectionViewHeight() -> CGFloat {
        var height:CGFloat = 0
        let (q,r) = userPosts.count.quotientAndRemainder(dividingBy: 4)
        let (q1,r1) = r.quotientAndRemainder(dividingBy: 2)
        height = CGFloat((q * 350) + (q1 * 210) + (r1 * 210) + 40)
        return height
    }
    // MARK: Set TableHeader According to Content Size.
    func sizeHeaderToFit(minusHeight:CGFloat = 0) {
        let headerView = userTableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        var frame = headerView.frame
        let stackHeightConstant: CGFloat = viewingMyOwnProfileAsOthers ? 28 : 0
        frame.size.height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height - minusHeight - ((otherUserId == nil || otherUserId == "") ? 88.0 : stackHeightConstant)
        headerView.frame = frame
        userTableView.tableHeaderView = headerView
    }
    
    private func getUnreadNotifcations() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count,id) in
            self.navigationBar.displayBadge(unreadCount: count)
        }
    }
    
    // MARK: AddRefreshController To TableView.
    private func addRefreshController() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(refreshPosts(sender:)) , for: .valueChanged)
        userTableView.addSubview(refreshControl)
    }
    
    // MARK: Function To Refresh Posts Tableview Data.
    @objc func refreshPosts(sender:AnyObject) {
        if selectedSection == .profile {
            refreshPostData()
        }
    }
    
    func handleNotification() {
        self.showLoader()
        self.refreshPostData()
    }
    
    func refreshPostData() {
        DispatchQueue.global(qos: .utility).async {
            // Update data
            // ......
            
            // Update the table view
            DispatchQueue.main.async {
                self.currentPage = 1
                self.previousPage = 1
                self.currentPageForSuggestedFriend = 1
                self.previousPageForSuggestedFriend = 1
                if Utility.isInternetAvailable(){
                    self.fetchUserData()
                }else {
                    self.refreshControl.endRefreshing()
                    self.hideLoader()
                    AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet)
                }
            }
        }
    }
    
    // MARK: Function hide keyboard on tableview scrolling.
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        endEditing()
    }
    
    func endEditing(){
        self.view.endEditing(true)
    }
    
    override func keyboardDisplayedWithHeight(value: CGRect) {
        self.currentPlayerIndex = nil
        self.previousPlayerIndex = nil
        self.removePlayer()
        
        print("keyboard height: \(value)")
        self.keyboardHeight = value.height
        //
        print("keyboardWillShow")
        //        if !keyboardVisible {
        //            keyboardVisible = true
        //        //    keyboardRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        //            // updateTextViewContentInset()
        //            print(keyboardRect)
        //            if self.view.frame.height == 724.0{
        //                textviewDisplayHeight = value.minY - 85
        //            }else{
        //                textviewDisplayHeight = value.minY - 72
        //            }
        //
        //            if let textviewTag = selectedTextViewTag{
        //
        //                let indexPath = IndexPath(row: textviewTag, section: 1)
        //                if let cell = userTableView.cellForRow(at: indexPath) as? ProfileTextViewCell{
        //                    print("Scroll enabled")
        //                    // cell.setInfo(info: cell.tvWhyAuPair.text)
        //                    //   cell.tvWhyAuPair.scrollToVisibleCaret(animated: false)
        //                    cell.accountabilityTextView.isScrollEnabled = true
        //                    cell.accountabilityTextView.becomeFirstResponder()
        //                    getTextviewData(cell.accountabilityTextView)
        //                    // cell.tvAboutMe.tvWhyAuPair = true
        //                }
        //                DispatchQueue.main.async {
        ////                    UIView.setAnimationsEnabled(false)
        ////                    self.userTableView.beginUpdates()
        ////                    self.userTableView.endUpdates()
        ////                    UIView.setAnimationsEnabled(true)
        //                    self.userTableView.reloadData()
        //                //    self.perform(#selector(self.scrollToRow), with: nil, afterDelay: 0.1)
        //                }
        //
        //            }
        //            // your code here
        //            print("Table begin update")
        //
        //
        //
        //        }
    }
    
    override func keyboardHide(height: CGFloat) {
        self.tagListContainerView.isHidden = true
        self.pausePlayVideo()
        
        print("keyboardWillHide")
        //        if keyboardVisible {
        //            print("keyboardWillHide1")
        //
        //            keyboardVisible = false
        //            //   updateTextViewContentInset()
        //
        //
        //            if let textviewTag = selectedTextViewTag{
        //
        //                let indexPath = IndexPath(row: textviewTag, section: 1)
        //                if let cell = userTableView.cellForRow(at: indexPath) as? ProfileTextViewCell{
        //                    cell.accountabilityTextView.isScrollEnabled = true
        //
        //                    // cell.setInfo(info: cell.tvWhyAuPair.text)
        //
        //                    getTextviewData(cell.accountabilityTextView)
        //                    // cell.tvAboutMe.tvWhyAuPair = true
        //                }
        //                DispatchQueue.main.async {
        //                    // your code here
        //                    print("Table begin update")
        ////                    UIView.setAnimationsEnabled(false)
        ////                    self.userTableView.beginUpdates()
        ////                    self.userTableView.endUpdates()
        ////                    UIView.setAnimationsEnabled(true)
        //                    self.userTableView.reloadData()
        //                }
        //                selectedTextViewTag = nil
        //            }
        //        }
    }
    
    // MARK: Helper functions
    func updateConnectionStatusButtonView() {
        if let user = self.userProfile,
            let friendStatus = user.friendStatus {
            self.connectionStatusButton?.setTitleColor(UIColor.white, for: .normal)
            switch friendStatus {
            case .connected:
                self.connectionStatusButton?.setTitleColor(UIColor.white, for: .normal)
                self.connectionStatusButton.backgroundColor = UIColor.clear
                self.connectionStatusButton.borderColor = UIColor.white
                self.connectionStatusButton.isEnabled = false
                self.connectionStatusButton.borderWidth = 1
            case .other, .requestReceived:
                self.connectionStatusButton.backgroundColor = UIColor.clear
                self.connectionStatusButton.isEnabled = true
                self.connectionStatusButton.borderWidth = 1
                self.connectionStatusButton.borderColor = UIColor.white
                
            case .requestSent:
                //                self.connectionStatusButton.backgroundColor = UIColor.lightGrayAppColor
                self.connectionStatusButton.setTitleColor(UIColor.lightGrayAppColor, for: .normal)
                self.connectionStatusButton.backgroundColor = UIColor.clear
                self.connectionStatusButton.borderWidth = 1
                self.connectionStatusButton.borderColor = UIColor.lightGrayAppColor
                self.connectionStatusButton.isEnabled = false
            case .blocked:
                self.connectionStatusButton.setTitleColor(UIColor.lightGrayAppColor, for: .normal)
                self.connectionStatusButton.backgroundColor = UIColor.clear
                self.connectionStatusButton.isEnabled = true
                self.connectionStatusButton.borderWidth = 1
                self.connectionStatusButton.borderColor = UIColor.lightGrayAppColor
            }
            self.connectionStatusButton.setTitle(friendStatus.title, for: .normal)
        }
    }
    
    override func fullScreenPreviewDidDismiss() {
        self.playVideo()
    }
    
    // MARK: Notification Observers
    private func addNotificationObservers() {
        self.removeNotificationObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewForNewPostUploaded(notification:)), name: Notification.Name.postUploaded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(isEditProfileNavigate(notification:)), name: Notification.Name.editProfileNavigate, object: nil)
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.postUploaded, object: nil)
        
        //         NotificationCenter.default.removeObserver(self, name: Notification.Name.editProfileNavigate, object: nil)
    }
    
    private func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeOnNotificationRead), name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeView), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    @objc func updateBadgeOnNotificationRead() {
        self.navigationBar.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
    }
    
    @objc func updateBadgeView() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count,id) in
            self.navigationBar.displayBadge(unreadCount: count)
        }
    }
    
    @objc func updateViewForNewPostUploaded(notification: Notification) {
        self.previousPage = 1
        self.currentPage = 1
        self.userTableView.setContentOffset(CGPoint.zero, animated: false)
        self.fetchUserData()
    }
    
    @objc func isEditProfileNavigate(notification: Notification) {
        print("<----Noitificaiton---->")
        isEditProfileNavigate = true
    }
    
    override func navigationBar(_ navigationBar: NavigationBar, rightButtonTapped rightButton: UIButton) {
        switch navigationBar.rightAction[rightButton.tag]  {
        case .addPost:
            //self.showYPPhotoGallery()
            self.showYPPhotoGallery(showCrop: false)
        case .filter:
            //SideMenuManager.default.menuWidth = self.view.frame.width/2+50
            let width = self.view.frame.width/2+50
            //.viewSlideInOut
            //viewSlideOutMenuIn
            self.presentSideMenuWith(menuPresentMode: .viewSlideOutMenuIn, screenType: .profileRightSideMenu, menuWidth: width, shadowColor: .gray)
            return
        case .search :
            let selectedVC:SearchViewController = UIStoryboard(storyboard: .search).initVC()
            self.navigationController?.pushViewController(selectedVC, animated: true)
        case .dot :
            if self.userProfile?.friendStatus == .connected {
                actionSheet = Utility.presentActionSheet(titleArray: [.message,.unfriend,.block,.cancel], titleColorArray: [UIColor.black,UIColor.black,UIColor.red,UIColor.gray], tag: 0,section: 0)
            }else if self.userProfile?.friendStatus == .blocked {
                actionSheet = Utility.presentActionSheet(titleArray: [.unBlock,.cancel], titleColorArray: [UIColor.gray,UIColor.gray], tag: 0,section: 0)
            }else{
                actionSheet = Utility.presentActionSheet(titleArray: [.block,.cancel], titleColorArray: [UIColor.red,UIColor.gray], tag: 0,section: 0)
            }
            actionSheet.delegate = self
        default:
            break
        }
    }
    
    override func  navigationBar(_ navigationBar: NavigationBar, titleLabelTapped titleLabel: UILabel) {
        self.redirectToDashBoard()
    }
    
    
    // MARK: TableViewDelegate
    override func setData(selectedData:ReportData,indexPath:IndexPath) {
        let index = indexPath.row
        if let desc = selectedData.desc , desc == 1 {
            addReportMessageView(index: index)
            return
        }
        reportPost(description:selectedData.title ?? "", id: selectedData.id ?? "", index: index)
        
    }
    
    func reportPost(description:String,id:String,index:Int) {
        if index >= self.userPosts.count {
            return
        }
        var obj = ReportPost()
        obj.id = id
        obj.description = description
        obj.postId = self.userPosts[index].id ?? ""
        self.showLoader()
        PostManager.shared.reportPost(parameters: obj.getDictionary(), success: { (message) in
            self.dotsButtonAction(indexPath: IndexPath(row: index, section: 0), type: .report)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    override func getReportMessage(decription: String,index:Int) {
        var categoryId = ""
        for (_,data) in Constant.reportHeadings.enumerated() {
            if data.desc ?? 0 == 1 {
                categoryId = data.id ?? ""
            }
        }
        reportPost(description:decription, id: categoryId, index: index)
    }
    
    // MARK: IBACtions.
    @IBAction func postsButtonTapped(_ sender: UIButton) {
        let postsVC: PostsViewController = UIStoryboard(storyboard: .profile).initVC()
        postsVC.userPosts = self.userPosts
        postsVC.userProfile = self.userProfile
        if let _ = self.otherUserId {
            postsVC.postLblTitle = viewPosts
        } else {
            postsVC.postLblTitle = myPosts
        }
        self.navigationController?.pushViewController(postsVC, animated: true)
    }
    func friendButtonRequest() {
        if let user = self.userProfile,
           let friendStatus = user.friendStatus {
            switch friendStatus {
            case .other:
                self.sendFriendRequest()
            case .requestReceived:
                self.acceptFriendRequest()
            case .blocked:
                self.unblockUser()
            case .connected:
                self.deleteFriend()
            default:
                break
            }
        }
    }
    
    @IBAction func connectionStatusButtonTapped(_ sender: UIButton) {
        guard isConnectedToNetwork() else {
            return
        }
        sender.isEnabled = false
        friendButtonRequest()
    }
    
    // MARK: Function Scroll To posts.
    @IBAction func postButtonTapped(_ sender: UIButton) {
        if !self.userPosts.isEmpty {
            self.userTableView.scrollToRow(at: IndexPath(row:0,section:0) , at: .top, animated: true)
        }
    }
    
    @IBAction func tematesCountTapped(_ sender: UIButton) {
        if viewingMyOwnProfileAsOthers {
            return
        }
        //push to temates view
        //check if current profile is of logged in user
        if let userId = self.otherUserId {
            // if the user is viewing someone's other profile
            //otherUserId will be nil if logged in user profile is viewed
            if let isPrivate = self.userProfile?.isPrivate,
                isPrivate == .yes {
                //user can't view the friends
                return
            }
            let friendsVC: UsersListingViewController = UIStoryboard(storyboard: .post).initVC()
            friendsVC.presenter = UsersListingPresenter(forScreenType: .othersTemates, id: userId)
            self.navigationController?.pushViewController(friendsVC, animated: true)
        } else {
            let tematesVC: NetworkViewController = UIStoryboard(storyboard: .network).initVC()
            tematesVC.isFromDashboard = false
            self.navigationController?.pushViewController(tematesVC, animated: true)
        }
    }
    
    // MARK: Action to view post in Grid and List Form.
    @IBAction func switchPostViewActions(_ sender: UIButton) {
        let postViewType = PostViewType(rawValue: sender.tag) ?? .grid
        resetData()
        if isGridView == true && postViewType == .grid || isGridView == false && postViewType == .list {
            return
        }
        //     gridButton.tintColor = .black
        //    listButton.tintColor = .black
        switch postViewType {
        case .grid: //For GridView.
            isGridView = true
            sender.tintColor = appThemeColor
            userTableView.reloadData()
            self.removePlayer()
        case .list: //For ListView.
            isGridView = false
            sender.tintColor = appThemeColor
            userTableView.reloadData()
            //playing video after table gets reloaded with the new data
            self.playVideo()
        }
    }
    
    // MARK: Segue Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostCommentFullView",
            let destination = segue.destination as? PostCommentAddTagContainerViewController {
            self.postCommentFullScreenVC = destination
            destination.delegate = self
        }
    }
    
    
    //============================
    func registerNotificationObservers() {
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func removeNotificationObservers1() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func scrollToRow(){
        self.userTableView.scrollToRow(at: IndexPath(row:0,section:1)  , at: .none, animated: false)
    }
    
    func createGradientView(view:GradientDashedLineCircularView){
        view.configureViewProperties(colors: [UIColor(red: 11.0 / 255.0, green: 249.0 / 255.0, blue: 243.0 / 255.0, alpha: 1), UIColor(red: 11.0 / 255.0, green: 249.0 / 255.0, blue: 243.0 / 255.0, alpha: 1)], gradientLocations: [0, 0])
        view.instanceWidth = 2.0
        view.instanceHeight = 3.0
        view.extraInstanceCount = 1
        view.lineColor = UIColor.gray
        view.updateGradientLocation(newLocations: [NSNumber(value: 0.00),NSNumber(value: 0.87)], addAnimation: false)
    }
    
    func createShadowViewNew(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor(red: 11.0 / 255.0, green: 130.0 / 255.0, blue: 220.0 / 255.0, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
    // MARK: Function to present bottom sheet for new goal amd challenge
    func startNewGoalAndChallenge() {
       let titleArray: [UserActions] = [.createGoal, .createChallenge, .cancel]
       let colorsArray: [UIColor] = [.gray, .gray, .gray]
       let customTitles: [String] = ["Goal", "Challenge", "Cancel"]
        self.actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: colorsArray, customTitles: customTitles, tag: 1)
       self.actionSheet.delegate = self
   }
    
}

// MARK: PostCommentAddTagContainerViewController
extension ProfileDashboardController: PostCommentAddTagDelegate {
    func updateCommentOnPost(indexPath: IndexPath, isDecrease: Bool, commentInfo: Comments) {
        self.UserActions(indexPath: indexPath, isDecrease: isDecrease, action: .comment, actionInformation: commentInfo)
    }
    
    func hideCommentView() {
        self.tagListContainerView.isHidden = true
    }
    
    func resetTableOffsetToBottom(indexPath: IndexPath) {
        let lastRow = (self.userPosts.count) - 1
        if indexPath.row == lastRow {
            self.userTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: EditProfileViewDelegate
extension ProfileDashboardController: EditProfileViewDelegate {
    func didEditProfileInformation(user: User) {
        //update the user information on this screen
        self.userProfile?.userName = user.userName
        self.userProfile?.firstName = user.firstName
        self.userProfile?.lastName = user.lastName
        self.userProfile?.address = user.address
        self.userProfile?.gym = user.gymAddress
        self.userProfile?.profilePic = user.profilePicUrl
        self.setInitialData()
    }
}

// MARK: PostTableVideoMediaDelegate
extension ProfileDashboardController: PostTableVideoMediaDelegate {
    func didDismissFullScreenPreview() {
        self.playVideo()
    }
    
    func mediaCollectionScrollDidEnd() {
        self.pausePlayVideo()
    }
    
    func didTapOnMuteButton(sender: CustomButton) {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            //set the reversed value
            Defaults.shared.set(value: !muteStatus, forKey: .muteStatus)
            //            updatePlayerSoundStatus()
        }
        self.updateMuteButtonOnChangingSoundStatus()
    }
    
    ///call this function whenevr the user changes the sound status of the video
    private func updateMuteButtonOnChangingSoundStatus() {
        //updating mute button on other rows as well
        guard let visibleTableCells = userTableView.visibleCells as? [PostTableCell] else {
            return
        }
        for tableCell in visibleTableCells {
            let firstVisibleCell = tableCell.mediaCollectionView.visibleCells.first
            guard let videoCell = firstVisibleCell as? GridCollectionCell else {
                continue
            }
            videoCell.setViewForMuteButton()
        }
    }
}

extension ProfileDashboardController {
    // MARK: VGPLayer Video player helpers
    ///initialize the VGPLayer and set current controller as its delegate
    func configurePlayer(view: UIView) {
        self.player = VGPlayer(parentViewFrame: view.frame)//VGPlayer()
        self.player.delegate = self
        self.player.displayView.delegate = self
    }
    
    /// add VGPlayer to the view passed as the cell
    func addPlayer(cell: GridCollectionCell, collectionItem: Int, tableRow: Int) {
        guard let url = self.userPosts[tableRow].media?[collectionItem].url else {
            return
        }
        self.removePlayer()
        //        self.configurePlayer()
        self.configurePlayer(view: cell.videoView)
        self.player.addTo(view: cell.videoView, url: url, previewUrl: self.userPosts[tableRow].media?[collectionItem].previewImageUrl)
        self.player.displayView.section = tableRow
        self.player.displayView.row = collectionItem
        updatePlayerSoundStatus()
    }
    
    /// remove the current player added to self
    func removePlayer() {
        if self.player != nil {
            self.player.remove()
            self.player = nil
            print("player removed")
        }
    }
    
    // MARK: Auto play - pause helpers
    private func playVideo() {
        self.currentPlayerIndex = nil
        self.previousPlayerIndex = nil
        self.pausePlayVideo()
    }
    
    /// call this function to handle the play and pause video for the visible table view cell
    private func pausePlayVideo() {
     /*  guard userPosts.count != 0 else {
            return
        }
        let visisbleCells = userTableView.visibleCells
        var mediaCollectionCell: GridCollectionCell?
        var maxHeight: CGFloat = 0.0
        
        //iterate through the table visible cells and get the maximum height visible
        for cellView in visisbleCells {
            
            if let containerCell = cellView as? PostTableCell,
                let indexPathOfFeedCell = userTableView.indexPath(for: containerCell) {
                
                let currentIndexOfCollection = Int(containerCell.mediaCollectionView.contentOffset.x / containerCell.mediaCollectionView.frame.width)
                let indexPathOfMediaCell = IndexPath(item: currentIndexOfCollection, section: 0)
                
                //print("index of current viisible item -------> \(indexPathOfMediaCell.item)")
                
                guard let collectionCell = containerCell.mediaCollectionView.cellForItem(at: indexPathOfMediaCell) as? GridCollectionCell,
                    let media = userPosts[indexPathOfFeedCell.row].media,
                    indexPathOfMediaCell.item < media.count,
                    self.userPosts[indexPathOfFeedCell.row].media?[indexPathOfMediaCell.item].type! == .video,
                    let _ = self.userPosts[indexPathOfFeedCell.row].media?[indexPathOfMediaCell.item].url else {
                        continue
                }
                
                let height = containerCell.visibleVideoHeight()
                //print("visible video view height of row: \(indexPathOfFeedCell.row)*********** \(height)")
                if maxHeight < height {
                    maxHeight = height
                    currentPlayerIndex = (indexPathOfFeedCell, indexPathOfMediaCell)
                    mediaCollectionCell = collectionCell
                }
            }
        }
        if maxHeight <= minVideoPlaySize {
            self.removePlayer()
            self.previousPlayerIndex = nil
            self.currentPlayerIndex = nil
        }
        guard let tableIndexPath = currentPlayerIndex?.tableIndexPath,
            let collectionIndexPath = currentPlayerIndex?.collectionIndexPath,
            self.userPosts[tableIndexPath.row].media?[collectionIndexPath.row].type! == .video else {
                return
        }
        
        //if maxheight is greater than minimum play size, play the video for this cell
        if maxHeight > minVideoPlaySize {
            if let lastTableIndex = previousPlayerIndex?.tableIndexPath,
                let lastCollectionIndex = previousPlayerIndex?.collectionIndexPath {
                if (lastTableIndex == tableIndexPath) && (collectionIndexPath == lastCollectionIndex) {
                    
                    let currentPlayingMediaUrl = self.userPosts[tableIndexPath.row].media?[collectionIndexPath.item].url ?? ""
                    //if current index media url is equal to the last playing then return else, add player with the new media url
                    if currentPlayingMediaUrl == lastPlayingMediaUrl {
                        //already playing video at this index
                        return
                    }
                }
            }
            if let mediaCollectionCell = mediaCollectionCell {
                self.addPlayer(cell: mediaCollectionCell, collectionItem: collectionIndexPath.item, tableRow: tableIndexPath.row)
                self.lastPlayingMediaUrl = self.userPosts[tableIndexPath.row].media?[collectionIndexPath.item].url ?? ""
                previousPlayerIndex = (tableIndexPath, collectionIndexPath)
            }
        }*/
    }
    
    func updatePlayerSoundStatus() {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            if self.player != nil {
                self.player.setSound(toValue: muteStatus)
            }
        }
    }
}

// MARK: VGPlayerDelegate
extension ProfileDashboardController: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        self.player.didChangeState()
        updatePlayerSoundStatus()
    }
}

// MARK: VGPlayerViewDelegate
extension ProfileDashboardController: VGPlayerViewDelegate {
    func didTapOnVGPlayerView(_ playerView: VGPlayerView) {
        //present the full screen preview
        
        if let tableRow = playerView.section,
            let collectionItem = playerView.row {
            let indexPathTable = IndexPath(row: tableRow, section: 0)
            if let tableCell = self.userTableView.cellForRow(at: indexPathTable) as? PostTableCell,
                let collection = tableCell.mediaCollectionView {
                self.presentFullScreenPreview(forPost: self.userPosts[tableRow], atIndex: collectionItem, collectionView: collection, currentDuration: self.player.currentDuration)
                self.removePlayer()
            }
        }
    }
}

// MARK: UIScrollViewDelegate
extension ProfileDashboardController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if selectedSection == .profile || selectedSection == .other {
            if scrollView == userTableView {
                if !decelerate {
                    self.pausePlayVideo()
                }
                if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                    if previousPage < currentPage {
                        previousPage = currentPage
                        self.userTableView.tableFooterView = Utility.getPagingSpinner()
                        fetchUserData()
                    }
                }
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pausePlayVideo()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
        if selectedSection == .profile || selectedSection == .other {
            if scrollView.contentOffset.y < -150 { //change 80 to whatever you want
                UIView.performWithoutAnimation {
                    if isRefresh {
                        isRefresh = false
                        refreshPostData()
                    }
                    self.userTableView.restore()
                }
            }
        }
    }
}

extension ProfileDashboardController: HaisDelegate {
    func onClickOfPanel(isSelected: Bool) {
        print(isSelected)
        if !isSelected{
            haisViewheight = 2000
        } else {
            haisViewheight = 1600
        }
        UIView.transition(with: userTableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.userTableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                UIView.transition(with: self.userTableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.userTableView.reloadData()
                }, completion: nil)
            }
        }, completion: nil)
    }
}

extension ProfileDashboardController: NetworkSearchDelegate {
    func getHeight(_ height:CGFloat) {
        temHeight = height
        UIView.transition(with: userTableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.userTableView.reloadData()
        }, completion: nil)
    }
    
}
