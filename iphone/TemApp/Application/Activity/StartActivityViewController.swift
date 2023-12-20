//
//  StartActivityViewController.swift
//  TemApp
//
//  Created by Shivani on 11/11/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol StartActivityDelegate: AnyObject {
    func startActivity()
}
enum ActivityOptional {
    case None
    case Optional
    case NotOptional
}
class StartActivityViewController: DIBaseController {
    // MARK: Properties
    
    @IBOutlet weak var startInLabel: UILabel!
    @IBOutlet weak var startsInProgressView: UIView!
   @IBOutlet weak var shadowViewBreakTime: UIView!
//       { didSet {
//            ver1(shadowViewBreakTime,9)
//            shadowViewBreakTime.viewNeumorphicShadowRadius = 3
//            shadowViewBreakTime.borderWidth = 0
//        }
//    }
    @IBOutlet weak var breakTimeView: UIView!
    @IBOutlet weak var backButtonOut: UIButton!
    @IBOutlet weak var skipbutOut: UIButton!
    @IBOutlet weak var tralingLabel: NSLayoutConstraint!
    @IBOutlet weak var optionalLabel: UILabel!
    var selectedActivity:ActivityData = ActivityData()
    var activityName: String = ""
    var isBinary: Bool = false
    var activityOptional : ActivityOptional = .None
    var activityState : ActivityPauseState = .none
    var startActivityDelegate: StartActivityDelegate?
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    var skipTapped:OnlySuccess?
    var exitTapped:OnlySuccess?
    var totalBreakTime = 60
    var breakTime:Timer?
    var activityCategoryDataType = ActivityCategoryType.physicalFitness.rawValue
    
    
    // MARK: IBOutlet
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var startActivityLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet var startButtonShadowView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    func breakTimerInitialise() {
        if breakTimeView.isHidden == false {
            breakTime =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(breakTimeSet), userInfo: nil, repeats: true)

        }
    }
    
    @objc func breakTimeSet() {
        if self.isBinary {
            self.startInLabel.text = "Logs in \n\(self.totalBreakTime)"
        } else {
            self.startInLabel.text = "Starts in \n\(self.totalBreakTime)"
        }
        self.totalBreakTime -= 1
        
        self.initialiseProgressView()
        if self.totalBreakTime <= 0 {
            self.breakTime?.invalidate()
            self.breakTime = nil
            self.startTapped(self.backButtonOut)
            UIView.animate(withDuration: 1, delay: 0, options: [.curveLinear], animations: {
                self.breakTimeView.alpha = 0
            }, completion: nil)
            
        }
    }
  
    func initialiseProgressView() {
        let valueUnwrapped = Double(60 - totalBreakTime) * 1.6667
    let scoreGradientLocation = valueUnwrapped < 100 ? valueUnwrapped/(100) : 1
    let nextGradientLocation = scoreGradientLocation + 0.03
  //  self.startsInProgressView.updateGradientLocation(newLocations: [NSNumber(value: scoreGradientLocation), NSNumber(value: nextGradientLocation)], addAnimation: true)
    }
    
    func initialize(){

    //    setGradientView(lineView)
        breakTimeView.cornerRadius = breakTimeView.frame.height / 2
        if activityState != .none{
            startActivityLabel.text = "ADD"
        }
        if activityCategoryDataType == ActivityCategoryType.nutritionAwareness.rawValue || selectedActivity.isBinary == 1 || self.isBinary  {
            startActivityLabel.text = "LOG"
        }
        checkActivityType()
        
        activityNameLabel.text = activityName.uppercased()
    }
    func checkActivityType() {
      //  setGradientView(startsInProgressView,UIColor.appRed)
        skipbutOut.isHidden = activityOptional != .Optional
        optionalLabel.isHidden = activityOptional != .Optional
        breakTimeView.isHidden = activityOptional == .None || totalBreakTime == 0
     shadowViewBreakTime.isHidden = activityOptional != .Optional
        breakTimerInitialise()
        nameLabelRotate()
    }
    func nameLabelRotate() {
        tralingLabel.constant = 5 - optionalLabel.frame.width/2 + optionalLabel.frame.height/2
        optionalLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)

    }
    
    // MARK: IBAction
    @IBAction func backTapped(_ sender : UIButton){
        switch activityOptional {
        case .None:
            self.dismiss(animated: true, completion: nil)
        case .Optional:
            alertOpt("Do you want to skip this activity", okayTitle: "Yes", cancelTitle: "No", okCall: {
                
                //Start next one
                self.dismiss(animated: true) {
                    self.skipTapped?()
                }
               
                
                debugPrint("Start next activity")
            }, cancelCall: nil, parent: self)

        case .NotOptional:
            alertOpt("Do you want to exit from this event", okayTitle: "Yes", cancelTitle: "No", okCall: {
                //Start next one
                self.dismiss(animated: true) {
                    self.exitTapped?()
                }
                //Start next one
                
                
            }, cancelCall: nil, parent: self)
        }
        
    }
    
    @IBAction func startTapped(_ sender : UIButton){
        let valueUnwrapped = 100.0
        let scoreGradientLocation = valueUnwrapped <= 100 ? valueUnwrapped/(100) : 1
        let nextGradientLocation = scoreGradientLocation + 0.03
     //   self.lineView.updateGradientLocation(newLocations: [NSNumber(value: scoreGradientLocation), NSNumber(value: nextGradientLocation)], addAnimation: true)
        
    //    Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(delayedAction), userInfo: nil, repeats: false)
        delayedAction()
    }
    @objc func delayedAction(){
        self.startActivityDelegate?.startActivity()
        self.dismiss(animated: false, completion: nil)
    }
    
    private func setGradientView(_ initView:GradientDashedLineCircularView,_ color:UIColor =  UIColor(red: 140/255, green: 148/255, blue: 147/255, alpha: 1.0)) {
        
        initView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        initView.instanceWidth = 1.0
        initView.instanceHeight = 4.0
        initView.extraInstanceCount = 1
        initView.lineColor = color
        
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        alertOpt("Do you want to skip this activity", okayTitle: "Yes", cancelTitle: "No", okCall: {
            
            //Start next one
            self.dismiss(animated: true) {
                self.skipTapped?()
            }
           
            
            debugPrint("Start next activity")
        }, cancelCall: nil, parent: self)
    }
}
