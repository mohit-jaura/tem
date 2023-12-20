//
//  DIBaseController.swift
//  BaseProject
//
//  Created by narinder on 28/02/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import MediaPlayer
import Mute
import Lightbox
import Kingfisher
import SideMenu
import SSNeumorphicView
protocol ShowErrorMessage {
    func showError(tag:Int)
}


enum Controller {
    case login
    case signUp
    case resetPassword
    case forgotPassword
}

enum ButtonTitle:String {
    case firstName = "firstName"
    case lastName = "lastName"
    case emailOrPhone = "emailOrPhone"
    case phoneNo = "phoneNo"
    case email = "email"
    case phone = "phone"
    case password = "password"
    case newPassword = "newPassword"
    case confirmPassword = "confirmPassword"
    
}

class DIBaseController: UIViewController,TableViewXibDelegate,ReportMessageViewDelegate,ActivitySheetProtocol {
    
    // var diLoader: DILoader!
    static var errorDelegate:ShowErrorMessage?
    var returnKeyHandler: IQKeyboardReturnKeyHandler!
    static var currentController:Controller = .login
    var lat:Double = 0
    var long:Double = 0
    var address = ""
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var validationMessage = ""
    var datePickerView:UIDatePicker?
    
    var lightBoxImage:[LightboxImage] = []
    
    var picker: YPImagePicker?
    
    var viewerController: ViewerController?
    var viewableArr:[Photo] = []
    
    private var observerAdded: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.delegate = self
    }
    
    //This method will change all textfield return keys next or done accoring to their view heierachy.
    func viewDidLoadWithKeyboardManager( viewController: UIViewController) {
        super.viewDidLoad()
        returnKeyHandler = IQKeyboardReturnKeyHandler.init(controller: viewController)
        returnKeyHandler.lastTextFieldReturnKeyType = .done
    }
    
    
    // didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///
    /// - Returns: It returns Back button and you can use any where in child classes.
    func getBackButton() -> UIButton {
        let buttonBack = UIButton(type: .custom)
        buttonBack.setImage(UIImage(named: "<")?.withRenderingMode(.alwaysTemplate), for: .normal)
        buttonBack.tintColor = UIColor.appThemeColor
        buttonBack.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        buttonBack.addTarget(self, action: #selector(self.popToBackScreen), for: .touchUpInside)
        return buttonBack
    }
    
    ///
    /// - Returns: It returns Back button and you can use any where in child classes.
    func getSkipButton() -> UIBarButtonItem {
        let skipButton = UIButton(type: .custom)
        skipButton.setTitle("SKIP", for: .normal)
        skipButton.setTitleColor(.lightGray, for: .normal)
        skipButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        skipButton.titleLabel?.font = UIFont(name: UIFont.robotoMedium, size: 15)
        skipButton.addTarget(self, action: #selector(self.navigateToInterestScreen), for: .touchUpInside)
        return UIBarButtonItem(customView: skipButton)
    }
    
    func dateFormatter(format:Constant.DateFormates) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    func uploadImg(_ image:UIImage?,completion:@escaping (_ imageUrl: String?) ->()){
        guard let image = image,let data = image.jpegData(compressionQuality: 0.5)  else { return }

            let firImageName = (User.sharedInstance.firebaseProfileImageName ?? "") + Utility.shared.getFileNameWithDate()
            // Method changes
            UploadMedia.shared.configureDataToUpload(type: .awsBucket, data: data, withName: firImageName, mimeType: "image/jpeg", mediaObj: Media())
            UploadMedia.shared.uploadImage(success: { (url, media) in
                completion(url)
            }) { (error) in
                self.hideLoader()
                self.alertOpt(error.message)
            }
        }

    func timeZoneDateFormatter(format:Constant.DateFormates,timeZone:TimeZone? = NSTimeZone.local) -> DateFormatter {
        let formatter = dateFormatter(format:format)
        formatter.timeZone = timeZone
        return formatter
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func setToggleShadow(_ view:SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.height / 2
    }
    func setNeumorphicView(view: SSNeumorphicView){
        view.viewDepthType = .outerShadow
        view.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.25).cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.25).cgColor
        view.viewNeumorphicMainColor = UIColor.black.cgColor
        view.viewNeumorphicCornerRadius = 8.0
        view.viewNeumorphicShadowOpacity = 0.6
        
    }
    
    @objc func navigateToInterestScreen() {
        if (Reachability.isConnectedToNetwork()) {
            let selectInterestVC : SelectInterestViewController = UIStoryboard(storyboard: .main).initVC()
            self.navigationController?.pushViewController(selectInterestVC, animated: true)
        } else {
            let message = AppMessages.AlertTitles.noInternet
            AlertBar.show(.error, message: message)
        }
    }
    
    func warningButton(tag:Int ) -> UIButton {
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(#imageLiteral(resourceName: "Error"), for: .normal)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rightButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        //  validationMessage = message
        rightButton.tag = tag
        rightButton.addTarget(self, action: #selector(self.showValidationAlert), for: .touchUpInside)
        return rightButton
    }
    
    func rightValidationButton() -> UIButton {
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(#imageLiteral(resourceName: "right"), for: .normal)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rightButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        rightButton.isUserInteractionEnabled = false
        return rightButton
    }
    
    @objc func showValidationAlert(_ target:UIButton) {
        DIBaseController.errorDelegate?.showError(tag: target.tag)
    }
    

    func openSetting() {
        self.showAlert(withTitle: AppMessages.Location.title, message: DIError.locationPermissionDenied().message, okayTitle: "Settings".localized, cancelTitle: "Cancel", okCall: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL)
        }, cancelCall: {
        })
    }
    
    func showActionSheet(title:String,message:String,buttonTitle:String,shouldShowRejectButton:Bool =
        false,style:UIAlertAction.Style,completion:@escaping () -> (),rejectCompletion:(() -> ())?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: buttonTitle, style: style , handler:{ (UIAlertAction) in
            completion()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction) in
        }))
        
        if shouldShowRejectButton {
            alert.addAction(UIAlertAction(title: AppMessages.ProfileMessages.reject, style: .destructive , handler:{ (UIAlertAction)in
                // do stuff!
                rejectCompletion?()
            }))
        }
        self.present(alert, animated: true, completion: {
        })
    }
    
    // MARK: Function to add TableView.
    func addTableView(indexPath:IndexPath) {
        let window = UIApplication.shared.keyWindow
        let  nibView = Bundle.main.loadNibNamed("TableViewXib" , owner: self, options: nil)?.first as? TableViewXib
        nibView?.frame = CGRect(x: 0, y: 0, width: (window?.frame.width)!, height: (window?.frame.height)!)
        nibView?.alpha = 0.0
        nibView?.dimView.alpha = 0.0
        nibView?.setData(height: (window?.frame.height)!)
        nibView?.delegate = self
        nibView?.indexPath = indexPath
        window?.addSubview(nibView!)
        UIView.animate(withDuration: 0.2, animations: {
            nibView?.transform = .identity
            nibView?.dimView.alpha = 0.4
            nibView?.alpha = 1.0
            
            self.view.layoutIfNeeded()
        }) { (true) in
            
        }
    }
    
    
    func showSelectionModal(array: [Any], type: SheetDataType, multiSelectionOn: Bool? = false, selectedIndices: [Int]? = nil, indexSelected:IndexSelected? = nil) {
        self.view.endEditing(true)
        let window = UIApplication.shared.keyWindow
        if (window?.viewWithTag(111)) != nil {
            return
        }
        let nibView = Bundle.main.loadNibNamed("ActivitySheet" , owner: self, options: nil)?.first as? ActivitySheet
        nibView?.frame = CGRect(x: 0, y: (window?.frame.height)!, width: (window?.frame.width)!, height: (window?.frame.height)!)
        nibView?.delegate = self
        nibView?.alpha = 0.0
        nibView?.tag = 111
        nibView?.dimView.alpha = 0.0
        nibView?.configureSheet(actionSheetArray: array, type: type, multipleSelectionOn: multiSelectionOn!, selectedIndices: selectedIndices,indexSelected: indexSelected)
        nibView?.initialize()
        window?.addSubview(nibView ?? UIView())
        UIView.animate(withDuration: 0.3, animations: {
            nibView?.frame.origin.y =  (nibView?.frame.origin.y ?? 0) - (window?.frame.height)!
            self.view.layoutIfNeeded()
            nibView?.alpha = 1.0
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                nibView?.dimView.alpha = 0.6
            })
        }
        
    }
    
    func handleSelection(index: Int, type: SheetDataType) {
    }
    
    func handleSelection(indices: [Int], type: SheetDataType) {
    }
    
    func cancelSelection(type: SheetDataType) {
    }
    
    func didSelectRowWithValue(data: Any, type: SheetDataType) {
        if type == .taggedList {
            if let taggedUser = data as? UserTag,
                let userId = taggedUser.id,
                let currentUserId = UserManager.getCurrentUser()?.id {
                let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                if userId != currentUserId {
                    //if this is not my profile
                    profileController.otherUserId = userId
                }
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
    }
    
    
    // MARK: Function to add TableView.
    func addReportMessageView(index:Int) {
        let window = UIApplication.shared.keyWindow
        let  nibView = Bundle.main.loadNibNamed("ReportMessageView" , owner: self, options: nil)?.first as? ReportMessageView
        nibView?.frame = CGRect(x: 0, y: 0, width: (window?.frame.width)!, height: (window?.frame.height)!)
        nibView?.alpha = 0.0
        nibView?.dimView.alpha = 0.0
        nibView?.delegate = self
        nibView?.index = index
        UIApplication.topViewController()?.view.addSubview(nibView!)
        UIView.animate(withDuration: 0.2, animations: {
            nibView?.transform = .identity
            nibView?.dimView.alpha = 0.4
            nibView?.alpha = 1.0
            
            self.view.layoutIfNeeded()
        }) { (true) in
            
        }
    }
    
    func getReportMessage(decription: String,index:Int) {
        
    }
    
    func setData(selectedData: ReportData, indexPath: IndexPath) {
        
    }
    
    
    /// Used to pop to previous controller.
    @objc func popToBackScreen(){
        _ =  self.navigationController?.popViewController(animated: true)
    }
    
    /// This Method is used to display the Error to user
    ///
    /// - Parameter error: Error Generated By System
    /// - Author: Aj Mehra
    func showAlert(withError error: DIError = DIError.unKnowError(), okayTitle:String = AppMessages.AlertTitles.Ok , cancelTitle:String? = nil , okCall:@escaping () -> ()  = {  }, cancelCall: @escaping () -> () = {  }) {
        showAlert(message: error.message, okCall: {
            okCall()
        }) {
            cancelCall()
        }
    }
   
    func alertOpt(_ error: String?, okayTitle:String = AppMessages.AlertTitles.Ok , cancelTitle:String? = nil , okCall:OnlySuccess? = nil, cancelCall: OnlySuccess? = nil,parent:DIBaseController? = nil) {
        showAlert(withTitle: error ?? "Some error occured",okayTitle:okayTitle,cancelTitle:cancelTitle, okCall: {
            okCall?()
        },parent:parent) {
            cancelCall?()
        }
    }
   
    
    func showAlert(withTitle title: String = "", message:String? = nil, okayTitle:String = AppMessages.AlertTitles.Ok , cancelTitle:String? = nil,okStyle:UIAlertAction.Style = .default, okCall:@escaping () -> ()  = {  }, cancelCall: @escaping () -> () = {  },parent:DIBaseController? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okayTitle, style: okStyle, handler: { (action) in
            okCall()
        }))
        if cancelTitle != nil {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                cancelCall()
            }))
        }
        if parent != nil {
            parent?.present(alert, animated: true, completion: nil)
        }else {
            present(alert, animated: true, completion: nil)
        }
    }
    
    func chooseImage(picker: UIImagePickerController){
        picker.allowsEditing = true
        if !(UIImagePickerController.availableMediaTypes(for: .camera) != nil){
            picker.sourceType = .photoLibrary
        }else{
            picker.sourceType = .camera
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    func setNavigationControllerTitleAndWithMenuButton(titleName:String,leftbutton1:UIButton?,leftbutton2:UIButton?,backGroundColor:UIColor,right_item1:UIButton?,right_item2:UIButton?,translucent:Bool){
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.2399999946, green: 0.25, blue: 0.3300000131, alpha: 1)]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = translucent
        self.navigationController?.navigationBar.barTintColor = backGroundColor
        self.title = titleName
        
        if leftbutton2 != nil {
            let item1 = UIBarButtonItem(customView: leftbutton1!)
            let item2 = UIBarButtonItem(customView: leftbutton2!)
            self.navigationItem.leftBarButtonItems = [item1, item2]
        } else {
            if leftbutton1 != nil {
                let item1 = UIBarButtonItem(customView: leftbutton1!)
                self.navigationItem.leftBarButtonItem = item1
            }
        }
        
        if right_item2 != nil {
            let item1 = UIBarButtonItem(customView: right_item1!)
            let item2 = UIBarButtonItem(customView: right_item2!)
            self.navigationItem.rightBarButtonItems = [item1, item2]
        } else {
            if right_item1 != nil {
                let item1 = UIBarButtonItem(customView: right_item1!)
                self.navigationItem.rightBarButtonItem = item1
            }
        }
    }
    
    func configureNavBarLeftBarButton(image: UIImage? = #imageLiteral(resourceName: "left-arrow")) {
        let button = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(leftBarButtonTapped(button:)))
        self.navigationItem.leftBarButtonItem = button
    }
    
    @objc func leftBarButtonTapped(button: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setNavigationController(titleName:String,leftBarButton:[UIBarButtonItem]?,rightBarButtom:[UIBarButtonItem]?,backGroundColor:UIColor,translucent:Bool){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.textBlackColor]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: UIFont.robotoBold, size: 17) ?? UIFont.systemFont(ofSize: 14)]
        if rightBarButtom != nil {
            //changing the common attributes of all right bar buttons
            let fontAttribute = [NSAttributedString.Key.font : UIFont(name: UIFont.robotoMedium, size: 15) ?? UIFont.systemFont(ofSize: 14)]
            _ = rightBarButtom!.map { (barButton) -> UIBarButtonItem in
                barButton.setTitleTextAttributes(fontAttribute, for: .normal)
                barButton.setTitleTextAttributes(fontAttribute, for: .highlighted)
                barButton.setTitleTextAttributes(fontAttribute, for: .selected)
                return barButton
            }
        }
        self.navigationController?.navigationBar.isTranslucent = translucent
        self.navigationController?.navigationBar.barTintColor = backGroundColor
        self.title = titleName
        self.navigationItem.leftBarButtonItems = leftBarButton
        self.navigationItem.rightBarButtonItems = rightBarButtom
    }
    
    func  handleDeepLinkOfPostShare(id: String) {
        let tabBarVC:HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
        appDelegate.setNavigationToRoot(viewContoller: tabBarVC, animated: true)
        appDelegate.redirectToPostDetails(withPostId: id)
    }

    func  handleDeepLinkOfAffiliateShare(id: String) {
        let tabBarVC:HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
        appDelegate.setNavigationToRoot(viewContoller: tabBarVC, animated: true)
        appDelegate.redirectToAffiliateLandingPage(marketPlaceId: id)
    }
    // MARK: ImagePicker Custom Functions
    /// Presenting sheet with option to select image source
    func presentActionSheet(actionSheetTitle: String = "Choose from", message: String = "Please select an option", actionsBtnTitles: [String], cancelTitle: String = "Cancel") {
        let alertController = UIAlertController(title: actionSheetTitle, message: message, preferredStyle: .actionSheet)
        for (index, element) in actionsBtnTitles.enumerated() {
            let button = UIAlertAction(title: element, style: .default, handler: { (action) -> Void in
                self.actionSheetButtonTapped(index: index, titles: actionsBtnTitles)
            })
            alertController.addAction(button)
        }
        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) -> Void in
            // self.actionSheetButtonTapped(index: actionsBtnTitles.count, titles: actionsBtnTitles)
        })
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //Override This method where you are adding actionsheet
    func actionSheetButtonTapped(index: Int, titles: [String]) {
    }
    
    
    func addDatePicker(textfield: UITextField,selectedDate:Date? = Date()) {
        datePickerView = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePickerView?.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        datePickerView!.datePickerMode = UIDatePicker.Mode.date
        datePickerView?.setDate(selectedDate!, animated: true)
        let maximumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        let minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        datePickerView?.minimumDate = minimumDate
        datePickerView?.maximumDate = maximumDate
        textfield.inputView = datePickerView
        datePickerView?.addTarget(self, action: #selector(self.datePickerValueChanged), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
    }
    
    // MARK: YPImagePicker
    /// present the photo gallery with the specified configuration
    func showYPPhotoGallery(showCrop: Bool? = true, isPresentingFromCreatePost: Bool? = false,isFromFoodTrek:Bool = false,showOnlyVideo: Bool = false) {
        var config = YPImagePickerConfiguration()
        if isFromFoodTrek {
            config.library.maxNumberOfItems = 1
            config.library.mediaType = .photo
            config.targetImageSize = YPImageSize.original
            config.screens = [.library, .photo]
            config.hidesStatusBar = false
            config.maxNumberOfItems = 1
            if showCrop! {
                config.showsCrop = .rectangle(ratio: 1.1)
            }
            picker?.modalPresentationStyle = .fullScreen
            picker = YPImagePicker(configuration: config)
            picker?.isEditing = true
            picker?.navigationBar.backgroundColor = .white
            //handle selection
            picker?.didFinishPicking(completion: {[weak self, isPresentingFromCreatePost] (mediaItems, isCancelled) in
                if !isCancelled {
                    self?.handleAfterMediaSelection(withMedia: mediaItems, isPresentingFromCreatePost: isPresentingFromCreatePost ?? false,isFromFoodTrek:true)
                } else {
                    self?.picker?.dismiss(animated: true, completion: nil)
                }
            })
            self.present(picker!, animated: true, completion: nil)
        } else {
            if showOnlyVideo{
                config.library.mediaType = .video
                config.screens = [.library, .video]
            }else{
                config.library.mediaType = .photoAndVideo
                config.screens = [.library, .photo, .video]
            }
            config.library.maxNumberOfItems = 10
            config.targetImageSize = YPImageSize.original
            
            config.video.recordingTimeLimit = 119
            config.video.libraryTimeLimit = 120
            config.hidesStatusBar = true
            config.video.minimumTimeLimit = 3.0
            config.video.trimmerMaxDuration = 119
            config.video.trimmerMinDuration = 3.0
            config.maxNumberOfItems = 2
            if showCrop! {
                config.showsCrop = .rectangle(ratio: 1.1)
            }
            picker?.modalPresentationStyle = .overFullScreen
            picker = YPImagePicker(configuration: config)
            picker?.isEditing = true
            picker?.navigationBar.backgroundColor = .white
            //handle selection
            picker?.didFinishPicking(completion: {[weak self, isPresentingFromCreatePost] (mediaItems, isCancelled) in
                if !isCancelled {
                    self?.handleAfterMediaSelection(withMedia: mediaItems, isPresentingFromCreatePost: isPresentingFromCreatePost ?? false)
                } else {
                    self?.picker?.dismiss(animated: true, completion: nil)
                }
            })
           self.present(picker!, animated: true, completion: nil)
        }
        
    }
    
    func handleAfterMediaSelection(withMedia items: [YPMediaItem], isPresentingFromCreatePost: Bool,isFromFoodTrek:Bool = false) {
        if isFromFoodTrek {

            let addFoodTrekViewController: AddFoodTrekViewController = UIStoryboard(storyboard: .foodTrek).initVC()
            addFoodTrekViewController.mediaItems = items
            self.picker?.pushViewController(addFoodTrekViewController, animated: true)
        } else {
            if isPresentingFromCreatePost {
              //  we need to dismiss the current controloler with passed media items
                if let createPostVC = self as? CreatePostViewController {
                    createPostVC.mediaItems = items
                    createPostVC.updateCurrentPostWithYPMedia()
                    self.picker?.dismiss(animated: true, completion: nil)
                }
            }
            let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()
            createPostVC.mediaItems = items
            createPostVC.isFromActivityLog = false
            self.picker?.pushViewController(createPostVC, animated: true)
        }
}

    //Keyboard notification observers
    func addKeyboardNotificationObservers() {
        self.removeKeyboardNotificationObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeKeyboardNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
          if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
              let keyboardHeight = keyboardFrame.cgRectValue
              // Do something...
            self.keyboardDisplayedWithHeight(value: keyboardHeight)
          }
      }
    
    //Will trigger when the keyboard is displayed
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardDisplayedWithHeight(value: keyboardSize)
        }
    }
    
    //Will trigger on resign first responder
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHide(height: keyboardSize.height)
        }
    }
    
    func setIQKeyboardManager(toEnable status: Bool) {
        IQKeyboardManager.shared.enable = status
        IQKeyboardManager.shared.enableAutoToolbar = status
    }
    
    func keyboardDisplayedWithHeight(value: CGRect) {
        //implement in the child class
    }
    
    func keyboardHide(height: CGFloat) {
        //implement in the child class
    }
    
    //implement in child classes to auto play videos
    func fullScreenPreviewDidDismiss() {}
    
    func presentSideMenuWith(menuPresentMode: SideMenuPresentationStyle, screenType: Constant.ScreenFrom, groupId: String? = nil, menuWidth: CGFloat? = nil, shadowColor: UIColor? = nil) {
        let leftView = UIStoryboard(name: "Sidemenu", bundle: nil)
        guard let viewcontroller : SideMenuNavigationController = leftView.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController else{
            return
        }
        SideMenuManager.default.rightMenuNavigationController = viewcontroller
        let sideMenuController: RightSideMenuController = UIStoryboard(name: "Sidemenu", bundle: nil).initVC()
        sideMenuController.groupId = groupId
        sideMenuController.screenType = screenType
        viewcontroller.viewControllers = [sideMenuController]
        viewcontroller.settings.presentationStyle = menuPresentMode
        viewcontroller.settings.statusBarEndAlpha = 0
        viewcontroller.settings.presentationStyle.backgroundColor = .red
        if let width = menuWidth {
            viewcontroller.settings.menuWidth = width
        }
        if let color = shadowColor {
            viewcontroller.settings.presentationStyle.onTopShadowColor = color
            viewcontroller.settings.presentationStyle.onTopShadowRadius = 5.0
            viewcontroller.settings.presentationStyle.onTopShadowOpacity = 0.5
        }
        self.present(SideMenuManager.default.rightMenuNavigationController!, animated: true, completion: nil)
    }
    
    func presentLeftSideMenuWith(menuPresentMode: SideMenuPresentationStyle, menuWidth: CGFloat? = nil, shadowColor: UIColor? = nil) {
        let leftView = UIStoryboard(name: "Sidemenu", bundle: nil)
        guard let viewcontroller : SideMenuNavigationController = leftView.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController else{
            return
        }
        SideMenuManager.default.leftMenuNavigationController = viewcontroller
        let sideMenuController: LeftSideMenuController = UIStoryboard(name: "Sidemenu", bundle: nil).initVC()
        viewcontroller.viewControllers = [sideMenuController]
        viewcontroller.settings.presentationStyle = menuPresentMode
        viewcontroller.settings.statusBarEndAlpha = 0
        if let width = menuWidth {
            viewcontroller.settings.menuWidth = width
        }
        if let color = shadowColor {
            viewcontroller.settings.presentationStyle.onTopShadowColor = color
            viewcontroller.settings.presentationStyle.onTopShadowRadius = 5.0
            viewcontroller.settings.presentationStyle.onTopShadowOpacity = 0.5
        }
        self.present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
}

extension DIBaseController: NVActivityIndicatorViewable {
    /*
     Show loader will add the custom loader view to current controller
     */
    //  AppMessages.AlertTitles.pleaseWait
    func showLoader(message: String = "", color: UIColor = .white) {
            let size = CGSize(width: 50, height:50)
            self.startAnimating(size, message: message, messageFont: UIFont.systemFont(ofSize: 12), color: color, padding: 0, displayTimeThreshold: 0, minimumDisplayTime: 0)

    }
    
    
    /*
     Hide loader will from remove its superview and hide loader from current view
     */
    func hideLoader() {
        stopAnimating()
    }

}//Extension

extension DIBaseController {
    func isConnectedToNetwork(shouldShowMessage:Bool = true) -> Bool {
        if Reachability.isConnectedToNetwork() {
            return true
        }
        self.hideLoader()
        if shouldShowMessage {
            self.noInternetConnectionMessage()
        }
        return false
    }
    
    func noInternetConnectionMessage(){
        let message = AppMessages.AlertTitles.noInternet
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: AppMessages.AlertTitles.Ok, style: .cancel, handler: nil)
        alert.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension DIBaseController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }
}

extension DIBaseController : UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if (navigationController.viewControllers.count > 1) {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            navigationController.interactivePopGestureRecognizer?.isEnabled = true 
        } else {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            navigationController.interactivePopGestureRecognizer?.isEnabled = false 
        }
    }
}

extension DIBaseController {
    func presentFullScreenPreview(forPost post: Post, atIndex index: Int, collectionView: UICollectionView, currentDuration: Double? = nil) {
        viewableArr.removeAll()
        getViewableObject(post: post, atIndex: index)
        let indexPath = IndexPath(item: index, section: 0)
        self.viewerController = ViewerController(initialIndexPath: indexPath, collectionView: collectionView)
        self.viewerController!.dataSource = self
        self.viewerController!.delegate = self
        self.viewerController?.autoplayVideos = true
        if let duration = currentDuration {
            self.viewerController?.currentDuration = duration
        }
        UIApplication.topViewController()?.navigationController?.present(viewerController!, animated: true, completion: nil)
    }
    
    func getViewableObject(post: Post, atIndex index: Int) {
        if let media = post.media {
            for (index,data) in media.enumerated(){
                if data.type == .video {
                    // Add video with poster photo
                    if let serverPath = data.url {
                        let photo = Photo(id: data.id ?? "\(index)")
                        photo.type = .video
                        photo.url = serverPath
                        ImageCache.default.retrieveImage(forKey: data.previewImageUrl ?? "" ) {  result in
                            switch result {
                            case .success(let value):
                                if value.image != nil {
                                    photo.placeholder = value.image!
                                } else {
                                    photo.placeholder = #imageLiteral(resourceName: "ImagePlaceHolder")
                                }
                            case .failure(_):
                                return
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
                                if value.image != nil {
                                    photo.placeholder = value.image!
                                } else {
                                    photo.placeholder = #imageLiteral(resourceName: "ImagePlaceHolder")
                                }
                            case .failure(_):
                                return
                            }
                        }
                        self.viewableArr.append(photo)
                    }
                }
            }
        }
    }
}

extension DIBaseController: ViewerControllerDataSource {
    
    func numberOfItemsInViewerController(_: ViewerController) -> Int {
        return self.viewableArr.count
    }
    
    func viewerController(_: ViewerController, viewableAt indexPath: IndexPath) -> Viewable {
        let viewable = self.viewableArr[indexPath.row]
        return viewable
    }
}//Extension.....

extension DIBaseController: ViewerControllerDelegate {
    func viewerController(_: ViewerController, didChangeFocusTo _: IndexPath) {}
    
    func viewerControllerDidDismiss(_: ViewerController) {
        #if os(tvOS)
        // Used to refocus after swiping a few items in fullscreen.
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        #endif
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: false, controller: self)
        }
        self.fullScreenPreviewDidDismiss()
    }
    
    func viewerController(_: ViewerController, didFailDisplayingViewableAt _: IndexPath, error _: NSError) {
        
    }
    
    func viewerController(_ viewerController: ViewerController, didLongPressViewableAt indexPath: IndexPath) {
    }
}

