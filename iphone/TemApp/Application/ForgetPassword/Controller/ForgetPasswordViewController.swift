//
//  ForgetPasswordViewController.swift
//  TemApp
//
//  Created by Sourav on 2/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ForgetPasswordViewController: DIBaseController {
    
    // MARK: @IBOutlets...
    
    @IBOutlet weak var emailOrPhoneNoTextField: CustomTextField!
    @IBOutlet weak var submitShadowView: SSNeumorphicView!{
        didSet{
            submitShadowView.setOuterDarkShadow()
        }
    }

    @IBOutlet weak var submitButton: UIButton!
    // MARK: App life Cycle:--
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intializer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DIBaseController.errorDelegate = self
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: Custom Methods....
    private func intializer() {
        emailOrPhoneNoTextField.delegate = self
    }
    
    /// This method is valid all the form of forgot password screen.
    ///
    /// - Returns: If user enter wrong data or violate any validation then return false and show error to the user.Otherwise you get true.
    private func isForgotPassFormValid() -> Bool {
        return setEmailOrPhoneAccordingToValidation()
    }
    
    //This method is uset get forgot Password parameters.
    private func getResendOtpParams() -> OTPVerification{
        var otpVerification = OTPVerification()
        otpVerification.username = emailOrPhoneNoTextField.text ?? ""
        return otpVerification
    }
    
    //This method is used to call forgot password api by getting email or phone no.
    private func callForgotPasswordApi(){
        self.showLoader()
        DIWebLayerUserAPI().forgotPassword(parameters:getResendOtpParams().getForgotDictionary(), success: { (response) in
            self.hideLoader()
            self.showAlert(message:response, okCall: {
                let otpVerificationVC : OtpVerificationViewController = UIStoryboard(storyboard: .main).initVC()
                otpVerificationVC.screenFrom = .forgotPassword
                otpVerificationVC.userName = self.emailOrPhoneNoTextField.text ?? ""
                if let emailOrPhone = self.emailOrPhoneNoTextField.text {
                    if emailOrPhone.toInt() == 0 {  //user has entered the email in the field
                        otpVerificationVC.confirmationOption = .email
                    } else { //user has entered phone number
                        otpVerificationVC.confirmationOption = .textMessage
                    }
                }
                self.navigationController?.pushViewController(otpVerificationVC, animated: true)
            })
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    // MARK: @IBAction Methods....
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        if isForgotPassFormValid(){
            self.callForgotPasswordApi()
        }
    }
    
}//Class.....
extension ForgetPasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 0 {
            textField.rightView =  nil
            return true
        }
        if (string == " ") {
            return false
        }
        resetEmailOrPhoneErrorMessage()
        let data = checkEmailOrPhoneValidation(text: newString as String)
        textField.rightView = data.1
        return true
    }
    
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
        }
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
}


extension ForgetPasswordViewController: ShowErrorMessage {
    func showError(tag: Int) {
        switch tag {
        case 0:
             _ = setEmailOrPhoneAccordingToValidation()
        default:
            break
        }
    }
}

extension ForgetPasswordViewController {
    
    
    // MARK: EmailOrPhoneFieldValidation Functions.
    func setEmailOrPhoneAccordingToValidation() -> Bool {
        let data = checkEmailOrPhoneValidation(text: emailOrPhoneNoTextField.text ?? "")
        emailOrPhoneNoTextField.errorMessage = data.0
        return data.2
    }
    func checkEmailOrPhoneValidation(text:String) -> (String,UIButton,Bool) {
        let output = Validation.shared.validate(values: (.emailOrPhone,(text)))
        switch output {
        case .failure( let message):
            return(message, warningButton(tag: 0),false)
        case .success:
            return("", rightValidationButton(),true)
        }
    }
    
    func resetEmailOrPhoneErrorMessage(){
        emailOrPhoneNoTextField.errorMessage = ""
    }
}
