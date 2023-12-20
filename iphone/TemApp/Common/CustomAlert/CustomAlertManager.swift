//
//  CustomAlertManager.swift
//  MrClipper
//
//  Created by debut on 09/10/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit

class CustomAlertManager: NSObject {
    
    static let shared = CustomAlertManager()
    var  customView = CustomAlert.instanceFromNib()
    var login = Login()
    
    func showCustomAlert(){
        customView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        customView.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        if Constant.DeviceType.IS_IPHONE_4_OR_LESS{
            customView.alertViewWidthConstraint.constant = 280
        } else if Constant.DeviceType.IS_IPHONE_5{
            customView.alertViewWidthConstraint.constant = 300
        } else {
            customView.alertViewWidthConstraint.constant = 340
        }
        customView.resetFormField()
        Constant.App.delegate.window?.rootViewController?.view.addSubview(customView)
    }
    
    func hideView(){
        customView.removeFromSuperview()
    }
    
}
