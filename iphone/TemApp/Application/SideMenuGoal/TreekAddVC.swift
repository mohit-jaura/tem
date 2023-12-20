//
//  TreekAddVC.swift
//  TemApp
//
//  Created by Developer on 01/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol TrekDelegate {
    func setTrekValue(value:Int)
}
class TreekAddVC: DIBaseController {
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    var delegate:TrekDelegate?
    // MARK: IBOutlet
    var selectedValue:Int = 1
    @IBOutlet var activityScoreView: SSNeumorphicView!
    @IBOutlet var activityScoreView1: SSNeumorphicView!
    @IBOutlet weak var lineView: GradientDashedLineCircularView!
    @IBOutlet weak var onTrekbtn: UIButton!
    @IBOutlet weak var offTrekbtn: UIButton!
   
    @IBOutlet weak var gradientContainerView: UIView!
    @IBOutlet weak var shadowView:SSNeumorphicView!{
        didSet{
            shadowView.viewDepthType = .innerShadow
            shadowView.viewNeumorphicMainColor = viewBackgroundColor.cgColor
            self.shadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            self.shadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(1).cgColor
            shadowView.viewNeumorphicCornerRadius = 9
            shadowView.viewNeumorphicShadowRadius = 3
            shadowView.borderWidth = 0
        }
    }
    
    @IBAction func onClickStart(_ sender:UIButton) {
        delegate?.setTrekValue(value: selectedValue)
     //   self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
//        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func backTapped(_ sender : UIButton){
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func onClickOnTrek(_ sender:UIButton) {
        selectedValue = 1
        onTrekbtn.setImage(UIImage(named: "selectActivity"), for: .normal)
        offTrekbtn.setImage(UIImage(named: "Rate Your wellness unselect"), for: .normal)
    }
    
    @IBAction func onClickOffTrek(_ sender:UIButton) {
        selectedValue = 2
        offTrekbtn.setImage(UIImage(named: "selectActivity"), for: .normal)
        onTrekbtn.setImage(UIImage(named: "Rate Your wellness unselect"), for: .normal)
    }
    @IBOutlet var startButtonShadowView: SSNeumorphicView! {
        didSet {
            startButtonShadowView.viewDepthType = .outerShadow
            startButtonShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            startButtonShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            startButtonShadowView.viewNeumorphicCornerRadius = startButtonShadowView.frame.width/2
            startButtonShadowView.viewNeumorphicShadowRadius = 1.0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityScoreView.cornerRadius = self.activityScoreView.frame.width/2
        self.activityScoreView.viewDepthType = .innerShadow
        activityScoreView.viewNeumorphicCornerRadius = self.activityScoreView.frame.width/2
        self.activityScoreView.viewNeumorphicMainColor = UIColor.black.cgColor
        self.activityScoreView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.activityScoreView.viewNeumorphicDarkShadowColor = UIColor.darkGray.cgColor
        
        
        self.activityScoreView1.cornerRadius = self.activityScoreView1.frame.width/2
        self.activityScoreView1.viewDepthType = .innerShadow
        activityScoreView1.viewNeumorphicCornerRadius = self.activityScoreView1.frame.width/2
        self.activityScoreView1.viewNeumorphicMainColor = UIColor.black.cgColor
        self.activityScoreView1.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.activityScoreView1.viewNeumorphicDarkShadowColor = UIColor.darkGray.cgColor
        gradientContainerView.cornerRadius = gradientContainerView.frame.width / 2
        setGradientView()
        // Do any additional setup after loading the view.
    }
    private func setGradientView() {
        
        lineView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1),UIColor.cyan.withAlphaComponent(1)], gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        lineView.instanceWidth = 1.0
        lineView.instanceHeight = 4.0
        lineView.extraInstanceCount = 1
        lineView.lineColor = UIColor(red: 140/255, green: 148/255, blue: 147/255, alpha: 1.0)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
