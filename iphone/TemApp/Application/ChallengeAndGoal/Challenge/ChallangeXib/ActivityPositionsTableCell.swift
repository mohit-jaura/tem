//
//  ActivityPositionsTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 22/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ActivityPositionsTableCell: UITableViewCell {
    
    // MARK: Properties
    weak var delegate: ChallengeJoinTableCellDelegate?
    
    @IBOutlet weak var infoView: UIView!
    // MARK: IBOutlets.
    @IBOutlet weak var leaderNameLabel: UILabel!
    @IBOutlet weak var LoginUserNameLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var emptyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var backShadowView: SSNeumorphicView!{
        didSet{
            backShadowView.setOuterDarkShadow()
            backShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    @IBOutlet weak var descriptionBackView: SSNeumorphicView!{
        didSet{
            descriptionBackView.setOuterDarkShadow()
            descriptionBackView.viewDepthType = .innerShadow
            descriptionBackView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        
        }
    }
    // MARK: IBActions
    @IBAction func joinTapped(_ sender: UIButton) {
        self.delegate?.didClickOnJoin(sender: sender)
    }
    
    // MARK: UITableViewCell Functions.
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Initializer
    func setData(activity: GroupActivity, indexPath: IndexPath) {
        descriptionTextView.text = activity.description
        if let leader = activity.leader {
//            for individual, member is always leader but for other two types, tem can be leader also
            if let challengeType = activity.activityMembersType,
                challengeType == .individual {
                self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + leader.fullName
            } else {
                if let groupName = leader.groupName,
                    !groupName.isEmpty {
                    self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + groupName
                } else {
                    self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + leader.fullName
                }
            }
        }
        self.setCurrentUserInfo(userRank: activity.myScore?.first?.rank)
        if let isJoined = activity.isActivityJoined {
            if !isJoined {
                self.joinButton.isHidden = false
                LoginUserNameLabel.text = "You"
            } else {
                self.joinButton.isHidden = true
            }
        }
    }
    
    private func setCurrentUserInfo(userRank: Int?) {
        var place = ""
        guard let userRank = userRank else {
            place = "0 place"
            return
        }
        
        let stringRank = String(describing: userRank)
        if stringRank.hasSuffix("1"){
            place = "\(userRank)st place"
        }
        else if stringRank.hasSuffix("2"){
            place = "\(userRank)nd place"
        }
        else if stringRank.hasSuffix("3"){
            place = "\(userRank)rd place"
        }
        else{
            place = "\(userRank)th place"
        }
        LoginUserNameLabel.text = "You | " + place
    }
    
    func setDataWith(myRank: Friends?, leader: Friends?) {
        self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + (leader?.fullName ?? "")
        self.setCurrentUserInfo(userRank: myRank?.rank)
    }
    
}
