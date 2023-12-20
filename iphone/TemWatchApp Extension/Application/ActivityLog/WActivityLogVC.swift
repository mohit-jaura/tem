//
//  WActivityLogVC.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-04-02.
//

import UIKit
import WatchKit
class WActivityLogVC: WKInterfaceController {
    private var totalActivityReport: UserActivityReport?
    
    
    @IBOutlet weak var tblView: WKInterfaceTable!
    @IBOutlet weak var activityIndicatorGroup: WKInterfaceGroup!
    @IBOutlet weak var activityIndicatorImageView: WKInterfaceImage!
    
    var tblArr = ["Total Activities","Total Activity Type","Accountability Index","Average Duration","Average Distance","Average Calories","Average Daily Steps","Average Sleep"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        tblView.setHidden(true)
        activityIndicatorGroup.setHidden(false)
        
        activityIndicatorImageView.setImageNamed("Activity")
        activityIndicatorImageView.startAnimatingWithImages(in: NSRange(location: 0,
                                                                        length: 30), duration: 5, repeatCount: 0)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.getActivityLog()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        print("Deactivated ==========")
        super.didDeactivate()
        self.activityIndicatorImageView.stopAnimating()
    }
    
    
    private func loadTableData() {
        
        self.activityIndicatorGroup.setHidden(true)
        self.tblView.setHidden(false)
        
        tblView.setNumberOfRows(tblArr.count, withRowType: "WActivityLogRow")
        
        for(index,_) in tblArr.enumerated() {
            if let rowController = tblView.rowController(at: index) as? WActivityLogRow {
                rowController.cellTitleLabel.setText("\(tblArr[index])")
                if index == 0 {
                    //totalActivities
                    rowController.cellTextLabel.setText("\(self.totalActivityReport?.totalActivities?.value?.toInt() ?? 0)")
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.totalActivities?.flag)
                }
                else if index == 1 {
                    //Total Activity Type
                    rowController.cellTextLabel.setText("\(self.totalActivityReport?.typesOfActivities?.count ?? 0)")
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.typesOfActivities?.flag)
                }
                else if index == 2 {
                    //AccountabilityIndex
                    rowController.cellTextLabel.setText("\((totalActivityReport?.accountAccountability?.value?.rounded(toPlaces: 2).formatted ?? "0") + "%")")
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.accountAccountability?.flag)
                    
                }
                else if index == 3 {
                    //Average Duration
                    rowController.cellTextLabel.setText("\(totalActivityReport?.averageDuration?.value?.rounded().toInt() ?? 0)" + " mins")
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.averageDuration?.flag)
                }
                else if index == 4 {
                    //Average Distance
                    rowController.cellTextLabel.setText("\((totalActivityReport?.averageDistance?.value?.rounded(toPlaces: 2).formatted ?? "0") + " miles")")
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.averageDistance?.flag)
                }
                else if index == 5 {
                    //Average Calories
                    rowController.cellTextLabel.setText("\((totalActivityReport?.averageCalories?.value?.rounded(toPlaces: 2).formatted ?? "0") + " cals")")
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.averageCalories?.flag)
                }
                else if index == 6 {
                    //Average Daily Steps
                    rowController.cellTextLabel.setText("\(totalActivityReport?.averageDailySteps?.value?.rounded().toInt() ?? 0)")
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.averageDailySteps?.flag)
                    
                }
                else if index == 7 {
                    //Average Sleep
                    self.formatAndSetSleepTime(label: rowController.cellTextLabel)
                    self.setColorOf(label: rowController.cellTextLabel, forFlag: totalActivityReport?.averageSleep?.flag)
                }
            }
        }
    }
    
    //change the color of label according to the flag status
    func setColorOf(label: WKInterfaceLabel, forFlag flag: ReportFlag?) {
        if let flag = flag {
            switch flag {
            case .lowStats:
                label.setTextColor(#colorLiteral(red: 1, green: 0.4117647059, blue: 0.3803921569, alpha: 1))
            case .highStats:
                label.setTextColor(#colorLiteral(red: 0.3137254902, green: 0.7843137255, blue: 0.4705882353, alpha: 1))
            case .sameStats:
                label.setTextColor(.gray)
            }
        } else {
            label.setTextColor(.gray) //same stats color
        }
    }
    
    //format sleep time in hours, minutes and seconds and display
    func formatAndSetSleepTime(label: WKInterfaceLabel) {
        let sleepTimeInHours = totalActivityReport?.averageSleep?.value ?? 0
        let sleepTimeInSeconds = sleepTimeInHours * 3600
        
        if let time = sleepTimeInSeconds.toInt() {
            let timeConverted = self.secondsToHoursMinutesSeconds(seconds: time)
            
            var formattedTime = ""
            if timeConverted.hours != 0 {
                formattedTime += "\(timeConverted.hours) hrs"
            }
            if timeConverted.minutes != 0 {
                if !formattedTime.isEmpty {
                    formattedTime += " "
                }
                formattedTime += "\(timeConverted.minutes) mins"
            }
            if timeConverted.seconds != 0 {
                if !formattedTime.isEmpty {
                    formattedTime += " "
                }
                formattedTime += "\(timeConverted.seconds) seconds"
            }
            
            if formattedTime.isEmpty {
                label.setText("0")
            } else {
                label.setText(formattedTime)
            }
        }
    }
    
    /// - Parameter seconds: total seconds
    /// - Returns: (hours, minutes, seconds)
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    }
    
    // MARK: Api Call
    private func getActivityLog() {
        ActivityNetworkLayer().getUserScore(fullReport: true, completion: { (report) in
            self.totalActivityReport = report
            DispatchQueue.main.async {
                self.loadTableData()
            }
        }) { (error) in
            //- Handle error
            self.activityIndicatorGroup.setHidden(true)
            self.showAlert(message: error.message ?? "Something went wrong!") {
                self.pop()
            }
        }
    }
}

