//
//  ProgramHeaderView.swift
//  TemApp
//
//  Created by Shiwani Sharma on 07/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol ShowEventDetailsDelegate: AnyObject {
    func openDetails(at index: Int)
}

class ProgramHeaderView: UITableViewHeaderFooterView {
    
    // MARK: Outlets
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var nameLAbel: UILabel!
    @IBOutlet weak var bgView: SSNeumorphicView! {
        didSet {
            manageBgViewUI(type: .outerShadow, darkColor: UIColor.black.withAlphaComponent(0.3).cgColor, lightColor: UIColor.white.withAlphaComponent(0.1).cgColor, mainColor: #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor)
        }
    }
   
    var showEventDetailsDelegate: ShowEventDetailsDelegate?
    var programData: Programs?
    
    @IBAction func arrowTapped(_ sender: UIButton) {
        showEventDetailsDelegate?.openDetails(at: sender.tag)
        setArrowButton()
        
    }
    func setData(data: Programs?){
        programData = data
        setArrowButton()
        nameLAbel.text = data?.event_name
        durationLabel.text = " Duration:\(data?.duration ?? 0) Days"
    }
    
    func manageBgViewUI(type: ShadowLayerType, darkColor: CGColor, lightColor: CGColor, mainColor: CGColor){
        bgView.viewDepthType = type
        bgView.viewNeumorphicLightShadowColor = lightColor
        bgView.viewNeumorphicDarkShadowColor = darkColor
        bgView.viewNeumorphicCornerRadius = 4.0
        bgView.viewNeumorphicMainColor = mainColor
        bgView.viewNeumorphicShadowRadius = 2.0
    }
    
    func setArrowButton() {
        let image = programData?.isOpened ?? false ? "roundDownArrow" : "roundRightArrow"
        arrowButton.setImage(UIImage(named: image), for: .normal)
    }
}
