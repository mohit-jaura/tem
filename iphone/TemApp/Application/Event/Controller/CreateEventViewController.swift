//
//  CreateEventViewController.swift
//  TemApp
//
//  Created by dhiraj on 11/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher
import IQKeyboardManagerSwift
import SwiftDate
import SSNeumorphicView
import UniformTypeIdentifiers
import MobileCoreServices
import Imaginary


enum EventMediaType:Int, Codable{
    case video = 1
    case pdf = 2
}

struct SavedURls: Codable{
    var name: String?
    var mediaType: Int?
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case mediaType = "mediaType"
        case url = "file"
    }
}
protocol SaveEventDetails: AnyObject{
    func saveEventDetails(data: CreateEventDetails, isEventEdited: Bool)
    func saveParticipants(data: CreateEventParticipants,isFriendsEdited: Bool)
    func saveActivity(data: CreateEventActivity, isActivitiesEdited: Bool)
}

protocol EventDelegate {
    func backTapped()
    func updateEvent(editMode: EditRecurringEventMode, eventDetail: EventDetail?, section: Int)
    func updateEventList(section: Int, eventID: String)
    func deleteEvent(section: Int, eventId: String, deleteType: DeleteEventType)
}

class CreateEventViewController: DIBaseController {
    var tempDate: String = ""
    var createEventDetails : CreateEventDetails?
    var createParticipants : CreateEventParticipants?
    var createActivity : CreateEventActivity?
    
    var isEditEvent = false
    var eventID = ""
    var selectedGroup: ChatRoom?
    var eventDetail : EventDetail?
    var delegate : EventDelegate?
    var screenFrom: Constant.ScreenFrom?
    var section = 0
    let currentMedia = Media()
    var mediaItems = [YPMediaItem]()
    var listOfFiles: [SavedURls] = []
    var activityDataModal:[ActivityAddOns]?
    var event = CreateEvent()
    var isActivitiesAdded = false
    var isEventDetailsEdited = false
    var isFriendsEdited = false
    var editMode: EditRecurringEventMode = .thisEvent
    // MARK: IBOutlets
    @IBOutlet weak var gradientContainerView: UIView!
 
   
    @IBOutlet weak var eventTypeDetailsLabel: UILabel!
    
    @IBOutlet weak var visibilityDetailsLabel: UILabel!
    @IBOutlet weak var gradientView: GradientDashedLineCircularView!
   
    @IBOutlet weak var eventTypeLabelHeight: NSLayoutConstraint!
   
    @IBOutlet weak var paymentViewHeight: NSLayoutConstraint!
   
    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var paymentFieldHeight: NSLayoutConstraint!
    
    @IBOutlet  var detailsShadowViews: [SSNeumorphicView]!{
        didSet{
            for view in detailsShadowViews{
                view.setShadow(view: view, shadowType: .innerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            }
        }
    }
    
    @IBOutlet weak var seperatorShadowView: SSNeumorphicView!{
        didSet {
            seperatorShadowView.viewDepthType = .innerShadow
            seperatorShadowView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
            seperatorShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            seperatorShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            seperatorShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet  var BgShadowViews: [SSNeumorphicView]!{
        didSet{
            for view in BgShadowViews{
                view.setShadow(view: view, shadowType: .outerShadow,mainColor: UIColor.newAppThemeColor.cgColor)
                view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
                view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
                view.viewNeumorphicShadowOpacity = 0.7
                view.viewNeumorphicShadowRadius = 3
            }
        }
    }
 
    @IBOutlet weak var nameField: CustomTextField!
    @IBOutlet weak var startField: CustomTextField!
    @IBOutlet weak var endField: CustomTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
 
    let dateFormatter = DateFormatter()
    private var friends: [Friends] = []
    private var name: String = "" {
        didSet {
            nameField.text = name
            nameField.errorMessage = ""
        }
    }
    private var start: Date = Date().addMinutes(n: 30) {
        didSet {
            startField.errorMessage = ""
            let distance = end.differenceInSeconds(fromDate: oldValue)
            end = start.addSec(n: distance)
        }
    }
    private var end: Date = Date().addMinutes(n: 90) {
        didSet {
            endField.errorMessage = ""
        }
    }
   

    private var eventType: EventType = .regular {
        didSet {
            //    eventTypeField.text = eventType.getTitle()
            eventTypeDetailsLabel.text = eventType.getTitle()
            eventTypeLabelHeight.constant = 50
    
        }
    }
   
    private var eventAmount:Int? = nil
  
    // MARK: App life Cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    private func setGradientView() {
     gradientView.configureViewProperties(colors: [ UIColor.appPurpleColor, UIColor(red: 247.0 / 255.0, green: 181.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)], gradientLocations: [0, 1], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        gradientView.instanceWidth = 1.5
        gradientView.instanceHeight = 2.5
        gradientView.extraInstanceCount = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        if isEditEvent{
            submitButton.setTitle("UPDATE", for: .normal)
        }else{
            submitButton.setTitle("SAVE", for: .normal)
        }
        self.navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.previousNextDisplayMode = .default
    }
    
    private func configureViewForEditEvent() {
        if let event = self.eventDetail {
            syncInvitedFriends(event)
            name = event.title ?? ""
            setUpDatesForEditEvent(event)
        }
    }
    
    func setToggleShadow(view:SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1)
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.height / 2
    }
    private func addShadows() {
        cancelButton.addDoubleShadowToButton(cornerRadius: cancelButton.frame.height / 2, shadowRadius: cancelButton.frame.height / 2, lightShadowColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3), shadowBackgroundColor: cancelButton.backgroundColor ?? UIColor.black)
        
    }
    func initialize(){
        setDelegates()
        configureView()
        addShadows()
      
    }
    
    func configureView(){
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        if isEditEvent {
            configureViewForEditEvent()
        } else {
           start = Date().addMinutes(n: 30)
            end = Date().addMinutes(n: 90)
        }
    }
    
    func setDelegates(){
        nameField.delegate = self
        startField.delegate = self
        endField.delegate = self
    }
    
    private func setUpDatesForEditEvent(_ eventDetail:EventDetail) {
        let utcFormatter = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone)
        let eventStartDate = utcFormatter.date(from: eventDetail.startDate?.date as? String ?? "")
        let eventEndDate = utcFormatter.date(from: eventDetail.endDate?.date as? String ?? "")
        start = eventStartDate ?? Date().addMinutes(n: 30)
        end = eventEndDate ?? Date().addMinutes(n: 90)
        startField.text = dateFormatter.string(from: start)
        endField.text = dateFormatter.string(from: end)
    }

    func getEventDateTime(_ date: Date) -> String {
        let dateString = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone).string(from: date)
        return dateString
    }
   
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .editEvent {
            if let editMode = EditRecurringEventMode(rawValue: index) {
                self.editMode = editMode
                self.updateEvent(editMode: editMode)

            }
        }
    }
   
    //on dismissing the activity sheet, reset the border color of the textfield to default gray
    override func cancelSelection(type: SheetDataType) {
   
    }
    // MARK: IBAction
    @IBAction func eventDetailsTapped(_ sender: UIButton) {
        let detailsVC: CreateEventDetailsController = UIStoryboard(storyboard: .createevent).initVC()
        detailsVC.saveEventDetails = self
        detailsVC.end = self.end
        detailsVC.eventID = self.eventID
        detailsVC.isEditEvent = self.isEditEvent
        detailsVC.createdEventDetail = self.createEventDetails
        if isEditEvent{
            if let event = self.eventDetail {
                detailsVC.eventDetail = event
            }
        }
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    @IBAction func participantsTapped(_ sender: Any) {
        let participantsVC: CreateEventParticipantController = UIStoryboard(storyboard: .createevent).initVC()
        participantsVC.saveEventDetails = self
        participantsVC.isEditEvent = self.isEditEvent
        participantsVC.createParticipants = self.createParticipants
        if isEditEvent{
            if let event = self.eventDetail {
                participantsVC.eventDetail = event
            }
        }
        navigationController?.pushViewController(participantsVC, animated: true)
    }
    
    @IBAction func activityTapped(_ sender: UIButton) {
        let activityVC: CreateEventActivityController = UIStoryboard(storyboard: .createevent).initVC()
        activityVC.saveEventDetails = self
        activityVC.isEditEvent = self.isEditEvent
        activityVC.createActivity = self.createActivity
        if isEditEvent{
            if let event = self.eventDetail {
                activityVC.eventDetail = event
            }
        }
        navigationController?.pushViewController(activityVC, animated: true)
    }
   
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
  
    
    @IBAction func submitButton(_ sender: UIButton) {
        self.view.endEditing(true)
        if validate() {
            if isEditEvent {
                if let recurrEvent = eventDetail?.reccurEvent, let recurrEventType = RecurrenceType(rawValue:recurrEvent) {
                    if recurrEventType != .doesNotRepeat {
                        self.showSelectionModal(array: EditRecurringEventMode.allCases, type: .editEvent)
                    } else {
                        updateEvent(editMode: .thisAndOtherEvent)
                    }
                }
            } else {
                createEvent()
            }
        } else {
            showAlert(message: "Please check event details")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func validate() -> Bool {
        var result = true
        if name.isEmpty || name == "" || name.isEmptyStr{
            result = false
            nameField.errorMessage = "Please specify event name"
        }
        return result
    }
    
    private func createEvent() {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        let params = getEventParams()
        DIWebLayerEvent().createEvent(parameter:params.toCreateEventDict(), success: { (detail) in
            self.hideLoader()
            let eventDetailVC:EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
            eventDetailVC.eventId = detail?.id ?? ""
            eventDetailVC.eventDetail = detail
            eventDetailVC.delegate = self
            NotificationCenter.default.post(name: NSNotification.Name(Constant.NotiName.refreshEvent), object: nil)
            //  CalendarManager.shared.insertEventIniCal(detail,params,self.endsOnType,self.endOnDate)
            self.editSuccessEvent()
            self.navigationController?.pushViewController(eventDetailVC, animated: true)
            self.backTapped()
            self.navigationController?.viewControllers.removeAll(where: { (controller) -> Bool in
                return controller is CreateEventViewController ? true : false
            })
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError: error ?? DIError.unKnowError())
        }
    }
    
    internal func updateEvent(editMode: EditRecurringEventMode) {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        let editObj = getEventParams(editMode: editMode)
        var params = editObj.toEditEventDict()
        if let updateFor = self.eventDetail?.rootUpdatedFor{
            params["rootUpdatedFor"] = updateFor
        }
        DIWebLayerEvent().updateEvent(parameter:params, success: { (eventDetail) in
            self.hideLoader()
            self.eventDetail = eventDetail
            self.showAlert(withTitle:"", message: "Event updated successfully.", okCall: {

                NotificationCenter.default.post(name: NSNotification.Name(Constant.NotiName.refreshEvent), object: nil)

                self.delegate?.updateEvent(editMode: editMode, eventDetail:self.eventDetail, section: self.section)
                self.editSuccessEvent()
                self.navigationController?.popViewController(animated: true)
                CalendarManager.shared.deleteEventFromiCal(.allFutureEvents, self.eventDetail)
            })
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError: error ?? DIError.unKnowError())
        }
    }
    func editSuccessEvent() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.editEvent), object: nil, userInfo: [Constant.NotiName.editEvent:eventDetail])
    }
    

    private func getEndsOn(endsOn: EndsOnValue?, reccurEvent: Int) -> EndsOnValue? {
        var newEndsOn: EndsOnValue?
        if eventDetail?.eDateTime != getEventDateTime(end) {
            if let endOnDate = endsOn?.any as? String {
                let endsOnDate = endOnDate.toISODate()!.date
                if endsOnDate > end && reccurEvent != 0 {
                    newEndsOn = endsOn
                } else {
                    newEndsOn = EndsOnValue.string(getEventDateTime(end))
                }
            } else if endsOn?.any as? Int != nil {
                newEndsOn = endsOn
            } else {
                newEndsOn = EndsOnValue.string(getEventDateTime(end))
            }
        } else {
            newEndsOn = endsOn
        }
        return newEndsOn
    }
        
    func getEventParams(editMode: EditRecurringEventMode = .thisEvent) -> CreateEvent {
        var event = CreateEvent()
        if isEditEvent && !isEventDetailsEdited{
            event.description = eventDetail?.description ?? ""
            event.media = eventDetail?.media ?? [SavedURls]()
            event.eventReminder = eventDetail?.eventReminder ?? true
            event.endsOn = getEndsOn(endsOn: eventDetail?.endsOn, reccurEvent: eventDetail?.reccurEvent ?? 0)
            event.reccurEvent = RecurrenceType(rawValue: eventDetail?.reccurEvent ?? 0) ?? .doesNotRepeat
            event.visibility = eventDetail?.visibility ?? .personal
            event.membersCount = eventDetail?.members?.count
            if eventDetail?.visibility == .open{
                event.signupSheetType = "public"
            }
        }else{
            event.description = createEventDetails?.description ?? ""
            event.media = createEventDetails?.media ?? [SavedURls]()
            event.eventReminder = createEventDetails?.eventReminder ?? true
            event.endsOn = getEndsOn(endsOn: createEventDetails?.endsOn, reccurEvent: createEventDetails?.reccurEvent.rawValue ?? 0)
            event.reccurEvent = createEventDetails?.reccurEvent ?? .doesNotRepeat
            event.location = createEventDetails?.location ?? Address()
            event.visibility = createParticipants?.visibility ?? .personal
            event.membersCount = createParticipants?.membersCount ?? 0
            event.signupSheetType = createParticipants?.signupSheetType ?? ""
        }
        event.checkList = getChecklistParams()
        event.activityAddOn = getActivityParams()
        event.amount = eventAmount
        event.title = name
        event.sDateTime = getEventDateTime(start)
        event.eDateTime = getEventDateTime(end)
        event.eventType = createParticipants?.eventType ?? .regular
        if createParticipants?.members.count == 0{
            event.members = createParticipants?.members ??  [Friends]()
        }else{
            if isEditEvent && !isFriendsEdited{
                var friend : Friends?
                if let friendList = eventDetail?.members?.filter({$0.userId == User.sharedInstance.id}),let user = friendList.first{
                    friend = Friends()
                    friend?.user_id = user.userId
                    friend?.inviteAccepted = user.inviteAccepted
                }
                if let value = friend {
                    self.friends.append(value)
                }
                event.members = self.friends
                event.membersCapacity = eventDetail?.members_add_number?.count //createParticipants?.membersCapacity ?? nil
                
            }else{
                event.members = createParticipants?.members ?? [Friends]()
                event.membersCapacity = createParticipants?.membersCapacity ?? nil
            }
        }
        event.id = self.eventID
        event.isEditEvent = createEventDetails?.isEditEvent ?? false
        event.updatedFor = timeZoneDateFormatter(format: .eventUtcDateString, timeZone: utcTimezone).string(from: self.eventDetail?.eventStartDate ?? Date())
        event.updateAllEvents = self.editMode.rawValue//createEventDetails?.updateAllEvents ?? 0
        return event
    }
    func getActivityParams() -> [[String : Any]]{
        let savedActivities = ActivityAddOns.inDic(eventDetail?.activityAddOn) ?? []//ActivityAddOns.inDic(activityDataModal) ?? []
        let newActivities = createActivity?.activityAddOn ?? [[String:Any]]()
        if isEditEvent && !isActivitiesAdded {
            return savedActivities
        }
        return newActivities
    }

    func getChecklistParams() -> [Rounds]{
        let newRounds = createActivity?.checkList ?? [Rounds]()
        guard let eventRound = eventDetail?.rounds else { return newRounds }
        let savedRounds = eventRound.map { round in
            return round.getRounds()
        }
        if isEditEvent && !isActivitiesAdded {
            return savedRounds
        }
        return newRounds
    }

    private func syncInvitedFriends(_ eventDetail:EventDetail){
        if let memberList = eventDetail.members{
            encodeObject(memberList)
        }
    }
    private func encodeObject(_ memberList : [Members]){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(memberList)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                self.decodeObject(jsonString)
            }
        } catch {
            self.showAlert(message:error.localizedDescription)
        }
    }

    private func decodeObject(_ jsonString : String){
        if let jsonData = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                var friendList = try decoder.decode([Friends].self, from: jsonData)
                for value in friendList{
                    value.user_id = value.userId
                }
                friendList.removeAll(where: {$0.user_id == User.sharedInstance.id})
                friends = friendList
            } catch {
                self.showAlert(message:error.localizedDescription)
            }
        }
    }
}

// MARK: Extension + TextField Delegate Methods

extension CreateEventViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: true)
        }
            return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? CustomTextField {
            field.errorMessage = ""
        }
        switch textField {
        case startField:
            showDatePicker(textfield: startField, action: #selector(startDateChanged), mode: .dateAndTime,
                           selectedDate: start, minDate: Date(), maxDate: Date().addYear(1))
            startField.text = dateFormatter.string(from: start)
            
        case endField:
            showDatePicker(textfield: endField, action: #selector(endDateChanged), mode: .dateAndTime,
                           selectedDate: end, minDate: start, maxDate: start.addMonth(n: 1))
            endField.text = dateFormatter.string(from: end)
        default:
            break
        }
    }
    
    private func showDatePicker(textfield: UITextField, action: Selector, mode: UIDatePicker.Mode, selectedDate: Date, minDate: Date, maxDate: Date) {
        datePickerView = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePickerView?.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        datePickerView!.datePickerMode = mode
        datePickerView?.setDate(selectedDate, animated: true)
        datePickerView?.minimumDate = minDate
        datePickerView?.maximumDate = maxDate
        textfield.inputView = datePickerView
        datePickerView?.addTarget(self, action: action, for: .valueChanged)
    }
    
    @objc private func startDateChanged(_ sender: UIDatePicker) {
        start = sender.date
        startField.text = dateFormatter.string(from: start)
        if isEditEvent{
            endField.text = dateFormatter.string(from: end)
        }
    }
    
    @objc private func endDateChanged(_ sender: UIDatePicker) {
        end = sender.date
        endField.text = dateFormatter.string(from: end)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: false)
        }
        if textField == nameField, let text = textField.text {
            name = text
        } 
        
        else if textField == paymentField{
            let amount = paymentField.text ?? ""
            if amount.count > 0 && amount.hasPrefix(" "){
                eventAmount = nil
                paymentField.text = nil
            }else{
                eventAmount = amount.toInt()
            }
        }
    }
}

// MARK: Picker Delegate Methods...



extension CreateEventViewController : EventDelegate{
    func updateEvent(editMode: EditRecurringEventMode, eventDetail: EventDetail?,section:Int) {
    }
    
    func deleteEvent(section: Int, eventId: String, deleteType: DeleteEventType) {
    }
    
    func updateEventList(section: Int, eventID: String) {
    }
    
    func backTapped() {
        self.delegate?.updateEventList(section: self.section, eventID: self.eventID)
    }
}


extension CreateEventViewController: SaveEventDetails{
    func saveEventDetails(data: CreateEventDetails, isEventEdited: Bool) {
        self.isEventDetailsEdited = isEventEdited
        self.createEventDetails = data
    }

    
    func saveParticipants(data: CreateEventParticipants, isFriendsEdited: Bool) {
        self.createParticipants = data
        self.isFriendsEdited = isFriendsEdited
    }
    
    func saveActivity(data: CreateEventActivity, isActivitiesEdited: Bool) {
        self.createActivity = data
        self.isActivitiesAdded = isActivitiesEdited
    }
    
}
