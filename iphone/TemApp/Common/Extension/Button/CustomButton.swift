//
//  CustomButton.swift
//  VIZU
//
//  Created by dhiraj on 14/11/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    var row:Int = 0
    var section:Int = 0
    
    
   
}

extension UIButton {
    func leftImage(image: UIImage, renderMode: UIImage.RenderingMode) {
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .center
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func rightImage(image: UIImage, renderMode: UIImage.RenderingMode){
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left:image.size.width / 2, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .right
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        //    pulse.autoreverses = true
        pulse.repeatCount = 0
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: "pulse")
    }
}

@IBDesignable class ShadowButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addShadowOnButton()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadowOnButton()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if isGradient == true
        {
            gradientLayer.frame = self.bounds
            gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
            if isHorizontalGradient{
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            }
            self.layer.insertSublayer(gradientLayer, at: 0)
            //            self.layer.addSublayer(gradientLayer)
        }
        else{
            gradientLayer.removeFromSuperlayer()
        }
        self.setNeedsDisplay()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        addShadowOnButton()
    }
    
    func addShadowOnButton(){
       self.layer.cornerRadius = 10.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 3, height: 2)
        self.layer.shadowRadius = 5
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
    
    @IBInspectable public var isGradient : Bool = false{
       didSet{
           self.setNeedsDisplay()
       }
   }
   @IBInspectable public var isHorizontalGradient : Bool = true{
       didSet{
           self.setNeedsDisplay()
       }
   }
   @IBInspectable public var firstColor : UIColor = .black{
       didSet{
           self.setNeedsDisplay()
       }
   }
   @IBInspectable public var secondColor : UIColor = .blue{
       didSet{
           self.setNeedsDisplay()
       }
   }
   
   lazy  var gradientLayer: CAGradientLayer = {
       return CAGradientLayer()
   }()
   

   func setGradient(gradientColors firstColor:UIColor , secondColor:UIColor,thirdColor:UIColor){
       self.firstColor = firstColor
       self.secondColor = secondColor
      
       self.setNeedsLayout()
   }
}


class NewShadowButton:UIButton{
    
    @IBInspectable public var isGradient : Bool = false{
       didSet{
           self.setNeedsDisplay()
       }
   }
   @IBInspectable public var isHorizontalGradient : Bool = true{
       didSet{
           self.setNeedsDisplay()
       }
   }
   @IBInspectable public var firstColor : UIColor = .black{
       didSet{
           self.setNeedsDisplay()
       }
   }
   @IBInspectable public var secondColor : UIColor = .blue{
       didSet{
           self.setNeedsDisplay()
       }
   }
  
   lazy  var gradientLayer: CAGradientLayer = {
       return CAGradientLayer()
   }()
   

   func set(gradientColors firstColor:UIColor , secondColor:UIColor){
       self.firstColor = firstColor
       self.secondColor = secondColor
      
       self.setNeedsLayout()
   }
   
   
   @IBInspectable public var imageColor: UIColor = .clear {
       didSet {
           
           if imageColor != .clear {
               
               if  let image = self.image(for: UIControl.State()) {
                   let tmImage  = image.withRenderingMode(.alwaysTemplate)
                   self.setImage(tmImage, for: UIControl.State())
                   self.tintColor = imageColor
                   
               }else if let image = self.backgroundImage(for: UIControl.State()) {
                   let tmImage  = image.withRenderingMode(.alwaysTemplate)
                   self.setBackgroundImage(tmImage, for: UIControl.State())
                   self.tintColor = imageColor
               }
           }
           
       }
   }
   
   
   @IBInspectable public var isShadow: Bool = false
    @IBInspectable public var cornerRadius1: CGFloat = 10.5 {
       didSet {
           
           layer.cornerRadius = 10.5
           
       }
   }
   @IBInspectable public var shadowColor: UIColor = UIColor.black {
       didSet {
           
           layer.shadowColor = shadowColor.cgColor
       }
   }
   
   @IBInspectable public var shadowOpacity: Float = 0.5 {
       didSet {
           layer.shadowOpacity = shadowOpacity
       }
   }
   
   @IBInspectable public var shadowOffset: CGSize = CGSize(width: 0, height: 3) {
       didSet {
           layer.shadowOffset = shadowOffset
       }
   }
   @IBInspectable public var shadowRadius1 : CGFloat = 3
       {
       didSet
       {
           layer.shadowRadius = shadowRadius
       }
   }
   
   
   @IBInspectable public var borderWidth1: CGFloat =  0 {
       didSet {
           layer.borderWidth = borderWidth
           //mkLayer.setMaskLayerCornerRadius(cornerRadius)
       }
   }
   @IBInspectable public var masksToBounds : Bool = false
       {
       didSet
       {
           layer.masksToBounds = masksToBounds
       }
   }
   
   @IBInspectable public var clipsToBound : Bool = false
       {
       didSet
       {
           self.clipsToBounds = clipsToBound
       }
   }
   
   
   
   // MARK - initilization
   override public init(frame: CGRect) {
       super.init(frame: frame)
       setupLayer()
   }
   
   required public init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       setupLayer()
   }
   
   // MARK - setup methods
   private func setupLayer() {
       adjustsImageWhenHighlighted = false
       
   }
   
   
   override open func layoutSubviews() {
       super.layoutSubviews()
       if isShadow == true
       {
           let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
           layer.masksToBounds = masksToBounds
           layer.shadowColor = shadowColor.cgColor
           layer.shadowOffset = shadowOffset
           layer.shadowOpacity = shadowOpacity
           layer.shadowPath = shadowPath.cgPath
       }
       if isGradient == true
       {
           gradientLayer.frame = self.bounds
           gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
           if isHorizontalGradient{
               gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
               gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
           }
           self.layer.insertSublayer(gradientLayer, at: 0)
           //            self.layer.addSublayer(gradientLayer)
       }
       else{
           gradientLayer.removeFromSuperlayer()
       }
       self.setNeedsDisplay()
   }
   
   
}
final class CustomShadowButton: UIButton {

    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.backgroundColor =  UIColor(r: 0, g: 38, b: 64).cgColor
        //UIColor.white.cgColor
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(r: 0, g: 19, b: 27).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOpacity = 0.35
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
        }
    }


