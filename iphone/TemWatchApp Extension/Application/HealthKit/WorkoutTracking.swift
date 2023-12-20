//
//  WorkoutTracking.swift
//  TemWatchApp Extension
//
//  Created by shilpa on 23/06/20.
//

import Foundation
import HealthKit

protocol WorkoutTrackingDelegate: AnyObject {
    func didReceiveHeartRate(heartRate: Double, avgValue: Double)
    func didReceiveActiveEnergy(calories: Double)
    ///received the distance while walking or running
    func didReceiveDistanceWalkingRunning(distance: Double)
    func didReceiveSteps(steps: Double)
    /// receive the distance the user has moved by cycling
    func didReceiveCyclingDistance(distance: Double)
    /// received the distance while swimming
    func didReceiveSwimmingDistance(distance: Double)
}

/// This class will track the single workout of the user, collects the health data and save it in the healthkit
class WorkoutTracking: NSObject {
    static let instance = WorkoutTracking()
    var configuration: HKWorkoutConfiguration!
    
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    private var workoutStartTime: Date = Date()
    private var activityId: Int = 1
    weak var delegate: WorkoutTrackingDelegate?
    var activeSession: HKWorkoutSession?
    
    // MARK: Initializer
    private override init() {
        super.init()
    }
    
    func recoverActiveWorkoutSession() {
        HealthKit.instance?.healthStore.recoverActiveWorkoutSession(completion: { (session, error) in
            if let _ = Defaults.shared.get(forKey: .sharedActivityInProgress) {
                if let sessionState = session?.state, sessionState != .ended {
                    self.activeSession = session
                }
            }
        })
    }
    
    // MARK: Workout Configuration
    private func setBuilderDataSourceDelegate() {
        builder.delegate = self
        guard let healthStore = HealthKit.instance?.healthStore else { return }
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)//datasource
    }
    
    func resetSessionVariables() {
        self.session = nil
        self.activeSession = nil
    }
    
    /// create and begin a workout session for the activity
    func startWorkout(activityId: Int, startTime: Date, kitActivityType: UInt, completion: @escaping (_ success: Bool, _ error: DIError?) -> Void) {
        self.activityId = activityId
        self.workoutStartTime = startTime
        guard let healthKit = HealthKit.instance else {
            return
        }
        let authorizationStatue = healthKit.healthStore.authorizationStatus(for: HKQuantityType.workoutType())
        print("status ========> \(authorizationStatue)")
        if authorizationStatue == .sharingAuthorized {
            print("sharing not authorized: \(authorizationStatue)")
        }
        if authorizationStatue == .notDetermined {
            print("not determined status")
        }
        self.configuration = HKWorkoutConfiguration()
        configuration.activityType = HKWorkoutActivityType(rawValue: kitActivityType)!
        configuration.locationType = .outdoor
        
        // Create the session and obtain the workout builder.
        do {
            if let activeSession = self.activeSession {
                session = activeSession
            } else {
                session = try HKWorkoutSession(healthStore: healthKit.healthStore, configuration: configuration)
            }
            builder = session.associatedWorkoutBuilder()
        } catch(let error) {
            //-dismiss()
            let diError = DIError(error: error)
            completion(false, diError)
            print("error: \(error)")
            return
        }
        
        // Setup session and builder.
        session.delegate = self
        setBuilderDataSourceDelegate()
        
        // Start the workout session and begin data collection.
        //if the session is already started, then we dont need to start activity or begin collection
        if self.activeSession == nil {
            print("On start activity")
            session.startActivity(with: workoutStartTime)
            builder.beginCollection(withStart: workoutStartTime) { (success, error) in
                print("begin collection status: \(success)")
                print("begin collection error: \(error)")
                print("workout started on watch")
                
                guard success else {
                    //there was some error in datacollection
                    let userInfo = ["error": error?.localizedDescription ?? "Something went wrong. Please try again!"]
                    NotificationCenter.default.post(name: Notification.Name.workoutFailed, object: nil, userInfo: userInfo)
                    completion(false, nil)
                    return
                }
            }
        } else {
            print("Got some active session \(self.activeSession)")
        }
    }
    
    func setDurationTimerDate(_ sessionState: HKWorkoutSessionState) {
        /// Obtain the elapsed time from the workout builder.
        let timerDate = Date(timeInterval: -self.builder.elapsedTime, since: Date())
        
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            //self.timer.setDate(timerDate)
        }
    }
    
    // MARK: Delegation
    /// Call the delegates with the new data
    /// - Parameter statistics: HKStatistics
    private func setStatisticsData(statistics: HKStatistics?) {
        guard let statistics = statistics else {
            return
        }
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            switch statistics.quantityType {
                case HKQuantityType.quantityType(forIdentifier: .stepCount):
                    let unit = HKUnit.count()
                    let value = statistics.sumQuantity()?.doubleValue(for: unit)
                    let roundedValue = value?.rounded(toPlaces: 2) ?? 0
                    self.delegate?.didReceiveSteps(steps: roundedValue)
                case HKQuantityType.quantityType(forIdentifier: .heartRate):
                    /// - Tag: SetLabel
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                    let roundedValue = Double( round( 1 * value! ) / 1 )
                    let avgValue = statistics.averageQuantity()?.doubleValue(for: heartRateUnit)
                    let roundedAvg = Double( round( 1 * avgValue! ) / 1 )
                    self.delegate?.didReceiveHeartRate(heartRate: roundedValue, avgValue: roundedAvg)
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    let energyUnit = HKUnit.kilocalorie()
                    let value = statistics.sumQuantity()?.doubleValue(for: energyUnit)
                    let roundedValue = value?.rounded(toPlaces: 2) ?? 0
                    print("energy burned ======> \(value)")
                    self.delegate?.didReceiveActiveEnergy(calories: roundedValue)
                case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                    let meterUnit = HKUnit.mile()
                    let value = statistics.sumQuantity()?.doubleValue(for: meterUnit)
                    let roundedValue = value?.rounded(toPlaces: 2) ?? 0
                    print("distance covered: \(roundedValue)")
                    self.delegate?.didReceiveDistanceWalkingRunning(distance: roundedValue)
                    return
                case HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                    let mileUnit = HKUnit.mile()
                    let value = statistics.sumQuantity()?.doubleValue(for: mileUnit)
                    let roundedValue = value?.rounded(toPlaces: 2) ?? 0
                    print("cycling distance: \(roundedValue)")
                    self.delegate?.didReceiveCyclingDistance(distance: roundedValue)
                case HKQuantityType.quantityType(forIdentifier: .distanceSwimming):
                    let mileUnit = HKUnit.mile()
                    let value = statistics.sumQuantity()?.doubleValue(for: mileUnit)
                    let roundedValue = value?.rounded(toPlaces: 2) ?? 0
                    print("swimming distance: \(roundedValue)")
                    self.delegate?.didReceiveSwimmingDistance(distance: roundedValue)
                default:
                    return
            }
        }
    }
    
    // MARK: Session Control
    func pauseWorkout() {
        self.session.pause()
    }
    
    func resumeWorkout() {
        self.session.resume()
    }
    
    /// complete the workout session
    /// - Parameter caloriesCalc: calories calculated from the formula
    /// - Parameter endDate: end date time of workout session
    /// - Parameter saveToHealthKit: true if the workout needs to be saved to the healthkit
    /// - Parameter completion: completion
    func endWorkout(caloriesCalc: Double, endDate: Date? = Date(), saveToHealthKit: Bool? = true, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        print("END WORKOUT IS CALLED")
        if session.state == .ended {
            completion(true, nil)
            return
        }
        /// Update the timer based on the state we are in.
        session.end()
        if let quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let unit = HKUnit.largeCalorie()//HKUnit.kilocalorie()
            let caloriesBurned = caloriesCalc
            let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: caloriesBurned)
            
            let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: self.workoutStartTime, end: Date())//HKCumulativeQuantitySample(type: quantityType, quantity: quantity, start: self.workoutStartTime, end: Date(), metadata: nil)
            builder.add([sample]) { (success, error) in
                guard success else {
                    print("error ======> \(error)")
                    return
                }
                self.builder.endCollection(withEnd: endDate!) { (success, error) in
                    guard success else {
                        completion(success, "Something went wrong! Please try again.")
                        return
                    }
                    self.activeSession = nil
                    if saveToHealthKit! {
                        self.builder.finishWorkout { (workout, error) in
                            print("FINISH WORKOUT IS CALLED")
                            if let error = error {
                                completion(false, "Something went wrong! Please try again.")
                                return
                            }
                            print("calculated calories: \(caloriesCalc)")
                            print("FINISHED WORKOUT : \(workout?.duration), name: \(workout?.workoutActivityType.rawValue) and energy: \(workout?.totalEnergyBurned)")
                            completion(true, nil)
                        }
                    } else {
                        self.builder.discardWorkout()
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func discardWorkout(completion: @escaping(_ success: Bool) -> Void) {
        //        self.activeSession = nil
        //        self.builder.discardWorkout()
        self.builder.endCollection(withEnd: Date()) { (success, error) in
            print("error in end collection: \(error)")
            guard success else {
                completion(false)
                return
            }
            self.activeSession = nil
            self.builder.discardWorkout()
            completion(true)
        }
    }
}

// MARK: HKWorkoutSessionDelegate
extension WorkoutTracking: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        let from = HKWorkoutSessionState.running.rawValue
        print("from state: \(from)")
        print("did change to state \(toState.rawValue) from state \(fromState.rawValue)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("didFailwitherror \(error)")
    }
}

// MARK: HKLiveWorkoutBuilderDelegate
extension WorkoutTracking: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        print("======== data collecting ========")
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            /// - Tag: GetStatistics
            let statistics = workoutBuilder.statistics(for: quantityType)
            self.setStatisticsData(statistics: statistics)
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("In did collect event")
        // Retreive the workout event.
        guard let workoutEventType = workoutBuilder.workoutEvents.last?.type else { return }
        
        // Update the timer based on the event received.
        switch workoutEventType {
            case .pause: // The user paused the workout.
                print("workout paused \(workoutBuilder.elapsedTime)")
            case .resume: // The user resumed the workout.
                print("workout resumed \(workoutBuilder.elapsedTime)")
            default:
                print("workout event is \(workoutEventType)--------> \(workoutEventType.rawValue)")
                
        }
    }
}
