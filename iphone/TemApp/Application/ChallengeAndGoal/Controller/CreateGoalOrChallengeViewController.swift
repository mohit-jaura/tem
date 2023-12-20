//
//  CreateGoalOrChallengeViewController.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Firebase
import SSNeumorphicView
import Kingfisher

protocol CreateGoalChallengeViewProtocol: AnyObject {
    func didCreatedNewActivity()
}

class CreateGoalOrChallengeViewController: DIBaseController, UITextFieldDelegate {
    
    // MARK: Properties
    weak var delegate: CreateGoalChallengeViewProtocol?
    var selectedFriends:[Friends]?
    var selectedGroup: ChatRoom?
    var presenter: CreateGoalOrChallengePresenter!
    var startDatePicker: UIDatePicker?
    var screenFrom: Constant.ScreenFrom?
    var groupActivityInfo: GroupActivity?
    var isEditingCurrentActivity: Bool = false
    
    private enum TemVsTemSelectionState {
        case tem1Selected, tem2Selected, none
    }
    
    private var temVsTemState: TemVsTemSelectionState = .none
    var photoManager:PhotoManager!
    private var fieldsArray:[InputFieldTableCellViewModel] = [InputFieldTableCellViewModel]()
    private var fundraisingViewModel: FundraisingViewModel?
    var isType:Bool = true
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gradientView:GradientDashedLineCircularView!
    var fundsSelect:Bool = false
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var nameField:UITextField!
    @IBOutlet weak var typeField:UITextField!
    @IBOutlet weak var descriptionField:UITextField!
    @IBOutlet weak var startDateField:UITextField!
    @IBOutlet weak var activitySelectionField:UITextField!
    @IBOutlet weak var customActivitySelectionField:UITextField!
    @IBOutlet weak var durationSelectionField:UITextField!
    @IBOutlet weak var customActivitySelectionView:UIView!
    @IBOutlet weak var activitySelectionView:UIView!
    @IBOutlet weak var tematesField:UITextField!
    @IBOutlet weak var temates2Field:UITextField!
    @IBOutlet weak var typeViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var metricsField:UITextField!
    @IBOutlet weak var postProgessFeedField:UITextField!
    @IBOutlet weak var perPersonGoalField:UITextField!
    @IBOutlet weak var fundraisingField:UITextField!
    @IBOutlet weak var fundsdestinationField:UITextField!
    @IBOutlet weak var goalamountField:UITextField!
    @IBOutlet weak var tem1View:UIView!
    @IBOutlet weak var tem2View:UIView!
    @IBOutlet weak var fundsDestinationView:UIView!
    @IBOutlet weak var goalsAmountView:UIView!
    @IBOutlet var innerShadowViews: [SSNeumorphicView]!
    @IBOutlet var toggleShadowViews: [SSNeumorphicView]!
    @IBOutlet var outerShadowViews: [SSNeumorphicView]!
    @IBOutlet weak var imageOuterShadowView:SSNeumorphicView!{
        didSet{
            imageOuterShadowView.viewDepthType = .outerShadow
            imageOuterShadowView.viewNeumorphicCornerRadius = imageOuterShadowView.frame.height / 2
            imageOuterShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            imageOuterShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            imageOuterShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            imageOuterShadowView.viewNeumorphicShadowRadius = 0.2
            imageOuterShadowView.viewNeumorphicShadowOpacity = 0.4
            imageOuterShadowView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
        }
    }
    
    @IBOutlet var imageInnerShadowView: [SSNeumorphicView]!{
        didSet{
            for view in imageInnerShadowView {
                view.viewDepthType = .innerShadow
                view.viewNeumorphicCornerRadius = view.frame.height / 2
                view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
                view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
                view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
                view.viewNeumorphicShadowRadius = 0.2
                view.viewNeumorphicShadowOpacity = 0.4
                view.viewNeumorphicShadowOffset = CGSize(width: 1, height: 1)
            }
        }
    }
    @IBOutlet weak var newGoalOrChallengeButton: UIButton!
    @IBOutlet weak var perPersonView: UIView!
    @IBOutlet weak var postProgressView: UIView!
    @IBOutlet weak var newGoalOrChallengeButtonGradientView:GradientDashedLineCircularView!
    @IBOutlet weak var nameToggle:UIButton!
    @IBOutlet weak var descriptionToggle:UIButton!
    @IBOutlet weak var startDateToggle:UIButton!
    @IBOutlet weak var activitySelectionToggle:UIButton!
    @IBOutlet weak var tematesToggle:UIButton!
    @IBOutlet weak var metricsToggle:UIButton!
    @IBOutlet weak var privateActivityToggle:UIButton!
    @IBOutlet weak var tematesActivityToggle:UIButton!
    @IBOutlet weak var publicActivityToggle:UIButton!
    @IBOutlet weak var postProgessFeedToggle:UIButton!
    @IBOutlet weak var perPersonGoalToggle:UIButton!
    @IBOutlet weak var fundraisingToggle:UIButton!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tem2View.isHidden = true
        self.presenter.initialize(currentView: self, groupActivityInfo: self.groupActivityInfo)
        self.initUI()
        self.newGoalOrChallengeButton.layer.cornerRadius = self.newGoalOrChallengeButton.frame.width / 2
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
        
        var selectedMembersInfo: [String: Any] = [:]
        if let chatGroup = selectedGroup {
            selectedMembersInfo["group"] = chatGroup
        }
        if let selectedMembers = selectedFriends {
            selectedMembersInfo["members"] = selectedMembers
        }
        self.presenter.updateCurrentGroupActivity(withValue: selectedMembersInfo, currentSection: .temates)
        
        self.presenter.updateCurrentGroupActivity(withValue: groupActivityInfo?.name, currentSection: .name)//Name----------->>
        self.presenter.updateCurrentGroupActivity(withValue: groupActivityInfo?.description, currentSection: .description)// DEscription------------->>
        if self.isEditingCurrentActivity{// Date--------->>
            let displayDate = groupActivityInfo?.startDate?.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? ""
            self.presenter.updateCurrentGroupActivity(withValue: displayDate, currentSection: .startDate)
            startDateField.isUserInteractionEnabled = false
        }
        self.presenter.updateCurrentGroupActivity(withValue: groupActivityInfo?.duration, currentSection: .duration)//Duration--------->>
        self.presenter.updateCurrentGroupActivity(withValue: groupActivityInfo?.anyActivity, currentSection: .activitySelectionType)//activitySelection--------->>

        if groupActivityInfo?.openToPublic == true{
            privateActivityToggle.setBackgroundImage( nil, for: .normal)
            tematesActivityToggle.setBackgroundImage(nil, for: .normal)
            publicActivityToggle.setBackgroundImage(UIImage(named:"Oval Copy 3"), for: .normal)
        } else if groupActivityInfo?.openToPublic == false{
            privateActivityToggle.setBackgroundImage(UIImage(named: "Oval Copy 3"), for: .normal)
            tematesActivityToggle.setBackgroundImage(nil, for: .normal)
            publicActivityToggle.setBackgroundImage(nil, for: .normal)
        }
        
        if groupActivityInfo?.isPerPersonGoal == true{
            perPersonGoalToggle.setBackgroundImage(UIImage(named:"Oval Copy 3"), for: .normal)
            
        }else if groupActivityInfo?.isPerPersonGoal == false{
            perPersonGoalToggle.setBackgroundImage(nil, for: .normal)
        }
        
        if groupActivityInfo?.isPublic ?? true{
            postProgessFeedToggle.setBackgroundImage(UIImage(named:"Oval Copy 3"), for: .normal)
        }else{
            postProgessFeedToggle.setBackgroundImage(nil, for: .normal)
        }
        
        if groupActivityInfo?.fundraising != nil{
            fundraisingToggle.setBackgroundImage(UIImage(named:"Oval Copy 3"), for: .normal)
        } else{
            fundraisingToggle.setBackgroundImage(nil, for: .normal)
        }
        
        if let goalImage = groupActivityInfo?.image ,let url = URL(string: goalImage){
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        } else{
            imageView.image = UIImage(named: "placeholder")
        }
    }
    
    func createGradientViewNew(view:GradientDashedLineCircularView) {
        let locations: [NSNumber] = [0, 0.2, 0.4, 0.6, 0.8, 1]
        view.configureViewProperties(colors: [UIColor.orange, UIColor.orange, UIColor.purple, UIColor.purple, UIColor.purple.withAlphaComponent(0.4), UIColor.purple.withAlphaComponent(0.2)], gradientLocations: locations)
        view.instanceWidth = 2.0
        view.instanceHeight = 3.0
        view.lineColor = UIColor.appThemeDarkGrayColor
        view.updateGradientLocation(newLocations: locations, addAnimation: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if isType {
            perPersonView.isHidden = false
            postProgressView.isHidden = false
            typeViewConstraint.constant = 0.0
            
        } else {
            perPersonView.isHidden = true
            postProgressView.isHidden = true
            typeViewConstraint.constant = 59.0
        }
    }
    
    // MARK: Initializer
    
    func initUI() {
        fundraisingViewModel = FundraisingViewModel()
        fundraisingViewModel?.info = self.presenter.groupActivity
        initInnerShadowView()
        initOuterShadowView()
        initToggleShadowView()
        initTextFields()
        createGradientViewNew(view: gradientView)
    }
    private func initInnerShadowView() {
        for view in innerShadowViews {
            view.setOuterDarkShadow()
            view.viewDepthType = .innerShadow
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    private func initToggleShadowView() {
        for view in toggleShadowViews {
            view.setOuterDarkShadow()
            view.viewDepthType = .innerShadow
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            view.cornerRadius = view.frame.height / 2
        }
    }
    private func initOuterShadowView() {
        for view in outerShadowViews {
            view.setOuterDarkShadow()
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            if view.tag == 11 { // tag 11 set statictly in story board for start button
                view.viewNeumorphicCornerRadius = view.frame.height / 2
            }
        }
    }
    
    private func initTextFields() {
        let textFieldsArray: [UITextField] = [nameField, descriptionField, startDateField, durationSelectionField, activitySelectionField, customActivitySelectionField, tematesField, temates2Field, metricsField, postProgessFeedField, perPersonGoalField, fundraisingField, fundsdestinationField, goalamountField]
        for field in textFieldsArray {
            field.setCustomPlaceholder(placeholder: field.placeholder?.uppercased())
        }
    }
    // MARK: Navigation
    private func pushToTematesScreen() {
        self.view.endEditing(true)
        let tematesVC: InviteFriendController = UIStoryboard(storyboard: .challenge).initVC()
        tematesVC.delegate = self
        if self.temVsTemState == .none {
            tematesVC.selectedFriends = self.selectedFriends ?? [Friends]()
            tematesVC.selectedGroup = self.selectedGroup
        } else if self.temVsTemState == .tem1Selected {
            if (User.sharedInstance.isCompanyAccount == 1) {
                tematesVC.showListForTem2Challenge = true
            }
            tematesVC.selectedGroup = self.presenter.groupActivity?.tem1?.toChatRoomType()
        } else if self.temVsTemState == .tem2Selected {
            tematesVC.showListForTem2Challenge = true
            tematesVC.selectedGroup = self.presenter.groupActivity?.tem2?.toChatRoomType()
        }
        tematesVC.screenFrom = self.presenter.screenType
        tematesVC.activityMembersType = self.presenter.activityMembersType
        self.navigationController?.pushViewController(tematesVC, animated: true)
    }
    
    // MARK: Helpers
    override func handleSelection(index: Int, type: SheetDataType) {
        switch type {
        case .activitySelectionType:
            let selection = ActivitySelectionType.allCases[index]
            if selection == .any {
                self.presenter.groupActivity?.anyActivity = true
                self.presenter.groupActivity?.activityTypes?.removeAll()
                customActivitySelectionView.isHidden = true
                activitySelectionView.isHidden = false
            } else if selection == .custom {
                self.presenter.groupActivity?.anyActivity = false
                customActivitySelectionView.isHidden = false
                activitySelectionView.isHidden = true
                self.presenter.showActivitiesModal()
                
            }
            activitySelectionField.text = selection.title
        case .duration:
            self.presenter.updateCurrentGroupActivity(withValue: index, currentSection: .duration)
        case .fundraisingDestination:
            fundraisingViewModel?.info?.fundraising?.destination = GNCFundraisingDestination.allCases[index]
            fundsdestinationField.text = fundraisingViewModel?.info?.fundraising?.destination?.description()
        default:
            break
        }
    }
    
    override func handleSelection(indices: [Int], type: SheetDataType) {
        switch type {
        case .activity:
            self.presenter.updateCurrentGroupActivity(withValue: indices, currentSection: .activity)
        default:
            break
        }
    }
    
    override func cancelSelection(type: SheetDataType) {
        switch type {
        case .duration:
            self.changeInputFieldState(forSection: .duration)
        case .activity:
            self.changeInputFieldState(forSection: .activity)
        case .activitySelectionType:
            self.changeInputFieldState(forSection: .activitySelectionType)
        default:
            break
        }
    }
    
    /// post notifcations of goal and challenge edited
    private func postEditNotification(updatedGroupActivity: GroupActivity?) {
        if let screenType = self.presenter.screenType {
            switch screenType {
            case .createChallenge:
                NotificationCenter.default.post(name: Notification.Name.challengeEdited, object: nil, userInfo: ["groupActivity": updatedGroupActivity ?? [:]])
            case .createGoal:
                NotificationCenter.default.post(name: Notification.Name.goalEdited, object: nil, userInfo: ["groupActivity": updatedGroupActivity ?? [:]])
            default:
                break
            }
        }
    }
    
    /// create new chatroom id on firestore
    private func createChatRoomOnFirestore() {
        guard let roomId = self.presenter.groupActivity?.id else {
            return
        }
        let chatRoom = ChatRoom()
        chatRoom.chatType = .groupChat
        chatRoom.createdAt = Date().timeIntervalSince1970 //adding the current time to the group
        chatRoom.name = self.presenter.groupActivity?.name
        chatRoom.chatWindowType = .chatInChallenge
        ChatManager().updateChatRoomInformationToDatabase(roomId: roomId, groupInfo: chatRoom)
    }
    
    // MARK: IBActions
    
    @IBAction func nameToggleAction(_ sender:UIButton){
        self.changeToggleButtonState(sender)
    }
    
    @IBAction func descriptionToggleAction(_ sender:UIButton) {
        self.changeToggleButtonState(sender)
    }
    
    @IBAction func startDateToggleAction(_ sender:UIButton){
        self.changeToggleButtonState(sender)
    }
    
    @IBAction func activitySelectionToggleAction(_ sender:UIButton){
        self.changeToggleButtonState(sender)
    }
    
    @IBAction func tematesToggleAction(_ sender:UIButton){
        self.changeToggleButtonState(sender)
    }
    
    @IBAction func onClickMetrics(_ sender:UIButton){
        if isType {
            let selectedVC:GoalAndChallengeSideMenuViewController = UIStoryboard(storyboard: .challenge).initVC()
            selectedVC.delegate = self
            
            if let target = self.presenter.getUpdatedGoalTarget()?.first, let targetMetric = target.matric {
                if targetMetric == Metrics.totalActivityTime.rawValue {
                    //convert to minutes
                    let minutes = (target.value ?? 0)/60
                    selectedVC.currentValue = minutes
                    selectedVC.metric = .totalActivityTime
                } else {
                    if targetMetric == Metrics.distance.rawValue {
                        selectedVC.metric = .distance
                    } else if targetMetric == Metrics.calories.rawValue {
                        selectedVC.metric = .calories
                    } else if targetMetric == Metrics.totalActivites.rawValue {
                        selectedVC.metric = .totalActivites
                    }
                    selectedVC.currentValue = target.value
                }
            }
            
            self.present(selectedVC, animated: false, completion: nil)
        } else {
            let selectedVC:ChallengeSideMenuController = UIStoryboard(storyboard: .challenge).initVC()
            selectedVC.delegate = self
            
            if let target = self.presenter.groupActivity?.selectedMetrics {
                selectedVC.selectedChallenges = target
            }
            self.present(selectedVC, animated: false, completion: nil)
        }
    }
    
    @IBAction func metricsToggleAction(_ sender:UIButton){
        self.changeToggleButtonState(sender)
    }
    
    @IBAction func privateActivityToggleAction(_ sender:UIButton){
        privateActivityToggle.isSelected = true
        tematesActivityToggle.isSelected = false
        publicActivityToggle.isSelected = false
        privateActivityToggle.setBackgroundImage(UIImage(named: "Oval Copy 3"), for: .normal)
        tematesActivityToggle.setBackgroundImage(nil, for: .normal)
        publicActivityToggle.setBackgroundImage(nil, for: .normal)
        self.presenter.updateCurrentGroupActivity(withValue: false, currentSection: .openToPublic)
    }
    
    @IBAction func tematesActivityToggleAction(_ sender:UIButton){
        tematesActivityToggle.isSelected = true
        privateActivityToggle.isSelected = false
        publicActivityToggle.isSelected = false
        tematesActivityToggle.setBackgroundImage(UIImage(named: "Oval Copy 3"), for: .normal)
        publicActivityToggle.setBackgroundImage(nil, for: .normal)
        privateActivityToggle.setBackgroundImage(nil, for: .normal)
        self.presenter.updateCurrentGroupActivity(withValue: false, currentSection: .openToPublic)
    }
    
    @IBAction func publicActivityToggleAction(_ sender:UIButton){
        publicActivityToggle.isSelected = true
        privateActivityToggle.isSelected = false
        tematesActivityToggle.isSelected = false
        publicActivityToggle.setBackgroundImage(UIImage(named: "Oval Copy 3"), for: .normal)
        tematesActivityToggle.setBackgroundImage(nil, for: .normal)
        privateActivityToggle.setBackgroundImage(nil, for: .normal)
        self.presenter.updateCurrentGroupActivity(withValue: true, currentSection: .openToPublic)
    }
    
    @IBAction func postProgressToggleAction(_ sender:UIButton) {
        self.changeToggleButtonState(postProgessFeedToggle,valueadded: .publicGoal)
    }
    
    @IBAction func perPersonGoalToggleAction(_ sender:UIButton){
        self.changeToggleButtonState(perPersonGoalToggle,valueadded:.isPerPerson)
    }
    
    @IBAction func fundraisingEventToggleAction(_ sender:UIButton){
        self.changeToggleButtonState(fundraisingToggle,type: true)
    }
    
    // MARK: Methods
    private func changeToggleButtonState(_ sender:UIButton,type:Bool = false,valueadded:CreateGoalChallengeSection = .doNotParticipate){
        sender.isSelected.toggle()
        if sender.isSelected {
            if type {
                fundsDestinationView.isHidden = false
                goalsAmountView.isHidden = false
                let currentSection = CreateGoalChallengeSection.init(rawValue: 13)!
                
                fundsSelect = true
                self.presenter.updateCurrentGroupActivity(withValue: true, currentSection: currentSection)
            }
            
            if valueadded == .isPerPerson {
                self.presenter.updateCurrentGroupActivity(withValue: true, currentSection: .isPerPerson)
            }
            if valueadded == .publicGoal{
                self.presenter.updateCurrentGroupActivity(withValue: true, currentSection: .publicGoal)
            }
            
            sender.setBackgroundImage(UIImage(named: "Oval Copy 3"), for: .normal)
        } else {
            if type {
                fundsSelect = false
                fundsDestinationView.isHidden = true
                goalsAmountView.isHidden = true
                let currentSection = CreateGoalChallengeSection.init(rawValue: 13)!
                
                
                self.presenter.updateCurrentGroupActivity(withValue: false, currentSection: currentSection)
            }
            
            if valueadded == .isPerPerson {
                self.presenter.updateCurrentGroupActivity(withValue: false, currentSection: .isPerPerson)
            }
            
            if valueadded == .publicGoal {
                self.presenter.updateCurrentGroupActivity(withValue: false, currentSection: .publicGoal)
            }
            sender.setBackgroundImage(nil, for: .normal)
        }
    }
    
    @IBAction func onClickType(_ sender:UIButton) {
        let activityVC:ActivityTypeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
        activityVC.delegate = self
        self.present(activityVC, animated: true, completion: nil)
    }
    
}

// MARK: CreateGoalOrChallengePresenterDelegate
extension CreateGoalOrChallengeViewController: CreateGoalOrChallengePresenterDelegate {
    func didCreateChallengeOrGoalSuccessfully(successMessage: String?, newInfo: GroupActivity?) {
        if let info = newInfo,
           self.isEditingCurrentActivity == false,
           let id = info.id {
            //if the screen is for create g/c
            //register current user in the chat room
            self.presenter.groupActivity?.id = id
            self.createChatRoomOnFirestore()
        }
        if let message = successMessage {
            self.showAlert(withTitle: "", message: message, okayTitle: AppMessages.AlertTitles.Ok, okStyle: .default, okCall: {
                if self.isEditingCurrentActivity {
                    let updatedGroupActivity = newInfo
                    updatedGroupActivity?.id = self.presenter.groupActivity?.id
                    self.postEditNotification(updatedGroupActivity: updatedGroupActivity)
                }
                self.delegate?.didCreatedNewActivity()
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showActivitiesListingOnView(array: [ActivityData], selectedIndices: [Int]?) {
        self.view.endEditing(true)
        self.showSelectionModal(array: array, type: .activity, multiSelectionOn: true, selectedIndices: selectedIndices)
    }
    
    func showDurationListingOnView(array: [String]) {
        self.showSelectionModal(array: array, type: .duration)
    }
    
    func showErrorAlertOnView(errorMessage: String) {
        self.showAlert(message: errorMessage)
    }
    
    func formValidation() -> Bool {
        if let errorMsg = self.getErrorMessage(){
            self.showLoader(shouldVisible: false)
            self.showAlert(message: errorMsg)
            return false
        }else{
            return true
        }
    }
    
    func getErrorMessage() -> String?{
        if nameField.text?.count == 0 || nameField.text!.hasPrefix(" "){
            return "Please enter name"
        }
        else if descriptionField.text?.count == 0 || descriptionField.text!.hasPrefix(" "){
            return "Please enter description"
        }
        else if startDateField.text?.count == 0 || startDateField.text!.hasPrefix(" "){
            return "Please select start date"
        }
        else if durationSelectionField.text?.count == 0 || durationSelectionField.text!.hasPrefix(" "){
            return "Please select duration"
        }
        else if activitySelectionField.text?.count == 0 || activitySelectionField.text!.hasPrefix(" "){
            return "Please select any activity"
        }
        else if metricsField.text?.count == 0{
            return "Please select metrics"
        }
        else if !privateActivityToggle.isSelected && !publicActivityToggle.isSelected && !tematesActivityToggle.isSelected {
            return "Please select goal/challenge visibilty"
        }
        else{
            return nil
        }
    }
    
    func showLoader(shouldVisible: Bool) {
        if shouldVisible {
            self.showLoader()
        } else {
            self.hideLoader()
        }
    }
    
    func updateFieldsValue(atSection section: CreateGoalChallengeSection?, value: String) {
        if section?.rawValue ?? 1 == 1 {
            nameField.text = value
        }else if section?.rawValue ?? 2 == 2 {
            descriptionField.text = value
        } else if section?.rawValue ?? 3 == 3 {
            startDateField.text = value
        }else if section?.rawValue ?? 6 == 4 {
            durationSelectionField.text = value
        }else if section?.rawValue ?? 5 == 5 {
            activitySelectionField.text = value
        } else if section?.rawValue ?? 6 == 6 {
            customActivitySelectionField.text = value
        } else if section?.rawValue ?? 7 == 7 {
            tematesField.text = value
        } else if section?.rawValue ?? 8 == 8 {
            tematesField.text = value
        } else if section?.rawValue ?? 9 == 9 {
            temates2Field.text = value
        }
    }
    
    //change the selected state of textfield to unselected
    func changeInputFieldState(forSection section: CreateGoalChallengeSection) {
    }
    
    func reloadParentTableWithErrorMessage(atSection section: CreateGoalChallengeSection?, message: String) {
        guard section != .metrics else {
            self.showAlert(message: message)
            return
        }
        if let section = section?.rawValue , section < self.fieldsArray.count{
            self.fieldsArray[section].errorMessage = message
            self.tableView.reloadSections([section], with: .none)
        }
    }
    
    func showFundraisingValidationError(_ fundsDestinationError: String?, _ goalAmountError: String?) {
        fundraisingViewModel?.fundsDestinationError = fundsDestinationError
        fundraisingViewModel?.goalAmountError = goalAmountError
    }
    
    func updateParentMetricsView(forSelectedMetric metric: Metrics) {
    }
    
    //set navigation view of current screen
    func setNavigationItemWith(title: String) {
        let leftBarButtonItem = UIBarButtonItem(customView: self.getBackButton())
        self.setNavigationController(titleName: title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    func reloadParentTable(atSection section: CreateGoalChallengeSection?) {
        if let currentSection = section {
            let indexSet = IndexSet(integer: currentSection.rawValue)
            self.tableView.reloadSections(indexSet, with: .automatic)
        } else {
            self.tableView.reloadData()
        }
    }
    
    func presentMetricsPopOver(forSelectedMetric metric: Metrics) {
        let popOverController: AddMetricValuePopOverViewController = UIStoryboard(storyboard: .activitysummary).initVC()
        popOverController.currentMetric = metric
        if let target = self.presenter.getUpdatedGoalTarget()?.first, let targetMetric = target.matric,
           targetMetric == metric.rawValue {
            if metric == .totalActivityTime {
                //convert to minutes
                let minutes = (target.value ?? 0)/60
                popOverController.currentValue = minutes
            } else {
                popOverController.currentValue = target.value
            }
        }
        self.present(popOverController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource
extension CreateGoalOrChallengeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRowsIn(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = CreateGoalChallengeSection.allCases[indexPath.section]
        switch currentSection {
        case .doNotParticipate, .publicGoal, .openToPublic, .isPerPerson:
            let cell = tableView.dequeueReusableCell(withIdentifier: GoalToggleViewCell.reuseIdentifier, for: indexPath) as! GoalToggleViewCell
            cell.delegate = self
            cell.initialize(groupActivity: self.presenter.getCurrentInfo(), currentSection: currentSection)
            cell.setUserInteraction(shouldEnable: true)
            return cell
        case .metrics:
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectMetricsHoneyCombTableViewCell.reuseIdentifier, for: indexPath) as! SelectMetricsHoneyCombTableViewCell
            if let viewModel = self.presenter.viewModelForMetricsSelectionCell(atIndexPath: indexPath) {
                cell.initializeWith(viewModel: viewModel, isEditing: isEditingCurrentActivity, selectedMetrics: groupActivityInfo?.selectedMetrics, goalTarget: groupActivityInfo?.target)
            }
            return cell
        case .challengeType:
            let cell = tableView.dequeueReusableCell(withIdentifier: ChallengeTypeSelectionTableViewCell.reuseIdentifier, for: indexPath) as! ChallengeTypeSelectionTableViewCell
            
            cell.initializeWith(groupActivity: self.presenter.getCurrentInfo(), screenType: self.screenFrom ?? .createChallenge)
            return cell
        case .enableFundraising:
            let cell = tableView.dequeueReusableCell(withIdentifier: GoalToggleViewCell.reuseIdentifier, for: indexPath) as! GoalToggleViewCell
            cell.delegate = self
            cell.initialize(groupActivity: self.presenter.getCurrentInfo(), currentSection: currentSection)
            cell.setUserInteraction(shouldEnable: !self.isEditingCurrentActivity)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: InputFieldTableViewCell.reuseIdentifier, for: indexPath) as! InputFieldTableViewCell
            cell.inputTextField.tag = indexPath.section
            cell.inputTextField.placeholder = currentSection.textFieldPlaceholder
            
            cell.initializeWith(viewModel: self.fieldsArray[indexPath.section], indexPath: indexPath)
            cell.inputTextField.setUserInteraction(shouldEnable: true)
            if self.isEditingCurrentActivity,
               let currentField = CreateGoalChallengeSection(rawValue: indexPath.section) {
                if currentField == .startDate {
                    cell.inputTextField.setUserInteraction(shouldEnable: false)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: InputFieldTableCellDelegate
extension CreateGoalOrChallengeViewController {
    
    func didTapDoneOnInputTextField(sender: UIBarButtonItem) {
        if let currentInputField = CreateGoalChallengeSection(rawValue: sender.tag) {
            switch currentInputField {
            case .startDate:
                let displayDateString = self.startDatePicker?.date.toString(inFormat: .displayDate)
                self.presenter.updateCurrentGroupActivity(withValue: displayDateString, currentSection: currentInputField)
            default:
                break
            }
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == startDateField {
            //set date picker as input view for the textfield
            if self.startDatePicker == nil {
                self.startDatePicker = UIDatePicker()
            }
            if #available(iOS 13.4, *) {
                self.startDatePicker?.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            self.startDatePicker?.minimumDate = Date()
            self.startDatePicker?.datePickerMode = .date
            textField.inputView = self.startDatePicker
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onClickDoneButton))
            
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()
            textField.inputAccessoryView = toolBar
        } else if textField == tematesField {
            
            if let screenFrom = self.screenFrom,
               screenFrom == .createGroupChallenge {
                
            }
            temVsTemState = .tem1Selected
            self.pushToTematesScreen()
            
        }else if textField == temates2Field {
            
            if let screenFrom = self.screenFrom,
               screenFrom == .createGroupChallenge {
            }
            temVsTemState = .tem2Selected
            self.pushToTematesScreen()
            
        } else if textField == activitySelectionField {
            self.showSelectionModal(array: ActivitySelectionType.allCases, type: .activitySelectionType)
        } else if textField == customActivitySelectionField {
            self.presenter.showActivitiesModal()
        } else if textField == durationSelectionField {
            self.presenter.showDurationSelectionModal()
        }
    }
    
    @objc func onClickDoneButton() {
        let displayDateString = self.startDatePicker?.date.toString(inFormat: .displayDate)
        startDateField.text = displayDateString
        self.presenter.updateCurrentGroupActivity(withValue: displayDateString, currentSection: .startDate)
        self.view.endEditing(true)
    }
    
    @IBAction  func tappedOnBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func profilePictureTapped(_ sender: UIButton) {
        self.getImage()
    }
    //This Fucntion will get the Image from gallery or Camera...
    private func getImage() {
        photoManager = PhotoManager(navigationController: self.navigationController!, allowEditing: true, callback: { (pickedimage) in
            if(pickedimage != nil) {
                self.imageView.image = pickedimage
            }
        })
    }
    
    @IBAction  func tappedOnStartButton() {
        self.view.endEditing(true)
        if fundsSelect {
            if fundsdestinationField.text!.isEmpty {
                self.showErrorAlertOnView(errorMessage:  "Please select funds destination")
                return
            }
            else if goalamountField.text!.isEmpty {
                self.showErrorAlertOnView(errorMessage:  "Please add goal amount")
                return
            }
            let text = goalamountField.text ?? ""
            let value = Int(text)!
            let finalValue = Decimal(value * 2)
            self.fundraisingViewModel?.info?.fundraising?.goalAmount = finalValue
        }
        
        presenter.groupActivity?.name = nameField.text ?? ""
        presenter.groupActivity?.description = descriptionField.text ?? ""
        presenter.groupActivity?.startDateToDisplay = "\(startDateField.text ?? "")"
        if let strValue = startDateField.text {
            let timestamp = strValue.convertToDate(inFormat: .displayDate).timestampInMilliseconds
            presenter.groupActivity?.startDate = timestamp
        }
        
        showLoader()
        self.uploadImageOnFirebase(completion: { [self] (imgUrl) in
            if (imgUrl != nil) {
                self.presenter.groupActivity?.image = imgUrl
                self.presenter.createChallengeOrGoal()
            } else {
                self.hideLoader()
                self.showAlert(withTitle: "Warning", message: "firebase error occured")
            }
        })
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == fundsdestinationField {
            showFundsDestinationSelection()
            return false
        } else {
            
            return true
        }
    }
    
    func showFundsDestinationSelection() {
        self.showSelectionModal(array: GNCFundraisingDestination.allCases, type: .fundraisingDestination)
    }
    @objc func updateDateField(sender: UIDatePicker) {
        let value = formatDateForDisplay(date: sender.date)
        if value == "" {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            startDateField.text =  formatter.string(from: Date())
        } else {
            startDateField.text = value
        }
    }
    
    private func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    func inputTextFieldDidEndEditing(textField: UITextField) {
        if let currentField = CreateGoalChallengeSection(rawValue: textField.tag) {
            switch currentField {
            case .name, .description, .activity, .duration:
                self.fieldsArray[textField.tag].isHighlighted = false
                self.presenter.updateCurrentGroupActivity(withValue: textField.text, currentSection: currentField)
            case .tem1, .tem2:
                let indexPath = IndexPath(row: 0, section: textField.tag)
                let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell
                cell?.endEditing()
                self.presenter.updateCurrentGroupActivity(withValue: textField.text, currentSection: currentField)
            default:
                break
            }
        }
    }

    func didTapOnButtonOnInputField(sender: UIButton) {
        self.fieldsArray[sender.tag].isHighlighted = true
        if let currentField = CreateGoalChallengeSection(rawValue: sender.tag) {
            switch currentField {
            case .tem1, .tem2:
                self.temVsTemState = currentField == .tem1 ? .tem1Selected : .tem2Selected
                self.changeInputFieldState(forSection: currentField)
                self.pushToTematesScreen()
            default:
                break
            }
        }
    }
    
    func didTapOnRightView(sender: UIButton) {
        self.fieldsArray[sender.tag].isHighlighted = true
    }
}

// MARK: SelectMetricsHoneCombViewDelegate
extension CreateGoalOrChallengeViewController: ChallengeSideMenuDelegate {
    func didClickOnMetricHoneyComb(isAllSelected:Bool,metrics: Metrics) {
        if self.presenter.screenType == Constant.ScreenFrom.createGoal {
            self.presentMetricsPopOver(forSelectedMetric: metrics)
            return
        }
        self.presenter.updateCurrentGroupActivity(isAllSelected:isAllSelected,withValue: metrics, currentSection: .metrics)
        self.updateMetricValueLabel(forSelectedMetric: metrics, value: "")
    }
    
    func isGoal() -> Bool {
        return self.presenter.screenType == Constant.ScreenFrom.createGoal
        || self.presenter.screenType == Constant.ScreenFrom.editGoal
    }
    
}//Extension.....

// MARK: InviteFriendControllerViewDelegate
extension CreateGoalOrChallengeViewController: InviteFriendControllerViewDelegate {
    func didSelectTemates(members: [Friends]) {
        self.selectedFriends = members
        selectedGroup = nil
        self.presenter.updateCurrentGroupActivity(withValue: members, currentSection: .temates)
        
    }
    
    func didSelectGroup(group: ChatRoom) {
        if self.temVsTemState != .none {
            self.presenter.updateCurrentGroupActivity(withValue: group.toGroupActivityType(), currentSection: temVsTemState == .tem1Selected ? .tem1 : .tem2)
        } else {
            self.selectedFriends?.removeAll()
            self.selectedGroup = group
            self.presenter.updateCurrentGroupActivity(withValue: group, currentSection: .temates)
        }
    }
    
    func didSelectMembersAndTem(members: [Friends]?, group: ChatRoom?) {
        var selectedMembersInfo: [String: Any] = [:]
        if let chatGroup = group {
            selectedMembersInfo["group"] = chatGroup
        }
        if let selectedMembers = members {
            selectedMembersInfo["members"] = selectedMembers
        }
        self.selectedGroup = group
        self.selectedFriends = members
        self.presenter.updateCurrentGroupActivity(withValue: selectedMembersInfo, currentSection: .temates)
    }
    
    func noMemberAndTemSelected() {
        self.selectedGroup = nil
        self.selectedFriends?.removeAll()
        var indexPath = IndexPath(row: 0, section: CreateGoalChallengeSection.temates.rawValue)
        if self.temVsTemState != .none {
            let currentSection = temVsTemState == .tem1Selected ? CreateGoalChallengeSection.tem1 : CreateGoalChallengeSection.tem2
            indexPath = IndexPath(row: 0, section: currentSection.rawValue)
            self.presenter.resetActivityInfo(currentSection: currentSection)
        } else {
            self.presenter.resetActivityInfo(currentSection: .temates)
        }
    }
}

// MARK: get metric data...

extension CreateGoalOrChallengeViewController:GoalMetricData {
    
    func getMetricValue(value: String, metric: Metrics) {
        var newValue = value
        if metric == .totalActivityTime {
            //convert the value i.e. minutes to the total seconds
            newValue = "\((Double(value) ?? 0) * 60)"
        }
        let goalTarget = GoalTarget(matric: metric.rawValue, value: Double(newValue))
        self.presenter.updateCurrentGroupActivity(withValue: metric, currentSection: .metrics,target: [goalTarget])
        
        updateMetricValueLabel(forSelectedMetric: metric,value:value)
    }
    
    func updateMetricValueLabel(forSelectedMetric metric: Metrics,value:String) {
        metricsField.text = "\(value) \(metric.title)"
    }
    
}//Extension......

// MARK: - for Public goals

extension CreateGoalOrChallengeViewController: PublicGoalVlaue {
    func didToggle(value: Bool, tag: Int) {
        let currentSection = CreateGoalChallengeSection.init(rawValue: tag)!
        self.presenter.updateCurrentGroupActivity(withValue: value, currentSection: currentSection)
    }
}//Extension.....

extension CreateGoalOrChallengeViewController {
    func didSelectChallengeTypeButton(type: ActivityMembersType) {
        self.view.endEditing(true)
        if let existingType = self.presenter.activityMembersType,
           existingType != type {
        }
        self.presenter.updateCurrentGroupActivity(withValue: type, currentSection: .challengeType)
        if type == .individualVsTem || type == .temVsTem {
            self.presenter.updateCurrentGroupActivity(withValue: false, currentSection: .openToPublic)
        }
    }
}

extension CreateGoalOrChallengeViewController:ActivityTypeViewDelegate {
    func didSelectActivity(type: ActivityMembersType) {
        
        if let existingType = self.presenter.activityMembersType,
           existingType != type {
        }
        self.presenter.updateCurrentGroupActivity(withValue: type, currentSection: .challengeType)
        if type == .individualVsTem || type == .temVsTem {
            self.presenter.updateCurrentGroupActivity(withValue: false, currentSection: .openToPublic)
        }
        if type == .individual {
            typeField.text = "Individual"
            tem2View.isHidden = true
            tematesField.placeholder = "Temates"
        } else if type == .individualVsTem {
            typeField.text = "Individual Vs Tem"
            tem2View.isHidden = true
            tematesField.placeholder = "Temates"
        } else {
            typeField.text = "Tem Vs Tem"
            tem2View.isHidden = false
            tematesField.placeholder = "Tem 1"
        }
        self.view.endEditing(true)
    }
    
}


extension CreateGoalOrChallengeViewController : FundraisingViewCellDelegate {

    func goalAmountChanged(value: Decimal?) {
    }
}

extension CreateGoalOrChallengeViewController {
    func uploadImageOnFirebase(completion:@escaping (_ imageUrl: String?) ->()){

        //Check will set a new profile image name on firebase, if uploading on first time, but in update time, it will use old imagename and reupload on firebase
        if (User.sharedInstance.firebaseProfileImageName == nil) || (User.sharedInstance.firebaseProfileImageName == "") {
            User.sharedInstance.firebaseProfileImageName = (User.sharedInstance.id)!
        }
        
        let firImageName = (User.sharedInstance.firebaseProfileImageName ?? "") + Utility.shared.getFileNameWithDate()
        // Method changes
        guard let data = self.imageView.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        UploadMedia.shared.configureDataToUpload(type: .awsBucket, data: data, withName: firImageName, mimeType: "image/jpeg", mediaObj: Media())
        UploadMedia.shared.uploadImage(success: { (url, media) in
            completion(url)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message: error.message ?? "")
        }
    }
}
