//
//  FriendRequestTableViewCell.swift
//  VIZU
//
//  Created by shubam on 06/10/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

protocol FriendRequestDelegate: AnyObject {
    func acceptRequest(section :Int,row:Int)
    func rejectRequest(section :Int,row:Int)
}

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var acceptRejectRqstStackView: UIStackView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var btnAccept: CustomButton!
    @IBOutlet weak var btnReject: CustomButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    weak var delegate:FriendRequestDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showSkeletionOnCell(){
        imgAvatar.showAnimatedSkeleton()
        labelName.showAnimatedSkeleton()
    }
    
    func hideSkeleton(){
        imgAvatar.hideSkeleton()
        labelName.hideSkeleton()
    }
    
    func configureCell(section:Int){
        if let friendRequestCell = NetworkSection(rawValue: section){
            switch friendRequestCell{
            case NetworkSection.friends:
                acceptRejectRqstStackView.isHidden = true
                pointsLabel.isHidden = false
                self.btnReject.isHidden = true
                self.btnAccept.isHidden = true
            case NetworkSection.sentRequests:
                acceptRejectRqstStackView.isHidden = false
                btnAccept.isHidden = true
                self.btnReject.isHidden = false
                self.pointsLabel.isHidden = true
            default:
                acceptRejectRqstStackView.isHidden = false
                pointsLabel.isHidden = true
                self.btnReject.isHidden = false
                self.btnAccept.isHidden = false
            }
        }
    }
    
    func setData(arrFriends:[Friends],indexPath:IndexPath) {
        self.btnAccept.row = indexPath.row
        self.btnAccept.section = indexPath.section
        self.btnReject.section = indexPath.section
        self.btnReject.row = indexPath.row
        if indexPath.row < arrFriends.count {
            self.hideSkeleton()
             let friend:Friends = arrFriends[indexPath.row]
             if let fname = arrFriends[indexPath.row].firstName, let lname = arrFriends[indexPath.row].lastName {
                    self.labelName?.text = fname + " " + lname
                }
             else {
                self.labelName.text = ""
            }
             self.pointsLabel.text = arrFriends[indexPath.row].points?.stringValue
             if let profileUrl = friend.profilePic,let url = URL(string: profileUrl) {
                    self.imgAvatar.kf.setImage(with:url, placeholder: #imageLiteral(resourceName: "dummy"))
             } else {
                self.imgAvatar.image =  #imageLiteral(resourceName: "dummy")
            }
        }
    }
    
    @IBAction func actionAccept(_ sender: Any) {
        
        let button:CustomButton = sender as! CustomButton
        self.delegate?.acceptRequest(section: button.section, row: button.row)
    }
    
    @IBAction func actionReject(_ sender: Any) {
        
        let button:CustomButton = sender as! CustomButton
        self.delegate?.rejectRequest(section: button.section, row: button.row)
        
    }
    
}
