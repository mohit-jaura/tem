//
//  ResetPasswordViewController.swift
//  TemApp
//
//  Created by Sourav on 2/13/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ResetPasswordViewController: DIBaseController {
    
    var resetToken : String = ""
    var username : String = ""
    private let stackSpacing: CGFloat = 35
    private var maxErrorHeight: CGFloat = 35
    
    // MARK: @IBOutlets....
    @IBOutlet weak var newPasswordTextField: CustomTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomTextField!
    @IBOutlet weak var textfieldsStackContainerView: UIStackView!
    
    @IBOutlet weak var submitShadowView: SSNeumorphicView!{
        didSet{
            submitShadowView.setOuterDarkShadow()
        }
    }
    @IBOutlet weak var submitButton: UIButton!
    // MARK: App life Cycle....
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DIBaseController.errorDelegate = self
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: Custom Methods
    func initializer(){
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.newPasswordTextField.customFieldDelegate = self
        self.confirmPasswordTextField.customFieldDelegate = self
    }
    
    //Function to check form validation of reset password.
    func isResetFormValid() -> Bool {
        var message:String?
        if (newPasswordTextField.text?.isBlank)!{
            message = AppMessages.Password.emptyPassword
        }
        else if !(newPasswordTextField.text?.trimmed.checkValidPassword == AppMessages.CommanMessages.success) {
            message = newPasswordTextField.text?.trimmed.checkValidPassword
            newPasswordTextField.errorMessage = message ?? AppMessages.Password.invalidNewPassword
        }
            //        else if !(newPasswordTextField.text?.trimmed.isValidPasswordForRange(minLength: Constant.MinimumLength.password, maxLength: Constant.MaximumLength.password))!{
            //            message = AppMessages.Password.invalidNewPassword
            //        }
        else if (confirmPasswordTextField.text?.isBlank)! {
            message = AppMessages.Password.emptyConfirmPassword
        }else if newPasswordTextField.text != confirmPasswordTextField.text{
            message = AppMessages.Password.newConfirmMismatch
        }
        if message != nil {
            // self.showAlert( message: message)
            return false
        }
        return true
    }
    
    
    func setErrorMessagesForField() {
        setNewPasswordAccordingToValidation()
        setConfirmPasswordPasswordAccordingToValidation()
    }
    
    //This method is used to get reset password api params.
    func getResetPwdParams() -> ResetPassword{
        var resetPassword = ResetPassword()
        resetPassword.username = username
        resetPassword.password = newPasswordTextField.text ?? ""
        resetPassword.resetToken = resetToken
        return resetPassword
    }
    
    //This method is used to call reset password api.
    func callResetPasswordApi(){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().resetPassword(parameters: getResetPwdParams().getDictionary(), success: { (response) in
            self.hideLoader()
            self.showAlert(message: response, okCall: {
                self.navigationController?.popToRootViewController(animated: true)
            })
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    // MARK: @IBAction Methods.....
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        setErrorMessagesForField()
        if isResetFormValid(){
            self.callResetPasswordApi()
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}//Class...


// MARK: - UITextFieldDelegate Method
extension ResetPasswordViewController:UITextFieldDelegate{
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 0 {
            textField.rightView =  nil
            return true
        }
        if textField == newPasswordTextField {
            resetNewPasswordErrorMessage()
            let data = checkNewPasswordValidation(text: newString as String)
            textField.rightView = data.1
        } else if textField == confirmPasswordTextField {
            resetConfirmPasswordErrorMessage()
            if newPasswordTextField.text == (newString as String) {
                textField.rightView = rightValidationButton()
            } else {
                textField.rightView = warningButton(tag: 1)
            }
        }
        return true
    }
}

extension ResetPasswordViewController: ShowErrorMessage {
    func showError(tag: Int) {
        switch tag {
        case 0:
            setNewPasswordAccordingToValidation()
        case 1:
            setConfirmPasswordPasswordAccordingToValidation()
        default:
            break
        }
        
    }
}



extension ResetPasswordViewController {
    
    // MARK: PasswordFieldValidation Functions.
    func setNewPasswordAccordingToValidation() {
        let data = checkNewPasswordValidation(text: newPasswordTextField.text ?? "")
        newPasswordTextField.errorMessage = data.0
        if data.0 == "" {
            updateStackView(spacing: stackSpacing)
        }
    }
    func checkNewPasswordValidation(text:String) -> (String,UIButton) {
        if text == "" {
            return(AppMessages.ResetPassword.enterNewPassword , warningButton(tag: 0))
        }
        if !(text.trimmed.checkValidPassword == AppMessages.CommanMessages.success) {
            return(text.trimmed.checkValidPassword , warningButton(tag: 0))
        } else {
            return("", rightValidationButton())
        }
        
        
        
        //        let output = Validation.shared.validate(values: (.newPassword,(text)))
        //        switch output {
        //        case .failure( let message):
        //            return(message, warningButton(tag: 0))
        //        case .success:
        //            return("", rightValidationButton())
        //        }
    }
    
    // MARK: ConfirmPasswordFieldValidation Functions.
    func setConfirmPasswordPasswordAccordingToValidation(){
        if (confirmPasswordTextField.text?.isBlank)! {
            confirmPasswordTextField.errorMessage = AppMessages.Password.emptyConfirmPassword
        }else if newPasswordTextField.text != confirmPasswordTextField.text{
            confirmPasswordTextField.errorMessage = AppMessages.Password.newConfirmMismatch
        }
    }
    
    func resetNewPasswordErrorMessage(){
        newPasswordTextField.errorMessage = ""
        updateStackView(spacing: stackSpacing)
    }
    
    func resetConfirmPasswordErrorMessage(){
        confirmPasswordTextField.errorMessage = ""
        updateStackView(spacing: stackSpacing)
    }
}

// MARK: CustomTextFieldDelegate
extension ResetPasswordViewController: CustomTextFieldDelegate {
    func didUpdateErrorLabelOn(textfield: CustomTextField, errorHeight: CGFloat) {
        if errorHeight == 0 {
            self.updateStackView(spacing: stackSpacing)
            maxErrorHeight = stackSpacing
        }else if errorHeight >= maxErrorHeight {
            maxErrorHeight = errorHeight
            self.updateStackView(spacing: errorHeight + 2)
        } else if maxErrorHeight > errorHeight {
            self.updateStackView(spacing: maxErrorHeight + 2)
        } else {
            self.updateStackView(spacing: stackSpacing)
        }
    }
    
    private func updateStackView(spacing: CGFloat) {
        self.textfieldsStackContainerView.spacing = spacing
        self.view.layoutIfNeeded()
    }
}
