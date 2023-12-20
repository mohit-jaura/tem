//
//  AccountTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 19/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol AccountTableCellDelegate: AnyObject {
    func seeOnlyTematesFeedSwitchTapped(sender: UISwitch)
    func noInternetConnection()
}

class AccountTableCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: AccountTableCellDelegate?
    
    // MARK: IBOutlets.
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var arrowButtonb: UIButton!
    
    // MARK: IBActions
    @IBAction func switchTapped(_ sender: UISwitch) {
        if Reachability.isConnectedToNetwork() {
            self.delegate?.seeOnlyTematesFeedSwitchTapped(sender: sender)
        } else {
            if sender.isOn {
                sender.setOn(false, animated: true)
            } else {
                sender.setOn(true, animated: true)
            }
            self.delegate?.noInternetConnection()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Initializer
    func initialize(atIndexPath indexPath: IndexPath) {
        if let section = AccountSections(rawValue: indexPath.row) {
            self.headingLabel.text = section.title
            if section == .seeTematesPostsOption {
                self.switchBtn.isHidden = false
                self.arrowButtonb.isHidden = true
                
                if let algoType = UserManager.getCurrentUser()?.algoOption {
                    if algoType == .new {
                        self.switchBtn.setOn(false, animated: false)
                    } else {
                        self.switchBtn.setOn(true, animated: false)
                    }
                } else {
                    self.switchBtn.setOn(false, animated: false)
                }
            } else {
                self.arrowButtonb.isHidden = false
                self.switchBtn.isHidden = true
                self.switchBtn.setOn(false, animated: false)
            }
        }
    }
}
