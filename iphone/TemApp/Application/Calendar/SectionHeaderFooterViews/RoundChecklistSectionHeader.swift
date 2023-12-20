//
//  RoundChecklistSectionHeader.swift
//  TemApp
//
//  Created by Mohit Soni on 20/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol RoundChecklistSectionHeaderDelegte: AnyObject {
    func didTappedDelete(at section: Int)
    func didTappedArrow(at section: Int)
    func didTappedDetails(at section: Int)
}
class RoundChecklistSectionHeader: UITableViewHeaderFooterView {
    // MARK: IBOutlets
    @IBOutlet weak var roundNumberLbl: UILabel!
    @IBOutlet weak var roundTitleLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var backShadowView: SSNeumorphicView! {
        didSet {
            setShadow(view: backShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var plainView: UIView!
    // MARK: Properties
   weak var delegate: RoundChecklistSectionHeaderDelegte?
    // MARK: IBActions
    @IBAction func deleteTapped(_ sender: UIButton) {
        self.delegate?.didTappedDelete(at: sender.tag)
    }
    @IBAction func arrowTapped(_ sender: UIButton) {
        self.delegate?.didTappedArrow(at: sender.tag)
    }
    @IBAction func detailsTapped(_ sender: UIButton) {
        self.delegate?.didTappedDetails(at: sender.tag)
    }
    func setData(rounds: [CreatedRounds], section: Int, screenFrom: Constant.ScreenFrom) {
        deleteBtn.tag = section
        arrowBtn.tag = section
        detailsBtn.tag = section
        roundNumberLbl.text = "\(section + 1)"
        roundTitleLbl.text = "Round \(section + 1)"// rounds[section].round?.round_name?.firstUppercased ?? ""
        if rounds[section].isOpened ?? false {
            arrowBtn.setBackgroundImage(UIImage(named: "roundDownArrow"), for: .normal)
            backShadowView.isHidden = true
            plainView.isHidden = false
        } else {
            arrowBtn.setBackgroundImage(UIImage(named: "roundRightArrow"), for: .normal)
            backShadowView.isHidden = false
            plainView.isHidden = true
        }
        deleteBtn.isHidden = false
        if screenFrom == .eventInfo {
            detailsBtn.isUserInteractionEnabled = false
            deleteBtn.isHidden = true
        }
    }
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1)
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
    }
}
