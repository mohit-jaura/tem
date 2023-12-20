//
//  ProductReviewTableCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 23/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import Cosmos
class ProductReviewTableCell: UITableViewCell {
    
    // MARK: @IBOutlet
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet  var ratingButtons: [UIButton]!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
            backView.viewNeumorphicCornerRadius = 8
        }
    }
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
      
    }
    func setData(products: Products?){
        nameLabel.text = products?.name?.firstUppercased ?? ""
        if let imageUrl = URL(string:products?.image[0].src ?? "") {
            self.productImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "ImagePlaceHolder"), options: nil, progressBlock: nil)
        }
        else {
            self.productImageView.image = #imageLiteral(resourceName: "ImagePlaceHolder")
        }
        ratingView.isUserInteractionEnabled = false
        ratingView.rating = Double(products?.rating ?? 0)
        //        if products.rating != 0{
//            for rating in 1...products.rating{
//                if rating == ratingButtons[rating - 1].tag{
//
//                    ratingButtons[rating - 1].setImage(UIImage(named: "star"), for: .normal)
//                    }else{
//                        ratingButtons[rating].setImage(UIImage(named: "starEmp"), for: .normal)
//                }
//            }
//        }else{
//            for rating in 0...ratingButtons.count - 1
//            {
//                ratingButtons[rating ].setImage(UIImage(named: "starEmp"), for: .normal)
//            }
//
//        }
      
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
