//
//  Extension+Double.swift
//  TemApp
//
//  Created by Sourav on 2/19/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

extension Double {
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return floor(self*divisor)/divisor
    }
    
    var formattedWithTrailingZeroes: String? {
        if self == 0 {
            return nil
        }
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    /// will return the double as formatted with zeroes.
    ///12.0 will return as 12,
    ///12.01 will return as 12.01
    var formatted: String? {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        let number = NSNumber(value: self)
        return formatter.string(from: number)
    }
    
    /// returns the double as max value if self is greater than value else returns the self
    ///
    /// - Parameter value: max value , eg. 100
    /// - Returns: double
    func formatToMax(value: Double) -> Double {
        if self > value {
            return value - 1
        }
        return self
    }
}
