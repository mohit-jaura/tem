//
//  Date+Extension.swift
//  TemApp
//
//  Created by dhiraj on 13/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import EventKit

enum DateFormat {
    case preDefined
    case displayDate
    case fitbitDate
    case fitbitTime
    case fbFormat
    case goalFormat
    case dateNumberFormat
    case notification
    case sleep
    case time
    case formatOneYearAgo
    case chatDate
    case year
    case activityDateDisplay
    case paymentHistory
    case foodTrek
    case utcDate
    case foodTrekDate
    case eventSlot
    case coachingTools
    var format: String {
        switch self {
            case .preDefined: return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            case .displayDate: return "MMM dd, yyyy"
            case .notification: return "MMM dd, yyyy at HH:mm"
            case .fbFormat: return "MM/dd/yyyy"
            case .fitbitDate: return "yyyy-MM-dd"
            case .fitbitTime: return "HH:mm"
            case .goalFormat: return "dd-mm-yyyy"
            case .dateNumberFormat: return "M-dd-yyyy"
            case .sleep: return "yyyy-MM-dd hh:mm a"
            case .time: return "h:mm a"
            case .formatOneYearAgo : return "M/d/yy"
            case .chatDate : return "MMM d"
            case .year : return "yyyy"
            case .activityDateDisplay: return "dd MMM yyyy"
            case .paymentHistory: return "MMM yyyy"
            case .foodTrek: return "MMMM d"
            case .eventSlot : return "EEEE, MMM d yyyy"
            case .coachingTools: return "d MMMM yyyy"
            case .utcDate: return"yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            case .foodTrekDate: return "yyyy-MM-dd'T'HH:mm:ss'Z'"
        }
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startDayOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }

//    var endOfDay: Date {
//        var components = DateComponents()
//        components.day = 1
//        components.second = -1
//        return Calendar.current.date(byAdding: components, to: startDayOfMonth)!
//    }

    var endDayOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth())!
    }

    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}

extension Date {
    ///Returns the seconds between the receiver and another given date.
    func differenceInSeconds(fromDate date: Date) -> Int {
        let difference = self.timeIntervalSince(date)
        return Int(difference)
    }
    ///returns the date by adding the number of minutes passed
    func dateByAdding(minutes: Int) -> Date? {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .minute, value: minutes, to: self) {
            return newDate
        }
        return nil
    }

    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    public var timeStamp: Int {
        let refrenceTimeInterval = self.timeIntervalSince1970
        return refrenceTimeInterval.toInt() ?? 0
    }
    public var timestampInMilliseconds: Int {
        let refrenceTimeInterval = self.timeIntervalSince1970 * 1000
        return refrenceTimeInterval.toInt() ?? 0
    }
    ///returns the display Date which will be show
    func displayDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        let dateOfBirth = dateFormatter.string(from: self)
        return dateOfBirth
    }
    func toString(inFormat format: DateFormat) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format.format
        return dateFormatter.string(from: self)
    }


    func toUTCString(inFormat format: DateFormat) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format.format
        return dateFormatter.string(from: self)
    }

    func UTCToLocalString(inFormat format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = deviceTimezone
        dateFormatter.dateFormat = format.format
        return dateFormatter.string(from: self)
    }

    func UTCToLocalDate(inFormat format: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = deviceTimezone
        dateFormatter.dateFormat = format.format
        let dateString = dateFormatter.string(from: self)
        dateFormatter.timeZone = utcTimezone
        return dateFormatter.date(from: dateString) ?? self
    }

    func locaToUTCDate(inFormat format: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = utcTimezone
        dateFormatter.dateFormat = format.format
        let dateString = dateFormatter.string(from: self)
        dateFormatter.timeZone = deviceTimezone
        return dateFormatter.date(from: dateString) ?? self
    }

    func locaToUTCString(inFormat format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = utcTimezone
        dateFormatter.dateFormat = format.format
        return dateFormatter.string(from: self)
    }

    func dateOnly(calendar: Calendar) -> Date {
        return self
        let yearComponent = calendar.component(.year, from: self)
        let monthComponent = calendar.component(.month, from: self)
        let dayComponent = calendar.component(.day, from: self)
        let hourComponent = calendar.component(.hour, from: self)
        let minuteComponent = calendar.component(.minute, from: self)
        let secondComponent = calendar.component(.second, from: self)
        let zone = calendar.timeZone

        let newComponents = DateComponents(timeZone: zone,
                                           year: yearComponent,
                                           month: monthComponent,
                                           day: dayComponent
                                           )
        let returnValue = calendar.date(from: newComponents)
        return returnValue ?? self
    }

    func getExactDateTime() -> Date {
        let now = Date().UTCToLocalDate(inFormat: .preDefined)
        let components = now.dateComponents
        let hour = components.hour
        let min = components.minute
        let sec = components.second
        let exactDate = self.dateBySet(hour: hour, min: min, secs: sec) ?? Date()
        return exactDate
    }

    func addHoursIfNeeded() -> Date {
        let now = Date().UTCToLocalDate(inFormat: .preDefined)
        let components = now.dateComponents
        let hour = components.hour ?? 6
        let min = components.minute
        let sec = components.second
        if hour < 6 {
           return self.dateBySet(hour: 6, min: min, secs: sec) ?? Date()
        }
        return self
    }
    func postCreatedTime( requiredFormat:DateFormat = .preDefined) -> String {
        let dateFormator = DIDateFormator.localFormat(dateFormat: requiredFormat)
        print("date.....\(self)")
        if let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour, diff <= 24 {
            print("diffHours.....\(diff)")
            if diff <= 0 {
                if let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute {
                    if (diff <= 0) {
                        return "just now  "
                    }
                    let diffStr = diff == 1 ? "\(diff) minute ago  " : "\(diff) minutes ago  "
                    return diffStr
                }
                return ""
            }
            return "\(diff) hours ago  "
        }else if let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day, diff <= 7 {
            return "\(diff) days ago  "
        }else{
            dateFormator.dateFormat = DateFormat.displayDate.format
            return dateFormator.string(from: self)
        }
    }

    func chatDisplayTime( requiredFormat:DateFormat = .displayDate) -> String {
        var dateFormator = DIDateFormator.localFormat(dateFormat: requiredFormat)
        if NSCalendar.current.isDateInToday(self)  {
            dateFormator = DIDateFormator.localFormat(dateFormat: .time)
            return "\(dateFormator.string(from: self))"
        }else if NSCalendar.current.isDateInYesterday(self) {
            return "yesterday".localized
        }else{
            dateFormator =  DIDateFormator.format(dateFormat: .year)
            let year1 = dateFormator.string(from: Date())
            let year2 = dateFormator.string(from: self)
            if year1 > year2 {

                dateFormator = DIDateFormator.localFormat(dateFormat: .formatOneYearAgo)
                return "\(dateFormator.string(from: self))"
            }

            dateFormator = DIDateFormator.localFormat(dateFormat: .chatDate)
            return "\(dateFormator.string(from: self))"
        }
    }

    func addYear(_ year: Int) -> Date{
        let cal = NSCalendar.current
        return cal.date(byAdding: .year, value: year, to: self)!
    }

    func addMonth(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    func addDay(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: n, to: self)!
    }

    func addSec(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: n, to: self)!
    }

    func addMinutes(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .minute, value: n, to: self)!
    }

    func addDuration(n: Int,type:Calendar.Component) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: type, value: n, to: self)!
    }

    func addDurationWithWeekDay(type:Calendar.Component) -> EKWeekday?{
        let cal = NSCalendar.current
        let intDay = cal.component(.weekday, from: self)
        let day = EKWeekday.init(rawValue: intDay)
        return day
    }



    var startOfWeek: Date {

        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!

        //        let gregorian = Calendar(identifier: .gregorian)
        //        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return Date() }
        //        return gregorian.date(byAdding: .day, value: 0, to: sunday) ?? Date()
    }

    var endOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return Date() }

        return gregorian.date(byAdding: .day, value: 6, to: sunday) ?? Date()
    }

    func info() -> (year:Int,month:Int,day:Int){
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        return (year,month,day)
    }
//    var startOfDay : Date {
//        let calendar = Calendar.current
//        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
//        let components = calendar.dateComponents(unitFlags, from: self)
//        return calendar.date(from: components)!
//    }
//
    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }

    func differenceBtwDates(endDate:Date?) -> DateComponents?{
        let calendar = Calendar.current
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: endDate ?? Date())

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components
    }

    func startOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }

    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }

    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate

        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }

}//Extnsion....

extension UIDatePicker {
    /// Returns the date that reflects the displayed date clamped to the `minuteInterval` of the picker.
    public var clampedDate: Date {
        let referenceTimeInterval = self.date.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTimeInterval.truncatingRemainder(dividingBy: TimeInterval(minuteInterval*60))
        let timeRoundedToInterval = referenceTimeInterval - remainingSeconds
        return Date(timeIntervalSinceReferenceDate: timeRoundedToInterval)
    }
    public var timeStamp: Int {
        let refrenceTimeInterval = self.date.timeIntervalSince1970
        return refrenceTimeInterval.toInt() ?? 0
    }
}//Extension+ UIPicker...


class DIDateFormator:NSObject {
    class func format(dateFormat:DateFormat = .preDefined) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = dateFormat.format
        dateFormatter.locale =  Locale(identifier: "en")
        return dateFormatter
    }
    class func localFormat(dateFormat:DateFormat = .preDefined) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = dateFormat.format
        dateFormatter.locale =  Locale(identifier: "en")
        return dateFormatter
    }
}
