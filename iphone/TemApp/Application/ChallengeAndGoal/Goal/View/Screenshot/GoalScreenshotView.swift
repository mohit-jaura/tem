//
//  GoalScreenshotView.swift
//  TemApp
//
//  Created by shilpa on 12/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class GoalScreenshotView: UIView {
    // MARK: IBOutlets
    @IBOutlet weak var honeyCombView: UIImageView!
    @IBOutlet weak var innerProgressView: BezierView!
    @IBOutlet weak var outerProgressView: BezierView!
    @IBOutlet weak var metricCountLabel: UILabel!
    @IBOutlet weak var metricNameLabel: UILabel!
    @IBOutlet weak var completionPercentLabel: UILabel!
    @IBOutlet weak var screenshotContentView: UIView!
    @IBOutlet weak var displayProgressView: GoalProgressDisplayView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var goalDescriptionLabel: UILabel!
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var goalDurationLabel: UILabel!
    @IBOutlet weak var goalStartDateLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var goalStatusAndTematesCountLabel: UILabel!
    // MARK: View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    private func intialize() {
        Bundle.main.loadNibNamed(GoalScreenshotView.reuseIdentifier, owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame.size = self.frame.size
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    // MARK: Initializer
    func initializeDataWith(goal: GroupActivity) {
        self.goalNameLabel.text = goal.name
        self.goalDescriptionLabel.text = goal.description
        goal.setActivityLabelAndImage(activityNameLabel, activityIconImageView)
        self.activityIconImageView.setImageColor(color: UIColor.appThemeColor)
        self.updateTimeInView(goal: goal)
        self.goalDurationLabel.text = "Length | \(goal.duration ?? "NA")"
        self.goalStartDateLabel.text = "Start Date | \(goal.startDate?.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? "NA")"
        self.setGoalStatus(goal: goal)
    }
    private func setGoalStatus(goal: GroupActivity) {
        var goalStatus = ""
        let tematesCount = goal.membersCount ?? 0
        if let status = goal.status {
            switch status {
            case .open:
                goalStatus = AppMessages.GroupActivityMessages.goalInProgress
            case .completed:
                if let goalPercent = goal.completionPercentage,
                    goalPercent >= 100 {
                    goalStatus = AppMessages.GroupActivityMessages.goalAchieved
                } else {
                    goalStatus = AppMessages.GroupActivityMessages.goalIncomplete
                }
            default:
                break
            }
        }
        self.goalStatusAndTematesCountLabel.text = goalStatus + " | " + "\(goal.getTematesLabel())"
    }
    func updateTimeInView(goal: GroupActivity) {
        self.timeLabel.text = goal.remainingTime()
    }
}
