//
//  ManageBillingViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 23/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ManageBillingViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var paymentCardsShadowButton: SSNeumorphicButton!{
        didSet{
            addShadow(button: paymentCardsShadowButton)
        }
    }
    
    @IBOutlet weak var spendHistoryShadowButton: SSNeumorphicButton!{
        didSet{
           addShadow(button: spendHistoryShadowButton)
        }
    }
    func addShadow(button: SSNeumorphicButton){
        button.btnNeumorphicCornerRadius = 8
        button.btnNeumorphicShadowRadius = 0
        button.btnDepthType = .outerShadow
        button.btnNeumorphicLayerMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
        button.btnNeumorphicShadowOpacity = 0.8
        button.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        button.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        button.btnNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    // MARK: IBActions
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func spendHistoryTapped(_ sender: UIButton) {
        let spendHistoryVC: PaymentHistoryViewController = UIStoryboard(storyboard: .payment).initVC()
        self.navigationController?.pushViewController(spendHistoryVC, animated: true)
    }
    
    @IBAction func managePaymentCardsTapped(_ sender: UIButton) {

        let manageCardsVC: ManageCardsViewController = UIStoryboard(storyboard: .managecards).initVC()
        self.navigationController?.pushViewController(manageCardsVC, animated: true)

    }
}
