//
//  GroupInfoMuteAndExitActionTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 23/12/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol GroupInfoMuteAndExitActionTableViewCellDelegate: AnyObject {
    func didTapOnMuteJoinAndExitButton(sender: UIButton)
}
class GroupInfoMuteAndExitActionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var muteGradientView:GradientDashedLineCircularView!{
        didSet{
            self.createGradientView(view: muteGradientView, colors:[UIColor.cyan.withAlphaComponent(1),UIColor.cyan.withAlphaComponent(0.5), UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)])
        }
    }
    @IBOutlet weak var exitGradientView:GradientDashedLineCircularView!{
        didSet{
            self.createGradientView(view: exitGradientView, colors:[UIColor.red.withAlphaComponent(1),UIColor.red.withAlphaComponent(0.5), UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)])
            
        }
    }
    
    @IBOutlet weak var joinGradientView:GradientDashedLineCircularView!{
        didSet{
            self.createGradientView(view: joinGradientView, colors:[UIColor.cyan.withAlphaComponent(1),UIColor.cyan.withAlphaComponent(0.5), UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)])
        }
    }
    
    @IBOutlet weak var muteShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: muteShadowView, shadowType: .outerShadow, cornerRadius: muteShadowView.frame.height / 2, shadowRadius: 5)
        }
    }
    @IBOutlet weak var exitShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: exitShadowView, shadowType: .outerShadow, cornerRadius: exitShadowView.frame.height / 2, shadowRadius: 5)
        }
    }
    
    @IBOutlet weak var joinShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: joinShadowView, shadowType: .outerShadow, cornerRadius: joinShadowView.frame.height / 2, shadowRadius: 5)
        }
    }
    
    @IBOutlet weak var muteButton:UIButton!
    @IBOutlet weak var exitButton:UIButton!
    @IBOutlet weak var joinButton:UIButton!
    @IBOutlet weak var muteExitView:UIView!
    @IBOutlet weak var joinView:UIView!
    var delegate: GroupInfoMuteAndExitActionTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(_ sender:UIButton){
        self.delegate?.didTapOnMuteJoinAndExitButton(sender: sender)
    }
    
    func createGradientView(view:GradientDashedLineCircularView , colors:[UIColor]){
        
        view.configureViewProperties(colors: colors, gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.25, y: 0.5)))
        view.instanceWidth = 2.0
        view.instanceHeight = 6.0
        view.extraInstanceCount = 1
        view.lineColor = UIColor.gray
        view.updateGradientLocation(newLocations: [NSNumber(value: 0.35),NSNumber(value: 0.60),NSNumber(value: 0.89),NSNumber(value: 0.99)], addAnimation: false)
    }
    
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.white.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
}
