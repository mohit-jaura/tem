//
//  CalendarVC.swift
//  TemApp
//
//  Created by PrabSharan on 28/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import FSCalendar
import UIKit
import SSNeumorphicView

struct EventDetailsByDate {
    let date:Date?
    let eventsArr:[EventDetail]?
}
struct EventFound {
    var date: Date?
    var isEventFound: Bool = false
}

enum GoToCalendar: Int {
    case NextMonth = 101
    case PreMonth = 100
}
class CalendarVC: DIBaseController {
    
    var allEventsDetails:[EventDetail]?
    var allCalculatedEventsOfMonth:[EventDetail]?
    var eventsByDate:[EventDetailsByDate]?
    var calendarEventsArr:[EventDetail]?
    var selectedDayEvent:[EventDetail]?
    var isNeedToHitApi:Bool?
    var monthStartDate: Date?
    var monthEndDate: Date?
    var selectedMonthIndex: Int?
    var currentSelectedMonth: Int?
    var noDataFound:NoDataFound!
    var isnoDataIsAdded :Bool = false
    var groupId: String? // this will hold the value in case the data is to be viewed relative to a group
    var selectedDate: Date = Date()
    let gregorianCalendar = Calendar.current
    var eventDatesForMonth:[Date] = []
    
    // MARK: - Outlets
    var eventFounds = [EventFound]()
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedMonthLabel: UILabel!
    @IBOutlet weak var monthContainerView: SSNeumorphicView! {
        didSet { outShadowVer1(monthContainerView) } }
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var monthlyContainerView: SSNeumorphicView! { didSet { outShadowVer1(monthlyContainerView) }
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var monthlyWeeklySegmentOut: UISegmentedControl!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewEventButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            setToggleShadow(lineShadowView)
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
        }
    }
    @IBOutlet var calendarContainerShadowView: SSNeumorphicView! {
        didSet {
            setToggleShadow(calendarContainerShadowView)
            calendarContainerShadowView.viewNeumorphicCornerRadius = 8
            calendarContainerShadowView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intialise()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNeedToHitApi == true {
            isNeedToHitApi = nil
            apiToGetCalendarEventsByMonth()
        }
    }
    
    // MARK: Initialse UI
    private func intialise() {
        calendarInitialise()
        tableInitialise()
        setUpMonth(selectedDate)
        segmentInitialise()
    }
    
    private func tableInitialise() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = false
        tableView.register(EventCell.nib, forCellReuseIdentifier: EventCell.identifier)
    }
    
    private func calendarInitialise() {
        selectedDate = Date()
        calendarView.select(selectedDate)
        calendarView.setCurrentPage(selectedDate, animated: true)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.allowsMultipleSelection = false
        calendarView.appearance.titleDefaultColor = UIColor.appThemeColor
        calendarView.appearance.selectionColor = UIColor.appMainColour
        calendarView.appearance.titleSelectionColor = .white
        calendarView.appearance.todayColor = UIColor.clear
        calendarView.appearance.titleTodayColor = .appPurpleColor
        calendarView.appearance.titleFont = UIFont(name: UIFont.avenirNextMedium, size: 14)
        calendarView.appearance.weekdayFont = UIFont(name: UIFont.avenirNextMedium, size: 15)
        calendarView.appearance.subtitleFont = UIFont(name: UIFont.avenirNextMedium, size: 25)
        calendarView.appearance.borderRadius = 0.5
        initilaiseStartEndDate()
    }
    
    func segmentInitialise() {
        monthlyWeeklySegmentOut.layer.borderColor = UIColor.appMainColour.cgColor
        monthlyWeeklySegmentOut.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            monthlyWeeklySegmentOut.selectedSegmentTintColor = UIColor.appMainColour
        } else {
            monthlyWeeklySegmentOut.tintColor  = UIColor.appMainColour
        }
        monthlyWeeklySegmentOut.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        monthlyWeeklySegmentOut.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    // MARK: Main method after api hit, which will sorts dates
    private func showCalendarEvents() {
        DispatchQueue.global(qos: .background).async {
            self.filterEventsForTheDay()
            self.eventDatesForMonth =  self.getAllEventsDates()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.calendarView.reloadData()
            })
        }
    }
    
    private func getAllEventsDates()-> [Date] {
        guard let allEvents = calendarEventsArr else { return [] }
        var datesOnly:[Date] = []
        for ev in allEvents {
            if let dateString = ev.startDate?.date as? String { // we are getting UTC string from backend, and we need to convert it into local time.
                let date = timeZoneDateFormatter(format: .preDefined, timeZone: .current).date(from: dateString)!
                datesOnly.append(date.UTCToLocalDate(inFormat: .preDefined))
            }
        }
        return datesOnly
    }
    
    func dayDifference(start:Date,end:Date) -> Int{
        if let day = Calendar.current.dateComponents([.day], from: start, to: end).day{
            return day
        }
        return 0
    }
    /// This method select only one day events from filtering current date selection
    /// Comparison will be like eventStartDate <= SelectedDate <= eventEndDate
    func filterEventsForTheDay() {
        selectedDayEvent = []
        if let events = calendarEventsArr {
            for event in events {
                if let dateString = event.startDate?.date as? String { // we are getting UTC string from backend, and we need to convert it into local time.
                    let eventStartDate = timeZoneDateFormatter(format: .preDefined, timeZone: .current).date(from: dateString)!
                    if eventStartDate.UTCToLocalDate(inFormat: .preDefined).kvkIsEqual(selectedDate) {
                        var temp = event
                        temp.dateNumber = temp.eventStartDate.differenceBtwDates(endDate: selectedDate)?.day ?? 0
                        selectedDayEvent?.append(temp)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.hideLoader()
            self.tableView.reloadData()
        }
    }
    // MARK: This method helpss to set new month start and end date and we can use that method when scroll month
    
    func initilaiseStartEndDate() {
        self.showLoader()
        DispatchQueue.global(qos: .background).async {
            self.apiToGetCalendarEventsByMonth()
        }
    }
    
    func setUpMonth(_ date: Date) {
        let formatter = dateFormatter(format: .month)
        monthLbl.text = formatter.string(from: date).uppercased()
        currentSelectedMonth = Utility.Months.getIndex(monthLbl.text ?? "")
        let formatter2 = dateFormatter(format: .onlymonth)
        self.selectedMonthLabel.text = formatter2.string(from: date)
    }
    
    private func monthName(date: Date) -> String {
        let newDate = date.dateBySet(hour: 12, min: 0, secs: 0) ?? date
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        var format = "MMMM"
        df.setLocalizedDateFormatFromTemplate(format)
        return df.string(from: newDate)
    }
    
    // MARK: APIs Method
    func apiToGetCalendarEventsByMonth(_ completion:OnlySuccess? = nil) {
        self.selectedDayEvent = nil
        self.eventFounds = []
        self.calendarEventsArr = []
        let monthStartDateString = selectedDate.startOfMonth().addDay(n: -1).toString(inFormat: .preDefined) ?? ""
        let monthEndDateString = selectedDate.endDayOfMonth.addDay(n: 2).toString(inFormat: .preDefined) ?? ""
        let urlInfo = EndPoint.GetCalendarEvents(monthStartDateString, monthEndDateString)
        DIWebLayerEvent().getCalendarEvents(endPoint: urlInfo.url, params: urlInfo.params, parent: self, isLoader: false) {[weak self] status in
            DispatchQueue.main.async {
                self?.showLoader()
                switch status {
                    case .Success(let data, _):
                        if let arrayEvents = data as? [EventDetail] {
                            self?.calendarEventsArr = arrayEvents
                            self?.showCalendarEvents()
                            completion?()
                        }
                    case .NoDataFound:
                        self?.hideLoader()
                        self?.selectedDayEvent = nil
                        self?.eventFounds = []
                        self?.calendarEventsArr = []
                        self?.showCalendarEvents()
                        self?.tableView.reloadData()
                        self?.calendarView.reloadData()
                    case .Failure(let message):
                        self?.hideLoader()
                        self?.alertOpt(message)
                }
            }
        }
    }
    // Delete event api
    private func callDeleteEventAPI(_ deleteType: DeleteEventType = .allFutureEvents, eventDetails: EventDetail?,completion:OnlySuccess? = nil) {
        guard isConnectedToNetwork() else { return }
        self.showLoader()
        let params = getParamsToDeleteEvent(deleteType,eventDetails: eventDetails)
        DIWebLayerEvent().updateEvent(parameter: params, success: { [weak self] (message) in
            if completion == nil {
                self?.apiToGetCalendarEventsByMonth({
                    DispatchQueue.main.async {
                        self?.hideLoader()
                        self?.alertOpt("Event deleted successfully.")
                    }
                })
            } else { // In case if a user delete event from next screen so need only delete api to hit
                self?.isNeedToHitApi = true
                completion?()
            }
            
        }, failure: { [weak self](error) in
            DispatchQueue.main.async {
                self?.hideLoader()
                self?.alertOpt(error?.message)
            }
        })
    }
    // MARK: All Actions
    
    @IBAction func addEventTapped(_ sender: UIButton) {
        openCreateEventVC()
    }
    func openCreateEventVC() {
        let createEventVC: CreateEventViewController = UIStoryboard(storyboard: .createevent).initVC()
        createEventVC.delegate = self
        self.navigationController?.pushViewController(createEventVC, animated: true)
    }
    @IBAction func monthChangeAction(_ sender: UIButton) {
        if let action = GoToCalendar(rawValue: sender.tag) {
            switch action {
                case .NextMonth:
                    selectedDate = gregorianCalendar.date(byAdding: .month, value: 1, to: selectedDate)!.startDayOfMonth
                case .PreMonth:
                    selectedDate = gregorianCalendar.date(byAdding: .month, value: -1, to: selectedDate)!.startDayOfMonth
            }
            calendarView.select(selectedDate, scrollToDate: true)
            setUpWeeklyCalendar()
        }
    }
    
    @IBAction func monthlyWeeklyAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            if let eventDayVC = containerView.parentViewController?.children.first as? EventDayVC {
                self.selectedDate = eventDayVC.selectedDate ?? Date()
                calendarView.select(selectedDate, scrollToDate: true)
                eventDayVC.dateChanged = { date in
                    self.selectedDate = date
                    self.calendarView.select(date, scrollToDate: true)
                }
                showCalendarEvents()
            }
        } else {
            setUpWeeklyCalendar()
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveLinear], animations: {
            self.containerView.alpha = sender.selectedSegmentIndex == 0 ? 0 : 1
        }, completion: nil)
    }
    
    private func setUpWeeklyCalendar() {
        if let eventDayVC = containerView.parentViewController?.children.first as? EventDayVC {
            eventDayVC.selectedDate = selectedDate
            if let calendarType = eventDayVC.calendarView?.selectedType {
                eventDayVC.calendarView?.set(type: calendarType, date: self.selectedDate)
            }
            eventDayVC.getEventListParams {
                eventDayVC.events = eventDayVC.eventsForDate(eventDayVC.selectedDate ?? Date())
                eventDayVC.calendarView?.reloadData()
            }
            eventDayVC.dateChanged = { date in
                self.setUpMonth(date)
            }
        }
    }
    
    func addNotiForMonthChanged(action: GoToCalendar) {
        if let eventDayVC = containerView.parentViewController?.children.first as? EventDayVC {
            switch action {
                case .NextMonth:
                    eventDayVC.selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)
                case .PreMonth:
                    eventDayVC.selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)
            }
        }
        
    }
}
// MARK: Calendar delegate Methods
extension CalendarVC {
    
    func compareTwoDates(_ date1:Date?,_ date2:Date?) -> Bool {
        guard let date1 = date1, let date2 = date2 else {return true }
        return Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }
}

// MARK: Other methods like delete event, did tapped event details
extension CalendarVC {
    
    func deleteEvent(eventDetail: EventDetail?) {
        if let recurrEvent = eventDetail?.reccurEvent, let recurrEventType = RecurrenceType(rawValue: recurrEvent) {
            if recurrEventType != .doesNotRepeat {
                let arrayList = DeleteEventType.allCases.map({$0.getTitle()})
                self.showSelectionModal(array: arrayList, type: .deleteEvent) {[weak self] selectedOption in
                    if let deleteEventType = DeleteEventType(rawValue: selectedOption.row) {
                        self?.callDeleteEventAPI(deleteEventType, eventDetails: eventDetail)
                    }
                }
            } else {
                self.showAlert(withTitle: "", message: AppMessages.Event.delete, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: AppMessages.AlertTitles.Cancel, okStyle: .default, okCall: {
                    self.callDeleteEventAPI(eventDetails: eventDetail)
                }, cancelCall: {
                })
            }
        }
    }
    // This method is used to delete a event.
    func getParamsToDeleteEvent(_ deleteType: DeleteEventType = .allFutureEvents, eventDetails: EventDetail?) -> [String:Any] {
        let date = (deleteType == .allFutureEvents) ? "0" : timeZoneDateFormatter(format: .eventUtcDateString, timeZone: utcTimezone).string(from: eventDetails?.eventStartDate ?? Date())
        var params: [String:Any] = [:]
        params["userId"] = User.sharedInstance.id ?? ""
        params["is_deleted"] = 1
        params["_id"] = eventDetails?.id ?? ""
        params["reccurEvent"] = eventDetails?.reccurEvent ?? 0
        params["updatedFor"] = date
        params["updateAllEvents"] = deleteType.rawValue
        params["rootUpdatedFor"] = eventDetails?.rootUpdatedFor ?? ""
        return params
    }
    
    func didClickOnEventDetails(_ eventDetails:EventDetail?) {
        guard let eventDetails = eventDetails, let eventType = eventDetails.eventType else {return}
        switch eventType {
            case .regular, .signupSheet:
                let eventDetailVC: EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
                eventDetailVC.delegate = self
                eventDetailVC.eventDetail = eventDetails
                eventDetailVC.eventId = eventDetails.id ?? ""
                eventDetailVC.selectedEventDate = timeZoneDateFormatter(format: .eventUtcDateString, timeZone: utcTimezone).string(from: eventDetails.eventStartDate)
                self.navigationController?.pushViewController(eventDetailVC, animated: true)
            case .challenges:
                let selectedVC: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                selectedVC.challengeId = eventDetails.id ?? ""
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .goals:
                let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                goalDetailController.goalId = eventDetails.id ?? ""
                goalDetailController.selectedGoalName = eventDetails.name
                self.navigationController?.pushViewController(goalDetailController, animated: true)
        }
    }
}
extension CalendarVC: EventDelegate {
    func backTapped() {
        isNeedToHitApi = true
    }
    
    func updateEvent(editMode: EditRecurringEventMode, eventDetail: EventDetail?, section: Int) {
        isNeedToHitApi = true
    }
    
    func updateEventList(section: Int, eventID: String) {
        isNeedToHitApi = true
    }
    
    func deleteEvent(section: Int, eventId: String, deleteType: DeleteEventType) {
        self.showLoader()
        isNeedToHitApi = true
    }
}

