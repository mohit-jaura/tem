//
//  ActivePaymentTableViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 25/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

protocol UpdateSubscriptionDelegate: AnyObject{
    func didTappedCancelOrUpgradeButton(index:Int)
}

enum PlanActiveStatus: Int, CaseIterable{
    case notActive = 1
    case active = 2
    case cancel = 3
    case upgrade = 4
    case downgrade = 5
}
class ActivePaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var planExpireDateLAbel: UILabel!
    @IBOutlet weak var planTypeNameLabel: UILabel!
    @IBOutlet weak var cancelOrUpgradeButton: CustomButton!
    @IBOutlet weak var activeLAbel: UILabel!
    @IBOutlet weak var upcomingLAbel: UILabel!
    @IBOutlet weak var planPriceLabel: UILabel!
    
    var affiliateId = ""
    var planData : PlanList?
    var updateSubscriptionDelegate: UpdateSubscriptionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(planData: PlanList,index:Int){
        self.planData = planData
        switch PlanActiveStatus(rawValue: planData.planActiveStatus){
        case .active:
            configureViewsLayout(bgColor: .red, title: "Cancel Subscription")
        case .notActive:
            configureViewsLayout(bgColor: .gray, title: "Purchase")
        case .upgrade:
            configureViewsLayout(bgColor: .gray, title: "Upgrade")
        case .downgrade:
            configureViewsLayout(bgColor: .gray, title: "Downgrade")
        case .cancel:
            configureViewsLayout(bgColor: .red, title: "Cancelled")
        default:
            break
        }
        cancelOrUpgradeButton.tag = index
        planTypeNameLabel.text = planData.name.firstUppercased
        let stringAmount = String(planData.amount)
        let sepratedAmount = stringAmount.split(separator: ".")
        if (sepratedAmount[1].hasPrefix("0") && sepratedAmount[1].count == 1) || sepratedAmount[1].hasPrefix("00"){
            planPriceLabel.text = "$\(sepratedAmount[0]) for \(planData.duration)"
        }else{
            planPriceLabel.text = "$\(planData.amount.rounded(toPlaces: 2)) for \(planData.duration)"
        }
        if planData.expirydate != 0{
            activeLAbel.isHidden = false
            activeLAbel.text = "Active"
            activeLAbel.textColor = UIColor.systemGreen
            planExpireDateLAbel.isHidden = false
            let date = planData.expirydate?.timestampInMillisecondsToDate ?? Date()
            let dateString = date.toUTCString(inFormat: .activityDateDisplay) ?? ""
            planExpireDateLAbel.text = "Plan Expire:\(dateString)"
        }else{
            activeLAbel.isHidden = true
            planExpireDateLAbel.isHidden = true
        }
        cancelOrUpgradeButton.isUserInteractionEnabled = true
        if planData.isUpComing ?? 0 == 1{
            cancelOrUpgradeButton.isUserInteractionEnabled = false
            activeLAbel.isHidden = false
            activeLAbel.text = "Upcoming"
            activeLAbel.textColor = UIColor.systemYellow
        }
    }
    
    func configureViewsLayout(bgColor: UIColor, title: String){
        if bgColor == UIColor.red{
            cancelOrUpgradeButton.setTitle(title, for: .normal)
            cancelOrUpgradeButton.backgroundColor = .red
            cancelOrUpgradeButton.setTitleColor(UIColor.white, for: .normal)
        }else{
            cancelOrUpgradeButton.setTitle(title, for: .normal)
            cancelOrUpgradeButton.backgroundColor = .gray
            cancelOrUpgradeButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    
    @IBAction func cancelOrUpgradeButtonTapped(_ sender: UIButton) {
        self.updateSubscriptionDelegate?.didTappedCancelOrUpgradeButton(index: sender.tag)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
