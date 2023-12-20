//
//  CompletedActivityData.swift
//  TemApp
//
//  Created by shilpa on 19/05/20.
//

import Foundation

/// this will hold the data for the final completed activity to be shared with either watch or iphone
struct CompletedActivityData: Codable {
    var calories:Double?
    var timeSpent:Double?
    var distanceCovered:Double?
    var steps:Double?
    var endTime: Double? //end date time of the activity, this would contain the current date time
}

struct InProgressActivityState: Codable {
    var totalTime: Double?
    var distance: Double?
    var duration: String?
    var elapsed: Double?
    var isPlaying: Bool?
    var stateChangeTime: Double? //store the time of the state change of the activity
}
