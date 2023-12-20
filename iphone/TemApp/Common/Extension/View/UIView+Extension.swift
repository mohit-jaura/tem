//
//  UIView+Extension.swift
//  BaseProject
//
//  Created by Aj Mehra on 09/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
class CustomLabel: UILabel {
    var row:Int = 0
    var section:Int = 0
}

class CustomImageView: UIImageView {
    var row:Int = 0
    var section:Int = 0
}

class CircularImgView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}

protocol ViewTaggable where Self: UIView {
    var row: Int { get set }
    var section: Int { get set }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowColor = shadowRadius > 0 ? UIColor.black.cgColor : nil//UIColor.black.cgColor
            layer.shadowOffset = shadowRadius > 0 ? CGSize(width: 0, height: 2) : CGSize.zero
            layer.shadowOpacity = shadowRadius > 0 ? 0.5 : 0.0//0.4
            layer.shadowRadius = shadowRadius
        }
    }
    
    
    func scale(scaleX: CGFloat, scaleY: CGFloat, completion: @escaping (_ finished: Bool) -> Void) {
        
        UIView.animate(withDuration: 0.35, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
        }, completion: { finished in
            
            completion(finished)
            
        })
        
    }
    
    func addShadow(radius: CGFloat? = 5.0, offset: CGSize? = CGSize.zero, color: UIColor? = UIColor.lightGray, opacity: Float? = 1) {
        self.layer.shadowColor = color!.cgColor
        self.layer.shadowOpacity = opacity!
        self.layer.shadowOffset = offset!
        self.layer.shadowRadius = radius!
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    func addDropShadowToView(opacity: Float? = 0.2) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = opacity!
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10.0).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shadowRadius = 1.0
        self.layer.masksToBounds = false
    }
    
    /// returns the screenshot of the caller view
    ///
    /// - Returns: returns the image of the view taken as screenshot
    func screenshot() -> UIImage? {
        // Begin context
        /*UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        print("could not create screenshot")
        return nil */
        
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
        

        
        /*let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return image */
        
       /* let renderer = UIGraphicsImageRenderer(size: (self.bounds.size) )
        let image = renderer.image { ctx in
            self.drawHierarchy(in: (self.bounds) , afterScreenUpdates: true)
        }
        let imageData = image.jpegData(compressionQuality: 0.7)//UIImageJPEGRepresentation(image, 0.75) ?? Data()
        let mapImage = UIImage(data: imageData ?? Data())
        return mapImage */
    }
}

extension UIView {

    //This Function will return identifier.......
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    //Load from nib
    class func loadNib<T: UIView>() -> T? {
        guard let nibs = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil), let nib = nibs.first else {
            return nil
        }
        return nib as? T
    }
    
    /// this function will add the ripple effect to the caller view
    ///
    /// - Parameters:
    ///   - bezierPath: the bezier path for the ripple layer
    ///   - repeatCount: number of times for which the animation is to be repeated, defaults to infinity
    ///   - strokeColor: the color of the ripple layer
    func addRippleEffect(bezierPath: UIBezierPath, repeatCount: Float? = Float.infinity, strokeColor: UIColor) {
        //let path = UIBezierPath(frame: self.bounds, sides: 6, cornerRadius: 0.0)
        
        /*! Position where the shape layer should be */
        let shapePosition = CGPoint(x: self.bounds.size.width / 2.0 + 14, y: self.bounds.size.height / 2.0)
        let rippleShape = CAShapeLayer()
        rippleShape.frame = self.bounds
        rippleShape.path = bezierPath.cgPath
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = strokeColor.cgColor
        rippleShape.lineWidth = 15
        rippleShape.position = shapePosition
        rippleShape.opacity = 0
        
        /*! Add the ripple layer as the sublayer of the reference view */
        self.layer.addSublayer(rippleShape)
        /*! Create scale animation of the ripples */
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1))
        /*! Create animation for opacity of the ripples */
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = nil
        /*! Group the opacity and scale animations */
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = CFTimeInterval(0.9)
        animation.repeatCount = repeatCount!
        animation.isRemovedOnCompletion = false
        rippleShape.add(animation, forKey: "rippleEffect")
    }
    
    
    func showView(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func hideView(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.alpha = 0.0
            self.isHidden = true
        }) { (completed) in
            completion(true)
        }
    }
    
    func normalizedPosition(for point: CGPoint, inFrame frame: CGRect) -> CGPoint {
        var point = point
        point.x -= frame.origin.x - self.frame.origin.x
        point.y -= frame.origin.y - self.frame.origin.y
        
        let normalizedPoint = CGPoint(x: point.x / frame.size.width, y: point.y / frame.size.height)
        
        return normalizedPoint
    }
}

extension UIView {
    ///apply gradient on view
    func applyGradient(inDirection direction: DirectionGradient, colors: [Any], locations: [NSNumber]? = [0.0, 0.4]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = direction.draw().startPoint
        gradientLayer.endPoint = direction.draw().endPoint
        gradientLayer.locations = locations//0.0, 0.4, 0.6, 1.0
        gradientLayer.colors = colors//[UIColor.appThemeColor.cgColor, UIColor.themeLightColor.cgColor]
        if let view = self as? UIButton {
            self.layer.insertSublayer(gradientLayer, below: view.titleLabel?.layer)
        } else {
            self.layer.addSublayer(gradientLayer)
        }
    }
    
    func startLayerAnimation() {
        let layer = CAGradientLayer()
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
        pulseAnimation.fromValue = backgroundColor
        pulseAnimation.toValue = UIColor.red//UIColor(cgColor: backgroundColor!).complementaryColor.cgColor
        pulseAnimation.duration = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        self.layer.add(pulseAnimation, forKey: "skeleton")
        //self.layer.insertSublayer(<#T##layer: CALayer##CALayer#>, at: <#T##UInt32#>)
    }
    
    func addTriangularView(){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0)) // 2
        path.addLine(to: CGPoint(x: self.frame.width / 2, y: 100))//3
        path.addLine(to: CGPoint(x: 0, y: 0)) //1
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = #colorLiteral(red: 0.2445561886, green: 0.5110852718, blue: 0.8627218604, alpha: 1)
        self.layer.addSublayer(shapeLayer)
        
        
        
        
        // -- For shadow on triangular view
 /*
        let innerShadowLayer = CALayer()
            innerShadowLayer.frame = shapeLayer.bounds
            let path2 = UIBezierPath(rect: innerShadowLayer.bounds.insetBy(dx: -20, dy: -20))
            let innerPart = UIBezierPath(rect: innerShadowLayer.bounds).reversing()
            path.append(innerPart)
            innerShadowLayer.shadowPath = path2.cgPath
            innerShadowLayer.masksToBounds = true
            innerShadowLayer.shadowColor = UIColor.red.cgColor
            innerShadowLayer.shadowOffset = CGSize.zero
            innerShadowLayer.shadowOpacity = 1
            innerShadowLayer.shadowRadius = 5
        triangularView.layer.addSublayer(innerShadowLayer)*/
    }
    
    func addShadowView(maxHeight: CGFloat) {
        //left single line
        let lineSize: CGFloat = 1.5
        let radius: CGFloat = 7
        let offset = CGSize(width:0, height:-6)
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: 0, y: 0))
        path1.addLine(to: CGPoint(x: self.frame.width/2, y: maxHeight))
        path1.addLine(to: CGPoint(x: 0, y: 0))
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.path = path1.cgPath
        shapeLayer1.strokeColor = #colorLiteral(red: 0.2445561886, green: 0.5110852718, blue: 0.8627218604, alpha: 1) //UIColor.red.cgColor
        shapeLayer1.lineWidth = lineSize
        shapeLayer1.lineJoin = .miter
        shapeLayer1.lineCap = .butt
        
        shapeLayer1.shadowColor = UIColor.white.cgColor
        shapeLayer1.shadowOffset = offset
        shapeLayer1.shadowRadius = radius
        shapeLayer1.shadowOpacity = 1.0 
        
        self.layer.addSublayer(shapeLayer1)
        
        //right single line
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: self.frame.width, y: 0))
        path2.addLine(to: CGPoint(x: self.frame.width/2, y: maxHeight))
        path2.addLine(to: CGPoint(x: self.frame.width, y: 0))
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.path = path2.cgPath
        shapeLayer2.strokeColor = #colorLiteral(red: 0.2445561886, green: 0.5110852718, blue: 0.8627218604, alpha: 1) //UIColor.red.cgColor
        shapeLayer2.lineWidth = lineSize
        
        shapeLayer2.shadowColor = UIColor.white.cgColor
        shapeLayer2.shadowOffset = offset
        shapeLayer2.shadowRadius = radius
        shapeLayer2.shadowOpacity = 1.0 
        
        self.layer.addSublayer(shapeLayer2)

    }
    
}


typealias Location = (startPoint: CGPoint, endPoint: CGPoint)

enum DirectionGradient {
    case leftToRight
    case topBottom
    
    func draw() -> Location {
        switch self {
        case .leftToRight:
            return (startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: (CGPoint(x: 1.0, y: 0.5)))
        default:
            return (startPoint: CGPoint(x: 0.5, y: 0.0), endPoint: (CGPoint(x: 0.5, y: 1.0)))
        }
    }
}

/* public extension UIView {
 
 @IBInspectable
 var isSkeletonable: Bool {
 get { return skeletonable }
 set { skeletonable = newValue }
 }
 
 var isSkeletonActive: Bool {
 return status == .on || (subviewsSkeletonables.first(where: { $0.isSkeletonActive }) != nil)
 }
 
 private var skeletonable: Bool! {
 get { return ao_get(pkey: &ViewAssociatedKeys.skeletonable) as? Bool ?? false }
 set { ao_set(newValue, pkey: &ViewAssociatedKeys.skeletonable) }
 }
 } */

protocol ViewLayoutConfigurable {
    /// Adds the shadow on top-left and bottom right of view
    /// - Parameters:
    ///   - cornerRadius: corner radius of view
    ///   - shadowRadius: shadow radius, defaults to 5
    ///   - lightShadowColor: top-left shadow color
    ///   - darkShadowColor: bottom-right shadow color
    ///   - shadowBackgroundColor: shadow background color
    func addDoubleShadow(cornerRadius: CGFloat?, shadowRadius: CGFloat?, lightShadowColor: CGColor?, darkShadowColor: CGColor?, shadowBackgroundColor: CGColor)
}

extension ViewLayoutConfigurable where Self: UIView {
    func addDoubleShadow(cornerRadius: CGFloat?, shadowRadius: CGFloat?, lightShadowColor: CGColor?, darkShadowColor: CGColor?, shadowBackgroundColor: CGColor) {
        self.layer.cornerRadius = cornerRadius ?? 0
        self.layer.masksToBounds = false

        let cornerRadius: CGFloat = cornerRadius ?? 0
        let shadowRadius: CGFloat = shadowRadius ?? 5.0
        

       
        
        let darkShadow = CALayer()
        darkShadow.frame = self.bounds
        darkShadow.backgroundColor = shadowBackgroundColor
        darkShadow.shadowColor = darkShadowColor
        darkShadow.cornerRadius = cornerRadius
        darkShadow.shadowOffset = CGSize(width: shadowRadius, height: shadowRadius)
        darkShadow.shadowOpacity = 0.7
        darkShadow.shadowRadius = shadowRadius
        
        
        darkShadow.name = "darkShadowLayer"
        let sublayers: [CALayer]? = self.layer.sublayers
        if let layeers = sublayers{
            for layer in  layeers{
                if layer.name == "darkShadowLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        self.layer.insertSublayer(darkShadow, at: 0)

        let lightShadow = CALayer()
        lightShadow.frame = self.bounds
        lightShadow.backgroundColor = shadowBackgroundColor
        lightShadow.shadowColor = lightShadowColor
        lightShadow.cornerRadius = cornerRadius
        lightShadow.shadowOffset = CGSize(width: -shadowRadius, height: -shadowRadius)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = shadowRadius
        
        lightShadow.name = "lightShadowLayer"
        let lightShadowSublayers: [CALayer]? = self.layer.sublayers
        if let layeers = lightShadowSublayers{
            for layer in  layeers{
                if layer.name == "lightShadowLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        self.layer.insertSublayer(lightShadow, at: 0)
    }
}

extension UIView: ViewLayoutConfigurable {}

extension UILabel {
    func addShadowToText(color: UIColor, radius: CGFloat, opacity: Float, offset: CGSize) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.masksToBounds = false
    }
}
extension UISearchBar {
    func setUI(_ color:UIColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1) ,_ cornerRadius:CGFloat = 10) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
       // isTranslucent = true
       // setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        textFieldInsideSearchBar?.backgroundColor = color
        textFieldInsideSearchBar?.layer.cornerRadius = cornerRadius
}
}
extension Bundle {
    var isProduction: Bool {
        #if DEBUG
            return false
        #else
            guard let path = self.appStoreReceiptURL?.path else {
                return true
            }
            return !path.contains("sandboxReceipt")
        #endif
    }
}

extension UIViewController {
    var vcName: String {
        NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
}


extension UIView{
    func addShadowToView() { // will show the view like a status bar line by adding shadow on it
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0 , height:2)
    }
}

class CustomView: UIView {
    func addGradient(color:UIColor){
        let path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: 5, dy: 5), byRoundingCorners: [.topLeft, .bottomLeft, .topRight, .bottomRight], cornerRadii: CGSize(width:frame.size.height / 2, height: frame.size.height / 2))

        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: frame.size)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [color.cgColor, UIColor.darkGray.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path = path.cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        layer.insertSublayer(gradient, at: 0)
    }

}
