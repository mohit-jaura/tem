//
//  HealthKit+IOS.swift
//  TemApp
//
//  Created by Egor Shulga on 16.03.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation
import HealthKit

extension HealthKit {
    func configureBackgroundWorkoutsObserving(_ completion: @escaping (Bool, Error?) -> Void) {
        let workoutType = HKSampleType.workoutType()
        let query: HKObserverQuery
        if self.workoutObserverQuery == nil {
            let notThisAppPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: HKQuery.predicateForObjects(from: HKSource.default()))
            query = HKObserverQuery(sampleType: workoutType, predicate: notThisAppPredicate) { (query, completionHandler, error) in
                if (!self.healthSyncEnabled) {
                    self.healthStore.stop(query)
                    completionHandler()
                } else {
                    if !self.isImportInProgress {
                        self.isImportInProgress = true
                        let (start, end) = self.getNextIntervalToImport()
                        self.readWorkouts(startDate: start, endDate: end) { (workouts, error) in
                            if let workouts = workouts {
                                DIWebLayerActivityAPI().importActivities(parameters: workouts.getDictionary()) { response in
                                    print(">>> \(workouts.activities.count) activities imported successfully")
                                    Defaults.shared.set(value: end, forKey: .lastHealthKitImportedIntervalEnd)
                                    self.isImportInProgress = false
                                    completionHandler()
                                } failure: { error in
                                    print(">>> Error importing activities: \(error)")
                                    self.isImportInProgress = false
                                    completionHandler()
                                }
                            }
                            else {
                                self.isImportInProgress = false
                                completionHandler()
                            }
                        }
                    }
                }
            }
            self.workoutObserverQuery = query
            self.healthStore.execute(query)
            print(">>> New workouts Observer Query executed")
        }
        self.healthStore.enableBackgroundDelivery(for: workoutType, frequency: .immediate, withCompletion: completion)
    }
    
    func disableSyncWithHealthKit(_ completion: @escaping (Bool, Error?) -> Void) {
        if (self.healthSyncEnabled) {
            self.disableBackgroundDeliveryOfWorkouts { (success, error) in
                if success {
                    Defaults.shared.set(value: false, forKey: .healthKitSyncEnabled)
                    self.healthSyncEnabled = false
                    completion(true, nil)
                }
                else {
                    completion(false, error)
                }
            }
        }
        else {
            completion(true, nil)
        }
    }
    
    func enableSyncWithHealthKit(_ completion: @escaping (Bool, Error?) -> Void) {
        requestAuthorizationForWorkouts { success, error in
            if success {
                self.enableBackgroundDeliveryOfWorkouts(completion: completion)
            }
            else {
                completion(false, error)
            }
        }
    }
    
    private func enableBackgroundDeliveryOfWorkouts(completion: @escaping (Bool, Error?) -> Void) {
        if (!healthSyncEnabled) {
            healthSyncEnabled = true
            Defaults.shared.set(value: true, forKey: .healthKitSyncEnabled)
            configureBackgroundWorkoutsObserving(completion)
        }
        else {
            completion(true, nil)
        }
    }
    
    func startObservingWorkoutsWithBackgroundDelivery(_ completion: @escaping (Bool, Error?) -> Void) {
        requestAuthorizationForWorkouts { success, error in
            if success {
                self.configureBackgroundWorkoutsObserving(completion)
            }
            else {
                completion(false, error)
            }
        }
    }
    
    func requestAuthorizationForWorkouts(_ completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: [HKObjectType.workoutType()], read: [HKObjectType.workoutType()], completion: completion)
    }
    
    private func getNextIntervalToImport() -> (Date, Date) {
        let end = Date()
        var start: Date
        if let stored = Defaults.shared.get(forKey: .lastHealthKitImportedIntervalEnd) as? Date {
            start = stored.addDay(n: -1)
        }
        else {
            start = end.addDay(n: -30)
        }
        return (start, end)
    }
    
    private func disableBackgroundDeliveryOfWorkouts(completion: @escaping (Bool, Error?) -> Void) {
        let workoutType = HKSampleType.workoutType()
        healthStore.disableBackgroundDelivery(for: workoutType, withCompletion: completion)
    }

    func readWorkouts(startDate: Date, endDate: Date, completion: @escaping (ExportedActivities?, DIError?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [HKQueryOptions.strictStartDate, HKQueryOptions.strictEndDate])
        let notThisAppPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: HKQuery.predicateForObjects(from: HKSource.default()))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, notThisAppPredicate])
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        let query = HKSampleQuery(sampleType: workoutType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: sort) { (query, samples, error) in
            if let error = error {
                completion(nil, DIError(error: error))
            } else {
                let results = ExportedActivities(
                    start: startDate.timestampInMilliseconds,
                    end: endDate.timestampInMilliseconds,
                    origin: .HealthKit,
                    workouts: samples as! [HKWorkout])
                completion(results, nil)
            }
        }
        healthStore.execute(query)
    }
    
}
