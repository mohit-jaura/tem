//
//  LoginViewController.swift
//  TemApp
//
//  Created by Sourav on 2/7/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn
import KeychainSwift
import AuthenticationServices
import Firebase
import SSNeumorphicView

class LoginViewController: DIBaseController {
    
    // MARK: Properties
    var rememberMe = false
    private let keychain = KeychainSwift()
    
    // MARK: @IBOutlet Variables
    @IBOutlet weak var passwordTxtFld: CustomTextField!
    @IBOutlet weak var emailTxtFld: CustomTextField!
    @IBOutlet weak var rememberMeBtn: UIButton!
    @IBOutlet weak var rememberMeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var appleloginButton: UIButton!

    @IBOutlet weak var loginShadowView: SSNeumorphicView!{
        didSet{
            loginShadowView.setOuterDarkShadow()
        }
    }

    // MARK: App lifeCycle:------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    fatalError()
//        self.startSession()
        self.getSavedEmailAndPassword()
        intilalizer()
        if #available(iOS 13.0, *) {
            appleloginButton.isHidden = false
        } else {
            // Fallback on earlier versions
            appleloginButton.isHidden = true
        }
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        DIBaseController.errorDelegate = self
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
    
    // MARK: Custom Methods:---
    
    private func intilalizer() {
      
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        emailTxtFld.delegate = self
        passwordTxtFld.delegate = self
    }
    
    //This method is used to login with facebook.
    private func facebookLogin(){
        DispatchQueue.main.async {
            FacebookManager.shared.login([.email, .publicProfile, .birthday, .gender, .location, .friends], success: { (login) in
                self.callSocialMediaExistsApi(login:login)
            }, failure: { (error) in
                self.hideLoader()
            }, onController: self)
        }
    }
    
    //This method is used to check whether user is on our server or not.
    private func callSocialMediaExistsApi(login:Login,isActive:Bool = false){
        showLoader()
        var loginData = login
        loginData.activate = isActive
        DIWebLayerUserAPI().socialUserCheck(parameters: loginData.getDictSocialExist(), success: { (user,arg)  in
            /* user modal recieved (Old user)*/
            if user != nil {
                UserManager.saveCurrentUser(user: user!)
                self.sendMessageToWatch()
                self.hideLoader()
                //self.redirectionOnLoginSuccess(user: user!)
                self.redirectionOnLoginSuccess(profileCompletionStatus: user!.profileCompletionStatus, socialLoginInfo: login)
            }
            /* Message for new registration require*/
            if arg != nil{
                var newUserLogin = login
                if login.username.isEmpty{
                    self.hideLoader()
                    newUserLogin.isEmailVerified = EmailVerified.no.rawValue
                    CustomAlertManager.shared.showCustomAlert()
                    CustomAlertManager.shared.customView.delegate = self
                    CustomAlertManager.shared.login = login
                    CustomAlertManager.shared.customView.emailTxtFld.delegate = self
                } else {
                    newUserLogin.isEmailVerified = EmailVerified.yes.rawValue
                    self.callSocialLoginApi(login:newUserLogin)
                }
            }
        }) {
            self.hideLoader()
            if let code = $0.code {
                if code == .userDisable {
                    self.showAlert(withTitle: "", message: $0.message, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
                        self.callSocialMediaExistsApi(login:loginData,isActive:true)
                    }) {
                    }
                    return
                }
                
                self.showAlert(withError: $0)
            }
        }
    }
    
    //This method is used to call login api and redirect user to dashboard.
    private func callSocialLoginApi(login:Login,isActive:Bool = false){
        self.showLoader()
        var loginData = login
        loginData.activate = isActive
        DIWebLayerUserAPI().login(parameters: loginData.getDictionaryForSociaSignUp(), success: { (response, status, type) in
            self.hideLoader()
            if status == 1 {
                UserManager.saveCurrentUser(user: response)
                self.sendMessageToWatch()
                self.redirectionOnLoginSuccess(profileCompletionStatus: response.profileCompletionStatus, socialLoginInfo: login)
            }else{
                CustomAlertManager.shared.hideView()
                let otpVC: OtpVerificationViewController = UIStoryboard(storyboard: .main).initVC()
                otpVC.userName = login.username
                if login.username.toInt() == 0 {
                    otpVC.confirmationOption = .email
                } else {
                    otpVC.confirmationOption = .textMessage
                }
                if let type = type {
                    otpVC.verificationType = type
                }
                otpVC.socialLoginInfo = login
                self.navigationController?.pushViewController(otpVC, animated: true)
            }
            
        }) { (error) in
            self.hideLoader()
            if let code = error.code {
                if code == .userDisable {
                    self.showAlert(withTitle: "", message: error.message, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
                        self.callSocialLoginApi(login:login,isActive:true)
                    }) {
                    }
                    return
                }
            }
            self.showAlert(withError:error)
        }
    }
    
    private func redirectionOnLoginSuccess(profileCompletionStatus: Int?, socialLoginInfo: Login?) {
        switch profileCompletionStatus {
        case UserProfileCompletion.notDone.rawValue:
            let createProfileVC: CreateProfileViewController = UIStoryboard(storyboard: .main).initVC()
            createProfileVC.socialLoginInfo = socialLoginInfo
            //saving the social login info to userdefaults
            socialLoginInfo?.saveEncodedInformation()
            appDelegate.setNavigationToRoot(viewContoller: createProfileVC)
        case UserProfileCompletion.createProfile.rawValue:
            let selectInetersts: SelectInterestViewController = UIStoryboard(storyboard: .main).initVC()
            appDelegate.setNavigationToRoot(viewContoller: selectInetersts)
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
                Defaults.shared.set(value: Date(), forKey: .stepsLastFetchTime)
                let homeVC: HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
                appDelegate.setNavigationToRoot(viewContoller: homeVC)
            }
        }
    }
    
    /// This method is valid all the form of login screen.
    ///
    /// - Returns: If user enter wrong data or violate any validation then return false and show error to the user.Otherwise you get true.
    private func isLoginFormValid() -> Bool {
        var message:String?
        let emailMessage = checkEmailOrPhoneValidation(text: emailTxtFld.text ?? "").0
        if emailMessage == "" {
            if passwordTxtFld.text!.isEmpty {
                message = AppMessages.Password.emptyLoginPassword
            }
        }else{
            message = emailMessage
            emailTxtFld.becomeFirstResponder()
        }
        if message != nil {
            //  self.showAlert( message: message)
            return false
        }
        return true
    }
    
    func setErrorMessagesForField() {
        setEmailOrPhoneAccordingToValidation()
        setPasswordAccordingToValidation()
    }
    
    //This method is used to get login params to hit login api.
    private func getLoginParams(isActive:Bool = false) -> Login{
        var login = Login()
        login.username = emailTxtFld.text?.lowercased() ?? ""
        login.password = passwordTxtFld.text ?? ""
        login.activate = isActive
        return login
    }
    
    //This method is used to call login api and redirect user to dashboard.
    private func callLoginApi(isActive:Bool = false){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().login(parameters: getLoginParams(isActive:isActive).getDictionary(), success: { (response,status, type) in
            self.saveEmailAndPassword()
            UserManager.saveCurrentUser(user: response)
            self.hideLoader()
            self.sendMessageToWatch()
            self.updateNewDeviceTokenToServer()
            self.redirectionOnLoginSuccess(profileCompletionStatus: response.profileCompletionStatus, socialLoginInfo: nil)
        }) { (error) in
            self.hideLoader()
            if let code = error.code {
                if code == .userDisable {
                    self.showAlert(withTitle: "", message: error.message, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
                        self.callLoginApi(isActive:true)
                    }) {
                    }
                    return
                }
            }
            self.showAlert(withError:error)
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
    ///save the credentials in keychain
    private func saveEmailAndPassword() {
        if self.rememberMe {
            let password = self.passwordTxtFld.text ?? ""
            let emailOrPhone = self.emailTxtFld.text ?? ""
            keychain.set(password, forKey: "password")
            keychain.set(emailOrPhone, forKey: "emailOrPhone")
        } else {
            keychain.clear()
        }
    }
    
    ///get the saved credentials from keychain
    private func getSavedEmailAndPassword() {
        if let password = keychain.get("password") {
            let emailOrPhone = keychain.get("emailOrPhone")
            self.rememberMe = true
            self.emailTxtFld.text = emailOrPhone
            self.passwordTxtFld.text = password
        } else {
            self.rememberMe = false
        }
        self.rememberMeBtn.isSelected = self.rememberMe
    }
    
    // MARK: @IBAction Methods
    //This method is used to navigate sign up screen.
    @IBAction func signUpTapped(_ sender: UIButton) {
        let signUpVC : SignUpViewController = UIStoryboard(storyboard: .main).initVC()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func rememberMeTapped(_ sender: UIButton) {
        rememberMeBtn.isSelected.toggle()
        self.rememberMe = rememberMeBtn.isSelected
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        setErrorMessagesForField()
        if isLoginFormValid(){
            self.callLoginApi()
        }
    }
    
    @IBAction func forgotPassTapped(_ sender: UIButton) {
        let forgotPassVC : ForgetPasswordViewController = UIStoryboard(storyboard: .main).initVC()
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
    }
    
    @IBAction func facebookTapped(_ sender: UIButton) {
        facebookLogin()
    }
    
    @IBAction func googleTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    
   /**
      - Perform acton on click of Sign in with Apple button
      - making ASAuthorizationAppleIDProvider for apple sign in
     */
    @IBAction func setupSOAppleSignIn(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
        
    }
    
}//Class:--

extension LoginViewController: GIDSignInDelegate{
    // MARK: Google SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if user != nil {
            var login = Login()
            login.username = user.profile.email
            login.snsId = user.userID
            login.snsType = UserType.google.rawValue
            login.firstName = user.profile.givenName
            login.lastName = user.profile.familyName
            login.profilePicure = user.profile.imageURL(withDimension: 200).absoluteString
            self.callSocialMediaExistsApi(login:login)
        }else{
            DILog.print(items: "failure")
            return
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        DILog.print(items: "Disconnect")
    }
}
extension LoginViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CustomTextField {
            textField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
            if let imageView = textField.leftImageView() {
                imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imageView.tintColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
            }
            if textField.text?.isBlank ?? true{
                textField.rightView =  nil
            }
        }
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CustomTextField {
            textField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
            if let imageView = textField.leftImageView() {
                imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imageView.tintColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
            }
            if textField.text?.isBlank ?? true{
                textField.rightView =  nil
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 0 {
            textField.rightView =  nil
            return true
        }
        if string == "\n" {
            return false
        }
        if textField == emailTxtFld || textField == CustomAlertManager.shared.customView.emailTxtFld{
            if (string == " ") {
                return false
            }
            resetEmailErrorMessage()
            let data = checkEmailOrPhoneValidation(text: newString as String)
            textField.rightView = data.1
        } else if textField == passwordTxtFld {
            resetPasswordErrorMessage()
            if string == " " {
                return false
            }
            textField.rightView = rightValidationButton()
        }
        return true
    }
}

extension LoginViewController : CustomAlertDelegate{
    func getEmail(txtFld: UITextField) {
        var login = CustomAlertManager.shared.login
        login.username = txtFld.text ?? ""
        self.callSocialLoginApi(login:login)
    }
    
}

extension LoginViewController: ShowErrorMessage {
    func showError(tag: Int) {
        switch tag {
        case 0:
            setEmailOrPhoneAccordingToValidation()
        case 1:
            setPasswordAccordingToValidation()
        default:
            break
        }
    }
}


extension LoginViewController {
    // MARK: EmailOrPhoneFieldValidation Functions.
    func setEmailOrPhoneAccordingToValidation() {
        let data = checkEmailOrPhoneValidation(text: emailTxtFld.text ?? "")
        emailTxtFld.errorMessage = data.0
        //emailTxtFld.setAttributes()
    }
    
    func checkEmailOrPhoneValidation(text:String) -> (String,UIButton) {
        let output = Validation.shared.validate(values: (.emailOrPhone,(text)))
        switch output {
        case .failure( let message):
            return(message, warningButton(tag: 0))
        case .success:
            return("", rightValidationButton())
        }
    }
    
    // MARK: PasswordFieldValidation Functions.
    func setPasswordAccordingToValidation() {
        if passwordTxtFld.text!.isEmpty {
            passwordTxtFld.errorMessage = AppMessages.Password.emptyLoginPassword
            rememberMeTopConstraint.constant = 25.0
        } else {
            rememberMeTopConstraint.constant = 16.25
        }
    }
    
    func resetPasswordErrorMessage(){
        passwordTxtFld.errorMessage = ""
        rememberMeTopConstraint.constant = 16.25
    }
    
    func resetEmailErrorMessage(){
        emailTxtFld.errorMessage = ""
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    // ASAuthorizationControllerDelegate function for authorization failed
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DILog.print(items: error.localizedDescription)
    }
    
    /*
     -ASAuthorizationControllerDelegate function for successful authorization
     - create login parameters request for apple sign in
     - calling social login api method
     */
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            
            // Create an account as per your requirement
            let appleId = appleIDCredential.user
            var appleUserFirstName = appleIDCredential.fullName?.givenName
            var appleUserLastName = appleIDCredential.fullName?.familyName
            var appleUserEmail = appleIDCredential.email
            
            if appleId == KeychainItem.currentUserIdentifier {
                if appleUserFirstName == "" {
                    appleUserFirstName = KeychainItem.currentUserLastName
                }
                if appleUserLastName == "" {
                    appleUserLastName = KeychainItem.currentUserLastName
                }
                if appleUserEmail == "" {
                    appleUserEmail = KeychainItem.currentUserLastName
                }
            }
            // Create an account in your system.
            // for further use store the these details in the keychain.
            KeychainItem.currentUserIdentifier = appleId
            KeychainItem.currentUserFirstName = appleUserFirstName
            KeychainItem.currentUserLastName = appleUserLastName
            KeychainItem.currentUserEmail = appleUserLastName
            
            
            var login = Login()
            login.username = appleUserEmail ?? ""
            login.snsId = appleId
            login.snsType = UserType.apple.rawValue
            login.firstName = appleUserFirstName ?? ""
            login.lastName = appleUserLastName ?? ""
            
            self.callSocialMediaExistsApi(login:login)
            
            DILog.print(items: appleId,appleUserEmail ?? "",appleUserFirstName ?? "",appleUserLastName ?? "",appleUserEmail ?? "")

        } 
    }
    
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    //For present window
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
