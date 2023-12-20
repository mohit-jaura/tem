//
//  ChangeEmailPhoneVC.swift
//  TemApp
//
//  Created by Narinder Singh on 24/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class ChangeEmailPhoneVC: DIBaseController {
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var textfield: CustomTextField!
    @IBOutlet weak var verifyBtn: UIButton!
    var fromEmail:Bool!
    var email:String!
    var phone:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfield.delegate = self
        if(fromEmail){
            titleLable.text = "CHANGE EMAIL"
            self.textfield.keyboardType = UIKeyboardType.emailAddress
            self.textfield.maxLength = 45
        }else{
            titleLable.text = "CHANGE PHONE \n NUMBER"
             self.textfield.keyboardType = UIKeyboardType.phonePad
            self.textfield.maxLength = 15
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        DIBaseController.errorDelegate = self
    }
    
    func getEmailParams() -> [String : Any]{
        let type = 1
        let param = ["type":type, "email": textfield.text?.trimmed ?? ""] as [String : Any]
        return param
    }
    
    func getPhoneParam() -> [String : Any]{
        let type =  2
        let param = ["type":type, "phone": textfield.text?.trimmed ?? "","country_code":"+91"] as [String : Any]
        return param
    }
    
    func checkValidation() ->  Bool{
        if(fromEmail){
            let data = checkEmailValidation(text: textfield.text ?? "")
            textfield.errorMessage = data.0
            
        }else{
            let data = checkPhoneNumberValidation(text: textfield.text ?? "")
            textfield.errorMessage = data.0
        }
        if(textfield.errorMessage != ""){
            return false
        }
        return true
    }
    
    @IBAction func verifyBtn(_ sender: Any) {
        if (checkValidation() == false){
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().updateEmailPhone(parameters: fromEmail == true ? getEmailParams() : getPhoneParam(), success: { (finished, message) in
            self.hideLoader()
            if (finished){
                let otpVC: OtpVerificationViewController = UIStoryboard(storyboard: .main).initVC()
                otpVC.userName = self.textfield.text!.trimmed
                otpVC.fromEditProfile = true
                otpVC.forEmail  = self.fromEmail
                otpVC.popController = 2
                if(self.fromEmail){
                    otpVC.confirmationOption = .email
                }else{
                    otpVC.confirmationOption = .textMessage
                }
                self.navigationController?.pushViewController(otpVC, animated: true)
            }
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError: error, okayTitle: "OK", cancelTitle: nil, okCall: {
            }, cancelCall: {
            })
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension ChangeEmailPhoneVC:UITextFieldDelegate{
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
        var AccaptableCharacter = passwordAccaptableCharacter
        if self.fromEmail {
            AccaptableCharacter = emailAccaptableCharacter
        }
        let cs = NSCharacterSet(charactersIn: AccaptableCharacter).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        if filtered == string {
            if self.fromEmail {
                resetEmailErrorMessage()
                let data = checkEmailValidation(text: newString as String)
                textField.rightView = data.1
            }else{
                resetPhoneErrorMessage()
                let data = checkPhoneNumberValidation(text: newString as String)
                textField.rightView = data.1
            }
        }
        return (filtered == string)
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

extension ChangeEmailPhoneVC: ShowErrorMessage {
    func showError(tag: Int) {
        switch tag {
        case 2:
            setEmailAccordingToValidation()
        case 3:
            setPhoneNumberAccordingToValidation()
        default:
            break
        }
    }
}
extension ChangeEmailPhoneVC {

    // MARK: EmailFieldValidation Functions.
    func setEmailAccordingToValidation() {
        let data = checkEmailValidation(text: textfield.text ?? "")
        textfield.errorMessage = data.0
    }

    // MARK: PhoneNumberFieldValidation Functions.
    func setPhoneNumberAccordingToValidation() {
        let data = checkPhoneNumberValidation(text: textfield.text ?? "")
        textfield.errorMessage = data.0
    }

    func resetEmailErrorMessage(){
        textfield.errorMessage = ""
    }
    func resetPhoneErrorMessage(){
        textfield.errorMessage = ""
    }
}
