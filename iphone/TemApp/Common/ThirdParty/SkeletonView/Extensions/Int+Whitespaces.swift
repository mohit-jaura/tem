// Copyright © 2018 Capovela LLC. All rights reserved.

import Foundation

extension Int {
    
    var whitespace: String {
        return whitespaces
    }
    
    var whitespaces: String {
        return String(repeating: " ", count: self)
    }
}
