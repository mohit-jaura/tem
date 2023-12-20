//
//  CartMangementCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 20/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView


class CartMangementCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var productmg: UIImageView!
    @IBOutlet weak var priceLAbel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
            backView.viewNeumorphicCornerRadius = 8
        }
    }
    
    // MARK: Variables
    var stepperTapped:IntCompletion?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(_ productInfo:ProductInfo?) {
        priceLAbel.text = "\(Constant.CUR_Sign)\(Double(productInfo?.quantity ?? 0) * (Double(productInfo?.variants?.first?.price ?? "0.0") ?? 0.0))"

        //priceLAbel.text = "\(Constant.CUR_Sign)\(productInfo?.cartTotal ?? 0)"
        nameLabel.text = productInfo?.product_name
        stepper.value = Double(productInfo?.quantity ?? 0)
        productmg.setImg(productInfo?.image?.first?.src)
        quantityLabel.text = "Quantity: \(productInfo?.quantity ?? 0)"

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func stepperAction(_ sender: UIStepper) {
       // quantityLabel.text = "Quantity: \(Int(sender.value))"
        stepperTapped?(Int(sender.value), IndexPath(row: self.tag, section: 0))
        
    }
}
