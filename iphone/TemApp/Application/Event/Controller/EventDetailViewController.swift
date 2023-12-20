//
//  EventDetailViewController.swift
//  TemApp
//
//  Created by dhiraj on 11/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import AVFoundation

class EventDetailViewController: DIBaseController {

    // MARK: IBOutlet Variables
    @IBOutlet weak var activityAddOnMoreOut: UIButton!
    @IBOutlet weak var nameLbl:UILabel!
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var timeLbl:UILabel!
    @IBOutlet weak var locationLbl:UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var logoImgVw:UIImageView!
    @IBOutlet weak var descriptionLbl:UILabel!
    @IBOutlet weak var reminderContainer: UIView!
    @IBOutlet weak var reminderLbl:UILabel!
    @IBOutlet weak var signupSheetMark: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var chatbutton: UIButton!
    @IBOutlet weak var tematesLabel: UILabel!
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    @IBOutlet weak var signUpOuterView: UIView!
    @IBOutlet weak var signUpViewHeight: NSLayoutConstraint!
    var isNeedToHitApi: Bool = true
    @IBOutlet weak var collectionShadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: collectionShadowView, shadowType: .innerShadow, isType: false)
        }
    }
    @IBOutlet weak var descriptionDetailsShadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: descriptionDetailsShadowView, shadowType: .innerShadow)
        }
    }

    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityAddOnLabelContainer: SSNeumorphicView! {
        didSet{
            setShadow(view: activityAddOnLabelContainer, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var checklistContainerShadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: checklistContainerShadowView, shadowType: .innerShadow)
        }
    }


    @IBOutlet weak var activityAddOnContainerView: SSNeumorphicView!{
        didSet{
            setShadow(view: activityAddOnContainerView, shadowType: .innerShadow)
        }
    }
    @IBOutlet weak var shadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: shadowView, shadowType: .innerShadow)
        }
    }


    @IBOutlet weak var signUpView: SSNeumorphicView!{
        didSet{
            setShadow(view: signUpView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var activityShadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: activityShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var checkListView: SSNeumorphicView!{
        didSet{
            setShadow(view: checkListView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var reminderView: SSNeumorphicView!{
        didSet{
            setShadow(view: reminderView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navLineView: UIView!
    @IBOutlet weak var gradientView: GradientDashedLineSquareView!
    @IBOutlet weak var membersCountHeader: UILabel!
    @IBOutlet weak var membersCountSubheader: UILabel!
    @IBOutlet weak var membersView: UICollectionView!

    @IBOutlet weak var signupSheetImageView: UIImageView!
    @IBOutlet weak var reminderImageView: UIImageView!
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var joinButton:UIButton!
    @IBOutlet weak var checkListsLbl:UILabel!
    @IBOutlet weak var startActivityButton: UIButton!
    @IBOutlet weak var checklistTogleImageView: UIImageView!
    @IBOutlet weak var activityToggleImageView: UIImageView!

    var selectedEventDate: String?
    var listOfFiles: [SavedURls] = []
    var eventId = ""
    var eventDetail : EventDetail?
    var delegate : EventDelegate?
    var section = 0
    private var owner: User?
    var chatRoomId: String?
    var profilePicURL: String?
    var joinStatus:EventInvitationStatus = .pending
    let currentDate = Date().addMinutes(n: 30) // here we are adding 30 mins to current date because when we create an event there we are also adding 30 min to start and end date

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationToRefresh()
        mediaCollectionView.registerNibsForCollectionView(nibNames: [MediaCollectionViewCell.reuseIdentifier])

    }

    @IBOutlet weak var indexViewInnerShadow: UIView!

    @IBOutlet weak var indexSuperviewInnerShadow: UIView!{
        didSet{
            print("")
            // addNeumorphicShadow(view: indexSuperviewInnerShadow, shadowType: .outerShadow, cornerRadius: 4, shadowRadius: 0.4, opacity:  0.3, darkColor:  #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5), lightColor: UIColor.black.cgColor, offset: CGSize(width: 2, height: 2))
        }
    }
    @IBAction func editTapped(_ sender: Any) {

        let createEventVC:CreateEventViewController = UIStoryboard(storyboard: .createevent).initVC()
        createEventVC.isEditEvent = true
        createEventVC.eventDetail = self.eventDetail
        createEventVC.eventID = self.eventDetail?.id ?? self.eventId
        createEventVC.delegate = self
        createEventVC.section = self.section
        self.navigationController?.pushViewController(createEventVC, animated: true)

    }

    @IBAction func deleteTapped(_ sender: Any) {
        if let recurrEvent = eventDetail?.reccurEvent,let recurrEventType = RecurrenceType(rawValue:recurrEvent) {
            if recurrEventType != .doesNotRepeat {
                let arrayList = DeleteEventType.allCases.map({$0.getTitle()})
                self.showSelectionModal(array: arrayList, type: .deleteEvent)
            } else {
                self.showAlert(withTitle:"", message: AppMessages.Event.delete, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: AppMessages.AlertTitles.Cancel, okStyle: .default, okCall: {
                    self.callDeleteEventAPI()
                }) {
                }
            }
        }
    }


    @IBAction func chattapped(_ sender: UIButton) {

        let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        let url = URL(string: profilePicURL ?? "")

        chatController.chatRoomId = chatRoomId
        chatController.chatName = ownerLabel.text

        chatController.chatImageURL = url
        self.navigationController?.pushViewController(chatController, animated: true)

    }
    func addDashedLineView(){
        let outerPath =   UIBezierPath(roundedRect: indexViewInnerShadow.bounds, byRoundingCorners: .allCorners,cornerRadii: CGSize(width: 8.0, height: 8.0))
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = outerPath.bounds
        gradientLayer.colors = [ UIColor.purple.withAlphaComponent(1).cgColor, UIColor.purple.withAlphaComponent(1).cgColor,UIColor.purple.withAlphaComponent(1).cgColor ]

        let shapeMask = CAShapeLayer()
        shapeMask.path = outerPath.cgPath
        shapeMask.lineWidth = 3
        shapeMask.lineDashPattern = [ 1, 1 ]
        shapeMask.lineCap = .butt
        shapeMask.lineJoin = .round
        shapeMask.strokeColor = UIColor.black.cgColor
        shapeMask.fillColor = nil
        gradientLayer.mask = shapeMask

        removeSublayer(gradientLayer: gradientLayer, view: indexViewInnerShadow)
        indexViewInnerShadow.layer.addSublayer( gradientLayer )
    }
    func removeSublayer(gradientLayer: CAGradientLayer, view: UIView?){
        gradientLayer.name = "gradientLayer"
        let sublayers: [CALayer]? = view?.layer.sublayers
        if let layeers = sublayers{
            for layer in  layeers{
                if layer.name == "gradientLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }

    func addNeumorphicShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius: CGFloat, shadowRadius: CGFloat , opacity: Float, darkColor: CGColor, lightColor: CGColor, offset: CGSize){
        view.viewDepthType = shadowType
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        //        view.viewNeumorphicMainColor = #colorLiteral(red: 0.2439696491, green: 0.5112304091, blue: 0.85862571, alpha: 1)
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)

        view.viewNeumorphicShadowOpacity = opacity
        view.viewNeumorphicDarkShadowColor =  darkColor
        view.viewNeumorphicShadowOffset = offset
        view.viewNeumorphicLightShadowColor = lightColor
    }


    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        if isType{
            view.viewNeumorphicCornerRadius = 25
        } else{
            view.viewNeumorphicCornerRadius = 8
        }

        view.viewNeumorphicShadowRadius = 3
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNeedToHitApi {
            intializer()
            isNeedToHitApi = false
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    func notificationToRefresh() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshToNotification), name: NSNotification.Name(rawValue: Constant.NotiName.refreshEvent), object: nil)
    }
   @objc func refreshToNotification() {
       isNeedToHitApi = true
    }

    // MARK: Custom Methods...
    private func intializer() {
        if eventDetail?.members_add_number?.count != 0 {
            signupSheetImageView.image = UIImage(named: "green")
        }else{
            signupSheetImageView.image = UIImage(named: "radio")
        }
        if eventDetail?.eventReminder == true{
            reminderImageView.image = UIImage(named: "oval copy 3")
        }else{
            reminderImageView.image = UIImage(named: "radio")
        }
        concurrentApi()
        let isPaid = checkEventIsPaidOrNot()
        if eventDetail?.isProgramEvent == 1{
            if  (Defaults.shared.get(forKey: .programEvent) as? Bool == true) {
                setProgramEvenStatus()
            }
        }
    }
    func concurrentApi() {
           let operationQueue = OperationQueue()
           let blockOperation1  = BlockOperation()
           let blockOperation2  = BlockOperation()
           operationQueue.maxConcurrentOperationCount  = 2
           blockOperation2.queuePriority = .veryHigh
           operationQueue.qualityOfService = .userInteractive
           blockOperation1.addExecutionBlock {
               self.getEventDetail()
           }
           blockOperation2.addExecutionBlock {
               self.getMembersList()
           }
           operationQueue.addOperations([blockOperation1, blockOperation2], waitUntilFinished: false)
       }

    /// Used to pop to previous controller.
    @objc override func popToBackScreen(){
        self.delegate?.backTapped()
        if let filteredVC = self.navigationController?.viewControllers.filter({$0.isKind(of: CalendarVC.self)}),let calendarVC = filteredVC.first{
            self.navigationController!.popToViewController(calendarVC, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func getEventDates() -> String{
        guard let eventDetail = eventDetail else { return "-" }
        let now = Date()
        let cal = Calendar.current
        
        if let startDateString = eventDetail.startDate?.date as? String,
           let endDateString = eventDetail.endDate?.date as? String { // we are getting UTC string from backend, and we need to convert it into local time.
            let sdate = timeZoneDateFormatter(format: .preDefined, timeZone: utcTimezone).date(from: startDateString)!
            let edate = timeZoneDateFormatter(format: .preDefined, timeZone: utcTimezone).date(from: endDateString)!
            let localStartDate = sdate.UTCToLocalString(inFormat: .eventSlot)
            let localEndDate = edate.UTCToLocalString(inFormat: .eventSlot)
            
            if sdate.startOfDay == edate.startOfDay{
                return localStartDate
            } else {
                return localStartDate + " - " + localEndDate
            }
        }
        return "--"
    }
    func setProgramEvenStatus(){
        DIWebLayerActivityAPI().completeProgramEvent(parameter: ["programId": eventDetail?.programId ?? "", "programEventId": eventDetail?.programEventId ?? "" ], success: { msg in
            print(msg)
        }, failure: { error in
            print(error?.message)
        })
    }
    private func getEventTime() -> String{
        let startDate = eventDetail?.eventStartDate ?? Date()
        let endDate = eventDetail?.eventEndDate ?? Date()
        let localFormatter = timeZoneDateFormatter(format: .timeHM)
        let startTimeString = localFormatter.string(from: startDate)
        let endTimeString = localFormatter.string(from: endDate)
        return startTimeString + " to " + endTimeString
    }

    //This function will call API to save data on backend server....
        func getEventDetail(editMode: EditRecurringEventMode = .thisAndOtherEvent) {
            DispatchQueue.main.async {
                guard self.isConnectedToNetwork() else {
                    return
                }
                self.showLoader()
            }
            DIWebLayerEvent().getEventDetail(parameter:nil, id: eventId,success: {[weak self] (detail) in
                guard let self = self else {return }
                DispatchQueue.main.async {

                self.hideLoader()
                self.eventDetail = detail
                self.setRoundsLbl(rounds: detail?.rounds ?? [])
                self.eventDetail?.id = self.eventId
                if let media = detail?.media{
                    self.listOfFiles = media
                }
                self.mediaCollectionView.reloadData()
                //- FIX It
                //self.delegate?.updateEvent(editMode: editMode, eventDetail: self.eventDetail, section: self.section)
                self.setUpEventDetail()
                }

            }) { (error) in
                self.hideLoader()
                self.showAlert(withError: error!)
            }
        }

    func setupActivityAddOn() {
        var info = [String]()
        if let addOnArr = eventDetail?.activityAddOn,addOnArr.count > 0 {
            //Get all categories
            let allCats = Array(Set(addOnArr.map({return $0.category_id})))
            for i in 0..<allCats.count {

                let filterOne = addOnArr.filter({$0.category_id == allCats[i]})
                let count = filterOne.count

                let name = (filterOne.first?.category_name ?? "Activity \(i+1)").capitalized

                info.append("\(name) (\(count) Activit\(count > 1 ? "ies" : "y"))")
            }
            activityLabel.text = info.reduce("", {$0 + $1 + "\n"})
            activityToggleImageView.image = UIImage(named: "Oval Copy 3")
        } else {
            activityToggleImageView.image = UIImage(named: "radio")
            activityLabel.text = "No Activity added !"
            activityLabel.textAlignment = .center
        }
    }

    private func setUpEventDetail() {
        guard let eventDetail = eventDetail else { return }
        if eventDetail.isProgramEvent == 1{
            startActivityButton.isHidden = false
            joinButton.isHidden = true
            tematesLabel.isHidden = true
            shadowView.isHidden = true
            shadowViewHeight.constant = 0
            signUpView.isHidden = true
            signUpViewHeight.constant = 0
        }
        nameLbl.text = eventDetail.title ?? ""
        let location = eventDetail.location?.location ?? ""
        locationLbl.text = location == "" ? "N/A" : location
        descriptionLbl.text = eventDetail.description ?? ""
        dateLbl.text = getEventDates()
        //        reminderContainer.isHidden = !(eventDetail.eventReminder  ?? false)
        setupActivityAddOn()
        timeLbl.text = getEventTime()
        visibilityLabel.text = (eventDetail.visibility ?? .personal).name
        if let userId = eventDetail.userId  {
            if userId == User.sharedInstance.id {
                if let isEditable = EditStatus(rawValue: eventDetail.isEditable ?? 1), isEditable == .yes{
                    editButton.isHidden = false
                    deleteButton.isHidden = false
                    chatbutton.isHidden = true
                    //  self.setUpBarItems(rightButtonAction: [.edit, .delete])
                } else{
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    chatbutton.isHidden = true
                }

            } else {
                editButton.isHidden = true
                deleteButton.isHidden = false
                chatbutton.isHidden = false
            }
            self.getUserChatRoomDetails(userId)
        }
        if  eventDetail.members_add_number?.count != 0{
            signupSheetImageView.image = UIImage(named: "Oval Copy 3")
        } else {
            signupSheetImageView.image = UIImage(named: "radio")
        }
        if eventDetail.isProgramEvent == 1{
            editButton.isHidden = true
            deleteButton.isHidden = true
            chatbutton.isHidden = true
        }
        if  eventDetail.members_add_number?.count != 0{
            signupSheetImageView.image = UIImage(named: "Oval Copy 3")
        }else{
            signupSheetImageView.image = UIImage(named: "radio")
        }
    }

    func getUserChatRoomDetails(_ userID:String?) {
        guard let userID = userID else {return}
        DIWebLayerUserAPI().getInfo(id: userID) {[weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.ownerLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
                self.profilePicURL = user.profilePicUrl ?? ""
                self.chatRoomId = user.chatRoomId
            }
        } failure: { error in
            self.showAlert(withError: error)
        }
    }
    @IBAction func activityAddonMoreAction(_ sender: Any) {
        let VC = loadVC(.ActivityAddOnListVC) as! ActivityAddOnListVC
        VC.isViewModeOn = true
        VC.screenFrom = .eventInfo
        VC.activityAddOnsArr  = eventDetail?.activityAddOn
        self.navigationController?.pushViewController(VC, animated: true)
    }
    //This function will call API to save data on backend server....
    private func getMembersList() {
        guard isConnectedToNetwork() else {
            return
        }
        let params = [
            "page": 0,
            "limit": 15
        ]
        DIWebLayerEvent().getMemberList(parameter: params, id: eventId, success: { [weak self](memberList) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.eventDetail?.members = memberList
                self.setUpMemberInfo()
                self.membersView.reloadData()
            }
            //self.hideLoader()
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError: error!)
        }
    }

    private func setUpMemberInfo() {
        if let members = eventDetail?.members, members.count > 0 {
            if let currentUserMember = members.first(where: { member in member.userId == User.sharedInstance.id }),
               let answer = EventInvitationStatus(rawValue: currentUserMember.inviteAccepted ?? 0) {
                self.setupJoinBtnView(answer)
            } else {
                self.setupJoinBtnView(.pending)
            }
        } else {
            self.setupJoinBtnView(.pending)
        }
    }

    //This method is used to delete a event.
    private func callDeleteEventAPI(_ deleteType : DeleteEventType = .allFutureEvents){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        let date = (deleteType == .allFutureEvents) ? "0" : timeZoneDateFormatter(format: .eventUtcDateString, timeZone: utcTimezone).string(from: eventDetail?.eventStartDate ?? Date())
        var params: [String:Any] = [:]
        params["userId"] = User.sharedInstance.id ?? ""
        params["is_deleted"] = 1
        params["_id"] = eventDetail?.id ?? ""
        params["reccurEvent"] = eventDetail?.reccurEvent ?? 0
        params["updatedFor"] = selectedEventDate
        params["updateAllEvents"] = deleteType.rawValue
        params["rootUpdatedFor"] = eventDetail?.rootUpdatedFor ?? ""
        DIWebLayerEvent().updateEvent(parameter:params,success: { (message) in
            self.hideLoader()
            self.showAlert(message:"Event deleted successfully.",okCall:{
                self.delegate?.deleteEvent(section: self.section, eventId: self.eventId, deleteType: deleteType)
                self.delSuccessEvent(deleteType,self.eventId)
                if let filteredVC = self.navigationController?.viewControllers.filter({$0.isKind(of: CalendarVC.self)}),let calendarVC = filteredVC.first{
                    self.navigationController!.popToViewController(calendarVC, animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                //self.navigationController?.popViewController(animated: true)
            })
        }) { (error) in
            self.hideLoader()
            let err = error?.message
            self.showAlert(withTitle: "", message: "\(err!)")
            //       self.showAlert(withError: error)
        }
    }
    func delSuccessEvent( _ deleteType : DeleteEventType = .allFutureEvents,_ eventID:String) {
        let dic:[String:Any] = ["deleteType":deleteType,"eventId":eventID]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.deleteEvent), object: nil, userInfo: dic)
    }


    //This method is used to get params to join event.
    private func getJoiningParams(_ joinType:EventAcceptRejectStatus) -> Parameters{
        var joinEvent = JoinEvent()
        joinEvent.eventId = self.eventId
        joinEvent.status = joinType
        return joinEvent.toDict()
    }

    private func setupJoinBtnView(_ joinType:EventInvitationStatus){
        if eventDetail?.isProgramEvent == 1{
            startActivityButton.isHidden = false
            return
        }else{
            startActivityButton.isHidden = true
        }

        let isPaymentDone = checkPaymentStatus()
        if isPaymentDone && joinType == .pending{
            callAcceptOrRejectEventAPI(.Accept)
        }
        switch joinType {
        case .accepted:
            joinButton.setTitle("Remove from my Calendar", for: .normal)

            if currentDate >= eventDetail?.eventStartDate ?? Date() && currentDate <= eventDetail?.eventEndDate ?? Date(){
                // redirection on activity screen
                startActivityButton.isHidden = false
            } else{
                startActivityButton.isHidden = true
            }
        case .rejected:
            break
        case .pending,.removed:
            joinButton.setTitle("Add to my Calendar", for: .normal)
        }

        self.joinStatus = joinType
    }

    //This method is used to accept or reject request of event.
    private func callAcceptOrRejectEventAPI(_ joinType:EventAcceptRejectStatus){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerEvent().joinEvent(parameter: getJoiningParams(joinType), success: { (data) in
            if data == "added-to-queue" {
                self.showAlert(message: "Unfortunately, there are no open slots in this event. We added you to the waiting list, and will send a notification once a slot becomes available")
            } else {
                self.delegate?.updateEvent(editMode: .thisAndOtherEvent, eventDetail: self.eventDetail, section: self.section)
                //                if joinType.rawValue == EventInvitationStatus.accepted.rawValue {
                //                    self.setupJoinBtnView(.accepted)
                //                } else if joinType.rawValue == EventInvitationStatus.rejected.rawValue {
                //                    self.setupJoinBtnView(.rejected)
                //                } else {
                //                    self.setupJoinBtnView(.pending)
                //                }
            }
            self.hideLoader()
            self.getEventDetail()
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError: error!)
        }
    }

    private func callRemoveEventApi(eventId:String){
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerEvent().removeEvent(eventId:eventId) { data in
            self.hideLoader()
            self.getEventDetail()
            self.setupJoinBtnView(.pending)
        } failure: { error in
            self.hideLoader()
            print(error)
        }
    }

    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .deleteEvent {
            if let deleteEventType = DeleteEventType(rawValue: index){
                CalendarManager.shared.deleteEventFromiCal(deleteEventType,eventDetail)
                self.callDeleteEventAPI(deleteEventType)
            }
        }
    }

    //on dismissing the activity sheet, reset the border color of the textfield to default gray
    override func cancelSelection(type: SheetDataType) {

    }



    //This method is used to edit a event and navigate user to edit event screen.
    func editTapped(_ button:UIButton){
        let createEventVC:CreateEventViewController = UIStoryboard(storyboard: .createevent).initVC()
        createEventVC.isEditEvent = true
        createEventVC.eventDetail = self.eventDetail
        createEventVC.eventID = self.eventId
        createEventVC.delegate = self
        createEventVC.section = self.section
        self.navigationController?.pushViewController(createEventVC, animated: true)
    }

    func checkEventIsPaidOrNot() -> Bool{
        if let userId = eventDetail?.userId  {
            if userId == User.sharedInstance.id {
                return false
            }
            else if eventDetail?.payableAmount != 0 && eventDetail?.isPaid == false{
                return true
            }
            return false
        }
        return false
    }

    func checkPaymentStatus() -> Bool{
        if let userId = eventDetail?.userId  {
            if userId == User.sharedInstance.id {
                return false
            }
            //            else if eventDetail?.payableAmount != nil {
            //                return true
            //            }
            else if eventDetail?.payableAmount != nil && eventDetail?.payableAmount != 0 && eventDetail?.isPaid == true{
                return true
            }
            return false
        }
        return false
    }

    func showPaymentAlert(){
        self.showAlert(withTitle: "", message: "You have to pay $\(eventDetail?.payableAmount ?? 0) amount to join this event", okayTitle: AppMessages.AlertTitles.Ok,  okCall:{
            self.getPaymentLink(completion: { url in
                if let paymentURL = url{
                    self.navigateToWebView(url: paymentURL)
                }
            })
        })
    }

    func showActivityScreen(){
        if self.eventDetail?.activityAddOn?.count != 0{
            self.starActivtity()
        }else{
            let activityVC: ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
            activityVC.screenFrom = .event
            activityVC.eventID = self.self.eventId
            self.navigationController?.pushViewController(activityVC, animated: true)
        }
    }

    @IBAction func startEventTapped(_ sender: UIButton) {
        if eventDetail?.isProgramEvent == 1{
            DIWebLayerEvent().startProgramEvent(parameter: ["eventId": eventDetail?.id ?? ""], success: { msg  in
                self.showActivityScreen()
            }, failure: { error in
                self.alertOpt(error?.message ?? "")
            })
        } else{
            showActivityScreen()
        }

    }
    @IBAction func yesTapped(_ sender: UIButton){
        switch joinStatus {

        case .accepted:
            callRemoveEventApi(eventId: self.eventDetail?.id ?? "")
        case .rejected:
            break
        case .pending,.removed:
            let isPaid = checkEventIsPaidOrNot()
            if isPaid{
                showPaymentAlert()
            }
            else{
                callAcceptOrRejectEventAPI(.Accept)
                getMembersList()
            }

        }
    }
    func starActivtity(){
        //Start eventity
        //v1.9/events/activitylist
        let endPointInfo = EndPoint.EventsActsGet(self.eventId )
        DIWebLayerEvent().getEventsActivities(endPoint: endPointInfo.url, parent: self,params: endPointInfo.params) {[weak self] status, data, message in
            switch status {
            case .DataFound:
                if let data = data as? [ActivityData] {
                    self?.navigateToActivity(data)
                }
            case .NoDataFound:
                print(message)
            case .Error:
                print(message)
            }
        }
    }
    func navigateToActivity(_ activity:[ActivityData]) {
        let VC = loadVC(.EventsActAddOnsVC)  as! EventsActAddOnsVC
        VC.allActivities = activity
        VC.eventID = eventId
        VC.programId = eventDetail?.programId ?? ""
        VC.programEventId = eventDetail?.programEventId ?? ""
        // vc.activityCategoryDataType =
        self.navigationController?.pushViewController(VC, animated: true)
    }

    @IBAction func noTapped(_ sender: UIButton){
        if sender.backgroundColor != #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1) {
            callAcceptOrRejectEventAPI(.Reject)
        }
    }

    @IBAction func checkListMoreTapped(_ sender:UIButton){
        let roundChecklistVC: RoundChecklistViewController = UIStoryboard(storyboard: .createevent).initVC()
        roundChecklistVC.screenFrom = .eventInfo
        roundChecklistVC.fetchedRounds = self.eventDetail?.rounds ?? []
        roundChecklistVC.eventId = self.eventId
        self.navigationController?.pushViewController(roundChecklistVC, animated: true)
    }
    func getPaymentLink(completion: @escaping (_ message:String?) -> Void) {
        DIWebLayerEvent().getPaymentLink(affiliateId: eventDetail?.userId ?? "", eventId: eventDetail?.id ?? "", amount: eventDetail?.payableAmount ?? 0, completion: { url in
            completion(url)

        }, failure: { error in
            print(error.message)

        })


    }

    func navigateToWebView(url:String){
        let webView:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
        webView.urlString = url
        webView.navigationTitle = "Payment"
        webView.paymentFrom = .Event
        self.navigationController?.pushViewController(webView, animated: true)
    }

    func setRoundsLbl(rounds:[EventRounds]){
        checkListsLbl.textAlignment = .left
        var lblText = ""

        if rounds.count != 0{
            checklistTogleImageView.image = UIImage(named: "Oval Copy 3")
        }else{
            checklistTogleImageView.image = UIImage(named: "radio")
        }

        if rounds.count == 0{
            lblText = "No checklist added !"
            checkListsLbl.textAlignment = .center
        }else if rounds.count > 2{
            lblText = """
                                Round1   (\(rounds[0].tasks?.count ?? 0) Tasks)
                                Round2   (\(rounds[1].tasks?.count ?? 0) Tasks)
                                """
        }
        else{
            for round in (0...rounds.count-1){
                lblText.append("Round\(round+1)   (\(rounds[round].tasks?.count ?? 0) Tasks)\n")
            }
        }
        checkListsLbl.text = lblText
    }
}

extension EventDetailViewController:UICollectionViewDelegate,UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mediaCollectionView{
            if listOfFiles.count == 0 {
                mediaCollectionView.setEmptyMessage("No media added !", textColor: .white)
            }else{
                mediaCollectionView.setEmptyMessage("", textColor: .white)
                return listOfFiles.count
            }
            return 0
        }else{
            if eventDetail?.members?.count ?? 0 > 2 {
                return 2
            }else{
                return self.eventDetail?.members?.count ?? 0
            }
        }


    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mediaCollectionView{
            guard let cell: MediaCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCollectionViewCell.reuseIdentifier, for: indexPath) as? MediaCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.setData(data: listOfFiles[indexPath.item])
            return cell
        }
        else{

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TematesInfoCell.reuseIdentifier, for: indexPath) as? TematesInfoCell else {
                return UICollectionViewCell()
            }
            if eventDetail?.members?.count ?? 0 < 3{
                cell.isShowMore = false
                if let member = self.eventDetail?.members?[indexPath.item]{
                    cell.configureCell(member:member)

                }
            }else{
                if indexPath.row == 0{
                    cell.isShowMore = false
                    if let member = self.eventDetail?.members?[indexPath.item]{
                        cell.configureCell(member:member)
                    }
                }else if indexPath.row == 1{
                    cell.showTematesDelegate = self
                    cell.isShowMore = true
                    if let member = self.eventDetail?.members?[indexPath.item]{
                        cell.configureCell(member:member)
                    }
                }

            }

            return cell
        }

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mediaCollectionView{
            if let mediaType = listOfFiles[indexPath.item].mediaType{
                switch EventMediaType(rawValue: mediaType){
                case .video:
                    let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
                    episodeVideoVC.url = listOfFiles[indexPath.item].url ?? ""
                    self.navigationController?.pushViewController(episodeVideoVC, animated: false)
                case .pdf:
                    let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
                    selectedVC.urlString = listOfFiles[indexPath.item].url ?? ""
                    self.navigationController?.pushViewController(selectedVC, animated: true)
                default:
                    break
                }
            }
        }

    }
}
extension EventDetailViewController: ShowTematesDelegate{
    func showMoreTemates() {
        let expendedVC: EventDetailsExpendedViewController = UIStoryboard(storyboard: .calendar).initVC()
        expendedVC.eventDetail = self.eventDetail
        self.navigationController?.pushViewController(expendedVC, animated: true)
    }


}
extension EventDetailViewController:EventDelegate{
    func deleteEvent(section: Int, eventId: String, deleteType: DeleteEventType) {
    }

    func updateEventList(section: Int, eventID: String) {
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func backTapped() {
    }

    func updateEvent(editMode: EditRecurringEventMode, eventDetail: EventDetail?,section:Int) {
        if eventDetail?.id?.isEmpty ?? false{
            getEventDetail(editMode: editMode)
        } else {
            self.eventDetail = eventDetail
            self.delegate?.updateEvent(editMode: editMode, eventDetail: self.eventDetail, section: self.section)
            self.setUpEventDetail()
        }
    }
}
extension EventDetailViewController: UICollectionViewDelegateFlowLayout
{
    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == mediaCollectionView{
            return CGSize(width: 100, height: 100)
        } else{
            return CGSize(width: membersView.frame.size.width, height: 50)
        }
    }
}

