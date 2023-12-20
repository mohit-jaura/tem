//
//  OtpVerificationViewController.swift
//  TemApp
//
//  Created by dhiraj on 13/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol ManageEmailPhone {
    func updateData()
}

class OtpVerificationViewController: DIBaseController {
    
    private var timer: Timer?
    private var timerDuration = 60 //seconds
    var userName : String = ""
    var screenFrom = Constant.ScreenFrom.signup
    var confirmationOption = UserConfirmation.email
    var verificationType: Int?
    var socialLoginInfo: Login?
    var fromEditProfile = false
    var forEmail:Bool!
    var popController:Int = 1
    static var delegate:ManageEmailPhone?
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var submitShadowView: SSNeumorphicView!{
        didSet{
            submitShadowView.setOuterDarkShadow()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setResendButtonAttributes(isDisabled: true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        initalizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.addShadows()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deinitTimer()
    }
    
    // MARK: Custom Methods
    private func addShadows() {
        self.firstTextField.addDropShadowToView()
        self.secondTextField.addDropShadowToView()
        self.thirdTextField.addDropShadowToView()
        self.fourthTextField.addDropShadowToView()
    }
    
    func initalizer(){
      //  self.setHeaderLabel()
        self.firstTextField.becomeFirstResponder()
        resendBtn.isEnabled = self.timerDuration <= 0 ? true : false
        self.setResendButtonAttributes(isDisabled: !resendBtn.isEnabled)
        setUpTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(setTimerDuration(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setResendButtonAttributes(isDisabled value: Bool) {
        let resendCodeTitle = "RESEND"
   var color = UIColor.lightGray
        let myNormalAttributedTitle = NSMutableAttributedString(string: resendCodeTitle,
                                                                attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        let range = NSRange(location: 0, length: resendCodeTitle.count)
        if value {
            color = UIColor.lightGray
        } else {
            color = UIColor.appThemeColor
        }
  //      myNormalAttributedTitle.addAttributes([NSAttributedString.Key.foregroundColor : color], range: range)
//        resendBtn.setAttributedTitle(myNormalAttributedTitle, for: .normal)
    }
    
    func setHeaderLabel() {
        self.headerLabel.text = "We are excited that you've chosen to become a TĒMATE.\nPlease use the OTP below to continue with the login process"
    }
    
    //This method is used to deinit of timer.
    func deinitTimer(){
        self.timer?.invalidate()
        self.timer = nil
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: Set up timer
    private func setUpTimer() {
        resendBtn.isEnabled = self.timerDuration <= 0 ? true : false
        self.setResendButtonAttributes(isDisabled: !resendBtn.isEnabled)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(disableResendButton), userInfo: nil, repeats: true)
    }
    
    //This method is call all the time when timer is running and when timer is running then resend btn is disable.
    @objc func disableResendButton() {
        if self.timerDuration > 0 {
            self.timerDuration -= 1
        }
        self.setResendButtonAttributes(isDisabled: true)
        self.timerLbl.text = "\(AppMessages.OTP.timer) \("0.")\(self.timerDuration)\(AppMessages.OTP.sec)"
        if self.timerDuration == 0 {
            //resendBtn.titleLabel?.textColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
            self.setResendButtonAttributes(isDisabled: false)
            self.timerLbl.text = "\(AppMessages.OTP.timer) \("0.") \(self.timerDuration)\(AppMessages.OTP.sec)"
            self.timer?.invalidate()
            self.timer = nil
        }
        resendBtn.isEnabled = self.timerDuration <= 0 ? true : false
        self.setResendButtonAttributes(isDisabled: !resendBtn.isEnabled)
    }
    
    
    // MARK: Notification handler
    @objc func setTimerDuration(notification: Notification) {
        if let foregroundEnterTime =  appDelegate.foregroundEnterTime,
            let backgroundEnterTime = appDelegate.backgroundEnterTime {
            let difference = foregroundEnterTime.differenceInSeconds(fromDate: backgroundEnterTime)
            self.timerDuration = difference
        }
    }
    
    //This method is uset get resendOtp parameters.
    private func getResendOtpParams() -> OTPVerification{
        var otpVerification = OTPVerification()
        otpVerification.username = userName
        if let type = self.verificationType {
            otpVerification.type = type
        }
        return otpVerification
    }
    
    //This method is used to get otp verify params.
    private func getVerifyOtpParams(_ otp:String) -> OTPVerification{
        var otpVerification = OTPVerification()
        otpVerification.username = userName
        otpVerification.otpCode = otp
        return otpVerification
    }
    
    //This method is used to get otp verify params.
    private func getEmailPhoneVerifyOtpParams(_ otp:String) -> Parameters{
        var type = 1
        if(!forEmail){
            type = 2
        }
        let dict:[String: Any] = [
            "otp_code": otp,
            "type": type
        ]
        return dict
    }
    
    //This method is used to validate otp field and call api to verify otp.
    private func isOtpFormValidAndCallApi(){
        var otp = ""
        if let first = firstTextField.text {
            otp += first
        }
        if let second = secondTextField.text {
            otp += second
        }
        if let third = thirdTextField.text {
            otp += third
        }
        if let fourth = fourthTextField.text {
            otp += fourth
        }
        let output = Validation.shared.validate(values: (ValidationType.otp, otp))
        switch output {
        case .success:
            errorLabel.text = ""
            switch self.screenFrom {
            case .signup:
                self.otpVerifyApi(otp)
            //to home screen
            case .forgotPassword:
                self.verifyForgotPasswordOtp(value: otp)
            default:
                break
            }
        case .failure(let message):
            errorLabel.text = message
            //self.showAlert(message: message)
        }
    }
    
    // MARK: Watch Connectivity
    private func sendMessageToWatch() {
        let headers = DeviceInfo.shared.getHeaderContent(true)
        
        var data: [String: Any] = ["request": MessageKeys.logintoApp,
                                   MessageKeys.loginHeaders: headers]
        if let weight = UserManager.getCurrentUser()?.weight {
            data[MessageKeys.userWeight] = weight
        }
        if let gender = UserManager.getCurrentUser()?.gender {
            data[MessageKeys.userGender] = gender
        }
        Watch_iOS_SessionManager.shared.updateApplicationContext(data: data)
    }
    
    //This method is used to verify forgot password otp.
    private func verifyForgotPasswordOtp(value: String) {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().forgotVerifyOtp(parameters: getVerifyOtpParams(value).getDictionary(), success: { (response) in
            self.hideLoader()
            print(response)
            let resetToken = response["reset_token"] as? String ?? ""
            let resetPasswordVC : ResetPasswordViewController = UIStoryboard(storyboard: .main).initVC()
            resetPasswordVC.resetToken = resetToken
            resetPasswordVC.username = self.userName
            self.navigationController?.pushViewController(resetPasswordVC, animated: true)
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    //This method is used to verify otp corresponding to the username(email or phone no).
    private func otpVerifyApi(_ otp:String){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        if (fromEditProfile){
            verifyOTPforEmailPhoneUpdation(otp)
        }else{
            verifyNewUser(otp)
        }
    }

    private func updateNewDeviceTokenToServer() {
        if let deviceToken = Defaults.shared.get(forKey: DefaultKey.fcmToken) as? String,
           !deviceToken.isEmpty {
            //update the new device token to the server
            let params: Parameters = ["device_token": deviceToken]
            print("update device token: \(deviceToken)")
            DIWebLayerUserAPI().updateDeviceToken(parameters: params)
        }
    }

    func  verifyNewUser(_ otp:String)  {
        DIWebLayerUserAPI().verifyAndRegisterUser(parameters: getVerifyOtpParams(otp).getDictionary(), success: { (response) in
            self.hideLoader()
            UserManager.saveCurrentUser(user: response)
            self.sendMessageToWatch()
            if let socialInfo = self.socialLoginInfo {
                socialInfo.saveEncodedInformation()
            }
            self.updateNewDeviceTokenToServer()
            self.otpVerificationCompletion(user: response)
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    func verifyOTPforEmailPhoneUpdation(_ otp:String) {
        DIWebLayerUserAPI().verifyAndUpdatPhoneEmail(parameters: getEmailPhoneVerifyOtpParams(otp), success: { (response) in
            //            UserManager.saveCurrentUser(user: response)
            //            if let socialInfo = self.socialLoginInfo {
            //                socialInfo.saveEncodedInformation()
            //            }
            //            self.otpVerificationCompletion(user: response)
            let user = User.sharedInstance
            user.verifiedStatus = response["verified_status"] as? Int ?? 0
            if(self.forEmail){
                user.email = self.userName
            }else{
                user.phoneNumber = self.userName
            }
            UserManager.saveCurrentUser(user: user)
            self.hideLoader()
            self.updateNewDeviceTokenToServer()
            OtpVerificationViewController.delegate?.updateData()
            var controllers = self.navigationController?.viewControllers
            controllers?.removeLast(self.popController)
            self.navigationController?.setViewControllers(controllers!, animated: true)
            
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    //This method is used to call resend otp for sign up.
    private func callResendOtpApi(){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().resendOtp(parameters: getResendOtpParams().resendDict(), success: { (response) in
            self.hideLoader()
            self.showAlert(message:response)
            self.timerDuration = 60
            self.setUpTimer()
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    private func callResendOtpApiForEmailPhoneUpdate() {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().updateEmailPhone(parameters: self.forEmail == true ? getEmailParams() : getPhoneParam(), success: { (_, message) in
            self.hideLoader()
            if let msg = message {
                self.showAlert(message: msg)
            }
            self.timerDuration = 60
            self.setUpTimer()
        }) { (error) in
            self.hideLoader()
            self.showAlert(message: error.message)
        }
    }
    
    func getEmailParams() -> [String : Any]{
        let type = self.confirmationOption.rawValue
        let param = ["type":type, "email": self.userName] as [String : Any]
        return param
    }
    
    func getPhoneParam() -> [String : Any]{
        let type =  self.confirmationOption.rawValue
        let param = ["type":type, "phone": self.userName,"country_code": User.sharedInstance.countryCode ?? ""] as [String : Any]
        return param
    }
    
    //This method is used to call resend otp for forgot password.
    private func callResendForgotOtpApi(){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().forgotPassword(parameters:getResendOtpParams().getForgotDictionary(), success: { (response) in
            self.hideLoader()
            self.showAlert(message:response)
            self.timerDuration = 60
            self.setUpTimer()
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    private func otpVerificationCompletion(user: User) {
        switch user.profileCompletionStatus {
        case UserProfileCompletion.notDone.rawValue:
            let createProfileVC: CreateProfileViewController = UIStoryboard(storyboard: .main).initVC()
            appDelegate.setNavigationToRoot(viewContoller: createProfileVC)
        case UserProfileCompletion.createProfile.rawValue:
            let selectInterestVC: SelectInterestViewController = UIStoryboard(storyboard: .main).initVC()
            appDelegate.setNavigationToRoot(viewContoller: selectInterestVC)
        default:
            if let deeplinkInfo = appDelegate.deepLinkInfo() {
                if let postId = deeplinkInfo.postId {
                    self.handleDeepLinkOfPostShare(id: postId)
                } else if let affiliateMarketPlaceId = deeplinkInfo.affiliateMarketPlaceId {
                    self.handleDeepLinkOfAffiliateShare(id: affiliateMarketPlaceId)
                }
                return
            }
            let isDeepLinkingPage = appDelegate.getDeepLinkRedirectionStatus()
            if isDeepLinkingPage {
                appDelegate.saveDeepLinkRedirection(value: false)
                return
            } else {
                let networkVC:HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
                appDelegate.setNavigationToRoot(viewContoller: networkVC)
            }
        }
    }
    
    // MARK: @IBAction Methods
    @IBAction func resendCodeTapped(_ sender: UIButton) {
        if self.fromEditProfile {
            self.callResendOtpApiForEmailPhoneUpdate()
            return
        }
        switch self.screenFrom {
        case .signup:
            self.callResendOtpApi()
        case .forgotPassword:
            self.callResendForgotOtpApi()
        default:
            break
        }
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        self.isOtpFormValidAndCallApi()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        if(fromEditProfile){
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


// MARK: UITextFieldDelegate
extension OtpVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorLabel.text = ""
        if ((textField.text?.count)! < 1  && string.count > 0) || (textField.text?.count == 1 && string.count > 0) {
            let nextTag = textField.tag + 1
            
            // get next responder
            let nextResponder = textField.superview?.viewWithTag(nextTag)
            textField.text = string
            
            if (nextResponder == nil) {
                textField.resignFirstResponder()
            }
            nextResponder?.becomeFirstResponder()
            return false
        }
        else if ((textField.text?.count)! >= 1  && string.count == 0) {
            // on deleting value from Textfield
            let previousTag = textField.tag - 1 
            
            // get previous responder
            var previousResponder = textField.superview?.viewWithTag(previousTag)
            
            if (previousResponder == nil) {
                previousResponder = textField.superview?.viewWithTag(1)
            }
            textField.text = ""
            previousResponder?.becomeFirstResponder()
            return false
        }
        return true
    }
}


