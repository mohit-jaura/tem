//
//  ScheduleViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 15/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import KVKCalendar
import EventKit

class ScheduleViewController: DIBaseController ,KVKCalendarSettings{


    // MARK: - Variables
        @IBOutlet weak var calendarUIView: UIView!
        var selectedDate = Date()
        private var monthChanged:GoToCalendar?
        private var isFirstTimeLoad :Bool = true
        private var allEventsDetails:[EventsDataByDate]?
        private var alreadyGeneratedSet = Set<Date>()
        private var isDataFetched :Bool = false
        private var lastStartOfWeek:String?
        private var lastEndOfWeek:String?
        var dateChanged:DateChanged?
        var events = [Event]()
        var calendarView: KVKCalendarView?
        var style: Style {
            createCalendarStyle()
        }

        func createCalendarStyle() -> Style {
            var style = Style()
            style.timeline.isHiddenStubEvent = false
            style.startWeekDay = .sunday
            style.systemCalendars = ["Calendar1", "Calendar2", "Calendar3"]
            style.month.autoSelectionDateWhenScrolling = true

            style.headerScroll.heightSubviewHeader = 0

            style.headerScroll.heightHeaderWeek = 0


            style.timeline.separatorLineColor = .newAppThemeColor
            style.timeline.scrollLineHourMode = .onlyOnInitForDate(Date())
            style.timeline.showLineHourMode = .today
            style.timeline.useDefaultCorderHeader = false
            style.timeline.backgroundColor = .newAppThemeColor
            style.allDay.backgroundColor = .newAppThemeColor
            style.allDay.titleColor = .white
            style.allDay.titleText = "ALL DAY"
            style.allDay.height = 35
            style.allDay.maxHeight = 100
            style.allDay.offsetX = 5
            return style
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            let calendar = KVKCalendarView(frame: CGRect(x: 0, y: 0, width: calendarUIView.frame.width, height: calendarUIView.frame.height),date: Date(), style: style)
            self.calendarView = calendar
            calendar.dataSource = self
            calendar.delegate = self
            self.calendarUIView.addSubview(calendar)
            addNotificationObserver()
            getEventListParams {
                self.events  = self.eventsForDate(Date())
                self.calendarView?.reloadData()
            }
        }
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            calendarView?.reloadFrame(CGRect(x: 0, y: 0, width: calendarUIView.frame.width, height: calendarUIView.frame.height))
        }

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

        // MARK: - Get weekly events API
        //This method is used to get params for get event list api.
        func getEventListParams(complition: @escaping OnlySuccess){
             let selectedDate = Date()
            print("selectedDate.startOfWeek", selectedDate.startOfWeek)
            let startDateString = Utility.timeZoneDateFormatter(format: .editEventDate, timeZone: deviceTimezone).string(from: selectedDate.startOfWeek.addDay(n: -1))
            let endDateString = Utility.timeZoneDateFormatter(format: .editEventDate, timeZone: deviceTimezone).string(from: selectedDate.endOfWeek.addDay(n: 2))

            let startDate = "\(startDateString)T00:00:00.000+0000"
            let endDate = "\(endDateString)T23:59:00.000+0000"

            //Avoid being hitting api again for same dates
            if lastStartOfWeek != startDate && lastEndOfWeek != endDate {
                lastStartOfWeek = startDate
                lastEndOfWeek = endDate
                isDataFetched = false
                isFirstTimeLoad = true
                showLoader()
                calendarView?.updateStyle(self.style)

                let apiInfo = EndPoint.GetDayEvent(startDate, endDate)
                DIWebLayerEvent().getDayEvent(parameter: apiInfo.params, endPoint: apiInfo.url) { [weak self] response in
                    self?.isDataFetched = true
                    if case let .Success(data, _) = response {
                        if let events = data as? [EventsDataByDate] {
                            self?.allEventsDetails = events
                        }
                    }
                    DispatchQueue.main.async {
                        self?.hideLoader()
                        complition()
                    }
                }
            }else {
                complition()
                self.isDataFetched = true
            }
        }

        private func generateEventsForDate(_ date: Date) -> [Event] {
            ///Calls that functions, cause we need current selected modal for that day
            guard let allEventsDetails = allEventsDetails else { return [] }
            ///Need to filter with modal date to show current event
            var selectedEvent: [EventDetail] = []
            for allEventsDetail in allEventsDetails {
                selectedEvent.append(contentsOf: allEventsDetail.eventdata ?? [])
            }
            let generatedEvents = selectedEvent.compactMap({ (item) -> Event in
                let startDate = formatter(date: item.eventStartDate.toString(inFormat: .preDefined) ?? "")
                let endDate = formatter(date: item.eventEndDate.toString(inFormat: .preDefined) ?? "")
                let startTime = timeFormatter(date: startDate, format: style.timeSystem.format)
                let endTime = timeFormatter(date: endDate, format: style.timeSystem.format)

                var event = Event(ID: item.id ?? "")
                event.start = startDate
                event.end = endDate
                event.color = Event.Color(.appThemeColor)
                event.textColor = .white
                //            let hoursDiff = event.start.difference(in: .hour, from: event.end) ?? 0
                //            let hoursForAllDayEvent = 24 // statically assign 24 because we all know there are 24 hours in a whole day
                if item.eventType == .goals || item.eventType == .challenges {
                    event.isAllDay = true
                    event.color = Event.Color(.white)
                    event.textColor = .appThemeColor
                    event.title = TextEvent(timeline: " \(item.name ?? "")",
                                            month: "\(item.name ?? "") \(startTime)",
                                            list: item.name ?? "")
                }
                //            else if hoursDiff >= hoursForAllDayEvent {
                //                event.isAllDay = true
                //                event.isAllDay = true
                //                event.color = Event.Color(.white)
                //                event.textColor = .appThemeColor
                //                event.title = TextEvent(timeline: " \(item.title ?? "")",
                //                                        month: "\(item.title ?? "") \(startTime)",
                //                                        list: item.title ?? "")
                //            }
                else {
                    event.title = TextEvent(timeline: "\(startTime) - \(endTime)\n\(item.title ?? "")",
                                            month: "\(item.title ?? "") \(startTime)",
                                            list: "\(startTime) - \(endTime) \(item.title ?? "")")
                    if item.isProgramEvent == 1 {
                        event.title = TextEvent(timeline: "\(startTime) - \(endTime)\nProgram Event\n\(item.title ?? "")",
                                                month: "\(item.title ?? "") \(startTime)",
                                                list: "\(startTime) - \(endTime) \(item.title ?? "")")
                    }
                }
                let memberInfo = item.members?.first(where:({($0.userId == User.sharedInstance.id || $0.memberId == User.sharedInstance.id)}))

                let invitationType = EventInvitationStatus(rawValue: memberInfo?.inviteAccepted ?? EventInvitationStatus.pending.rawValue)

                if invitationType == .rejected{
                    event.title = TextEvent(timeline: item.title ?? "",
                                            month: "",
                                            list: "")
                }
                return event
            })
            return generatedEvents
        }

        func eventsForDate(_ date: Date) -> [Event] {
            let getEvents = generateEventsForDate(date)
            if getEvents.count > 0 {
                for event in getEvents {
                    let alreadyPresent = events.filter({ ev in
                        if event.isAllDay {
                            return ev.ID == event.ID
                        }
                        return ev.ID == event.ID && DateInterval(start: ev.start, end: ev.end) == DateInterval(start: event.start, end: event.end)
                    })
                    if alreadyPresent.count == 0 {
                        events.append(event)
                    }
                }
            }
            return events
        }

        private func initialiseEventModal() {
            guard let allEventsDetails = allEventsDetails else {return}
            ///Need to filter with modal date to show current event
            _ = allEventsDetails.filter({ event in
                let sDate = event.compareDate?.toDate(dateFormat: .preDefined) ?? Date()
                return Calendar.current.isDate(sDate, equalTo: selectedDate ?? Date(), toGranularity: .day)
            }).first?.eventdata
        }


        private func didTapEvent(_ eventDetail:EventDetail?) {
            guard let eventDetail = eventDetail else { return }

            if let eventType = eventDetail.eventType {
                switch eventType {
                    case .regular,.signupSheet:
                        let eventDetailVC:EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
                        eventDetailVC.eventDetail = eventDetail
                        eventDetailVC.eventId = eventDetail.id ?? ""
                        self.navigationController?.pushViewController(eventDetailVC, animated: true)
                    case .goals:
                        let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                        goalDetailController.goalId = eventDetail.id ?? ""
                        goalDetailController.selectedGoalName = eventDetail.name
                        self.navigationController?.pushViewController(goalDetailController, animated: true)
                    case .challenges:
                        let selectedVC:ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                        selectedVC.challengeId = eventDetail.id ?? ""
                        self.navigationController?.pushViewController(selectedVC, animated: true)
                }
            }
        }
    }

    extension ScheduleViewController {
        private func addNotificationObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name.challengeEdited, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name.goalEdited, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue:Constant.NotiName.editEvent),object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name(rawValue:Constant.NotiName.deleteEvent), object: nil)

        }

        @objc func refresh(_ not:Notification) {
            events.removeAll()
            alreadyGeneratedSet.removeAll()
            lastEndOfWeek = nil
            lastStartOfWeek = nil
            getEventListParams(complition: {})
        }


    }

    extension ScheduleViewController: CalendarDataSource {
        func eventsForCalendar(systemEvents: [EKEvent]) -> [Event] {
            return events
        }
    }

    extension ScheduleViewController: CalendarDelegate {

        func didSelectDates(_ dates: [Date], type: CalendarType, frame: CGRect?) {
            selectedDate = dates.first ?? Date()
            getEventListParams {
                self.events  = self.eventsForDate(self.selectedDate ?? Date())
                self.calendarView?.reloadData()
            }
            self.dateChanged?(selectedDate ?? Date())
        }

        func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
            guard let allEventsDetails = allEventsDetails else { return }
            var selectedEvents: [EventDetail] = []
            for allEventsDetail in allEventsDetails {
                selectedEvents.append(contentsOf: allEventsDetail.eventdata ?? [])
            }
            let selectedEvent = selectedEvents.filter { eventData in
                return eventData.id == event.ID //&& eventData.eventStartDate == event.start
            }
            if selectedEvent.count > 0 {
                didTapEvent(selectedEvent.first)
            }
        }
    }

