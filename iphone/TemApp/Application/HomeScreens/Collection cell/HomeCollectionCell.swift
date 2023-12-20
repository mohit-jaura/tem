//
//  HomeCollectionCell.swift
//  TemApp
//
//  Created by shivani on 01/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView


class HomeCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var badgeCountLAbel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet var outerShadowView: SSNeumorphicView!
    @IBOutlet var lightBrownCircleView: SSNeumorphicView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setShadow()
    }

    
    func setShadow() {
        imageView.cornerRadius = 8
        self.outerShadowView.viewDepthType = .outerShadow
        outerShadowView.viewNeumorphicCornerRadius = 8
        self.outerShadowView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        self.outerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.outerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor

        self.lightBrownCircleView.viewDepthType = .outerShadow
        lightBrownCircleView.viewNeumorphicCornerRadius = 8
        self.lightBrownCircleView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        self.lightBrownCircleView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.lightBrownCircleView.viewNeumorphicDarkShadowColor = UIColor.darkGray.cgColor
    }
 
}
