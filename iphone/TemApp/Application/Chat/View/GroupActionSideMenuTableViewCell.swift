//
//  GroupActionSideMenuTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 10/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol GroupSideMenuTableCellDelegate: AnyObject {
    func didTapOnActionOnGroupSideMenu(sender: UIButton)
}

class GroupActionSideMenuTableViewCell: UITableViewCell {
    
    // MARK: Properties
    weak var delegate: GroupSideMenuTableCellDelegate?
    let neumorphicShadow = NumorphicShadow()
    
    // MARK: IBOutlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: backView, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor, opacity:  0.8, darkColor:UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor, lightColor:UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3).cgColor, offset: CGSize(width: 2, height: 3))
        }
    }
    
    // MARK: IBActions
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapOnActionOnGroupSideMenu(sender: sender)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        actionButton.backgroundColor = UIColor.clear
        label.backgroundColor = UIColor.clear
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func initialize(atSection section: GroupInfoSideMenuSection, indexPath: IndexPath, groupInfo: ChatRoom?) {
        self.actionButton.tag = section.rawValue
        self.label.text = section.title
        self.actionButton.isUserInteractionEnabled = false
        self.label.textColor = UIColor.appThemeColor
    }
}
