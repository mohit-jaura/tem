//
//  PrivacyAndSecurityTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 19/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol PrivacyAndSecurityTableCellDelegate: AnyObject {
    func setAccountPrivate(status:Bool)
}

class PrivacyAndSecurityTableCell: UITableViewCell {
    
    // MARK: Variables.
    weak var delegate:PrivacyAndSecurityTableCellDelegate?
    
    // MARK: IBOutlets.
    @IBOutlet weak var messageLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var tableSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Set Data.
    func setData(section:PrivacySections) {
        headingLabel.text = section.title
        messageLabel.text = section.message
        arrowButton.isHidden = false
        tableSwitch.isHidden = false
        messageLabelTopConstraint.constant = 0
        switch section {
        case .account:
            messageLabelTopConstraint.constant = 10
            arrowButton.isHidden = true
            if User.sharedInstance.isPrivate == Proprivate.isPrivate.rawValue {
                tableSwitch.setOn(true, animated: true)
            }else{
                tableSwitch.setOn(false, animated: true)
            }
        case .blockedUser:
            tableSwitch.isHidden = true
        case .contacts:
            tableSwitch.isHidden = true
        }
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        self.delegate?.setAccountPrivate(status: sender.isOn)
    }
    
}
