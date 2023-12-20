//
//  DeviceControllerTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 28/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class DeviceControllerTableCell: UITableViewCell {

    // MARK: IBOutlets.
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var deviceNameLable: UILabel!
    @IBOutlet weak var backView:SSNeumorphicView!{
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor =  UIColor.white.cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            backView.viewNeumorphicCornerRadius = 10.5
            backView.viewNeumorphicShadowRadius = 0.5
            backView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
