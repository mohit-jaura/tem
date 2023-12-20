//
//  AddFriendCell.swift
//  VIZU
//
//  Created by dhiraj on 13/11/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit
import Kingfisher
protocol AddFriendDelegate: AnyObject {
    func friendRequestSent(button:UIButton)
    func cancelButtonPressed(index:Int)
    
}


class AddFriendCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    weak var delegate:AddFriendDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func showOrHideSkeletonView(isShow:Bool){
        if isShow{
            [imgProfile,lblName].forEach({$0?.showAnimatedSkeleton()})
        } else {
            [imgProfile,lblName].forEach({$0?.hideSkeleton()})
        }
    }
    
    
    func setData(with indexPath:IndexPath,friends :[Friends]?) {
        showOrHideSkeletonView(isShow: friends == nil ? true : false)
        setBasicDetails(indexPath: indexPath, friends: friends)
        self.btnCancel.isHidden = true
        switch indexPath.section {
        case NetworkSearchSection.friendSearch.rawValue:
            self.btnAdd.isHidden = true
        default:
            self.btnAdd.isHidden = false
        }
        setButtonVisibilty(indexPath: indexPath, friends: friends,isSearch: true)
    }
    
    func setFriendsData(with indexPath:IndexPath,friends :[Friends]?) {
        setBasicDetails(indexPath: indexPath,friends: friends)
        setButtonVisibilty(indexPath: indexPath, friends: friends)
        if User.sharedInstance.id == friends?[indexPath.row].id {
            self.btnAdd.isHidden = true
            self.btnCancel.isHidden = true
        }
    }
    
    func setBasicDetails(indexPath:IndexPath,friends :[Friends]?) {
        if indexPath.row < friends?.count ?? 0{
            if let friendObj:Friends = friends?[indexPath.row]  {
                if let fname = friendObj.firstName,let lname = friendObj.lastName,let profile = friendObj.profilePic {
                    self.lblName.text = fname + " " + lname
                    self.imgProfile.image = #imageLiteral(resourceName: "dummy")
                    if let url = URL(string: profile) {
                        self.imgProfile.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "dummy"))
                    }
                }
            }
        }
    }
    
    func setButtonVisibilty(indexPath:IndexPath,friends :[Friends]?,isSearch:Bool = false) {
        guard friends?.count ?? 0 > 0 && friends?.count ?? 0 < indexPath.row else {
            return
        }
        if let friendObj:Friends = friends?[indexPath.row] {
            var staus:Int?
            if isSearch {
                staus = friendObj.status
            } else {
                //staus = friendObj.statusWithMe
            }
            switch staus {
            case 0:
                self.btnAdd.backgroundColor = UIColor.clear
                self.btnCancel.backgroundColor = UIColor.clear
                self.btnAdd.isHidden = false
                self.btnAdd.setImage(#imageLiteral(resourceName: "users_plus"), for: .normal)
                self.btnCancel.isHidden = true
                self.btnAdd.isUserInteractionEnabled = true
            case 1:
                self.btnAdd.backgroundColor = UIColor.clear
                self.btnCancel.backgroundColor = UIColor.clear
                self.btnAdd.isHidden = false
                self.btnAdd.setImage(#imageLiteral(resourceName: "RectangleCheck"), for: .normal)
                self.btnCancel.isHidden = true
                self.btnAdd.isUserInteractionEnabled = false
            case 2:
                self.btnAdd.backgroundColor = UIColor.clear
                self.btnCancel.backgroundColor = UIColor.clear
                self.btnAdd.isHidden = false
                self.btnAdd.setImage(#imageLiteral(resourceName: "networkBlack"), for: .normal)
                self.btnCancel.isHidden = true
                self.btnAdd.isUserInteractionEnabled = false
            case 3:
                self.btnAdd.backgroundColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
                self.btnCancel.backgroundColor = .red
                self.btnAdd.isHidden = false
                self.btnAdd.setImage(#imageLiteral(resourceName: "correctwhite"), for: .normal)
                self.btnCancel.isHidden = false
                self.btnCancel.setImage(#imageLiteral(resourceName: "cancelwhite"), for: .normal)
                self.btnAdd.isUserInteractionEnabled = true
                self.btnCancel.isUserInteractionEnabled = true
            default: break
                
            }
        }
    }
    
    @IBAction func actionAddFriend(_ sender: Any) {
        
        let button:UIButton = sender as! UIButton
        self.delegate?.friendRequestSent(button: button)
    }
    @IBAction func actionCancel(_ sender: Any) {
        let button:UIButton = sender as! UIButton
        self.delegate?.cancelButtonPressed(index: button.tag)
    }
}
