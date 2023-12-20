//
//  ReceiverSideCell.swift
//  TemApp
//
//  Created by Mohit Soni on 08/10/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ReceiverSideCell: UITableViewCell {

    
    @IBOutlet weak var shadowView:SSNeumorphicView!{
        didSet{
            shadowView.viewDepthType = .outerShadow
            shadowView.viewNeumorphicMainColor =  UIColor.lightGrayAppColor.cgColor
            shadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
            shadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            shadowView.viewNeumorphicCornerRadius = 8
            shadowView.viewNeumorphicShadowRadius = 3
            shadowView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
        }
    }
    
    @IBOutlet weak var messageLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
