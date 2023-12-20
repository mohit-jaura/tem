//
//  GoalInfoSideMenuTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 21/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit
import Kingfisher

protocol JoinGoal: AnyObject {
    func loader(shouldShow: Bool)
    func showAlertMsg(message: String)
}
class GoalInfoSideMenuTableViewCell: UITableViewCell {
    // MARK: Properties...
    weak var delegate: JoinGoal?
    private(set) var activity: GroupActivity?
    var selectedIndexPath: IndexPath?
    // MARK: IBOutlets
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var tematesCountLabel: UILabel!
    @IBOutlet weak var goalMetricLabel: UILabel!
    @IBOutlet weak var goalStatusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIconLabel: UIImageView!
    @IBOutlet weak var goalImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var lineView: SSNeumorphicView! {
        didSet {
            lineView.viewDepthType = .innerShadow
            lineView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            lineView.viewNeumorphicLightShadowColor = UIColor.appThemeDarkGrayColor.withAlphaComponent(1).cgColor
            lineView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            lineView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var cellContentView: UIView!
    // MARK: IBActions
    @IBAction func joinTapped(_ sender: UIButton) {
        guard Reachability.isConnectedToNetwork() else {
            self.delegate?.showAlertMsg(message: AppMessages.AlertTitles.noInternet)
            return
        }
        if let goalId = self.activity?.id {
            delegate?.loader(shouldShow: true)
            let params = JoinActivityApiKey().toDict()
            sender.isUserInteractionEnabled = false
            DIWebLayerGoals().joinGoal(id: goalId, parameters: params, completion: {[weak self](result) in
                NotificationCenter.default.post(name: Notification.Name.activityJoined, object: nil, userInfo: ["id": goalId])
                sender.isUserInteractionEnabled = true
                self?.delegate?.loader(shouldShow: false)
                self?.activity?.isActivityJoined = result
                if let act = self?.activity, let indexPath = self?.selectedIndexPath {
                    self?.setJoinActivityStatus(activity: (act), indexPath: (indexPath))
                }
            }, failure: { [weak self](error) in
                sender.isUserInteractionEnabled = true
                self?.delegate?.loader(shouldShow: false)
                self?.delegate?.showAlertMsg(message: error.message ?? "")
            })
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
    // Initializer
    func setDataWith(goal: GroupActivity, indexPath: IndexPath) {
        self.lineView.isHidden = false
        self.selectedIndexPath = indexPath
        self.activity = goal
        self.updateRemainingTimeForActivity()
        self.goalNameLabel.text = goal.name
        self.tematesCountLabel.text = goal.getTematesLabel()
        self.setJoinActivityStatus(activity: goal, indexPath: indexPath)
        self.descriptionLabel.text = ""// goal.description
        self.setMetricsInformationFor(goal: goal)
        self.activityIconLabel.isHidden = true
        self.setGoalStatus(goal: goal)
        goal.setActivityLabelAndImage(activityNameLabel, activityIconLabel)
        if let logo = goal.image, let url = URL(string: logo) {
            goalImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "placeholder"))
        } else {
            goalImageView.image = UIImage(named: "placeholder")
        }
        setImageShape()
    }
    private func setImageShape(){
        let path = UIBezierPath(rect: goalImageView.bounds, sides: 6, lineWidth: 5, cornerRadius: 0)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        goalImageView.layer.mask = mask
    }
    private func setGoalStatus(goal: GroupActivity) {
        if let status = goal.status {
            switch status {
            case .completed:
                if let goalPercent = goal.completionPercentage,
                    goalPercent >= 100 {
                    self.goalStatusLabel.text = AppMessages.GroupActivityMessages.goalAchieved
                } else {
                    self.goalStatusLabel.text = AppMessages.GroupActivityMessages.goalIncomplete
                }
            default:
                self.goalStatusLabel.text = "\(goal.completionPercentage?.toInt() ?? 0)" + "% Complete"
            }
        }
    }
    private func setMetricsInformationFor(goal: GroupActivity) {
        self.goalMetricLabel.text = ""
        if let target = goal.target?.first,
            let metric = target.matric,
            let metricValue = Metrics(rawValue: metric),
            let value = target.value {
            switch metricValue {
            case .steps, .totalActivites:
                self.goalMetricLabel.text = "\(value.toInt() ?? 0)" + " " + metricValue.title
            case .totalActivityTime:
                if let totalTime = value.toInt() {
                    let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTime)
                    let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                    self.goalMetricLabel.text = "\(displayTime) \(metricValue.title )"
                }
            case .distance:
                self.goalMetricLabel.text = "\(value.rounded(toPlaces: 2)) Miles" + " " + metricValue.title
            default:
                self.goalMetricLabel.text = "\(value.rounded(toPlaces: 2))" + " " + metricValue.title
            }
        }
    }
    func updateRemainingTimeForActivity() {
        self.timeLabel.text = activity?.remainingTime()
    }

    private func setJoinActivityStatus(activity: GroupActivity, indexPath: IndexPath) {
        self.joinButton.tag = indexPath.row
        self.joinButton.isHidden = true
        if let status = activity.status,
            let joinedStatus = activity.isActivityJoined {
            switch status {
            case .open:
                if joinedStatus == false {
                    self.joinButton.isHidden = false
                }
            case .upcoming:
                self.joinButton.isHidden = false
                if joinedStatus == true {
                    self.joinButton.isUserInteractionEnabled = false
                    self.joinButton.setTitle(AppMessages.GroupActivityMessages.joined, for: .normal)
                } else {
                    self.joinButton.isUserInteractionEnabled = true
                    self.joinButton.setTitle(AppMessages.GroupActivityMessages.joinTitle, for: .normal)
                }
            default:
                break
            }
        }
    }
}
