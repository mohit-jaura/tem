//
//  Gender.swift
//  TemApp
//
//  Created by shilpa on 12/06/20.
//

import Foundation
enum Gender: Int, Codable {
    case none = 0
    case male = 1
    case female = 2
    case other = 3
    
    /// default value of the weight if the user has not set it
    var defaultWeight: Int {
        switch self {
        case .none, .other:
            return 120
        case .male:
            return 140
        case .female:
            return 100
        }
    }
}
