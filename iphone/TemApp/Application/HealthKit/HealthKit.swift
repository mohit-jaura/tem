//
//  HealthKit.swift
//  TemApp
//
//  Created by Egor Shulga on 15.03.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation
import HealthKit

var healthKitAutorized = "NotificationIdentifier"

class HealthKit {
    class var instance: HealthKit? {
        struct Singleton { static let instance = HKHealthStore.isHealthDataAvailable() ? HealthKit() : nil }
        return Singleton.instance
    }
    
    public let healthStore: HKHealthStore = HKHealthStore()

    private var stepsObserverQuery: HKObserverQuery?
    var workoutObserverQuery: HKObserverQuery?
    var healthSyncEnabled: Bool
    var askedForSyncEnable: Bool
    var isImportInProgress: Bool = false
    
    init() {
        healthSyncEnabled = Defaults.shared.get(forKey: .healthKitSyncEnabled) as? Bool ?? false
        askedForSyncEnable = Defaults.shared.get(forKey: .askedForHealthKitSyncEnable) as? Bool ?? false
    }
    
    func requestAuthorization(completion: @escaping () -> Void) {
        healthStore.requestAuthorization(toShare: [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ], read: [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!,
        ]) { (success, error) in
            if success {
                NotificationCenter.default.post(name: Notification.Name(healthKitAutorized), object: nil)
                completion()
            } else {
                print(error.debugDescription)
            }
        }
    }

    func getStepsForTimePeriod(startDate:Date, endDate:Date, completion: @escaping (Double,Error?) -> Void) {
        let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepCount, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0,error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()),error)
        }
        self.healthStore.execute(query)
    }
    
    func stopObservingStepsCount() {
        if let query = self.stepsObserverQuery {
            healthStore.stop(query)
        }
    }
    
    func getWalkingDistance(forSpecificDate:Date, completion: @escaping (Double,Error?) -> Void) {
        let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let (start, end) = self.getWholeDate(date: forSpecificDate)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceWalkingRunning, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0,error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.mile()).rounded(toPlaces: 2),error)
        }
        self.healthStore.execute(query)
    }
    
    func getWalkingDistanceForTimePeriod(startDate:Date, endDate:Date, completion: @escaping (Double,Error?) -> Void) {
        let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceWalkingRunning, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0,error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.mile()).rounded(toPlaces: 2),error)
        }
        self.healthStore.execute(query)
    }
    
    func activeEnergyBurnedForTimePeriod(startDate:Date, endDate:Date, completion: @escaping (Double,Error?) -> Void) {
        let activeEnergyBurned = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: activeEnergyBurned, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0,error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.kilocalorie()).rounded(toPlaces: 2),error)
        }
        self.healthStore.execute(query)
    }
    
    func retrieveSleepAnalysis(startDate:Date, endDate:Date, completion: @escaping (Double,Error?) -> Void) {
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                if error != nil {
                    return
                }
                if let result = tmpResult {
                    var sleepAggr: Double = 0
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                            let distanceBetweenDates = (sample.endDate.timeIntervalSince(sample.startDate)).rounded(toPlaces: 0)
                            sleepAggr += distanceBetweenDates
                            print("seconds from TimeInterval: \(distanceBetweenDates)")
                        }
                    }
                    let minutes = sleepAggr/60
                    completion(minutes.rounded(toPlaces: 2),error)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    private func getWholeDate(date : Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        print("")
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate,endDate)
    }

    func recordWorkoutOfActivity(activityDates:[AccessTuple], activityData:ActivityData, distance:Double, calories:Double, completion: @escaping (_ isSucess:Bool) -> Void) {
        let totalDistance = HKQuantity(unit:.mile(), doubleValue: distance.rounded(toPlaces: 2))
        let totalEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
        var workoutEvents: [HKWorkoutEvent] = []
        for value in activityDates.enumerated(){
            let currentActivityDate = value.element
            var previousActivityDate : AccessTuple?
            if value.offset-1 >= 0 {
                previousActivityDate = activityDates[value.offset-1]
            }
            
            if previousActivityDate != nil && ((previousActivityDate?.endDate ?? Date()) != currentActivityDate.startDate) {
                if let startDate = activityDates.first?.startDate,let endDate = activityDates.last?.endDate {
                    if let pauseDate = previousActivityDate?.endDate {
                        if pauseDate >= startDate && pauseDate <= endDate {
                            //if the pause duration/date lies between the activity start and end date, then only append in the workout event else it might crash the HKWorkout initializer
                            workoutEvents.append(HKWorkoutEvent(type: .pause, date: previousActivityDate?.endDate ?? Date()))
                        }
                    }
                    if currentActivityDate.startDate >= startDate && currentActivityDate.startDate <= endDate {
                        //if the resume duration/date lies between the activity start and end date, then only append in the workout event else it might crash the HKWorkout initializer
                        workoutEvents.append(HKWorkoutEvent(type: .resume, date: currentActivityDate.startDate))
                    }
                }
            }
        }
        
        if let startDate = activityDates.first?.startDate,
           let endDate = activityDates.last?.endDate {
            // MARK: need to change
            guard endDate >= startDate else {
                completion(true)
                return
            }
            let typeRawValue: UInt
            if let healthKit = activityData.externalTypes?.HealthKit {
                typeRawValue = UInt(healthKit) ?? 0
            } else {
                typeRawValue = UInt(HKWorkoutActivityType.other.rawValue)
            }
            let activityType = HKWorkoutActivityType(rawValue: typeRawValue) ?? HKWorkoutActivityType.other
            let workout = HKWorkout(activityType: activityType, start: startDate, end: endDate, workoutEvents:workoutEvents, totalEnergyBurned: totalEnergyBurned, totalDistance: totalDistance, metadata: nil)
            self.healthStore.save(workout, withCompletion: { (success, error) in
                if success {
                    // Workout was successfully saved
                    completion(true)
                } else {
                    // Workout was not successfully saved
                    print(error ?? "error")
                    completion(false)
                }
            })
        }
        else {
            completion(false)
        }
    }
    
    func setAskedForSyncEnable() {
        askedForSyncEnable = true
        Defaults.shared.set(value: true, forKey: .askedForHealthKitSyncEnable)
    }
    
    func reset() {
        askedForSyncEnable = false
        healthSyncEnabled = false
        Defaults.shared.set(value: false, forKey: .askedForHealthKitSyncEnable)
        Defaults.shared.set(value: false, forKey: .healthKitSyncEnabled)
    }
    
    //Calculate Calories based on duration
    func calculateCalories(duration: Double?, metValue: Double?) -> Double? {
        let timeInSeconds = duration ?? 0
        let timeInHours = timeInSeconds/3600
        return Utility.calculatedCaloriesFrom(metValue: metValue ?? 0, duration: timeInHours)
    }
}
