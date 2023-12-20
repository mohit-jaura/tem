//
//  WCompleteActivityVC.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-03-25.
//

import WatchKit
import Foundation

class WCompleteActivityVC: WKInterfaceController {

    // MARK: IBOutlets
    @IBOutlet weak var distanceGroup: WKInterfaceGroup!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    @IBOutlet weak var caloriesLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateGroup: WKInterfaceGroup!
    
    // MARK: IBActions
    @IBAction func completeButtonTapped() {
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "WChooseActivityVC", context: [:] as AnyObject)])
    }
    
    // MARK: Properties
    var summaryData : [UserActivity] = [UserActivity]()
    var contextDict = [String:Any]()

    // MARK: View Life Cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let conDict = context as? [String:Any] {
            if let summArr = conDict["ActivitySummaryData"] as? [UserActivity] {
                summaryData = summArr
            }
            self.contextDict = conDict
        }
        self.setDisplayOfViews()
        self.setData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
    }
    
    // MARK: Helpers
    /// hide distance group if the distance activities are nil
    private func setDisplayOfViews() {
        if self.totalDistanceActivities() > 0 {
            self.distanceGroup.setHidden(false)
        } else {
            self.distanceGroup.setHidden(true)
        }
    }
    
    private func setData() {
        self.timeLabel.setText(getDuration())
        self.distanceLabel.setText(getDistance())
        self.caloriesLabel.setText(getCalories())
        self.heartRateLabel.setText(getHeartRate())
    }
    
    private func getDuration() -> String {
        let timeConverted = self.secondsToHoursMinutesSeconds(seconds: self.totalTime())
        
        let displayTime = self.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
        return displayTime
    }
    
    private func getDistance() -> String {
        return "\(self.totalDistance().rounded(toPlaces: 2)) Miles"
    }
    
    /// return the total number of distance type activities
    private func totalDistanceActivities() -> Int {
        let distanceActivities = self.summaryData.filter { (activity) -> Bool in
            //parent distance
            //goal: either distance or open
            let selectedActivityType = activity.selectedActivityType ?? 1
            if let type = activity.type {
                if selectedActivityType == ActivityMetric.distance.rawValue {
                    if type == ActivityMetric.distance.rawValue || type == ActivityMetric.none.rawValue {
                        return true
                    }
                }
            }
            return false
        }
        return distanceActivities.count
    }
    
    /// returns the total distance by adding distance in each UserActivity object
    ///
    /// - Returns: total distance
    private func totalDistance() -> Double {
        let distanceActivities = self.summaryData.filter { (activity) -> Bool in
            //parent: distance
            //goal: either distance or open
            let selectedActivityType = activity.selectedActivityType ?? 1
            if let type = activity.type {
                if selectedActivityType == ActivityMetric.distance.rawValue {
                    if type == ActivityMetric.distance.rawValue || type == ActivityMetric.none.rawValue {
                        return true
                    }
                }
            }
            return false
        }
        let distance = distanceActivities.compactMap({$0.distance}).reduce(0, {$0 + $1})
        return distance
    }
    
    private func getCalories() -> String {
        return "\(self.totalCalories().rounded(toPlaces: 2))"
    }
    
    private func getHeartRate() -> String {
        guard let heartRate = self.summaryData.last?.heartRate,
            heartRate != 0 else {
                self.heartRateGroup.setHidden(true)
                return ""
        }
        self.heartRateGroup.setHidden(false)
        return "\(heartRate.toInt() ?? 0)"
    }
    
    /// returns the total time by adding time in each UserActivity object
    ///
    /// - Returns: total time
    private func totalTime() -> Int {
        let time = self.summaryData.compactMap({$0.timeSpent?.toInt()}).reduce(0, {$0 + $1})
        return time
    }
    
    /// returns the total calories by adding calories in each UserActivity object
    ///
    /// - Returns: total calories
    private func totalCalories() -> Double {
        let total = self.summaryData.compactMap({$0.calories}).reduce(0, {$0 + $1})
        return total
    }

    /// call this function to convert the seconds to hours, minutes and seconds format
    ///
    /// - Parameter seconds: total seconds
    /// - Returns: (hours, minutes, seconds)
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func formattedTimeWithLeadingZeros(hours: Int, minutes: Int, seconds: Int) -> String {
        // Format time vars with leading zero
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let displayTime = "\(strHours):\(strMinutes):\(strSeconds)"
        return displayTime
    }
    
    @IBAction func newActivityButtonAction() {
        if let data = Defaults.shared.get(forKey: .sharedActivityInProgress) {
            //there is already an activity in running state
            do {
                guard let data = data as? Data else {return}
                let runActData = try JSONDecoder().decode(ActivityProgressData.self, from: data)
                
                if let isPlaying = runActData.isPlaying,
                    isPlaying {
                    let difference = Date().timeIntervalSinceReferenceDate - (runActData.startTime ?? Date().timeIntervalSinceReferenceDate)
                    runActData.elapsed = difference
                    print("elapsed time is \(difference)")
                }
                
                self.contextDict["activityProgressData"] = runActData
                
                if let dates = Defaults.shared.get(forKey: .sharedUserActivityDates) as? Data {
                    let activityDates = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dates) as? [AccessDictionary]
                    self.contextDict["activityDates"] = activityDates
                }
                
                
                pushController(withName: "WInProgressActivityVC", context: contextDict)
            } catch(let error) {
                print("error: \(error)")
            }
        } else {
            pushController(withName: "WChooseActivityVC", context: nil)
        }
        
        //pushController(withName: "WChooseActivityVC", context: nil)
    }
    
    @IBAction func activityListButtonAction() {
        pushController(withName: "CompleteActivityListVC", context: self.contextDict)
    }
    
    @IBAction func homeButtonAction() {
     //  popToRootController()
        WKInterfaceController.reloadRootPageControllers(withNames: ["WHomeVC"], contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
}
