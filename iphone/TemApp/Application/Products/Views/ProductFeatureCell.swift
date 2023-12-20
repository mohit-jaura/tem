//
//  ProductFeatureCell.swift
//  TemApp
//
//  Created by debut_mac on 13/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class ProductFeatureCell: UICollectionViewCell {

    @IBOutlet weak var titleLabels: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
            initialise()
    }
    func initialise() {
        containerView.layer.borderWidth  = 2
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.cornerRadius = 25
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius =  25
        containerView.clipsToBounds = true
    }
}
