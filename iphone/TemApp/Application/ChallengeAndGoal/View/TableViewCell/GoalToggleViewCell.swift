//
//  GoalToggleViewCell.swift
//  TemApp
//
//  Created by shilpa on 11/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol PublicGoalVlaue {
    func didToggle(value:Bool, tag: Int)
}

class GoalToggleViewCell: UITableViewCell {
    
    // MARK: Variables....
    var delegate: PublicGoalVlaue?
    
    // MARK: IBOutlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var toggle: UIButton!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var toggleButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: toggleButtonShadowView, shadowType: .outerShadow, cornerRadius: toggleButtonShadowView.frame.width / 2, shadowRadius: 2)
        }
    }
    
    // MARK: IBActions
    @IBAction func toggleButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        delegate?.didToggle(value: sender.isSelected, tag: sender.tag)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUserInteraction(shouldEnable: Bool) {
        let labelTextColor = shouldEnable ? UIColor.textBlackColor : UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 0.6)
        isUserInteractionEnabled = shouldEnable
        label.textColor = labelTextColor
        desc.textColor = labelTextColor
        toggle.isUserInteractionEnabled = shouldEnable
    }
    
    func initialize(groupActivity: GroupActivity?, currentSection: CreateGoalChallengeSection) {
        selectionStyle = .none
        toggle.isSelected = false
        switch currentSection {
        case .publicGoal:
            toggle.tag = CreateGoalChallengeSection.publicGoal.rawValue
            desc.isHidden = false
            desc.text = "(progress gets posted to feed)"
            label.text = "Public"
            if let isPublic = groupActivity?.isPublic {
                toggle.isSelected = isPublic
            }
        case .openToPublic:
            toggle.tag = CreateGoalChallengeSection.openToPublic.rawValue
            desc.isHidden = true
            label.text = "Open To Public"
            if let isOpen = groupActivity?.openToPublic {
                toggle.isSelected = isOpen
            }
        case .doNotParticipate:
            toggle.tag = CreateGoalChallengeSection.doNotParticipate.rawValue
            desc.isHidden = true
            label.text = "Do Not Participate"
            label.textColor = UIColor.red
            toggle.setImage(#imageLiteral(resourceName: "on-red"), for: UIControl.State.selected)
            if let isSelected = groupActivity?.doNotParticipate {
                toggle.isSelected = isSelected
            }
        case .enableFundraising:
            toggle.tag = CreateGoalChallengeSection.enableFundraising.rawValue
            desc.isHidden = true
            label.text = "Fundraising Event"
            toggle.isSelected = groupActivity?.fundraising != nil
        case .isPerPerson:
            toggle.tag = CreateGoalChallengeSection.isPerPerson.rawValue
            desc.isHidden = false
            desc.text = "(increase total goal with each new participant)"
            label.text = "Per Person Goal"
            if let isPerPersonGoal = groupActivity?.isPerPersonGoal {
                toggle.isSelected = isPerPersonGoal
            }
        default:
            break
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
