//
//  HomeLeaderboardHeaderView.swift
//  TemApp
//
//  Created by Shilpa Vashisht on 20/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class HomeLeaderboardHeaderView: UITableViewHeaderFooterView {

    // MARK: Properties
    private let purpleGradientColor = UIColor(red: 193.0 / 255.0, green: 23.0 / 255.0, blue: 217.0 / 255.0, alpha: 1)
    
    // MARK: IBOutlets
    @IBOutlet weak var leaderTitleLabel: UILabel!
    @IBOutlet weak var youTitleLabel: UILabel!
    @IBOutlet weak var leaderNameLabel: UILabel!
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var rankInnerShadowView: SSNeumorphicView! {
        didSet {
            rankInnerShadowView.viewDepthType = .innerShadow
            rankInnerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            rankInnerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.5).cgColor
            rankInnerShadowView.viewNeumorphicMainColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var leaderImageView: UIImageView!
    @IBOutlet weak var leaderImageContainerView: SSNeumorphicView! {
        didSet {
            leaderImageContainerView.viewDepthType = .outerShadow
            leaderImageContainerView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            leaderImageContainerView.viewNeumorphicDarkShadowColor = UIColor.black.cgColor
            leaderImageContainerView.viewNeumorphicMainColor = UIColor.white.cgColor
            leaderImageContainerView.viewNeumorphicShadowOpacity = 0.3
            leaderImageContainerView.viewNeumorphicCornerRadius = leaderImageContainerView.frame.size.width/2
            leaderImageContainerView.viewNeumorphicShadowRadius = 3.0
            leaderImageContainerView.viewNeumorphicShadowOffset = CGSize(width: 4, height: 0)
        }
    }
    @IBOutlet weak var currentUserRankLabel: UILabel!
    
    // MARK: View Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: Initialize
    func initialize() {
        self.setGrdient()
    }
    
    private func addShadowsToTextLabels() {
        let shadowColor = UIColor.black.withAlphaComponent(0.4)
        let shadowRadius: CGFloat = 3
        let shadowOffset = CGSize(width: 1, height: 1)
        self.currentUserRankLabel.addShadowToText(color: shadowColor, radius: shadowRadius, opacity: 1, offset: shadowOffset)
        self.leaderTitleLabel.addShadowToText(color: shadowColor, radius: shadowRadius, opacity: 1, offset: shadowOffset)
        self.youTitleLabel.addShadowToText(color: shadowColor, radius: shadowRadius, opacity: 1, offset: shadowOffset)
    }
    
    private func setGrdient() {
        self.rankView.applyGradient(inDirection: .leftToRight, colors: [UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1).cgColor, purpleGradientColor.cgColor], locations: [0, 0.5])
    }
    
    // MARK: Data initializer
    func setDataWith(myRank: Friends?, leader: Friends?) {
        leaderImageView.image = #imageLiteral(resourceName: "user-dummy")
        if let profilePic = leader?.profilePic,
            let url = URL(string: profilePic) {
            self.leaderImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }
//        self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + (leader?.fullName ?? "")
//        self.leaderNameLabel.text = "1" + " " + (leader?.fullName ?? "")
        self.leaderNameLabel.text =  (leader?.fullName ?? "")
        self.currentUserRankLabel.text = "\(myRank?.rank ?? 0)"
        self.addShadowsToTextLabels()
    }
}
