//
//  Utility.swift
//  TemWatchApp Extension
//
//  Created by shilpa on 18/05/20.
//

import Foundation
class Utility {
    
    /// calculates the calories from the formula
    /// - Parameter metValue: met value of the respective activity
    /// - Parameter duration: duration in hours
    class func calculatedCaloriesFrom(metValue: Double, duration: Double) -> Double {
        let genderValue = Defaults.shared.get(forKey: .userGender) as? Int ?? 0
        let gender = Gender(rawValue: genderValue) ?? .none
        var weight: Double = Double(Defaults.shared.get(forKey: .userWeight) as? Int ?? 0)
        if weight == 0 {
            weight = Double(gender.defaultWeight)
        }
        let caloriesCalculated = (weight/2.205) * metValue * duration
        return caloriesCalculated
    }
    
    /// convert the seconds to minutes and seconds and format it to show the average and in progress miles distance
    /// - Parameter totalSeconds: total time in seconds
    class func formatToMinutesAndSecondsOfMiles(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        //format the minutes value with the leading zeroes
        var formattedMinutes = "\(minutes)"
        var formattedSeconds = "\(seconds)"
        if minutes == 0 {
            formattedMinutes = "00"
        } else if minutes < 10 {
            formattedMinutes = "0\(minutes)"
        }
        if seconds == 0 {
            formattedSeconds = "00"
        } else if seconds < 10 {
            formattedSeconds = "0\(seconds)"
        }
        let timeFormatted = "\(formattedMinutes)" + "'" + "\(formattedSeconds)" + "\""
        return timeFormatted
    }
}
