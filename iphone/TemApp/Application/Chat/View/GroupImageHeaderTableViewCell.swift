//
//  GroupImageHeaderTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 18/09/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class GroupImageHeaderTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var groupImageGradientView:GradientDashedLineCircularView!{
        didSet{
            groupImageGradientView.configureViewProperties(colors: [ #colorLiteral(red: 0.8862745098, green: 0.6784313725, blue: 0.3921568627, alpha: 1),#colorLiteral(red: 0.7294117647, green: 0.3647058824, blue: 0.7176470588, alpha: 1),UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0])
            groupImageGradientView.instanceWidth = 2.0
            groupImageGradientView.instanceHeight = 6.0
            groupImageGradientView.extraInstanceCount = 1
            groupImageGradientView.lineColor = UIColor.gray
            groupImageGradientView.updateGradientLocation(newLocations: [NSNumber(value: 0.35),NSNumber(value: 0.60),NSNumber(value: 0.89),NSNumber(value: 0.99)], addAnimation: false)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setImage(urlString: String?) {
        if let icon = urlString,
            let url = URL(string: icon) {
            self.iconImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "placeholder"))
        } else {
            self.iconImageView.image = #imageLiteral(resourceName: "placeholder")
        }
    }
}
