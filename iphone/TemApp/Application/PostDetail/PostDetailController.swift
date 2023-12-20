//
//  PostDetailController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 03/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
protocol PostDetailDotsDelegate: AnyObject {
    func dotsButtonAction(indexPath:IndexPath,type:UserActions)
}

var refreshPostData = "refreshPostData"

class PostDetailController: DIBaseController {
    
    // MARK: Vraibales.
    var postCommentFullScreenVC: PostCommentAddTagContainerViewController?
    private var minVideoPlaySize: CGFloat = 125.0
    var keyboardHeight: CGFloat = 0
    var postId: String?
    var post:Post?
    var user:Friends?
    var indexPath:IndexPath?
    
    weak var delegate:PostDetailDotsDelegate?
    private var collectionOffsets: [Int: CGPoint] = [:]
    var actionSheet = CustomBottomSheet()
    let feedsDataprovider = FeedsDataProvider()
    var isLikeNotification:Bool = true
    var isUserActionsFromPushNotification:Bool = false
    var isFoodTrekPost: Bool = false
    //VGPlayer
    var player : VGPlayer!
    
    //Will keep track of the index paths of currently playing player view
    private var currentPlayerIndex: IndexPath?
    
    //will keep track of the index paths of last played player view
    private var previousPlayerIndex: IndexPath?
    
    //will keep track of the last url being played in the player view
    private var lastPlayingMediaUrl: String?
    
    private var tagUsersListController: TagUsersListViewController?
    
    private var activeTextView: UITextView?
    
    // MARK: IBOutlets.
    @IBOutlet weak var postDetailTableView: UITableView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var tagListContainerView: UIView!
    @IBOutlet weak var tagListBottomConstraint: NSLayoutConstraint!
    
    // MARK: ViewLifeCycle.
    override func viewDidLoad(){
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(handleNotification),name: NSNotification.Name(rawValue:refreshPostData),object: nil)
        self.handleRedirectionOfPush()
        self.postDetailTableView.keyboardDismissMode = .onDrag
        initUI()
        self.getDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        self.setIQKeyboardTouchOutside(enable: false)
        //self.listenVolumeButton()
        NotificationCenter.default.addObserver(self, selector: #selector(outputVolumeChanged), name: Notification.Name.outputVolumeChanged, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        self.setIQKeyboardTouchOutside(enable: true)
        self.view.endEditing(true)
        
        self.removePlayer()
    }
    
    deinit {
        //  NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: refreshPostData), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        self.removeKeyboardNotificationObservers()
        self.view.endEditing(true)
        //self.removeVolumeListeners()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.outputVolumeChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.addKeyboardNotificationObservers()
        self.navigationController?.navigationBar.isHidden = false
        self.playVideo()
    }
    
    // MARK: Segue Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostCommentFullView",
            let destination = segue.destination as? PostCommentAddTagContainerViewController {
            self.postCommentFullScreenVC = destination
            destination.delegate = self
        }
    }

    private func setIQKeyboardTouchOutside(enable: Bool) {
        IQKeyboardManager.shared.shouldResignOnTouchOutside = enable
    }
    
    func playVideo(){
        self.currentPlayerIndex = nil
        self.lastPlayingMediaUrl = nil
        if self.post?.tem_post_type == 1 {
        self.pausePlayVideo()
        }
    }
    
    private func setUpTagListContainer() {
        self.tagListContainerView.isHidden = true
    }

    
    func handleRedirectionOfPush() {
        if isUserActionsFromPushNotification {
            if isLikeNotification {
                self.navigateToLikesScreen()
            }else{
                redirectToCommentScreen(id: self.postId ?? "")
            }
        }
    }
    
    @objc func handleNotification(notification: NSNotification) {
        if let id = notification.userInfo?["postId"] as? String {
            self.postId = id
            self.fetchPostDetails()
            //            if let isLike = notification.userInfo?["isLikeNotification"] as? Bool {
            //                if isLike {
            //                    self.UserActions(index: index ?? 0 , isDecrease: false, action: .like)
            //                }else{
            //                    self.UserActions(index: index ?? 0 , isDecrease: false, action: .comment)
            //                }
            //            }
        }
        
    }
    
    // MARK: Helpers
    func initUI(){
        postDetailTableView.tableFooterView = UIView()
        configureNavigation()
        self.postDetailTableView.register(UINib(nibName: PostTableCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: PostTableCell.reuseIdentifier)
        self.setUpTagListContainer()
    }
    
    // MARK: Set Navigation
    func configureNavigation(){
        let name:String = ("\(Utility.getUserName(firstName: self.user?.firstName ?? "", lastName: self.user?.lastName ?? "", userName: self.user?.userName ?? ""))")
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: name, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.newAppThemeColor, translucent: true)
        self.navigationController?.setTransparentNavigationBar()
    }
    
    private func getDataSource() {
        if isFoodTrekPost {
            self.fetchFoodTrekPostDetails()
        } else {
            if self.post == nil {
                //get the data from api call
                self.fetchPostDetails()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.post?.tem_post_type == 1 {
                        self.pausePlayVideo()
                    }
                }
            }
        }
    }
    
    func refreshView() {
        if isFoodTrekPost {
            fetchFoodTrekPostDetails()
        } else {
            self.fetchPostDetails()
        }
    }
    
    @objc func outputVolumeChanged() {
        self.updateMuteButtonOnChangingSoundStatus()
        self.updatePlayerSoundStatus()
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
    func addPlayer(cell: GridCollectionCell, collectionItem: Int) {
        guard let url = self.post?.media?[collectionItem].url else {//self.post?[tableRow].media?[collectionItem].url else {
            return
        }
        self.removePlayer()
        //        self.configurePlayer()
        self.configurePlayer(view: cell.videoView)
        self.player.addTo(view: cell.videoView, url: url, previewUrl: self.post?.media?[collectionItem].previewImageUrl)
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
    
    func updatePlayerSoundStatus() {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            if self.player != nil {
                self.player.setSound(toValue: muteStatus)
            }
        }
    }
    
    // MARK: Auto play - pause helpers
    /// call this function to handle the play and pause video for the visible table view cell
    private func pausePlayVideo() {
        guard post != nil else {
            return
        }
        let visisbleCells = postDetailTableView.visibleCells
        var mediaCollectionCell: GridCollectionCell?
        var maxHeight: CGFloat = 0.0
        
        //iterate through the table visible cells and get the maximum height visible
        for cellView in visisbleCells {
            
            if let containerCell = cellView as? PostTableCell {
                let currentIndexOfCollection = Int(containerCell.mediaCollectionView.contentOffset.x / containerCell.mediaCollectionView.frame.width)
                let indexPathOfMediaCell = IndexPath(item: currentIndexOfCollection, section: 0)
                
                guard let collectionCell = containerCell.mediaCollectionView.cellForItem(at: indexPathOfMediaCell) as? GridCollectionCell,
                    self.post?.media?[indexPathOfMediaCell.item].type! == .video,
                    let media = self.post?.media,
                    indexPathOfMediaCell.item < media.count,
                    let _ = self.post?.media?[indexPathOfMediaCell.item].url else {
                        continue
                }
                
                let height = containerCell.visibleVideoHeight()
                if maxHeight < height {
                    maxHeight = height
                    currentPlayerIndex = indexPathOfMediaCell
                    mediaCollectionCell = collectionCell
                }
            }
        }
        if maxHeight <= minVideoPlaySize {
            self.removePlayer()
            self.previousPlayerIndex = nil
            self.currentPlayerIndex = nil
        }
        guard let collectionIndexPath = currentPlayerIndex,
            self.post?.media?[collectionIndexPath.item].type! == .video else {
                return
        }
        
        //if maxheight is greater than minimum play size, play the video for this cell
        if maxHeight > minVideoPlaySize {
            if let lastCollectionIndex = previousPlayerIndex {
                if (collectionIndexPath == lastCollectionIndex) {
                    
                    let currentPlayingMediaUrl = self.post?.media?[collectionIndexPath.item].url ?? ""
                    //if current index media url is equal to the last playing then return else, add player with the new media url
                    if currentPlayingMediaUrl == lastPlayingMediaUrl {
                        //already playing video at this index
                        return
                    }
                }
            }
            if let mediaCollectionCell = mediaCollectionCell {
                self.addPlayer(cell: mediaCollectionCell, collectionItem: collectionIndexPath.item)
                self.lastPlayingMediaUrl = self.post?.media?[collectionIndexPath.item].url ?? ""
                previousPlayerIndex = collectionIndexPath
            }
        }
    }
    
    // MARK: Keyboard observers
    override func keyboardDisplayedWithHeight(value: CGRect) {
        self.keyboardHeight = value.height
        self.currentPlayerIndex = nil
        self.previousPlayerIndex = nil
        self.removePlayer()
    }
    
    override func keyboardHide(height: CGFloat) {
        self.tagListContainerView.isHidden = true
        if self.post?.tem_post_type == 1 {
        self.pausePlayVideo()
        }
    }
    
    // MARK: Server hit
    //fetch post details
    func fetchPostDetails() {
        guard let id = postId else {
            return
        }
        if !Reachability.isConnectedToNetwork() {
            self.postDetailTableView.showEmptyScreen(AppMessages.AlertTitles.noInternet)
            return
        }
        self.showLoader()
        PostManager.shared.getPostDetailsWith(postId: id, success: {[weak self] (post) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.hideLoader()
                self.post = post
                self.user = self.post?.user
                self.configureNavigation()
                self.postDetailTableView.reloadData()
                self.postDetailTableView.layoutIfNeeded()
                self.postDetailTableView.beginUpdates()
                self.postDetailTableView.endUpdates()
            }
            if self.post?.tem_post_type == 1 {
                self.pausePlayVideo()
            }
            
        }) { (error) in
            self.hideLoader()
            self.postDetailTableView.showEmptyScreen(error.message ?? "")
        }
    }
    
    func fetchFoodTrekPostDetails() {
        guard let id = postId else {
            return
        }
        if !Reachability.isConnectedToNetwork() {
            self.postDetailTableView.showEmptyScreen(AppMessages.AlertTitles.noInternet)
            return
        }
        self.showLoader()
        PostManager.shared.getFoodTrekPostDetailsWith(postId: id, success: {[weak self] (post) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.hideLoader()
                self.post = post
                self.user = self.post?.user
                self.configureNavigation()
                self.postDetailTableView.reloadData()
                self.postDetailTableView.layoutIfNeeded()
                self.postDetailTableView.beginUpdates()
                self.postDetailTableView.endUpdates()
            }
            if self.post?.tem_post_type == 1 {
                self.pausePlayVideo()
            }
            
        }) { (error) in
            self.hideLoader()
            self.postDetailTableView.showEmptyScreen(error.message ?? "")
        }
    }
    //delete post api call
    func deletePost() {
        self.showLoader()
        let params = DeletePostApiKey(id: self.post?.id ?? "")
        PostManager.shared.deletepost(parameters: params.toDictionary(), success: { (message) in
            self.hideLoader()
            self.showAlert( message: message, okCall: {
                if let path = self.indexPath {
                    self.delegate?.dotsButtonAction(indexPath: path, type: .delete)
                }
                self.navigationController?.popViewController(animated: true)
            }, cancelCall: {
            })
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    
    func unfriend() {
        self.showLoader()
        let params = DeleteFriendApiKey(friendId: self.user?.id ?? "")
        NetworkConnectionManager().deleteFriend(params: params.toDictionary() , success: { (message) in
            self.hideLoader()
            self.showAlert(message:message)
            self.user?.friendStatus = .other
            if let path = self.indexPath {
                self.delegate?.dotsButtonAction(indexPath: path, type: .unfriend)
            }
            self.navigationController?.popViewController(animated: true)
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        })
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
        var obj = ReportPost()
        obj.id = id
        obj.description = description
        obj.postId = self.post?.id ?? ""
        self.showLoader()
        PostManager.shared.reportPost(parameters: obj.getDictionary(), success: { (_) in
            self.hideLoader()
            if let value = self.indexPath {
                self.delegate?.dotsButtonAction(indexPath: value, type: .report)
            }
            self.navigationController?.popViewController(animated: true)
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
}

// MARK: PostCommentAddTagContainerViewController
extension PostDetailController: PostCommentAddTagDelegate {
    func resetTableOffsetToBottom(indexPath: IndexPath) {
        self.postDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func updateCommentOnPost(indexPath: IndexPath, isDecrease: Bool, commentInfo: Comments) {
        self.UserActions(indexPath: indexPath, isDecrease: isDecrease, action: .comment, actionInformation: commentInfo)
    }
    
    func hideCommentView() {
        self.tagListContainerView.isHidden = true
    }
    
}

// MARK: VGPlayerDelegate
extension PostDetailController: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        self.player.didChangeState()
        updatePlayerSoundStatus()
    }
}

// MARK: VGPlayerViewDelegate
extension PostDetailController: VGPlayerViewDelegate {
    func didTapOnVGPlayerView(_ playerView: VGPlayerView) {
        //present the full screen preview
        if let post = self.post,
            let item = playerView.row {
            let indexPathTable = IndexPath(row: 0, section: 0)
            if let tableCell = self.postDetailTableView.cellForRow(at: indexPathTable) as? PostTableCell,
                let collectionView = tableCell.mediaCollectionView {
                print("player current duration: \(self.player.currentDuration)")
                self.presentFullScreenPreview(forPost: post, atIndex: item, collectionView: collectionView, currentDuration: self.player.currentDuration)
                self.removePlayer()
            }
        }
    }
}

// MARK: PostTableVideoMediaDelegate
extension PostDetailController: PostTableVideoMediaDelegate {
    func didDismissFullScreenPreview() {
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
    
    ///call this function whenevr the user changes the sound status of the video
    private func updateMuteButtonOnChangingSoundStatus() {
        //updating mute button on other rows as well
        guard let visibleTableCells = postDetailTableView.visibleCells as? [PostTableCell] else {
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
    
    func mediaCollectionScrollDidEnd() {
        if self.post?.tem_post_type == 1{
            self.pausePlayVideo()
        }
        
    }
    
    
    func redirectToCommentScreen(id:String) {
        let commentsVC : CommentsController = UIStoryboard(storyboard: .post).initVC()
        commentsVC.postId = id
        commentsVC.delegate = self
        commentsVC.indexPath = self.indexPath
        UIApplication.topViewController()?.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func navigateToLikesScreen() {
        let likesVC: UsersListingViewController = UIStoryboard(storyboard: .post).initVC()
        if isFoodTrekPost {
            likesVC.presenter = UsersListingPresenter(forScreenType: .foodTrekLikes, id: self.postId ?? "")
            self.navigationController?.viewControllers.removeAll(where: { vc in
                let posDetailcontroller : PostDetailController = UIStoryboard(storyboard: .profile).initVC()
                return vc.nibName == posDetailcontroller.nibName
            })
        } else {
            likesVC.presenter = UsersListingPresenter(forScreenType: .postLikes, id: self.postId ?? "")
        }
        UIApplication.topViewController()?.navigationController?.pushViewController(likesVC, animated: true)
    }
}

// MARK: UITableViewDataSource&UITableViewDelegate
extension PostDetailController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.post != nil {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:PostTableCell = tableView.dequeueReusableCell(withIdentifier: PostTableCell.reuseIdentifier, for: indexPath) as? PostTableCell else {
            return UITableViewCell()
        }
        cell.postTableVideoMediaDelegate = self
        cell.actionDelegate = self
        cell.delegate = self
        cell.isFrompostDetail = true
        //cell.mediaCollectionHeightConstraint.constant = 320.0
        cell.setData(post: self.post ?? Post(), atIndexPath: indexPath, user: user ?? Friends())
        cell.setContentOffset(contentOffset: self.collectionOffsets[indexPath.row] ?? CGPoint.zero)
//        if let media = self.post?.media,
//            let height = media.first?.height,
//            height != 0 {
//            cell.mediaCollectionHeightConstraint.constant = CGFloat(height)
//        } else {
//            cell.mediaCollectionHeightConstraint.constant = 320.0
//        }
        cell.backgroundColor = UIColor.newAppThemeColor
        cell.contentView.backgroundColor = UIColor.newAppThemeColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: SkeletonTableViewDataSource
extension PostDetailController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PostTableCell.reuseIdentifier
    }
}

extension PostDetailController : PostTableCellDelegate, URLTappableProtocol {
    func didTapOnUrl(url: URL) {
        self.pushToSafariVCOnUrlTap(url: url)
    }
    
    func didBeginEdit(textView: UITextView) {
        //self.postDetailTableView.scrollWithKeyboard(keyboardHeight: keyboardHeight, inputView: textView)
        self.activeTextView = textView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var safeArea: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            } else {
                // Fallback on earlier versions
            }
            self.tagListBottomConstraint.constant = -(self.keyboardHeight - safeArea)//-(self.keyboardHeight + textView.frame.size.height + 20)//(point + textView.frame.height + CGFloat(safeArea))//pointInTable?.y ?? 0.0//self.keyboardSize//pointInTable.y
            self.tagListContainerView.isHidden = false
            self.postCommentFullScreenVC?.setFirstResponder()
            self.postCommentFullScreenVC?.indexPath = IndexPath(row: 0, section: 0)
            if let postId = self.postId {
                self.postCommentFullScreenVC?.postId = postId
            } else if let postId = self.post?.id {
                self.postCommentFullScreenVC?.postId = postId
            }
        }
    }
    
    func didTapOnViewTaggedPeople(sender: CustomButton) {
        if let taggedPeople = self.post?.media?[sender.row].taggedPeople {
            self.showSelectionModal(array: taggedPeople, type: .taggedList)
        }
    }
    
    func didTapMentionOnCommentAt(row: Int, section: Int, tagText: String, commentFirst: Comments?, commentSecond: Comments?) {
        var comment = commentFirst
        if commentSecond != nil {
            comment = commentSecond
        }
        if let first = comment,
            let taggedIds = first.taggedIds {
            let current = taggedIds.filter({$0.text == tagText})
            if let userId = current.first?.id {
                let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                    profileController.otherUserId = userId
                }
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
    }
    
    func didTapMentionOnCaptionAt(row: Int, section: Int, tagText: String) {
        if let captionTaggedIds = self.post?.captionTags {
            let currentTagged = captionTaggedIds.filter({$0.text == tagText})
            if let userId = currentTagged.first?.id {
                let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                    profileController.otherUserId = userId
                }
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
    }
    
    func didTapOnSharePostWith(id: String, indexPath: IndexPath) {
        _ = indexPath.row
        if let link = self.post?.shortLink , link != ""{
            self.shareLink(data: link)
            return
        }else{
            let urlString = Constant.SubDomain.sharePost + "?post_id=\(id)"
            let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            self.showLoader()
            DIWebLayerNetworkAPI().getBusinessDynamicLink(url:url,parameters: nil, success: { (response) in
                self.hideLoader()
                self.post?.shortLink = response
                self.shareLink(data: response)
            }) { (error) in
                self.hideLoader()
                self.showAlert(withError:error)
            }
        }
    }
    func shareLink(data:String) {
        let activityViewController = UIActivityViewController(activityItems: [ data ] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func UserActions(indexPath: IndexPath, isDecrease: Bool, action: UserActions, actionInformation: Any?) {
        switch action {
        case .like:
            self.post?.updateLikes(withStatus: isDecrease)
            self.feedsDataprovider.updateLikesInPostInDatabaseWith(postId: self.post?.id, isLikeByMe: self.post?.isLikeByMe, likesCount: self.post?.likesCount)
        case .comment :
            self.post?.updateCommentsCount(forStatus: isDecrease)
            if let comment = actionInformation as? Comments {
                post?.updateLatestComment(info: comment, value: isDecrease)
            }
            if let comments = actionInformation as? [Comments] {
                post?.updateLatestCommentsArray(data: comments, value: isDecrease)
            }
        default:
            break
        }
        self.postDetailTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func adjustTableHeight(scrollToTp:Bool) {
        UIView.setAnimationsEnabled(false)
        self.postDetailTableView.beginUpdates()
        self.postDetailTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        if scrollToTp {
            self.postDetailTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func collectionViewDidScroll(newContentOffset: CGPoint, scrollView: UIScrollView) {
        self.collectionOffsets[scrollView.tag] = newContentOffset
    }
    
    
}

extension PostDetailController: PresentActionSheetDelegate{
    func presentActionSheet(titleArray: [UserActions], titleColorArray: [UIColor], tag: Int, indexPath: IndexPath) {
        actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: titleColorArray, tag: tag,section: indexPath.section)
        actionSheet.delegate = self
    }
}

extension PostDetailController: CustomBottomSheetDelegate {
    
    func customSheet(actionForItem action: UserActions) {
        let actionIndex = actionSheet.tag
        let indexPath = IndexPath(row: actionIndex, section: 0)
        self.actionSheet.dismissSheet()
        if action == .report {
            if Constant.reportHeadings.isEmpty {
                Utility.getHeadings()
            }
        }
        if action == .challenge {
            let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
            controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
            controller.isType = false
            if let user = self.user {
                controller.selectedFriends = [user]
            }
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        if action == .cancel {
            return
        }
        self.showAlert(withTitle: "", message: action.message, okayTitle: action.action, cancelTitle: AppMessages.AlertTitles.No,okStyle:.destructive, okCall: {
            guard self.isConnectedToNetwork() else {
                return
            }
            switch action {
            case .delete:
                self.deletePost()
            case .unfriend:
                self.unfriend()
            case .report:
                self.addTableView(indexPath: indexPath)
            default:
                break
            }
        }) {
        }
    }
}


// MARK: CommomentsDelegate(Method will increase/decrease the comment count by one according to user action.)
extension PostDetailController: CommomentsDelegate {
    func updateCount(indexPath: IndexPath,isDecrease:Bool, dataInfo: Any?) {
        //
        self.UserActions(indexPath: indexPath, isDecrease: isDecrease, action: .comment, actionInformation: dataInfo)
    }
}
