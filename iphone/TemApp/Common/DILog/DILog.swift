//
//  DILog.swift
//  BaseProject
//
//  Created by Aj Mehra on 09/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
class DILog {
  static var enableLog = true
  class func print(items: Any..., separator: String = " ", terminator: String = "\n") {
   
    if !enableLog {
      return
    }
    
    var idx = items.startIndex
    let endIdx = items.endIndex
    repeat {
      Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
      idx += 1
    }
      while idx < endIdx
  }
}
