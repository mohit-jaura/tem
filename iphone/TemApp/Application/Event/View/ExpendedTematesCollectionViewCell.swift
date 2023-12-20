//
//  ExpendedTematesCollectionViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 28/02/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView


class ExpendedTematesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImgVw: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var statusImgVw: UIImageView!
    @IBOutlet weak var imageShadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: imageShadowView, shadowType: .outerShadow,isType : true)
        }
    }
    
    
    
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        if isType{
            view.viewNeumorphicCornerRadius = 27.5
        } else{
            view.viewNeumorphicCornerRadius = 8
        }
        
        view.viewNeumorphicShadowRadius = 3
    }
    func configureCellForEventDetails(member:Members){
        profileImgVw.image = nil
        nameLbl.text = ""
        if let profilePic = member.profile_pic{
            if let url = URL(string:profilePic){
                profileImgVw.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }  else {
                profileImgVw.image = #imageLiteral(resourceName: "user-dummy")
            }
        }
        if let firstName = member.first_name,let lastName =  member.last_name{
            nameLbl.text = "\(firstName) \(lastName)"
        }
        if let eventInvitationStatus = EventInvitationStatus(rawValue: member.inviteAccepted ?? EventInvitationStatus.pending.rawValue){
            statusImgVw.image = eventInvitationStatus.getImage()
        }
    }
    
    func configureCellForActivityDetails(member:ActivityMember){
        profileImgVw.image = nil
        nameLbl.text = ""
        if let profilePic = member.userInfo?.profilePic{
            if let url = URL(string:profilePic){
                profileImgVw.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }  else {
                profileImgVw.image = #imageLiteral(resourceName: "user-dummy")
            }
        }
        if let firstName = member.userInfo?.firstName,let lastName =  member.userInfo?.lastName{
            nameLbl.text = "\(firstName) \(lastName)"
        }
        if member.inviteAccepted == 0{
            statusImgVw.isHidden = true
        } else{
            statusImgVw.isHidden = false
        }
       
    }
}

