//
//  DIBaseController+Extension.swift
//  Omakase
//
//  Created by Harpreet on 24/10/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import SideMenu
import SSNeumorphicView
// MARK: - Navigation Bar Delegate.
extension DIBaseController: NavigationDelegate {
    @objc func navigationBar(_ navigationBar: NavigationBar, titleLabelTapped titleLabel: UILabel) {
        
    }
    
    func redirectToDashBoard() {
        if let tabBarController = self.navigationController?.findController(controller: TabBarViewController.self) {
            if (tabBarController.viewControllers?.first as? DashboardViewController) != nil{
                self.navigationController?.popToViewController(tabBarController, animated: true)
                let mainwindow = (UIApplication.shared.delegate?.window!)!
                mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
                UIView.transition(with: mainwindow, duration: 0.55001, options: .transitionFlipFromLeft, animations: { () -> Void in
                }) { (_) -> Void in
                }
            }
        }
    }
    
    
    // MARK: Customize views
    func ver1(_ viewGet:SSNeumorphicView, _ cornorRadius:CGFloat = 0) {
        viewGet.viewDepthType = .innerShadow
        viewGet.viewNeumorphicMainColor = viewGet.backgroundColor?.cgColor
        viewGet.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
        viewGet.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        viewGet.viewNeumorphicCornerRadius = cornorRadius
    }
    func ver2(_ thisView:SSNeumorphicView) {
        thisView.viewDepthType = .outerShadow
        thisView.viewNeumorphicMainColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
        thisView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        thisView.viewNeumorphicDarkShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
        thisView.viewNeumorphicCornerRadius = 8
    }
    func outShadowVer1(_ thisView:SSNeumorphicView, radius: Int = 8) {
        thisView.viewDepthType = .outerShadow
        thisView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.09).cgColor
        thisView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        thisView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        thisView.viewNeumorphicCornerRadius = CGFloat(radius)
    }
    
    func configureNavigtion(onView view: UIView, title: String?, leftButtonAction leftAction: ButtonAction = .back, rightButtonAction:[ButtonAction] = [.hidden] ,backgroundColor: UIColor = .clear, showBottomSeparator: Bool? = false,isProfile:Bool = false) -> NavigationBar {
        
        if let child = self.children.first(where: {$0.isKind(of: NavigationBar.self)}) {
            if let navigationBar = child as? NavigationBar {
                return navigationBar
            }
        }
        view.backgroundColor = .clear
        let navBar = NavigationBar()
        addChild(navBar)
        navBar.view.frame = view.bounds
        navBar.view.tag = 1008
        view.addSubview(navBar.view)
        navBar.isProfile = isProfile
        navBar.configureNavigation(title,leftButtonAction:leftAction,rightButtonAction:rightButtonAction,backgroundColor: backgroundColor, showBottomSeparator: showBottomSeparator!)
        navBar.delegate = self
        return navBar
    }
    
    func setUpBarItems(rightButtonAction:[ButtonAction] = [.hidden]) {
        if let child = self.children.last as? NavigationBar {
            child.updateRightButtonItems(rightButtonAction: rightButtonAction)
        }
    }
    
    @objc func navigationBar(_ navigationBar: NavigationBar,leftButtonTapped leftButton: UIButton) {
        switch navigationBar.leftAction {
        case .back, .backWhite,.back1:
            navigationController?.popViewController(animated: true)
        case .menu, .menuWhite:
          self.presentSideMenu()
        default:
            break
        }
    }
    @objc func navigationBar(_ navigationBar: NavigationBar,rightButtonTapped rightButton: UIButton) {
        switch navigationBar.rightAction[rightButton.tag] {
        case .back, .backWhite:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    func presentSideMenu() {
        self.presentLeftSideMenuWith(menuPresentMode: .menuSlideIn, menuWidth: self.view.frame.width, shadowColor: .gray)
    }
}


extension DIBaseController {
    // MARK: FirstNameValidation Functions.
    func checkFirstNameValidation(text:String) -> (String,UIButton) {
        if text.isEmpty {
            return (AppMessages.SignUp.enterFirstName, warningButton(tag: 0))
        }
        if text.count < Constant.MinimumLength.firstLastName {
            return (AppMessages.UserName.maxLengthFirstname, warningButton(tag: 0))
        }
        if text.count >= Constant.MinimumLength.firstLastName && text.count <= Constant.MaximumLength.firstName {
            return("", rightValidationButton())
        }
        return("", rightValidationButton())
    }
    
    // MARK: LastNameValidation Functions.
    func checkLastNameValidation(text:String) -> (String,UIButton) {
        if text.isEmpty {
            return (AppMessages.SignUp.enterLastName, warningButton(tag: 1))
        }
        if text.count < Constant.MinimumLength.firstLastName {
            return (AppMessages.UserName.maxLengthLastname, warningButton(tag: 1))
        }
        if text.count >= Constant.MinimumLength.firstLastName && text.count <= Constant.MaximumLength.lastName {
            return("", rightValidationButton())
        }
        return("", rightValidationButton())
    }
    
    // MARK: EmailFieldValidation Functions.
    func checkEmailValidation(text:String) -> (String,UIButton) {
        if !text.isEmpty {
            let output = Validation.shared.validate(values: (.email,(text)))
            switch output {
            case .failure( let message):
                return(message, warningButton(tag: 2))
            case .success:
                return("", rightValidationButton())
            }
        }
        return ("", UIButton())
    }
    
    // MARK: PhoneNumberFieldValidation Functions.
    func checkPhoneNumberValidation(text:String) -> (String,UIButton) {
        if !text.isEmpty {
            let output = Validation.shared.validate(values: (.phoneNo,(text)))
            switch output {
            case .failure( let message):
                return(message, warningButton(tag: 3))
            case .success:
                return("", rightValidationButton())
            }
        }
        return ("", UIButton())
    }
}
