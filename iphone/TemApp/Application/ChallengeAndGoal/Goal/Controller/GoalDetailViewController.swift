//
//  GoalDetailViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 05/10/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class GoalDetailViewController: UIViewController {

    // MARK: OUTLETS
    @IBOutlet weak var headerLineView:UIView!
    
    @IBOutlet weak var activityBtn:SSNeumorphicButton!{
        didSet{
            setBtnShadow(btn: activityBtn, shadowType: .innerShadow)
        }
    }
    
    @IBOutlet weak var fundraisingBtn:SSNeumorphicButton!
    {
        didSet{
            setBtnShadow(btn: fundraisingBtn, shadowType: .innerShadow)
        }
    }
    
    @IBOutlet weak var nameFieldView:SSNeumorphicView!{
        didSet{
            setViewShadow(view: nameFieldView, shadowType: .outerShadow)
        }
    }
    
    @IBOutlet weak var temMatesFieldView:SSNeumorphicView!{
        didSet{
            setViewShadow(view: temMatesFieldView, shadowType: .outerShadow)
        }
    }
    
    @IBOutlet weak var daysLbl:UILabel!

    @IBOutlet weak var daysLblTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var chatterMainView:SSNeumorphicView!{
        didSet{
            setViewShadow(view: chatterMainView, shadowType: .innerShadow)
        }
    }
    
    @IBOutlet weak var chatterTableView:UITableView!
    
    @IBOutlet weak var navBar:UINavigationBar!
    
    @IBOutlet weak var navItem:UINavigationItem!
    
    @IBOutlet weak var navBarLeftItem:UIBarButtonItem!
    
    @IBOutlet weak var navBarRightItem:UIBarButtonItem!
    
    @IBOutlet weak var honeyCombImageView:UIImageView!
    
    @IBOutlet weak var honeyCombShapeView:UIView!
    
    @IBOutlet weak var honeyCombShapeShadowView:GradientDashedLineCircularView!
    
    // MARK: Properties
    private var rightInset: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        headerLineView.layer.shadowOffset = CGSize(width: 20, height: 20)
        headerLineView.layer.shadowColor = UIColor.black.cgColor
        headerLineView.shadowRadius = 15
        
        //Rotate the days label vertically
        daysLblTrailing.constant = rightInset - daysLbl.frame.width/2 + daysLbl.frame.height/2
        daysLbl.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.chatterTableView.registerNibs(nibNames: [
            SenderSideCell.reuseIdentifier,ReceiverSideCell.reuseIdentifier
        ])
        navItem.rightBarButtonItem = navBarRightItem
        navItem.leftBarButtonItem = navBarLeftItem
        navBar.setItems([navItem], animated: false)
        honeyCombImageView.image = UIImage(named: "edit-pro")
        setImageShape()
        setLinesView()
    }
    
    // MARK: IBACTIONS
    @IBAction func activityTapped(_ sender:SSNeumorphicButton){
        activityBtn.btnNeumorphicLayerMainColor = UIColor.appThemeColor.cgColor
        activityBtn.tintColor = UIColor.white
        setBtnShadow(btn: fundraisingBtn, shadowType: .innerShadow)
        fundraisingBtn.tintColor = UIColor.black
    }
    
    @IBAction func fundraisingTapped(_ sender:UIButton){
        fundraisingBtn.btnNeumorphicLayerMainColor = UIColor.appThemeColor.cgColor
        fundraisingBtn.tintColor = UIColor.white
        setBtnShadow(btn: activityBtn, shadowType: .innerShadow)
        activityBtn.tintColor = UIColor.black
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem){
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func editTapped(_ sender: UIBarButtonItem){
        
    }
    
    // MARK: Methods
    
    func setLinesView(){
        honeyCombShapeShadowView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        honeyCombShapeShadowView.instanceWidth = 2.0
        honeyCombShapeShadowView.instanceHeight = 15.0
        honeyCombShapeShadowView.extraInstanceCount = 1
        honeyCombShapeShadowView.lineColor = UIColor.red
        honeyCombShapeShadowView.updateGradientLocation(newLocations: [NSNumber(value: 0.00),NSNumber(value: 0.87)], addAnimation: true)
    }
    
    func setImageShape(){
        let path = UIBezierPath(rect: honeyCombImageView.bounds, sides: 6, lineWidth: 5, cornerRadius: 0)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        honeyCombImageView.layer.mask = mask
    }
    func setViewShadow(view: SSNeumorphicView, shadowType: ShadowLayerType){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.white.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
    func setBtnShadow(btn: SSNeumorphicButton, shadowType: ShadowLayerType){
        btn.btnNeumorphicCornerRadius = 8
        btn.btnNeumorphicShadowRadius = 0.8
        btn.btnDepthType = shadowType
        btn.btnNeumorphicLayerMainColor = UIColor.white.cgColor
        btn.btnNeumorphicShadowOpacity = 0.25
        btn.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.7)
        btn.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        btn.btnNeumorphicLightShadowColor = UIColor.black.cgColor
    }
}

// MARK: Extensions
extension GoalDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = self.chatterTableView.dequeueReusableCell(withIdentifier: "ReceiverSideCell", for: indexPath) as! ReceiverSideCell
            cell.messageLbl.text = "Testing the chat funtionality for the design"
            return cell
        }
        else {
            let cell = self.chatterTableView.dequeueReusableCell(withIdentifier: "SenderSideCell", for: indexPath) as! SenderSideCell
            return cell
        }
    }
}
