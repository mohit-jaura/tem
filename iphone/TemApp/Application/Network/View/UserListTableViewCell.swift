//
//  UserListTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 19/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol UserListTableCellDelegate: AnyObject {
    func didTapAcceptOrRemindButton(sender: CustomButton)
    func didTapCancelButton(sender: CustomButton)
    func didTapremoveFriend(sender:UIButton, rowSection: Int?, userId: String?)
}

class UserListTableViewCell: UITableViewCell {
    
    // MARK: Properties
    weak var delegate: UserListTableCellDelegate?
    var userId: String?
    var isCompanyUser = 0
    var section:Int?
    let grayishColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)

    // MARK: IBOutlets
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor = grayishColor.cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            backView.viewNeumorphicCornerRadius = 19.5
        }
    }
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var acceptOrRemindButton: CustomButton!
    @IBOutlet weak var cancelButton: CustomButton!
    
    // MARK: IBActions
    @IBAction func actionAcceptOrRemindTapped(_ sender: CustomButton) {
        self.delegate?.didTapAcceptOrRemindButton(sender: sender)
    }
    @IBAction func removeFriendTapped(_ sender: UIButton) {
        delegate?.didTapremoveFriend(sender: sender, rowSection: self.section, userId: userId)
        print("REmoved============")
        
    }
    
    @IBAction func cancelTapped(_ sender: CustomButton) {
        self.delegate?.didTapCancelButton(sender: sender)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        addGesture()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: Function to add gesture to redirect on user profile screen.
    func addGesture() {
        let viewProfileGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToUserProfile))
        let viewProfileGesture2 = UITapGestureRecognizer(target: self, action: #selector(navigateToUserProfile))
        viewProfileGesture.numberOfTapsRequired = 1
        self.profileImageView.addGestureRecognizer(viewProfileGesture2)
        self.userNameLabel.addGestureRecognizer(viewProfileGesture)
    }
    
    @objc func navigateToUserProfile(recognizer: UITapGestureRecognizer) {
        if isCompanyUser == 0 {
            let profileVC : ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
            if userId == "" {
                return
            }
            if let id = userId,
               !id.isEmpty,
               id != User.sharedInstance.id {
                profileVC.otherUserId = userId
            }
            UIApplication.topViewController()?.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    // MARK: Initializer
    func configureViewAt(indexPath: IndexPath, user: Friends, likesScreen:Bool = false, isSearch:Bool = false) {
        //    backView.addDoubleShadow(cornerRadius: 5, shadowRadius: 3, lightShadowColor: #colorLiteral(red: 232, green: 235, blue: 241, alpha: 1).cgColor, darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor, shadowBackgroundColor: UIColor.white.cgColor)
        userId = user.id
        isCompanyUser = user.isCompanyAccount ?? 0
        locationIcon.isHidden = true
        self.acceptOrRemindButton.row = indexPath.row
        self.acceptOrRemindButton.section = indexPath.section
        self.cancelButton.section = indexPath.section
        self.cancelButton.row = indexPath.row
        userNameLabel.text = user.fullName.uppercased()
        profileImageView.image = #imageLiteral(resourceName: "user-dummy")
        if let profilePicString = user.profilePic,
           let url = URL(string: profilePicString) {
            profileImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user-dummy"))
        }
        
        //set address of user
        if let address = user.address {
            var displayAddress = ""
            if let city = address.city,
               !city.isEmpty {
                displayAddress = city
            }
            if let state = address.state,
               !state.isEmpty {
                displayAddress = displayAddress + ", " + state
            }
            locationLabel.text = displayAddress
            if displayAddress.isEmpty {
                locationIcon.isHidden = true
            } else {
                locationIcon.isHidden = false
            }
        }
        if isSearch {
            self.setActionForSearchView(indexPath: indexPath,status:user.friendStatus ?? .other)
            underLineView.isHidden = true
        }else{
            if likesScreen {
                self.setActionForView(indexPath: indexPath,status:user.friendStatus?.rawValue ?? 0)
            }else{
                self.setActionForViewAt(indexPath: indexPath, user: user)
            }
        }
        
        if isCompanyUser == 1 {
            self.acceptOrRemindButton.isHidden = true
            self.cancelButton.isHidden = true
            self.removeButton.isHidden = true
        }
        
        if let temAdminId = UserManager.getCurrentUser()?.temAdminId {
            if user.id == temAdminId {
                self.acceptOrRemindButton.isHidden = true
                self.cancelButton.isHidden = true
                self.removeButton.isHidden = true
            }
        }
    }
    
    /// call this function to toggle the appearance of action buttons for each section
    private func setActionForViewAt(indexPath: IndexPath, user: Friends) {
        self.actionsStackView.isHidden = false
        self.removeButton.isHidden = true
        self.acceptOrRemindButton.isHidden = false
        self.cancelButton.isHidden = false
        if let section = NetworkSection(rawValue: indexPath.section) {
            switch section {
            case .pendingRequests:
                self.setActionButtonWith(icon: #imageLiteral(resourceName: "check-white"), title: AppMessages.TematesAction.accept)
            case .sentRequests:
                if let canRemind = user.canRemind {
                    if canRemind == .yes {
                        self.acceptOrRemindButton.isHidden = false
                    } else {
                        self.acceptOrRemindButton.isHidden = true
                    }
                }
                self.setActionButtonWith(icon: #imageLiteral(resourceName: "remind"), title: AppMessages.TematesAction.remind)
            case .suggestedFriends:
                removeButton.isHidden = false
                self.actionsStackView.isHidden = true
                self.acceptOrRemindButton.isHidden = true
                self.cancelButton.isHidden = true
                self.removeButton.setBackgroundImage(UIImage(named: "complete"), for: .normal)
                    self.removeButton.setTitle(AppMessages.TematesAction.add.uppercased(), for: .normal)
                self.setActionButtonWith(icon: nil, title: nil)
                //                self.setActionButtonWith(icon: #imageLiteral(resourceName: "honey-blue-border1"), title: AppMessages.TematesAction.add)
            case .friends:
                removeButton.isHidden = false
                    self.removeButton.setTitle(AppMessages.TematesAction.remove.uppercased(), for: .normal)
                self.actionsStackView.isHidden = true
                self.acceptOrRemindButton.isHidden = true
                self.cancelButton.isHidden = true
                self.setActionButtonWith(icon: nil, title: nil)
            }
        }
    }
    private func setActionForView(indexPath: IndexPath,status:Int) {
        self.removeButton.isHidden = true
        if indexPath.section == 0 {
            acceptOrRemindButton.isHidden = true
            cancelButton.isHidden = true
        }else{
            cancelButton.isHidden = true
            acceptOrRemindButton.isHidden = false
            self.removeButton.isHidden = true
            self.actionsStackView.isHidden = true
            self.acceptOrRemindButton.isEnabled = true
            self.acceptOrRemindButton.backgroundColor =  self.acceptOrRemindButton.borderColor
            self.acceptOrRemindButton.tintColor = .white
            self.acceptOrRemindButton.setTitleColor(.white, for: .normal)
            switch status {
            case 1 :
                self.acceptOrRemindButton.isEnabled = false
                self.removeButton.isHidden = true
                self.actionsStackView.isHidden = true
                self.acceptOrRemindButton.backgroundColor = .white
                self.acceptOrRemindButton.setTitleColor(self.acceptOrRemindButton.borderColor, for: .normal)
                self.acceptOrRemindButton.tintColor = self.acceptOrRemindButton.borderColor
                self.setActionButtonWith(icon: #imageLiteral(resourceName: "check-white"), title: AppMessages.TematesAction.sent)
            case 3 :
                self.setActionButtonWith(icon: #imageLiteral(resourceName: "check-white"), title: AppMessages.TematesAction.accept)
            case 0:
//                self.setActionButtonWith(icon: #imageLiteral(resourceName: "add-white"), title: AppMessages.TematesAction.add)
                removeButton.isHidden = false
                self.actionsStackView.isHidden = true
                self.acceptOrRemindButton.isHidden = true
                self.cancelButton.isHidden = true
                self.removeButton.setBackgroundImage(UIImage(named: "complete"), for: .normal)
                    self.removeButton.setTitle(AppMessages.TematesAction.add.uppercased(), for: .normal)
                self.setActionButtonWith(icon: nil, title: nil)
            default:
                break
            }
        }
    }
    private func setActionForSearchView(indexPath: IndexPath,status:FriendStatus) {
        self.backgroundColor = .clear
        outerView.backgroundColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
        backView.viewNeumorphicMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
        backView.viewNeumorphicLightShadowColor =  #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.5).cgColor
        backView.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.5).cgColor
        backView.viewNeumorphicCornerRadius = 15
        backView.shadowRadius = 15
        backView.viewNeumorphicShadowOpacity = 0.5
        
        userNameLabel.textColor = .white
        locationLabel.textColor = .white
        if indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 4 || indexPath.section == 6 {
            acceptOrRemindButton.isHidden = true
            cancelButton.isHidden = true
            removeButton.isHidden = true
        }else{
            removeButton.isHidden = true
            cancelButton.isHidden = true
            acceptOrRemindButton.isHidden = false
            self.acceptOrRemindButton.isEnabled = true
            self.acceptOrRemindButton.backgroundColor =  self.acceptOrRemindButton.borderColor
            self.acceptOrRemindButton.tintColor = .white
            self.acceptOrRemindButton.setTitleColor(.white, for: .normal)
            switch status {
            case .requestSent:
                self.acceptOrRemindButton.isEnabled = false
                self.acceptOrRemindButton.backgroundColor = .white
                self.acceptOrRemindButton.setTitleColor(self.acceptOrRemindButton.borderColor, for: .normal)
                self.acceptOrRemindButton.tintColor = self.acceptOrRemindButton.borderColor
                self.setActionButtonWith(icon: #imageLiteral(resourceName: "check-white"), title: AppMessages.TematesAction.sent)
            case .requestReceived :
                self.setActionButtonWith(icon: #imageLiteral(resourceName: "check-white"), title: AppMessages.TematesAction.accept)
            case .other:
                removeButton.isHidden = false
                self.actionsStackView.isHidden = true
                self.acceptOrRemindButton.isHidden = true
                self.cancelButton.isHidden = true
                self.removeButton.setBackgroundImage(UIImage(named: "complete"), for: .normal)
                    self.removeButton.setTitle(AppMessages.TematesAction.add.uppercased(), for: .normal)
                self.setActionButtonWith(icon: nil, title: nil)
//                self.setActionButtonWith(icon: #imageLiteral(resourceName: "add-white"), title: AppMessages.TematesAction.add)
            default:
                break
            }
        }
    }
    
    
    ///call this function to customize the appearance of action button in the cell for different section
    ///- Parameters:
    ///- icon: image to set as button image
    ///- title: title of action button
    private func setActionButtonWith(icon: UIImage?, title: String?) {
//        self.acceptOrRemindButton.setImage(icon, for: .normal)
        self.acceptOrRemindButton.setTitle(title?.uppercased(), for: .normal)
    }
}
