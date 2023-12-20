//
//  NotificationTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 20/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol  NotificationTableCellDelegate: AnyObject {
    func handleTap(index:Int,status:Bool)
}

class NotificationTableCell: UITableViewCell {
    
    // MARK: Variables.
    weak var delegate:NotificationTableCellDelegate?
    
    // MARK: IBOutlets.
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var cellSwitch: UIButton!
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
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setData(section:NotificationSettingSections,indexPath:IndexPath) {
        headingLabel.text = section.title
        cellSwitch.tag = indexPath.row
        cellSwitch.isUserInteractionEnabled = true
        if let section = NotificationSettingSections(rawValue: indexPath.row) {
            switch section {
            case .push:
                if User.sharedInstance.pushNotificationStatus == pushStatus.on.rawValue {
//                    cellSwitch.setOn(true, animated: true)
                    cellSwitch.isSelected = true
                }else{
//                    cellSwitch.setOn(false, animated: true)
                    cellSwitch.isSelected = false
                }
            case .calender:
                if User.sharedInstance.pushNotificationStatus == pushStatus.off.rawValue || User.sharedInstance.calenderNotificationStatus == pushStatus.off.rawValue{
//                    cellSwitch.isUserInteractionEnabled = false
                    cellSwitch.isSelected = false
                }
                else {
//                    cellSwitch.setOn(true, animated: true)
                    cellSwitch.isSelected = true
                }
            }
        }
    }
    
    @IBAction func switchButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        delegate?.handleTap(index: sender.tag,status:sender.isSelected)
    }
    
}
