//
//  UIButton+Extensions.swift
//  YPImagePicker
//
//  Created by Nik Kov on 26.04.2018.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

internal extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        setBackgroundImage(imageWithColor(color), for: forState)
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
extension UIButton{
    func addDoubleShadowToButton(cornerRadius: CGFloat?, shadowRadius: CGFloat?, lightShadowColor: CGColor?, darkShadowColor: CGColor?, shadowBackgroundColor: UIColor) {
        self.backgroundColor = shadowBackgroundColor
        self.layer.masksToBounds = false
                self.layer.cornerRadius = self.frame.height/2
        let darkShadow = CALayer()
        darkShadow.frame = bounds
        darkShadow.backgroundColor = backgroundColor?.cgColor
        darkShadow.shadowColor =  darkShadowColor
        darkShadow.cornerRadius = self.frame.height/2
        darkShadow.shadowOffset = CGSize(width: 2, height: 2)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = 1
        self.layer.insertSublayer(darkShadow, at: 0)

        let lightShadow = CALayer()
        lightShadow.frame = bounds
        lightShadow.backgroundColor = backgroundColor?.cgColor
        lightShadow.shadowColor = lightShadowColor
        lightShadow.cornerRadius = self.frame.height/2
        lightShadow.shadowOffset = CGSize(width: -2, height: -2)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = 1
        self.layer.insertSublayer(lightShadow, at: 0)
        
        if let imageView = self.imageView {
            self.bringSubviewToFront(imageView)
        }
    }
}

extension UIView{
    func addDoubleShadowToView(cornerRadius: CGFloat?, shadowRadius: CGFloat?, lightShadowColor: CGColor?, darkShadowColor: CGColor?, shadowBackgroundColor: UIColor) {
        self.layer.masksToBounds = false
                self.layer.cornerRadius = self.frame.height/2
        let darkShadow = CALayer()
        darkShadow.frame = bounds
        darkShadow.backgroundColor = backgroundColor?.cgColor
        darkShadow.shadowColor =  darkShadowColor
        darkShadow.cornerRadius = self.frame.height/2
        darkShadow.shadowOffset = CGSize(width: 2, height: 2)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = 1
        self.layer.insertSublayer(darkShadow, at: 0)

        let lightShadow = CALayer()
        lightShadow.frame = bounds
        lightShadow.backgroundColor = backgroundColor?.cgColor
        lightShadow.shadowColor = lightShadowColor
        lightShadow.cornerRadius = self.frame.height/2
        lightShadow.shadowOffset = CGSize(width: -2, height: -2)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = 1
        self.layer.insertSublayer(lightShadow, at: 0)
        
       
    }
}

extension SSNeumorphicView{
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false, mainColor: CGColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1).cgColor){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = mainColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
    }
    func setToggleShadow(view:SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1)
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.height / 2
    }
}
