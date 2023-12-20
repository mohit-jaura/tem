//
//  CommentsController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 22/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol CommomentsDelegate: AnyObject {
    func updateCount(indexPath:IndexPath,isDecrease:Bool, dataInfo: Any?)
}


class CommentsController: DIBaseController {

    // MARK: Variables.
    private var previousPage:Int = 1
    private var currentPage:Int = 1
    var comments = [Comments]()
    weak var delegate:CommomentsDelegate?
    var postId:String?
    var indexPath:IndexPath?
    var refreshControl: UIRefreshControl!
    var rightBarButtonItem: UIBarButtonItem?
    var presenter: UsersListingPresenter?
    private var tagUsersListController: TagUsersListViewController?
    private var currentTaggedIds: [UserTag]?
    
    // MARK: IBOutlets.
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var commentTextView: IQTextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var loginUserImageView: UIImageView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagListContainerView: UIView!
    
    // MARK: Food Trek Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var shoutoutsLbl:UILabel!
    @IBOutlet weak var captionTextView: ActiveLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var foodTrekImageView:UIImageView!
    
    // MARK: Food Trek Properties
    var isFromFoodTrek:Bool = false
    // MARK: ViewLifeCycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.commentsTableView.showAnimatedSkeleton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.navigationController?.navigationBar.isHidden = false
        self.addKeyboardNotificationObservers()
        self.setIQKeyboardManager(toEnable: false)
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: true, controller: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.removeKeyboardNotificationObservers()
        self.setIQKeyboardManager(toEnable: true)
    }
    
    func initUI() {
        self.commentTextView.addDoneButtonOnKeyboard()
        configureNavigation()
        addRefreshController()
        self.setUpTagListContainer()
        if let imageUrl = URL(string:User.sharedInstance.profilePicUrl ?? "") {
            self.loginUserImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.loginUserImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        commentsTableView.tableFooterView = UIView()
        if isFromFoodTrek{
            getFoodTrekDetail(id: postId ?? "")
        }
        fetchCommentsList()
    }
    
    // MARK: Set Navigation
    func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.comments.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    // MARK: - UI Components
    private func setUpTagListContainer() {
        self.tagUsersListController = UIStoryboard(storyboard: .post).initVC()
        tagUsersListController?.listType = .commentTagging
        tagUsersListController?.delegate = self
        tagUsersListController?.screenFrom = .newsFeeds
        self.addChild(tagUsersListController!)
        tagUsersListController?.view.frame = self.tagListContainerView.bounds
        self.tagListContainerView.addSubview(tagUsersListController?.view ?? UIView())
        tagUsersListController?.didMove(toParent: self)
        self.tagListContainerView.isHidden = true
    }
    
    func refreshDataOnPush() {
        self.currentPage = 1
        self.previousPage = 1
        self.comments.removeAll()
        self.fetchCommentsList()
    }
    
    func fetchCommentsList() {
        DIWebLayerUserAPI().getPostComments(isFromFoodTrek:isFromFoodTrek,id: postId ?? "", page: currentPage, success: { (data) in
            let previousData = self.comments
            self.comments = data
            self.comments = self.comments.sorted { $0.createdAt ?? "" < $1.createdAt ?? ""}
            if self.currentPage == 1 && !previousData.isEmpty {
                //in case the user posted a comment before the api got response, then that would be added to the list.
                self.comments.append(contentsOf: previousData)
            }
            if (self.currentPage > 1) {
                self.comments.append(contentsOf: previousData)
            }
            self.commentsTableView.hideSkeleton()
            self.commentsTableView.tableFooterView = UIView()
            self.refreshControl.endRefreshing()
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
                if (self.currentPage == 1) {
                    self.scroolToBottom()
                }
            }
            if data.count >= 15 {
                self.currentPage += 1
            }
        }, failure: { (error) in
            self.commentsTableView.tableFooterView = UIView()
            self.refreshControl.endRefreshing()
            self.showAlert(message:error.message)
        })
    }
    
    private func getFoodTrekDetail(id: String) {
        self.showLoader()
        PostManager.shared.getFoodTrekDetail(id: id) { result in
            self.setFoodTrekDetails(foodTrek: result)
        } failure: { _ in
            self.hideLoader()
        }
    }
    private func getDateForLbl(timeStamp: Int) -> String{
        let sDate = String(describing: timeStamp)
        var date = Date()
        if sDate.count == 10 {
            date = timeStamp.toDate
        }
        else if sDate.count == 13 {
            date = timeStamp.timestampInMillisecondsToDate
        }
        let uppercasedDate = date.toString(inFormat: .foodTrek) ?? ""
        return uppercasedDate
    }
    func getTrekTime(timeStamp: Int) -> String {
        let sDate = String(describing: timeStamp)
        var date = Date()
        if sDate.count == 10 {
            date = timeStamp.toDate
        }
        else if sDate.count == 13 {
            date = timeStamp.timestampInMillisecondsToDate
        }
        return date.toString(inFormat: .time) ?? ""
    }
    private func setFoodTrekDetails(foodTrek: FoodTrekModel) {
        self.hideLoader()
        foodTrekImageView.isHidden = false
        mainView.isHidden = false
        foodTrekImageView.image = UIImage(named: "ImagePlaceHolder")
        if let imageUrl = URL(string: foodTrek.image ?? "") {
            foodTrekImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "ImagePlaceHolder"))
        }else {
            foodTrekImageView.image = UIImage(named: "ImagePlaceHolder")
        }
        self.captionTextView.text = foodTrek.text ?? ""
        scrollView.isDirectionalLockEnabled = true
        setAndDetectTagsInCaption(foodTrek: foodTrek)
        self.dateLbl.text = getDateForLbl(timeStamp: foodTrek.date ?? 0)
        self.shoutoutsLbl.text = "\(foodTrek.likes_count ?? 0)"
    }
    
    private func setAndDetectTagsInCaption(foodTrek: FoodTrekModel) {
        captionTextView.isUserInteractionEnabled = true
        let customType = ActiveType.custom(pattern: RegEx.mention.rawValue)
        let hashTagCustomType = ActiveType.custom(pattern: RegEx.hashTag.rawValue)
        
        captionTextView.numberOfLines = 0
        captionTextView.customColor[customType] = UIColor.white
        captionTextView.customSelectedColor[customType] = UIColor.white
        captionTextView.customColor[hashTagCustomType] = UIColor.white
        captionTextView.customSelectedColor[hashTagCustomType] = UIColor.white
        captionTextView.enabledTypes = [customType, hashTagCustomType, .url]
        
        captionTextView.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                    case customType, hashTagCustomType:
                        atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.captionTextView.font.pointSize)!
                        atts[NSAttributedString.Key.foregroundColor] = UIColor.appThemeColor
                    case .url:
                        atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.captionTextView.font.pointSize)!
                        atts[NSAttributedString.Key.foregroundColor] = UIColor.appThemeColor
                    default: ()
                }
                
                return atts
            }
        }
        captionTextView.handleCustomTap(for: customType, handler: {[weak self] (element) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    let tagText = element.replace(Constant.taggedSymbol, replacement: "")
                    wkSelf.getCaptionTagId(foodTrek: foodTrek, tagText: tagText)
                }
            }
        })
        captionTextView.handleURLTap { _ in
            return
        }
    }
    
    private func redirectToProfile(userId: String) {
        let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
            profileController.otherUserId = userId
        }
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    private func getCaptionTagId(foodTrek: FoodTrekModel, tagText: String) {
        if let captionTaggedIds = foodTrek.captionTagIds {
            let currentTagged = captionTaggedIds.filter({$0.text == tagText})
            if let userId = currentTagged.first?.id {
                redirectToProfile(userId: userId)
            }
        }
    }
    // MARK: AddRefreshController To TableView.
    private func addRefreshController() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(refreshComments(sender:)) , for: .valueChanged)
        commentsTableView.addSubview(refreshControl)
    }
    
    // MARK: Function To Refresh Posts Tableview Data.
    @objc func refreshComments(sender:AnyObject) {
        if Utility.isInternetAvailable(){
            if previousPage < currentPage {
                previousPage = currentPage
                self.commentsTableView.tableFooterView = Utility.getPagingSpinner()
                fetchCommentsList()
            }else{
                refreshControl.endRefreshing()
            }
        }else {
            refreshControl.endRefreshing()
            AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet)
        }
    }
    @IBAction func postButtonAction(_ sender: UIButton) {
        if !(Reachability.isConnectedToNetwork()) {
            self.showAlert(message:AppMessages.AlertTitles.noInternet)
            return
        }
        if commentTextView.text.isBlank {
            Utility.showPopupOnTopViewController(withTitle: "Alert!", message: AppMessages.Comments.enterComment)
            return
        }
        var objComment = Comment()
        objComment.postId = self.postId ?? ""
        objComment.comment = commentTextView.text.trim
        if let taggedIds = self.currentTaggedIds,
           !taggedIds.isEmpty {
            objComment.taggedIds = taggedIds
        }
        currentTaggedIds = nil
        self.commentsTableView.tableFooterView = Utility.getPagingSpinner()
        self.commentTextView.text = ""
        self.postButton.isUserInteractionEnabled = false
        self.commentViewHeightConstraint.constant = 33
        self.tagUsersListController?.resetTagList()
        DIWebLayerUserAPI().addcomment(isFromFoodTrek:isFromFoodTrek,parameters: objComment.getDictionary(), success: { (data) in
            self.commentsTableView.tableFooterView = UIView()
            if let path = self.indexPath {
                //setting the comment data
                let commentInformation = Comments()
                commentInformation.comment = objComment.comment
                let userInformation = UserId()
                userInformation.userName = UserManager.getCurrentUser()?.userName
                userInformation.firstName = UserManager.getCurrentUser()?.firstName
                userInformation.lastName = UserManager.getCurrentUser()?.lastName
                userInformation.id = UserManager.getCurrentUser()?.id
                commentInformation.userId = userInformation
                commentInformation.taggedIds = []
                if let taggedIds = data["commentTagIds"] as? [Parameters] {
                    commentInformation.taggedIds = taggedIds.map({ (data) -> UserTag in
                        return UserTag(dict: data)
                    })
                }
                self.delegate?.updateCount(indexPath: path, isDecrease: false, dataInfo: commentInformation)
            }
            let obj = Comments()
            obj.comment = objComment.comment
            obj._id = data["_id"] as? String ?? ""
            obj.userId = UserId()
            obj.userId?.id  = User.sharedInstance.id
            obj.userId?.userName = User.sharedInstance.userName
            obj.userId?.firstName = User.sharedInstance.firstName
            obj.userId?.lastName = User.sharedInstance.lastName
            obj.userId?.picture = User.sharedInstance.profilePicUrl
            obj.createdAt = Utility.currentDate()
            obj.taggedIds = []
            if let taggedIds = data["commentTagIds"] as? [Parameters] {
                obj.taggedIds = taggedIds.map({ (data) -> UserTag in
                    return UserTag(dict: data)
                })
            }
            self.commentsTableView.hideSkeleton()
            self.comments.append(obj)
            self.commentsTableView.reloadData()
            self.scroolToBottom()
        }) { (error) in
            self.commentsTableView.tableFooterView = UIView()
            self.showAlert(message:error.message)
        }
    }
    
    func scroolToBottom() {
        let row = (self.comments.count - 1)
        if row > 0 {
            self.commentsTableView.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: false)
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
        self.commentViewBottomConstraint.constant = -(value.height-verticalSafeAreaInset)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func keyboardHide(height: CGFloat) {
        self.commentViewBottomConstraint.constant = 0
    }
    
}

// MARK: TagUsersListViewDelegate
extension CommentsController: TagUsersListViewDelegate {
    func didChangeTaggedList(taggedList: [TaggingModel]) {
        self.currentTaggedIds = taggedList.map({ $0.toUserTagModel() })
    }
    
    func didChangeTaggableList(isEmpty: Bool) {
        self.tagListContainerView.isHidden = isEmpty
    }
    
    func didSelectUserFromTagList(tagText: String, userId: String) {
        Tagging.sharedInstance.updateTaggedList(allText: commentTextView.text, tagText: tagText, id: userId)
    }
    
    func updateAttributedTextOnTagSelect(attributedValue: (NSMutableAttributedString, NSRange)) {
        self.commentTextView.attributedText = attributedValue.0
        self.commentTextView.selectedRange = attributedValue.1
    }
}

// MARK: UITableViewDataSource&UITableViewDelegate
extension CommentsController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(Reachability.isConnectedToNetwork()) {
            tableView.showEmptyScreen(AppMessages.AlertTitles.noInternet)
        }else if comments.count == 0 {
            tableView.showEmptyScreen(AppMessages.Comments.noComments)
        }else{
            tableView.showEmptyScreen("")
        }
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:CommentsTableCell = tableView.dequeueReusableCell(withIdentifier: CommentsTableCell.reuseIdentifier, for: indexPath) as? CommentsTableCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.commentLabel.row = indexPath.row
        cell.commentLabel.section = indexPath.section
        cell.setData(data: self.comments[indexPath.row])
        return cell
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
        if self.comments[indexPath.row].userId?.id ?? "" == User.sharedInstance.id ?? "" {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteComment(indexPath: indexPath)
        }
    }
    
    func deleteComment(indexPath:IndexPath) {
        self.showLoader()
        DIWebLayerUserAPI().deletecomment(parameters: ["comment_id":self.comments[indexPath.row]._id ?? ""], success: { (message) in
            self.hideLoader()
            self.comments.remove(at: indexPath.row)
            if let indexPathOfParent = self.indexPath {
                var latestCommentsArray: [Comments] = []
                if self.comments.count > 0 {
                    let lastComment = self.comments.last
                    latestCommentsArray.append(lastComment ?? Comments())
                    if self.comments.count > 1 {
                        let secondLastComment = self.comments[self.comments.count - 2]
                        latestCommentsArray.append(secondLastComment)
                    }
                    self.delegate?.updateCount(indexPath: indexPathOfParent, isDecrease: true, dataInfo: latestCommentsArray)
                } else {
                    self.delegate?.updateCount(indexPath: indexPathOfParent, isDecrease: true, dataInfo: [])
                }
            }
            self.commentsTableView.deleteRows(at: [indexPath], with: .automatic)
            self.showAlert(message:message)
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        })
    }
}

// MARK: UITextviewDelegate.
extension CommentsController:UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.scroolToBottom()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var hidebutton = false
        if (textView.text.count == 1 && text.count == 0) {
            hidebutton = true
        }
        if (textView.text.count + text.count) >= 1 && (hidebutton == false){
            self.postButton.setTitleColor(appThemeColor, for: .normal)
            self.postButton.isUserInteractionEnabled = true
        }else{
            self.postButton.setTitleColor(UIColor(red: 148/255, green: 199/255, blue: 240/255, alpha: 1.0), for: .normal)
            self.postButton.isUserInteractionEnabled = false
        }
        Tagging.sharedInstance.updateTaggedList(range: range, textCount: text.utf16.count)
        if textView.text.count + text.count > 2000 {
            return false
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        self.commentViewHeightConstraint.constant = textView.contentSize.height
        if self.commentViewHeightConstraint.constant > 67 {
            self.commentViewHeightConstraint.constant = 67
        }
        Tagging.sharedInstance.tagging(textView: textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        Tagging.sharedInstance.tagging(textView: textView)
    }
}


// MARK: SkeletonTableViewDataSource
extension CommentsController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CommentsTableCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
}

// MARK: CommentTableCellDelegate
extension CommentsController: CommentTableCellDelegate, URLTappableProtocol {
    func didTapOnUrlInCommentAt(row: Int, section: Int, url: URL) {
        self.pushToSafariVCOnUrlTap(url: url)
    }
    
    func didTapOnTagInCommentAt(row: Int, section: Int, tagText: String) {
        if let captionTaggedIds = self.comments[row].taggedIds {
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
}
