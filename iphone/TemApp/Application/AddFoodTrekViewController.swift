//
//  AddFoodTrekViewController.swift
//  TemApp
//
//  Created by Developer on 28/02/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift
class AddFoodTrekViewController: DIBaseController {

    @IBOutlet weak var lineShadowView: SSNeumorphicView!{
        didSet{
            lineShadowView.viewDepthType = .outerShadow
            lineShadowView.viewNeumorphicCornerRadius = 12
            lineShadowView.viewNeumorphicMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        }
    }
    @IBOutlet weak var taggedPeopleLabel: UILabel!
    @IBOutlet weak var taglistContainerView: UIView!
    @IBOutlet weak var captionView: SSNeumorphicView!{
        didSet{
            setShadow(view: captionView, shadowType: .innerShadow)
        }
    }
    @IBOutlet weak var captionTextView: UITextView!
    @IBAction func selectedImagesTapped(_ sender: UIButton) {
        popBackToImageGallery()
        //  self.popBackToImageGallery()
    }
    // pop the current navigation stack to the image gallery with the selected media shown as selected

    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var newGoalOrChallengeButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: newGoalOrChallengeButtonShadowView, shadowType: .outerShadow, cornerRadius: newGoalOrChallengeButtonShadowView.frame.width / 2, shadowRadius: 5)
        }
    }

    @IBOutlet weak var newGoalOrChallengeButtonGradientView:GradientDashedLineCircularView!

    var todayTimeStamp:Int?
    var fireBaseURL:String = ""
    let currentMedia = Media()
    var type: PostType = .normal
    var mediaItems = [YPMediaItem]()
    var trekAddVC:TreekAddVC?
    private var tagUsersListController: TagUsersListViewController?
    var post = Post()
    private var totalTaggedCount = 0
    var taggedPeople: [UserTag]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createGradientView(view: newGoalOrChallengeButtonGradientView)
        iterateMediaItems()
        setUpTagListContainer()
        // Do any additional setup after loading the view.
        captionTextView.textColor = .white

    }


    func createGradientView(view:GradientDashedLineCircularView){
        view.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        view.instanceWidth = 2.0
        view.instanceHeight = 7.0
        view.extraInstanceCount = 1
        view.lineColor = UIColor.gray
        view.updateGradientLocation(newLocations: [NSNumber(value: 0.00),NSNumber(value: 0.99)], addAnimation: false)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func backTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        trekAddVC = UIStoryboard(storyboard: .foodTrek).initVC()
        if let trekAddVC = trekAddVC {
            trekAddVC.delegate = self
            self.present(trekAddVC, animated: true, completion: nil)
        }
    }
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

    private func popBackToImageGallery() {
        //check the navigation stack of the presented navigation controller which is of type YPImagePicker
        if let rootNavigation = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? YPImagePicker,
           let firstController = rootNavigation.viewControllers.first {
            self.navigationController?.popToViewController(firstController, animated: true)
        }
    }
    func generateCurrentDayTimeStamp(_ date: Date) -> Int {
        let dateString = timeZoneDateFormatter(format: .eventDate, timeZone: utcTimezone).string(from: date)
        let timeString = timeZoneDateFormatter(format: .eventTime, timeZone: utcTimezone).string(from: date)
        let fullDate = "\(dateString)T\(timeString)".convertToDate()
        return fullDate.timestampInMilliseconds
    }

    func uploadMediaToFireBase(value:Int = 1,failure: @escaping (DIError) -> ()) {
        showLoader()
        var mediaId:String?
        let media = currentMedia
        //skip the media object if it is already has the firebase url

        guard let data = media.data else { return }
        if let id = media.id {
            mediaId = id
        }

        let mimeType = media.mimeType
        let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        DispatchQueue.main.async {
            AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: mimeType ?? "", key: "file", fileName: filepath) { (_, firebaseUrl, error, _)  in
                if let url = firebaseUrl {
                    self.fireBaseURL  =  url
                    self.createFoodTrek(value:value)
                }
                else {
                    failure(error)
                }
            }
        }
    }

    private func iterateMediaItems() {
        for mediaItem in self.mediaItems {

            switch mediaItem {
                case .photo(let photo):
                    currentMedia.image = photo.image
                    currentMedia.type = MediaType.photo
                    currentMedia.ext = MediaType.photo.mediaExt
                    currentMedia.data = photo.image.jpegData(compressionQuality: 0.5)
                    selectedImageView.image = photo.image

                case .video(_):
                    break
            }
            self.post.media = [currentMedia]
        }
    }

    private func createFoodTrek(value:Int = 1) {
        guard isConnectedToNetwork() else {
            return
        }
        let currentDate = Utility.timeZoneDateFormatter(format: .editEventDate, timeZone: utcTimezone).string(from: Date())
        todayTimeStamp = Date().timeStamp
        var taggedUsersDict:[[String: Any]] = []

        if let user = post.media?[0].taggedPeople{
            for taggedUser in user{
                let taggedUsers:[String: Any] = [
                    "first_name":taggedUser.firstName ?? "",
                    "last_name":taggedUser.lastName ?? "",
                    "positionX":taggedUser.centerX ?? "",
                    "positionY":taggedUser.centerY ?? "",
                    "profile_pic":taggedUser.profilePic ?? "",
                    "text": taggedUser.text ?? "",
                    "id": taggedUser.id ?? ""
                ]
                taggedUsersDict.append(taggedUsers)
            }
        }

        var captionTaggedDict:[[String: Any]] = []
        if let captionTaggedId = post.captionTags{
            for taggedUser in captionTaggedId{
                let taggedUsers:[String: Any] = [
                    "id": taggedUser.id ?? "",
                    "text": taggedUser.text ?? ""
                ]
                captionTaggedDict.append(taggedUsers)
            }
        }
        let dict:[String: Any] = [
            "text":captionTextView.text ?? "",
            "image": fireBaseURL ,
            "trek": value, "date":todayTimeStamp ?? 0,
            "foodTrekDate": currentDate,
            "captionTagIds": captionTaggedDict,
            "postTagIds": taggedUsersDict
        ]

        DIWebLayerUserAPI().addFoodTrek(parameters: dict, success: { (_) in
            self.hideLoader()
            if self.isModal {
                self.performSegue(withIdentifier: "UnwindToFoodTrekList", sender: self)
            }
        }) { [weak self] (error) in
            self?.hideLoader()
            if let trekAddVC = self?.trekAddVC {
                trekAddVC.showAlert(withError: error) {
                    trekAddVC.dismiss(animated: true)
                } cancelCall: {
                    // cancel call
                }
            }
        }
    }

    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicCornerRadius = 14
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
    }

    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.white.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
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

    @objc private func doneTappedOnKeyboard(sender: UIBarButtonItem) {
        if !self.taglistContainerView.isHidden {
            self.tagUsersListController?.setTableViewVisibility(shouldHide: true)
        }
    }

}

extension AddFoodTrekViewController:TrekDelegate {

    func setTrekValue(value:Int) {
        uploadMediaToFireBase(value : value) { (_) in
            // do nothing ?
        }
    }
}


extension AddFoodTrekViewController: TagUsersListViewDelegate {
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
// MARK: TagPeopleOnMediaControllerDelegate
extension AddFoodTrekViewController: TagPeopleOnMediaControllerDelegate {
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

extension AddFoodTrekViewController: UITextViewDelegate {
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
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        //Tagging
        //tagging text view if changed
        Tagging.sharedInstance.tagging(textView: textView)
    }

}
