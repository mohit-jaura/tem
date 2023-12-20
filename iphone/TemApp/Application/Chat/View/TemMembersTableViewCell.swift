//
//  TemMembersTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 12/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol TemMemberTableCellDelegate: AnyObject {
    func didTakeActionOnTemMember(tag: Int)
}

class TemMembersTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: TemMemberTableCellDelegate?
    let neumorphicShadow = NumorphicShadow()
    
    // MARK: IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var adminView: UIButton!
    @IBOutlet weak var shadowView: SSNeumorphicView!{
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: shadowView, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor, opacity:  0.8, darkColor:UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor, lightColor:UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3).cgColor, offset: CGSize(width: 2, height: 3))
        }
    }
    
    // MARK: IBActions
    @IBAction func actionTapped(_ sender: UIButton) {
        self.delegate?.didTakeActionOnTemMember(tag: sender.tag)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: Initializer
    func setData(memberInfo: Friends, groupInfo: ChatRoom?, indexPath: IndexPath) {
        self.actionButton.tag = indexPath.row
        self.memberNameLabel.text = memberInfo.fullName
        self.actionButton.isHidden = false
        self.adminView.isHidden = true
        if let profileUrl = memberInfo.profilePic,
            let url = URL(string: profileUrl) {
            self.profileImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        } else {
            self.profileImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        if groupInfo?.groupChatStatus == .notPartOfGroup {
            actionButton.isHidden = true
        } else {
            if memberInfo.user_id == UserManager.getCurrentUser()?.id {
                //this is the information of the current user
                self.memberNameLabel.text = "You"
                self.actionButton.isHidden = true
            }
            if memberInfo.user_id == groupInfo?.admin?.userId {
                //user is the admin of the group
                actionButton.isHidden = true
                adminView.isHidden = false
            }
            
            //check if the group is closed or open, if it is closed, only admin can add/remove participants. If it is open any of the member can add remove
            if groupInfo?.editableByMembers == false {
                if UserManager.getCurrentUser()?.id != groupInfo?.admin?.userId {
                    actionButton.isHidden = true
                }
            }
        }
    }
}
