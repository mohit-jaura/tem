//
//  FeedsViewController.swift
//  TemApp
//
//  Created by shilpa on 15/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Kingfisher
import MediaPlayer
import Alamofire
import IQKeyboardManagerSwift
import SSNeumorphicView

//import JPVideoPlayer

enum FeedSections: Int, CaseIterable {
    case Progress = 0
    case Feeds = 1
}

class FeedsViewController: DIBaseController {
    
    
    // MARK: IBOutlets
    @IBOutlet weak var tagListContainerView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newPostsButton: UIButton!
    @IBOutlet weak var newPostsButtonShadowView: UIView!
    @IBOutlet weak var tagListBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarLineView: SSNeumorphicView! {
        didSet{
            navigationBarLineView.viewDepthType = .outerShadow
            navigationBarLineView.viewNeumorphicMainColor = UIColor.white.cgColor
            navigationBarLineView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            navigationBarLineView.viewNeumorphicDarkShadowColor = UIColor.newAppThemeColor.cgColor
            navigationBarLineView.viewNeumorphicCornerRadius = 0
        }
    }
    
    
    // MARK: Properties
    var postCommentFullScreenVC: PostCommentAddTagContainerViewController?
    var tabBarHeight: CGFloat {
        if tabBarController?.tabBar.isHidden ?? true { return 0 }
        return tabBarController?.tabBar.bounds.size.height ?? 0
    }
    var keyboardSize: CGFloat = 0
    var screenType: Constant.ScreenFrom = .newsFeeds
    var searchText:String?
    let feedsDataProvider = FeedsDataProvider()
    private var isCallFeedsData = false
    private var minVideoPlaySize: CGFloat = 125.0
    var collectionOffsets: [Int: CGPoint] = [:]
    private var previousPage:Int = 1
    private var currentPage:Int = 1
    var previousPageForSuggestedFriend:Int = 1
    var currentPageForSuggestedFriend:Int = 1
    var posts:[Post]?
    var inProgressPosts:[Post]?
    var actionSheet = CustomBottomSheet()
    private var postsCount = 0
    var freindsSuggestion = [Friends]()
    var isResponse = false
    var refreshControl: UIRefreshControl!
    
    var navBar: NavigationBar?
    
    //
    private var reachabilityManager: NetworkReachabilityManager?
    private var showInternetErrorLabel:Bool? = false
    //VGPlayer
    var player : VGPlayer!
    //Will keep track of the index paths of currently playing player view
    private var currentPlayerIndex: (tableIndexPath: IndexPath?, collectionIndexPath: IndexPath?)?
    //will keep track of the index paths of last played player view
    private var previousPlayerIndex: (tableIndexPath: IndexPath?, collectionIndexPath: IndexPath?)?
    //will keep track of the last url being played in the player view
    private var lastPlayingMediaUrl: String?
    private var pageNumber = 1
    var tagUsersListController: TagUsersListViewController?
    
    var activeTextView: UITextView?
    
    //this variable will store the posts array of page number 1 whenever the new data arrives. After appending it to the original data source this will be set to nil
    private var newPosts: [Post]? {
        didSet {
            if let tempPosts = self.newPosts,
                !tempPosts.isEmpty {
                if screenType == .newsFeeds {
                    self.newPostsButtonShadowView.isHidden = false
                    self.newPostsButton.isHidden = false
                }else{
                    self.newPostsButtonShadowView.isHidden = true
                    self.newPostsButton.isHidden = true
                }
            } else {
                self.newPostsButtonShadowView.isHidden = true
                self.newPostsButton.isHidden = true
            }
        }
    }
    private var storeTemporarily = false
    
    // MARK: IBActions
    @IBAction func newPostsTapped(_ sender: UIButton) {
        //replace the current posts array with the new posts data
        self.previousPage = 1
        self.posts?.removeAll()
        if let newPostsData = self.newPosts {
            self.posts?.append(contentsOf: newPostsData)
        }
        self.newPosts?.removeAll()
        self.newPosts = nil
        self.tableView.reloadData()
        
        
        let firstRowIndexPath = IndexPath(row: 0, section: FeedSections.Feeds.rawValue)
        //scroll tableview to top
        self.tableView.scrollToRow(at: firstRowIndexPath, at: .top, animated: true)
        //saving data offline
        if let posts = self.posts {
            self.feedsDataProvider.savePostsOffline(posts: posts)
        }
        self.currentPage = 2
    }
    
    @IBAction func backTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addPostTapped(_ sender:UIButton){
        let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()
        createPostVC.isForCreatePost = true
        self.navigationController?.pushViewController(createPostVC, animated: true)
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
        self.tableView.backgroundColor = .clear
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setIQKeyboard(enable: false)
        //self.listenVolumeButton()
        NotificationCenter.default.addObserver(self, selector: #selector(outputVolumeChanged), name: Notification.Name.outputVolumeChanged, object: nil)
        self.playVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addBadgeObserver()
        self.addReachabilityObserver()
        self.addKeyboardNotificationObservers()
        self.updateBadgeViewOnReadNotification()
      //  self.getUnreadNotifcations()
        if isCallFeedsData {
            currentPage = 1
            previousPage = 1
            currentPageForSuggestedFriend = 1
            previousPageForSuggestedFriend = 1
            getFeeds()
        }else{
            isCallFeedsData = true
        }
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: false, controller: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotificationObservers()
        //self.removeVolumeListeners()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.outputVolumeChanged, object: nil)
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeBadgeObserver()
        setIQKeyboard(enable: true)
        //self.removeNotificationObservers()
        self.removePlayer()
    }
    
    private func setIQKeyboard(enable: Bool) {
        IQKeyboardManager.shared.enable = enable//true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = enable
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    // MARK: Server Call
    @objc func getUnreadNotifcations() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count,id) in
            DispatchQueue.main.async {
                self.navBar?.displayBadge(unreadCount: count)
            }
        }
    }
    
    private func getFeeds() {
        guard Reachability.isConnectedToNetwork() else {
            self.tableView.tableFooterView = UIView()
            self.updateViewWithError(error: AppMessages.AlertTitles.noInternet)
            self.refreshControl.endRefreshing()
            return
        }
        switch screenType {
        case .newsFeeds :
            PostManager.shared.getFeeds(atPage: self.currentPage, completion: {[weak self] (posts) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.isResponse = true
                    self.tableView.tableFooterView = UIView()
                    self.refreshControl.endRefreshing()
                    if posts.count <= 0 {
                        self.getUserSuggestion(pagenumber: self.previousPageForSuggestedFriend)
                        return
                    }
                    self.setDataSourceWith(posts: posts, currentPage: self.currentPage)
                    if posts.count >= 15 {
                        self.currentPage += 1
                    }

                }
            }) { (error) in
                self.updateViewWithError(error: error.message)
            }
        default:
            break
        }
    }
    
    
    // MARK: Fetch User Suggestions.
    func getUserSuggestion(pagenumber:Int) {
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
                self.tableView.hideSkeleton()
                self.tableView.reloadData()
                
            }
        }) { (error) in
            self.tableView.hideSkeleton()
            self.showAlert(message:error.message)
        }
    }
    
    // MARK: Set Navigation
    func configureNavigation() {
        if screenType == .newsFeeds {
            self.navBar = configureNavigtion(onView: navigationBarView, title: AppMessages.AppSpecific.appName, leftButtonAction: .back1, rightButtonAction: [.addPost],backgroundColor: .white,showBottomSeparator: true)
            self.navBar?.titleLabel.shadowOffset = CGSize(width: 2, height: 2)
            self.navBar?.titleLabel.shadowColor = .lightGrayAppColor
            self.navBar?.titleLabel.textColor = .appThemeColor
        }else{
            _ = configureNavigtion(onView: navigationBarView, title: AppMessages.AppSpecific.appName)
        }
        
    }
    
    // MARK: Interenet Connection observer......
    //
    private func addReachabilityObserver() {
        self.reachabilityManager = NetworkReachabilityManager()
        self.reachabilityManager?.startListening()
        self.reachabilityManager?.listener = { _ in
            if Reachability.isConnectedToNetwork() {
               self.showInternetErrorLabel = false
               self.reloadTableView()
            } else {
               self.showInternetErrorLabel = true
               self.reloadTableView()
            }
            
        }
    }
    
    private func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.layoutIfNeeded()
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
    }
    private func removeReachabiltyObserever() {
        guard self.reachabilityManager != nil else {
            return
        }
        self.reachabilityManager?.stopListening()
    }
    //End...
    
    // MARK: Notification Observers
    private func addNotificationObservers() {
        self.removeNotificationObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(addNewPostToExisting(notification:)), name: Notification.Name.postUploaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNewFeedInProgressView(notification:)), name: Notification.Name.postUploadInProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelPostUploadingOnError(notification:)), name: Notification.Name.postUploadingError, object: nil)
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.postUploaded, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.postUploadInProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.postUploadingError, object: nil)
    }
    
    private func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeViewOnReadNotification), name: Notification.Name.notificationChange, object: nil)
      //  NotificationCenter.default.addObserver(self, selector: #selector(getUnreadNotifcations), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }
    
    // MARK: Helpers
    @objc func updateBadgeViewOnReadNotification() {
        self.navBar?.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
    }
    
    private func initialize() {
        UserDefaults().setValue(Constant.ScreenSize.SCREEN_WIDTH, forKey: "Height")
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
  //      configureNavigation()
        self.setUpTagListContainer()
        self.addNotificationObservers()
        self.addRefreshController()
        self.tableView.registerNibs(nibNames: [PostTableCell.reuseIdentifier, PostUploadingProgressTableViewCell.reuseIdentifier])
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 288
        self.tableView.estimatedSectionHeaderHeight = 140.0
        self.tableView.isSkeletonable = true
        self.getUploadingPostsOfUser()
        self.setInitialScreenView()

    }
    
  
    
    private func setUpTagListContainer() {
        self.tagListContainerView.isHidden = true
    }
    
    private func setViewWithNewPostsButtonOnTop() {
        if let tempPosts = self.newPosts,
            !tempPosts.isEmpty {
            if screenType == .newsFeeds {
                self.newPostsButton.isHidden = false
            }else{
                self.newPostsButton.isHidden = true
            }
        } else {
            self.newPostsButton.isHidden = true
        }
    }
    
    override func  navigationBar(_ navigationBar: NavigationBar, titleLabelTapped titleLabel: UILabel) {
        self.tabBarController?.selectedIndex = 0
    }
    
    // MARK: AddRefreshController To TableView.
    private func addRefreshController() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(refreshPosts(sender:)) , for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: Function To Refresh Posts Tableview Data.
    @objc func refreshPosts(sender:AnyObject) {
        currentPage = 1
        previousPage = 1
        currentPageForSuggestedFriend = 1
        previousPageForSuggestedFriend = 1
        if Utility.isInternetAvailable(){
            getFeeds()
        }else {
            refreshControl.endRefreshing()
            AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet)
        }
    }
    private func setInitialScreenView() {
        currentPage = 1
        previousPage = 1
        // self.setViewWithNewPostsButtonOnTop()
        //check if there is some data saved offline in core data
        switch screenType {
        case .newsFeeds :
            self.tableView.showAnimatedSkeleton()
            self.feedsDataProvider.getOfflineSavedPosts(completion: {[weak self] (posts) in
                print("got the offline saved data")
                self?.processOfflineFeeds(posts: posts)
                }, failure: {(error) in
                    //fetch the new data from server and show it on screen
                    self.getFeeds()
            })
        default:
            break
        }
    }
    
    private func processOfflineFeeds(posts: [Post]) {
        if !posts.isEmpty {
            //there is some offline data already saved -> show it on the screen to user
            self.setDataSourceWith(posts: posts, offlineSaved: true, currentPage: self.currentPage)
            storeTemporarily = true
        } else {
            storeTemporarily = false
//            self.tableView.showAnimatedSkeleton()
        }
        self.getFeeds()
    }
    
    private func getUploadingPostsOfUser() {
        guard self.screenType == .newsFeeds else {
            return
        }
        // get the posts which are currently uploading to the server
        self.feedsDataProvider.getInProgressUploadingPosts(completion: {[weak self] (posts) in
            self?.inProgressPosts = [Post]()
            self?.inProgressPosts?.append(contentsOf: posts)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.tableView.layoutIfNeeded()
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
        }) { (_) in
            
        }
    }
    
    @objc func addNewPostToExisting(notification: Notification) {
        guard let newPost = notification.object as? Post else {
            return
        }
        self.inProgressPosts?.removeAll(where: { (post) -> Bool in
            return post.tempId == newPost.tempId
        })
        if self.posts == nil {
            self.posts = [Post]()
        }
        self.posts?.insert(newPost, at: 0)
        self.tableView.reloadData()
       
    }
    
    @objc func cancelPostUploadingOnError(notification: Notification) {
        guard let newPost = notification.object as? Post else {
            return
        }
        self.inProgressPosts?.removeAll(where: { (post) -> Bool in
            return post.tempId == newPost.tempId
        })
        if self.posts == nil {
            self.posts = [Post]()
        }
        self.tableView.reloadData()
       
        self.showAlert(message: ErrorMessage.Post.cannotUpload)
    }

    @objc func updateNewFeedInProgressView(notification: Notification) {
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: false, controller: self)
        }
        guard let newPost = notification.object as? Post else {
            return
        }
        if self.inProgressPosts == nil {
            self.inProgressPosts = [Post]()
        }
        self.inProgressPosts?.append(newPost)
        self.tableView.reloadData()
        
        self.playVideo()
    }
    
    //this function deals with setting the data source values. It will hold the posts array from server as well as from offline
    private func setDataSourceWith(posts: [Post], offlineSaved: Bool? = false, currentPage: Int) {
        self.tableView.restore()
        self.tableView.hideSkeleton()
        guard storeTemporarily == false else {
            self.storeTemporarily = false
            if self.newPosts == nil {
                self.newPosts = [Post]()
            }
            self.newPosts?.removeAll()
            self.newPosts?.append(contentsOf: posts)
            if self.isFirstFeedVisible() {
                //if the table view is on top, then refresh the listing, otherwise return
                self.newPostsButtonShadowView.isHidden = true
                self.newPostsButton.isHidden = true
                self.setDataSourceWith(posts: posts, currentPage: currentPage)
                return
            }
            return
        }
        if self.posts == nil {
            self.posts = [Post]()
        }
        if currentPage == 1 {
            //save offline first page
            //if this is not already saved offline, then save it otherwise, skip the process
            if screenType == .newsFeeds,
                !offlineSaved! {
                self.feedsDataProvider.savePostsOffline(posts: posts)
            }
            self.posts?.removeAll()
        }
        self.postsCount = posts.count
        self.posts?.append(contentsOf: posts)
        self.updateFeedsListing()
    }
    
    private func isFirstFeedVisible() -> Bool {
        if let cell = tableView.visibleCells.first,
            let indexPath = tableView.indexPath(for: cell) {
            //if this is the first cell visible currently on the tableview
            if indexPath.row == 0 {
                return true
            }
        }
        return false
    }
    
    private func updateFeedsListing() {
        DispatchQueue.main.async {
           // self.tableView.hideSkeleton()
            self.tableView.endPull2RefreshAndInfiniteScrolling(count: self.postsCount)
            self.tableView.reloadData()
            
        }
        self.pausePlayVideo()
    }
    
    //call this function in case of any error in api call
    private func updateViewWithError(error: String?) {
        //decrement page number value
        self.tableView.hideSkeleton()
        tableView.endPull2RefreshAndInfiniteScrolling(count: 0)
        if self.posts == nil || self.posts?.count == 0 {
            //if there was no data, show tableview background view
            self.tableView.showEmptyScreen(error ?? AppMessages.Post.errorFetchingNewsFeeds, isWhiteBackground: false)
        } else {
            //show alert pop up to the user
            self.showAlert(message: error ?? AppMessages.Post.errorFetchingNewsFeeds)
        }
    }
    
    @objc func outputVolumeChanged() {
        print("output volume changed in news feed")
        self.updateMuteButtonOnChangingSoundStatus()
        self.updatePlayerSoundStatus()
    }
    
    func updatePlayerSoundStatus() {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            if self.player != nil {
                self.player.setSound(toValue: muteStatus)
            }
        }
    }
    
    override func fullScreenPreviewDidDismiss() {
        self.playVideo()
    }
    
    // MARK: VGPLayer Video player helpers
    ///initialize the VGPLayer and set current controller as its delegate
    func configurePlayer(view: UIView) {
        self.player = VGPlayer(parentViewFrame: view.frame)//VGPlayer()
        self.player.delegate = self
        self.player.displayView.delegate = self
    }
    
    /// add VGPlayer to the view passed as the cell
    func addPlayer(cell: GridCollectionCell, collectionItem: Int, tableRow: Int) {
        guard let url = self.posts?[tableRow].media?[collectionItem].url else {
            return
        }
        self.removePlayer()
        self.configurePlayer(view: cell.videoView)
        self.player.addTo(view: cell.videoView, url: url, previewUrl: self.posts?[tableRow].media?[collectionItem].previewImageUrl)
        //setting the unique tag of player display view
        self.player.displayView.section = tableRow
        self.player.displayView.row = collectionItem
        updatePlayerSoundStatus()
    }
    
    /// remove the current player added to self
    func removePlayer() {
        if self.player != nil {
            self.player.remove()
            self.player = nil
        }
    }
    
    // MARK: Auto play - pause helpers
     func playVideo() {
        self.previousPlayerIndex = nil
        self.currentPlayerIndex = nil
        self.pausePlayVideo()
    }
    
    /// call this function to handle the play and pause video for the visible table view cell
     func pausePlayVideo() {
        guard posts?.count != 0 else {
            return
        }
        let visisbleCells = tableView.visibleCells
        var mediaCollectionCell: GridCollectionCell?
        var maxHeight: CGFloat = 0.0
        
        //iterate through the table visible cells and get the maximum height visible
        for cellView in visisbleCells {
            
            if let containerCell = cellView as? PostTableCell,
                let indexPathOfFeedCell = tableView.indexPath(for: containerCell) {
                var width = containerCell.mediaCollectionView.frame.width
                if width == 0.0{
                    width = 0.1
                }
                let currentIndexOfCollection = Int(containerCell.mediaCollectionView.contentOffset.x / width)
                let indexPathOfMediaCell = IndexPath(item: currentIndexOfCollection, section: 0)
                guard let collectionCell = containerCell.mediaCollectionView.cellForItem(at: indexPathOfMediaCell) as? GridCollectionCell,
                    indexPathOfFeedCell.row < self.posts!.count,//safe checking
                    let media = self.posts?[indexPathOfFeedCell.row].media,
                    indexPathOfMediaCell.item < media.count,
                    self.posts?[indexPathOfFeedCell.row].media?[indexPathOfMediaCell.item].type! == .video,
                    let _ = self.posts?[indexPathOfFeedCell.row].media?[indexPathOfMediaCell.item].url else {
                        continue
                }
                
                let height = containerCell.visibleVideoHeight()
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
            self.posts?[tableIndexPath.row].media?[collectionIndexPath.row].type! == .video else {
                return
        }
        
        //if maxheight is greater than minimum play size, play the video for this cell
        if maxHeight > minVideoPlaySize {
            if let lastTableIndex = previousPlayerIndex?.tableIndexPath,
                let lastCollectionIndex = previousPlayerIndex?.collectionIndexPath {
                if (lastTableIndex == tableIndexPath) && (collectionIndexPath == lastCollectionIndex) {
                    
                    let currentPlayingMediaUrl = self.posts?[tableIndexPath.row].media?[collectionIndexPath.item].url ?? ""
                    //if current index media url is equal to the last playing then return else, add player with the new media url
                    if currentPlayingMediaUrl == lastPlayingMediaUrl {
                        //already playing video at this index
                        return
                    }
                }
            }
            if let mediaCollectionCell = mediaCollectionCell {
                print("add player called")
                self.addPlayer(cell: mediaCollectionCell, collectionItem: collectionIndexPath.item, tableRow: tableIndexPath.row)
                self.lastPlayingMediaUrl = self.posts?[tableIndexPath.row].media?[collectionIndexPath.item].url ?? ""
                previousPlayerIndex = (tableIndexPath, collectionIndexPath)
            }
        }
    }
    
    ///call this function whenevr the user changes the sound status of the video
    private func updateMuteButtonOnChangingSoundStatus() {
        //updating mute button on other rows as well
        guard let visibleTableCells = tableView.visibleCells as? [PostTableCell] else {
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
        if index >= self.posts?.count ?? 0 {
            return
        }
        var obj = ReportPost()
        obj.id = id
        obj.description = description
        obj.postId = self.posts?[index].id ?? ""
        self.showLoader()
        PostManager.shared.reportPost(parameters: obj.getDictionary(), success: { (message) in
            self.dotsButtonAction(indexPath:IndexPath(row: index, section: 0), type: .report)
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
    
    override func navigationBar(_ navigationBar: NavigationBar, rightButtonTapped rightButton: UIButton) {
        switch navigationBar.rightAction[rightButton.tag]  {
        case .addPost:
            //self.showYPPhotoGallery()
            self.showYPPhotoGallery(showCrop: false)
        case .search :
            let selectedVC:SearchViewController = UIStoryboard(storyboard: .search).initVC()
            self.navigationController?.pushViewController(selectedVC, animated: true)
        default:
            break
        }
    }
    
    // MARK: Keyboard observers
    override func keyboardDisplayedWithHeight(value: CGRect) {
        self.keyboardSize = value.height
        self.currentPlayerIndex = nil
        self.previousPlayerIndex = nil
        self.removePlayer()
        
        var safeArea: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            // Fallback on earlier versions
        }
        var constraintValue = self.keyboardSize - safeArea
        if self.tabBarHeight != 0 {
            constraintValue = constraintValue - self.tabBarHeight + safeArea
        }
        self.tagListBottomConstraint.constant = constraintValue
    }
    
    override func keyboardHide(height: CGFloat) {
        self.tagListContainerView.isHidden = true
        self.pausePlayVideo()
    }
    
    // MARK: Segue Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostCommentFullView",
            let destination = segue.destination as? PostCommentAddTagContainerViewController {
            self.postCommentFullScreenVC = destination
            destination.delegate = self
        }
    }
}

// MARK: PostCommentAddTagContainerViewController
extension FeedsViewController: PostCommentAddTagDelegate {
    func resetTableOffsetToBottom(indexPath: IndexPath) {
        let lastRow = (self.posts?.count ?? 1) - 1
        if indexPath.row == lastRow {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func updateCommentOnPost(indexPath: IndexPath, isDecrease: Bool, commentInfo: Comments) {
        self.UserActions(indexPath: indexPath, isDecrease: isDecrease, action: .comment, actionInformation: commentInfo)
    }
    
    func hideCommentView() {
        self.tagListContainerView.isHidden = true
    }
}

// MARK: UITableViewDataSource.....

extension FeedsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FeedSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = FeedSections(rawValue: section) {
            switch currentSection {
            case .Progress:
                return self.inProgressPosts?.count ?? 0
            case .Feeds:
                if self.posts?.count ?? 0 == 0 {
                    if self.freindsSuggestion.count == 0 {
                        return 0
                    }
                    return 1
                }
                return self.posts?.count ?? 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = FeedSections(rawValue: indexPath.section) {
            switch currentSection {
            case .Progress:
                return cellForInProgressPosts(tableView, atIndexPath: indexPath)
            case .Feeds:
                if self.posts?.count ?? 0 == 0 {
                    guard let cell:SuggestionTableCell = tableView.dequeueReusableCell(withIdentifier: SuggestionTableCell.reuseIdentifier, for: indexPath) as? SuggestionTableCell else {
                        return UITableViewCell()
                    }
                    cell.delegate = self
                    cell.suggestionList = self.freindsSuggestion
                    cell.suggestionCollectionView.reloadData()
                    return cell
                }
                guard let cell:PostTableCell = tableView.dequeueReusableCell(withIdentifier: PostTableCell.reuseIdentifier, for: indexPath) as? PostTableCell else {
                    return UITableViewCell()
                }
               
                cell.postTableVideoMediaDelegate = self
                cell.actionDelegate = self
                cell.isReadMoreShow = true
                cell.postButton.tag = indexPath.row
                //cell.mediaCollectionHeightConstraint.constant = 250
                if indexPath.row < self.posts?.count ?? 0 {
                    if screenType == .newsFeeds {
                        if  self.posts![indexPath.row].user?.id != User.sharedInstance.id {
                            self.posts![indexPath.row].user?.friendStatus = .connected
                        }
                    }
                    cell.setData(post: self.posts![indexPath.row], atIndexPath: indexPath, user: self.posts![indexPath.row].user ?? Friends(),isFromFeed:true)
                    cell.setContentOffset(contentOffset: self.collectionOffsets[indexPath.row] ?? CGPoint.zero)
//                    if let media = self.posts![indexPath.row].media,
//                        let height = media.first?.height,
//                        height != 0 {
//                        cell.mediaCollectionHeightConstraint.constant = CGFloat(height)
//                    } else {
//                        cell.mediaCollectionHeightConstraint.constant = 250
//                    }
                }
                cell.spaceViewHeightConstraint.constant = 5
                cell.delegate = self
                cell.redirectPostDelegate = self
                cell.layoutIfNeeded()
                return cell
            }
        }
        return UITableViewCell()
        
    }
    
    // returning the cell with progress indicator
    func cellForInProgressPosts(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostUploadingProgressTableViewCell.reuseIdentifier, for: indexPath) as? PostUploadingProgressTableViewCell else {
            return UITableViewCell()
        }
        if let inProgressPosts = self.inProgressPosts {
            cell.setDataWith(post: inProgressPosts[indexPath.row],showErrorLabel: self.showInternetErrorLabel!)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension FeedsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //remove player if the cell playing the video goes offscreen
        if self.player != nil,
            self.player.state == .playing,
            let currentPlayIndex = self.currentPlayerIndex?.tableIndexPath,
            currentPlayIndex == indexPath {
            print("------------------ didEndDisplaying \(indexPath.row)------------------")
            self.removePlayer()
            
        }
        //stop cell animation when cell goes off screen
        if let currentSection = FeedSections(rawValue: indexPath.section),
            currentSection == .Progress {
            if let cell = cell as? PostUploadingProgressTableViewCell {
                cell.stopAnimation()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isResponse {
            if let currentSection = FeedSections(rawValue: section) {
                switch currentSection {
                case .Progress:
                    return UIView()
                case .Feeds:
                    /*if self.posts?.count ?? 0 == 0 && self.freindsSuggestion.count > 0{
                        let headerView = Bundle.main.loadNibNamed(MessageView.reuseIdentifier, owner: self, options: nil)?.first as? MessageView
                        return headerView
                    } */
                    if self.posts?.count ?? 0 == 0 {
                        let headerView = Bundle.main.loadNibNamed(MessageView.reuseIdentifier, owner: self, options: nil)?.first as? MessageView
                        if self.freindsSuggestion.count > 0 {
                            return headerView
                        } else {
                            headerView?.titleLabel.text = ""
                            tableView.showCenterBackgroundView(view: headerView ?? UIView(),isTabBar: true, centerY: tableView.tableHeaderView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height ?? 500)
                            return headerView
                        }
                    }
                }
            }
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection = FeedSections(rawValue: section) {
            switch currentSection {
            case .Progress:
                return 0
            case .Feeds:
                if self.posts?.count ?? 0 == 0 {
                    return UITableView.automaticDimension
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if self.posts?.isEmpty == false,
//            cell.isSkeletonActive {
//            cell.hideSkeleton()
//        }
        if let currentSection = FeedSections(rawValue: indexPath.section) {
            switch currentSection {
            case .Progress:
                if let cell = cell as? PostUploadingProgressTableViewCell {
                    cell.startAnimation()
                }
            default:
                return
            }
        }
    }
    
}

// MARK: SkeletonTableViewDataSource
extension FeedsViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PostTableCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

// MARK: UITableViewDataSourcePrefetching
extension FeedsViewController: UITableViewDataSourcePrefetching {
    // Check this
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        /*guard let _ = self.posts else {
         return
         }
         var urls: [URL] = []
         for indexPath in indexPaths {
         if let post = self.posts?[indexPath.row],
         let media = post.media,
         media.isEmpty {
         continue
         }
         let url = self.posts?[indexPath.row].media?.first?.previewImageUrl ?? ""
         urls.append(URL(string: url)!)
         }
         ImagePrefetcher(urls: urls).start() */
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        /*guard let _ = self.posts else {
         return
         }
         var urls: [URL] = []
         for indexPath in indexPaths {
         //safe indexing
         if let post = self.posts?[indexPath.row],
         let media = post.media,
         media.isEmpty {
         continue
         }
         let url = self.posts?[indexPath.row].media?.first?.previewImageUrl ?? ""
         urls.append(URL(string: url)!)
         }
         ImagePrefetcher(urls: urls).stop() */
    }
}

// MARK: VGPlayerDelegate
extension FeedsViewController: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        self.player.didChangeState()
        updatePlayerSoundStatus()
    }
}

// MARK: VGPlayerViewDelegate
extension FeedsViewController: VGPlayerViewDelegate {
    func didTapOnVGPlayerView(_ playerView: VGPlayerView) {
        //present the full screen preview
        
        if let tableRow = playerView.section,
            let post = self.posts?[tableRow],
            let collectionItem = playerView.row {
            let indexPathTable = IndexPath(row: tableRow, section: FeedSections.Feeds.rawValue)
            if let tableCell = tableView.cellForRow(at: indexPathTable) as? PostTableCell,
                let collection = tableCell.mediaCollectionView {
                self.presentFullScreenPreview(forPost: post, atIndex: collectionItem, collectionView: collection, currentDuration: self.player.currentDuration)
                self.removePlayer()
            }
        }
    }
}

// MARK: UIScrollViewDelegate
extension FeedsViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pausePlayVideo()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tableView {
            if !decelerate {
                self.pausePlayVideo()
            }
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                
                if previousPage < currentPage {
                    previousPage = currentPage
                    self.tableView.tableFooterView = Utility.getPagingSpinner()
                    getFeeds()
                }
            }
        }
    }
}

// MARK: NewsFeedTableCellDelegate
extension FeedsViewController: PostTableVideoMediaDelegate {
    func didDismissFullScreenPreview() {
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: false, controller: self)
        }
        self.fullScreenPreviewDidDismiss()
    }
    
    func didTapOnMuteButton(sender: CustomButton) {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            //set the reversed value
            Defaults.shared.set(value: !muteStatus, forKey: .muteStatus)
            updatePlayerSoundStatus()
        }
        self.updateMuteButtonOnChangingSoundStatus()
    }
    
    func collectionViewDidScroll(newContentOffset: CGPoint, scrollView: UIScrollView) {
        self.collectionOffsets[scrollView.tag] = newContentOffset
    }
    
    func mediaCollectionScrollDidEnd(){
        self.pausePlayVideo()
    }
}


extension FeedsViewController: ViewPostDetailDelegate {
    func redirectToPostDetail(indexPath : IndexPath) {
        let controller : PostDetailController = UIStoryboard(storyboard: .profile).initVC()
        controller.post = self.posts?[indexPath.row]
        controller.indexPath = indexPath
        controller.user = self.posts?[indexPath.row].user
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
}



extension FeedsViewController : PostDetailDotsDelegate {
    func dotsButtonAction(indexPath: IndexPath, type: UserActions) {
        self.hideLoader()
        switch type {
        case .delete:
            self.posts?.remove(at: indexPath.row)
            if self.posts?.count == 0 {
                self.getUserSuggestion(pagenumber: self.previousPageForSuggestedFriend)
            }
            self.tableView.reloadData()
            
        case .unfriend:
            self.posts = self.posts?.filter { $0.user?.id != self.posts?[indexPath.row].user?.id ?? "" }
            if self.posts?.count ?? 0 <= 0 {
                self.getUserSuggestion(pagenumber: self.previousPageForSuggestedFriend)
                return
            }
            self.tableView.reloadData()
            
        case .report :
            self.posts?.remove(at: indexPath.row)
        default:
            break
        }
        self.tableView.reloadData()
        
    }
}

