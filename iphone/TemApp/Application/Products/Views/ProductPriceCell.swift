//
//  ProductPriceCell.swift
//  TemApp
//
//  Created by Gurpreet Kanda on 13/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import Cosmos

class ProductPriceCell: UITableViewCell {
    private var productInfo: ProductInfo?
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var reviewView: CosmosView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initialse(_ info:ProductInfo?) {
        guard let info = info else {return}
            productInfo = info
        priceLabel.text = "\(info.variants?.first?.price ?? "0")"
        reviewView.rating = productInfo?.average_rating ?? 0
        titleLabel.text = productInfo?.product_name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
