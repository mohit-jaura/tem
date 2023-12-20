//
//  PlanTVC.swift
//  TemApp
//
//  Created by Developer on 24/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class PlanTVC: UITableViewCell {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var planName:UILabel!
    @IBOutlet weak var durationName:UILabel!
    @IBOutlet weak var amountName:UILabel!
    @IBOutlet weak var selectBtn:CustomButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var planTitle: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setData(planData: PlanList,index:Int, planAlreadyPurchased:Bool){
        planName.text = planData.name
        let stringAmount = String(planData.amount)
        let sepratedAmount = stringAmount.split(separator: ".")
        if (sepratedAmount[1].hasPrefix("0") && sepratedAmount[1].count == 1) || sepratedAmount[1].hasPrefix("00"){
            amountName.text = "$\(sepratedAmount[0]) for \(planData.duration)"
        }else{
            amountName.text = "$\(planData.amount.rounded(toPlaces: 2)) for \(planData.duration)"
        }
        planTitle.text = planData.displayName ?? ""
        descriptionTextView.text = planData.description ?? ""
        if planData.planActiveStatus == 2{
            selectBtn.backgroundColor = UIColor.cyan
            selectBtn.setBackgroundImage(UIImage(named: ""), for: .normal)
            selectBtn.setTitle("Selected", for: .normal)
            selectBtn.setTitleColor(UIColor.black, for: .normal)
        }else{
            selectBtn.backgroundColor = UIColor.clear
            selectBtn.setBackgroundImage(UIImage(named: "save-exit"), for: .normal)
            selectBtn.setTitle("Select", for: .normal)
            selectBtn.setTitleColor(UIColor.white, for: .normal)
        }
        if planAlreadyPurchased{
            selectBtn.isUserInteractionEnabled = false
        }else{
            selectBtn.isUserInteractionEnabled = true
        }
        selectBtn.tag = index
    }
    
}
