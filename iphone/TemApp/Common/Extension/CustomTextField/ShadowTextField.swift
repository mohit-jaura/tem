//
//  ShadowTextField.swift
//  TemApp
//
//  Created by shivani on 09/08/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import SSNeumorphicView

extension UITextField{
        func addNeumorphicShadow(textField: SSNeumorphicTextField, shadowType: ShadowLayerType, cornerRadius: CGFloat, shadowRadius: CGFloat , opacity: Float, darkColor: CGColor, lightColor: CGColor, offset: CGSize){
            textField.txtDepthType = .innerShadow//shadowType
            textField.txtNeumorphicCornerRadius = 8//cornerRadius
            textField.txtNeumorphicShadowRadius = 0.5//shadowRadius
           textField.txtNeumorphicMainColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
            textField.txtNeumorphicDarkShadowColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) //darkColor
            textField.txtNeumorphicLightShadowColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) //lightColor
            textField.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
         
        }
}
//@IBDesignable class ShadowTextField: SSNeumorphicTextField {
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//       // setupView()
//        addNeumorphicShadow(textField: self, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 0.8, opacity:  0.3, darkColor:  #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5), lightColor: UIColor.black.cgColor, offset: CGSize(width: -2, height: -2))
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//
//    // MARK: - UI Setup
//    override func prepareForInterfaceBuilder() {
////        setupView()
//        addNeumorphicShadow(textField: self, shadowType: .innerShadow, cornerRadius: 8, shadowRadius: 0.8, opacity:  0.3, darkColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.09), lightColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35), offset: CGSize(width: -2, height: -2))
//    }
//
//    func addNeumorphicShadow(textField: SSNeumorphicTextField, shadowType: ShadowLayerType, cornerRadius: CGFloat, shadowRadius: CGFloat , opacity: Float, darkColor: CGColor, lightColor: CGColor, offset: CGSize){
//        textField.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
//        textField.txtDepthType = shadowType
//        textField.txtNeumorphicCornerRadius = cornerRadius
//        textField.txtNeumorphicShadowRadius = shadowRadius
//        textField.txtNeumorphicMainColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
//        textField.txtNeumorphicShadowOpacity = opacity
//        textField.txtNeumorphicDarkShadowColor =  darkColor
//        textField.txtNeumorphicShadowOffset = offset
//        textField.txtNeumorphicLightShadowColor = lightColor
//    }
//
////    func setupView() {
////        self.backgroundColor = color
////        self.layer.cornerRadius = cornerRadius
////        self.layer.shadowColor = shadowColor.cgColor
////        self.layer.shadowRadius = shadowRadius
////        self.layer.shadowOpacity = shadowOpacity
////        self.layer.borderWidth = borderWidth
////
////    }
//
////    // MARK: - Properties
////    @IBInspectable
////    var color: UIColor = .systemBlue {
////        didSet {
////            self.backgroundColor = color
////        }
////    }
////
////
////    @IBInspectable
////    var shadowColor: UIColor = .black {
////        didSet {
////            self.layer.shadowColor = shadowColor.cgColor
////        }
////    }
////
////
////
////    @IBInspectable
////    var shadowOpacity: Float = 0 {
////        didSet {
////            self.layer.shadowOpacity = shadowOpacity
////        }
////    }
////
//
//
//}
