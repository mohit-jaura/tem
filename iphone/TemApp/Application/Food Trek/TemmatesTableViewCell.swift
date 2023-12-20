//
//  TemmatesTableViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 07/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol AddTematesDelegate{
    func addTemates(userId: Int, isAlreadyAdded: Bool)
}
enum AddedFriends: Int, CaseIterable{
    case isAdded = 1
    case isNotAdded = 0
}

class TemmatesTableViewCell: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addButton: CustomButton!
    @IBOutlet weak var nameLAbel: UILabel!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicCornerRadius = 12
            backView.viewNeumorphicMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        }
    }
    // MARK: Variables
    var addTematesDelegate: AddTematesDelegate?
    var isFriendAdded = 0
    var isSearchedFriendSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    @IBAction func addTapped(_ sender: CustomButton) {
        
        if isFriendAdded == 0{ // 0 indicates friend not added
            if isSearchedFriendSelected{
               // addTematesDelegate?.addTemates(userId: sender.tag, isAlreadyAdded: true)
            }
            configureViews(isAdded: 1)
            addTematesDelegate?.addTemates(userId: sender.tag, isAlreadyAdded: true)
        }else{ // 1  0 indicates friend is added
            addTematesDelegate?.addTemates(userId: sender.tag, isAlreadyAdded: false)
            configureViews(isAdded: 0)
        }
    }
    func setData(friends: Friends, indexRow: Int){
        
        nameLAbel?.text = friends.fullName.uppercased()
        if let profilePic = friends.profilePic, let url = URL(string: profilePic) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "user-dummy"))
        }else{
            profileImageView.image = UIImage(named: "user-dummy")
        }
        if let  friendStatus = AddedFriends(rawValue: friends.isAdded ?? 0){
            switch friendStatus{
            case .isAdded:
                configureViews(isAdded: 1)
                addTematesDelegate?.addTemates(userId: indexRow, isAlreadyAdded: true)
            case .isNotAdded:
                configureViews(isAdded: 0)
                addTematesDelegate?.addTemates(userId: indexRow, isAlreadyAdded: false)
            }
        }
    }
    
    func configureViews(isAdded: Int){
        if isAdded == 0{
            isFriendAdded = 0
            addButton.setBackgroundImage(#imageLiteral(resourceName: "gray-honey"), for: .normal)
            addButton.setTitle("ADD", for: .normal)
        }else{
            isFriendAdded = 1
            addButton.setBackgroundImage(UIImage(named: "complete"), for: .normal)
            addButton.setTitle("ADDED", for: .normal)
        }
    }
}
