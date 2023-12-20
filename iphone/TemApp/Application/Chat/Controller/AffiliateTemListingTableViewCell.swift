//
//  AffiliateTemListingTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 13/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView


protocol AffiliateTemListingTableViewCellDelegate{
    func didTapOnJoinButton(indexPath:Int)
}
class AffiliateTemListingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var temImageView:UIImageView!
    @IBOutlet weak var temNameLbl:UILabel!
    @IBOutlet weak var joinButton:UIButton!
    
    private var chatRoomId: String?
    var delegate:AffiliateTemListingTableViewCellDelegate?
    let neumorphicShadow = NumorphicShadow()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBOutlet weak var groupBackgroundView: SSNeumorphicView! {
        didSet{
            groupBackgroundView.setOuterDarkShadow()
            groupBackgroundView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    @IBAction func joinBtnTapped(_ sender:UIButton){
        self.delegate?.didTapOnJoinButton(indexPath:sender.tag)
    }
    
    func setDataForAffiliateTems(group: ChatRoom,indexPath:Int) {
        temImageView.cornerRadius = temImageView.frame.height / 2
        temNameLbl.text = group.name
        chatRoomId = group.groupId ?? ""
        joinButton.tag = indexPath
        if let members = group.members{
            for member in members{
                if member.user_id == UserManager.getCurrentUser()?.id || group.adminId == UserManager.getCurrentUser()?.id ?? ""{
                    joinButton.setTitle("JOINED", for: .normal)
                    joinButton.setTitleColor(UIColor.white, for: .normal)
                    joinButton.setBackgroundImage(UIImage(named: "honeySelected"), for: .normal)
                    joinButton.isUserInteractionEnabled = false
                    break
                }else{
                    joinButton.setTitle("JOIN", for: .normal)
                    joinButton.setTitleColor(UIColor.black, for: .normal)
                    joinButton.setBackgroundImage(UIImage(named: "honeyUnselected"), for: .normal)
                    joinButton.isUserInteractionEnabled = true
                }
            }
        }
        if let icon = group.icon,
           let url = URL(string: icon) {
            self.temImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "grp-image"))
        } else {
            self.temImageView.image = #imageLiteral(resourceName: "grp-image")
        }
    }
}
