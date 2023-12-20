//
//  GoalInfoTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 19/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class GoalInfoTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var tematesCountLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var goalDescriptionLabel: UILabel!
    @IBOutlet weak var infoView: UIView!

    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Initialization
    func initializeWith(goal: GroupActivity) {
        self.goalNameLabel.text = goal.name
        self.tematesCountLabel.text = goal.getTematesLabel()
        self.goalDescriptionLabel.text = goal.description
        self.updateTimeFor(goal: goal)
        goal.setActivityLabelAndImage(activityNameLabel, activityIconImageView)
    }
    // update time
    func updateTimeFor(goal: GroupActivity) {
        self.timeRemainingLabel.text = goal.remainingTime()
    }
}
