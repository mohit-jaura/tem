//
//  CreateEventParticipantController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 29/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//


import UIKit
import SSNeumorphicView
import IQKeyboardManagerSwift

struct CreateEventParticipants{
    var visibility: EventVisibility = .personal
    var membersCount: Int?
    var signupSheetType: String?
    var groupId: String?
    var groupName: String?
    var members : [Friends] = []
    var eventType: EventType = .regular
    var membersCapacity: Int? = nil
}

class CreateEventParticipantController: DIBaseController {
    var tempDate: String = ""
    var isEditEvent = false
    var eventID = ""
    var selectedGroup: ChatRoom?
    var eventDetail : EventDetail?
    var saveEventDetails : SaveEventDetails?
    var screenFrom: Constant.ScreenFrom?
    var section = 0
    var mediaItems = [YPMediaItem]()
    var listOfFiles: [SavedURls] = []
    var activityDataModal:[ActivityAddOns]?
    var createParticipants : CreateEventParticipants?
    // MARK: IBOutlets
    @IBOutlet weak var membersCountDetailsLabel: UILabel!
    @IBOutlet weak var tematesDetailsLabel: UILabel!
    @IBOutlet weak var visibilityDetailsLabel: UILabel!
    @IBOutlet weak var visibilityLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var signUpFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var membersCountFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var temmatesBgView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet  var detailsShadowViews: [SSNeumorphicView]!{
        didSet{
            for view in detailsShadowViews{
                view.setShadow(view: view, shadowType: .innerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            }
        }
    }
    @IBOutlet var bgShadowViews: [SSNeumorphicView]!{
        didSet{
            for view in bgShadowViews{
                view.setShadow(view: view, shadowType: .outerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            }
        }
    }
    @IBOutlet weak var toggleButtonShadowView: SSNeumorphicView!{
        didSet{
            toggleButtonShadowView.setShadow(view: toggleButtonShadowView, shadowType: .outerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            toggleButtonShadowView.viewNeumorphicShadowOpacity = 0.2
        }
    }
    
    @IBOutlet weak var signUpField: CustomTextField!
    @IBOutlet weak var membersCapacityContainer: UIView!
    @IBOutlet weak var membersCapacityField: CustomTextField!
    @IBOutlet weak var tematesField: CustomTextField!
    @IBOutlet weak var visibilityField: CustomTextField!
    @IBOutlet var signUpToggleImage: UIImageView!
    @IBOutlet var tematesToggleImage: UIImageView!
    @IBOutlet var visibilityToggleImage: UIImageView!
    
    
    @IBOutlet weak var signUpToggleShadowView: SSNeumorphicView!{
        didSet{
            //            setToggleShadow(view: signUpToggleShadowView)
        }
    }
    
    
    @IBOutlet weak var tematesToggleShadowView: SSNeumorphicView!{
        didSet{
            setToggleShadow(view: tematesToggleShadowView)
        }
    }
    @IBOutlet weak var visibilityToggleShadowView: SSNeumorphicView!{
        didSet{
            setToggleShadow(view: visibilityToggleShadowView)
        }
    }
    
    private var eventType: EventType = .regular {
        didSet {
            if eventType == .signupSheet {
                membersCountFieldHeight.constant = 60
            } else {
                membersCountFieldHeight.constant = 0
            }
            membersCapacity = nil
        }
    }
    
    private var signUpSheetType:SignUpSheetType = .unlimited{
        didSet{
            switch signUpSheetType {
                case .count:
                    membersCountFieldHeight.constant = 60
                    ///   activityFieldTop.constant = 146
                    membersCapacityField.text = ""
                case .unlimited:
                    membersCount = -1
                    membersCountFieldHeight.constant = 0
                    ///    activityFieldTop.constant = 109
            }
            signUpField.text = signUpSheetType.title
        }
    }
    private var membersCapacity: Int? {
        didSet {
            if let membersCapacity = membersCapacity {
                membersCapacityField.text = String(membersCapacity)
            } else {
                membersCapacityField.text = nil
            }
            membersCapacityField.errorMessage = ""
        }
    }
    private var membersCount:Int?{
        didSet {
            if let membersCount = membersCount {
                membersCapacityField.text = String(membersCount)
                if membersCount > 0{
                    membersCountFieldHeight.constant = 60
                }
            } else {
                membersCapacityField.text = nil
            }
            membersCapacityField.errorMessage = ""
        }
    }
    
    
    private var friends: [Friends] = [] {
        didSet {
            updateSelectedTemates()
        }
    }
    private var visibility: EventVisibility = .personal {
        didSet {
            visibilityLabelHeight.constant = 50.0
            visibilityDetailsLabel.text = visibility.name
            if visibilityDetailsLabel.text?.isEmpty ?? true{
                visibilityToggleImage.image = UIImage(named: "")
            } else {
                visibilityToggleImage.image = UIImage(named: "Oval Copy 3")
            }
            
            if visibility == .open || visibility == .temates {
                signUpFieldHeight.constant = 41
                ///     activityFieldTop.constant = 109
                membersCapacityField.text = ""
            }else{
                signUpField.text = "Sign Up"
                signUpFieldHeight.constant = 0
                //                signUpToggleImage.image = UIImage(named: "")
                membersCapacity = nil
                membersCount = nil
                membersCountFieldHeight.constant = 0
                ///      activityFieldTop.constant = 27
                
            }
        }
    }
    
    // MARK: App life Cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func updateSelectedTemates() {
        if let group = selectedGroup {
            //       tematesField.text = group.name
            tematesDetailsLabel.text = group.name
        } else if let groupName = createParticipants?.groupName {
            tematesDetailsLabel.text = groupName
        } else {
            tematesDetailsLabel.text = friends.map({ $0.fullName }).joined(separator: ", ")
            //      tematesField.text = friends.map({ $0.fullName }).joined(separator: ", ")
        }
        if tematesDetailsLabel.text?.isEmpty ?? true{
            tematesToggleImage.image = UIImage(named: "")
        }else{
            tematesToggleImage.image = UIImage(named: "Oval Copy 3")
        }
    }
    
    @IBOutlet var findTematesShadowView: SSNeumorphicView! {
        didSet {
            findTematesShadowView.viewDepthType = .outerShadow
            findTematesShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            findTematesShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            findTematesShadowView.viewNeumorphicCornerRadius = findTematesShadowView.frame.width/2
            findTematesShadowView.viewNeumorphicShadowRadius = 1.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
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
            visibility = event.visibility ?? .personal
            membersCapacityField.setUserInteraction(shouldEnable: false)
            submitButton.setTitle("UPDATE", for: .normal)
        }
    }
    private func initUI() {
        submitButton.setTitle("SAVE", for: .normal)
        guard let eventDetail = self.createParticipants else {
            visibility = .personal
            eventType = .regular
            return
        }
        self.friends = eventDetail.members
        visibility = eventDetail.visibility
        membersCount = eventDetail.membersCount
        membersCapacity = eventDetail.membersCapacity
    }
    func setToggleShadow(view:SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.height / 2
    }
    func initialize(){
        setDelegates()
        DispatchQueue.main.async {
            self.configureView()
        }
        temmatesBgView.isHidden = false
    }
    
    func configureView(){
        if isEditEvent {
            configureViewForEditEvent()
            initUI()

        } else {
            initUI()
        }
    }
    
    func setDelegates(){
        signUpField.delegate = self
        membersCapacityField.delegate = self
        tematesField.delegate = self
        visibilityField.delegate = self
        
    }
    func getEventParams(editMode: EditRecurringEventMode = .thisEvent) -> CreateEventParticipants {
        var event = CreateEventParticipants()
        event.visibility = visibility
        event.membersCount = membersCount
        if visibility == .open{
            event.signupSheetType = "public"
        }
        if isEditEvent {
            if let selectedGroup = self.selectedGroup {
                event.groupId = selectedGroup.groupId
                event.groupName = selectedGroup.name
                if let members = selectedGroup.members {
                    event.members = members
                }
                var friend : Friends?
                if let friendList = eventDetail?.members?.filter({$0.userId == User.sharedInstance.id}),let user = friendList.first{
                    friend = Friends()
                    friend?.user_id = user.userId
                    friend?.inviteAccepted = user.inviteAccepted
                }
                if let value = friend {
                    event.members.append(value)
                }
            } else {
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
            }
        } else {
            if let selectedGroup = self.selectedGroup {
                event.groupId = selectedGroup.groupId
                event.groupName = selectedGroup.name
                if let members = selectedGroup.members {
                    event.members = members
                }
                var friend : Friends?
                if let friendList = eventDetail?.members?.filter({$0.userId == User.sharedInstance.id}),let user = friendList.first{
                    friend = Friends()
                    friend?.user_id = user.userId
                    friend?.inviteAccepted = user.inviteAccepted
                }
                if let value = friend {
                    event.members.append(value)
                }
            } else {
                event.members = self.friends
            }
            event.eventType = eventType
            event.membersCapacity = membersCapacity
        }
        return event
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

    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .editEvent {
            if let editMode = EditRecurringEventMode(rawValue: index) {
                ///   self.updateEvent(editMode: editMode)
            }
        }else if type == .eventVisibility {
            visibility = EventVisibility.allCases[index]
            visibilityField.changeViewFor(selectedState: false)
        }
        else if type == .signUpSheetType{
            signUpSheetType = SignUpSheetType.allCases[index]
        }
    }
    
    //on dismissing the activity sheet, reset the border color of the textfield to default gray
    override func cancelSelection(type: SheetDataType) {
        if type == .eventVisibility {
            visibilityField.changeViewFor(selectedState: false)
        } else if type == .signUpSheetType{
            signUpField.changeViewFor(selectedState: false)
        }
    }
    // MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        let params = getEventParams()
        saveEventDetails?.saveParticipants(data: params, isFriendsEdited: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func redirectToTematesSelection() {
        if let screenFrom = self.screenFrom,
           screenFrom == .createGroupEvent {
            return
        }
        let inviteFrndVC: InviteFriendController = UIStoryboard(storyboard: .challenge).initVC()
        inviteFrndVC.delegate = self
        inviteFrndVC.selectedFriends = self.friends
        inviteFrndVC.selectedGroup = selectedGroup
        inviteFrndVC.screenFrom = .event
        navigationController?.pushViewController(inviteFrndVC, animated: true)
    }
    
    private func validate() -> Bool {
        var result = true
        if signUpSheetType == .count {
            if let capacity = membersCount {
                if capacity <= 0 {
                    result = false
                    membersCapacityField.errorMessage = "Please specify positive number"
                } else if friends.count > capacity {
                    result = false
                    membersCapacityField.errorMessage = "Please specify capacity to accommodate all selected temates (min. \(friends.count))"
                } else {
                    membersCapacityField.errorMessage = ""
                }
            } else {
                membersCapacityField.errorMessage = ""
            }
        }
        return result
    }
    
    func editSuccessEvent() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.editEvent), object: nil, userInfo: [Constant.NotiName.editEvent:eventDetail])
    }
}

// MARK: Extension + TextField Delegate Methods

extension CreateEventParticipantController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: true)
        }
        switch textField {
        case tematesField:
            redirectToTematesSelection()
            return false
        case visibilityField:
            showSelectionModal(array: EventVisibility.allCases, type: .eventVisibility)
            return false
        case signUpField:
            showSelectionModal(array: SignUpSheetType.supported, type: .signUpSheetType)
            return false
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? CustomTextField {
            field.errorMessage = ""
        }
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: false)
        }
        if textField == membersCapacityField, let text = textField.text {
            if let capacity = Int(text) {
                membersCapacity = capacity
                membersCount = capacity
            } else {
                membersCapacity = nil
                membersCount = nil
            }
        }
    }
}

// MARK: Picker Delegate Methods...
extension CreateEventParticipantController: InviteFriendControllerViewDelegate {
    func didSelectTemates(members: [Friends]) {
        tematesField.changeViewFor(selectedState: false)
        self.selectedGroup = nil
        friends = members
        self.updateSelectedTemates()
    }
    
    func didSelectGroup(group: ChatRoom) {
        tematesField.changeViewFor(selectedState: false)
        self.friends.removeAll()
        self.selectedGroup = group
        self.updateSelectedTemates()
    }
    
    func noMemberAndTemSelected() {
        tematesField.changeViewFor(selectedState: false)
        selectedGroup = nil
        friends.removeAll()
        //        self.updateSelectedTemates()
    }
}
