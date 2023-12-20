//
//  WeightGoalInfoTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 26/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class WeightGoalInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var goalTypeLabel: UILabel!
    @IBOutlet weak var backView: SSNeumorphicView!
    @IBOutlet weak var startWeightLbl: UILabel!
    @IBOutlet weak var endWeightLbl: UILabel!
    @IBOutlet weak var frequencyDateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var currentWeightLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: GroupActivity) {
        backView.setOuterDarkShadow()
        backView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        self.setStartEndDateInformation(activity: data)

        if let frequency = data.frequency {
            frequencyDateLbl.text = "FREQUENCY:  \(CheckInType(rawValue: frequency)?.getTitle().uppercased() ?? "N/A" )"
        }
        if data.type?.rawValue == 4{// health goal
            goalTypeLabel.text = "\(HealthInfoType(rawValue: (data.healthInfoType ?? 0) - 1)?.getTitle() ?? "") GOAL"
            let units = HealthInfoType(rawValue: (data.healthInfoType ?? 0) - 1)?.getUnitType() ?? ""
            currentWeightLbl.text = "\(data.currentHealthValue ?? 0) \(units)"
            startWeightLbl.text = "START:  \(data.currentHealthUnits ?? 0) \(units)"
            endWeightLbl.text = "END:  \(data.goalHelathUnits ?? 0) \(units)"

        } else{ // weight goal
            let lbsUnit = "LBS"
            currentWeightLbl.text = "\(data.currentHealthValue ?? 0) \(lbsUnit)"
            startWeightLbl.text = "START:  \(data.startWeight?.rounded(toPlaces: 1) ?? 0.0) \(lbsUnit)"
            endWeightLbl.text = "END:  \(data.endWeight?.rounded(toPlaces: 1) ?? 0.0) \(lbsUnit)"

            goalTypeLabel.text = "WEIGHT GOAL"
        }
    }
    private func setStartEndDateInformation(activity: GroupActivity) {
        if let startDate = activity.startDate {
            var date = startDate.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? ""
            if let endDate = activity.endDate {
                date = date + " - " + (endDate.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? "")
            }
            self.durationLbl.text = "\(date)"
        }
    }
}
