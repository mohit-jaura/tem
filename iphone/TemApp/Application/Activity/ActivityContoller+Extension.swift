//
//  ActivityContoller+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 11/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

extension ActivityContoller {
    
    // MARK: Functions to fecth data from backend.
    // MARK: Function to get acticities from server.
    func getActivitiesFromBackend(categoryType: ActivityCategoryType.RawValue, reload:Bool = true,showLoader:Bool = true) {
        if reload {
            if showLoader {
                self.showLoader()
            }
            DIWebLayerActivityAPI().getUserActivity( success: { [weak self] (activities) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.hideLoader()
                    if reload { self.hideLoader()
                        self.allActivities = activities
                        self.activityArray =   activities.filter({$0.categoryType == categoryType}).first?.type ?? []
                        self.firstLoad = false
                    }
//                    self.tableView.showEmptyScreen( self.activityArray.count == 0 ? "You don't have any activity" : "")
//                    self.tableView.reloadData()
                }
            }) { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            }
        } else {
            self.activityArray = self.allActivities?.filter({$0.categoryType == categoryType}).first?.type ?? []
            self.activityArray.sort { firstAct, secondAct in
                return firstAct.name ?? "" < secondAct.name ?? ""
            }
            if !firstLoad {
                self.showNewActivitiesList(activities: activityArray)
            }
            self.firstLoad = false
        }
     //   self.tableView.showEmptyScreen( self.activityArray.count == 0 ? "You don't have any activity" : "")
       // self.tableView.reloadData()

    }
    
    func getScheduledEventsStatus() {
        self.performScheduledActivity = false
        self.objCreateActivity.isScheduledActivity = CustomBool.no.rawValue
        let dateTimeFormatted = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone).string(from: Date())
        let params: Parameters = ["date": dateTimeFormatted]
        print("check event status params ===========: \(params)")
        DIWebLayerEvent().checkIfEventExistsForADate(params: params, success: { (exists) in
            if exists {
                ///setting default to yes
                self.objCreateActivity.isScheduledActivity = CustomBool.yes.rawValue
            }
        }) { ( _) in
            print("error in checking scheduled events")
        }
    }
    
    // MARK: Function to createUserActivity
    func createUserActivity() {
        guard Reachability.isConnectedToNetwork() else {
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
            return
        }
        self.showLoader()
        DIWebLayerActivityAPI().createActivity(parameters: objCreateActivity.getDictionary(), success: { (data) in
            self.hideLoader()
            if self.activityState == .newActivityAdded {
                self.saveAdditionalActivityData()
            }
            self.selectedActivity.activityProgressId = data["_id"] as? String ?? ""
            var externalTypes : ExternalActivityTypes? = nil
            if let types = data["externalTypes"] as? Parameters {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: types, options: .prettyPrinted)
                    externalTypes = try JSONDecoder().decode(ExternalActivityTypes.self, from: jsonData)
                }
                catch (let error) {
                    DILog.print(items: error.localizedDescription)
                }
            }
            self.selectedActivity.externalTypes = externalTypes
            if self.activityCategoryDataType == ActivityCategoryType.nutritionAwareness.rawValue || self.selectedActivity.isBinary == 1 {
                self.completeACtivityLog()
            } else if self.activityState == .newActivityAdded {
                if let activityType = self.selectedActivity.activityType,
                   let type = ActivityMetric(rawValue: activityType),
                   type == .distance{
                    appDelegate.initalizeLocation()
                }
                self.writeDataToHealthKit()
                self.navigateToActivityProgressController()
            } else {
                let countdownController: ActivityCountdownViewController = UIStoryboard(storyboard: .activity).initVC()
                countdownController.selectedActivity = self.selectedActivity
                countdownController.isTabbarChild = self.isTabbarChild
                countdownController.activityId = self.selectedActivity.id
                countdownController.categoryType = self.activityCategoryDataType
                countdownController.screenFrom = self.screenFrom
                countdownController.eventID = self.eventID ?? ""
                DispatchQueue.main.async {
                    if self.isTabbarChild {
                        self.navigationController?.viewControllers = [countdownController]
                    } else if self.screenFrom == .event{
                        // DispatchQueue.main.async {
                        self.navigationController?.pushViewController(countdownController, animated: true)
                        //   }
                    }else {
                        self.navigationController?.pushViewController(countdownController, animated: true)
                    }
                }
            }
            //            self.updateActivityStatusToWatchApp()
            //            self.navigateToActivityProgressController()
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    
    
    // In case of Nutrition awareness and Mental strength only. No need to send distance, calories, tym etc for next screen
    func completeACtivityLog(){
        var activityLogData:[String:Any] = [:]
        activityLogData["steps"] = "0.0"
        activityLogData["rating"] = 1
        activityLogData["categoryType"] = activityCategoryDataType
        activityLogData["distanceCovered"] = 0.0
        activityLogData["timeSpent"] = 0.0
        activityLogData["calories"] = 0.0
        activityLogData["duration"] =  "00:00:00"
        activityLogData["activityImage"] = self.selectedActivity.image//string
        activityLogData["status"] = 2
        activityLogData["activityType"] = 0
        activityLogData["distance"] = "0.0"
        activityLogData["activityName"] = self.selectedActivity.name
        activityLogData["activityId"] = self.selectedActivity.activityProgressId ?? 0//string
        activityLogData["date"] = Date().timeStamp
        let params3: [String: Any] = ["activities": [activityLogData]]
        DIWebLayerActivityAPI().completeActivity(parameters: params3, success: { (_) in
            self.hideLoader()
            self.showAlert(withTitle: "Activity has been logged sucessfully!", okayTitle: "Ok")
        }, failure: { (msg) in
            self.showAlert(withTitle: msg.message ?? "", okayTitle: "Ok")
            self.hideLoader()
        })
    }
    
    
    func writeDataToHealthKit(){
        if let activityData = combinedActivity?.activityData?.activity{
            let activityDates = self.deserializeDictionary(dictionary: UserManager.getUserActivityDates() ?? [AccessDictionary](), distanceDict: UserManager.getUserActivityDistance() ?? [AccessDistance]())
            
            let listOfDistance = activityDates.map({$0.distance})
            let totalDistance = listOfDistance.reduce(0, +)
            var totalCalories : Double = 0
            for value in activityDates{
                let dateDifference = value.endDate.timeIntervalSince(value.startDate)
                let calories = HealthKit.instance?.calculateCalories(duration: dateDifference, metValue: activityData.metValue ?? 0) ?? 0
                totalCalories += calories
            }
            if let activityType = self.selectedActivity.activityType,
               let type = ActivityMetric(rawValue: activityType),
               type == .distance{
                appDelegate.initalizeLocation()
            }
            HealthKit.instance?.recordWorkoutOfActivity(activityDates: activityDates, activityData: activityData,distance:totalDistance,calories: totalCalories) { (value) in
                print(value)
                UserManager.removeStatsOfAtivityData()
            }
            //            if self.writeDataCounter < activityDates.count {
            //                let value = activityDates[writeDataCounter]
            //                print("Current value--->\(value),    counter---->\(writeDataCounter)")
            //                var previousEndDate : Date?
            //                if writeDataCounter-1 >= 0 {
            //                    print("previous Workout Value--->\(activityDates[writeDataCounter - 1]), counter---->\(writeDataCounter - 1)")
            //
            //                    previousEndDate = activityDates[writeDataCounter - 1].endDate
            //                }
            //                HealthKit.instance?.recordWorkout(startDate: value.startDate, endDate: value.endDate, previousEndDate: previousEndDate, distance: value.distance, activityData: activityData){(sucess) in
            //                    self.writeDataCounter += 1
            //                    if self.writeDataCounter < activityDates.count {
            //                        self.writeDataToHealthKit()
            //                    }
            //                }
            //            }
            
            //            if self.writeDataCounter+1 == activityDates.count{
            //                UserManager.removeStatsOfAtivityData()
            //            }
        }
        
    }
    
    
    func deserializeDictionary(dictionary: [AccessDictionary],distanceDict: [AccessDistance]) -> [AccessTuple] {
        var array : [AccessTuple] = [AccessTuple]()
        for (_,data) in dictionary.enumerated() {
            array.append(AccessTuple(
                data[startDateKey] ?? Date(),
                data[endDateKey] ?? Date(),
                0
            ))
        }
        for (index,data) in distanceDict.enumerated() {
            array[index].distance = data[distanceKey] ?? 0
        }
        
        return array
    }
    
    private func saveAdditionalActivityData() {
        //saving to defaults
        guard let combinedActivity = self.combinedActivity else {
            return
        }
        var activitiesArray = [CombinedActivity]()
        if let activities = CombinedActivity.currentActivityInfo() {
            var combinedActivities = activities
            combinedActivities.append(combinedActivity)
            activitiesArray = combinedActivities
        } else {
            activitiesArray.append(combinedActivity)
        }
        if !activitiesArray.isEmpty {
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(activitiesArray) {
                self.combinedActivityEncodedData = encodedData
                Defaults.shared.set(value: encodedData, forKey: .combinedActivities)
            }
        }
    }
    
    func navigateToActivityProgressController() {
        Defaults.shared.set(value: true, forKey: .isActivity)
        let selectedVC:ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
        selectedVC.activityData = self.getActivityProgressObject()
        selectedVC.isFromDashBoard = self.isFromDashBoard
        selectedVC.isTabbarChild = isTabbarChild
        DispatchQueue.main.async {
            if self.isTabbarChild {
                self.navigationController?.viewControllers = [selectedVC]
            } else if self.activityState == .newActivityAdded {
                if var viewControllers = self.navigationController?.viewControllers {
                    // remove current screen in stack
                    _ = viewControllers.popLast()
                    // replace progress screen
                    _ = viewControllers.popLast()
                    viewControllers.append(selectedVC)
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
                else {
                    self.navigationController?.pushViewController(selectedVC, animated: true)
                }
            } else {
                self.navigationController?.pushViewController(selectedVC, animated: true)
            }
        }
        
    }
    
    func getActivityProgressObject() -> ActivityProgressData {
        /*let objActivityProgressData:ActivityProgressData = ActivityProgressData()
        objActivityProgressData.activity = self.selectedActivity
        objActivityProgressData.createdAt = Date()
        objActivityProgressData.elapsed = 0
        objActivityProgressData.startTime = 0
        if self.performScheduledActivity {
            //setting this to 2, for the activity which is scheduled and is going to be completed
            objActivityProgressData.isScheduled = 2
        }
        objActivityProgressData.saveEncodedInformation()
        return objActivityProgressData */
        
        let objActivityProgressData:ActivityProgressData = ActivityProgressData()
        objActivityProgressData.activity = self.selectedActivity
        objActivityProgressData.createdAt = Date()
        objActivityProgressData.elapsed = 0
        objActivityProgressData.startTime = 0
        do {
            let progressDataToSend = objActivityProgressData
            progressDataToSend.startTime = Date().timeIntervalSinceReferenceDate
            progressDataToSend.isPlaying = true
            let data =  try JSONEncoder().encode(objActivityProgressData)
            objActivityProgressData.saveEncodedInformation()
            
            let userActivityData = try JSONEncoder().encode(objActivityProgressData.activity)
            //in watch app
            var infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
                                                 "request": MessageKeys.createdNewActivityOnPhone,
                                                 MessageKeys.userActivityData: userActivityData]
            if self.activityState == .newActivityAdded,
               let encodedCombinedData = self.combinedActivityEncodedData {
                infoDictToPass[MessageKeys.additionalActivityAdded] = encodedCombinedData
            }
            Watch_iOS_SessionManager.shared.updateApplicationContext(data: infoDictToPass)
        } catch {
            
        }
        return objActivityProgressData
    }
}
