//
//  RetailNotificationsTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 22/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class RetailNotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationLbl:UILabel!
    @IBOutlet weak var dateLbl:UILabel!
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
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(notification:RetailNotifications){
        let date = notification.createdAt?.toDate(dateFormat: .displayDate)
        dateLbl.text = date?.toString(inFormat: .displayDate) ?? ""
        notificationLbl.text = notification.message?.firstCapitalized ?? ""
    }

}
