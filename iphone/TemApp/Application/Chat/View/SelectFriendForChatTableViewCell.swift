//
//  SelectFriendForChatTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 23/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class SelectFriendForChatTableViewCell: UITableViewCell {

    let neumorphicShadow = NumorphicShadow()
    
    // MARK: IBOutlets
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var nameLabel: CustomLabel!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: backView, shadowType: .innerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor, opacity:  0.5, darkColor:  UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor , lightColor:UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.3).cgColor, offset: CGSize(width: 2, height: 3))
    }
}
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
  
    }

    // MARK: Initializer
    func setData(friend: Friends?, atIndexPath indexPath: IndexPath) {
        if friend != nil {
            self.nameLabel.text = friend?.fullName
            if let urlString = friend?.profilePic,
                let url = URL(string: urlString) {
                self.profileImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }else{
                self.profileImageView.image = UIImage(named: "user-dummy")
            }
        } else {
            //set group
            self.nameLabel.text = "New Group"
        }
    }
    
    func setTemsData(tem: ChatRoom?, atIndexPath indexPath: IndexPath) {
        if tem != nil {
            self.nameLabel.text = tem?.name
            if let urlString = tem?.icon,
                let url = URL(string: urlString) {
                self.profileImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }
            else{
                self.profileImageView.image = UIImage(named: "user-dummy")
            }
        } else {
            //set group
            self.nameLabel.text = "New Group"
        }
    }
}
