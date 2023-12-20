//
//  BezierView.swift
//  TemApp
//
//  Created by shilpa on 12/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import BezierPathLength

class BezierView: UIView {
    
    var hasExceededTheMaxPercent = false
    
    let backgroundStrokeColor = UIColor(red: 197/255, green: 233/255, blue: 255/255, alpha: 1.0)
    var progressBarFillColor: UIColor {
        get {
            if hasExceededTheMaxPercent {
                return appThemeColor
            }
            if endStrokeValue > 0.0 && endStrokeValue <= 0.50 {
                return UIColor(0xFF6961) // red
            }
            if endStrokeValue > 0.50 && endStrokeValue <= 0.90 {
                return UIColor(0xF5DE50) //yellow
            }
            if endStrokeValue > 0.90 && endStrokeValue <= 0.99 {
                return UIColor(0x50C878) // green
            }
            if endStrokeValue >  0.99 {
                return appThemeColor
            }
            return appThemeColor
        }
    }
    
    var bezierPath: UIBezierPath? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var focusPercent: CGFloat? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var progressLayer = CAShapeLayer()
    var gradientLayer = CAGradientLayer()
    var endStrokeValue:CGFloat = 0.0 {
        didSet {
            self.updateGradientColors()
        }
    }
    
    var lineWidth: CGFloat = 6.0 // line width of CAShapeLayer
    var focusSize: CGFloat = 12.0
    
    override func draw(_ rect: CGRect) {
        
        guard let path = bezierPath else {
            return
        }
        
        path.lineWidth = self.lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        self.backgroundStrokeColor.setStroke()
        
        path.stroke()
        
        if let focusPercent = focusPercent {
            
            if let p = path.point(at: focusPercent) {
                
                //let focusSize: CGFloat = 12.0
                
                let ovalRect = CGRect(x: p.x - focusSize/2.0, y: p.y - focusSize/2.0, width: focusSize, height: focusSize)
                let focusPointPath = UIBezierPath(ovalIn: ovalRect)
                self.progressBarFillColor.setFill()
                focusPointPath.fill()
                
            }
            
        }
    }
    
    func setProgress(endValue:CGFloat) {
        self.endStrokeValue = endValue
        self.layoutIfNeeded()
        //setBackgroundCircle()
        self.transform = self.transform.rotated(by: CGFloat(Double.pi))
        //add gradient to the below
        self.addShapeLayer(strokeStart:0.0,endValue: endValue)
        self.addGradient()
        self.addAnimation(fromValue: 0.0,endValue: CGFloat(self.endStrokeValue))
        self.focusPercent = endValue
    }
    
    
    /// Add a new layer over the beizer path of circle. Layer fills the circle.
    ///
    /// - Parameter endValue: value upto which circle is to be filled
    func addShapeLayer(strokeStart:CGFloat,endValue:CGFloat) {
        progressLayer = CAShapeLayer()
        progressLayer.path = self.bezierPath?.cgPath
        progressLayer.strokeColor = self.backgroundStrokeColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = self.lineWidth
        progressLayer.strokeStart = strokeStart
        progressLayer.strokeEnd = endValue
    }
    
    
    /// Add gradient to the layer of circle
    func addGradient() {
//        let gradient: CAGradientLayer = CAGradientLayer()
        self.updateGradientColors()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.mask = progressLayer //uses the shape layer as mask
        progressLayer.frame = gradientLayer.bounds
        self.layer.addSublayer(gradientLayer)
    }
    
    func updateGradientColors() {
        let startingColorOfGradient = self.progressBarFillColor.cgColor
        let endingColorOFGradient = self.progressBarFillColor.cgColor
        gradientLayer.colors = [startingColorOfGradient , endingColorOFGradient]
    }
    
    /// Add animation to the fill circle layer
    func addAnimation(fromValue:CGFloat,endValue : CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = endValue
        CATransaction.commit()
    }
    
    func updateView(lastValue: CGFloat, newValue: CGFloat) {
        self.focusPercent = newValue
        endStrokeValue = newValue
        if newValue > 0.0 && lastValue != newValue {
            addAnimation(fromValue:lastValue,endValue : endStrokeValue)
        }
    }
}

