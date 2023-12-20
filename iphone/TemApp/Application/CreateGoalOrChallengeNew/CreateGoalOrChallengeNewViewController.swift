//
//  CreateGoalOrChallengeNewViewController.swift
//  TemApp
//
//  Created by Developer on 17/10/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class CreateGoalOrChallengeNewViewController: UIViewController {
    @IBOutlet weak var nameField: CustomTextField!
    @IBOutlet weak var nameFieldshadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: nameFieldshadowView, shadowType: .innerShadow)
        }
    }
    
    @IBOutlet weak var saveButtonshadowView: SSNeumorphicView!{
        didSet{
            setShadowButton(view: saveButtonshadowView, shadowType: .outerShadow)
        }
    }

    @IBOutlet weak var seperatorShadowView: SSNeumorphicView!{
        didSet {
            seperatorShadowView.viewDepthType = .innerShadow
            seperatorShadowView.viewNeumorphicMainColor = UIColor.lightGray.cgColor
            seperatorShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            seperatorShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            seperatorShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    func setShadowButton(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.systemBlue.cgColor
        view.borderColor = UIColor.clear
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.darkGray.cgColor
        view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
        view.viewNeumorphicCornerRadius = view.frame.width/2
        view.viewNeumorphicShadowRadius = 1
    }
    
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.white.cgColor
        view.borderColor = UIColor.clear
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.8509803922, green: 0.862745098, blue: 0.8862745098, alpha: 1).withAlphaComponent(0.4).cgColor
        view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
        view.viewNeumorphicCornerRadius = 15
        view.viewNeumorphicShadowRadius = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
