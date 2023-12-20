//
//  OrderCell.swift
//  TemApp
//
//  Created by PrabSharan on 16/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol RedirectReviewDelegate: AnyObject{
    func showReviewPage()
}

class OrderCell: UITableViewCell {

    @IBOutlet weak var productImage:UIImageView!
    @IBOutlet weak var productNumber:UILabel!
    @IBOutlet weak var productName:UILabel!
    @IBOutlet weak var productPrice:UILabel!
    @IBOutlet weak var pleaseRateButton:UIButton!
    @IBOutlet weak var rateButton1:UIButton!
    @IBOutlet weak var rateButton2:UIButton!
    @IBOutlet weak var rateButton3:UIButton!
    @IBOutlet weak var rateButton4:UIButton!
    @IBOutlet weak var rateButton5:UIButton!
    lazy var buttonsArray = [rateButton1,rateButton2,rateButton3,rateButton4,rateButton5]
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
            backView.viewNeumorphicCornerRadius = 8
        }
    }
    var redirectReviewDelegate: RedirectReviewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pleaseRateTapped(_ sender:UIButton){
        redirectReviewDelegate?.showReviewPage()
    }
    
    func setData(product:ProductInfo,orderId:Int,price:Int){
        pleaseRateButton.isHidden = true
        
        if let imageUrl = URL(string:product.image?[0].src ?? "") {
            self.productImage.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "ImagePlaceHolder"), options: nil, progressBlock: nil)
        }
        else {
            self.productImage.image = #imageLiteral(resourceName: "ImagePlaceHolder")
        }
        
        productNumber.text = "Order ID: \(orderId)"
        productName.text = product.product_name ?? ""
        if let price = product.variants?[0].price{
            productPrice.text = "Total:\(Constant.CUR_Sign)\(price)"
        }
       
        if product.rating != 0{
            pleaseRateButton.isHidden = true
            if product.rating ?? 0 > 1{
                for rating in 1...Int(product.rating ?? 0.0) - 1 {
                    if rating == buttonsArray[rating - 1]?.tag{
                      
                        buttonsArray[rating - 1]?.setImage(UIImage(named: "star"), for: .normal)
                        }else{
                            buttonsArray[rating]?.setImage(UIImage(named: "starEmp"), for: .normal)
                    }
                }
            }else{
                buttonsArray[0]?.setImage(UIImage(named: "star"), for: .normal)
            }
          
        }else{
            for rating in 0...buttonsArray.count - 1
            {
                pleaseRateButton.isHidden = false
                buttonsArray[rating]?.setImage(UIImage(named: "starEmp"), for: .normal)
            }
        }
     
        
    }
}
