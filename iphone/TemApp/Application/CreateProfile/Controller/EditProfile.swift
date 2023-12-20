//
//  EditProfile.swift
//  TemApp
//
//  Created by Narinder Singh on 23/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher
import SSNeumorphicView


protocol EditProfileViewDelegate: AnyObject {
    func didEditProfileInformation(user: User)
}
class EditProfile: DIBaseController {

    // MARK: Variables.....
    weak var delegate: EditProfileViewDelegate?
    var photoManager:PhotoManager!
    var gender:Int = 1
    var tempDate:String = ""
    var regiseterUser:User = User()
    var isUserImageChanged:Bool = false
    var userSuggestionList:[String] = [String]()
    var index = 0
    private var lastFilledPercent = 0.0
    private var userNameAlreadyExistMsg: String?
    var isProfileDashboardView = false
    //variable saving the social login information
    var socialLoginInfo: Login?
    private var gymType: GymLocationType?
    private let fadedGradientPercent: NSNumber = 0.75
    // MARK: @IBOutlets...
    
    // MARK: UImageView...
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    // MARK: TextField....
    @IBOutlet weak var gymClubButton: UIButton!
    @IBOutlet weak var userNameTextField: CustomTextField!
    @IBOutlet weak var dateOfBirthTextField: CustomTextField!
    @IBOutlet weak var locationTextField: CustomTextField!
    @IBOutlet weak var heightTextField: CustomTextField!
    @IBOutlet weak var weightTextField: CustomTextField!
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var gymClubTextField: CustomTextField!
    @IBOutlet weak var userNameFieldStackView: UIStackView!
    @IBOutlet weak var fnTextField: CustomTextField!
    @IBOutlet weak var lnTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var innerStackView: UIStackView!
    @IBOutlet weak var verifyPhn: UIButton!
    @IBOutlet weak var verifyEmail: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var emailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var heightViwHeight: NSLayoutConstraint!
    @IBOutlet weak var weightViewHeight: NSLayoutConstraint!
    // MARK: UIButton.....
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var maleButtonOutlet: UIButton!
    @IBOutlet weak var femaleButtonOutlet: UIButton!
    @IBOutlet weak var naButtonOutlet: UIButton!
    @IBOutlet weak var homeGymRadioButton: UIButton!
    @IBOutlet weak var otherGymRadioButton: UIButton!
    @IBOutlet var backView: [SSNeumorphicView]!
    @IBOutlet weak var submitShadowView: SSNeumorphicView!{
        didSet{
            submitShadowView.setOuterDarkShadow()
        }
    }
    @IBOutlet weak var gradientView: GradientDashedLineCircularView!
    @IBOutlet weak var gradientOuterShadowView: UIView!
    @IBOutlet weak var gradientInnerShadowView: SSNeumorphicView! {
        didSet {
            gradientInnerShadowView.viewNeumorphicMainColor =   #colorLiteral(red: 0.1725490196, green: 0.1882352941, blue: 0.2352941176, alpha: 1).cgColor
            gradientInnerShadowView.viewDepthType = .innerShadow
            gradientInnerShadowView.viewNeumorphicShadowOffset = CGSize(width: 0.5, height: 0.5)
            gradientInnerShadowView.viewNeumorphicDarkShadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
            gradientInnerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.6).cgColor
            gradientInnerShadowView.viewNeumorphicShadowRadius = 2.5
            gradientInnerShadowView.viewNeumorphicCornerRadius = gradientInnerShadowView.frame.width/2
        }
    }
    @IBOutlet weak var userImageShadowView: SSNeumorphicView! {
        didSet {
            userImageShadowView.viewDepthType = .innerShadow
            userImageShadowView.viewNeumorphicMainColor =   #colorLiteral(red: 0.1725490196, green: 0.1882352941, blue: 0.2352941176, alpha: 1).cgColor
            userImageShadowView.viewNeumorphicCornerRadius = userImageShadowView.frame.width/2
            userImageShadowView.viewNeumorphicShadowOffset = CGSize(width: 0, height: -2)
            userImageShadowView.viewNeumorphicLightShadowColor = UIColor.black.cgColor
            userImageShadowView.viewNeumorphicShadowOpacity = 0.6
            userImageShadowView.viewNeumorphicShadowRadius = 3
        }
    }
    // MARK: App life Cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        intializer()
        for view in backView {
            view.setOuterDarkShadow()
            view.viewNeumorphicCornerRadius = 12
            view.viewNeumorphicMainColor = UIColor.white.cgColor
            view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.4).cgColor
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DIBaseController.errorDelegate = self
        OtpVerificationViewController.delegate = self
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: WatchConnectivity
    /// updates the user updated weight to the watch app
    private func updateInfoToWatchApp() {
        let weight = UserManager.getCurrentUser()?.weight ?? 0
        let gender = UserManager.getCurrentUser()?.gender ?? 0
        let data: [String: Any] = ["request": MessageKeys.userWeightUpdated,
                                   MessageKeys.userWeight: weight,
                                   MessageKeys.userGender: gender]
        Watch_iOS_SessionManager.shared.updateApplicationContext(data: data)
    }
    
    // MARK: Custom Methods...
    private func initializeGradientView() {
        gradientView.instanceHeight = 5.0
        gradientView.instanceWidth = 2.0
        gradientOuterShadowView.addDoubleShadow(cornerRadius: 92, shadowRadius: 4, lightShadowColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3).cgColor, darkShadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor, shadowBackgroundColor:    #colorLiteral(red: 0.1725490196, green: 0.1882352941, blue: 0.2352941176, alpha: 1).cgColor)
    }
    func intializer() {
        initializeGradientView()
        self.validationButton.isHidden = true
        getUserSuggestionList()
        verifyPhn.setTitle("Verified", for: .normal)
        fnTextField.delegate = self
        lnTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        userNameTextField.delegate = self
        dateOfBirthTextField.delegate = self
        gymClubTextField.delegate = self
        regiseterUser = UserManager.getCurrentUser() ?? User()
        regiseterUser.address = UserManager.getCurrentUser()?.address
        //set social login info
        self.initializeWithSocialLoginInfo()
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.editProfile.title, leftBarButton: [leftBarButtonItem], rightBarButtom: [], backGroundColor: .white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
        setPrefetchData() //Call to set prefetch Data
        self.configureUserNameField()
        checkCreateFormEmptyStatus()
    }
    
    private func setProgress(endValue: CGFloat, isInitialConfiguration: Bool = false) {
        let percentComplete = NSNumber(floatLiteral: Double(endValue))
        var locations: [NSNumber] = [0, percentComplete, percentComplete, fadedGradientPercent, fadedGradientPercent, 1]
        if percentComplete.compare(fadedGradientPercent) == .orderedAscending || percentComplete.compare(fadedGradientPercent) == .orderedSame {
            if isInitialConfiguration {
                self.gradientView.configureViewProperties(colors: [UIColor.orange, UIColor.orange, UIColor.purple, UIColor.purple, UIColor.purple.withAlphaComponent(0.4), UIColor.purple.withAlphaComponent(0.2)], gradientLocations: locations)
            } else {
                self.gradientView.updateGradientLocation(newLocations: locations)
            }
        } else {
            locations = [0, percentComplete, percentComplete, percentComplete, percentComplete, 1]
            if isInitialConfiguration {
                self.gradientView.configureViewProperties(colors: [UIColor.orange, UIColor.orange, UIColor.purple, UIColor.purple, UIColor.purple.withAlphaComponent(0.4), UIColor.purple.withAlphaComponent(0.2)], gradientLocations: locations)
            } else {
                self.gradientView.updateGradientLocation(newLocations: locations)
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func hideDetailForProfile(){
        heightTextField.isHidden = true
        weightTextField.isHidden = true
        heightTextField.myLabel.isHidden = true
        weightTextField.myLabel.isHidden = true
        isProfileDashboardView = true
        weightViewHeight.constant = 0
        heightViwHeight.constant = 0
        gymClubTextField.myLabel.removeFromSuperview()
        locationTextField.myLabel.removeFromSuperview()
        submitBtn.isHidden = true
        saveBtn.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.updateTitle()
        }
    }
    
    func updateTitle(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.gymClubTextField.awakeFromNib()
            self.locationTextField.awakeFromNib()
            let lastFilled = CGFloat(self.lastFilledPercent)
            let newFilled = CGFloat(self.filledPercentage())
            self.setProgress(endValue: newFilled)
        }
    }
    
    private func initializeWithSocialLoginInfo() {
        //set social login info if any
        if let socialLoginInfo = Login.currentUserInfo() {
            regiseterUser.profilePicUrl = socialLoginInfo.profilePicure
            regiseterUser.dateOfBirth = socialLoginInfo.dateOfBirth
            regiseterUser.gender = socialLoginInfo.gender
            regiseterUser.address = socialLoginInfo.address
        }
    }
    
    //This Fucntion will color the selected TextField....
    private func changeBorderColor(selectedTextField: UITextField) {
        resetBorderColorOfAllTextField()
        if(selectedTextField == locationTextField) {
            locationTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        } else if (selectedTextField == heightTextField) {
            heightTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        } else if (selectedTextField == weightTextField) {
            weightTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        } else if (selectedTextField == gymClubTextField) {
            gymClubTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        }
        changeTextFieldLeftViewWith(color: #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1), textField: selectedTextField)
    }
    
    private func resetBorderColorOfAllTextField() {
        locationTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        heightTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        weightTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        gymClubTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        changeTextFieldLeftViewWith(color: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), textField: locationTextField)
        changeTextFieldLeftViewWith(color: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), textField: heightTextField)
        changeTextFieldLeftViewWith(color: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), textField: weightTextField)
        changeTextFieldLeftViewWith(color: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), textField: gymClubTextField)
    }
    
    //This Function will filled prefetch data
    private func setPrefetchData() {
        if (regiseterUser.feet ?? 0 > 0) {
            if (regiseterUser.inch ?? 0 > 0) {
                heightTextField.text = "\(regiseterUser.feet ?? 0)' \(regiseterUser.inch ?? 0)''"
            } else {
                heightTextField.text = "\(regiseterUser.feet ?? 0)' 0''"
            }
        }
        if(regiseterUser.weight ?? 0 > 0) {
            weightTextField.text = "\(regiseterUser.weight ?? 0) lbs"
        }
        fnTextField.text = regiseterUser.firstName
        lnTextField.text = regiseterUser.lastName
        userNameTextField.text = regiseterUser.userName
        if let date = regiseterUser.dateOfBirth?.utcToLocal() , date != ""{
            dateOfBirthTextField.text = date.toDate().toString(inFormat: .displayDate)
        }else if tempDate != "" {
            dateOfBirthTextField.text = tempDate.utcToLocal().toDate().toString(inFormat: .displayDate)
        }else {
            dateOfBirthTextField.text = ""
        }
        locationTextField.text = regiseterUser.address?.formatAddress()
        var gymAddress = ""
        if let data = regiseterUser.gymAddress!.name , data != "" {
            gymAddress = data// + ", "
        }
        if regiseterUser.gymAddress?.formatAddress() != nil && regiseterUser.gymAddress?.formatAddress() != "" {
            let address = (gymAddress + ", " + (regiseterUser.gymAddress!.formatAddress() ?? ""))
            gymClubTextField.text = address.trim
        } else {
            gymClubTextField.text = gymAddress
        }
        if let gymType = regiseterUser.gymAddress?.gymType {
            if let hasGymType = regiseterUser.gymAddress?.hasGymType,
                hasGymType == .yes {
                switch gymType {
                case .home:
                    self.gymType = .home
                    self.gymClubButton.isHidden = false
                    self.homeGymRadioButton.isSelected = true
                    self.otherGymRadioButton.isSelected = false
                case .other:
                    self.gymType = .other
                    self.gymClubButton.isHidden = true
                    self.otherGymRadioButton.isSelected = true
                    self.homeGymRadioButton.isSelected = false
                }
            }
        }
        setVerifiedStatus()
        let gender = regiseterUser.gender
        if maleButtonOutlet.tag == gender {
            maleButtonOutlet.setImage(#imageLiteral(resourceName: "radioSelect"), for: .normal)
        }else  if femaleButtonOutlet.tag == gender {
            femaleButtonOutlet.setImage(#imageLiteral(resourceName: "radioSelect"), for: .normal)
        }else if naButtonOutlet.tag == gender {
            naButtonOutlet.setImage(#imageLiteral(resourceName: "radioSelect"), for: .normal)
        }
        if let imageUrl = self.regiseterUser.profilePicUrl,
            let url = URL(string: imageUrl) {
            self.userImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        let percent = CGFloat(self.filledPercentage())
        setProgress(endValue: percent, isInitialConfiguration: true)
    }
    
    func setVerifiedStatus() {
        emailTextField.text = regiseterUser.email
        phoneTextField.text = regiseterUser.phoneNumber
        switch regiseterUser.verifiedStatus {
        // Neither email nor phone verified
        case 0:
            verifyEmail.setTitle("Verify Now", for: .normal)
            verifyEmail.setTitleColor(.red, for: .normal)
            verifyPhn.setTitle("Verify Now", for: .normal)
            verifyPhn.setTitleColor(.red, for: .normal)
        // Only phone Verified
        case 2:
            verifyPhn.setTitle("Phone Verified", for: .normal)
            verifyPhn.setTitleColor(.white, for: .normal)
            verifyPhn.isEnabled = false
            if(regiseterUser.email != ""){
                verifyEmail.setTitle("Verify Now", for: .normal)
                verifyEmail.setTitleColor(.red, for: .normal)
            }else{
                verifyEmail.setTitle("Add New Email", for: .normal)
                verifyEmail.setTitleColor(.red, for: .normal)
            }
        //Only email verified
        case 1:
            verifyEmail.setTitle("Email Verified", for: .normal)
            verifyEmail.setTitleColor(.white, for: .normal)
            verifyEmail.isEnabled = false
            if(regiseterUser.phoneNumber != ""){
                verifyPhn.setTitle("Verify Now", for: .normal)
                verifyPhn.setTitleColor(.red, for: .normal)
            }else{
                verifyPhn.setTitle("Add Phone Number", for: .normal)
                verifyPhn.setTitleColor(.red, for: .normal)
            }
        //both email and phone verified
        default:
            verifyEmail.setTitle("Email Verified", for: .normal)
            verifyEmail.setTitleColor(.white, for: .normal)
            verifyEmail.isEnabled = false
            verifyPhn.setTitle("Phone Verified", for: .normal)
            verifyPhn.setTitleColor(.white, for: .normal)
            verifyPhn.isEnabled = false
            
        }
    }
    
    private func isCreateFormValid() -> Bool{
        checkFieldsEmptyStatus()
        var message:String = ""
        if (fnTextField.text?.isBlank)!{
            message = AppMessages.UserName.emptyFirstname
        }else if !(fnTextField.text?.isValidInRange(minLength: Constant.MinimumLength.firstLastName, maxLength: Constant.MaximumLength.firstName))!{
            message = AppMessages.UserName.maxLengthFirstname
        } else if (lnTextField.text?.isBlank)!{
            message = AppMessages.SignUp.enterLastName
        }else if !(lnTextField.text?.isValidInRange(minLength: Constant.MinimumLength.firstLastName, maxLength: Constant.MaximumLength.lastName))!{
            message = AppMessages.UserName.maxLengthLastname
        }
        if message == ""{
            return true
        }
        mainScrollView.scrollToTop()
        return false
    }

    private func checkCreateFormEmptyStatus(){
        self.submitBtn.isEnabled = true
        self.submitBtn.alpha = 1.0
        let userNameStatus = checkUserNameValidation(text: userNameTextField.text ?? "").1
        var gymFeildStatus = true
        if (self.regiseterUser.gymAddress != nil && self.regiseterUser.gymAddress?.name != nil){
            if((self.regiseterUser.gymAddress?.name!.isBlank)!){
                gymFeildStatus = false
            }else{
                gymFeildStatus = true
            }
        }else{
            gymFeildStatus = false
        }
        if(userNameTextField.text!.isBlank && locationTextField.text!.isBlank && heightTextField.text!.isBlank && weightTextField.text!.isBlank && dateOfBirthTextField.text!.isBlank && (regiseterUser.gender == nil || regiseterUser.gender == 0) && (!userNameStatus) && (!gymFeildStatus) && (!isUserImageChanged)) {
            self.submitBtn.isEnabled = false
            self.submitBtn.alpha = 0.6
        }
    }

    func checkFieldsEmptyStatus() {
        fnTextField.errorMessage = checkFirstNameValidation(text: fnTextField.text ?? "").0
        lnTextField.errorMessage = checkLastNameValidation(text: lnTextField.text ?? "").0
    }
    
    func checkGenderStatus() {
        if(regiseterUser.gender ?? 0 <= 0 )  {
            errorLabel.text = "emptyGender".localized
        }else{
            errorLabel.text = "".localized
        }
    }

    override func datePickerValueChanged(sender:UIDatePicker) {
        let dateOfBirth = sender.date.toString(inFormat: .displayDate)
        dateOfBirthTextField.text = dateOfBirth
        tempDate = (sender.date.toString(inFormat: .preDefined) ?? "").localToUTC()
        if let date = dateOfBirth?.toDate(dateFormat: .displayDate) {
            regiseterUser.dateOfBirth = "\(date.timeStamp)"
        }
    }
    
    func actionOnSubmitButton() {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        if (isUserImageChanged) {
            self.uploadImageOnFirebase(completion: { (imgUrl) in
                if (imgUrl != nil) {
                    self.regiseterUser.profilePicUrl = imgUrl
                    self.createProfile()
                    self.setUserData()
                } else {
                    self.hideLoader()
                    self.showAlert(withTitle: "Warning", message: "firebase error occured")
                }
            })
        } else {
            self.createProfile()
        }
    }
    
    //This Fucntion will return param to create profile....
    private func getParameterKey() -> Parameters {
        var param = CreateProfile()
        param.location = regiseterUser.address ?? Address()
        if (userNameTextField.text != UserManager.getCurrentUser()!.userName){
            param.userName = regiseterUser.userName ?? ""
        }
        param.firstName = regiseterUser.firstName ?? ""
        param.lastName = regiseterUser.lastName ?? ""
        
        param.imgUrl = regiseterUser.profilePicUrl ?? ""
        if regiseterUser.dateOfBirth?.toInt() == 0 {
            //convert to timestamp
            if let date = regiseterUser.dateOfBirth?.toDate(dateFormat: .preDefined) {
                param.dateOfBirth = "\(date.timeStamp)"
            }
        } else {
            param.dateOfBirth = regiseterUser.dateOfBirth ?? ""
        }
        param.gender = regiseterUser.gender ?? 0
        if !isProfileDashboardView{
            param.heightInInch = regiseterUser.inch ?? 0
            param.heightInFeet = regiseterUser.feet ?? 0
            param.weight = regiseterUser.weight ?? 0
        }
        param.lat = regiseterUser.address?.lat ?? 0.0
        param.long = regiseterUser.address?.lng ?? 0.0
        param.profileCompletion = Double(self.filledPercentage())
        param.gymLocation = regiseterUser.gymAddress ?? Address()
        if let gymType = self.gymType {
            param.gymAddressType = gymType
        }
        return param.getDictionary() ?? [:]
    }
    
    //This fucntion will call API to save data on backend server....
    private func createProfile() {
        guard isConnectedToNetwork() else {
            return
        }
        DIWebLayerUserAPI().uplodaProfileData(parameters: getParameterKey(), success: { (message) in
            self.hideLoader()
            self.setUserData()
            self.showAlert(withTitle: "", message:message, okayTitle: "OK".localized, okCall: {
                self.updateCurrentUserProfileInfo()
                if self.isProfileDashboardView == false{
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError: error)
        }
    }

    private func updateCurrentUserProfileInfo() {
           self.delegate?.didEditProfileInformation(user: self.regiseterUser)
    }

    private func redirectOnLocationViewController(isFromGym:Bool? = false) {
        let locationVC:LocationViewController = UIStoryboard(storyboard: .main).initVC()
        locationVC.isFromGym = isFromGym!
        locationVC.delegate = self
        self.navigationController?.pushViewController(locationVC, animated: true)
    }

    func setUserData() {
        Defaults.shared.remove(DefaultKey.socialLoginInfo)
        let user = User.sharedInstance
        user.userName = userNameTextField.text?.trim
        if tempDate != "" {
            user.dateOfBirth = tempDate
        }
        user.address = regiseterUser.address
        user.gymAddress = regiseterUser.gymAddress
        user.feet = regiseterUser.feet
        user.inch = regiseterUser.inch
        user.weight = regiseterUser.weight
        user.gender = regiseterUser.gender
        user.profilePicUrl = regiseterUser.profilePicUrl
        user.gymAddress = regiseterUser.gymAddress
        user.gymAddress?.gymType = self.gymType
        if self.gymType != nil {
            user.gymAddress?.gymType = self.gymType
            user.gymAddress?.hasGymType = .yes
        } else {
            user.gymAddress?.gymType = nil
            user.gymAddress?.hasGymType = .no
        }
        user.firstName = regiseterUser.firstName
        user.lastName = regiseterUser.lastName
        UserManager.saveCurrentUser(user: user)
        self.updateInfoToWatchApp()
        //update the user information on firebase as well.
        ChatManager().updateCurrentUserInfoToDatabase()
    }

    //This Fucntion will get the Image from gallery or Camera...
    private func getImage() {
        photoManager = PhotoManager(navigationController: self.navigationController!, allowEditing: true, callback: { (pickedimage) in
            if(pickedimage != nil) {
                self.userImage.image = pickedimage
                self.isUserImageChanged = true
                self.updateProfileCompletion()
            }
        })
    }

    func getUserSuggestionList() {
        DIWebLayerProfileAPI().getUserSuggestion(success: { (userList) in
            self.userSuggestionList = userList
        }) { (_) in
        }
    }

    //To open Weight Picker....
    func openWeightPicker() {
        let picker = UIPickerManager()
        picker.delegate = self
        if(regiseterUser.weight != 0 && regiseterUser.weight != nil) {
            picker.selectedWeight = regiseterUser.weight
        } else {
            picker.selectedWeight = 120
        }
        picker.addPickerView()
    }

    //To open Height Picker...
    func openHeightPicker() {
        let picker = UIPickerManager()
        picker.openHeightPicker = true
        picker.delegate = self
        if(regiseterUser.feet != nil && regiseterUser.feet != 0){
            picker.selectedHeightInFeet = regiseterUser.feet
        } else {
            //set default value of height in inches
            picker.selectedHeightInFeet = 5
        }
        if (regiseterUser.inch != nil && regiseterUser.inch != 0) {
            picker.selectedHeightInInch = regiseterUser.inch
        } else {
            picker.selectedHeightInInch = 0
        }
        picker.addPickerView()
    }

    /// Starts the profile completion animation
    private func updateProfileCompletion() {
        let lastFilled = CGFloat(lastFilledPercent)
        let newFilled = CGFloat(filledPercentage())
        self.setProgress(endValue: newFilled)
        checkCreateFormEmptyStatus()
    }

    /// configure user name textfield text input frame
    private func configureUserNameField() {
        let width = userNameFieldStackView.frame.size.width + 10
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: userNameTextField.frame.height))
        self.userNameTextField.rightViewMode = .always
        self.userNameTextField.rightView = rightView
        if let socialMediaInfo = self.regiseterUser.socialMedia,
            socialMediaInfo.isEmpty {
            self.setRightButton(textfield: emailTextField, tag: 101)
        }
        self.setRightButton(textfield: phoneTextField, tag: 102)
    }

    private func setRightButton(textfield:CustomTextField, tag:Int){
        let rightEditButton = UIButton(frame: CGRect(x: 0, y: 0, width: userNameFieldStackView.frame.size.width, height: emailTextField.frame.height))
        rightEditButton.addTarget(self, action: #selector(editclicked(sender:)), for: .touchUpInside)
        rightEditButton.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
        rightEditButton.tag = tag
        textfield.rightViewMode = .always
        textfield.rightView = rightEditButton
    }

    @objc func editclicked(sender:UIButton){
        self.view.endEditing(true)
        let changeEmailPhone: ChangeEmailPhoneVC = UIStoryboard(storyboard: .main).initVC()
        if (sender.tag == 101){
            //email field
            changeEmailPhone.fromEmail = true
        }else if (sender.tag == 102){
            //phone feild
            changeEmailPhone.fromEmail = false
        }
        self.navigationController?.pushViewController(changeEmailPhone, animated: true)
    }

    /// Returns the percentage of the profile completion of the form
    ///
    private func filledPercentage() -> Float {

        var overallCompletionFieldsCount = 0.0
        if isUserImageChanged || (self.regiseterUser.profilePicUrl != nil && self.regiseterUser.profilePicUrl != "") {
            overallCompletionFieldsCount += 1.0
        }
        if self.regiseterUser.userName != "" && self.checkUserNameValidation(text: regiseterUser.userName ?? "").1 {
            overallCompletionFieldsCount += 1.0
        }
        if self.regiseterUser.dateOfBirth != nil && self.regiseterUser.dateOfBirth != "" {
            overallCompletionFieldsCount += 1.0
        }
        if !isProfileDashboardView {
            if self.regiseterUser.feet != 0 {
                overallCompletionFieldsCount += 1.0
            }
            if self.regiseterUser.weight != 0 {
                overallCompletionFieldsCount += 1.0
            }
        }
        if self.regiseterUser.gender != nil && self.regiseterUser.gender != 0 {
            overallCompletionFieldsCount += 1.0
        }
        if self.regiseterUser.address?.formatted != nil && self.regiseterUser.address?.formatted != ""{
            overallCompletionFieldsCount += 1.0
        }
        if (self.regiseterUser.gymAddress != nil && self.regiseterUser.gymAddress?.name != nil){
            if(!(self.regiseterUser.gymAddress?.name!.isBlank)!){
                overallCompletionFieldsCount += 1.0
            }
        }
        if regiseterUser.firstName?.count ?? 0 >= 2 {
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.lastName?.count ?? 0 >= 2{
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.email != ""{
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.phoneNumber != ""{
            overallCompletionFieldsCount += 1.0
        }
        // Add gym calculation here
        if isProfileDashboardView {
            lastFilledPercent = overallCompletionFieldsCount / 10.0
            return Float(overallCompletionFieldsCount/10.0)
        }
        lastFilledPercent = overallCompletionFieldsCount / 12.0
        return Float(overallCompletionFieldsCount/12.0)
    }
    
    
    // MARK: @IBAction Methods....
    @IBAction func homeGymRadioTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            gymType = .home
            self.homeGymRadioButton.isSelected = true
            if otherGymRadioButton.isSelected {
                self.gymClubTextField.text = ""
                regiseterUser.gymAddress = nil
                self.updateProfileCompletion()
            }
            self.otherGymRadioButton.isSelected = false
            self.gymClubButton.isHidden = false
        } else {
            gymType = nil
        }
    }
    
    @IBAction func otherGymRadioTapped(_ sender: UIButton) {
        self.gymClubTextField.text = ""
        sender.isSelected.toggle()
        if sender.isSelected {
            gymType = .other
            self.homeGymRadioButton.isSelected = false
            self.otherGymRadioButton.isSelected = true
            self.gymClubButton.isHidden = true
        } else {
            gymType = nil
            self.gymClubTextField.resignFirstResponder()
            self.gymClubButton.isHidden = false
        }
        regiseterUser.gymAddress = nil
        self.updateProfileCompletion()
    }
    
    @IBAction func verifyEmailaction(_ sender: Any) {
        if(regiseterUser.email == ""){
            let changeEmailPhone: ChangeEmailPhoneVC = UIStoryboard(storyboard: .main).initVC()
            changeEmailPhone.fromEmail = true
            self.navigationController?.pushViewController(changeEmailPhone, animated: true)
            return
        }
        redirectToOtpScreen(userName: regiseterUser.email!, confirmationOption: .email)
    }
    
    @IBAction func verifyPhoneAction(_ sender: Any) {
        if(regiseterUser.phoneNumber == ""){
            let changeEmailPhone: ChangeEmailPhoneVC = UIStoryboard(storyboard: .main).initVC()
            changeEmailPhone.fromEmail = false            
            self.navigationController?.pushViewController(changeEmailPhone, animated: true)
            return
        }
        redirectToOtpScreen(userName: regiseterUser.phoneNumber!, confirmationOption: .textMessage,fromEmail: false)
    }
    
    func redirectToOtpScreen(userName:String,confirmationOption:UserConfirmation,fromEmail:Bool = true) {
        DIWebLayerUserAPI().updateEmailPhone(parameters: fromEmail == true ? getEmailParams() : getPhoneParam(), success: { (finished, message) in
            if (finished){
            }
        }) { (error) in
            self.showAlert(withError: error, okayTitle: "OK", cancelTitle: nil, okCall: {
            }, cancelCall: {
            })
        }
        let otpVC: OtpVerificationViewController = UIStoryboard(storyboard: .main).initVC()
        otpVC.userName = userName
        otpVC.confirmationOption = confirmationOption
        otpVC.fromEditProfile = true
        otpVC.forEmail  = fromEmail
        otpVC.popController = 1
        self.navigationController?.pushViewController(otpVC, animated: true)
    }
    
    func getEmailParams() -> [String : Any]{
        let type = 1
        let param = ["type":type, "email": regiseterUser.email ?? ""] as [String : Any]
        return param
    }
    
    func getPhoneParam() -> [String : Any]{
        let type =  2
        let param = ["type":type, "phone": regiseterUser.phoneNumber ?? "","country_code":regiseterUser.countryCode ?? ""] as [String : Any]
        return param
    }

    @IBAction func maleBtnAction(_ sender: UIButton) {
        resetBorderColorOfAllTextField()
        if (regiseterUser.gender != 1) {
            regiseterUser.gender = 1
            maleButtonOutlet.setImage(#imageLiteral(resourceName: "radioSelect"), for: .normal)
            femaleButtonOutlet.setImage(#imageLiteral(resourceName: "radioUnselect"), for: .normal)
            naButtonOutlet.setImage(#imageLiteral(resourceName: "radioUnselect"), for: .normal)
            self.updateProfileCompletion()
        }
        checkGenderStatus()
    }

    @IBAction func femaleBtnAction(_ sender: UIButton) {
        resetBorderColorOfAllTextField()
        if (regiseterUser.gender != 2) {
            regiseterUser.gender = 2
            maleButtonOutlet.setImage(#imageLiteral(resourceName: "radioUnselect"), for: .normal)
            femaleButtonOutlet.setImage(#imageLiteral(resourceName: "radioSelect"), for: .normal)
            naButtonOutlet.setImage(#imageLiteral(resourceName: "radioUnselect"), for: .normal)
            self.updateProfileCompletion()
        }
        checkGenderStatus()
    }

    @IBAction func naButtonAction(_ sender: UIButton) {
        resetBorderColorOfAllTextField()
        if (regiseterUser.gender != 3) {
            regiseterUser.gender = 3
            maleButtonOutlet.setImage(#imageLiteral(resourceName: "radioUnselect"), for: .normal)
            femaleButtonOutlet.setImage(#imageLiteral(resourceName: "radioUnselect"), for: .normal)
            naButtonOutlet.setImage(#imageLiteral(resourceName: "radioSelect"), for: .normal)
            self.updateProfileCompletion()
        }
        checkGenderStatus()
    }

    @IBAction func submitButton(_ sender: UIButton) {
        resetBorderColorOfAllTextField()
        if (isCreateFormValid()) {
            actionOnSubmitButton()
        }
    }

    @IBAction func locationBtn(_ sender: UIButton) {
        changeBorderColor(selectedTextField: locationTextField)
        redirectOnLocationViewController()
    }

    @IBAction func heightBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        changeBorderColor(selectedTextField: heightTextField)
        openHeightPicker()
    }

    @IBAction func weightBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        changeBorderColor(selectedTextField: weightTextField)
        openWeightPicker()
    }

    @IBAction func validationButtonAction(_ sender: UIButton) {
        setUserNameAccordingToValidation()
    }

    @IBAction func refreshButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        guard !self.userSuggestionList.isEmpty else {
            return
        }
        refreshButton.pulsate()
        self.userNameTextField.text = self.userSuggestionList[index]
        self.regiseterUser.userName = self.userSuggestionList[index]
        index += 1
        if index == self.userSuggestionList.count {
            index = 0
        }
        self.updateProfileCompletion()
    }

    @IBAction func gymClubFieldTapped(_ sender: UIButton) {
        redirectOnLocationViewController(isFromGym: true)
    }

    @IBAction func profilePictureTapped(_ sender: UIButton) {
        resetBorderColorOfAllTextField()
        self.getImage()
    }
    
}//Class...


// MARK: Extension + CreateProfileView Controller
//To Upload Image on firebase.....

extension EditProfile {
    func uploadImageOnFirebase(completion:@escaping (_ imageUrl: String?) ->()){
        if(userImage.image != #imageLiteral(resourceName: "camera") && (User.sharedInstance.id != nil)) {
            //Check will set a new profile image name on firebase, if uploading on first time, but in update time, it will use old imagename and reupload on firebase
            if (User.sharedInstance.firebaseProfileImageName == nil) || (User.sharedInstance.firebaseProfileImageName == "") {
                User.sharedInstance.firebaseProfileImageName = (User.sharedInstance.id)!
            }
            let firImageName = (User.sharedInstance.firebaseProfileImageName ?? "") + Utility.shared.getFileNameWithDate()
            // Method changes
            guard let data = self.userImage.image?.jpegData(compressionQuality: 0.5) else {
                return
            }
            UploadMedia.shared.configureDataToUpload(type: .awsBucket, data: data, withName: firImageName, mimeType: "image/jpeg", mediaObj: Media())
            UploadMedia.shared.uploadImage(success: { (url, media) in
                completion(url)
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "")
            }
        }
    }
}//Extension.....

// MARK: Extension + TextField Delegate Methods

extension EditProfile:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameTextField {
            userNameTextField.errorMessage =  ""
        }else if textField == dateOfBirthTextField {
            dateOfBirthTextField.errorMessage =  ""
        }else if textField == gymClubTextField {
            gymClubTextField.errorMessage = ""
        }
        resetBorderColorOfAllTextField()//To reste border color of textField..
        textField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        changeTextFieldLeftViewWith(color: #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1), textField: textField)
        switch textField {
        case dateOfBirthTextField:
            if let dateOfBirth = regiseterUser.dateOfBirth,
                !dateOfBirth.isEmpty {
                if dateOfBirth.toInt() == 0 {
                    if let date = regiseterUser.dateOfBirth?.toDate(dateFormat: .preDefined) {
                        self.addDatePicker(textfield: dateOfBirthTextField, selectedDate: date)
                    }
                } else {
                    self.addDatePicker(textfield: dateOfBirthTextField, selectedDate: dateOfBirth.toInt().toDate)
                }
            } else {
                //setting default selected date: January 1, 2000
                let calendar = Calendar.current
                var components = DateComponents()
                components.year = 2000
                components.month = 1
                components.day = 1
                components.timeZone = TimeZone(identifier: "UTC")
                let date = calendar.date(from: components)
                self.addDatePicker(textfield: dateOfBirthTextField,selectedDate:date)
            }
        default:
            break
        }
    }
    
    func changeTextFieldLeftViewWith(color: UIColor, textField: UITextField) {
        if let textField = textField as? CustomTextField {
            if let imageView = textField.leftImageView() {
                imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imageView.tintColor = color
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        changeTextFieldLeftViewWith(color: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), textField: textField)
        textField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        if (textField == userNameTextField) {
            regiseterUser.userName = textField.text?.trimmed
        } else if (textField == dateOfBirthTextField) {
            datePickerValueChanged(sender: datePickerView ?? UIDatePicker())
        }else if(textField == fnTextField){
            regiseterUser.firstName = textField.text?.trimmed
        }else if(textField == lnTextField){
            regiseterUser.lastName = textField.text?.trimmed
        }else if(textField == emailTextField){
            if(regiseterUser.email != textField.text?.trimmed){
                verifyEmail.setTitle("Verify now", for: .normal)
                verifyEmail.setTitleColor(.red, for: .normal)
            }else{
                verifyEmail.setTitleColor(.white, for: .normal)
            }
        } else if textField == gymClubTextField {
            let address = Address()
            address.name = textField.text?.trimmed
            regiseterUser.gymAddress = address
        }
        self.updateProfileCompletion()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField || textField == phoneTextField {
            return false
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 0 {
            textField.rightView =  nil
            return true
        }
        if (textField.text?.isBlank)! {
            if string.first == " " {
                return false
            }
        }
        var AccaptableCharacter = nameAccaptableCharacter
        if textField == emailTextField {
            AccaptableCharacter = emailAccaptableCharacter
        }else if textField == phoneTextField {
            AccaptableCharacter = phoneAccaptableCharacter
        }
        let cs = NSCharacterSet(charactersIn: AccaptableCharacter).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        if filtered == string {
            if textField == fnTextField {
                fnTextField.errorMessage = ""
                let data = checkFirstNameValidation(text: newString as String)
                textField.rightView = data.1
            }else if textField == lnTextField {
                lnTextField.errorMessage = ""
                let data = checkLastNameValidation(text: newString as String)
                textField.rightView = data.1
            }
        }
        if textField == userNameTextField {
            self.userNameAlreadyExistMsg = nil
            self.userNameTextField.errorMessage = ""
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            
            if newString == "" {
                self.validationButton.isHidden = true
            }else{
                self.validationButton.isHidden = false
            }
            if (textField.text!.count == Constant.MaximumLength.userName) {
                if string.isEmpty {
                    return true
                }
                return false
            }
            //validate username
            let data = checkUserNameValidation(text: newString as String)
            if data.1 {
                if Reachability.isConnectedToNetwork() {
                    DIWebLayerProfileAPI().checkUserNameExist(name: newString as String, success: { (data) in
                        self.validationButton.setImage(#imageLiteral(resourceName: "right"), for: .normal)
                    }) { (_) in
                        self.validationButton.setImage(#imageLiteral(resourceName: "Error"), for: .normal)
                        self.userNameTextField.errorMessage = AppMessages.UserName.userNameAlreadyExists
                        self.userNameAlreadyExistMsg = AppMessages.UserName.userNameAlreadyExists
                    }
                } else {
                    self.validationButton.setImage(#imageLiteral(resourceName: "right"), for: .normal)
                }
            }else{
                self.validationButton.setImage(#imageLiteral(resourceName: "Error"), for: .normal)
            }
        }
        return true
    }
}//Extension....

// MARK: Picker Delegate Methods...

extension EditProfile:MyPickerDelegate,AddressDelegate {
    func tappedOnDoneOrCancel() {
    }
    
    func getPickerValue(firstValue: String, secondValue: String) {
    }
    //For Adderess....
    func selectedAddress(address: Address, isGymLocation: Bool) {
        NotificationCenter.default.post(name: Notification.Name.editProfileNavigate, object: [:])
        if (isGymLocation) {
            self.regiseterUser.gymAddress = address
            self.gymClubTextField.text = (address.name ?? "") + ", " + (address.formatted ?? "")
            self.gymClubTextField.errorMessage = ""
        } else {
            self.regiseterUser.address = address
            self.locationTextField.text = address.formatted
            self.locationTextField.errorMessage = ""
        }
        self.updateProfileCompletion()
    }

    //For Weight....

    func getWeight(weight: Int) {
        regiseterUser.weight = weight
        weightTextField.text = "\(weight) lbs"
        weightTextField.errorMessage = ""
        self.updateProfileCompletion()
    }

    //For Height...

    func getHeight(heightInFeet: Int, heightIninch: Int) {
        regiseterUser.feet = heightInFeet
        regiseterUser.inch = heightIninch
        heightTextField.text = "\(heightInFeet)' \(heightIninch)''"
        heightTextField.errorMessage = ""
        self.updateProfileCompletion()
    }
}
extension EditProfile {

    func setUserNameAccordingToValidation() {
        let data = checkUserNameValidation(text: userNameTextField.text ?? "")
        userNameTextField.errorMessage = data.0
    }
    // MARK: UserNameValidation Functions.
    func checkUserNameValidation(text:String) -> (String,Bool) {
        if let msg = userNameAlreadyExistMsg {
            return(msg, false)
        }
        if text.isBlank {
            return("emptyUserName".localized,false)
        } else if text.containsNoLetter() {
            return ("Username must contain atleast one letter.".localized, false)
        } else if text.trim.length < 3 {
            return("invalidUserName".localized,false)
        }else{
            return("".localized,true)
        }
    }
}

extension EditProfile : ManageEmailPhone {
    func updateData() {
        regiseterUser.email = User.sharedInstance.email
        regiseterUser.phoneNumber = User.sharedInstance.phoneNumber
        regiseterUser.verifiedStatus = User.sharedInstance.verifiedStatus
        setVerifiedStatus()
    }
}
extension EditProfile: ShowErrorMessage {
    func showError(tag: Int) {
        switch tag {
        case 0:
            fnTextField.errorMessage = checkFirstNameValidation(text: fnTextField.text ?? "").0
        case 1:
            lnTextField.errorMessage = checkLastNameValidation(text: lnTextField.text ?? "").0
        default:
            break
        }
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}
