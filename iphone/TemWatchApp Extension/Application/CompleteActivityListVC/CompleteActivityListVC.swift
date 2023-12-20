//
//  CompleteActivityListVC.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-05-06.
//

import UIKit
import WatchKit

class CompleteActivityListVC: WKInterfaceController {

    @IBOutlet weak var activityTblView: WKInterfaceTable!
    
    var summaryData : [UserActivity] = [UserActivity]()
    var contextDict = [String:Any]()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let conDict = context as? [String:Any] {
            if let summArr = conDict["ActivitySummaryData"] as? [UserActivity] {
                summaryData = summArr
            }
            self.contextDict = conDict
        }
        self.loadTableData()
    }
    
    private func loadTableData() {
        activityTblView.setNumberOfRows(summaryData.count, withRowType: "CompleteActivityRow")
        for(index,_) in summaryData.enumerated() {
            if let rowController = activityTblView.rowController(at: index) as? CompleteActivityRow {
                let activity = summaryData[index]
                
                DispatchQueue.global(qos: .default).async() {
                    if let selectedActivtyImg = activity.image {
                        let url:URL = URL(string:selectedActivtyImg)!
                         if let data:Data? = try? Data(contentsOf: url) {
                            if #available(watchOSApplicationExtension 6.0, *) {
                                let placeholder = UIImage(data: (data ?? nil)!)?.withTintColor(.black)
                                //- cellImageView is nil
                                rowController.cellImageView.setImage(placeholder)
                            } else {
                                // Fallback on earlier versions
                                let placeholder = UIImage(data: (data ?? nil)!)
                                rowController.cellImageView.setImage(placeholder)
                            }
//                        rowController.cellImageView.setImage(placeholder)
                    }
                    }
                }
                rowController.cellTitleLabel.setText("\(String(describing: activity.name ?? ""))")
                                
                if let calories = activity.calories {
                    rowController.cellCaloriesLabel.setText("\(calories) Calories")
                }
                
                if let activityTime = self.activityTime(activity: activity) {
                    rowController.cellDurationLabel.setText(activityTime)
                }
            }
        }
    }
    
    func activityTime(activity: UserActivity) -> String? {
        if let time = activity.timeSpent?.toInt() {
            let timeConverted = self.secondsToHoursMinutesSeconds(seconds: time)
            let displayTime = self.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
            //self.distOrTimMeasure = "\(displayTime) hrs"
            return displayTime
        }
        return nil
    }
    
    /// call this function to convert the seconds to hours, minutes and seconds format
    ///
    /// - Parameter seconds: total seconds
    /// - Returns: (hours, minutes, seconds)
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func formattedTimeWithLeadingZeros(hours: Int, minutes: Int, seconds: Int) -> String {
        // Format time vars with leading zero
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let displayTime = "\(strHours):\(strMinutes):\(strSeconds)"
        return displayTime
    }


}
