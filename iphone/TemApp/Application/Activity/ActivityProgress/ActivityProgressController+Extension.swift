//
//  ActivityProgressController+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 13/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

enum FitBitResourcePath {
    case distance
    case steps
    case calories
    case floors
    
    var path:String {
        switch self {
        case .distance:
            return "activities/distance"
        case .steps:
            return "activities/steps"
        case .calories:
            return "activities/calories"
        case .floors:
            return "activities/floors"
        }
    }
}
//https://i.diawi.com/oxer5F
//second:- https://i.diawi.com/74h73R
extension ActivityProgressController {
    
    // MARK: Function to fetch Data From FitBit.
    // MARK: Function to get distance from FitBit for Saved Dates(stop and resume time).
    @objc func getInitialDistanceFromFibit() {
        if self.count < self.activityDates.count {
            let data  = self.activityDates[count]
            self.getCompleteUrl(resourcePath: FitBitResourcePath.distance.path, startDate: data.startDate, endDate: data.endDate) { (value) in
                let result = value*0.621371
                self.distance += result.rounded(toPlaces: 2) //Double(result).rounded(toPlaces: 2)
                self.metricValueLabel.text = "\(self.distance.rounded(toPlaces: 2))"
                self.count += 1
                if self.count < self.activityDates.count {
                    self.getInitialDistanceFromFibit()
                }
            }
        } else {
            self.metricValueLabel.text = "0.0"
        }
    }
    
    // MARK: This Function will be called after 3 minutes to collect distance covered by user.
    @objc func getDistanceFromFitbit() {
        self.getCompleteUrl(resourcePath: FitBitResourcePath.distance.path, startDate: self.activityData.currentPeriodStartingDate ??  Date() , endDate: Date()) { (double) in
            let result = (double*0.621371).rounded(toPlaces: 2)
            self.tempDistance = result //Double(result).rounded(toPlaces: 2)
            self.metricValueLabel.text = "\(Double(self.distance+result))"
        }
    }
    
    // MARK: This will call when activity will stop by the user.(To collect Steps and Calories)
    func getStepsAndCaloriesFromFitbit(data:AccessTuple) {
        self.getCompleteUrl(resourcePath: FitBitResourcePath.distance.path, startDate: data.startDate, endDate: data.endDate) { (value) in
            let result = value*0.621371
            self.totalDistance += result.rounded(toPlaces: 2)
            self.getCompleteUrl(resourcePath: FitBitResourcePath.steps.path, startDate: data.startDate, endDate: data.endDate) { (value) in
                self.totalSteps += value
                self.getCompleteUrl(resourcePath: FitBitResourcePath.calories.path, startDate: data.startDate, endDate: data.endDate) { (value) in
                    self.totalCalories += value.rounded(toPlaces: 2)
                    self.count += 1
                    if self.count < self.activityDates.count {
                        self.getDataForTimeInterval()
                    } else {
                        self.totalCalories = self.totalCalories.rounded(toPlaces: 2)
                        self.updateServerToStopActivity()
                    }
                }
            }
        }
    }
    
    func getSleepTimeFromFitbit() {
        let apiUrl = "https://api.fitbit.com/1.2/user/-/sleep/date/2019-06-30/2019-07-06.json"
        let token = FitbitAuthHandler.getToken()
        let manager = FitbitAPIManager.shared()
        manager?.requestGET(apiUrl, token: token, success: { responseObject in
            if let response = responseObject {
                if let data = response["sleep"] as? [Parameters] {
                    var value : Double = 0.0
                    for (_,sample) in data.enumerated() {
                        value += sample["duration"] as? Double ?? 0.0
                        self.showAlert(message:"\(value)")
                    }
                    self.showAlert(message:"\(value)")
                }
                
            }
        }, failure: { error in
            if let response = error {
                self.handleFitBitError(error: response)
            }
        })
    }
    /*// MARK: `-Function to create FitBit Api URL.(Fitbit does not return result for 3 days according to time
     1     that is why we have to collect data for each day according to time selected by user.)*/
    @objc func getCompleteUrl(resourcePath:String,startDate:Date,endDate:Date,completion: @escaping (Double) -> Void) {
        let fitbitURL = "https://api.fitbit.com/1/user/-/\(resourcePath)/date/"
        let dayDifference = Utility.getDaysDifference(firstDate: startDate, secondDate: endDate)
        if dayDifference == 0 {
            let apiUrl = "\(fitbitURL)\(startDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/\(startDate.UTCToLocalString(inFormat: .fitbitTime))/\(endDate.UTCToLocalString(inFormat: .fitbitTime)).json"
            self.fetchData(resourcePath: resourcePath,url: apiUrl) { (value) in
                completion(value)
            }
        } else {
            var totalResponse = 0.0
            var firstDate = startDate
            var apiUrl = ""
            firstDate = firstDate.dayAfter
            for i in 1...dayDifference {
                switch i {
                case 1:
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/\(firstDate.UTCToLocalString(inFormat: .fitbitTime))/24:00.json"
                    firstDate = firstDate.dayAfter
                case dayDifference :
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/00:00/\(endDate.UTCToLocalString(inFormat: .fitbitTime)).json"
                default:
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocalString(inFormat: .fitbitDate))/today/time/00:00/\(endDate.UTCToLocalString(inFormat: .fitbitTime)).json"
                }
                firstDate = firstDate.dayAfter
                self.fetchData(resourcePath: resourcePath, url: apiUrl) { (value) in
                    totalResponse += value
                }
            }
            completion(totalResponse)
        }
    }
    
    // MARK: This function will communicate with FitBit Apis.
    func fetchData(resourcePath:String,url:String,completion: @escaping (Double) -> Void) {
        let token = FitbitAuthHandler.getToken()
        let manager = FitbitAPIManager.shared()
        manager?.requestGET(url, token: token, success: { responseObject in
            if let response = responseObject {
                if let data = response["\(resourcePath.replace("/", replacement: "-"))"] as? [Parameters] {
                    let valueDict = data[0]
                    if let value = (valueDict["value"] as? String)?.toDouble() {
                        completion(value)
                    } else {
                        completion(0.0)
                    }
                }
            }
        }, failure: { error in
            if let response = error {
                self.handleFitBitError(error: response)
            }
        })
    }
    
        // MARK: This function will handle error created by FitBit Apis.
    func handleFitBitError(error:Error) {
        self.hideLoader()
        let errorData = error._userInfo?[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
        var errorResponse: [AnyHashable : Any]? = nil
        do {
            if let errorData = errorData {
                errorResponse = try JSONSerialization.jsonObject(with: errorData, options: .allowFragments) as? [AnyHashable : Any]
            }
        } catch {
        }
        let errors = errorResponse?["errors"] as? [Any]
        let errorType = (errors?[0] as? NSObject)?.value(forKey: "errorType") as? String
        //   self.showAlert(message:"\(errorType)")
//        print("errorTypeerrorTypeerrorType \(String(describing: errorType))")
        if (errorType == fInvalid_Client) || (errorType == fExpied_Token) || (errorType == fInvalid_Token) || (errorType == fInvalid_Request) {
            // To perform login if token is expired
            //            self.showAlert(withTitle: "FiBit Login", message: "You must login to FitBit, After login Tem can fetch your health data from fitbit App", okayTitle: "Login", cancelTitle: "Cancel", okStyle: .default, okCall: {
            FitbitAuthHandler.shareManager()?.loadVars()
            FitbitAuthHandler.shareManager()?.login(self)
            //            }) {
            //            }
        } else {
            //  self.showAlert(message:errorType)
        }
    }
    
    // MARK: HealthKit Functions.
    // MARK: Function to get distance from HealthKit for Saved Dates(stop and resume time).
    @objc func getInitialDistance() {
        if self.count < self.activityDates.count {
            let data  = self.activityDates[count]
            HealthKit.instance?.getWalkingDistanceForTimePeriod(startDate: data.startDate, endDate: data.startDate, completion: { (double, error) in
                if error == nil {
                    self.distance += double
                    self.metricValueLabel.text = "\(self.distance.rounded(toPlaces: 2))"
                } else {
                    self.metricValueLabel.text = "0.0"
                }
                self.count += 1
                if self.count < self.activityDates.count {
                    self.getInitialDistance()
                }
            })
        } else {
            DispatchQueue.main.async {
                self.metricValueLabel.text = "0.0"
            }
        }
    }
    
    func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit] // 1
        formatter.unitStyle = .short
        let newDistance = distance.converted(to: .meters)
        let speedMagnitude = seconds != 0 ? newDistance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        //        print("speed.converted(to: outputUnit)",speed.converted(to: outputUnit).value.rounded(toPlaces: 2))
        return "\(speed.converted(to: outputUnit).value.rounded(toPlaces: 2))"
        //        return formatter.string(from: speed.converted(to: outputUnit))
    }
    
    // MARK: This Function will be called after 2 seconds to collect distance covered by user.
    @objc func getDistance() {
        //        HealthKit.instance?.getWalkingDistanceForTimePeriod(startDate: self.activityData.currentPeriodStartingDate ?? Date(), endDate: Date(), completion: { (double, error) in
        //            if error == nil {
        //                self.tempDistance = double//Double(double).rounded(toPlaces: 2)
        //                let totalDistanceToDisplay = (self.distance + double).rounded(toPlaces: 2)
        //                DispatchQueue.main.async {
        //                    self.metricValueLabel.text = "\(totalDistanceToDisplay) miles"
        //                }
        //            }else{
        //                DispatchQueue.main.async {
        //                    self.metricValueLabel.text = "\(self.distance.rounded(toPlaces: 2)) miles"
        //                }
        //            }
        //        })
        DispatchQueue.main.async {
            let milesDistance = appDelegate.distance.converted(to: .miles).value.rounded(toPlaces: 2)
            //            print("TravelDistanceManager.shared.distance",TravelDistanceManager.shared.distance)
            //            print("converted(to: .miles).value.rounded(toPlaces: 2)",milesDistance)
            self.tempDistance = milesDistance
 
            let totalDistanceToDisplay = (self.distance + milesDistance).rounded(toPlaces: 2)
            if totalDistanceToDisplay > self.totalDisplayedDistance {
                self.totalDisplayedDistance = totalDistanceToDisplay
            } else if  Watch_iOS_SessionManager.shared.isReachable() && Watch_iOS_SessionManager.shared.isWatchAppInstalled() {
                self.tempDistance = self.totalDisplayedDistance
                //                self.tempDistance = self.tempDistance + self.totalDisplayedDistance
            }
            //send message to watch
            let message: [String: Any] = ["request": MessageKeys.distanceFromCounterpart,
                                          "totalDistance": self.totalDisplayedDistance]
            Watch_iOS_SessionManager.shared.sendMessage(message: message, replyHandler: nil, errorHandler: nil)
            self.setAverageAndInProgressMile(distance: self.totalDisplayedDistance, totalTime: self.totalTime ?? 0)
            let paceDistance =  Measurement(value: self.totalDisplayedDistance, unit: UnitLength.miles)
            let formattedPace = self.pace(distance: paceDistance,
                                          seconds: self.totalTime?.toInt() ?? 0,
                                          outputUnit: UnitSpeed.milesPerHour)
        //    self.speedLabel.text = formattedPace
            //            print("formattedpace----->\(formattedPace)")
            if self.isDistanceTypeActivity {
                self.metricValueLabel.text = "\(self.totalDisplayedDistance)"
            } else {
                self.metricValueLabel.text = "--"
            }
            
        }
        
    }
    
    // MARK: Function to get Steps from HealthKit
    func getStepsFromHealthKit(startDate:Date,endDate:Date,completion: @escaping (_ steps:Double,_ distance:Double,_ calories:Double) -> Void) {
        if checkPermissionForSteps() {
            HealthKit.instance?.getStepsForTimePeriod(startDate: startDate, endDate: endDate, completion: { (steps, error) in
                var stepsCount = steps
                if error != nil {
                    stepsCount = 0
                }
                self.getCaloriesFromHealthKit(startDate: startDate, endDate: endDate, completion: { (distance,calories) in
                    completion(stepsCount,distance,calories)
                })
            })
        } else {
            self.getCaloriesFromHealthKit(startDate: startDate, endDate: endDate, completion: { (distance,calories) in
                completion(0,distance,calories)
            })
        }
    }
    
    // MARK: Function to get Calories from HealthKit
    func getCaloriesFromHealthKit(startDate:Date,endDate:Date,completion: @escaping (_ distance:Double,_ calories:Double) -> Void) {
        if checkPermissionForCalories() {
            HealthKit.instance?.activeEnergyBurnedForTimePeriod(startDate: startDate, endDate: endDate, completion: { (calories, error) in
                var caloriesValue = calories
                if error != nil {
                    caloriesValue = 0
                }
                self.getDistanceFromHealthKit(startDate: startDate, endDate: endDate, completion: { (distance) in
                    completion(distance,caloriesValue)
                })
            })
        } else {
            self.getDistanceFromHealthKit(startDate: startDate, endDate: endDate, completion: { (distance) in
                completion(distance,0.0)
            })
        }
    }
    
    // MARK: This Function will be called after 2 seconds to collect distance covered by user.
    @objc func getDistanceFromHealthKit(startDate:Date,endDate:Date,completion: @escaping (Double) -> Void) {
        if checkPermissionForDistance() {
            HealthKit.instance?.getWalkingDistanceForTimePeriod(startDate:startDate, endDate: endDate, completion: { (distance, error) in
                if error != nil {
                    completion(0.0)
                    return
                }
                completion(distance)
            })
        } else {
            completion(0.0)
        }
    }
    
    // MARK: This will call when activity will stop by the user.(To collect Steps and Calories)
    func getDataFromHealthKit(data:AccessTuple) {
        self.getStepsFromHealthKit(startDate: data.startDate, endDate: data.endDate) { (steps, _, _) in
            self.totalSteps += steps
            self.count += 1
            if self.count < self.activityDates.count {
                self.getDataForTimeInterval()
            } else {
                self.updateServerToStopActivity()
            }
        }
    }
    
    // MARK: Function to fetch Data one by one for each time periods.
    func getDataForTimeInterval() {
        if self.count < self.activityDates.count {
            let data  = self.activityDates[count]
            if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String , deviceType == HealthAppType.fitbit.title {
                self.getStepsAndCaloriesFromFitbit(data: data)
            } else {
                self.getDataFromHealthKit(data: data)
            }
        } else {
            self.updateServerToStopActivity()
        }
    }
    
    // MARK: This function will update server that activity has been completed by user.
    func updateServerToStopActivity() {
        
        if self.activityPausedState == .newActivityAdded {
            /*self.newUserActivityCreatedSuccessfully()
             return */
            
            //push the activity progress screen
            DispatchQueue.main.async {
                
                let activityScreen: ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
                activityScreen.activityState = .newActivityAdded
                activityScreen.combinedActivity = self.getActivityObjectToSave()
                activityScreen.isTabbarChild = self.isTabbarChild
                self.navigationController?.pushViewController(activityScreen, animated: true)
            }
            return
        }
        
        let listOfDistance = self.activityDates.map({$0.distance})
        self.totalDistance = listOfDistance.reduce(0, +)
        self.totalCalories = 0
        for value in self.activityDates {
            let dateDifference = value.endDate.timeIntervalSince(value.startDate)
            let calories = HealthKit.instance?.calculateCalories(duration: dateDifference, metValue: self.activityData.activity?.metValue ?? 0) ?? 0
            self.totalCalories += calories
        }
        
        var objCompeleteActivityData = CompeleteActivityData()
        objCompeleteActivityData.activityId = self.activityData.activity?.activityProgressId
        objCompeleteActivityData.calories = self.calculateCalories(calories: totalCalories, duration: totalTime, metValue: self.activityData.activity?.metValue)
//        objCompeleteActivityData.calories = totalCalories
        objCompeleteActivityData.steps = self.totalSteps
        objCompeleteActivityData.distanceCovered = self.calculateDistance(activity: self.activityData.activity, distance: self.totalDistance)//self.totalDistance
        objCompeleteActivityData.status = .completed
        objCompeleteActivityData.timeSpent = self.totalTime ?? 0.0
        objCompeleteActivityData.isScheduledActivity = self.activityData.isScheduled
        
       // var activitiesArray = [[String: Any]]()
        
        if let activities = CombinedActivity.currentActivityInfo() {
            for activity in activities {
                if let params = paramsFor(activity: activity).getDictionary() {
                    activitiesArray.append(params)
                }
            }
        }
        if let currentActivityParams = objCompeleteActivityData.getDictionary() {
            activitiesArray.append(currentActivityParams)
        }
        let params: [String: Any] = ["activities": activitiesArray]
        self.hideLoader()
        if let activity = self.activityData.activity {
            self.writeDataToHealthKit(activityData:activity,compeleteActivityData: objCompeleteActivityData)
        }
        self.updateToWatch(params: params, additionalActivitiesData: CombinedActivity.currentActivityInfo())
        if let reqDict = params["activities"] as? [Parameters] {
            self.navigateToActivitySummaryViewController(completeActParams: reqDict)
        } else {
            self.navigateToActivitySummaryViewController()
        }
//        DIWebLayerActivityAPI().completeActivity(parameters: params, success: { (message) in
//            self.hideLoader()
//            if let activity = self.activityData.activity {
//                self.writeDataToHealthKit(activityData:activity,compeleteActivityData: objCompeleteActivityData)
//            }
//            self.updateToWatch(params: params, additionalActivitiesData: CombinedActivity.currentActivityInfo())
//            if let reqDict = params["activities"] as? [Parameters] {
//                self.navigateToActivitySummaryViewController(completeActParams: reqDict)
//            } else {
//                self.navigateToActivitySummaryViewController()
//            }
//        }, failure: { (error) in
//            self.hideLoader()
//            self.showAlert(message: "internalServerError".localized, okayTitle: "Stay here", cancelTitle: "Go to Activities", okCall: {
//                // do nothing to stay here
//            }, cancelCall: {
//                self.resetData()
//                if self.isTabbarChild {
//                    let selectedVC:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
//                    selectedVC.isFromDashBoard = self.isFromDashBoard
//                    self.isFromDashBoard = false
//                    selectedVC.isTabbarChild = self.isTabbarChild
//                    DispatchQueue.main.async {
//                        self.navigationController?.viewControllers = [selectedVC]
//                    }
//                } else {
//                    if let _ = self.navigationController?.viewControllers.first {
//                        DispatchQueue.main.async {
//                            self.navigationController?.popViewController(animated: true)
//                        }
//                    }
//                }
//            })
//        })
    }
    
    func writeDataToHealthKit(activityData:ActivityData,compeleteActivityData:CompeleteActivityData) {
        if self.activityDates.count > 0 {
            self.activityDates[0].startDate = self.activityData.createdAt ?? Date()
        }
        HealthKit.instance?.recordWorkoutOfActivity(activityDates: self.activityDates, activityData: activityData,distance: compeleteActivityData.distanceCovered ?? 0,calories: compeleteActivityData.calories ?? 0) { (value) in
            print(value)
        }
        
        //        if self.writeDataCounter < self.activityDates.count {
        //            let value = self.activityDates[writeDataCounter]
        //            var previousEndDate : Date?
        //            if writeDataCounter-1 >= 0 {
        //                previousEndDate = self.activityDates[writeDataCounter - 1].endDate
        //            }
        //            HealthKit.instance?.recordWorkout(startDate: value.startDate, endDate: value.endDate, previousEndDate: previousEndDate, distance: value.distance, activityData: activityData){(sucess) in
        //                self.writeDataCounter += 1
        //                if self.writeDataCounter < self.activityDates.count {
        //                    self.writeDataToHealthKit(activityData:activityData)
        //                }
        //            }
        //        }
    }
    
    func getActivityObjectToSave() -> CombinedActivity {
        let combinedActivity = CombinedActivity()
        let listOfDistance = self.activityDates.map({$0.distance})
        let totalDistance = listOfDistance.reduce(0, +)
        
        var activityTotalCalories : Double = 0
        for value in self.activityDates {
            let dateDifference = value.endDate.timeIntervalSince(value.startDate)
            let calories = HealthKit.instance?.calculateCalories(duration: dateDifference, metValue: self.activityData.activity?.metValue ?? 0) ?? 0
            activityTotalCalories += calories
        }
        
        combinedActivity.distance = totalDistance//self.distance
        combinedActivity.steps = self.totalSteps
        combinedActivity.calories = self.calculateCalories(calories: activityTotalCalories, duration: totalTime, metValue: self.activityData.activity?.metValue)//self.totalCalories

        combinedActivity.activityData = self.activityData
        combinedActivity.duration = self.totalTime
        return combinedActivity
    }
    
    /// creates the parameters of an additional activity
    ///
    /// - Parameter activity: activity information
    /// - Returns: parameters
    func paramsFor(activity: CombinedActivity) -> CompeleteActivityData {
        var params = CompeleteActivityData()
        params.activityId = activity.activityData?.activity?.activityProgressId
        params.steps = activity.steps
        params.status = .completed
        params.distanceCovered = calculateDistance(activity: activity.activityData?.activity, distance: activity.distance)//activity.distance
        params.timeSpent = activity.duration
        params.calories = self.calculateCalories(calories: activity.calories, duration: activity.duration, metValue: activity.activityData?.activity?.metValue)
        
        params.isScheduledActivity = activity.activityData?.isScheduled
        return params
    }
    
    func calculateDistance(activity: ActivityData?, distance: Double?) -> Double? {
        //send distance only for distance activities
        if let selectedActivity = activity?.selectedActivityType,
            let activityType = activity?.activityType {
            if selectedActivity == ActivityMetric.distance.rawValue {
                if activityType == ActivityMetric.distance.rawValue || activityType == ActivityMetric.none.rawValue {
                    return distance
                }
            }
            return 0
        }
        return distance
    }
    
    //check if user has any linked device on "Link devices" screen, if not, then if the calories count is zero then calculate it
    func calculateCalories(calories: Double?, duration: Double?, metValue: Double?) -> Double? {
        let timeInSeconds = duration ?? 0
        let timeInHours = timeInSeconds/3600
        return Utility.calculatedCaloriesFrom(metValue: metValue ?? 0, duration: timeInHours)
    }
    
    func resetData() {
        self.totalDistance = 0
        self.totalSteps = 0
        self.totalCalories = 0
        
        Defaults.shared.remove(.isActivity)
        Defaults.shared.remove(.userActivityInProgress)
        Defaults.shared.removeActivityPaceValues()
        Defaults.shared.remove(.userActivityData)
        Defaults.shared.remove(.combinedActivities)
    }
    func generateActivityLogParams() -> [String:Any] {
        var params:[String:Any] = [:]
        params["steps"] =  ""
        params["activityName"] = self.activityData.activity?.name
        params["duration"] = self.activityData.duration
        params["distance"] = String(describing: self.activityData.distance)
        params["activityImage"] = self.activityData.activity?.image
        params["calories"] = String(describing: self.totalCalories.rounded(toPlaces:2))
        params["date"] = self.startDate?.timeStamp ?? Date().timeStamp
        params["rating"] = 1
        let endTime:String = self.getDateTime()
        params["startDate"] = self.activityStartTime.iso8601
        params["endDate"] = endTime.iso8601
        params["date"] = Date().timeStamp

        params["activityId"] = activityData.activity?.activityProgressId ?? 0
        params["activityType"] = self.activityData.activity?.selectedActivityType
        params["status"] = ActivityStateStatus.completed.rawValue
        params["isScheduled"] = self.activityData.isScheduled
        return params
    }
    func navigateToActivitySummaryViewController(completeActivityData: [CompletedActivityData]? = nil, completeActParams: [Parameters]? = nil) {
        UserManager.removeAtivityData()
        Defaults.shared.set(value: true, forKey: .isActivityRemoved)
        let obj = self.createActivitySummaryObject(steps: self.totalSteps, calories: self.totalCalories)
        if completeActivityData != nil {
            obj.calories = completeActivityData?.last?.calories //last is the current activity
        }
        if let activityParams = completeActParams?.last {
            //last is the current activity
            obj.calories = activityParams["calories"] as? Double
        }
        let activityLogParams = self.generateActivityLogParams()
        let selectedVC:ActivitySummaryViewController = UIStoryboard(storyboard: .activitysummary).initVC()
        selectedVC.activityLogData = activityLogParams
        selectedVC.activityId = self.selctedActivityId
        selectedVC.categoryType = self.categoryType
        if let activitiesData = CombinedActivity.currentActivityInfo(),
           !activitiesData.isEmpty {
            
            var summaryData = [UserActivity]()
            for (i, activityData) in activitiesData.enumerated() {
                let data = self.activitySummaryFor(activity: activityData)
                if let completeActData = completeActivityData ,
                   i < completeActData.count {
                    data.calories = completeActData[i].calories
                } else if let activityParams = completeActParams,
                          i < activityParams.count {
                    let value = activityParams[i]
                    data.calories = value["calories"] as? Double
                }
                summaryData.append(data)
            }
            summaryData.append(obj)
            selectedVC.summaryData = summaryData
            //also remove the combined activities data
            Defaults.shared.remove(.combinedActivities)
        } else {
            selectedVC.summaryData = [obj]
        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //            // your code here
        //            UserManager.removeAtivityData()
        //        }
        
        //selectedVC.userActivitySummary = obj
        
        selectedVC.isTabbarChild = self.isTabbarChild
        selectedVC.isFromDashBoard = self.isFromDashBoard
        
        selectedVC.params = activitiesArray
        selectedVC.screenFrom = self.screenFrom
        selectedVC.activityEventId = self.eventID
        if self.isTabbarChild {
            DispatchQueue.main.async {
                self.navigationController?.viewControllers = [selectedVC]
            }
        } else if screenFrom == .event {
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(selectedVC, animated: true)
            }
        } else {
            //page view controller child
            DispatchQueue.main.async {

                if let activityController = self.navigationController?.viewControllers.first {
                    self.navigationController?.viewControllers = [activityController, selectedVC]
                }
            }
        }
    }
}
// MARK: Average and in-progress mile calculation
extension ActivityProgressController {
    /// get the average and in-progress mile distance
    /// - Parameter distance: total distance
    /// - Parameter totalTime: total time in seconds
    func setAverageAndInProgressMile(distance: Double, totalTime: Double) {
        guard self.isDistanceTypeActivity else {
            return
        }
        //average mile calculation
        if totalTime != 0 && distance != 0 {
            let timeInSeconds = totalTime/distance //in seconds
            avgMile = timeInSeconds
            Defaults.shared.set(value: avgMile, forKey: .avgMile)
            //set average mile in label
//            print("avg mile time ---------> \(timeInSeconds)")
            if timeInSeconds > 0 {
                let avgMileTime = Utility.formatToMinutesAndSecondsOfMiles(totalSeconds: timeInSeconds.toInt() ?? 0)
//                print("average mile time for \(distance)miles and totaltime \(totalTime) -> \(avgMileTime)")
                DispatchQueue.main.async {
//                   self.averageMileView.isHidden = false
//                    self.averageMileLabel.text = avgMileTime
                    //                    self.averageMileGroup.setHidden(false)
                    //                    self.averageMileValueLabel.setText(avgMileTime)
                }
            }
        }
        //Inprogress mile calculation
        var currentMileDistance: Double = 0
        if distance > (Double(singleMileCount) + 1) {
            singleMileCount = Int(distance)
            lastMileCount = 0
        }
        //calculate last mile completion time
        //in case data for last mile is available use that otherwise calculate on the basis of average time
        
        if distance > 1 && ((distance - Double(lastMileCount)) > 2 || lastMileCount == 0) {
            lastMileCompletedTime = avgMile * Double(singleMileCount)
            lastMileCount = Int(distance)
            singleMileCount = Int(distance)
            singleMileCount += 1
        }
        
        if distance >= Double(singleMileCount) {
            lastMileCompletedTime = avgMile * Double(singleMileCount)
            currentMileDistance = distance - Double(singleMileCount)
            singleMileCount += 1
            lastMileCount = Int(distance)
            if currentMileDistance > 0 {
                let duration: Double = currentMileDistance*avgMile
                lastMileCompletedTime = lastMileCompletedTime - duration
            } else {
                lastMileCompletedTime = totalTime
            }
        }
        Defaults.shared.set(value: lastMileCompletedTime, forKey: .lastMileCompletedTime)
        Defaults.shared.set(value: singleMileCount, forKey: .singleMileCount)
        Defaults.shared.set(value: lastMileCount, forKey: .lastMileCount)
        let value = totalTime - lastMileCompletedTime
//        print("In progress =========> \(value)")
        if value > 0 {
            let formattedTime = Utility.formatToMinutesAndSecondsOfMiles(totalSeconds: value.toInt() ?? 0)
//            print("inprogress time for \(distance)miles and totaltime \(totalTime) -> \(formattedTime)")
/*            DispatchQueue.main.async {
                self.inProgressMileView.isHidden = false
                self.inProgressMileLabel.text = formattedTime
                //                self.inProgressMileGroup.setHidden(false)
                //                self.inProgressValueLabel.setText(formattedTime)
            }*/
        }
    }
}

// MARK: WatchiOSSessionManagerDelegate
extension ActivityProgressController: WatchiOSSessionManagerDelegate {
    func didReceiveDistanceValueFromCounterpartApp(distance: Double, activityId: String?) {
        print("total displayed distance")
        print("distance received: \(distance)")
        guard let id = self.activityData.activity?.activityProgressId,
            let watchActId = activityId,
            id == watchActId else {
                return
        }
        //distance of this activity
        if distance > self.totalDisplayedDistance {
            //show the watch distance
            self.totalDisplayedDistance = distance
            DispatchQueue.main.async {
                self.metricValueLabel.text = "\(distance.rounded(toPlaces: 2))"
            }
        }
    }
}
