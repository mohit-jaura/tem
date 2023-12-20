//
//  WeekSlot.swift
//  TemApp
//
//  Created by dhiraj on 12/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

class WeekSlot{
    var startDate:Date = Date()
    var endDate:Date = Date()
    var eventList : [EventDetail] = []
    var height : CGFloat = 0
    init(startDate:Date,endDate:Date,eventList:[EventDetail]) {
        self.startDate = startDate
        self.endDate = endDate
        self.eventList = eventList
    }
}
