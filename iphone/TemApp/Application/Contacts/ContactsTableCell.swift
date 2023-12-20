//
//  ContactsTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 21/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ContactsTableCell: UITableViewCell {
    let neumorphicShadow = NumorphicShadow()
    
    // MARK: IBOutlets.
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: backView, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor, opacity:  0.8, darkColor:UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor, lightColor:UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3).cgColor, offset: CGSize(width: 2, height: 3))
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(section:ContactsSections,selectedSection:ContactsSections?) {
        titleLabel.textColor = section.color
        titleLabel.text = section.text
        headingLabel.text = section.title
        iconImageView.image = section.icon
    }
}
