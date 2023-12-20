//
//  OpenActivityTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 20/04/20.
//

import UIKit
import SSNeumorphicView
protocol ChallengeDetailDelegate {
    func redirectToChallengeDetail(indexPath:IndexPath)
}
class OpenChallengeDashboardCell: UITableViewCell {

    // MARK: Properties
    private(set) var activity: GroupActivity?
    var indexPath: IndexPath?
    var joinHandler: OnlySuccess?
    @IBOutlet weak var upcomingShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: upcomingShadowView, shadowType: .outerShadow, cornerRadius: 5, shadowRadius: 3)
        }
    }
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.white.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    // MARK: IBOutlets
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var groupActivityNameLabel: UILabel!
    @IBOutlet weak var tematesLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var leaderInfoView: UIView!
    @IBOutlet weak var leaderProfileImageView: UIImageView!
    @IBOutlet weak var leaderNameLabel: UILabel!
    @IBOutlet weak var leaderLocationLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet var metricValuesLabel: [UILabel]!
    @IBOutlet var metricTitlesLabel: [UILabel]!
    @IBOutlet var honeyCombs: [UIImageView]!
    @IBOutlet weak var metricsInfoView: UIView!
    @IBOutlet weak var joinButtonView: UIView!
    @IBOutlet weak var metricsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var separator: UIView!
    
    // MARK: IBActions
    @IBAction func joinTapped(_ sender: UIButton) {
        if let controller = (UIApplication.topViewController() as? DIBaseController) {
            if controller.isConnectedToNetwork() {
                if let activity = activity,
                   let id = activity.id {
                    let params = JoinActivityApiKey().toDict()
                    activity.isActivityJoined = true
                    DIWebLayerActivityAPI().joinActivity(isChallenge: true, id: id, parameters: params, completion: {[weak self] (_) in
                        activity.isActivityJoined = true
                        if let count = activity.membersCount {
                            activity.membersCount = count + 1
                        }
                        if let joinHandler = self?.joinHandler {
                            joinHandler()
                        }
                    }) {(error) in
                        activity.isActivityJoined = false
                        if let error = error.message {
                            controller.showAlert(message: error)
                        }
                    }
                }
            }
        }
        // update view
        self.initialize(activity: self.activity!, indexPath: self.indexPath!)
    }
    
  
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        content.addGestureRecognizer(tap)
    }
    
    @objc func onTap(_ sender: Any) {
        if let controller = (UIApplication.topViewController() as? DIBaseController) {
            if let id = self.activity?.id,
               controller.isConnectedToNetwork() {
                let vc: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                vc.challengeId = id
                vc.joinHandler = {[weak self] in
                    if let joinHandler = self?.joinHandler {
                        joinHandler()
                    }
                }
                controller.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Initialization
    func initialize(activity: GroupActivity, indexPath: IndexPath, showBottomSeparator: Bool = true) {
        self.activity = activity
        self.indexPath = indexPath
        groupActivityNameLabel.text = activity.name
        tematesLabel.text = activity.getTematesLabel()
        self.updateRemainingTimeForActivity()
        activityIconImageView.isHidden = false
        leaderLocationLabel.text = activity.leader?.address?.formatAddress()
        activity.setActivityLabelAndImage(activityNameLabel, activityIconImageView)
        metricsInfoView.isHidden = false
        self.setJoinActivityStatus(activity: activity, indexPath: indexPath)
        self.setChallengeMetricsInfo(selectedMetrics: activity.selectedMetrics ?? [], scoreboard: activity.myScore?.first ?? Leaderboard())
        separator.isHidden = !showBottomSeparator
    }
    func setCardUI(backGround color: UIColor, hideJoinButton: Bool) {
        joinButtonView.isHidden = hideJoinButton
        upcomingShadowView.setOuterDarkShadow()
        upcomingShadowView.viewNeumorphicMainColor = color.cgColor
        groupActivityNameLabel.textColor = .white
        tematesLabel.textColor = .white
        leaderLocationLabel.textColor = .white
        activityNameLabel.textColor = .white
        groupActivityNameLabel.textColor = .white
        leaderNameLabel.textColor = .white
        self.contentView.backgroundColor = .appThemeDarkGrayColor
    }

    //set chalelnge target
    private func setChallengeMetricsInfo(selectedMetrics: [Int], scoreboard: Leaderboard) {
        var totalEffortImage: UIImageView? = nil
        var totalEffortTitleLabel: UILabel? = nil
        var totalEffortValueLabel: UILabel? = nil
        for honeyComb in self.honeyCombs {
            let titleLabel = metricTitlesLabel.first(where: {$0.tag == honeyComb.tag})
            let valueLabel = metricValuesLabel.first(where: {$0.tag == honeyComb.tag})
            if let selectedMetric = selectedMetrics.first(where: {$0 == honeyComb.tag}) {
                self.setMetricsViewFor(state: true, hoenyComb: honeyComb, titleLabel: titleLabel, valueLabel: valueLabel)
                if let metric = Metrics(rawValue: selectedMetric) {
                    self.updateHoneyCombValue(forMetric: metric, scoreboard: scoreboard, valueLabel: valueLabel, titleLabel: titleLabel)
                }
            } else {
                self.setMetricsViewFor(state: false, hoenyComb: honeyComb, titleLabel: titleLabel, valueLabel: valueLabel)
                if (honeyComb.tag == Metrics.steps.rawValue) {
                    totalEffortImage = honeyComb
                    totalEffortTitleLabel = titleLabel
                    totalEffortValueLabel = valueLabel
                    self.updateHoneyCombTotalEffort(valueLabel: totalEffortValueLabel, titleLabel: totalEffortTitleLabel)
                } else {
                    self.updateHoneyCombDeafultValue(valueLabel: valueLabel, titleLabel: titleLabel)
                }
            }
        }
        if (totalEffortImage != nil && selectedMetrics.count == Metrics.selectableMetricsCount) {
            self.setMetricsViewFor(state: true, hoenyComb: totalEffortImage, titleLabel: totalEffortTitleLabel, valueLabel: totalEffortValueLabel)
        }
    }
    
    /// setting the view properties for the metrics honey comb view
    ///- Parameters:
    /// isViewSelected: the selected state, will contain either true or false
    private func setMetricsViewFor(state isViewSelected: Bool, hoenyComb: UIImageView? = nil, titleLabel: UILabel? = nil, valueLabel: UILabel? = nil) {
        if !isViewSelected {
            hoenyComb?.image = #imageLiteral(resourceName: "honey-blue-border")
            titleLabel?.textColor = UIColor.grayishBlackColor
            valueLabel?.textColor = UIColor.grayishBlackColor
        } else {
            hoenyComb?.image = #imageLiteral(resourceName: "blue")
            titleLabel?.textColor = UIColor.white
            valueLabel?.textColor = UIColor.white
        }
    }
    
    private func updateHoneyCombDeafultValue(valueLabel: UILabel?, titleLabel: UILabel?) {
        guard let tag = titleLabel?.tag,
            let metricValue = Metrics(rawValue: tag) else {
                return
        }
        titleLabel?.text = metricValue.title
        valueLabel?.text = metricValue.measuringText
    }
    
    private func updateHoneyCombTotalEffort(valueLabel: UILabel?, titleLabel: UILabel?) {
        titleLabel?.text = Metrics.totalEffortTitle
        valueLabel?.text = Metrics.totalEffortLabel
    }
    
    private func updateHoneyCombValue(forMetric metric: Metrics, scoreboard: Leaderboard, valueLabel: UILabel?, titleLabel: UILabel?) {
        titleLabel?.text = metric.title
        switch metric {
        case .steps:
            valueLabel?.text = "\(scoreboard.steps?.toInt() ?? 0)"
        case .calories:
            valueLabel?.text = "\(scoreboard.calories?.rounded(toPlaces: 2) ?? 0)"
        case .distance:
            valueLabel?.text = "\(scoreboard.distance?.rounded(toPlaces: 2) ?? 0)"
            titleLabel?.text = "Miles"
        case .totalActivites:
            valueLabel?.text = "\(scoreboard.totalActivities?.toInt() ?? 0)"
        case .totalActivityTime:
            if let totalTimeInSeconds = scoreboard.totalTime?.toInt() {
                let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTimeInSeconds)
                
                let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                valueLabel?.text = displayTime
            }
        default:
            break
        }
    }
    
    func updateRemainingTimeForActivity() {
        self.remainingTimeLabel.text = activity?.remainingTime()
    }
    
    //set the join button visibility for different activity statuses
    func setJoinActivityStatus(activity: GroupActivity, indexPath: IndexPath) {
        self.joinButton.tag = indexPath.row
        self.joinButton.isHidden = true
        joinButtonView.isHidden = true
        self.setLeaderInfo(leader: activity.leader, groupActivity: activity)
        
        if let joinedStatus = activity.isActivityJoined {
            if joinedStatus == false {
                self.joinButton.isHidden = false
                joinButtonView.isHidden = false
            }
        }
    }
    
    private func setLeaderInfo(leader: ActivityLeader?, groupActivity: GroupActivity) {
        self.leaderInfoView.isHidden = true
        self.leaderNameLabel.isHidden = true
        self.leaderLocationLabel.isHidden = true
        self.leaderProfileImageView.isHidden = true
        if let leader = leader {
            self.leaderNameLabel.isHidden = false
            self.leaderLocationLabel.isHidden = false
            self.leaderProfileImageView.isHidden = false
            self.leaderInfoView.isHidden = false
            if let profilePic = leader.profilePic,
                let url = URL(string: profilePic) {
                self.leaderProfileImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            } else {
                self.leaderProfileImageView.image = #imageLiteral(resourceName: "user-dummy")
            }
            //for individual, member is always leader but for other two types, tem can be leader also
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
