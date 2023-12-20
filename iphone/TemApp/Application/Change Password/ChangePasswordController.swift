//
//  ChangePasswordController.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SSNeumorphicView
class ChangePasswordController: DIBaseController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
     @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: CustomButton!
    @IBOutlet weak var saveShadowView: SSNeumorphicView!{
        didSet{
            saveShadowView.setOuterDarkShadow()
        }
    }
    // MARK: ViewLifeCycle.
    // MARK: ViewDidLoad.
    override func viewDidLoad() {
        super.viewDidLoadWithKeyboardManager(viewController: self)
        initUI()
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }

    // MARK: IBActions.
    // MARK: SubmitButtonAction to Reset Password.
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        changePasswordAction(button:sender)
    }

    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: PrivateFunction.
    // MARK: Function to init UI.
    private func initUI() {
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    // MARK: Function For Checking Form Validation.
    private func isFormValid() -> Bool {
        var message : String?
        if (oldPasswordTextField.text?.isBlank)! {
            message = AppMessages.ChangePassword.currentPasswordBlank
        }else if (newPasswordTextField.text?.isBlank)! {
            message = AppMessages.ChangePassword.newPasswordBlank
        }
        
        else if !(newPasswordTextField.text?.trimmed.checkValidPassword == AppMessages.CommanMessages.success) {
            message = newPasswordTextField.text?.trimmed.checkValidPassword
        }

        else if (confirmPasswordTextField.text?.isBlank)! {
            message = AppMessages.ChangePassword.confirmPasswordBlank
        }else if confirmPasswordTextField.text?.trim != newPasswordTextField.text?.trim {
            message = AppMessages.ChangePassword.passwordDoesnotMatch
        }
        if message != nil {
            self.showAlert(message:message)
            return false
        }
        return true
    }
    
    // MARK: ResetButtonAction.
    private func changePasswordAction(button:UIButton){
        guard Reachability.isConnectedToNetwork() else {
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
            return
        }
        if isFormValid() {
            var objChangePasswordKey = ChangePasswordKey()
            objChangePasswordKey.oldPassword = oldPasswordTextField.text?.trim
            objChangePasswordKey.newPassword = newPasswordTextField.text?.trim
            guard Reachability.isConnectedToNetwork() else {
                self.showAlert(message: AppMessages.AlertTitles.noInternet)
                return
            }
            self.showLoader()
            SettingsAPI().changePassword(parameters: objChangePasswordKey.toDict(), success: { (message) in
                self.hideLoader()
                self.showAlert(withTitle: "", message:message, okayTitle: "ok".localized, okCall: {
                    self.navigationController?.popViewController(animated: true)
                })
            }, failure: { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            })
        }
    }
}


// MARK: UITextFieldDelegate
extension ChangePasswordController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        if let textField = textField as? CustomTextField {
            if let imageView = textField.leftImageView() {
                imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imageView.tintColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
            }
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
        if (textField.text?.isBlank)! {
            if string.first == " " {
                return false
            }
        }
        let AccaptableCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=;':?><,./"
        let cs = NSCharacterSet(charactersIn: AccaptableCharacter).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
}
