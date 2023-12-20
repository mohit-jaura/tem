//
//  CreatePostViewController.swift
//  TemApp
//
//  Created by shilpa on 13/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import GooglePlaces
import IQKeyboardManagerSwift
import SSNeumorphicView
let AWSBucketFileSizeLimit: Int = 104857600

//Create post screen
class CreatePostViewController: DIBaseController {


    // MARK: IBOutlets.
    @IBOutlet weak var multipleImagesImageview: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cossButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!

    @IBOutlet  var captionTextViewTopConstraint: NSLayoutConstraint!
    @IBOutlet  var captionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet  var captionTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var locationArrowButton: UIButton!
    @IBOutlet weak var taggedPeopleLabel: UILabel!
    @IBOutlet weak var taglistContainerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    var isForCreatePost:Bool = false
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.appThemeDarkGrayColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }

    // MARK: Properties
    var post = Post()
    var currentAddress:Address?
    var height:CGFloat = 0
    var mediaItems = [YPMediaItem]()
    var screenshot: UIImage?
    private var hashTags: [String]?
    var isComingFromActivity:Bool = false
    var isFromDashBoard:Bool = false
    private var tagUsersListController: TagUsersListViewController?
    private var totalTaggedCount = 0
    var isFromActivityLog = false
    //setting the default to create post
    var type: PostType = .normal

    // MARK: - UI Components
    private func setUpTagListContainer() {
        self.tagUsersListController = UIStoryboard(storyboard: .post).initVC()
        tagUsersListController?.listType = .postCaptionTagging
        tagUsersListController?.delegate = self
        tagUsersListController?.screenFrom = .newsFeeds
        self.addChild(tagUsersListController!)
        tagUsersListController?.view.frame = self.taglistContainerView.bounds
        self.taglistContainerView.addSubview(tagUsersListController?.view ?? UIView())
        tagUsersListController?.didMove(toParent: self)
        self.taglistContainerView.isHidden = true
    }
    @IBAction func backTapped(_ sender: UIButton) {
        if isFromActivityLog || isForCreatePost {
            self.navigationController?.popViewController(animated: true)
        } else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBOutlet weak var captionView: SSNeumorphicView!{
        didSet{
            setShadow(view: captionView, shadowType: .innerShadow)
        }
    }
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.setOuterDarkShadow()
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
    }

    // MARK: IBActions
    @IBAction func tagPeopleTapped(_ sender: UIButton) {
        let controller: TagPeopleViewController = UIStoryboard(storyboard: .post).initVC()
        let navController = UINavigationController(rootViewController: controller)
        controller.delegate = self
        controller.screenFrom = .newsFeeds
        controller.totalTaggedCount = self.totalTaggedCount
        if let media = self.post.media {
            controller.media = media
        }
        self.present(navController, animated: true, completion: nil)
    }

    @IBAction func locationActionButtonTapped(_ sender: UIButton) {
        self.post.address = nil
        self.locationArrowButton.setImage(UIImage(named: "right-arrowSmall"), for: .normal)
        self.locationLabel.text = "Add Location".localized
        self.addLocationButton.isUserInteractionEnabled = true
    }

    @IBAction func selectedImagesTapped(_ sender: UIButton) {
        if isForCreatePost {
            self.showYPPhotoGallery(showCrop: false)
        } else {
            print("selected images tapped")
            self.popBackToImageGallery()
        }

    }

    override func handleAfterMediaSelection(withMedia items: [YPMediaItem], isPresentingFromCreatePost: Bool, isFromFoodTrek:Bool = false) {
        guard isConnectedToNetwork() else {
            return
        }
        self.picker?.dismiss(animated: true, completion: nil)
        mediaItems = items
        initializeNewPostWithYPMedia()
    }

    @IBAction func addLocationTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.pushToLocationViewController()
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        if let _ = Defaults.shared.get(forKey: .imageId) as? Int{
            Defaults.shared.remove(.imageId)
        }
        guard hashTagsValidated(),
              isConnectedToNetwork() else {
            return
        }
        guard mediaSizeValidated() else {
            self.showAlert(message: "Some files are too large to share. Please, select other files.")
            return
        }

        self.setActivityIndicatorOnRightBarButton()
        self.post.caption = captionTextView.text.trim
        if let post  = self.post.media {
            self.post.tem_post_type = 1
        } else {

            self.post.tem_post_type = 2
        }
        if let long = self.post.address?.lng,
           let lat = self.post.address?.lat {
            self.post.coordinates = [long, lat]
        }
        //saving the current user information to the post user
        if let user = UserManager.getCurrentUser() {
            let postOwner = Friends()
            self.post.user = Friends()
            postOwner.profilePic = user.profilePicUrl
            postOwner.firstName = user.firstName
            postOwner.lastName = user.lastName
            postOwner.id = user.id
            postOwner.userName = user.userName
            self.post.user = postOwner
        }
        self.showLoader()
        OfflineSync().savePostLocally(post: self.post, success: {
            self.hideLoader()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if self.isModal {
                    UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
                    self.removeCurrentControllerFromStack()
                    appDelegate.popToRootViewController()
                }else{
                    if self.isComingFromActivity {
                        self.removeCurrentControllerFromStack()
                        appDelegate.popToRootViewController()
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        }) { (failure) in
            self.hideLoader()
            if let locDesc = failure.userInfo[NSLocalizedDescriptionKey] as? String {
                self.showAlert(message: locDesc)
            }
        }
    }


    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.captionTextView.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneTappedOnKeyboard(sender:)))
        self.setUpTagListContainer()
        if !isForCreatePost {
            self.initializePostMedia()
            setData()
        }
//        cossButton.addDoubleShadowToButton(cornerRadius: cossButton.frame.height / 2, shadowRadius: cossButton.frame.height / 2, lightShadowColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3), shadowBackgroundColor: UIColor.appThemeDarkGrayColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.navigationController?.navigationBar.isHidden = true
        self.addKeyboardNotificationObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.removeKeyboardNotificationObservers()
        self.navigationController?.setDefaultNavigationBar()
    }

    // MARK: Keyboard observers
    override func keyboardDisplayedWithHeight(value: CGRect) {
        self.containerViewBottomConstraint.constant = -value.height
    }

    // MARK: Helpers
    @objc private func doneTappedOnKeyboard(sender: UIBarButtonItem) {
        if !self.taglistContainerView.isHidden {
            self.tagUsersListController?.setTableViewVisibility(shouldHide: true)
        }
    }

    override func leftBarButtonTapped(button: UIBarButtonItem) {
        self.navigationController?.setDefaultNavigationBar()
    }

    /// pushes the search location screen on the navigation stack
    func pushToLocationViewController() {
        let locationVC:LocationViewController = UIStoryboard(storyboard: .main).initVC()
        locationVC.delegate = self
        self.navigationController?.pushViewController(locationVC, animated: true)
    }

    /// call this function to set the selected media from YPImagePicker to the current view
    func setData() {
        if let count = post.media?.count, count >= 2 {
            multipleImagesImageview.isHidden = false
        }else{
            multipleImagesImageview.isHidden = true
        }
        if let image = post.media![0].image {
            selectedImageView.image = image
        }
    }

    /// pop the current navigation stack to the image gallery with the selected media shown as selected
    private func popBackToImageGallery() {
        //check the navigation stack of the presented navigation controller which is of type YPImagePicker
        if let rootNavigation = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? YPImagePicker,
           let firstController = rootNavigation.viewControllers.first {
            self.navigationController?.popToViewController(firstController, animated: true)
        }
        else {
            switch self.type {
                case .activity:
                    //if it is not stack ,then push it
                    guard let inputImage = screenshot else { return }
                    let imageSaver = ImageSaver()
                    if Defaults.shared.get(forKey: .imageId) as? Int == nil{
                        imageSaver.writeToPhotoAlbum(image: inputImage)
                        imageSaver.imgID = Int(arc4random())
                        Defaults.shared.set(value: imageSaver.imgID , forKey: .imageId)
                    }
                    self.showYPPhotoGallery(showCrop: false, isPresentingFromCreatePost: true)
                default:
                    break
            }
        }
    }

    ///set the activity indicator view to the top right of the navigation bar
    private func setActivityIndicatorOnRightBarButton() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.style = .gray
        let rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        rightBarButtonItem.tintColor = UIColor.textBlackColor
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        activityIndicator.startAnimating()
    }

    // MARK: Validation
    private func hashTagsValidated() -> Bool {
        let hastagsCount = self.captionTextView.text.hashtags().count
        if hastagsCount > Constant.MaximumLength.hashTagsCount {
            self.showAlert(withTitle: "", message: AppMessages.Post.invalidHashtagsCount, okayTitle: AppMessages.AlertTitles.Ok, okCall: {

            })
            return false
        }
        return true
    }

    private func mediaSizeValidated() -> Bool {
        if let postMedia = self.post.media {
            for media in postMedia {
                if let data = media.data,
                   data.count >= AWSBucketFileSizeLimit {
                    return false
                }
            }
        }
        return true
    }

    // MARK: Initializer
    private func initializePostMedia() {
        switch self.type {
            case .normal:
                self.initializeNewPostWithYPMedia()
            case .activity, .goal, .challenge:
                self.createPostMediaWithImage()
        }
    }

    //pass the media items array picked from gallery
    func initializeNewPostWithYPMedia() {
        self.post.media = [Media]()
        self.iterateMediaItems()
    }

    /// updates the current post media object with new media items
    func updateCurrentPostWithYPMedia() {
        self.iterateMediaItems()
    }

    private func iterateMediaItems() {
        for mediaItem in self.mediaItems {
            let currentMedia = Media()
            switch mediaItem {
                case .photo(let photo):
                    currentMedia.image = photo.image
                    currentMedia.type = MediaType.photo
                    currentMedia.ext = MediaType.photo.mediaExt
                    currentMedia.data = photo.image.jpegData(compressionQuality: 0.5)

                   let renderedImage = self.resize(targetSize: CGSize(width: Constant.ScreenSize.IPHONE_MAX_WIDTH - 18, height: 420), image: photo.image)
                    currentMedia.height = Double(renderedImage.size.height)
                case .video(let video):
                    do {
                        currentMedia.data = try Data(contentsOf: video.url)
                    } catch {
                    }
                    currentMedia.ext = MediaType.video.mediaExt
                    currentMedia.type = MediaType.video
                    currentMedia.image = video.thumbnail
            }
            self.post.media?.append(currentMedia)
        }
        self.setData()
    }

    func resize(targetSize: CGSize, image: UIImage) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    //create the post media with the image
    func createPostMediaWithImage() {
        self.post.media = [Media]()
        guard let image = self.screenshot else {
            return
        }
        let media = Media()
        media.image = image
        media.type = MediaType.photo
        media.ext = MediaType.photo.mediaExt
        media.data = image.jpegData(compressionQuality: 0.5)
        media.height = Double(image.size.height)

        //add the media object
        self.post.media?.append(media)
    }
}

// MARK: TagUsersListViewDelegate
extension CreatePostViewController: TagUsersListViewDelegate {
    func didChangeTaggedList(taggedList: [TaggingModel]) {
        self.post.captionTags = taggedList.map({ $0.toUserTagModel() })
    }

    func didChangeTaggableList(isEmpty: Bool) {
       self.taglistContainerView.isHidden = isEmpty
    }

    func didSelectUserFromTagList(tagText: String, userId: String) {
        Tagging.sharedInstance.updateTaggedList(allText: captionTextView.text, tagText: tagText, id: userId)
    }

    func updateAttributedTextOnTagSelect(attributedValue: (NSMutableAttributedString, NSRange)) {
        self.captionTextView.attributedText = attributedValue.0.string.attributedStringFor(specialCharacter: "#", regex: RegEx.hashTag, color: UIColor.white)
        self.captionTextView.selectedRange = attributedValue.1
    }
}

// MARK: UITextViewDelegate
extension CreatePostViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //Tagging
        //update tag list
        Tagging.sharedInstance.updateTaggedList(range: range, textCount: text.utf16.count)
        if text.isEmpty {
            return true
        }
        let newText = NSString(string: textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= Constant.MaximumLength.postCaption
    }

    func textViewDidChange(_ textView: UITextView) {
        let caption = captionTextView.text
        captionTextView.attributedText = caption?.attributedStringFor(specialCharacter: "#", regex: RegEx.hashTag, color: UIColor.white)
        //Tagging
        // set listener for text view on which TAgging need to check
        Tagging.sharedInstance.tagging(textView: textView)
        // _ = Tagging.sharedInstance.updateAttributeText(txt:textView.text,selectedLocation: textView.selectedRange.location)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        //Tagging
        //tagging text view if changed
        Tagging.sharedInstance.tagging(textView: textView)
    }

}

// MARK: AddressDelegate
extension CreatePostViewController: AddressDelegate {
    func selectedAddress(address: Address, isGymLocation: Bool) {
        self.post.address = address
        self.locationLabel.text = address.formatted
        //right-arrowSmall
        self.locationArrowButton.setImage(UIImage(named: "close@3x"), for: .normal)
        self.addLocationButton.isUserInteractionEnabled = false
    }

}

// MARK: TagPeopleOnMediaControllerDelegate
extension CreatePostViewController: TagPeopleOnMediaControllerDelegate {
    func didTapDoneOnScreen(updatedMedia: [Media], taggedCount: Int) {
        self.post.media = updatedMedia
        self.totalTaggedCount = taggedCount
        guard taggedCount > 0 else {
            self.taggedPeopleLabel.text = ""
            return
        }
        var appendString = "Person".localized
        if taggedCount > 1 {
            appendString = "People".localized
        }
        self.taggedPeopleLabel.text = "\(taggedCount) \(appendString)"
    }
}

extension UIViewController {
    var isModal: Bool {
        return presentingViewController != nil ||
        navigationController?.presentingViewController?.presentedViewController === navigationController ||
        tabBarController?.presentingViewController is UITabBarController
    }
}
