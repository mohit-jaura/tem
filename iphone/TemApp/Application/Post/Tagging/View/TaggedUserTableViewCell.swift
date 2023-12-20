//
//  TaggedUserTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 17/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol TaggedUserTableCellDelegate: AnyObject {
    func didClickOnCross(sender: CustomButton)
}

class TaggedUserTableViewCell: UITableViewCell {

    // MARK: properties
    weak var delegate: TaggedUserTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var crossButton: CustomButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var backView: UIView!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: IBActions
    @IBAction func crossTapped(_ sender: CustomButton) {
        self.delegate?.didClickOnCross(sender: sender)
    }
    
    // MARK: Initializer
    func initialize(user: Friends, currentSection: Int, row: Int, listType: TagUsersListType = .pictureTagging) {
        crossButton.section = currentSection
        crossButton.row = row
        self.userNameLabel.text = user.userName
        self.firstLastNameLabel.text = user.fullName
        profilePicImageView.image = #imageLiteral(resourceName: "user-dummy")
        if let profilePicString = user.profilePic,
            let url = URL(string: profilePicString) {
            profilePicImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user-dummy"))
        }
        switch listType{
        case.commentTagging:
            self.backView.backgroundColor = .newAppThemeColor
            self.userNameLabel.textColor = .grayishBlackColor
            self.firstLastNameLabel.textColor = .white
        default:
            break
        }
    }
    
    func setTaggedUserData(data: UserTag) {
        self.lineView.isHidden = true
        self.firstLastNameLabel.text = data.displayName
        self.userNameLabel.text = ""
        profilePicImageView.image = #imageLiteral(resourceName: "user-dummy")
        if let profilePicString = data.profilePic,
            let url = URL(string: profilePicString) {
            profilePicImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user-dummy"))
        }
    }
    
    func setVisibilityOfCrossButton(shouldHide: Bool) {
        self.crossButton.isHidden = shouldHide
    }
}
