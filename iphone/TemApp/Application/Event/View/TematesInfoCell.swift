//
//  TematesInfoCell.swift
//  TemApp
//
//  Created by dhiraj on 17/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol ShowTematesDelegate{
    func showMoreTemates()
}

class TematesInfoCell: UICollectionViewCell {
    @IBOutlet weak var profileImgVw: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var statusImgVw: UIImageView!
    
    @IBOutlet weak var morebutton: UIButton!
    @IBOutlet weak var imageShadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: imageShadowView, shadowType: .outerShadow,isType : true)
        }
    }
    
    @IBAction func moreTappped(_ sender: UIButton) {
        showTematesDelegate?.showMoreTemates()
    }
    
    var isShowMore = false
    var showTematesDelegate: ShowTematesDelegate?
    
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1)
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        if isType{
            view.viewNeumorphicCornerRadius = 25
        } else{
            view.viewNeumorphicCornerRadius = 8
        }
        
        view.viewNeumorphicShadowRadius = 3
    }
    func configureCell(member:Members){
       if isShowMore{
            morebutton.isHidden = false
        }else{
            morebutton.isHidden = true
        }
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
            nameLbl.text = firstName + "\n" + lastName
        }
        if let eventInvitationStatus = EventInvitationStatus(rawValue: member.inviteAccepted ?? EventInvitationStatus.pending.rawValue){
            statusImgVw.image = eventInvitationStatus.getImage()
        }
    }
}
