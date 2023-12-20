//
//  ActivityLogTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 28/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
 
class ActivityLogTableViewCell: UITableViewCell {

    @IBOutlet weak var activityDateAndTimeLabel:UILabel!
    @IBOutlet weak var activityDetailLabel:UILabel!
    @IBOutlet weak var activityNameLabel:UILabel!
    @IBOutlet weak var activityImage:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func createShadowViewNew(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.black.cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.25).cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.25).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
    func configureCell(activityLog: ActivitiesLog) {
        
        let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: Int(activityLog.duration))
        
        let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
        
        let date = activityLog.date.toDate
        let dateString = getActivityDate(date: date)
        let distance = activityLog.distance.rounded(toPlaces: 2)
        let calories = activityLog.calories.rounded(toPlaces: 2)

        let name = activityLog.activityName ?? ""
     //   let imageUrl = activityLog.activityImage
        let date1 = NSDate(timeIntervalSince1970: Double(activityLog.startDate ) / 1000)
        let date2 = NSDate(timeIntervalSince1970: Double(activityLog.endDate ) / 1000)
        let dayTimePeriodFormatter = DateFormatter()
        
        dayTimePeriodFormatter.dateFormat = "hh:mm a"
        dayTimePeriodFormatter.timeZone = .current
        
        let dateStriing = dayTimePeriodFormatter.string(from: date1 as Date)
        let endTimeString = dayTimePeriodFormatter.string(from: date2 as Date)
        
        activityDetailLabel.text = "\(displayTime) HRS | \(distance) MI | \(calories) CALS"
        activityDateAndTimeLabel.text = "\(dateString)(\(dateStriing)-\(endTimeString))"
        activityNameLabel.text = "\(name.uppercased()): "
       /// setActivityImage(url: imageUrl)
    }
    
    private func getActivityDate(date:Date) -> String {
        return date.toString(inFormat: .activityDateDisplay) ?? ""
    }
    
    private func setActivityImage(url:String) {
        if let imageUrl = URL(string:url) {
            self.activityImage.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "activity"), options: nil, progressBlock: nil) { (_) in
                self.activityImage.setImageColor(color: UIColor.white)
            }
        } else {
            self.activityImage.image = #imageLiteral(resourceName: "activity")
        }
    }
}
