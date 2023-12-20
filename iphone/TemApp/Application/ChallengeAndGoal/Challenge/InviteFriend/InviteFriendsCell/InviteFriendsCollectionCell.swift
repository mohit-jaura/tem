//
//  InviteFriendsCollectionCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 27/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class InviteFriendsCollectionCell: UICollectionViewCell {
    
    // MARK: IBOutlets.
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setData(indexPath:IndexPath,data:Friends) {
        self.crossButton.tag = indexPath.item
        self.nameLabel.text = data.fullName
        if let imageUrl = URL(string:data.profilePic ?? "") {
            self.profileImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.profileImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    
    func setDataForChatGroup(indexPath: IndexPath, data: ChatRoom) {
        self.crossButton.tag = indexPath.item
        self.nameLabel.text = data.name
        if let imageUrl = URL(string:data.icon ?? "") {
            self.profileImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "grp-image"))
        }else{
            self.profileImageView.image = #imageLiteral(resourceName: "grp-image")
        }
    }
}
