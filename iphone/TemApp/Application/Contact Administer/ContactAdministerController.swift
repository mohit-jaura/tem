//
//  ContactAdministerController.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class ContactAdministerController: DIBaseController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var subjectTextField: CustomTextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: CustomButton!
    @IBOutlet weak var gradientContainerView: UIView!
    @IBOutlet weak var gradientView: GradientDashedLineCircularView!
    @IBOutlet var findTematesShadowView: SSNeumorphicView! {
        didSet {
            findTematesShadowView.viewDepthType = .outerShadow
            findTematesShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            findTematesShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            findTematesShadowView.viewNeumorphicCornerRadius = findTematesShadowView.frame.width/2
            findTematesShadowView.viewNeumorphicShadowRadius = 1.0
        }
    }

    @IBOutlet weak var submitShadowView: SSNeumorphicView!{
        didSet{
            submitShadowView.setOuterDarkShadow()
        }
    }

    final let textViewPlaceholderText = "DESCRIPTION"
    //MARK: ViewLifeCycle.
    override func viewDidLoad() {
        super.viewDidLoadWithKeyboardManager(viewController: self)
        descTextView.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 10)
        descTextView.delegate = self
        descTextView.text = textViewPlaceholderText
        descTextView.textColor = UIColor.lightGray
        subjectTextField.delegate = self
    }

    // MARK: IBActions.
    @IBAction func submitButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if isFormValid() {
            guard Reachability.isConnectedToNetwork() else {
                self.showAlert(message: AppMessages.AlertTitles.noInternet)
                return
            }
            showLoader()
            var objContactUsKey = ContactUsKey()
            objContactUsKey.subject = subjectTextField.text?.trim
            objContactUsKey.message = descTextView.text.trim
            SettingsAPI().contactAdmin(parameters: objContactUsKey.toDict() , success: { (message) in
                self.hideLoader()
                self.showAlert(message: message, okayTitle: "ok".localized, okCall: {
                    self.navigationController?.popViewController(animated: true)
                })
            }, failure: { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            })
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: PrivateFunction.
    private func setGradientView() {
        gradientView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.yellow.withAlphaComponent(0.6), UIColor.cyan.withAlphaComponent(1)], gradientLocations: [0.28, 0.30, 0.55])
        gradientView.instanceWidth = 1.5
        gradientView.instanceHeight = 3.0
        gradientView.extraInstanceCount = 1
    }
    // MARK: Function to check Form Validation.
    func isFormValid() -> Bool {
        var message:String?
        if (subjectTextField.text?.isBlank) ?? false {
            message = AppMessages.ContactUs.emptySubject
        }else if (descTextView.text?.isBlank) ?? false {
            message = AppMessages.ContactUs.emptyMessage
        }
        if message != nil {
            self.showAlert(message:message)
            return false
        }
        return true
    }
}

// MARK: UITeaxtFieldDelegate.
extension ContactAdministerController:UITextFieldDelegate {
    
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
        let AccaptableCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=;':?><,./ "
        let cs = NSCharacterSet(charactersIn: AccaptableCharacter).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
}


// MARK: UITeaxtFieldDelegate.
extension ContactAdministerController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return (textView.text.count + text.count < Constant.contactDescriptionLength)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descTextView.textColor == UIColor.lightGray || descTextView.text == textViewPlaceholderText {
            descTextView.text = ""
            descTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if descTextView.text.hasPrefix(" ") || descTextView.text.count == 0 {
            descTextView.text = textViewPlaceholderText
            descTextView.textColor = UIColor.lightGray
        }
    }
}
