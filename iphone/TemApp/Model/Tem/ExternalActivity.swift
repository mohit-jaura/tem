//
//  ExternalActivity.swift
//  TemApp
//
//  Created by Vladislav Savionok on 27.01.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation
import HealthKit

class ExportedActivities : Encodable {
    let start: Int
    let end: Int
    let origin: ActivityOrigin
    let activities: [ExternalActivity]
    
    init(start: Int, end: Int, origin: ActivityOrigin, workouts: [HKWorkout]) {
        self.start = start
        self.end = end
        self.origin = origin
        self.activities = workouts.map({ (workout) -> ExternalActivity in
            return ExternalActivity(from: workout)
        })
    }
    
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "start": start,
            "end": end,
            "origin": String(origin.rawValue),
            "activities": activities.map({ $0.getDictionary() }),
        ]
        return dict
    }
}

enum ActivityOrigin: String, Codable {
    case TEM
    case GoogleFit
    case HealthKit
}

class ExternalActivity : Encodable {
    let type: String
    let start: Int
    let end: Int
    let distance: Double?
    let steps: Int?

    init(from workout: HKWorkout) {
        self.type = String(workout.workoutActivityType.rawValue)
        self.start = workout.startDate.timestampInMilliseconds
        self.end = workout.endDate.timestampInMilliseconds
        self.distance = workout.totalDistance?.doubleValue(for: .mile())
        self.steps = nil
    }
    
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "type": type,
            "start": start,
            "end": end,
            "distance": distance ?? 0,
            "steps": steps ?? 0
        ]
        return dict
    }
}
