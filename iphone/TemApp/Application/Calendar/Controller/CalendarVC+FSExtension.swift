//
//  CalendarVC+FSDataSource.swift
//  TemApp
//
//  Created by debut_mac on 19/01/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//
import FSCalendar
import Foundation

extension CalendarVC: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let now = Date()
        let cal = Calendar.current
        let newDate = cal.date(bySettingHour: cal.component(.hour, from: now),
                               minute: cal.component(.minute, from: now),
                               second: cal.component(.second, from: now),
                               of: date)!
        
        let datesAreInTheSameDay = cal.isDate(newDate, equalTo: selectedDate, toGranularity: .month)
        if datesAreInTheSameDay{
            let filtred = eventDatesForMonth.filter({$0.kvkIsEqual(newDate)})
            if filtred.count > 0 {
                return UIImage(named: "dotN")
            }
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
}

extension CalendarVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let now = Date()
        let cal = Calendar.current
        let newDate = cal.date(bySettingHour: cal.component(.hour, from: now),
                               minute: cal.component(.minute, from: now),
                               second: cal.component(.second, from: now),
                               of: date)!
        if selectedDate.dateComponents.month == newDate.dateComponents.month {
            selectedDate = newDate
            filterEventsForTheDay()
        } else {
            selectedDate = newDate
            calendarView.select(selectedDate, scrollToDate: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let now = Date()
        let cal = Calendar.current
        let newDate = cal.date(bySettingHour: cal.component(.hour, from: now),
                               minute: cal.component(.minute, from: now),
                               second: cal.component(.second, from: now),
                               of: calendar.currentPage)!
        selectedDate = newDate
        calendarView.select(selectedDate, scrollToDate: true)
        calendarView.setCurrentPage(selectedDate, animated: true)
        self.setUpMonth(self.selectedDate)
        self.initilaiseStartEndDate()
    }
}

extension CalendarVC: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        var mcalendar = Calendar.current
        mcalendar.timeZone = TimeZone.current
        let datesAreInTheSameDay = mcalendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
        if datesAreInTheSameDay{
            if date == calendar.today ?? Date() {
                return UIColor.appPurpleColor
            }
            return UIColor.appThemeColor
        }
        return UIColor.white.withAlphaComponent(0.8)
    }
}
