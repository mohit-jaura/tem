//
//  CalendarManager.swift
//  TemApp
//
//  Created by dhiraj on 15/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import EventKit
class CalendarManager: NSObject {
    
    static let shared = CalendarManager()
    
    var eventSchedule : EKRecurrenceFrequency?
    var eventFrequency : Int?
    var eventDetail:EventDetail?
    var endsOn : Date?
    var isDeleteEvent = false
    var deleteEventType:DeleteEventType = .thisEventOnly
    var eventID = ""
    
    
    func checkPermissionAndPerformOperation(){
        // 1
        let eventStore = EKEventStore()
        // 2
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            if self.isDeleteEvent {
                self.deleteEvent(eventStore : eventStore)
            } else {
                self.insertEvent(store: eventStore)
            }
        case .denied:
            print("Access denied")
            displayAccessDenied()
        case .notDetermined:
            // 3
            eventStore.requestAccess(to: .event, completion:
                {[weak self] (granted: Bool, _: Error?) -> Void in
                    if granted {
                        if self!.isDeleteEvent {
                            self!.deleteEvent(eventStore : eventStore)
                        } else {
                            self!.insertEvent(store: eventStore)
                        }
                    } else {
                        print("Access denied")
                        self?.displayAccessDenied()
                    }
            })
        case .restricted:
            self.displayAccessRestricted()
        @unknown default:
            break
        }
    }
    

    
    
    func insertEvent(store: EKEventStore) {
        // 1
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars {
            // 2
            if calendar.title == "Calendar" {
                // 3
                if let startDate = eventDetail?.eventStartDate,let endDate = eventDetail?.eventEndDate {
                    let endDateWeekType = endDate.addDurationWithWeekDay(type: .day)
                    // 4
                    let event = EKEvent(eventStore: store)
                    event.calendar = calendar
                    
                    event.title = eventDetail?.title
                    event.notes = eventDetail?.description
                    event.startDate = startDate
                    event.endDate = endDate
                    event.recurrenceRules = eventSchedule == nil ? nil : getRecurrenceRule(startDate, (endDate,endDateWeekType))
                    event.location = eventDetail?.location?.location
                    // 5
                    do {
                        try store.save(event, span: .thisEvent)
                    }
                    catch {
                        print("Error saving event in calendar")
                        
                    }
                }
            }
        }
    }
    
    func insertEventIniCal(_ eventDetail:EventDetail?,_ createEvetDict: CreateEvent,_ endsOnType : RecurrenceFinishType?,_ endOnDate:Date?){
        if let eventDetail = eventDetail{
            CalendarManager.shared.eventDetail = eventDetail
            CalendarManager.shared.eventFrequency = 1
            CalendarManager.shared.isDeleteEvent = false
            switch createEvetDict.reccurEvent{
            case .doesNotRepeat:
                CalendarManager.shared.eventSchedule = nil
            case .everyDay:
                CalendarManager.shared.eventSchedule = .daily
            case .week:
                CalendarManager.shared.eventSchedule = .weekly
            case .eveyTwoWeeks:
                CalendarManager.shared.eventFrequency = 2
                CalendarManager.shared.eventSchedule = .weekly
            case .everyMonth:
                CalendarManager.shared.eventSchedule = .monthly
            }
            if let endsOnType = endsOnType {
                if endsOnType != .never{
                    CalendarManager.shared.endsOn =  endOnDate?.endOfDay
                }
            }
            DispatchQueue.global(qos: .background).async{
                CalendarManager.shared.checkPermissionAndPerformOperation()
            }
        }
    }
    
    func deleteEventFromiCal(_ deleteEventType:DeleteEventType, _ eventDetail:EventDetail?){
        CalendarManager.shared.eventDetail = eventDetail
        CalendarManager.shared.deleteEventType = deleteEventType
        CalendarManager.shared.isDeleteEvent = true
        DispatchQueue.global(qos: .background).async{
            CalendarManager.shared.checkPermissionAndPerformOperation()
        }
    }
    
    
    func displayAccessDenied(){
        print("Access to the event store is denied.")
    }
    
    func displayAccessRestricted(){
        print("Access to the event store is restricted.")
    }
    
    func getRecurrenceRule(_ startDate:Date,_ endDate:(Date,EKWeekday?)) -> [EKRecurrenceRule]?{
        
        var pos : [NSNumber]?
        //
        //        if eventSchedule != .daily {
        ////            pos = [1]
        //        }
        //eventSchedule == .daily ? nil : [EKRecurrenceDayOfWeek.init(endDate.1 ?? .monday)]
        let recurrenceRule = EKRecurrenceRule.init(
            recurrenceWith: eventSchedule ?? .monthly,
            interval: eventFrequency ?? 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: pos ?? nil,
            end:EKRecurrenceEnd.init(end:endsOn ?? Date())
        )
        
        return [recurrenceRule]
    }
    
    func deleteEvent(eventStore : EKEventStore){
        if let calendar = eventStore.calendars(for: .event).filter({$0.title == "Calendar" }).first{
            if let startDate = eventDetail?.eventStartDate.startOfDay,let endDate = eventDetail?.eventEndDate.endOfDay {
                // What about Calendar entries?
                let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                let eventList = eventStore.events(matching: predicate)
                for i in eventList {
                    if let eventTitle = eventDetail?.title {
                        if i.title == eventTitle{
                            do {
                                try eventStore.remove(i, span: deleteEventType == .thisEventOnly ? .thisEvent : .futureEvents)
                                CalendarManager.shared.isDeleteEvent = false
                            } catch {
                                print("Error saving event in calendar")
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
}
