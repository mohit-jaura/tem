//
//  Serializable.swift
//  SpotMe
//
//  Created by shilpa on 23/04/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation

protocol SerializableArray {
    init?(fromDict dict: [String: Any])
}

extension Sequence where Iterator.Element == [String : Any] {
  func toModelArray<T: SerializableArray>() -> [T] {
    var tempArray = [T]()
    for rawObject in self {
      if let object = T(fromDict: rawObject) {
        tempArray.append(object)
      }
    }
    return tempArray
  }
}
