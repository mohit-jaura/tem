//
//  PostTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 28/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import MapKit
import Lightbox
import Kingfisher
import SSNeumorphicView
//import ActiveLabel

enum UserActions : Int , CaseIterable {
    case like = 0
    case comment = 1
    case profile = 2
    case share = 3
    case delete = 4
    case report = 5
    case unfriend = 6
    case challenge = 7
    case cancel = 8
    case block = 9
    case clearChat = 10
    case message = 11
    case unBlock = 12
    case deleteMemberFromGroup = 13
    case makeAdmin
    case addMedia
    case createEvent
    case addTemates
    case muteGroup
    case clearAll
    case readAll
    case createGoal
    case createChallenge
    case goal
    case pdf
    case weightGoal
    case createHealthGoal

    var message:String {
        switch self {
        case .delete:
            return "Do you really want to delete this post?"
        case .report:
            return "Are you sure you want to report this post?\nPost will not be longer shown to you"
        case .unfriend:
            return "Are you sure, you want to remove this user from your friend list?"
        case .block:
            return "Are you sure, you want to block this user? After blocking user will not reflect anywhere in the App.You will not able to see user profile."
        case .unBlock:
            return "Are you sure, you want to unblock this user?"
        case .deleteMemberFromGroup:
            return ""
        case .makeAdmin:
            return ""
        default:
            return ""
        }
    }
    var action:String {
        switch self {
        case .delete:
            return "Delete"
        case .report:
            return "Report"
        case .unfriend:
            return "Unfriend"
        case .cancel:
            return "Cancel"
        case .challenge:
            return "Challenge"
        case .block:
            return "Block"
        case .clearChat:
            return "Clear Chat"
        case .message:
            return "Message"
        case .unBlock :
            return "Unblock"
        case .muteGroup:
            return "Mute"
        case .goal:
            return "Goal"
        case .weightGoal:
            return "Weight Goal"
        case .createHealthGoal:
            return "HEALTH GOAL"
        default:
            return ""
        }
    }

    var title:String {
        switch self {
        case .delete:
            return "Delete Post"
        case .report:
            return "Report"
        case .challenge:
            return "Challenge"
        case .unfriend:
            return "Disconnect"
        case .cancel:
            return "Cancel"
        case .block:
            return "Block"
        case .clearChat:
            return "Clear Chat"
        case .message:
            return "Message"
        case .unBlock :
            return "Unblock"
        case .createEvent:
            return "Event"
        case .addMedia:
            return "Media"
        case .addTemates:
            return "Add Tēmates"
        case .muteGroup:
            return "Mute"
        case .goal:
            return "Goal"
        case .pdf:
            return "Pdf"
        case .weightGoal:
            return "Weight Goal"
        case .createHealthGoal:
            return "Health Goal"
        default:
            return ""
        }
    }
}

protocol PresentActionSheetDelegate {
    func presentActionSheet(titleArray:[UserActions],titleColorArray:[UIColor],tag:Int,indexPath:IndexPath)
    func presentAction(sender: UIButton)
}

extension PresentActionSheetDelegate {
    func presentAction(sender: UIButton) {}
}

protocol PostTableCellDelegate: class {
    func collectionViewDidScroll(newContentOffset: CGPoint, scrollView: UIScrollView)
    func adjustTableHeight(scrollToTp:Bool)
    func UserActions(indexPath:IndexPath,isDecrease:Bool,action:UserActions, actionInformation: Any?)
    func didTapOnSharePostWith(id: String,indexPath:IndexPath)
    func didTapMentionOnCaptionAt(row: Int, section: Int, tagText: String)
    func didTapOnViewTaggedPeople(sender: CustomButton)
    func didTapMentionOnCommentAt(row: Int, section: Int, tagText: String, commentFirst: Comments?, commentSecond: Comments?)
    func didBeginEdit(textView: UITextView)
    func didTapOnUrl(url: URL)
}

extension PostTableCellDelegate {
    func didBeginEdit(textView: UITextView) {}
}

protocol PostTableVideoMediaDelegate: class {
    func mediaCollectionScrollDidEnd()
    //    func mediaItemTapped(atIndex index: Int)
    func didTapOnMuteButton(sender: CustomButton)
    func didDismissFullScreenPreview()
}

extension String {
    @available(iOS 11.0, *)
    var iso8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}

extension Date {
    @available(iOS 11.0, *)
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
extension Formatter {
    @available(iOS 11.0, *)
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

class PostTableCell: UITableViewCell {

    // MARK: Properties
    var isFrompostDetail:Bool = false
    weak var delegate: PostTableCellDelegate?
    weak var postTableVideoMediaDelegate: PostTableVideoMediaDelegate?
    var redirectPostDelegate: ViewPostDetailDelegate?
    var postData:Post?
    var user:Friends?
    var loginUserActionList = [UserActions.delete,UserActions.cancel]
    var otherUserActionList = [UserActions.report,UserActions.cancel]
    var userFriendsActionList = [UserActions.challenge,UserActions.report,UserActions.unfriend,UserActions.cancel]
    var otherUserActionColor = [UIColor.black,UIColor.gray]
    var loginUserActionColor = [UIColor.red,UIColor.gray]
    var userFriendsActionColor = [UIColor.black,UIColor.black,UIColor.black,UIColor.gray]
    var actionDelegate:PresentActionSheetDelegate?
    var isReadMoreShow:Bool = false
    let baseControllerObject = DIBaseController()
    var lightBoxImage:[LightboxImage] = []
    var indexPath:IndexPath?
    private var commentViewDefaultHeight:CGFloat = 33.0
    private var commentViewMaximumHeight:CGFloat = 67.0

    // MARK: For View Controller.
    //Start.
    var viewerController: ViewerController?
    var viewableArr:[Photo] = []
    //End.


    // MARK: IBOutlets.
    @IBOutlet var mediaCollectionFixedHeightConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mediaCollectionSkeletonView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var pageControllerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var pageControl: ISPageControl!
    @IBOutlet weak var spaceViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var imagesViewWidth: NSLayoutConstraint!
    @IBOutlet weak var firstFriendImageView: UIImageView!
    @IBOutlet weak var secondFriendImageView: UIImageView!
    @IBOutlet weak var thirdFriendImageView: UIImageView!
    @IBOutlet weak var imagesContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var loginUserImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commwntViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mediaCollectionHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var readMoreBtnOutlet: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var collectionAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentOneLabel: ActiveLabel!
    @IBOutlet weak var commentTwoLabel: ActiveLabel!
    @IBOutlet weak var postActivityLabel: UILabel!
    @IBOutlet weak var postActivityBottomView: UIView!
    @IBOutlet weak var postActivityDotBtn: UIButton!
    @IBOutlet weak var postActivityTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButtonShadowView:SSNeumorphicView!{
        didSet{
            //self.setViewShadow(view: likeButtonShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var commentButtonShadowView:SSNeumorphicView!{
        didSet{
          //  self.setViewShadow(view: commentButtonShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var commentFieldShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: commentFieldShadowView, shadowType: .innerShadow)
        }
    }
    @IBOutlet weak var loginUserImageShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: loginUserImageShadowView, shadowType: .outerShadow)
            loginUserImageShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        }
    }
    @IBOutlet weak var shareButtonShadowView:SSNeumorphicView!{
        didSet{
         //   self.setViewShadow(view: shareButtonShadowView, shadowType: .outerShadow)
        }
    }

    @IBOutlet weak var backView:SSNeumorphicView!{
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.blakishGray.cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor.black.cgColor
            backView.viewNeumorphicCornerRadius = 8
            backView.viewNeumorphicShadowRadius = 8
            backView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
        }
    }

    //New outlets
    @IBOutlet weak var descriptionLabelTopFomUserView: NSLayoutConstraint!
    @IBOutlet weak var likeBtnTopFromUserView: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelBottomFromStackView: NSLayoutConstraint!

    @IBOutlet weak var likeBtnBottomFrpmDescription: NSLayoutConstraint!
    @IBOutlet weak var descriptionBackView: SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: descriptionBackView, shadowType: .innerShadow,radius:  0)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeCell()
        self.postButton.titleLabel?.shadowColor = .lightGray
        self.postButton.titleLabel?.shadowOffset = CGSize(width: 2, height: 2)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
    }

    private func showSkeletonOnView() {
        [locationImageView, userLocationLabel, userNameLabel, mediaCollectionView, loginUserImageView, descriptionLabel, likeButton, commentButton, shareButton, userImageView, postTimeLabel, likeButtonShadowView, commentButtonShadowView, shareButtonShadowView].forEach({$0?.showAnimatedSkeleton()})
    }

    private func hideSkeletonOnView() {
        [locationImageView, userLocationLabel, userNameLabel, mediaCollectionView, loginUserImageView, descriptionLabel, likeButton, commentButton, shareButton, commentTextView, userImageView, postTimeLabel, likeButtonShadowView, commentButtonShadowView, shareButtonShadowView].forEach({$0?.hideSkeleton()})
    }

    private func addShadowTo(view: UIView) {

        mainView.borderColor = ViewDecorator.viewBorderColor
        mainView.borderWidth = ViewDecorator.viewBorderWidth
        mainView.cornerRadius = 15.0
        view.cornerRadius = 15.0
        view.layer.masksToBounds = true
        view.layer.shadowColor = ViewDecorator.viewShadowColor
        view.layer.shadowOpacity = ViewDecorator.viewShadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        view.layer.shadowRadius = 15.0
    }
    // MARK: Custome Functions.


    func getViewableObject() {
        if let media = self.postData?.media {
            for (index,data) in media.enumerated(){
                if data.type == .video {
                    // Add video with poster photo
                    if let serverPath = data.url {
                        let photo = Photo(id: data.id ?? "\(index)")
                        photo.type = .video
                        photo.url = serverPath//"http://techslides.com/demos/sample-videos/small.mp4"//
                        print(data)
                        ImageCache.default.retrieveImage(forKey: data.previewImageUrl ?? "") {  result in
                            switch result {
                            case .success(let value):
                                if let _ = value.image {
                                    photo.placeholder = value.image!
                                } else {
                                    photo.placeholder = #imageLiteral(resourceName: "ImagePlaceHolder")
                                }
                            case .failure(let error):
                                print(" no image stored, you should create new one:- \(error)")
                            }
                        }
                        self.viewableArr.append(photo)
                    }
                }else{
                    if let serverPath = data.url {
                        let photo = Photo(id: data.id ?? "\(index)")
                        photo.type = .image
                        photo.url = serverPath
                        ImageCache.default.retrieveImage(forKey: data.url ?? "") {  result in
                            switch result {
                            case .success(let value):
                                if let img = value.image {
                                    photo.placeholder = img
                                }
                            case .failure(let error):
                                print(" no image stored, you should create new one:- \(error)")
                            }
                        }
                        self.viewableArr.append(photo)
                    }
                }
            }
        }
    }


    // MARK: Function to set Post Data.
    func setData(post:Post, atIndexPath indexPath: IndexPath, user:Friends, isFromFeed:Bool = false){
        //commentOneUserNameLabel.isUserInteractionEnabled = true
        //commentTwoUserNameLabel.isUserInteractionEnabled = true
        if isFromFeed{
            //            self.addShadowTo(view: self.contentView)
        }
        self.hideSkeletonOnView()
        self.indexPath = indexPath
        //        dotButton.isHidden = false
        commentTextView.isHidden = false
        if (post.user?.id ?? "" != User.sharedInstance.id) && (post.user?.isCompanyAccount ?? 0 == 1) {
            dotButton.isHidden = true
        } else {
            dotButton.isHidden = false
        }
        self.descriptionLabel.row = indexPath.row
        self.descriptionLabel.section = indexPath.section
        self.commentTextView.tag = indexPath.row
        self.commentOneLabel.row = indexPath.row
        self.commentOneLabel.section = indexPath.section

        self.commentTwoLabel.row = indexPath.row
        self.commentTwoLabel.section = indexPath.section

        self.setTags(tag: indexPath.item)
        self.commentTextView.text = post.commentText
        self.setHieghtOfTextView()
        self.postData = post
        self.user = user
        self.setUsersProfilePic()
        userNameLabel.text = ("\(Utility.getUserName(firstName: user.firstName ?? "", lastName: user.lastName ?? "", userName: user.userName ?? ""))")
        userLocationLabel.text = Utility.getAddress(userAddress: post.address ?? Address())
        self.addGestureToLocationLabel()
        postTimeLabel.text = post.createdAt?.utcToLocal().toDate().postCreatedTime()
        if #available(iOS 11.0, *) {
            if let date = post.createdAt?.iso8601 {
                self.postTimeLabel.text = date.postCreatedTime()
            }} else {/*Fallback on earlier versions*/}
        //if createdAt is nil, for eg. in case of the post displayed locally
        if post.createdAt == nil {
            //setting it to the current date time
            postTimeLabel.text = Date().postCreatedTime()
        }

        self.setAndDetectTagsInCaption()
        self.descriptionLabel.text = post.caption
        //descriptionLabel.attributedText = post.caption?.attributedStringFor(specialCharacter: "#", regex: RegEx.hashTag,fontSize: 14)

        if post.isLikeByMe == 1 {
            // likeButton.tintColor = appThemeColor
            likeButton.setImage(#imageLiteral(resourceName: "high five-blue"), for: .normal)
        }else{
            likeButton.setImage(#imageLiteral(resourceName: "high five"), for: .normal)
        }
        let shoutoutsText = (post.likesCount ?? 0) > 1 ? "Shoutouts" : "Shoutout"
        likeCountLabel.text = (post.likesCount ?? 0) > 0 ? "\(post.likesCount ?? 0) \(shoutoutsText)" : ""
        commentsCountLabel.text = (post.commentsCount ?? 0) > 0 ? "View all \(post.commentsCount ?? 0) comments" : ""

        self.setAndDetectMentionOnCommentLabel(commentLabel: commentOneLabel)
        self.setAndDetectMentionOnCommentLabel(commentLabel: commentTwoLabel)
        self.showLatestTwoComments(post: post)

        setLikesImages()
        self.setNumberOfPagesOfPageController()

        //Manage these constraints according to media type

        if post.tem_post_type == 2 {//For text
            var height = 160.0//36.0
            let font = UIFont(name: "Roboto-Regular", size: 15)
            let calculatedHeight = postData?.caption?.height(constraintedWidth: self.descriptionLabel.frame.width, font: font!) ?? 0.0
            if height > calculatedHeight {
                height = calculatedHeight
            }
            self.readMoreHideShow()
            if isFrompostDetail {
                let newHeight = descriptionLabel.text?.heightForView(withConstrainedWidth: descriptionLabel.frame.width, font: font!)
                DispatchQueue.main.async {
                    let value = self.descriptionLabel.calculateMaxLines(label: self.descriptionLabel)
                    let newData = value * 18 + 10
                    self.likeBtnTopFromUserView.constant = CGFloat(newData + 20)
                    self.likeBtnBottomFrpmDescription.constant = CGFloat(-(newData + 53))
                }
            } else {
                DispatchQueue.main.async {
                    self.likeBtnTopFromUserView.constant = height + 20
                    self.likeBtnBottomFrpmDescription.constant = -(height + 53)
                    if self.descriptionLabel.numberOfLines == 9 {
                        self.likeBtnTopFromUserView.constant = height + 40
                        self.likeBtnBottomFrpmDescription.constant = -(height + 73)
                    }
                }
            }
                self.descriptionLabelTopFomUserView.constant = 0
                self.descriptionLabelBottomFromStackView.constant = 75
                self.pageControl.isHidden = true
                self.descriptionBackView.isHidden = false
                self.mediaCollectionView.isHidden = true

            self.layoutIfNeeded()

        } else{// For multimedia
            if isFrompostDetail {
                self.likeBtnTopFromUserView.constant = 60 + self.mediaCollectionFixedHeightConstraint.constant//45
                self.likeBtnBottomFrpmDescription.constant = 8
                self.descriptionLabelTopFomUserView.constant = 100 + self.mediaCollectionFixedHeightConstraint.constant//120
            }else{

                self.likeBtnTopFromUserView.constant = 5 + self.mediaCollectionFixedHeightConstraint.constant
                self.likeBtnBottomFrpmDescription.constant = 10
                self.descriptionLabelTopFomUserView.constant = 100 + self.mediaCollectionFixedHeightConstraint.constant
            }

            self.descriptionLabelBottomFromStackView.constant = 20
            self.pageControl.isHidden = false
            self.descriptionBackView.isHidden = true
            self.mediaCollectionView.isHidden = false
            self.readMoreHideShow()
            self.layoutIfNeeded()
        }

        if let media = post.media,
           let height = media.first?.height,
           height != 0 {
            self.mediaCollectionFixedHeightConstraint.isActive = true
            if self.collectionAspectRatioConstraint != nil {
                self.collectionAspectRatioConstraint.isActive = false
            }
            self.mediaCollectionHeightConstraint.isActive = false
            self.mediaCollectionFixedHeightConstraint.constant = CGFloat(height)

            descriptionLabelTopFomUserView.constant = 75 + height
            likeBtnTopFromUserView.constant = 5 + height//30 + height
            mediaCollectionView.isHidden = false
            self.likeBtnBottomFrpmDescription.constant = 5// -30
        } else {
            self.mediaCollectionFixedHeightConstraint.isActive = false
            if self.collectionAspectRatioConstraint != nil {
                self.collectionAspectRatioConstraint.isActive = true
            }
            self.mediaCollectionHeightConstraint.isActive = true
        }
        setUpPostShare()
    }

    func setContentOffset(contentOffset: CGPoint) {

        var width = mediaCollectionView.bounds.width
        if width == 0.0{
            width = 0.1
        }
        pageControl.currentPage = Int(round(contentOffset.x / width))
        self.mediaCollectionView.setContentOffset(contentOffset, animated: false)
        mediaCollectionView.reloadData()
    }

    func setUpPostShare(){
        postActivityLabel.text = ""
        postActivityBottomView.isHidden = true
        postActivityDotBtn.isHidden = true
        dotButton.isHidden = false
        postActivityTopConstraint.constant = 0
        if let postType = self.postData?.postType,let postShareType = PostShareType(rawValue: postType){
            switch postShareType {
            case .postedByUser:
                postActivityDotBtn.isHidden = true
                dotButton.isHidden = false
                postActivityLabel.text = ""
                postActivityTopConstraint.constant = 0
                postActivityBottomView.isHidden = true
            case .likedByFriend:
                postActivityDotBtn.isHidden = false
                dotButton.isHidden = true
                postActivityLabel.text = "\(self.postData?.friendsLikeCount ?? 0) \(AppMessages.Post.likeByTemate)"
                postActivityTopConstraint.constant = 10
                postActivityBottomView.isHidden = false

            case .commentByFriend:
                dotButton.isHidden = true
                postActivityDotBtn.isHidden = false
                postActivityLabel.text = "\(self.postData?.friendsCommentCount ?? 0) \(AppMessages.Post.commentByTemate)"
                postActivityTopConstraint.constant = 10
                postActivityBottomView.isHidden = false

            }
        }
    }

    func setCommentText(text: String) {
        self.postData?.commentText = text
    }

    private func setAndDetectTagsInCaption() {
        descriptionLabel.isUserInteractionEnabled = true
        let customType = ActiveType.custom(pattern: RegEx.mention.rawValue)
        let hashTagCustomType = ActiveType.custom(pattern: RegEx.hashTag.rawValue)

        descriptionLabel.singleLineLength = 18
        //descriptionLabel.numberOfLines = 0
        descriptionLabel.customColor[customType] = UIColor.white
        descriptionLabel.customSelectedColor[customType] = UIColor.white
        descriptionLabel.customColor[hashTagCustomType] = UIColor.white
        descriptionLabel.customSelectedColor[hashTagCustomType] = UIColor.white
        descriptionLabel.enabledTypes = [customType, hashTagCustomType, .url]

        descriptionLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case customType, hashTagCustomType:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.descriptionLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.white
                case .url:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.descriptionLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.appThemeColor
                default: ()
                }

                return atts
            }
        }
        descriptionLabel.handleCustomTap(for: customType, handler: {[weak self] (element) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    print("tapped in post table cell")
                    let tagText = element.replace(Constant.taggedSymbol, replacement: "")
                    wkSelf.delegate?.didTapMentionOnCaptionAt(row: wkSelf.descriptionLabel.row, section: wkSelf.descriptionLabel.section, tagText: tagText)
                }
            }
        })
        descriptionLabel.handleURLTap {[weak self] (url) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    wkSelf.delegate?.didTapOnUrl(url: url)
                }
            }
        }
    }

    private func setAndDetectMentionOnCommentLabel(commentLabel: ActiveLabel) {
        commentLabel.isUserInteractionEnabled = true
        let customType = ActiveType.custom(pattern: RegEx.mention.rawValue)
        commentLabel.singleLineLength = 18
        commentLabel.customColor[customType] = UIColor.white
        commentLabel.customSelectedColor[customType] = UIColor.white
        commentLabel.enabledTypes = [customType, .url]

        commentLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case customType:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: commentLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.white
                case .url:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: commentLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.appThemeColor
                default: ()
                }

                return atts
            }
        }
        commentLabel.handleCustomTap(for: customType, handler: {[weak self] (element) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    print("tapped on comment in post table cell")
                    let tagText = element.replace(Constant.taggedSymbol, replacement: "")
                    if let comments = wkSelf.postData?.comments {
                        if comments.count == 1 {
                            self?.tappedOnComment(comment: wkSelf.postData?.comments?.first, tagText: tagText)
                        } else if comments.count == 2 {
                            if commentLabel == wkSelf.commentOneLabel {
                                self?.tappedOnComment(comment: wkSelf.postData?.comments?.last, tagText: tagText)
                            } else {
                                self?.tappedOnComment(comment: wkSelf.postData?.comments?.first, tagText: tagText)
                            }
                        }
                    }
                }
            }
        })

        commentLabel.handleURLTap {[weak self] (url) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    wkSelf.delegate?.didTapOnUrl(url: url)
                }
            }
        }
    }

    private func tappedOnComment(comment: Comments?, tagText: String) {
        if let first = comment,
           let taggedIds = first.taggedIds {
            let current = taggedIds.filter({$0.text == tagText})
            if let userId = current.first?.id {
                let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                    profileController.otherUserId = userId
                }
                UIApplication.topViewController()?.navigationController?.pushViewController(profileController, animated: true)
            }
        }
    }

    //show the latest two comments on the post
    private func showLatestTwoComments(post: Post) {
        self.commentOneLabel.isHidden = true
        self.commentTwoLabel.isHidden = true
        //        self.commentOneUserNameLabel.isHidden = true
        //        self.commentTwoUserNameLabel.isHidden = true

        //        commentOneLabel.attributedText = NSMutableAttributedString(string: "")
        //        commentTwoLabel.attributedText = NSMutableAttributedString(string: "")
        commentOneLabel.text = ""
        commentTwoLabel.text = ""

        //        commentOneUserNameLabel.attributedText = NSMutableAttributedString(string: "")
        //        commentTwoUserNameLabel.attributedText = NSMutableAttributedString(string: "")
        self.commentsCountLabel.isHidden = false
        if let commentsCount = post.commentsCount {
            if commentsCount > 0 && commentsCount <= 2 {
                self.commentsCountLabel.isHidden = true
            }
        }
        if let comments = post.comments {
            if comments.count == 1 {
                self.commentOneLabel.isHidden = false
                //self.commentOneUserNameLabel.isHidden = false
                //commentOneLabel.attributedText = self.attributedTextFor(comment: post.comments?.first)
                commentOneLabel.text = self.textFor(comment: post.comments?.first)
                //commentOneUserNameLabel.attributedText = attributedTextForUserName(comment: post.comments?.first)
                //self.commentOneLabel.text = post.comments?.first?.comment
            } else if comments.count == 2 {
                self.commentOneLabel.isHidden = false
                self.commentTwoLabel.isHidden = false
                //self.commentOneUserNameLabel.isHidden = false
                //self.commentTwoUserNameLabel.isHidden = false
                //commentOneLabel.attributedText = self.attributedTextFor(comment: post.comments?.last)
                commentOneLabel.text = self.textFor(comment: post.comments?.last)
                //commentOneUserNameLabel.attributedText = attributedTextForUserName(comment: post.comments?.last)
                //commentTwoLabel.attributedText = self.attributedTextFor(comment: post.comments?.first)
                commentTwoLabel.text = self.textFor(comment: post.comments?.first)
                //commentTwoUserNameLabel.attributedText = attributedTextForUserName(comment: post.comments?.first)
                //                self.commentOneLabel.text = post.comments?.last?.comment
                //                self.commentTwoLabel.text = post.comments?.first?.comment
            }
        }
    }

    // MARK: Function to set Users Profile Pic
    func setUsersProfilePic() {
        /*Set post User Profile Pic*/
        userImageView.contentMode = .scaleAspectFill
        if let image = self.user?.profilePic {
            if let imageUrl = URL(string: image) {
                self.userImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }else{
                self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
            }
        }else{
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        /*Set Login User Profile Pic*/
        if let imageUrl = URL(string:User.sharedInstance.profilePicUrl ?? "") {
            self.loginUserImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.loginUserImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }

    // MARK: Function to handle pages of pageControl
    func setNumberOfPagesOfPageController() {
        if let count = self.postData?.media?.count,
           (count != 0 && count > 1) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.pageControl.numberOfPages = self.postData?.media?.count ?? 0
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.pageControl.numberOfPages = 0
            }
        }
    }

    // MARK: Function to set Gesture on location label.
    fileprivate func addGestureToLocationLabel() {
        if(userLocationLabel.text != "") {
            let tap = UITapGestureRecognizer(target: self, action: #selector(openMapForPlace))
            tap.delegate = self // This is not required
            userLocationLabel.isUserInteractionEnabled = true
            userLocationLabel.addGestureRecognizer(tap)
        }
        if userLocationLabel.text?.trim == "" {
            locationImageView.isHidden = true
        }else{
            locationImageView.isHidden = false
        }
    }
    // MARK: Function to set Tag for cell properties.
    fileprivate func setTags(tag:Int) {
        self.dotButton.tag = tag
        self.likeCountLabel.tag = tag
        self.commentsCountLabel.tag = tag
        self.readMoreBtnOutlet.tag = tag
        self.mediaCollectionView.tag = tag
    }

    // MARK: Set height of textview without text.
    fileprivate func setHieghtOfTextView() {
        self.commwntViewHeightConstraint.constant = commentTextView.contentSize.height
        if self.commwntViewHeightConstraint.constant > commentViewMaximumHeight {
            self.commwntViewHeightConstraint.constant = commentViewMaximumHeight
        }else if self.commwntViewHeightConstraint.constant < commentViewDefaultHeight {
            self.commwntViewHeightConstraint.constant = commentViewDefaultHeight
        }
    }
    // MARK: Function to implement read more and read less.
    fileprivate func readMoreHideShow() {

        let font = UIFont(name: "Roboto-Regular", size: 15)

        let getHeight = postData?.caption?.height(constraintedWidth: self.descriptionLabel.frame.width, font: font!) ?? 0.0

        if getHeight >= 160.0 && (isReadMoreShow == true) {
            readMoreBtnOutlet.isHidden = false
            descriptionLabel.numberOfLines = 9
        } else {
            descriptionLabel.numberOfLines = 0
            readMoreBtnOutlet.isHidden = true
            if isFrompostDetail {

                descriptionLabel.numberOfLines = 0

            }
        }
        self.layoutIfNeeded()
    }

    @objc func openMapForPlace() {
        let latitude: CLLocationDegrees = self.postData?.coordinates?.last ?? 0
        let longitude: CLLocationDegrees = self.postData?.coordinates?.first ?? 0

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.postData?.address?.formatAddress()
        mapItem.openInMaps(launchOptions: options)
    }


    // MARK: Function to show the images of three friends(if post liked by them,otherwise no images will be shown)
    func setLikesImages() {
        switch self.postData?.likes?.count {
        case 1:
            hideLikesImges(firstStatus: false, secondStatus: true, thirdStatus: true,containerWidth:25.0)
            self.setImageOfFirstUser()
        case 2:
            hideLikesImges(firstStatus: false, secondStatus: false, thirdStatus: true,containerWidth:40.0)
            self.setImageOfFirstUser()
            self.setImageOfSecondUser()
        case 3:
            hideLikesImges(firstStatus: false, secondStatus: false, thirdStatus: false,containerWidth:55.0)
            self.setImageOfFirstUser()
            self.setImageOfSecondUser()
            self.setImageOfThirdUser()
        default:
            hideLikesImges(firstStatus: true, secondStatus: true, thirdStatus: true,dotViewWidth: 0.0)
        }
    }

    // MARK: Function to set the profile pic of user by them post has been liked.
    //first user....
    fileprivate func setImageOfFirstUser() {
        if let firstImageUrl = URL(string:self.postData?.likes?[0].profilePic ?? "") {
            self.firstFriendImageView.kf.setImage(with: firstImageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.firstFriendImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    //second user....
    fileprivate func setImageOfSecondUser() {
        if let secondImageUrl = URL(string:self.postData?.likes?[1].profilePic ?? "") {
            self.secondFriendImageView.kf.setImage(with: secondImageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.secondFriendImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    //third user....
    fileprivate func setImageOfThirdUser() {
        if let thirdImageUrl = URL(string:self.postData?.likes?[2].profilePic ?? "") {
            self.thirdFriendImageView.kf.setImage(with: thirdImageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.thirdFriendImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    // MARK: Function show or hide images.
    func hideLikesImges(firstStatus:Bool,secondStatus:Bool,thirdStatus:Bool,dotViewWidth:CGFloat = 20.0,containerWidth:CGFloat = 0.0) {
        firstFriendImageView.isHidden = firstStatus
        secondFriendImageView.isHidden = secondStatus
        thirdFriendImageView.isHidden = thirdStatus
        imagesViewWidth.constant = dotViewWidth
        imagesContainerWidth.constant = containerWidth
        if dotViewWidth == 0.0 {
            dotView.isHidden = true
        }else{
            dotView.isHidden = false
        }
    }

    // MARK: Function to add Gesture.
    func addGesture() {
        let viewCommentsGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToCommentsScreen))
        let viewLikesGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToLikesScreen))
        let viewProfileGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToUserProfile))
        let viewProfileGesture2 = UITapGestureRecognizer(target: self, action: #selector(navigateToUserProfile))
        let viewLoginUserProfileGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToLoginUserProfile))

        let tapGestureOnCommentOne = UITapGestureRecognizer(target: self, action: #selector(navigateToCommentsScreen(recognizer:)))
        commentOneLabel.isUserInteractionEnabled = true
        //commentOneLabel.addGestureRecognizer(tapGestureOnCommentOne)

        let tapGestureOnCommentTwo = UITapGestureRecognizer(target: self, action: #selector(navigateToCommentsScreen(recognizer:)))
        commentTwoLabel.isUserInteractionEnabled = true
        //commentTwoLabel.addGestureRecognizer(tapGestureOnCommentTwo)

        self.commentsCountLabel.addGestureRecognizer(viewCommentsGesture)
        self.likeCountLabel.addGestureRecognizer(viewLikesGesture)
        self.userImageView.addGestureRecognizer(viewProfileGesture)
        self.userNameLabel.addGestureRecognizer(viewProfileGesture2)
        self.loginUserImageView.addGestureRecognizer(viewLoginUserProfileGesture)

    }

    @objc func navigateToCommentsScreen(recognizer: UITapGestureRecognizer) {
        redirectToCommentScreen()
    }
    @objc func navigateToLikesScreen(recognizer: UITapGestureRecognizer) {
        let likesVC: UsersListingViewController = UIStoryboard(storyboard: .post).initVC()
        likesVC.presenter = UsersListingPresenter(forScreenType: .postLikes, id: self.postData?.id ?? "")
        UIApplication.topViewController()?.navigationController?.pushViewController(likesVC, animated: true)
    }

    @objc func navigateToUserProfile(recognizer: UITapGestureRecognizer) {
        if self.postData?.user?.isCompanyAccount ?? 0 == 0{
            let profileVC : ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
            if let id = postData?.user?.id {
                if id != User.sharedInstance.id {
                    profileVC.otherUserId = id
                }
            }
            UIApplication.topViewController()?.navigationController?.pushViewController(profileVC, animated: true)
        }
    }

    @objc func navigateToLoginUserProfile(recognizer: UITapGestureRecognizer) {
        let profileVC : ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        UIApplication.topViewController()?.navigationController?.pushViewController(profileVC, animated: true)
    }

    func redirectToCommentScreen() {
        let commentsVC : CommentsController = UIStoryboard(storyboard: .post).initVC()
        commentsVC.postId = self.postData?.id ?? ""
        commentsVC.delegate = self
        commentsVC.indexPath = indexPath
        UIApplication.topViewController()?.navigationController?.pushViewController(commentsVC, animated: true)
    }


    // MARK: Set cell properties here(connect delegate, set initial data etc)
    func initializeCell() {
        addGesture()
        commentTextView.delegate = self
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        if let count = self.postData?.media?.count , count > 1{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.pageControl.numberOfPages = count
            }
            pageControllerHeightConstraint.constant = 20
        }else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.pageControl.numberOfPages = 1
            }
            pageControllerHeightConstraint.constant = 0
        }

        self.mediaCollectionView.register(UINib(nibName: GridCollectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: GridCollectionCell.reuseIdentifier)
        self.showSkeletonOnView()
    }


    // MARK: IBActions.
    // MARK: Action for Likes, Comments and Share.
    @IBAction func postsActions(_ sender: UIButton) {
        if let actionType = UserActions(rawValue: sender.tag) {
            switch actionType {
            case .like :  //For Like.
                let dictionary = PostLikes.getDictForLikeOrUnlikePost(postData: self.postData ?? Post())
                if let path = indexPath {
                    self.delegate?.UserActions(indexPath : path, isDecrease: dictionary.1, action: .like, actionInformation: nil)
                }
                if !(Utility.isInternetAvailable()) {
                    return
                }
                DIWebLayerUserAPI().likeOrDislikePost(parameters: dictionary.0, success: { (message) in
                }) { (error) in
                }
            case .comment :  //For Comments.
                redirectToCommentScreen()
            case .profile :  //For Share.
                if let postId = self.postData?.id {
                    if let path = indexPath {
                        self.delegate?.didTapOnSharePostWith(id: postId, indexPath:path)
                    }
                }
            default:
                break
            }
        }
    }

    // MARK: This function will be called when user will comment on post.
    @IBAction func postButtonAction(_ sender: UIButton) {
    }

    // MARK: Dots Action.(options will be different for user(depending upon the owner of post))
    @IBAction func dotsAction(_ sender: UIButton) {
        if user?.id ?? "" != User.sharedInstance.id  {
            if user?.friendStatus != .connected {
                /*Action sheet will present when user will be taking action on friends post*/
                if let path = indexPath { actionDelegate?.presentActionSheet(titleArray:otherUserActionList,titleColorArray:otherUserActionColor, tag: sender.tag, indexPath:  path)
                }
                return
            }
            /*Action sheet will present when user will be taking action on others post*/
            if let path = indexPath{
                actionDelegate?.presentActionSheet(titleArray:userFriendsActionList,titleColorArray:userFriendsActionColor, tag: sender.tag, indexPath: path)
            }
        } else {
            /*Action sheet will present when user will be taking action on self post*/
            if let path = indexPath {
                actionDelegate?.presentActionSheet(titleArray:loginUserActionList,titleColorArray:loginUserActionColor, tag: sender.tag, indexPath: path)
            }
        }
    }

    /*// MARK: This function will open the post in different controller.
     (Read option will be shown to user when caption content will be more then 3 lines.)*/
    @IBAction func readMoreAction(_ sender: UIButton) {
        if let path = indexPath {
            redirectPostDelegate?.redirectToPostDetail(indexPath: path)
        }
    }

    /// returns the height of the video view of the cell that is visible on screen
    ///
    /// - Returns: height of the view visible
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(self.mediaCollectionView.frame, from: self.contentView)//self.superview?.superview?.convert(self.videoVView.frame, from: self.videoVView)
        guard let videoFrame = videoFrameInParentSuperView,
              let superViewFrame = superview?.frame else {
            return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        //print("visible video frame height::::::::: \(visibleVideoFrame.size.height)")
        return visibleVideoFrame.size.height
    }

    func setViewShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, shadowRadius: CGFloat = 3, radius: CGFloat = 1){
        var radii = view.frame.width / 2
        if radius == 0{
            radii = 8
        }
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = radii//view.frame.width / 2
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
}

extension PostTableCell {
    func attributedTextFor(comment: Comments?) -> NSMutableAttributedString {
        let userName = Utility.getUserName(firstName: comment?.userId?.firstName ?? "", lastName: comment?.userId?.lastName ?? "", userName: comment?.userId?.userName ?? "")
        let commentText = comment?.comment ?? ""
        let commentWithUserName = userName + " " + commentText
        let attributeString =  NSMutableAttributedString(string: commentWithUserName)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkText, NSAttributedString.Key.font: UIFont(name: UIFont.robotoMedium, size: 13.0) ?? UIFont.systemFont(ofSize: 12.0)], range: NSRange(location: 0, length: userName.utf16.count))


        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: UIFont.robotoMedium, size: 13.0) ?? UIFont.systemFont(ofSize: 12.0)], range: NSRange(location: userName.length + 1, length: commentText.utf16.count))

        //        let otherString = commentText.attributedStringFor(specialCharacter: "@", regex: RegEx.mention)
        //        let combination = NSMutableAttributedString()
        //        combination.append(attributeString)
        //        combination.append(otherString!)
        //
        return attributeString
    }

    func textFor(comment: Comments?) -> String {
        let userName = Utility.getUserName(firstName: comment?.userId?.firstName ?? "", lastName: comment?.userId?.lastName ?? "", userName: comment?.userId?.userName ?? "")
        let commentText = comment?.comment ?? ""
        let commentWithUserName = userName + ": " + commentText
        return commentWithUserName
    }

    func attributedTextForUserName(comment: Comments?) -> NSMutableAttributedString {
        let userName = Utility.getUserName(firstName: comment?.userId?.firstName ?? "", lastName: comment?.userId?.lastName ?? "", userName: comment?.userId?.userName ?? "")
        let attributeString =  NSMutableAttributedString(string: userName)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkText, NSAttributedString.Key.font: UIFont(name: UIFont.robotoMedium, size: 13.0) ?? UIFont.systemFont(ofSize: 12.0)], range: NSRange(location: 0, length: userName.utf16.count))
        return attributeString
    }
}

extension String {
    func heightForView(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}

extension String {

func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let label =  ActiveLabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.text = self
    label.singleLineLength = 18
    label.lineBreakMode = .byWordWrapping
    label.font = font
    label.sizeToFit()

    return label.frame.height
 }

}
