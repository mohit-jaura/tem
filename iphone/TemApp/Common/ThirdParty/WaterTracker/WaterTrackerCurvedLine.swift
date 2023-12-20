//
//  WaterTrackerCurvedLine.swift
//  TemApp
//
//  Created by Mohit Soni on 28/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

enum WaterTrackerDirection: Int {
    case left, right
}

class WaterTrackerCurvedLineView: UIView {
    
    public var currentLayoutDirection: WaterTrackerDirection = .left {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var nextLayoutDirection: WaterTrackerDirection = .left
    private var shapeLayer: CAShapeLayer!
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        shapeLayer = self.layer as? CAShapeLayer
        shapeLayer.strokeColor = UIColor.appThemeColor.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineDashPattern = [1, 0]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawCurve()
    }
    
    private func drawQuadCurve() {
        let y: CGFloat = bounds.size.height
        let x: CGFloat = bounds.size.width
        var ptC: CGPoint = CGPoint(x: 0.0, y: bounds.midY)
        ptC.x = currentLayoutDirection == .right ? bounds.maxX - (frame.width/2) : frame.width/2
        let bez = UIBezierPath()
        bez.addLine(to: CGPoint(x: ptC.x, y: bounds.minY))
        if currentLayoutDirection == .right {
            bez.move(to: CGPoint(x: bounds.maxX - 20 , y: bounds.minY))
            bez.addQuadCurve(to: CGPoint(x: bounds.minX + 19 , y: bounds.maxY), controlPoint: CGPoint(x: x * 1.6 , y: y / 1.4))
        } else {
            bez.move(to: CGPoint(x: bounds.minX + 20, y: bounds.minY))
            bez.addQuadCurve(to: CGPoint(x: bounds.maxX - 19, y: bounds.maxY), controlPoint: CGPoint(x: -(x / 1.7), y: y / 1.4))
        }
        shapeLayer.path = bez.cgPath
    }
    private func drawCurve() {
        let y: CGFloat = bounds.size.height
        let x: CGFloat = bounds.size.width
        var ptC: CGPoint = CGPoint(x: 0.0, y: bounds.midY)
        var endPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
        var controlPoint2: CGPoint = CGPoint(x: 0.0, y: 0.0)
        var controlPoint1: CGPoint = CGPoint(x: 0.0, y: 0.0)
        if nextLayoutDirection == .right {
            endPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
            controlPoint2 = CGPoint(x: -3, y: (y / 2) - 5)
            controlPoint1 = CGPoint(x: -(x / 3), y: y / 1.5)
        } else {
            endPoint = CGPoint(x: bounds.minX, y: bounds.maxY)
            controlPoint2 = CGPoint(x: 50, y: (y / 2) - 5)
            controlPoint1 = CGPoint(x: -(x / 2), y: y / 1.5)
        }
        ptC.x = currentLayoutDirection == .right ? bounds.maxX - (frame.width/2) : frame.width/2
        let bez = UIBezierPath()
        bez.addLine(to: CGPoint(x: ptC.x, y: bounds.minY))
        if currentLayoutDirection == .right {
            bez.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            bez.addCurve(to: endPoint, controlPoint1: CGPoint(x: x * 1.6 , y: y / 1.5), controlPoint2: CGPoint(x: 3, y: (y / 2) - 5))
        } else {
            bez.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            bez.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        shapeLayer.path = bez.cgPath
    }
}
