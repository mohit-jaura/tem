//
//  GroupVisibilityTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 16/12/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView


protocol GroupVisibilityTableViewCellDelegate{
    func didTapOnToggleButton(sender:UIButton)
}
class GroupVisibilityTableViewCell: UITableViewCell {

    @IBOutlet weak var privateButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: privateButtonShadowView, shadowType: .innerShadow, cornerRadius: privateButtonShadowView.frame.width / 2, shadowRadius: 5)
        }
    }
    
    @IBOutlet weak var tematesButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: tematesButtonShadowView, shadowType: .innerShadow, cornerRadius: tematesButtonShadowView.frame.width / 2, shadowRadius: 5)
        }
    }
    
    @IBOutlet weak var publicButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: publicButtonShadowView, shadowType: .innerShadow, cornerRadius: publicButtonShadowView.frame.width / 2, shadowRadius: 5)
        }
    }
    
    @IBOutlet weak var privateToggle:UIButton!
    @IBOutlet weak var tematesToggle:UIButton!
    @IBOutlet weak var publicToggle:UIButton!
    
    var delegate:GroupVisibilityTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func privateButtonTapped(_ sender:UIButton){
        sender.isSelected.toggle()
        tematesToggle.isSelected = false
        publicToggle.isSelected = false
        self.delegate?.didTapOnToggleButton(sender: sender)
    }
    
    func changeToggle(senderTag:Int){
        switch senderTag {
        case 0:
            tematesToggle.isSelected = false
            publicToggle.isSelected = false
        case 1:
            privateToggle.isSelected = false
            publicToggle.isSelected = false
        case 2:
            tematesToggle.isSelected = false
            privateToggle.isSelected = false
        default:
            return
        }
    }
    
    @IBAction func tematesButtonTapped(_ sender:UIButton){
        sender.isSelected.toggle()
        privateToggle.isSelected = false
        publicToggle.isSelected = false
        self.delegate?.didTapOnToggleButton(sender: sender)
    }
    
    @IBAction func publicButtonTapped(_ sender:UIButton){
        sender.isSelected.toggle()
        tematesToggle.isSelected = false
        privateToggle.isSelected = false
        self.delegate?.didTapOnToggleButton(sender: sender)
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
