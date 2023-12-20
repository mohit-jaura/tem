//  CircleView.swift

import Foundation
import UIKit


class CircleView:UIView {
    var progressCircle = CAShapeLayer()
    var thumbLayer = CAShapeLayer()
    var startThumbLayer = CAShapeLayer()
    var circlePath:UIBezierPath?
    var thumbImageView = UIImageView()
    var startThumbImageView = UIImageView()
    
    var endStrokeValue:Float = 0.0
    
    //change these to customize the appearance
    var backgroundStrokeColor = UIColor.init(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
    var lineWidth: CGFloat = 6.0
    
    /// Set the progress of a circle view
    ///
    /// - Parameter endValue: Value upto which circle is to be filled
    func setCircleProgress(endValue:CGFloat) {
        self.endStrokeValue = Float(endValue)
        self.layoutIfNeeded()
        circlePath = self.getCircleBeizerPath()
        setBackgroundCircle()
        //add gradient to the below
        self.addShapeLayer(strokeStart:0.0,endValue: endValue)
        self.addGradient()
        self.addAnimation(fromValue: 0.0,endValue: CGFloat(self.endStrokeValue))
        self.addImage()
    }
    
    
    /// Add a new layer over the beizer path of circle. Layer fills the circle.
    ///
    /// - Parameter endValue: value upto which circle is to be filled
    func addShapeLayer(strokeStart:CGFloat,endValue:CGFloat) {
        progressCircle = CAShapeLayer()
        progressCircle.path = circlePath?.cgPath
        progressCircle.strokeColor = UIColor.red.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = 6.0
        progressCircle.strokeStart = strokeStart
        progressCircle.strokeEnd = endValue
    }
    
    
    /// Add gradient to the layer of circle
    func addGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        let startingColorOfGradient = #colorLiteral(red: 0.1650000066, green: 0.6980000138, blue: 1, alpha: 1).cgColor
        let endingColorOFGradient = #colorLiteral(red: 0.1650000066, green: 0.6980000138, blue: 1, alpha: 1).cgColor
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.colors = [startingColorOfGradient , endingColorOFGradient]
        gradient.mask = progressCircle //uses the shape layer as mask
        progressCircle.frame = gradient.bounds
        self.layer.addSublayer(gradient)
    }
    
    
    /// Add animation to the fill circle layer
    func addAnimation(fromValue:CGFloat,endValue : CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        //animation.delegate = self
        animation.duration = 1.5
        animation.fromValue = fromValue
        animation.toValue = endValue // changed here
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.isRemovedOnCompletion = false
        progressCircle.add(animation, forKey: "ani")
    }
    
    
    /// Create a backgroud gray color layer. It will have same beizerpath a circle
    func setBackgroundCircle() {
        let bgCircle = CAShapeLayer ()
        bgCircle.path = circlePath?.cgPath
        bgCircle.strokeColor = self.backgroundStrokeColor.cgColor//UIColor.init(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0).cgColor
        bgCircle.fillColor = UIColor.clear.cgColor
        bgCircle.lineWidth = self.lineWidth//6.0
        bgCircle.strokeStart = 0
        bgCircle.strokeEnd = 1.0
        self.layer.addSublayer(bgCircle)
    }
    
    
    /// Create a beizer path for circle with the view conrdinates
    ///
    /// - Returns: Beizerpath drawn as a circle
    func getCircleBeizerPath() -> UIBezierPath {
        let centerPoint = CGPoint (x: self.bounds.width / 2, y: self.bounds.width / 2)
        let circleRadius : CGFloat = self.bounds.width / 2 * 0.83
        let beizerPath = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        return beizerPath
    }
    
    //Add an image
    
    
    //Add an image head to the circle fill layer. Move it along the fill circle layer animation
    func addImage() {
        let centerPoint = CGPoint (x: self.bounds.width / 2, y: self.bounds.width / 2)
        let circleRadius : CGFloat = self.bounds.width / 2 * 0.83
        let startAngle: CGFloat = CGFloat(-Double.pi / 2)
        var endAngle: CGFloat = CGFloat(-Double.pi / 2) + CGFloat(min(1.0, endStrokeValue) * .pi * 2)
        if endStrokeValue <= 0 {
            endAngle = (startAngle)
        }
        let bpath = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise:true)
        if lineWidth <= 4.0 {
            //for smaller line width, set the smaller image
            thumbImageView.image = UIImage(named: "arrowupSmall")
            startThumbImageView.image = UIImage(named: "arrow-bfillSmall")
        } else {
            thumbImageView.image = #imageLiteral(resourceName: "arrowup")
            startThumbImageView.image = #imageLiteral(resourceName: "arrow-bfill")
        }
        startThumbLayer.contents = startThumbImageView.image?.cgImage
        thumbLayer.contents = thumbImageView.image?.cgImage
        //thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if endStrokeValue <= 0 {
            thumbLayer.frame = CGRect(x: self.bounds.width/2 - ((thumbImageView.image?.size.width)!/2), y: 3, width: thumbImageView.image!.size.width, height: thumbImageView.image!.size.height)
        } else {
            thumbLayer.frame = CGRect(x: 0.0, y: 3, width: thumbImageView.image!.size.width, height: thumbImageView.image!.size.height)
        }
        thumbLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi)))
        thumbLayer.fillColor = UIColor.clear.cgColor
        thumbLayer.strokeEnd = CGFloat(2)
        
        startThumbLayer.frame = CGRect(x: self.bounds.width/2 - ((startThumbImageView.image?.size.width)!/2), y: 3, width: startThumbImageView.image!.size.width, height: startThumbImageView.image!.size.height)
        
        startThumbLayer.strokeEnd = CGFloat(0)
        self.layer.addSublayer(startThumbLayer)
        self.layer.addSublayer(thumbLayer)
        
        if endStrokeValue > 0 {
            updateframeAnimtion(bPath:bpath)
        }
    }
    
    func updateframeAnimtion(bPath:UIBezierPath){
        let pathAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        pathAnimation.duration = 1.5
        if endStrokeValue <= 0.0 {
            pathAnimation.duration = 0
        }
        pathAnimation.path = bPath.cgPath
        pathAnimation.repeatCount = 0
        pathAnimation.calculationMode = CAAnimationCalculationMode.paced
        pathAnimation.rotationMode = CAAnimationRotationMode.rotateAuto
        pathAnimation.fillMode = CAMediaTimingFillMode.forwards
        pathAnimation.isRemovedOnCompletion = false
        thumbLayer.add(pathAnimation, forKey: "movingMeterTip")
    }
    
    
    
    func updateView(lastValue:CGFloat,newValue:CGFloat){
        let centerPoint = CGPoint (x: self.bounds.width / 2, y: self.bounds.width / 2)
        let circleRadius : CGFloat = self.bounds.width / 2 * 0.83
        var startAngle : CGFloat = 0.0
        var endAngle : CGFloat = 0.0
        var bpath : UIBezierPath?
        if lastValue < newValue {
            startAngle = CGFloat(-Double.pi / 2) + CGFloat(min(1.0, lastValue) * .pi * 2)
            endAngle = CGFloat(-Double.pi / 2) + CGFloat(min(1.0, newValue) * .pi * 2)
            bpath = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise:true)
        } else if lastValue > newValue {
            startAngle = CGFloat(-Double.pi / 2) + CGFloat(min(1.0, lastValue) * .pi * 2)
            endAngle = CGFloat(-Double.pi / 2) + CGFloat(min(1.0, newValue) * .pi * 2)
            bpath = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise:false)
        }
        endStrokeValue = Float(newValue)
        if newValue > 0.0 && lastValue != newValue {
            progressCircle.strokeEnd = newValue
            addAnimation(fromValue:lastValue,endValue : newValue)
            
            updateframeAnimtion(bPath:bpath!)
        }
    }
    
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
}


