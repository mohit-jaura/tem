//
//  InviteFriendsTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 27/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol UserInfoRedirectionDelegate: AnyObject {
    func didTapOnUserInformation(atRow row: Int, section: Int)
    func didTapOnAddBtn(atRow row: Int, section: Int)
}
class InviteFriendsTableCell: UITableViewCell {
    
    // MARK: Properties
    weak var delegate: UserInfoRedirectionDelegate?
    
    // MARK: IBOutlets.
    @IBOutlet weak var groupNameLabel: CustomLabel!
    @IBOutlet weak var groupMembersCountLabel: UILabel!
    @IBOutlet weak var profilePicImageView: CustomImageView!
    @IBOutlet weak var nameLabel: CustomLabel!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var groupMemberView: UIView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var addButton: CustomButton!
    @IBOutlet weak var outerShadowView: SSNeumorphicView! {
        didSet {
            outerShadowView.viewDepthType = .outerShadow
            outerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
            outerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
            outerShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            outerShadowView.viewNeumorphicCornerRadius = 4.0
            outerShadowView.viewNeumorphicShadowOpacity = 1
        }
    }
    // MARK: UITableviewCellFunctions.
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(indexPath:IndexPath,data:Friends) {
        self.groupMembersCountLabel.text = ""
        self.groupNameLabel.text = ""
        self.groupMemberView.isHidden = true
        self.nameLabel.isHidden = false
        nameLabel.text = data.fullName
        if let imageUrl = URL(string:data.profilePic ?? "") {
            self.profilePicImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.profilePicImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        setProperties(indexPath: indexPath)
        
        if data.memberExist == .yes {
            nameLabel.textColor = UIColor.gray
        }
    }
    
    func configureCellForGroup(indexPath: IndexPath, data: ChatRoom) {
        self.groupMemberView.isHidden = false
        self.nameLabel.isHidden = true
        nameLabel.text = data.name
        self.groupNameLabel.text = data.name
        self.groupMembersCountLabel.text = "\(data.membersCount ?? 0) members"
        if let imageUrl = URL(string:data.icon ?? "") {
            self.profilePicImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "grp-image"))
        } else {
            self.profilePicImageView.image = #imageLiteral(resourceName: "grp-image")
        }
        setProperties(indexPath: indexPath)
    }
    
    private func setProperties(indexPath: IndexPath) {
        self.nameLabel.row = indexPath.row
        self.nameLabel.section = indexPath.section
        self.profilePicImageView.row = indexPath.row
        self.profilePicImageView.section = indexPath.section
        self.addButton.section = indexPath.section
        self.addButton.row = indexPath.row
        //add tap gesture
        
        let tapGestureOnProfilePic = UITapGestureRecognizer(target: self, action: #selector(profilePicTapped(recognizer:)))
        self.profilePicImageView.addGestureRecognizer(tapGestureOnProfilePic)
        
        nameLabel.textColor = UIColor.white
    }
    
    //Gestures hanlders
    @objc func userNameLabelTapped(recognizer: UITapGestureRecognizer) {
        if let tappedView = recognizer.view as? CustomLabel {
            self.delegate?.didTapOnUserInformation(atRow: tappedView.row, section: tappedView.section)
        }
    }
    
    @objc func profilePicTapped(recognizer: UITapGestureRecognizer) {
        if let tappedView = recognizer.view as? CustomImageView {
            self.delegate?.didTapOnUserInformation(atRow: tappedView.row, section: tappedView.section)
        }
    }
    @IBAction func addTapped(_ sender: CustomButton) {
        self.delegate?.didTapOnAddBtn(atRow: sender.row, section: sender.section)
    }
    
}
