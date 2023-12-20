//
//  AnalyticsManager.swift
//  TemApp
//
//  Created by Harmeet on 26/05/20.
//

import Foundation
import Firebase
import CoreTelephony

class AnalyticsManager: NSObject {
    
    static func logEventWith(event: String,parameter: [String:Any]){
            Analytics.logEvent(event, parameters: parameter)
        }
}
