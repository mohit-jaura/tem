//
//  Encodable+Extension.swift
//  TemApp
//
//  Created by shilpa on 14/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
extension Encodable {
    
    ///encode the type to the parameters type i.e. [String: Any]
    func json() -> Parameters? {
        if let encodedData = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? Parameters {
            return dictionary
        }
        return nil
    }
}

