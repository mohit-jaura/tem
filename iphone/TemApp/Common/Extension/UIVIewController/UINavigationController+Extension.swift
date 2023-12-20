//
//  UINavigationController+Extension.swift
//  ArchiveSmart
//
//  Created by shilpa on 22/10/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
extension UINavigationController {
    
    /// add bottom shadow to navigation bar
    
    func addBottomShadow(shadowRadius: CGFloat, lightShadowColor: CGColor?, darkShadowColor: CGColor?, shadowBackgroundColor: UIColor) {
//        self.navigationBar.backgroundColor = shadowBackgroundColor
        self.navigationBar.layer.masksToBounds = false
        let darkShadow = CALayer()
        darkShadow.frame = CGRect(x: self.navigationBar.frame.minX, y: self.navigationBar.frame.minY, width: self.navigationBar.frame.width, height: 1)
        darkShadow.backgroundColor = UIColor(r: 247/255, g: 247/255, b: 247/255, a: 1.0).cgColor
        darkShadow.shadowColor =  darkShadowColor
        darkShadow.shadowOffset = CGSize(width: 2, height: 2)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = shadowRadius
        self.navigationBar.layer.insertSublayer(darkShadow, at: 0)

        let lightShadow = CALayer()
        lightShadow.frame = CGRect(x: self.navigationBar.frame.minX, y: self.navigationBar.frame.minY, width: self.navigationBar.frame.width, height: 1)
        lightShadow.backgroundColor =  UIColor(r: 247/255, g: 247/255, b: 247/255, a: 1.0).cgColor
        lightShadow.shadowColor = lightShadowColor
        lightShadow.shadowOffset = CGSize(width: -2, height: -2)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = 1
        self.navigationBar.layer.insertSublayer(lightShadow, at: 0)
        self.navigationBar.layer.zPosition = 1
        
    }
    ///set transparent navigation bar
    func setTransparentNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barTintColor = .clear
        self.navigationBar.isTranslucent = true
        self.navigationBar.backgroundColor = UIColor.clear
    }
    
    ///set navigation bar to default
    func setDefaultNavigationBar() {
        self.navigationBar.backgroundColor = UIColor.white
        self.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationBar.shadowImage = nil
        self.navigationBar.barTintColor = .white
        //self.navigationBar.isTranslucent = false
    }
    
    ///check if the controller exists in stack
    func findController<T: UIViewController>(controller: T.Type) -> T? {
        for controller in self.viewControllers {
            if controller is T {
                let foundController = controller as! T
                return foundController
            }
        }
        return nil
    }
    
    func isTopController<T: UIViewController>(controller: T.Type) -> Bool {
        let controllersInStack = self.viewControllers
        if let topViewController = controllersInStack.last,
            topViewController is T {
            return true
        }
        return false
    }
    
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}
