//
//  LeftMenuTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 20/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol LeftMenuTableCellDelegate: AnyObject {
    func cellSelectionHandling(indexPath:IndexPath)
}

class LeftMenuTableCell: UITableViewCell {
    
    // MARK: Variables.
    weak var delegate:LeftMenuTableCellDelegate?
    
    // MARK: IBOutlets.
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var appVersionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(section:LeftSideMenuSections,isSettingOpen:Bool) {
        arrowImageView.isHidden = true
        appVersionLabel.text = ""
        headingLabel.text = section.title
        iconImageView.image = section.icon
        badgeView.isHidden = true
        unreadCountLabel.text = ""
        if section == .notification {
            //badgeView.isHidden = false
            if let unreadCount = UserManager.getCurrentUser()?.unreadNotiCount,
                unreadCount > 0 {
                unreadCountLabel.text = "\(unreadCount)"
                self.iconImageView.image = #imageLiteral(resourceName: "setting_notification-red")
            } else {
                unreadCountLabel.text = "0"
                iconImageView.image = section.icon
            }
        }
        if section == .settings {
            arrowImageView.isHidden = false
            if isSettingOpen {
               arrowImageView.image = #imageLiteral(resourceName: "arrowDown")
            }else{
               arrowImageView.image = #imageLiteral(resourceName: "right-arrow")
            }
        }
        if section == .version {
            appVersionLabel.text = "App Version \(BuildConfiguration.shared.appVersion)"
        }
        selectionButton.tag = section.rawValue
    }
    
    @IBAction func cellSelectionButton(_ sender: UIButton) {
        delegate?.cellSelectionHandling(indexPath: IndexPath(row: 0, section: sender.tag) )
    }
}


