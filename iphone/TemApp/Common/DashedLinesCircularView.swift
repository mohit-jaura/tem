//
//  DashedLinesCircularView.swift
//  TemApp
//
//  Created by Shilpa Vashisht on 25/06/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
struct GradientLocation {
    var startPoint: CGPoint
    var endPoint: CGPoint?
}
class GradientDashedLineCircularView: UIView {
    
    // MARK: Properties
    @IBInspectable var startColor: UIColor = .white { didSet { setNeedsLayout() } }
    @IBInspectable var endColor:   UIColor = .blue  { didSet { setNeedsLayout() } }
    @IBInspectable var lineWidth:  CGFloat = 3      { didSet { setNeedsLayout() } }
    
    private var colors: [UIColor]?
    
    //The width and height of the lines replica
    var instanceWidth: CGFloat = 3.0
    var instanceHeight: CGFloat = 10.0
    //store the last gradient locations in this array
    private var currentGradientLocations: [NSNumber] = []
    var lineColor: UIColor = UIColor.white
    var extraInstanceCount: Int = 0
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .conic
        //set start point to start from the top
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        
        //    gradientLayer.locations = [0.0, 0.25]
        return gradientLayer
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
}

extension GradientDashedLineCircularView: CAAnimationDelegate {
    
    //set the initial configuration properties of the gradient view
    func configureViewProperties(colors: [UIColor], gradientLocations: [NSNumber], startEndPint: GradientLocation? = nil) {
        self.colors = colors
        self.currentGradientLocations = gradientLocations
        self.gradientLayer.locations = gradientLocations
        if let startEnd = startEndPint {
            self.gradientLayer.startPoint = startEnd.startPoint
        } else {
            //end point to end on the top
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        }
    }
    
    func configure() {
        layer.addSublayer(gradientLayer)
    }
    
    func updateGradient() {
        
        
        //set gradient layer colors, this would be the array of colors
        gradientLayer.frame = bounds
        gradientLayer.colors = self.colors?.map({$0.cgColor})
        
        //create replicator layer
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame.size = self.frame.size
        replicatorLayer.masksToBounds = true
        //    replicatorLayer.instanceColor = UIColor.red.cgColor
        replicatorLayer.instanceColor = UIColor.green.cgColor
        
        
        //calculate the instance count
        let radius = self.frame.size.width/2
        let spacing: CGFloat = 2
        let circum = 2 * CGFloat.pi * radius
        let num = circum/(instanceWidth + spacing)
        let instanceCount = num
        replicatorLayer.instanceCount = Int(instanceCount) + extraInstanceCount
        replicatorLayer.instanceDelay = 1.0
        
        let layer = CALayer()
        let x = self.bounds.midX
        layer.frame = CGRect(x: x, y: 0, width: instanceWidth, height: instanceHeight)
        layer.backgroundColor = lineColor.cgColor
        replicatorLayer.addSublayer(layer)
        
        // Shift each instance by the width of the image
        /*replicatorLayer.instanceTransform = CATransform3DMakeTranslation(
         image!.size.width, 0, 0
         ) */
        let angle = Float.pi * 2 / Float(instanceCount)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
        
        //set replicator layer as mask of gradient layer
        gradientLayer.mask = replicatorLayer
        
    }
    
    //Handle gradient location
    //call this function to update the gradient colors to the new location.
    func updateGradientLocation(newLocations: [NSNumber], addAnimation: Bool = true) {
        let gradientAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        gradientAnimation.fromValue = self.currentGradientLocations
        gradientLayer.locations = newLocations
        currentGradientLocations = newLocations
        gradientAnimation.duration = 2.0
        gradientAnimation.repeatCount = 1//Float.infinity
        gradientAnimation.fillMode = .forwards
        if addAnimation {
            gradientLayer.add(gradientAnimation, forKey: nil)
        }
    }
}





// MARK: Square View


class GradientDashedLineSquareView: UIView {
    
    // MARK: Properties
    @IBInspectable var startColor: UIColor = .white { didSet { setNeedsLayout() } }
    @IBInspectable var endColor:   UIColor = .blue  { didSet { setNeedsLayout() } }
    @IBInspectable var lineWidth:  CGFloat = 3      { didSet { setNeedsLayout() } }
    
    private var colors: [UIColor]?
    
    //The width and height of the lines replica
    var instanceWidth: CGFloat = 3.0
    var instanceHeight: CGFloat = 10.0
    //store the last gradient locations in this array
    private var currentGradientLocations: [NSNumber] = []
    var lineColor: UIColor = UIColor.white
    var extraInstanceCount: Int = 0
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .conic
        //set start point to start from the top
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        
        //    gradientLayer.locations = [0.0, 0.25]
        return gradientLayer
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
}

extension GradientDashedLineSquareView: CAAnimationDelegate {
    
    //set the initial configuration properties of the gradient view
    func configureViewProperties(colors: [UIColor], gradientLocations: [NSNumber], startEndPint: GradientLocation? = nil) {
        self.colors = colors
        self.currentGradientLocations = gradientLocations
        self.gradientLayer.locations = gradientLocations
        if let startEnd = startEndPint {
            self.gradientLayer.startPoint = startEnd.startPoint
        } else {
            //end point to end on the top
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        }
    }
    
    func configure() {
        layer.addSublayer(gradientLayer)
    }
    
    func updateGradient() {
        
        
        //set gradient layer colors, this would be the array of colors
        gradientLayer.frame = bounds
        gradientLayer.colors = self.colors?.map({$0.cgColor})
        
        //create replicator layer
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame.size = self.frame.size
        replicatorLayer.masksToBounds = true
        //    replicatorLayer.instanceColor = UIColor.red.cgColor
        replicatorLayer.instanceColor = UIColor.green.cgColor
        
        
        //calculate the instance count
        let radius:CGFloat = 10
        let spacing: CGFloat = 2
        let circum = 2 * CGFloat.pi * radius
        let num = circum/(instanceWidth + spacing)
        let instanceCount = num
        replicatorLayer.instanceCount = Int(instanceCount) + extraInstanceCount
        replicatorLayer.instanceDelay = 1.0
        
        let layer = CALayer()
        let x = self.bounds.midX
        layer.frame = CGRect(x: x, y: 0, width: instanceWidth, height: instanceHeight)
        layer.backgroundColor = lineColor.cgColor
        replicatorLayer.addSublayer(layer)
        
        // Shift each instance by the width of the image
        /*replicatorLayer.instanceTransform = CATransform3DMakeTranslation(
         image!.size.width, 0, 0
         ) */
//        let angle = Float.pi * 2 / Float(instanceCount)
//        replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
        
        //set replicator layer as mask of gradient layer
        gradientLayer.mask = replicatorLayer
        
    }
    
    //Handle gradient location
    //call this function to update the gradient colors to the new location.
    func updateGradientLocation(newLocations: [NSNumber], addAnimation: Bool = true) {
        let gradientAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        gradientAnimation.fromValue = self.currentGradientLocations
        gradientLayer.locations = newLocations
        currentGradientLocations = newLocations
        gradientAnimation.duration = 1.5
        gradientAnimation.repeatCount = 1//Float.infinity
        gradientAnimation.fillMode = .forwards
        if addAnimation {
            gradientLayer.add(gradientAnimation, forKey: nil)
        }
    }
}

