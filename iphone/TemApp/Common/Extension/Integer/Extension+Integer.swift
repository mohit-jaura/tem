//
//  Extension+Integer.swift
//  TemApp
//
//  Created by Sourav on 2/19/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}
extension Int {
    
    public var toDate: Date {
        let timeInterval = Double(self)
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    
    public var timestampInMillisecondsToDate: Date {
        let timeInterval = Double(self)/1000
        return Date(timeIntervalSince1970: timeInterval)
    }
}// Extension + Int......

extension Double {
    public var toDate: Date {
        let timeInterval = Double(self)
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    public var timestampInMillisecondsToDate: Date {
        let timeInterval = Double(self)/1000
        return Date(timeIntervalSince1970: timeInterval)
    }
}
