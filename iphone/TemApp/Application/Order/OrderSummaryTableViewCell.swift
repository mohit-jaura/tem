//
//  OrderSummaryTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 23/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class OrderSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var backShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: backShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var productNameLbl:UILabel!
    @IBOutlet weak var productDescLbl:UILabel!
    @IBOutlet weak var productPriceLbl:UILabel!
    @IBOutlet weak var productImage:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func initialise(_ cartData:ProductInfo?) {
        productPriceLbl.text = "\(Constant.CUR_Sign)\(Double(cartData?.quantity ?? 0) * (Double(cartData?.variants?.first?.price ?? "0.0") ?? 0.0))"

        productNameLbl.text = cartData?.product_name
        productImage.setImg(cartData?.image?.first?.src)
        productDescLbl.text = "Quantity: \(cartData?.quantity ?? 0)"
    }
    
    private func addShadowView(view:SSNeumorphicView,shadowType:ShadowLayerType){
        view.viewNeumorphicCornerRadius = 8
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
        view.viewNeumorphicShadowOpacity = 0.8
        view.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        view.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        view.viewNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
    }
}
