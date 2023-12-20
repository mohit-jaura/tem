//
//  ActivityInformationTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 22/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol CountDown: AnyObject {
    func countdownHasFinished(atIndex index: Int)
}

protocol ActivityInformationTableCellDelegate: AnyObject {
    func didClickOnJoinActivity(sender: UIButton)
}

class ActivityInformationTableCell: UITableViewCell {
    
    // MARK: Variables.
    weak var countdownCompleteDelegate:CountDown?
    weak var delegate: ActivityInformationTableCellDelegate?
    private(set) var activity: GroupActivity?
    var isFromMenuScreen = false
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoShadowView:SSNeumorphicView!{
        didSet{
            infoShadowView.setOuterDarkShadow()
            infoShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var lineShadowView:SSNeumorphicView!{
        didSet{
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.appThemeDarkGrayColor.withAlphaComponent(1).cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    
    // MARK: IBOutlets.
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaderInfoView: UIView!
    @IBOutlet weak var metricNameLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var fundraisingLabel: UILabel!
    @IBOutlet weak var timeDurationLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var emptyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var leaderImageView: UIImageView!
    @IBOutlet weak var leaderLocationLabel: UILabel!
    @IBOutlet weak var leaderNameLabel: UILabel!
    
    @IBOutlet weak var challangeNameLabel: UILabel!
    // MARK: IBActions
    @IBAction func joinTapped(_ sender: UIButton) {
        self.delegate?.didClickOnJoinActivity(sender: sender)
    }
    
    // MARK: UITableviewCellFunctions.
    override func awakeFromNib() {
        super.awakeFromNib()
        activityNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAllActivities)))
        activityNameLabel.isUserInteractionEnabled = true
    }
    
    @objc private func showAllActivities(_ sender: UITapGestureRecognizer) {
        if let activityTypes = self.activity?.activityTypes {
            Utility.showAlert(withTitle: "Activities", message: activityTypes.map({ x in x.activityName ?? "N/A" }).joined(separator: ", "))
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setViewForSideMenu() {
        discriptionLabel.text = ""
        emptyViewHeightConstraint.constant = 10
        leaderInfoView.isHidden = false
        descriptionBottomConstraint.constant = 0
        infoShadowView.isHidden = true
        lineShadowView.isHidden = false
        joinButton.isHidden = false
    }
   
    func setViewForDeatil() {
        emptyViewHeightConstraint.constant = 20
        leaderInfoView.isHidden = true
        descriptionBottomConstraint.constant = 20
        infoShadowView.isHidden = false
        lineShadowView.isHidden = true
        joinButton.isHidden = true
    }

    //update time
    /// call this method to update the time left or time to start for an activity
    ///
    /// - Parameter activity: reference of the challenge
    func updateRemainingTimeForActivity() {
    }

    /// set metrics information of the activity
    func setMetricsInfo(forActivity activity: GroupActivity) {
        self.metricNameLabel.text = "METRIC: \(activity.metricsFormattedString())"
    }
    
    //set the start date and end date information in the cell
    func setStartEndDateInformation(activity: GroupActivity) {
        if let startDate = activity.startDate {
            var date = startDate.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? ""
            if let endDate = activity.endDate {
                date = date + " - " + (endDate.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? "")
            }
            self.timeDurationLabel.text = "\(date)"
        }
    }
}

extension ActivityInformationTableCell {
    //data source of the cell
    func setChallengeInformation(activity: GroupActivity, indexPath: IndexPath) {
        self.activity = activity
        if isFromMenuScreen{
            self.challangeNameLabel.text = activity.name?.firstCapitalized
        }else{
            self.challangeNameLabel.text = "CHALLENGE DETAILS"
        }
        
        self.discriptionLabel.text = activity.description
        activity.setActivityLabelAndImage(activityNameLabel, activityImageView)
        self.updateRemainingTimeForActivity()
        setStartEndDateInformation(activity: activity)
        self.activityImageView.isHidden = true
        self.leaderLocationLabel.text = activity.leader?.address?.formatAddress()
        let collectedAmount = activity.fundraising?.collectedAmount ?? 0
        let totalAmount = activity.fundraising?.goalAmount ?? 0
        self.fundraisingLabel.text = "FUNDRAISING GOAL: $\(collectedAmount) of $\(totalAmount)"
        self.setJoinActivityStatus(activity: activity, indexPath: indexPath)
    }
    
    // call this function to hide the leader information view on the cell
    func showLeaderInformation(status: Bool) {
        self.leaderInfoView.isHidden = status
    }
    
    //set the join button visibility for different activity statuses
    func setJoinActivityStatus(activity: GroupActivity, indexPath: IndexPath) {
        self.joinButton.tag = indexPath.row
        self.joinButton.isHidden = true
        self.setLeaderInfo(leader: activity.leader, groupActivity: activity)
        self.leaderInfoView.isHidden = true
        
        if let status = activity.status,
            let joinedStatus = activity.isActivityJoined {
            switch status {
            case .open:
                self.setLeaderInfo(leader: activity.leader, groupActivity: activity)
                if joinedStatus == false {
                    self.leaderInfoView.isHidden = false
                    self.joinButton.isHidden = false
                }
            case .upcoming:
                self.leaderInfoView.isHidden = false
                self.leaderImageView.isHidden = true
                self.leaderNameLabel.isHidden = true
                self.leaderLocationLabel.isHidden = true
                self.joinButton.isHidden = false
                if joinedStatus == true {
                    self.joinButton.isUserInteractionEnabled = false
                    self.joinButton.setTitle(AppMessages.GroupActivityMessages.joined, for: .normal)
                } else {
                    self.joinButton.isUserInteractionEnabled = true
                    self.joinButton.setTitle(AppMessages.GroupActivityMessages.joinTitle, for: .normal)
                }
            case .completed:
                self.setLeaderInfo(leader: activity.leader, groupActivity: activity)
            }
        }
    }
    
    private func setLeaderInfo(leader: ActivityLeader?, groupActivity: GroupActivity) {
        self.leaderInfoView.isHidden = true
        self.leaderNameLabel.isHidden = true
        self.leaderLocationLabel.isHidden = true
        self.leaderImageView.isHidden = true
        if let leader = leader {
            self.leaderNameLabel.isHidden = false
            self.leaderLocationLabel.isHidden = false
            self.leaderImageView.isHidden = false
            self.leaderInfoView.isHidden = false
            if let profilePic = leader.profilePic,
                let url = URL(string: profilePic) {
                self.leaderImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            } else {
                self.leaderImageView.image = #imageLiteral(resourceName: "user-dummy")
            }
            if let challengeType = groupActivity.activityMembersType,
                challengeType == .individual {
                self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + leader.fullName
            } else {
                if let groupName = leader.groupName {
                    self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + groupName
                } else {
                    self.leaderNameLabel.text = AppMessages.GroupActivityMessages.leader + " | " + leader.fullName
                }
            }
        }
    }
}
