//
//  ActivityReportTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 24/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class ActivityReportTableViewCell: UITableViewCell {

    @IBOutlet weak var originLabel: UILabel!
    // MARK: IBOutlets
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var barLabel2: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        [activityNameLabel, timeLabel, distanceLabel, caloriesLabel, barLabel, barLabel2, dateTimeLabel, originLabel].forEach { (label) in
            label?.showAnimatedSkeleton()
        }
        activityIconImageView.showAnimatedSkeleton()
        dateTimeLabel.showAnimatedSkeleton()
        // Initialization code
    }
    
    /// call this to remove the skeleton animation from all subviews of the cell once the data is loaded
    func hideSkeletonAnimation() {
        [activityNameLabel, timeLabel, distanceLabel, caloriesLabel, barLabel, barLabel2, dateTimeLabel, originLabel].forEach { (label) in
            label?.hideSkeleton()
        }
        activityIconImageView.hideSkeleton()
        dateTimeLabel.hideSkeleton()
    }

    // MARK: Initializer
    func initializeAt(indexPath: IndexPath, activityInfo: UserActivity) {
//        self.barLabel.isHidden = false
        self.activityIconImageView.isHidden = true
        self.hideSkeletonAnimation()
        activityNameLabel.text = activityInfo.name
        distanceLabel.text = "\(activityInfo.distance?.rounded(toPlaces: 2) ?? 0) Miles"
        caloriesLabel.text = "\(activityInfo.calories?.rounded(toPlaces: 2) ?? 0) Calories"
        if let origin = activityInfo.origin,
           origin != ActivityOrigin.TEM.rawValue {
            originLabel.text = origin
            originLabel.isHidden = false
        } else {
            originLabel.isHidden = true
            originLabel.text = ""
        }
        if let image = activityInfo.image,
            let url = URL(string: image) {
            self.activityIconImageView.isHidden = false
            self.activityIconImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (_) in
                self.activityIconImageView.setImageColor(color: UIColor.appThemeColor)
            }
        }
        if let totalTime = activityInfo.timeSpent?.toInt() {
            let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTime)
            
            let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
            timeLabel.text = "\(displayTime) hrs"
        }
        self.setFormattedDateTime(startTimestamp: activityInfo.startTimestamp, endTimestamp: activityInfo.endTimestamp)
    }
    
    /// set the date and time of the activity
    /// - Parameter startTimestamp: start timestamp
    /// - Parameter endTimestamp: end date timestamp
    private func setFormattedDateTime(startTimestamp: Double?, endTimestamp: Double?) {
        if let startTime = startTimestamp,
            let endTime = endTimestamp {
            let startDate = startTime.timestampInMillisecondsToDate.toString(inFormat: .activityDateDisplay) ?? ""
            let startTimeStr = startTime.timestampInMillisecondsToDate.toString(inFormat: .time) ?? ""
            let endTimeStr = endTime.timestampInMillisecondsToDate.toString(inFormat: .time) ?? ""
            let formattedDate = startDate + " " + "(\(startTimeStr) - \(endTimeStr))"
            dateTimeLabel.text = formattedDate
        } else {
            dateTimeLabel.text = ""
        }
    }
}
