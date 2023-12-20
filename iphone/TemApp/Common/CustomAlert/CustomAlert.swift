//
//  CustomAlert.swift
//  MrClipper
//
//  Created by debut on 09/10/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit
protocol CustomAlertDelegate {
    func getEmail(txtFld: UITextField)
}

class CustomAlert: UIView {

    class func instanceFromNib() -> CustomAlert {
        return UINib(nibName: "CustomAlert", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomAlert
    }
    var delegate : CustomAlertDelegate?
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var alertViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTxtFld: CustomTextField!
    
    
    private func isValidEmail() -> Bool {
        var message:String?
        if (emailTxtFld.text?.isBlank)! {
            message = AppMessages.Email.loginEmptyEmail
        }else if !((emailTxtFld.text?.isValidEmail)!) {
            message = AppMessages.Email.loginInValidEmail
        }
        if message != nil {
            self.showAlert( message: message)
            return false
        }
        return true
    }
    
    func resetFormField() {
        self.emailTxtFld.text = ""
    }
    
    func showAlert(withTitle title: String = appName, message:String? = nil, okayTitle:String = AppMessages.AlertTitles.Ok , cancelTitle:String? = nil , okCall:@escaping () -> ()  = {  }, cancelCall: @escaping () -> () = {  }) {
        
        //DILog.print(items: title ?? appName)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okayTitle, style: .default, handler: { (action) in
            okCall()
        }))
        if cancelTitle != nil {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                cancelCall()
            }))
        }
        Constant.App.delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func crossTapped(_ sender: UIButton) {
        CustomAlertManager.shared.hideView()
    }
    
    
    @IBAction func okTapped(_ sender: Any) {
        if isValidEmail() {
            delegate?.getEmail(txtFld: emailTxtFld)
        }
    }
}

