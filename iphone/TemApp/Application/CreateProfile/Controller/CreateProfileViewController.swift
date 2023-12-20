//
//  CreateProfileViewController.swift
//  TemApp
//
//  Created by Sourav on 2/13/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher
import SSNeumorphicView

class CreateProfileViewController: DIBaseController {
    
    // MARK: Variables.....
    var photoManager:PhotoManager!
    var gender:Int = 1
    var tempDate:String = ""
    var regiseterUser:User = User()
    var isUserImageChanged:Bool = false
    var userSuggestionList:[String] = [String]()
    var index = 0
    private var lastFilledPercent = 0.0
    private var userNameAlreadyExistMsg: String?
    private let fadedGradientPercent: NSNumber = 0.75
    
    //variable saving the social login information
    var socialLoginInfo: Login?
    private var gymType: GymLocationType?
    
    // MARK: @IBOutlets...
    
    // MARK: UImageView...
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    // MARK: TextField....
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
    @IBOutlet weak var nexShadowView: SSNeumorphicView!{
        didSet{
            nexShadowView.setOuterDarkShadow()
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
    // MARK: UIButton.....
    @IBOutlet weak var homeGymRadioButton: UIButton!
    @IBOutlet weak var otherGymRadioButton: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var maleButtonOutlet: UIButton!
    @IBOutlet weak var femaleButtonOutlet: UIButton!
    @IBOutlet weak var naButtonOutlet: UIButton!
    @IBOutlet weak var circularAnimationView: CircleView!
    @IBOutlet weak var gymClubView: UIView!
    @IBOutlet weak var gymClubButton: UIButton!
    @IBOutlet weak var gymClubViewHeightConstarint: NSLayoutConstraint!
    
    // MARK: App life Cycle....
    //shilpa.vashist@debutinfotech.com
    override func viewDidLoad() {
        super.viewDidLoad()
        intializer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: Custom Methods...
    private func intializer() {
        

        initializeGradientView()
        self.validationButton.isHidden = true
        self.configureUserNameField()
        getUserSuggestionList()
        userNameTextField.delegate = self
        dateOfBirthTextField.delegate = self
        gymClubTextField.delegate = self
        regiseterUser = UserManager.getCurrentUser() ?? User()
        regiseterUser.address = UserManager.getCurrentUser()?.address
        self.initializeWithSocialLoginInfo()
        setPrefetchData() //Call to set prefetch Data
        checkCreateFormEmptyStatus()
    }
    
    private func initializeGradientView() {
        gradientView.instanceHeight = 5.0
        gradientView.instanceWidth = 2.0
        gradientOuterShadowView.addDoubleShadow(cornerRadius: 92, shadowRadius: 4, lightShadowColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3).cgColor, darkShadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor, shadowBackgroundColor:    #colorLiteral(red: 0.1725490196, green: 0.1882352941, blue: 0.2352941176, alpha: 1).cgColor)
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
    
    //called when skip bar button is tapped
    override func navigateToInterestScreen() {
        let dateIsEmpty = self.checkDateOfBirtIsEmpty()
        let weightIsEmpty = self.checkWeightIsEmpty()
        if (dateIsEmpty || weightIsEmpty) {
            return
        }
        let dict = getMandatoryProfileData()
        DIWebLayerUserAPI().uplodaProfileData(parameters: dict , success: { (message) in
            User.sharedInstance.dateOfBirth = self.tempDate
            UserManager.saveCurrentUser(user: User.sharedInstance)
        }) { (_) in
        }
        /****** remove social login saved info from User defaults *****/
        Defaults.shared.remove(DefaultKey.socialLoginInfo)
        let user = User.sharedInstance
        user.profileCompletionStatus = UserProfileCompletion.createProfile.rawValue
        user.profilePicUrl = nil
        UserManager.saveCurrentUser(user: user)
        self.updateProfileStatusToServer()
        super.navigateToInterestScreen()
    }
    
    //This Fucntion will color the selected TextField....
    private func changeBorderColor(selectedTextField: UITextField) {
        if(selectedTextField == locationTextField) {
            locationTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        } else if (selectedTextField == heightTextField){
            heightTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        } else if (selectedTextField == weightTextField) {
            weightTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        } else if (selectedTextField == gymClubTextField) {
            gymClubTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        }
    }
    
    private func resetBorderColorOfAllTextField() {
        locationTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        heightTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        weightTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        gymClubTextField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
    }
    
    // This Function will filled prefetch data
    private func setPrefetchData() {
        if (regiseterUser.feet ?? 0 > 0){
            if (regiseterUser.inch ?? 0 > 0) {
                heightTextField.text = "\(regiseterUser.feet ?? 0)' \(regiseterUser.inch ?? 0)''"
            } else {
                heightTextField.text = "\(regiseterUser.feet ?? 0)' 0''"
            }
        }
        if(regiseterUser.weight ?? 0 > 0) {
            weightTextField.text = "\(regiseterUser.weight ?? 0) lbs"
        }
        userNameTextField.text = regiseterUser.userName
        dateOfBirthTextField.text = regiseterUser.dateOfBirth
        locationTextField.text = regiseterUser.address?.formatted
        let gender = regiseterUser.gender
        if maleButtonOutlet.tag == gender {
            maleButtonOutlet.isSelected = true
        }else  if femaleButtonOutlet.tag == gender {
            femaleButtonOutlet.isSelected = true
        }else if naButtonOutlet.tag == gender {
            naButtonOutlet.isSelected = true
        }
        if let imageUrl = self.regiseterUser.profilePicUrl,
            let url = URL(string: imageUrl) {
            self.userImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        let percent = CGFloat(self.filledPercentage())
        setProgress(endValue: percent, isInitialConfiguration: true)
    }
    
    //This will update the gradient as per the percenatage of the fields filled.
    // isInitialConfiguration: true if the view is loaded initially , else false
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
    
    private func isCreateFormValid() -> Bool{
        checkFieldsEmptyStatus()
        var message:String = ""
        message = checkUserNameValidation(text: userNameTextField.text ?? "").0
        if(dateOfBirthTextField.text?.isBlank)! {
            message = "dateOfBirthTextField"
        }else if(locationTextField.text?.isBlank)! {
            message = "locationTextField"
        }else if(heightTextField.text?.isBlank)! {
            message = "heightTextField"
        }else if(weightTextField.text?.isBlank)! {
            message = "weightTextField"
        }else if(regiseterUser.gender == nil || regiseterUser.gender == 0)  {
            message = "gender"
        }
        
        if message == ""{
            return true
        }
        return false
        
    }
    
    
    private func checkCreateFormEmptyStatus(){
        self.submitBtn.isEnabled = true
        self.submitBtn.alpha = 1.0
        let userNameStatus = checkUserNameValidation(text: userNameTextField.text ?? "").1
        var gymFeildStatus = true
        if (self.regiseterUser.gymAddress != nil && self.regiseterUser.gymAddress?.name != nil){
            if regiseterUser.gymAddress?.name?.isEmpty == true {
                gymFeildStatus = false
            } else {
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
        setUserNameAccordingToValidation()
        dateOfBirthTextField.errorMessage = (dateOfBirthTextField.text?.isBlank)! ? "emptyDateOfBirth".localized : ""
        locationTextField.errorMessage = (locationTextField.text?.isBlank)! ? "emptyUserLocation".localized : ""
        heightTextField.errorMessage = (heightTextField.text?.isBlank)! ? "emptyHeight".localized : ""
        weightTextField.errorMessage = (weightTextField.text?.isBlank)! ? "emptyWeight".localized : ""
        checkGenderStatus()
    }
    
    func checkGenderStatus() {
        if(regiseterUser.gender ?? 0 <= 0 )  {
            errorLabel.text = "emptyGender".localized
        }else{
            errorLabel.text = "".localized
        }
    }
    
    override func datePickerValueChanged(sender:UIDatePicker) {
        let dateOfBirth = sender.date.toString(inFormat: .displayDate)//sender.date.displayDate()
        dateOfBirthTextField.text = dateOfBirth
        tempDate = (sender.date.toString(inFormat: .preDefined) ?? "").localToUTC()
        if let date = dateOfBirth?.toDate(dateFormat: .displayDate) {
            regiseterUser.dateOfBirth = "\(date.timeStamp)"
        }
    }
    
    func checkDateOfBirtIsEmpty() -> Bool {
        if(dateOfBirthTextField.text?.isBlank)! {
            dateOfBirthTextField.errorMessage = (dateOfBirthTextField.text?.isBlank)! ? "emptyDateOfBirth".localized : ""
            return true
        }
         return false
    }
    
    func checkWeightIsEmpty() -> Bool {
        if(weightTextField.text?.isBlank)! {
            weightTextField.errorMessage = (weightTextField.text?.isBlank)! ? "emptyWeight".localized : ""
            return true
        }
         return false
    }
    
    private func actionOnSubmitButton() {
        let dateIsEmpty = self.checkDateOfBirtIsEmpty()
        let weightIsEmpty = self.checkWeightIsEmpty()
        if (dateIsEmpty || weightIsEmpty) {
            return
        }
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
            self.uploadImageOnFirebase(completion: { (imgUrl) in
                if (imgUrl != nil) {
                    self.regiseterUser.profilePicUrl = imgUrl
                    self.createProfile()
                } else {
                    self.hideLoader()
                    self.showAlert(withTitle: "Warning", message: "firebase error occured")
                }
            })
    }
    
    private func getMandatoryProfileData() -> Parameters {
        var param:[String:Any] = [String:Any]()
        if regiseterUser.dateOfBirth?.toInt() == 0 {
            //convert to timestamp
            if let date = regiseterUser.dateOfBirth?.toDate(dateFormat: .displayDate) {
                param["dob"] = "\(date.timeStamp)"
            }
        } else {
            param["dob"] = regiseterUser.dateOfBirth ?? ""
        }
        param["weight"] = regiseterUser.weight ?? ""
        param["profile_completion_percentage"] = (Double(self.filledPercentage())*100)
        return param
    }
    
    //This Fucntion will return param to create profile....
    private func getParameterKey() -> Parameters {
        var param = CreateProfile()
        param.location = regiseterUser.address ?? Address()
        param.userName = regiseterUser.userName ?? ""
        param.imgUrl = regiseterUser.profilePicUrl ?? ""
        if regiseterUser.dateOfBirth?.toInt() == 0 {
            //convert to timestamp
            if let date = regiseterUser.dateOfBirth?.toDate(dateFormat: .displayDate) {
                param.dateOfBirth = "\(date.timeStamp)"
            }
        } else {
            param.dateOfBirth = regiseterUser.dateOfBirth ?? ""
        }
        param.gender = regiseterUser.gender ?? 0
        param.heightInInch = regiseterUser.inch ?? 0
        param.heightInFeet = regiseterUser.feet ?? 0
        param.weight = regiseterUser.weight ?? 0
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
            self.updateProfileStatusToServer()
            self.setUserData()
            let selectInterestVC : SelectInterestViewController = UIStoryboard(storyboard: .main).initVC()
            self.navigationController?.pushViewController(selectInterestVC, animated: true)
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError: error)
        }
    }
    
    private func updateProfileStatusToServer() {
        let parameters: Parameters = ["status": UserProfileCompletion.createProfile.rawValue]
        DIWebLayerUserAPI().updateProfileCompletionStatus(parameters: parameters) { (_) in
        }
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
        user.userName = userNameTextField.text
        user.dateOfBirth = tempDate
        user.address = regiseterUser.address
        user.gymAddress = regiseterUser.gymAddress
        user.feet = regiseterUser.feet
        user.inch = regiseterUser.inch
        user.weight = regiseterUser.weight
        user.gender = regiseterUser.gender
        user.profileCompletionStatus = UserProfileCompletion.createProfile.rawValue
        user.profilePicUrl = regiseterUser.profilePicUrl
        user.gymAddress = regiseterUser.gymAddress
        if self.gymType != nil {
            user.gymAddress?.gymType = self.gymType
            user.gymAddress?.hasGymType = .yes
        } else {
            user.gymAddress?.gymType = nil
            user.gymAddress?.hasGymType = .no
        }
        UserManager.saveCurrentUser(user: user)
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
        if self.regiseterUser.feet != nil && self.regiseterUser.feet != 0 {
            overallCompletionFieldsCount += 1.0
        }
        if self.regiseterUser.weight != nil && self.regiseterUser.weight != 0  {
            overallCompletionFieldsCount += 1.0
        }
        if self.regiseterUser.gender != nil && self.regiseterUser.gender != 0 {
            overallCompletionFieldsCount += 1.0
        }
        if self.regiseterUser.address?.formatted != nil && self.regiseterUser.address?.formatted != ""{
            overallCompletionFieldsCount += 1.0
        }
        if self.homeGymRadioButton.isSelected{
            overallCompletionFieldsCount += 1.0
        }
        if (self.regiseterUser.gymAddress != nil && self.regiseterUser.gymAddress?.name != nil){
            if(!(self.regiseterUser.gymAddress?.name!.isBlank)!){
                overallCompletionFieldsCount += 1.0
            }
        }
        // Add gym calculation here
        lastFilledPercent = overallCompletionFieldsCount / 8.0
        return Float(overallCompletionFieldsCount/8.0)
    }
    
    
    // MARK: @IBAction Methods....
    @IBAction func homeGymTapped(_ sender: UIButton) {
        gymClubViewHeightConstarint.constant = 0
      sender.isSelected.toggle()
        if sender.isSelected {
            gymType = .home
            self.homeGymRadioButton.isSelected = true
            if otherGymRadioButton.isSelected {
                self.gymClubTextField.text = ""
                regiseterUser.gymAddress = nil
                self.updateProfileCompletion()
            }
            self.updateProfileCompletion()
            self.otherGymRadioButton.isSelected = false
            self.gymClubButton.isHidden = false
        } else {
            self.updateProfileCompletion()
            gymType = nil
        }
    }
    
    @IBAction func otherGymTapped(_ sender: UIButton) {
        gymClubViewHeightConstarint.constant = 41
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
    
    @IBAction func maleBtnAction(_ sender: UIButton) {
        if (regiseterUser.gender != 1) {
            regiseterUser.gender = 1
            maleButtonOutlet.isSelected = true
            femaleButtonOutlet.isSelected = false
            naButtonOutlet.isSelected = false
            self.updateProfileCompletion()
        }
        checkGenderStatus()
    }
    
    @IBAction func femaleBtnAction(_ sender: UIButton) {
        if (regiseterUser.gender != 2) {
            regiseterUser.gender = 2
            femaleButtonOutlet.isSelected = true
            maleButtonOutlet.isSelected = false
            naButtonOutlet.isSelected = false
            self.updateProfileCompletion()
        }
        checkGenderStatus()
    }
    
    @IBAction func naButtonAction(_ sender: UIButton) {
        if (regiseterUser.gender != 3) {
            regiseterUser.gender = 3
            femaleButtonOutlet.isSelected = false
            maleButtonOutlet.isSelected = false
            naButtonOutlet.isSelected = true
            self.updateProfileCompletion()
        }
        checkGenderStatus()
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        if (isCreateFormValid()) {
            if ( otherGymRadioButton.isSelected) || homeGymRadioButton.isSelected{
                
                if (otherGymRadioButton.isSelected && gymClubTextField.text == "") && (!homeGymRadioButton.isSelected){
                    
                    self.showAlert(message:AppMessages.ProfileMessages.enterGymClubValue )
                }else{
                    actionOnSubmitButton()
                }
            }else{
                self.showAlert(message: AppMessages.ProfileMessages.selectGymClub)
            }
        }else {
        }
    }

    @IBAction func locationBtn(_ sender: UIButton) {
        redirectOnLocationViewController()
    }
    
    @IBAction func heightBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        openHeightPicker()
    }
    
    @IBAction func weightBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        openWeightPicker()
    }
    
    @IBAction func validationButtonAction(_ sender: UIButton) {
        setUserNameAccordingToValidation()
    }
    
    @IBAction func refreshButtonAction(_ sender: UIButton) {
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
        self.getImage()
    }
    
}//Class...

// MARK: Extension + CreateProfileView Controller
//To Upload Image on firebase.....

extension CreateProfileViewController {
    
    func uploadImageOnFirebase(completion:@escaping (_ imageUrl: String?) ->()){
        var image: UIImage?
        if(User.sharedInstance.id != nil) {
            let id = User.sharedInstance.id!
            LoginFirebaseUser.signIn(email: id, password: id) { (finished, error) in
                if (finished == nil) {
                    self.hideLoader()
                    return
                }
                if self.userImage.image?.pngData() == #imageLiteral(resourceName: "placeholder").pngData(){
                    let lblNameInitialize = UILabel()
                    lblNameInitialize.font = UIFont(name: UIFont.avenirNextBold, size: 32)
                    lblNameInitialize.frame.size = CGSize(width: 100, height: 100)
                    lblNameInitialize.textColor = UIColor.white
                    if let fname = UserManager.getCurrentUser()?.firstName, let lname = UserManager.getCurrentUser()?.lastName, let firstName = fname.first?.uppercased(), let lastName = lname.first?.uppercased(){
                        
                        lblNameInitialize.text = firstName + lastName
                    }
                    lblNameInitialize.textAlignment = NSTextAlignment.center
                    lblNameInitialize.backgroundColor = UIColor.random()
                    UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
                    lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
                    image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    self.userImage.image = image
                }
                
                //Check will set a new profile image name on firebase, if uploading on first time, but in update time, it will use old imagename and reupload on firebase
                if (User.sharedInstance.firebaseProfileImageName == nil) || (User.sharedInstance.firebaseProfileImageName == "") {
                    User.sharedInstance.firebaseProfileImageName = (User.sharedInstance.id)!
                }
                let firImageName = (User.sharedInstance.firebaseProfileImageName ?? "") + Utility.shared.getFileNameWithDate()
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
    }
}//Extension.....

// MARK: Extension + TextField Delegate Methods

extension CreateProfileViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameTextField {
            userNameTextField.errorMessage =  ""
        }else if textField == dateOfBirthTextField {
            dateOfBirthTextField.errorMessage =  ""
        }else if textField == gymClubTextField {
            gymClubTextField.errorMessage = ""
        }
        switch textField {
        case dateOfBirthTextField:
            if let dateOfBirth = regiseterUser.dateOfBirth,
                !dateOfBirth.isEmpty {
                if dateOfBirth.toInt() == 0 {
                    if let date = regiseterUser.dateOfBirth?.toDate(dateFormat: .displayDate) {
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
        textField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        if (textField == userNameTextField) {
            regiseterUser.userName = textField.text?.trimmed
        } else if (textField == dateOfBirthTextField) {
            datePickerValueChanged(sender: datePickerView ?? UIDatePicker())
        } else if textField == gymClubTextField {
            let address = Address()
            address.name = textField.text?.trimmed
            regiseterUser.gymAddress = address
        }
        self.updateProfileCompletion()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count == 1,
            string.isEmpty {
            self.validationButton.isHidden = true
            return true
        }
        if textField == userNameTextField {
            self.userNameAlreadyExistMsg = nil
            self.userNameTextField.errorMessage = ""
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
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

extension CreateProfileViewController:MyPickerDelegate,AddressDelegate {
    func tappedOnDoneOrCancel() {
    }
    
    func getPickerValue(firstValue: String, secondValue: String) {
    }

    //For Adderess....
    
    func selectedAddress(address: Address, isGymLocation: Bool) {
        if (isGymLocation) {
            regiseterUser.gymAddress = address
            gymClubTextField.text = (address.name ?? "") + ", " + (address.formatted ?? "")
            gymClubTextField.errorMessage = ""
        } else {
            regiseterUser.address = address
            locationTextField.text = address.formatted
            locationTextField.errorMessage = ""
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

extension UINavigationController{
    func addShadow(){
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationBar.layer.shadowOpacity = 0.8
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.navigationBar.layer.shadowRadius = 2
    }
}

extension CreateProfileViewController {
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

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
