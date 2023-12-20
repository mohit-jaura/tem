//
//  ProductSettingsTableViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 17/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ProductSettingsTableViewCell: UITableViewCell {

    // MARK: IBOutlet
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel! 
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
