//
//  TemInfoTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 10/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class TemInfoTableViewCell: UITableViewCell {
    
    let neumorphicShadow = NumorphicShadow()
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var titleBackgroundView: SSNeumorphicView! {
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: titleBackgroundView, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor, opacity:  0.8, darkColor:UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor, lightColor:UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3).cgColor, offset: CGSize(width: 2, height: 3))
        }
    }

    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: Initializer
    func initializeAt(indexPath: IndexPath, groupInfo: ChatRoom?) {
        if let currentRow = TemInfoRow(rawValue: indexPath.row) {
            self.titleLabel.text = currentRow.title
            self.valueLabel.text = "NA"
            switch currentRow {
            case .name:
                self.valueLabel.text = groupInfo?.name
            case .desc:
                if groupInfo?.desc != nil && groupInfo?.desc != "" {
                    self.valueLabel.text = groupInfo?.desc
                }
            case .interest:
                if groupInfo?.interests != nil && groupInfo?.interests?.isEmpty == false {
                    self.valueLabel.text = groupInfo?.interests?.map({$0.name ?? ""}).joined(separator: ", ")
                }
            case .temates:
                self.valueLabel.text = "\(groupInfo?.membersCount ?? 0)"
            case .groupType:
                self.valueLabel.text = "\(groupInfo?.visibility?.name ?? "NA") "
            case .admin:
                if let adminId = groupInfo?.admin?.userId, adminId == UserManager.getCurrentUser()?.id {
                    self.valueLabel.text = "You"
                } else {
                    self.valueLabel.text = (groupInfo?.admin?.fullName ?? "")
                }
            default: break
            }
        }
    }
}
