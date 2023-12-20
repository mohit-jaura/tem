//
//  OpenGaolDashboardCell.swift
//  TemApp
//
//  Created by shilpa on 21/04/20.
//

import UIKit
import SSNeumorphicView
class OpenGoalDashboardCell: UITableViewCell {

    // MARK: Properties
    private(set) var activity: GroupActivity? = nil
    var indexPath: IndexPath? = nil
    
    // MARK: IBOutlets
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var activtiyNameLabel: UILabel!
    @IBOutlet weak var tematesCountLabel: UILabel!
    @IBOutlet weak var goalMetricLabel: UILabel!
    @IBOutlet weak var goalPercentLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var activityIconLabel: UIImageView!
    @IBOutlet weak var goalProgressDisplayView: GoalProgressDisplayView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinButtonView: UIView!
    @IBOutlet weak var separator: UIView!
    var joinHandler: OnlySuccess?
    // MARK: IBActions
    @IBAction func joinTapped(_ sender: UIButton) {
        if let controller = (UIApplication.topViewController() as? DIBaseController) {
            if controller.isConnectedToNetwork() {
                if let activity = activity,
                   let id = activity.id {
                    let params = JoinActivityApiKey().toDict()
                    activity.isActivityJoined = true
                    DIWebLayerActivityAPI().joinActivity(isChallenge: false, id: id, parameters: params, completion: {(_) in
                        activity.isActivityJoined = true
                        if let count = activity.membersCount {
                            activity.membersCount = count + 1
                        }
                        if let joinHandler = self.joinHandler {
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
        goalProgressDisplayView.setViewsLayoutForOpenGoalView()
        self.layoutIfNeeded()
    }
    
    @objc func onTap(_ sender: Any) {
        if let controller = (UIApplication.topViewController() as? DIBaseController) {
            if let id = self.activity?.id,
               controller.isConnectedToNetwork() {
                let vc: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                vc.goalId = id
                vc.selectedGoalName = activity?.name
                vc.activeGoalsJoinHandler = { [weak self] in
                    if let joinHandler = self?.joinHandler {
                        joinHandler()
                    }
                }
                controller.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBOutlet weak var upcomingShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: upcomingShadowView, shadowType: .outerShadow, cornerRadius: 5, shadowRadius: 3)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
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
    // MARK: Initialization
    func initialize(activity: GroupActivity, indexPath: IndexPath, showBottomSeparator: Bool = true) {
        self.activity = activity
        self.indexPath = indexPath
        goalNameLabel.text = activity.name
        tematesCountLabel.text = activity.getTematesLabel()
        self.goalPercentLabel.text = "Status | \(activity.completionPercentage?.toInt() ?? 0)" + "% Complete"
        self.updateRemainingTimeForActivity()
        activityIconLabel.isHidden = false
        activity.setActivityLabelAndImage(activtiyNameLabel, activityIconLabel)
        self.setJoinActivityStatus(activity: activity, indexPath: indexPath)
        self.setMetricsInformationFor(goal: activity)
        self.goalProgressDisplayView.setBezierProperties(padding: 4.0, focusSize: 6.0, lineWidth: 3.0)
        self.goalProgressDisplayView.completionPercentage = activity.completionPercentage
        self.goalProgressDisplayView.achievedValue = activity.currentAchievedValue
        if let metric = activity.target?.first?.matric,
            let metricParam = Metrics(rawValue: metric) {
            self.goalProgressDisplayView.metric = metricParam
        }
        self.goalProgressDisplayView.updateCompletionPercentage()
        self.goalProgressDisplayView.updateProgressInstant()
        separator.isHidden = !showBottomSeparator
    }
    func setCardUI(backGround color: UIColor, hideJoinButton: Bool) {
        joinButtonView.isHidden = hideJoinButton
        upcomingShadowView.setOuterDarkShadow()
        upcomingShadowView.viewNeumorphicMainColor = color.cgColor
        goalNameLabel.textColor = .white
        activtiyNameLabel.textColor = .white
        tematesCountLabel.textColor = .white
        goalMetricLabel.textColor = .white
        goalPercentLabel.textColor = .white
        self.contentView.backgroundColor = .appThemeDarkGrayColor
    }
    
    func updateRemainingTimeForActivity() {
        self.durationLabel.text = activity?.remainingTime()
    }

    //set goal target
    private func setMetricsInformationFor(goal: GroupActivity) {
        self.goalMetricLabel.text = ""
        if let target = goal.target?.first,
            let metric = target.matric,
            let metricValue = Metrics(rawValue: metric),
            let value = target.value {
            let initialText = "Goal | "
            switch metricValue {
            case .steps, .totalActivites:
                self.goalMetricLabel.text = initialText + "\(value.toInt() ?? 0)" + " " + metricValue.title
            case .totalActivityTime:
                if let totalTime = value.toInt() {
                    let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTime)
                    
                    let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                    self.goalMetricLabel.text = initialText + "\(displayTime) \(metricValue.title )"
                }
            case .distance:
                self.goalMetricLabel.text = initialText + "\(value.rounded(toPlaces: 2)) Miles" + " " + metricValue.title
            default:
                self.goalMetricLabel.text = initialText + "\(value.rounded(toPlaces: 2))" + " " + metricValue.title
            }
        }
    }
    
    //set the join button visibility for different activity statuses
    func setJoinActivityStatus(activity: GroupActivity, indexPath: IndexPath) {
        self.joinButton.tag = indexPath.row
        self.joinButtonView.isHidden = true
        if let joinedStatus = activity.isActivityJoined,
            joinedStatus == false {
            self.joinButtonView.isHidden = false
        }
    }
}
