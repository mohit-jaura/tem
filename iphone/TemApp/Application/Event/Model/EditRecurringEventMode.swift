//
//  EditRecurringEventMode.swift
//  TemApp
//
//  Created by Egor Shulga on 21.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

enum EditRecurringEventMode : Int, CaseIterable{
    case thisEvent = 0
    case thisAndOtherEvent
    
    func getTitle() -> String{
        switch self {
        case .thisEvent:
            return "Update for this event only"
        case .thisAndOtherEvent:
            return "Update for this and following events"
        }
    }
}
