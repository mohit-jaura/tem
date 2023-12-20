//
//  ProductListingCollectionViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 14/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ProductListCell: UICollectionViewCell {
    
    // MARK: IBOutlets
    var wishlistTapped:IndexSelected?
    var cartTapped:IndexSelected?
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addToCartButton.shadowVer1()
        favouriteButton.shadowVer1()
    }
    
// MARK: Helper Function
    func setData(data: ProductInfo?){
        
        self.productImageView.setImg(data?.image?.first?.src)
        
        nameLabel.text = data?.product_name
        
        priceLabel.text = "\(Constant.CUR_Sign)\(data?.variants?.first?.price ?? "0")"
        
        let img = data?.isLiked ?? false ? UIImage.fav : UIImage.nofav
        
        favouriteButton.setImage(img, for: .normal)
    }
    
    @IBAction func heartAction(_ sender: Any) {
        favouriteButton.animateTapEffect(1.6)
        wishlistTapped?(IndexPath(item: favouriteButton.tag, section: 0))
    }
    
    @IBAction func addTocartAction(_ sender: Any) {
        cartTapped?(IndexPath(item: addToCartButton.tag, section: 0))

        addToCartButton.animateTapEffect(1.6)
    }
}
