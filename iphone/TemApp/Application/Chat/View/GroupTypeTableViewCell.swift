//
//  GroupTypeTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 12/09/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol GroupTypeTableCellDelegate: AnyObject {
    func groupTypeToggle(on: Bool)
}

class GroupTypeTableViewCell: UITableViewCell {
    
    // MARK: Properties
    weak var delegate: GroupTypeTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var toggleButton: UIButton!
    
    @IBOutlet weak var editGroupButtonShadowView:SSNeumorphicView!{
        didSet{
            editGroupButtonShadowView.viewDepthType = .outerShadow
            editGroupButtonShadowView.viewNeumorphicMainColor =  #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
            editGroupButtonShadowView.viewNeumorphicLightShadowColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
            editGroupButtonShadowView.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            editGroupButtonShadowView.viewNeumorphicCornerRadius = 8
            editGroupButtonShadowView.viewNeumorphicShadowRadius = 0.8
            editGroupButtonShadowView.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            editGroupButtonShadowView.viewNeumorphicShadowOpacity = 0.25
        }
    }
    
    @IBOutlet weak var editGroupToggleButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: editGroupToggleButtonShadowView, shadowType: .innerShadow, cornerRadius: editGroupToggleButtonShadowView.frame.height / 2, shadowRadius: 5)
        }
    }
    // MARK: IBActions
    @IBAction func toggleTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            delegate?.groupTypeToggle(on: true)
        } else {
            delegate?.groupTypeToggle(on: false)
        }
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initialize(editableByMembers: Bool?) {
        if let editable = editableByMembers {
            toggleButton.isSelected = editable
        } else {
            toggleButton.isSelected = false
        }
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
