//
//  PaymentHistoryTableViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 16/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class PaymentHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var affiliateNameLbl:UILabel!
    @IBOutlet weak var affiliateImage:UIImageView!
    @IBOutlet weak var amountLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var bgShadowButton: SSNeumorphicButton!{
        didSet{
            bgShadowButton.btnNeumorphicCornerRadius = 8
            bgShadowButton.btnNeumorphicShadowRadius = 0.8
            bgShadowButton.btnDepthType = .outerShadow
            bgShadowButton.btnNeumorphicLayerMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
            bgShadowButton.btnNeumorphicShadowOpacity = 0.8
            bgShadowButton.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            bgShadowButton.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            bgShadowButton.btnNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(history:PaymentHistory) {
        affiliateNameLbl.text = history.affiliateName ?? ""
        if let image = history.affiliateImage,let url = URL(string: image){
            affiliateImage.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "placeholder"))
        }
        let stringAmount = String(history.paymentAmout ?? 0)
        let sepratedAmount = stringAmount.split(separator: ".")
        if (sepratedAmount[1].hasPrefix("0") && sepratedAmount[1].count == 1) || sepratedAmount[1].hasPrefix("00"){
            amountLbl.text = "$\(sepratedAmount[0])"
        }else{
            amountLbl.text = "$\(history.paymentAmout?.rounded(toPlaces: 2) ?? 0)"
        }
    }

}
