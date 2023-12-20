//
//  HomeLeaderboardTableViewCell.swift
//  TemApp
//
//  Created by Shilpa Vashisht on 20/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class HomeLeaderboardTableViewCell: UITableViewCell {

    // MARK: Properties
    private let purpleGradientColor = UIColor(red: 193.0 / 255.0, green: 23.0 / 255.0, blue: 217.0 / 255.0, alpha: 1)

    // MARK: IBOutlets
    @IBOutlet weak var imageContainerView: SSNeumorphicView! {
        didSet {
            imageContainerView.viewDepthType = .outerShadow
            imageContainerView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            imageContainerView.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1).cgColor
            imageContainerView.viewNeumorphicMainColor = UIColor.white.cgColor
            imageContainerView.viewNeumorphicShadowOpacity = 0.3
            imageContainerView.viewNeumorphicCornerRadius = imageContainerView.frame.size.width/2
            imageContainerView.viewNeumorphicShadowRadius = 3.0
            imageContainerView.viewNeumorphicShadowOffset = CGSize(width: 4, height: 0)
        }
    }
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentUserRankView: UIView!
    @IBOutlet weak var currentUserRankShadowView: UIView!
    @IBOutlet weak var currentUserRankLabel: UILabel!
    @IBOutlet weak var bgView: SSNeumorphicView! {
        didSet {
            bgView.viewDepthType = .outerShadow
            bgView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
            bgView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            bgView.viewNeumorphicCornerRadius = 4.0
            bgView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
            bgView.viewNeumorphicShadowRadius = 2.0
        }
    }
    
    @IBOutlet weak var currentUserRankInnerShadowView: SSNeumorphicView! {
        didSet {
            currentUserRankInnerShadowView.viewDepthType = .innerShadow
            currentUserRankInnerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            currentUserRankInnerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.5).cgColor
            currentUserRankInnerShadowView.viewNeumorphicMainColor = UIColor.white.cgColor
        }
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageContainerView.cornerRadius = self.imageContainerView.frame.width/2
    }
    
    // MARK: Initialize/set data
    func setLeaderboardInfo(userInfo: Friends) {
        self.rankLabel.text = "\(userInfo.accountabilityScore?.rounded(toPlaces: 1) ?? 0.0)"
        self.profileImgView.image = #imageLiteral(resourceName: "user-dummy")
        if let imageUrl = userInfo.profilePic,
            let url = URL(string: imageUrl) {
            self.profileImgView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }
        self.userNameLabel.text = userInfo.fullName
       // self.setViewDisplayForRanking(userInfo: userInfo)
    }
    
    private func setGrdient() {
        self.currentUserRankView.applyGradient(inDirection: .leftToRight, colors: [UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1).cgColor, purpleGradientColor.cgColor], locations: [0, 0.5])
    }
    
    private func setViewDisplayForRanking(userInfo: Friends) {
        if userInfo.user_id == UserManager.getCurrentUser()?.id {
            self.rankLabel.isHidden = true
            self.imageContainerView.isHidden = true
        } else {
            self.rankLabel.isHidden = false
            self.imageContainerView.isHidden = false
        }
    }
}
