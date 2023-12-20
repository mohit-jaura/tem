//
//  SignUpViewController.swift
//  TemApp
//
//  Created by dhiraj on 12/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.


import UIKit
import SSNeumorphicView

class SignUpViewController: DIBaseController {
    
    
    @IBOutlet weak var passwordEyeButton: UIButton!
    @IBOutlet weak var passwordFieldValidationButton: UIButton!
    @IBOutlet weak var agreeFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsAndConditionBtn: UIButton!
    @IBOutlet weak var firstNameTxtFld: CustomTextField!
    @IBOutlet weak var lastNameTxtFld: CustomTextField!
    @IBOutlet weak var emailTxtFld: CustomTextField!
    //    @IBOutlet weak var phoneNoTxtFld: CountryPickerTextField!
    @IBOutlet weak var phoneNoTxtFld: CustomTextField!
    @IBOutlet weak var passwordTxtFld: CustomTextField!
    @IBOutlet weak var signupShadowView: SSNeumorphicView!{
        didSet{
            signupShadowView.setOuterDarkShadow()
        }
    }
    @IBOutlet weak var countryPickerButton: UIButton!
    
    var countryList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        intilalizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        SelectCountryViewController.delegate = self
        DIBaseController.errorDelegate = self
    }
    
    // MARK: Custom Methods:---
    
    private func intilalizer() {
        termsAndConditionBtn.isSelected = false
        emailTxtFld.delegate = self
        firstNameTxtFld.delegate = self
        lastNameTxtFld.delegate = self
        passwordTxtFld.delegate = self
        getCountryCode()
        phoneNoTxtFld.delegate = self
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let currentCountry = SelectCountryViewController.getCountryPhonceCode(countryCode)
            countryPickerButton.setTitle(currentCountry, for: .normal)
        }
    }
    
    func getCountryCode(){
        DIWebLayerUserAPI().getCountryCode(success: { (response) in
            self.hideLoader()
            self.countryList = response
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    // MARK: Function to check form validation of Registration.
    //-----Developer -> Shubham Singla
    func isRegistrationFormValid() -> Bool {
        var message:String?
      //  isValidPassword(passwordTxtFld.text?.trimmed ?? "")
        if (firstNameTxtFld.text?.isBlank)!{
            message = AppMessages.UserName.emptyFirstname
        }else if !(firstNameTxtFld.text?.isValidInRange(minLength: Constant.MinimumLength.firstLastName, maxLength: Constant.MaximumLength.firstName))!{
            message = AppMessages.UserName.maxLengthFirstname
        } else if (lastNameTxtFld.text?.isBlank)!{
            message = AppMessages.SignUp.enterLastName
        }else if !(lastNameTxtFld.text?.isValidInRange(minLength: Constant.MinimumLength.firstLastName, maxLength: Constant.MaximumLength.lastName))!{
            message = AppMessages.UserName.maxLengthLastname
        }else if (!(emailTxtFld.text?.isBlank)! && !((emailTxtFld.text?.isValidEmail)!)){
            message = AppMessages.Email.invalidEmail
        } else if !(phoneNoTxtFld.text?.isBlank)! && !(phoneNoTxtFld.text?.isValidInRange(minLength: Constant.MinimumLength.phoneNumber, maxLength: Constant.MaximumLength.phoneNumber))!{
            message = AppMessages.PhoneNumber.invalid
        } else if (emailTxtFld.text?.isBlank)! && (phoneNoTxtFld.text?.isBlank)!{
            message = AppMessages.Email.emptyEmailOrPhoneNo
            self.showAlert( message: message)
        }else if (passwordTxtFld.text?.isBlank)!{
            message = AppMessages.Password.emptyPassword
        }
        else if !(passwordTxtFld.text?.trimmed.checkValidPassword == AppMessages.CommanMessages.success) {
                        message = passwordTxtFld.text?.trimmed.checkValidPassword
                        passwordTxtFld.errorMessage = message ?? AppMessages.Password.invalidNewPassword
                    }
//        else if !(passwordTxtFld.text?.trimmed.isValidPasswordForRange(minLength: Constant.MinimumLength.password, maxLength: Constant.MaximumLength.password))!{
//            message = AppMessages.Password.invalidNewPassword
//        }
        
        else if !termsAndConditionBtn.isSelected{
            message = AppMessages.UserName.termsAndCondition
            self.showAlert( message: message)
        }
        if message != nil {
            //  self.showAlert( message: message)
            return false
        }
        return true
        /*if emailTxtFld.text!.isEmpty && phoneNoTxtFld.text!.isEmpty {
            self.showAlert(message: AppMessages.UserName.enterEmailOrPhone)
            return false
        }
        
        let output = Validation.shared.validate(values: (.firstName, firstNameTxtFld.text), (.lastName, lastNameTxtFld.text), (.email, emailTxtFld.text), (.phoneNo, phoneNoTxtFld.text), (.password, passwordTxtFld.text))
        switch output {
        case .success:
            if !termsAndConditionBtn.isSelected {
                self.showAlert(message: AppMessages.UserName.termsAndCondition)
                return false
            }
            return true
        case .failure(_):
            return false
        } */
    }
    func checkFormValidation()  {
        setFirstNameAccordingToValidation()
        setLastNameAccordingToValidation()
        setEmailAccordingToValidation()
        setPhoneNumberAccordingToValidation()
        setPasswordAccordingToValidation()
    }
    
    //This method is used to get registration api request params.
    private func getRegistrationParams() -> Registration{
        var registration = Registration()
        registration.firstName = firstNameTxtFld.text?.firstUppercased ?? ""
        registration.lastName = lastNameTxtFld.text?.firstUppercased ?? ""
        registration.email = emailTxtFld.text ?? ""
        registration.password = passwordTxtFld.text ?? ""
        registration.phone = self.phoneNoTxtFld.text ?? ""
        registration.countryCode = countryPickerButton.titleLabel?.text ?? ""
        return registration
    }
    
    
    //This method is used to call registration api.
    private func callRegistrationApi(){
        self.showLoader()
        let registrationParmasObj = getRegistrationParams()
        DIWebLayerUserAPI().registation(parameters: registrationParmasObj.getDictionary(), success: { (response) in
            self.hideLoader()
            User.sharedInstance.isFromSignUp = true
            self.showAlert(message:response,okCall:{
                let otpVC: OtpVerificationViewController = UIStoryboard(storyboard: .main).initVC()
                if !registrationParmasObj.phone.isEmpty {
                    otpVC.userName = registrationParmasObj.phone
                    otpVC.confirmationOption = .textMessage
                } else {
                    otpVC.userName = registrationParmasObj.email
                    otpVC.confirmationOption = .email
                }
                self.navigationController?.pushViewController(otpVC, animated: true)
            })
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    // MARK: @IBAction Methods
    @IBAction func signUpTapped(_ sender: UIButton) {
        checkFormValidation()
        if isRegistrationFormValid(){
            if isConnectedToNetwork() {
                self.callRegistrationApi()
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Function to pick country.
    @IBAction func countryPickerButtonAction(_ sender: UIButton) {
        let countryVC  = SelectCountryViewController()
        countryVC.selectedCountryCodeList = countryList
        self.navigationController?.pushViewController(countryVC, animated: false)
    }
    
    @IBAction func termsTapped(_ sender: UIButton) {
        if self.isConnectedToNetwork() {
            let controller:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
            controller.urlString = Constant.WebViewsLink.termsAndConditions
            controller.navigationTitle = Constant.ScreenFrom.termsOfService.title
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func policyTapped(_ sender: UIButton) {
        if self.isConnectedToNetwork() {
            let controller:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
            controller.urlString=Constant.WebViewsLink.privacyPolicy
            controller.navigationTitle=Constant.ScreenFrom.privacyPolicy.title
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func agreeTermsTapped(_ sender: UIButton) {
        termsAndConditionBtn.isSelected = !termsAndConditionBtn.isSelected
    }
    
    @IBAction func passwordEyeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordTxtFld.isSecureTextEntry = !sender.isSelected
    }
    @IBAction func passwordValidationButtonTapped(_ sender: UIButton) {
        self.setPasswordAccordingToValidation()
    }
}
extension SignUpViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        if let textField = textField as? CustomTextField {
            if let imageView = textField.leftImageView() {
                imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imageView.tintColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
            }
        }
        if textField.text?.isBlank ?? true{
            textField.rightView =  nil
            if textField == passwordTxtFld {
                passwordFieldValidationButton.isHidden = true
            }
        }
//        //customize for password field
//        if textField == passwordTxtFld {
//            passwordFieldValidationButton.isHidden = true
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        if let textField = textField as? CustomTextField {
            if let imageView = textField.leftImageView() {
                imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imageView.tintColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 0 {
            textField.rightView =  nil
            if textField == passwordTxtFld {
                passwordFieldValidationButton.isHidden = true
            }
            return true
        }
        if (textField.text?.isBlank)! {
            if string.first == " " {
                return false
            }
        }
        var AccaptableCharacter = nameAccaptableCharacter
        if textField == emailTxtFld {
            AccaptableCharacter = emailAccaptableCharacter
        }else if textField == passwordTxtFld {
            AccaptableCharacter = passwordAccaptableCharacter
        }else if textField == phoneNoTxtFld {
            AccaptableCharacter = phoneAccaptableCharacter
        }
        let cs = NSCharacterSet(charactersIn: AccaptableCharacter).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        if filtered == string {
            if textField == firstNameTxtFld {
                resetFirstNameErrorMessage()
                let data = checkFirstNameValidation(text: newString as String)
                textField.rightView = data.1
            }else if textField == lastNameTxtFld {
                resetLastNameErrorMessage()
                let data = checkLastNameValidation(text: newString as String)
                textField.rightView = data.1
            }else if textField == emailTxtFld {
                resetEmailErrorMessage()
                let data = checkEmailValidation(text: newString as String)
                textField.rightView = data.1
            } else if textField == phoneNoTxtFld {
                resetPhoneErrorMessage()
                let data = checkPhoneNumberValidation(text: newString as String)
                textField.rightView = data.1
            } else if textField == passwordTxtFld {
                resetPasswordErrorMessage()
                 _ = checkPasswordValidation(text: newString as String)
                //textField.rightView = data.1
            }
        }
        return (string == filtered)
    }
}


extension SignUpViewController: ShowErrorMessage {
    func showError(tag: Int) {
        switch tag {
        case 0:
            setFirstNameAccordingToValidation()
        case 1:
            setLastNameAccordingToValidation()
        case 2:
            setEmailAccordingToValidation()
        case 3:
            setPhoneNumberAccordingToValidation()
//        case 4:
//            setPasswordAccordingToValidation()
        default:
            break
        }
        
    }
}



extension SignUpViewController {
    
    // MARK: FirstNameValidation Functions.
    func setFirstNameAccordingToValidation() {
        let data = checkFirstNameValidation(text: firstNameTxtFld.text ?? "")
        firstNameTxtFld.errorMessage = data.0
    }
    
    // MARK: LastNameValidation Functions.
    func setLastNameAccordingToValidation() {
        let data = checkLastNameValidation(text: lastNameTxtFld.text ?? "")
        lastNameTxtFld.errorMessage = data.0
    }
    
    // MARK: EmailFieldValidation Functions.
    func setEmailAccordingToValidation() {
        let data = checkEmailValidation(text: emailTxtFld.text ?? "")
        emailTxtFld.errorMessage = data.0
    }
    
    // MARK: PhoneNumberFieldValidation Functions.
    func setPhoneNumberAccordingToValidation() {
        let data = checkPhoneNumberValidation(text: phoneNoTxtFld.text ?? "")
        phoneNoTxtFld.errorMessage = data.0
    }
    
    // MARK: PasswordFieldValidation Functions.
    func setPasswordAccordingToValidation() {
        let data = checkPasswordValidation(text: passwordTxtFld.text ?? "")
        passwordTxtFld.errorMessage = data.0
        agreeFieldTopConstraint.constant = 50.0
        if data.0 == "" {
            agreeFieldTopConstraint.constant = 20.0//12.0
        }
    }
    func checkPasswordValidation(text:String) -> (String,UIButton) {
        print(text)
        self.passwordFieldValidationButton.isHidden = false
        if !(text.trimmed.checkValidPassword == AppMessages.CommanMessages.success) {
            self.passwordFieldValidationButton.setImage(#imageLiteral(resourceName: "Error"), for: .normal)
            return(text.trimmed.checkValidPassword , warningButton(tag: 4))
         } else {
            self.passwordFieldValidationButton.setImage(#imageLiteral(resourceName: "right"), for: .normal)
            return("", rightValidationButton())
        }
        
        
//        let output = Validation.shared.validate(values: (.password,(text)))
//        self.passwordFieldValidationButton.isHidden = false
//        switch output {
//        case .failure( let message):
//            self.passwordFieldValidationButton.setImage(#imageLiteral(resourceName: "Error"), for: .normal)
//            return(message, warningButton(tag: 4))
//        case .success:
//            self.passwordFieldValidationButton.setImage(#imageLiteral(resourceName: "right"), for: .normal)
//            return("", rightValidationButton())
//        }
    }
    
    func resetFirstNameErrorMessage(){
        firstNameTxtFld.errorMessage = ""
    }
    func resetLastNameErrorMessage(){
        lastNameTxtFld.errorMessage = ""
    }
    func resetEmailErrorMessage(){
        emailTxtFld.errorMessage = ""
    }
    func resetPhoneErrorMessage(){
        phoneNoTxtFld.errorMessage = ""
    }
    func resetPasswordErrorMessage(){
        passwordTxtFld.errorMessage = ""
        agreeFieldTopConstraint.constant = 20.0//12.0
    }
}


extension SignUpViewController : SelectCountryViewControllerDelegate{
    // MARK: SelectCountryViewControllerDelegate function.
    func setCountryCode(code: String) {
        countryPickerButton.setTitle(code, for: .normal)
    }
}

