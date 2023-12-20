//
//  ProgresViewXib.swift
//  TemApp
//
//  Created by Harpreet_kaur on 30/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//
//self.innerImageView.layer.addSublayer(self.setBackgroundCircle(path: innerViewPath))

import UIKit

protocol ActivityProgressHoneyCombDelegate:AnyObject {
    func stopAndStartActivity()
}

class ProgresViewXib: UIView {
    
    // MARK: Variables.
    weak var delegate:ActivityProgressHoneyCombDelegate?
    private var showingBack = false
    var isRecursiveCall:Bool = true
    var activityImageUrl:String = ""
    var isPlaying:Bool = true
    
    private var animationStarted = false
    
    // MARK: IBOutlets.
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var rotatingView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var outerImageView: UIImageView!
    @IBOutlet weak var innerImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var stopAndStartActivityView: UIView!
    @IBOutlet weak var activityLogoImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    
    // MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize() 
    }
    
    // MARK: Function to configure UIView.
    func configureView(frame:CGRect,activityData:ActivityData) {
//        self.startAnimationOfViewWith(frame: frame)
        self.activityNameLabel.text = activityData.name
        if let imageUrl = URL(string:activityData.image ?? "") {
            self.activityLogoImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "activity"), options: nil, progressBlock: nil) { (_) in
                self.activityLogoImageView.setImageColor(color: UIColor.white)
            }
        } else {
            self.activityLogoImageView.image = #imageLiteral(resourceName: "activity")
        }
        self.activityLogoImageView.setImageColor(color: UIColor.white)
        self.addGestureToView()
        if !isPlaying {
            self.stopAllAnimations()
        }
    }
    
    func addGestureToView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureTapped(recognizer:)))
        tapGesture.numberOfTapsRequired = 1
        self.stopAndStartActivityView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Helpers
    @objc func gestureTapped(recognizer: UITapGestureRecognizer) {
        if self.isRecursiveCall {
            self.stopAndStartActivityView.isUserInteractionEnabled = false
            self.stopAllAnimations()
        } else {
            self.restartAnimation()
        }
        self.delegate?.stopAndStartActivity()
    }
    
    // MARK: stopAllAnimations
    func stopAllAnimations() {
        self.animationStarted = false
        self.isRecursiveCall = false
        self.pauseLayer(layer: self.outerImageView.layer)
        //outerImageView.layoutIfNeeded()
        self.pauseLayer(layer: self.innerImageView.layer)
       // innerImageView.layoutIfNeeded()
        self.outerImageView.tintColor = UIColor(red: 100/255, green: 175/255, blue: 230/255, alpha: 1.0)
        self.innerImageView.tintColor = UIColor(red: 100/255, green: 175/255, blue: 230/255, alpha: 1.0)
    }
    
    //    private func pauseLayer(layer: CALayer) {
    //        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
    //        layer.speed = 0.0
    //        layer.timeOffset = pausedTime
    //    }
    //
    //    private func resumeLayer(layer: CALayer) {
    //        let pausedTime = layer.timeOffset
    //        layer.speed = 1.0
    //        layer.timeOffset = 0.0
    //        layer.beginTime = 0.0
    //        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    //        layer.beginTime = timeSincePause
    //    }
    
    // MARK: restartAnimation
    func restartAnimation() {
        guard animationStarted == false else {
            return
        }
        self.animationStarted = true
        self.outerImageView.tintColor = .clear
        self.innerImageView.tintColor = .clear
        self.isRecursiveCall = true
        self.rotateViewClockWise()
        self.addRipples()
//        self.resumeLayer(layer: self.outerImageView.layer)
//        self.resumeLayer(layer: self.innerImageView.layer)
    }
    
    // MARK: This method will stop all animation on call.
    func pauseLayer(layer: CALayer) {
        //This was freezing the UI interaction like in case if UIAlertController is presented on window
//        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
//        layer.speed = 0.0
//        layer.timeOffset = pausedTime
        
        layer.removeAllAnimations()
        layer.sublayers?.forEach({ (layer) in
            layer.removeAllAnimations()
            //layer.removeAnimation(forKey: "rippleEffect")
        })
    }
    // MARK: This method will resume all animation on call.
    func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    private func intialize() {
        Bundle.main.loadNibNamed("ProgresViewXib", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame.size = self.frame.size
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.perform(#selector(startViewsAnimations), with: nil, afterDelay: 1)
    }
    
    @objc func startViewsAnimations() {
        if isPlaying == false {
            return
        }
        self.startAnimationOfViewWith(frame: frame)
        self.addRipples()
    }
    
    private func addRipples() {
        let outerImageBezierPath = UIBezierPath(frame: self.outerImageView.bounds, sides: 6, cornerRadius: 0.0)
        let innerImageBezierPath = UIBezierPath(frame: self.innerImageView.bounds, sides: 6, cornerRadius: 0.0)
        self.outerImageView.addRippleEffect(bezierPath: outerImageBezierPath ?? UIBezierPath(), strokeColor: UIColor.appThemeColor)
        self.innerImageView.addRippleEffect(bezierPath: innerImageBezierPath ?? UIBezierPath(), strokeColor: UIColor.appThemeColor)
    }
    
    private func rotateViewClockWise() {
        if self.isRecursiveCall {
            self.showActivityIconOrLogo(state: !self.activityNameLabel.isHidden)
            UIView.transition(with: self.rotatingView, duration: 1.0, options: [.transitionFlipFromLeft], animations: {
            }) { (true) in
            //    print("completed")
                self.stopAndStartActivityView.isUserInteractionEnabled = true
                if self.isRecursiveCall {
                    self.rotateViewClockWise()
                }
            }
        }
        
    }
    
    func showActivityIconOrLogo(state:Bool) {
        self.activityNameLabel.isHidden = state
        self.activityLogoImageView.isHidden = state
        if state {
            self.logoImageView.image =  #imageLiteral(resourceName: "logo-white")
        } else {
            self.logoImageView.image = nil
        }
    }
    
    private func startAnimationOfViewWith(frame:CGRect) {
        self.rotateViewClockWise()
    }
    
}

