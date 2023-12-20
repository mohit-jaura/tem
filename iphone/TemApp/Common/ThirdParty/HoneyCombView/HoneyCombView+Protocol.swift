//
//  HoneyCombView+Protocol.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

/// Protocol defining the requirements of the honey comb view
// the classes confirming to this protocol need to confirm to the requirements
protocol HoneyCombViewable {
    // MARK: Properties
    var padding: CGFloat { get set }
    var minNumberOfItemsInRow: Int { get set } //number of columns
    var numberOfRows: Int { get set }   //number of rows
    var dividerForHeight: Double { get set }
    
    func isEven(_ number: Int) -> Bool
}

extension HoneyCombViewable {
    var padding: CGFloat {
        get {
            return 2
        }
        set {
            padding = newValue
        }
    }
    
    /// check if number is Even or odd
    func isEven(_ number: Int) -> Bool {
        var result: Bool
        if number % 2 == 0 {
            result = true
        }
        else {
            result = false
        }
        return result
    }
}
