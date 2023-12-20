//
//  CalendarViewController.swift
//  TemApp
//
//  Created by dhiraj on 09/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Alamofire
import SSNeumorphicView
enum GoToCalendar: Int {
    case NextMonth = 101
    case PreMonth = 100
}
class CalendarViewController: DIBaseController {
    @IBOutlet weak var selectedMonthLabel: UILabel!
    @IBOutlet weak var monthContainerView: SSNeumorphicView! {
        didSet {
            outShadowVer1(monthContainerView)
        }
    }
    @IBOutlet weak var monthlyContainerView: SSNeumorphicView! {
        didSet {
            outShadowVer1(monthlyContainerView)
        }
    }
    @IBOutlet weak var containerView: UIView!
    // MARK: @IBOutlet Variables
    @IBOutlet weak var monthlyWeeklySegmentOut: UISegmentedControl!
    @IBOutlet var calendarView: JTAppleCalendarView!
    var selectedMonthIndex: Int?
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewEventButton: UIButton!
    @IBOutlet var dayLabels: [UILabel]!
    private var selectedDate: Date = Date()
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet var calendarContainerShadowView: SSNeumorphicView! {
        didSet {
            calendarContainerShadowView.viewDepthType = .innerShadow
            calendarContainerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.09).cgColor
            calendarContainerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
            calendarContainerShadowView.viewNeumorphicMainColor = calendarContainerShadowView.backgroundColor?.cgColor
            calendarContainerShadowView.viewNeumorphicCornerRadius = 8
        }
    }
    // MARK: Variables
    var startDate = Date()
    var monthStartDate = Date()
    var monthEndDate = Date().endDayOfMonth
    let dateGenerator = JTAppleDateConfigGenerator()
    var monthEventList: [Int: [EventDetail]]?
    var eventList: [EventDetail] = []
    var calendarCalculation: (months: [Month], monthMap: [Int: Int], totalSections: Int, totalDays: Int)?
    var weeklySlotList: [Int: [WeekSlot]] = [:]
    var monthLblDate: Date?
    var isAPICall = false
    var eventDetail: EventDetail?
    var deletedSection = 0
    var isCreateEventPushed = false
    var isEventDetailPushed = false
    var eventDayVC: EventDayVC?
    var groupId: String? // this will hold the value in case the data is to be viewed relative to a group
    var monthFilteredEventList: [EventDetail] = []
    private var monthlyFilteredEventsDict = [Int: [EventDetail]]()
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializer()
    }
    
    func segmentInitialise() {
        monthlyWeeklySegmentOut.layer.borderColor = UIColor.appMainColour.cgColor
        monthlyWeeklySegmentOut.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            monthlyWeeklySegmentOut.selectedSegmentTintColor = UIColor.appMainColour
        } else {
            monthlyWeeklySegmentOut.tintColor  = UIColor.appMainColour
        }
        if #available(iOS 13.0, *) {
            monthlyWeeklySegmentOut.selectedSegmentTintColor = UIColor.appMainColour
        } else {
            monthlyWeeklySegmentOut.tintColor  = UIColor.appMainColour
        }
        monthlyWeeklySegmentOut.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        monthlyWeeklySegmentOut.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isCreateEventPushed = false
        self.navigationController?.navigationBar.isHidden = true
        if let headerView = tableView?.tableHeaderView as? UIView {
            headerView.frame.size.height = self.view.frame.height/2
            tableView.tableHeaderView = headerView
        }
        if isEventDetailPushed {
            isEventDetailPushed = false
            callEventListAPI(date: monthStartDate)
        }
    }
    func addNotiForMonthChanged(action: GoToCalendar) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.monthChanged), object: nil, userInfo: ["action": action])
    }
    @IBAction func monthChangeAction(_ sender: UIButton) {
        if let action = GoToCalendar(rawValue: sender.tag) {
            switch action {
                case .NextMonth:
                    calendarView.scrollToSegment(SegmentDestination.next)
                case .PreMonth:
                    calendarView.scrollToSegment(SegmentDestination.previous)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        self.deallocCalendar()
        super.didReceiveMemoryWarning()
    }
    // MARK: Methods
    // This method is used to intiliaze value when controller apper first time.
    func initializer() {
        self.addShadows()
        self.containerView.alpha = 0
        if groupId != nil {
            self.addNewEventButton.isHidden = true
        }
        segmentInitialise()
        monthEventList = [:]
        let month = self.dateFormatter(format: .month).string(from: Date())
        self.monthLbl.text = month.uppercased()
        self.selectedMonthLabel.text = self.dateFormatter(format:
                .onlymonth).string(from: Date()).uppercased()
        DispatchQueue.main.async {
            self.configureWeekSlots()
        }
        callBackForDateChangeFromDayEvent()
        self.configureCalendarUI(calendar: self.calendarView)
    }
    func callBackForDateChangeFromDayEvent() {
        if let vc = containerView.parentViewController?.children.first as? EventDayVC {
            eventDayVC = vc
            eventDayVC?.dateChanged = {[weak self](changedDate) in
                self?.selectedDate = changedDate
            }
        }
    }
    private func addShadows() {
        searchButton.addDoubleShadowToButton(cornerRadius: searchButton.frame.height / 2, shadowRadius: searchButton.frame.height / 2, lightShadowColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3), shadowBackgroundColor: searchButton.backgroundColor ?? UIColor.black)
        addNewEventButton.addDoubleShadowToButton(cornerRadius: addNewEventButton.frame.height / 2, shadowRadius: addNewEventButton.frame.height / 2, lightShadowColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3), shadowBackgroundColor: addNewEventButton.backgroundColor ?? UIColor.black)
        _ = self.dayLabels.map({$0.addShadowToText(color: UIColor.black.withAlphaComponent(0.56), radius: 3, opacity: 1, offset: CGSize(width: 1, height: 1))})
    }
    // This method is used to calculate slots of weeks as per month.
    func configureWeekSlots() {
        if let monthMap = calendarCalculation?.monthMap {
            // Number of month in between two interval which is set in calendar.
            for value in 0..<monthMap.count {
                var slots: [WeekSlot] = []
                if calendarView != nil {
                    if let info = calendarView?.monthInfoFromSection(value) {
                        // Get number of weeks in a month.
                        let weeks = Utility.numberOfWeeksInMonth(info.range.start)
                        for value in 0..<weeks {
                            // Caluclate slots of weeks in a month
                            let weekStartDate = info.range.start.startOfWeek.addDuration(n: value * 7, type: .day)
                            let weekEndDate = info.range.start.endOfWeek.addDuration(n: value * 7, type: .day)
                            if info.range.start.startOfMonth() == weekStartDate.startOfMonth() {
                                let slot = WeekSlot(startDate: weekStartDate, endDate: weekEndDate, eventList: [])
                                slots.append(slot)
                            }
                        }
                    }
                }
                weeklySlotList[value] = slots
            }
        }
        if self.tableView != nil {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func monthlyWeeklyAction(_ sender: UISegmentedControl) {
        if  eventDayVC == containerView.parentViewController?.children.first as? EventDayVC {
            eventDayVC?.selectedDate = selectedDate
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveLinear], animations: {
            self.containerView.alpha = sender.selectedSegmentIndex == 0 ? 0 : 1
        }, completion: nil)
    }
    // This method is used to navigate to partiuclar date in month list
    func scrollToMonthDate(_ date: Date) {
        if calendarView != nil {
            if let indexPath =  self.calendarView.pathsFromDates([date.startOfDay]).first {
                if indexPath.section < calendarCalculation?.monthMap.count ?? 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let indexPath = IndexPath(row: 0, section: indexPath.section)
                        if self.tableView != nil {
                            // self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                        if let info = self.calendarView.monthInfoFromSection(indexPath.section) {
                            self.monthLblDate = info.range.start
                            let month = self.dateFormatter(format: .month).string(from: info.range.start)
                            self.monthLbl.text = month.uppercased()
                            self.selectedMonthLabel.text = self.dateFormatter(format: .onlymonth).string(from: info.range.start).uppercased()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.monthLblDate = nil
                        }
                    }
                }
            }
        }
    }
    // This method is used to configure user interface of calendar.
    func configureCalendarUI(calendar: JTAppleCalendarView) {
        calendar.scrollToDate(Date(), animateScroll: false)
        calendar.scrollDirection = .horizontal
        calendar.scrollingMode   = .stopAtEachCalendarFrame
        calendar.showsHorizontalScrollIndicator = false
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        calendar.cellSize = (UIScreen.main.bounds.size.width - 50)/7 // subtracting 50 , because the view has leading and trailing constants of 25 with the main screen.
    }
    func dayRangeOf(weekOfYear: Int, for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let startComponents = DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: year)
        guard let  startDate = calendar.date(from: startComponents) else {
            return (Date(), Date())
        }
        let endComponents = DateComponents(day: 7, second: -1)
        guard let endDate = calendar.date(byAdding: endComponents, to: startDate) else {
            return (Date(), Date())
        }
        return (startDate, endDate)
    }
    // This method is used to show month in the navigation title.
    func setUpMonth(_ date: Date) {
        let formatter = dateFormatter(format: .month)
        monthLbl.text = formatter.string(from: date).uppercased()
        self.selectedMonthLabel.text = self.dateFormatter(format: .onlymonth).string(from: date).uppercased()
        changeMonthActionForDayEvent()
    }
    func changeMonthActionForDayEvent() {
        let index = Utility.Months.getIndex(self.selectedMonthLabel.text ?? "")
        // We are coming first time so no need to fire notification for month change in Day view
        if let preMonthIndex = selectedMonthIndex {
            if index != preMonthIndex, let action = Utility.Months.actionType(preMonthIndex, index ?? 0) {
                selectedMonthIndex = index
                addNotiForMonthChanged(action: action)
            }
        } else {
            selectedMonthIndex = index
        }
    }
    // This method is used to show dates.
    func configureCell(view: JTAppleCell?, cellState: CellState, calendar: JTAppleCalendarView) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        if calendar == self.calendarView {
            hideAllData(cell: cell)
        } else {
            cell.eventView.isHidden = true
        }
        if eventList.count > 0 {
            DispatchQueue.global(qos: .userInteractive).async {
                let filteredList = self.getFilteredEventList(cellState)
                DispatchQueue.main.async {
                    if calendar == self.calendarView {
                        self.handleCellData(cell: cell, cellState: cellState, list: filteredList)
                    } else {
                        self.handleMonthViewCellData(cell: cell, cellState: cellState, list: filteredList)
                    }
                }
            }
        }
    }
    // This method is used to handle dates visibility of current visible month.
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.newThemeBlueTextColor
        } else {
            cell.dateLabel.textColor = UIColor(red: 167.0 / 255.0, green: 186.0 / 255.0, blue: 200.0 / 255.0, alpha: 1)
        }
        if Calendar.current.isDateInToday(cellState.date) {
            cell.dateLabel.textColor = UIColor.appPurpleColor
        }
    }
    func getFilteredEventList(_ cellState: CellState) -> [Int] {
        let filteredList = self.eventList.compactMap { (eventDetail) -> Int? in
            if eventDetail.eventStartDate.startOfDay < eventDetail.eventEndDate.endOfDay {
                let range = eventDetail.eventStartDate.startOfDay...eventDetail.eventEndDate.endOfDay
                if range.contains(cellState.date.startOfDay) {
                    return eventDetail.eventType?.rawValue
                }
            }
            return nil
        }
        return filteredList
    }
    func hideAllData(cell: DateCell) {
        cell.goalImgVw.isHidden = true
        cell.challengeImgVw.isHidden = true
        cell.activityImgVw.isHidden = true
        cell.showMoreLbl.isHidden = true
    }
    // This method is used to handle challenges, Activity, goals data.
    func handleCellData(cell: DateCell, cellState: CellState, list: [Int]) {
        if list.count > 0 {
            cell.activityImgVw.isHidden = list.isEmpty
        }
    }
    // This method is used to handle challenges, Activity, goals data.
    func handleMonthViewCellData(cell: DateCell, cellState: CellState, list: [Int]) {
        cell.eventView.isHidden = true
        if list.count > 0 {
            cell.eventView.isHidden = false
            return
        } else {
            cell.eventView.isHidden = true
        }
    }
    // This method is used to get params for get event list api.
    func getEventListParams(isParticularDaySelect: Bool = false) -> Parameters {
        if isParticularDaySelect {
            let monthStartDateString = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone).string(from: selectedDate)
            let monthEndDateString = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone).string(from: selectedDate)
            let delimiter = "T"
            let newstr = monthStartDateString
            let token = newstr.components(separatedBy: delimiter)
            let startDate = "\(token[0])T00:30:59.000+0000"
            let endDate = "\(token[0])T18:29:00.000+0000"
            var params = [
                "startDate": startDate,
                "endDate": endDate
            ]
            if let groupId = self.groupId {
                params["group_id"] = groupId
            }
            return params
        } else {
            self.setUpMonth(monthStartDate)
            let monthStartDateString = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone).string(from: monthStartDate)
            let monthEndDateString = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone).string(from: monthEndDate.endOfDay)
            var params = [
                "startDate": monthStartDateString,
                "endDate": monthEndDateString
            ]
            if let groupId = self.groupId {
                params["group_id"] = groupId
            }
            return params
        }
    }
    // This method is used to get event list.
    // This function will call API to save data on backend server....
    @objc private func getEventList(section: Any) {
        var sectionToLoad = 0
        var isTableReload = false
        if let value = section as? (section: Int, isReload: Bool) {
            sectionToLoad = value.section
            isTableReload = value.isReload
        }
        if let value = section as? Int {
            sectionToLoad = value
        }
        if let eventList = self.monthEventList?[sectionToLoad] {
            if eventList.count >= 0 {
                self.eventList = eventList
                self.configureSlots(sectionToLoad)
                self.updateEventInView()
                if self.tableView != nil {
                    self.tableView.reloadData()
                }
                return
            }
        }
        if tableView != nil {
            self.tableView.reloadData()
        }
        self.callEventListAPI(sectionToLoad, isReload: isTableReload)
    }
    // This method is usd to call api to get events
    private func callEventListAPI(isParticularDaySelect: Bool = false, _ section: Int = 0, isReload: Bool = false) {
        guard isConnectedToNetwork() else {
            return
        }
        DIWebLayerEvent().getEventList(parameter: getEventListParams(isParticularDaySelect: isParticularDaySelect), success: { (eventListResponse) in
            self.hideLoader()
            if let eventList = eventListResponse {
                self.isAPICall = true
                let filteredList = eventList.sorted(by: {$0.showingDate?.compare($1.showingDate ?? Date()) == .orderedAscending})
                self.monthEventList?[section] = filteredList
                self.eventList = filteredList
                DispatchQueue.global(qos: .userInteractive).async {
                    self.configureSlots(section)
                    self.monthFilteredEventList.removeAll()
                    for event in self.eventList {
                        self.monthFilteredEventList.append(contentsOf: self.getEventsFilteredWithDates(event.eventStartDate, event.eventEndDate, event))
                    }
                    self.monthFilteredEventList = self.monthFilteredEventList.sorted(by: {$0.showingDate?.compare($1.showingDate ?? Date()) == .orderedAscending})
                    self.monthlyFilteredEventsDict[section] = self.monthFilteredEventList
                    DispatchQueue.main.async {
                        if self.tableView != nil {
                            self.tableView.reloadData()
                        }
                        self.updateEventInView()
                        if isReload {
                            if self.tableView != nil {
                            }
                        }
                    }
                }
            } else {
            }
        }, failure: { (error) in
            self.hideLoader()
            if let error = error {
                self.showAlert(withError: error)
            }
        })
    }
    // This method is used to update list in calendar
    private func updateEventInView() {
        guard self.calendarView != nil else {
            return
        }
        self.calendarView.reloadData()
    }
    // THis method is used to configure event in slot wise.
    func configureSlots(_ section: Int) {
        if let slots = weeklySlotList[section] {
            for value in slots.enumerated() {
                let slot = value.element
                let events = self.getFilteredEventList(section, slot.startDate, slot.endDate)
                slots[value.offset].eventList = events
            }
        }
    }
    // This method is used to get filtered event list by date.
    func getFilteredEventList(_ section: Int, _ startDate: Date, _ endDate: Date) -> [EventDetail] {
        // Get dates of slots and get events according to dates.
        let dates = Date.dates(from: startDate, to: endDate)
        var filteredList: [EventDetail] = []
        var nextEventList: [EventDetail] = []
        for value in dates {
            var dateNumber = 0
            if let events = self.monthEventList?[section]?.compactMap({ (eventDetail) -> EventDetail? in
                if eventDetail.eventStartDate.startOfDay < eventDetail.eventEndDate.endOfDay {
                    let range = eventDetail.eventStartDate.startOfDay...eventDetail.eventEndDate.endOfDay
                    if range.contains(value.startOfDay) {
                        dateNumber += 1
                        var detail = eventDetail
                        detail.dateNumber = dateNumber
                        detail.showingDate = value.startOfDay
                        return detail
                    }
                }
                return nil
            }) {
                filteredList.append(contentsOf: events)
            }
            if calendarCalculation?.monthMap.count ?? 0 > section {
                if calendarView != nil {
                    if let monthInfo = calendarView.monthInfoFromSection(section+1) {
                        if monthInfo.range.start.isBetween(date: startDate, andDate: endDate) {
                            var number = 0
                            if let events = self.monthEventList?[section+1]?.compactMap({ (eventDetail) -> EventDetail? in
                                if eventDetail.eventStartDate.startOfDay < eventDetail.eventEndDate.endOfDay {
                                    let range = eventDetail.eventStartDate.startOfDay...eventDetail.eventEndDate.endOfDay
                                    if range.contains(value.startOfDay) {
                                        number += 1
                                        var detail = eventDetail
                                        detail.dateNumber = number
                                        detail.showingDate = value.startOfDay
                                        return detail
                                    }
                                }
                                return nil
                            }) {
                                nextEventList.append(contentsOf: events)
                            }
                        }
                    }
                }
            }
        }
        if  nextEventList.count > 0 {
            nextEventList = nextEventList.sorted(by: {$0.showingDate?.compare($1.showingDate ?? Date()) == .orderedAscending})
            filteredList.append(contentsOf: nextEventList)
        }
        filteredList = filteredList.sorted(by: {$0.showingDate?.compare($1.showingDate ?? Date()) == .orderedAscending})
        return filteredList
    }
    private func getEventsFilteredWithDates(_ startDate: Date, _ endDate: Date, _ eventDetail: EventDetail) -> [EventDetail] {
        // Get dates of slots and get events according to dates.
        let dates = Date.dates(from: startDate, to: endDate)
        var filteredList: [EventDetail] = []
        for value in dates {
            var dateNumber = 0
            if eventDetail.eventStartDate.startOfDay < eventDetail.eventEndDate.endOfDay {
                let range = eventDetail.eventStartDate.startOfDay...eventDetail.eventEndDate.endOfDay
                if range.contains(value.startOfDay) {
                    dateNumber += 1
                    var detail = eventDetail
                    detail.dateNumber = dateNumber
                    detail.showingDate = value.startOfDay
                    filteredList.append(detail)
                }
            }
        }
        return filteredList
    }
    // This method is used to navigate month calendar to particular month.
    private func navigateToMonthView(date: Date) {
        self.calendarView.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if let indexPath =  self.calendarView.pathsFromDates([date.startOfDay]).first {
                self.calendarView.reloadSections([indexPath.section])
            }
        }
        let month = self.dateFormatter(format: .month).string(from: date)
        self.monthLbl.text = month.uppercased()
        self.selectedMonthLabel.text = self.dateFormatter(format: .onlymonth).string(from: date).uppercased()
    }
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .deleteEvent {
            if let deleteEventType = DeleteEventType(rawValue: index) {
                CalendarManager.shared.deleteEventFromiCal(deleteEventType, eventDetail)
                self.callDeleteEventAPI(deleteEventType, section: deletedSection)
            }
        }
    }
    // This method is used to delete a event.
    private func callDeleteEventAPI(_ deleteType: DeleteEventType = .allFutureEvents, section: Int) {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        var params = [
            "userId": User.sharedInstance.id ?? "",
            "is_deleted": 1,
            "_id": eventDetail?.id ?? "",
            "reccurEvent": self.eventDetail?.reccurEvent ?? 0,
            "updatedFor": deleteType == .allFutureEvents ? 0 : timeZoneDateFormatter(format: .eventUtcDateString, timeZone: utcTimezone).string(from: eventDetail?.eventStartDate ?? Date()),
            "updateAllEvents": deleteType.rawValue
        ] as [String: Any]
        if let updateFor = self.eventDetail?.rootUpdatedFor {
            params["rootUpdatedFor"] = updateFor
        }
        DIWebLayerEvent().updateEvent(parameter: params, success: { (message) in
            self.deleteEventCompletion(eventId: self.eventDetail?.id ?? "", deleteType: deleteType)
            self.hideLoader()
            self.showAlert(message: "Event deleted successfully.", okCall: {
            })
        }, failure: { (error) in
            self.hideLoader()
            if let error =  error {
                self.showAlert(withError: error)
            }
        })
    }
    // on dismissing the activity sheet, reset the border color of the textfield to default gray
    override func cancelSelection(type: SheetDataType) {
    }
    // This method is used to dealloc memory when controller is pop.
    private func deallocCalendar() {
        if calendarView.superview != nil {
            calendarView.removeFromSuperview()
        }
        if tableView.superview != nil {
            tableView.removeFromSuperview()
        }
        weeklySlotList = [:]
        monthEventList = [:]
        eventList = []
    }
    // MARK: @IBAction Methods
    @IBAction func backTapped(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.deallocCalendar()
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addEventTapped(_ sender: UIButton) {
        if !isCreateEventPushed {
            isCreateEventPushed = true
            let createEventVC: CreateEventViewController = UIStoryboard(storyboard: .createevent).initVC()
            createEventVC.delegate = self
            self.navigationController?.pushViewController(createEventVC, animated: true)
        }
    }
    @IBAction func monthViewTapped(_ sender: UIButton) {
        self.navigateToMonthView(date: monthStartDate)
    }
    @IBAction func listViewTapped(_ sender: UIButton) {
    }
}

// This method is used to configure datasource for calendar.
extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        startDate = dateFormatter(format: .calendar).date(from: Constant.Calendar.startDate) ?? Date()
        let endDate = Constant.Calendar.endDate
        let configureParams = ConfigurationParameters(startDate: startDate,
                                                      endDate: endDate,
                                                      calendar: Calendar.current,
                                                      firstDayOfWeek: .sunday)
        calendarCalculation = dateGenerator.setupMonthInfoDataForStartAndEndDate(configureParams)
        return configureParams
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    func callEventListAPI(date: Date) {
        if let indexPath =  self.calendarView.pathsFromDates([date.startOfDay]).first {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.getEventList(section: indexPath.section)
                self.scrollToMonthDate(date)
            }
        }
    }
    func updateCalendarOnScroll(_ calendar: JTAppleCalendarView, date: Date) {
        self.setUpMonth(date)
        self.monthStartDate = date.startOfMonth()
        self.monthEndDate = date.endDayOfMonth
        if calendar == calendarView {
            callEventListAPI(date: date.startOfDay)
        } else {
            calendarView.scrollToDate(date, triggerScrollToDateDelegate: false)
        }
    }
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DateCell.reuseIdentifier, for: indexPath) as? DateCell else {
            return DateCell()
        }
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState, calendar: calendar)
    }
    // This method is call when calendar is scroll.
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let date = visibleDates.monthDates.first?.date {
            updateCalendarOnScroll(calendar, date: date)
        }
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        selectedDate = date.addDay(n: 1)
        if calendar == calendarView {
            self.callEventListAPI(isParticularDaySelect: true, calendar.currentSection() ?? 0, isReload: true)
        } else {
        }
        self.scrollToMonthDate(date)
    }
}
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableCell(withIdentifier: MonthCell.reuseIdentifier) as? MonthCell else {
            return UIView()
        }
        if let info = calendarView.monthInfoFromSection(section) {
            let month = self.dateFormatter(format: .month).string(from: info.range.start)
            header.monthLbl.text = month.uppercased()
            self.selectedMonthLabel.text = self.dateFormatter(format: .onlymonth).string(from: info.range.start).uppercased()
        }
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        view.backgroundColor = .white
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude// 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = calendarView.currentSection() {
            return self.monthlyFilteredEventsDict[currentSection]?.count ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.reuseIdentifier) as? EventCell else {
            return UITableViewCell()
        }
        if let list = self.monthlyFilteredEventsDict[calendarView.currentSection() ?? 0],
           list.count > indexPath.row {
            let eventDetail = list[indexPath.row]// slot.eventList[indexPath.row]
            cell.delegate = self
            cell.detailsButton.row = indexPath.row
            cell.detailsButton.section = calendarView.currentSection() ?? 0
            cell.configureCell(eventDetail)
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: AppMessages.NetworkMessages.delete) { _, _ in
            if let list = self.monthlyFilteredEventsDict[self.calendarView.currentSection() ?? 0],
               list.count > editActionsForRowAt.row {
                let eventDetail = list[editActionsForRowAt.row]
                self.deleteEvent(eventDetail: eventDetail)
            }
        }
        delete.backgroundColor = UIColor(0xFF6363)
        return [delete]
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let list = self.monthlyFilteredEventsDict[self.calendarView.currentSection() ?? 0],
           list.count > indexPath.row && (eventDetail?.isProgramEvent == 0){
            let eventDetail = list[indexPath.row]
            return eventDetail.eventType == EventType.regular ? true : false
        }
        return false
    }
}

extension CalendarViewController: EventSlotsCellDelegate {
    func deleteEvent(eventDetail: EventDetail, section: Int) {
        self.eventDetail = eventDetail
        self.deletedSection = section
        if let recurrEvent = eventDetail.reccurEvent, let recurrEventType = RecurrenceType(rawValue: recurrEvent) {
            if recurrEventType != .doesNotRepeat {
                let arrayList = DeleteEventType.allCases.map({$0.getTitle()})
                self.showSelectionModal(array: arrayList, type: .deleteEvent)
            } else {
                self.showAlert(withTitle: "", message: AppMessages.Event.delete, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: AppMessages.AlertTitles.Cancel, okStyle: .default, okCall: {
                    self.callDeleteEventAPI(section: section)
                }, cancelCall: {
                })
            }
        }
    }
    func eventSelect(eventDetail: EventDetail, section: Int) {
        if !self.isEventDetailPushed {
            if let eventType = eventDetail.eventType {
                if eventType == .regular || eventType == .signupSheet {
                    if self.isConnectedToNetwork() {
                        let eventDetailVC: EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
                        eventDetailVC.delegate = self
                        eventDetailVC.eventDetail = eventDetail
                        eventDetailVC.eventId = eventDetail.id ?? ""
                        eventDetailVC.section = section
                        self.isEventDetailPushed = true
                        self.navigationController?.pushViewController(eventDetailVC, animated: true)
                    }
                } else if eventType == .challenges {
                    if self.isConnectedToNetwork() {
                        let selectedVC: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                        selectedVC.challengeId = eventDetail.id ?? ""
                        self.isEventDetailPushed = true
                        self.navigationController?.pushViewController(selectedVC, animated: true)
                    }
                } else if eventType == .goals {
                    if self.isConnectedToNetwork() {
                        let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                        goalDetailController.goalId = eventDetail.id ?? ""
                        goalDetailController.selectedGoalName = eventDetail.name
                        self.isEventDetailPushed = true
                        self.navigationController?.pushViewController(goalDetailController, animated: true)
                    }
                }
            }
        }
    }
}
// MARK: EventCellDelegate
extension CalendarViewController: EventCellDelegate {
    func deleteEvent(eventDetail: EventDetail) {
        self.eventDetail = eventDetail
        if let recurrEvent = eventDetail.reccurEvent, let recurrEventType = RecurrenceType(rawValue: recurrEvent) {
            if recurrEventType != .doesNotRepeat {
                let arrayList = DeleteEventType.allCases.map({$0.getTitle()})
                self.showSelectionModal(array: arrayList, type: .deleteEvent)
            } else {
                self.showAlert(withTitle: "", message: AppMessages.Event.delete, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: AppMessages.AlertTitles.Cancel, okStyle: .default, okCall: {
                    self.callDeleteEventAPI(section: self.calendarView.currentSection() ?? 0)
                }, cancelCall: {
                })
            }
        }
    }
    func didClickOnEventDetails(sender: CustomButton) {
        let currentCalendarSection = sender.section
        if let eventList = self.monthlyFilteredEventsDict[currentCalendarSection] {
            if !self.isEventDetailPushed {
                let eventDetail = eventList[sender.row]
                if let eventType = eventDetail.eventType {
                    if eventType == .regular || eventType == .signupSheet {
                        if self.isConnectedToNetwork() {
                            let eventDetailVC: EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
                            eventDetailVC.delegate = self
                            eventDetailVC.eventDetail = eventDetail
                            eventDetailVC.eventId = eventDetail.id ?? ""
                            self.isEventDetailPushed = true
                            self.navigationController?.pushViewController(eventDetailVC, animated: true)
                        }
                    } else if eventType == .challenges {
                        if self.isConnectedToNetwork() {
                            let selectedVC: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                            selectedVC.challengeId = eventDetail.id ?? ""
                            self.isEventDetailPushed = true
                            self.navigationController?.pushViewController(selectedVC, animated: true)
                        }
                    } else if eventType == .goals {
                        if self.isConnectedToNetwork() {
                            let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                            goalDetailController.goalId = eventDetail.id ?? ""
                            goalDetailController.selectedGoalName = eventDetail.name
                            self.isEventDetailPushed = true
                            self.navigationController?.pushViewController(goalDetailController, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension CalendarViewController: EventDelegate {
    func deleteEvent(section: Int, eventId: String, deleteType: DeleteEventType) {
    }
    func resetFields() {
        self.monthEventList = nil
        self.monthEventList = [:]
        self.eventList = []
        self.monthFilteredEventList.removeAll()
        self.monthlyFilteredEventsDict = [:]
        for eventDict in weeklySlotList {
            for value in self.weeklySlotList[eventDict.key] ?? [] {
                value.eventList.removeAll()
            }
        }
        guard tableView != nil,
              calendarView != nil else {
            return
        }
        self.tableView.reloadData()
        self.calendarView.reloadData()
    }
    func updateEvent(editMode: EditRecurringEventMode, eventDetail: EventDetail?, section: Int) {
        resetFields()
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            if let indexPath =  self.calendarView.pathsFromDates([Date().startOfDay]).first {
                if indexPath.section < self.calendarCalculation?.monthMap.count ?? 0 {
                    self.monthStartDate = self.monthStartDate.startOfMonth()
                    self.monthEndDate = self.monthEndDate.endDayOfMonth
                    self.getEventList(section: (indexPath.section, true))
                }
            }
        }
    }
    // This method is call when we delete a event and update event list.
    private func deleteEventCompletion(eventId: String, deleteType: DeleteEventType) {
        if deleteType == .allFutureEvents {
            for eventDict in self.monthEventList ?? [:] {
                self.monthEventList?[eventDict.key]?.removeAll(where: {$0.id == eventId})
            }
            for eventDict in self.weeklySlotList {
                for value in self.weeklySlotList[eventDict.key] ?? [] {
                    value.eventList.removeAll(where: {$0.id == eventId})
                }
            }
            if let currentSection = calendarView.currentSection() {
                self.monthlyFilteredEventsDict[currentSection]?.removeAll(where: {$0.id == eventId})
            }
            self.getEventList(section: (calendarView.currentSection() ?? 0, true))
            guard tableView != nil,
                  calendarView != nil else {
                return
            }
            self.tableView.reloadData()
            self.calendarView.reloadData()
        } else {
            resetFields()
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                if let currentSection = self.calendarView.currentSection(),
                   let info = self.calendarView.monthInfoFromSection(currentSection) {
                    self.monthStartDate = info.range.start.startOfMonth()
                    self.monthEndDate = info.range.start.endDayOfMonth
                    self.getEventList(section: (currentSection, true))
                }
            }
        }
    }
    func backTapped() {
    }
    // This method is call when we update a event and update data in eventlist.
    func updateEventList(section: Int, eventID: String) {
        self.monthEventList = nil
        self.monthEventList = [:]
        for eventDict in weeklySlotList {
            for value in self.weeklySlotList[eventDict.key] ?? [] {
                value.eventList.removeAll()
            }
        }
        self.eventList = []
        if tableView != nil {
            self.tableView.reloadData()
        }
        self.navigateToMonthView(date: Date())
        if let indexPath =  self.calendarView.pathsFromDates([Date().startOfDay]).first {
            if indexPath.section < self.calendarCalculation?.monthMap.count ?? 0 {
                self.monthStartDate = Date().startOfMonth()
                self.monthEndDate = Date().endDayOfMonth
                self.getEventList(section: indexPath.section)
            }
        }
    }
}
