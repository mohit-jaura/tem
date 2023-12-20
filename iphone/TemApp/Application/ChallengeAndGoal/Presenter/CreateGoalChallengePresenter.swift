//
//  CreateGoalChallengePresenter.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import Firebase

enum CreateGoalChallengeSection: Int, CaseIterable {
    case challengeType
    case name
    case description
    case startDate
    case duration
    case activitySelectionType
    case activity
    case temates
    case tem1
    case tem2
    case doNotParticipate
    case openToPublic
    case publicGoal
    case enableFundraising
    case fundraisingInfo
    case isPerPerson
    case metrics
    
    var textFieldPlaceholder:String{
        switch self {
        case .challengeType:
            return "ChallengeType"
        case .name:
            return "Name"
        case .description:
            return "Description"
        case .startDate:
            return "Start Date"
        case .duration:
            return "Duration"
        case .activitySelectionType:
            return "Activity Selection"
        case .activity:
            return "Activity"
        case .temates:
            return "TEMATES"
        case .metrics:
            return "Metrics"
        case .isPerPerson:
            return "Per Person Goal(automatically increase goal"
        case .enableFundraising:
            return "Fundraising Event"
        default:
            return String(rawValue).firstUppercased
        }
    }
}

enum ActivitySelectionType : CaseIterable {
    case any
    case custom
    
    var title: String {
        switch self {
        case .any: return "Any activity"
        case .custom: return "Custom"
        }
    }
}

enum goalChallengeFieldsErrorMessage: String, CaseIterable {
    case name, description , startDate,  duration, activity, temates , publicGoal , metrics
}

protocol CreateGoalOrChallengePresenterDelegate: AnyObject {
    func setNavigationItemWith(title: String)
    func reloadParentTable(atSection section: CreateGoalChallengeSection?)
    func reloadParentTableWithErrorMessage(atSection section: CreateGoalChallengeSection?,message:String)
    func showFundraisingValidationError(_ fundsDestination: String?, _ goalAmount: String?)
    func presentMetricsPopOver(forSelectedMetric metric: Metrics)
    func updateParentMetricsView(forSelectedMetric metric: Metrics)
    func updateFieldsValue(atSection section: CreateGoalChallengeSection?, value: String)
    func showErrorAlertOnView(errorMessage: String)
    func formValidation() -> Bool
    func showLoader(shouldVisible: Bool)
    
    func showDurationListingOnView(array: [String])
    func showActivitiesListingOnView(array: [ActivityData], selectedIndices: [Int]?)
    
    func didCreateChallengeOrGoalSuccessfully(successMessage: String?, newInfo: GroupActivity?)
}

class CreateGoalOrChallengePresenter {
    
    weak var delegate: CreateGoalOrChallengePresenterDelegate?
    /*
     this will hold the logic on the basis of different screen types
     */
    var screenType: Constant.ScreenFrom?
    var groupActivity: GroupActivity?
    private var isEditScreenView = false
    var activityMembersType: ActivityMembersType? {
        return groupActivity?.activityMembersType
    }
    
    let activityNetworkLayer = DIWebLayerActivityAPI()
    
    /// initializer for presenter. pass in the screen type
    init(forScreenType type: Constant.ScreenFrom) {
        self.screenType = type
    }
    
    func initialize(currentView: CreateGoalOrChallengePresenterDelegate, groupActivityInfo: GroupActivity?) {
        self.delegate = currentView
        if let activityInfo = groupActivityInfo {
            self.isEditScreenView = true
            self.groupActivity = activityInfo
        } else {
            self.groupActivity = GroupActivity()
            if let screenType = self.screenType,
               screenType == .createChallenge {
                self.groupActivity?.activityMembersType = .individual
            }
        }
        self.setUpViewLayout()
    }
    
    private func setUpViewLayout() {
        self.setTitleOfNavigation()
    }
    
    private func setTitleOfNavigation() {
        if let screenType = self.screenType {
            if isEditScreenView {
                switch screenType {
                case .createChallenge:
                    self.delegate?.setNavigationItemWith(title: Constant.ScreenFrom.editChallenge.title)
                case .createGoal:
                    self.delegate?.setNavigationItemWith(title: Constant.ScreenFrom.editGoal.title)
                default:
                    break
                }
            } else {
                self.delegate?.setNavigationItemWith(title: screenType.title)
            }
        }
    }
    
    // MARK: Api call
    //api call to get the activities data from server
    func getActivitiesFromServer() {
        guard Reachability.isConnectedToNetwork() else {
            self.delegate?.showErrorAlertOnView(errorMessage: AppMessages.AlertTitles.noInternet)
            return
        }
        self.delegate?.showLoader(shouldVisible: true)
        activityNetworkLayer.getUserActivityNew(forType: self.screenType, success: { (activities) in
            self.delegate?.showLoader(shouldVisible: false)
            self.groupActivity?.activities = activities
            self.showActivityTypes()
        }) { (error) in
            self.delegate?.showLoader(shouldVisible: false)
            if let error = error.message {
                self.delegate?.showErrorAlertOnView(errorMessage: error)
            }
        }
    }
    
    func showActivitiesModal() {
        if let activities = self.groupActivity?.activities,
           activities.isEmpty {
            self.getActivitiesFromServer()
            return
        }
        self.showActivityTypes()
    }
    
    private func showActivityTypes() {
        if let activities = self.groupActivity?.activities {
            let selectedIndices: [Int]? =
            groupActivity?.activityTypes?.map({ activityType in
                activities.firstIndex(where: { activity in activity.id == activityType.type })
            })
            .filter({ index in index != nil })
            .map({ index in index! })
            self.delegate?.showActivitiesListingOnView(array: activities, selectedIndices: selectedIndices)
        }
    }
    
    func showDurationSelectionModal() {
        let durationListing = Constant.GroupActivityConstants.durationList
        self.groupActivity?.durationList = durationListing
        self.delegate?.showDurationListingOnView(array: durationListing)
    }
    
    func createChallengeOrGoal() {
        guard Reachability.isConnectedToNetwork() else {
            self.delegate?.showErrorAlertOnView(errorMessage: AppMessages.AlertTitles.noInternet)
            return
        }
        self.delegate?.showLoader(shouldVisible: true)
        guard let formValidated = self.delegate?.formValidation() else{
            return
        }
        if formValidated{
            if let screenType = self.screenType, let event = self.groupActivity {
                switch screenType {
                case .createChallenge:
                    //create challenge api call
                    self.activityNetworkLayer.createChallenge(method: isEditScreenView ? .put : .post, parameters: CreateGoalOrChallengeDTO(event: event, type: .createChallenge).json() ?? Parameters(), completion: { (message, activityInfo) in
                        //Create totall challenge's event
                        //Analytics.logEvent("TotalCreatedChallenges", parameters: [:])
                        AnalyticsManager.logEventWith(event: Constant.EventName.totalCreatedChallenges,parameter: [:])
                        self.delegate?.showLoader(shouldVisible: false)
                        self.delegate?.didCreateChallengeOrGoalSuccessfully(successMessage: message, newInfo: activityInfo)
                    }) { (_) in
                        self.delegate?.showLoader(shouldVisible: false)
                    }
                case .createGoal:
                    //To create goals
                    DIWebLayerGoals().createGoal(httpMethod: isEditScreenView ? .put : .post, parameter: CreateGoalOrChallengeDTO(event: event, type: .createGoal).json() ?? Parameters(), success: { (message, activityInfo) in
                        
                        //Create totall goal's event
                        //   Analytics.logEvent("TotalCreatedGoals", parameters: [:])
                        AnalyticsManager.logEventWith(event: Constant.EventName.totalCreatedGoals,parameter: [:])
                        self.delegate?.showLoader(shouldVisible: false)
                        self.delegate?.didCreateChallengeOrGoalSuccessfully(successMessage: message, newInfo: activityInfo)
                    }) { (_) in
                        self.delegate?.showLoader(shouldVisible: false)
                    }
                default:
                    break
                }
            }
        }
    }
    
    // set the friends array in the temates section and returns the names of the members by concatenating
    func setInvitedMembers(members: [Friends], groupInfo: ChatRoom? = nil) -> String {
        var membersNameString = ""
        var concatenator = ", "
        if self.groupActivity?.members == nil {
            self.groupActivity?.members = [ActivityMember]()
        }
        for (index, member) in members.enumerated() {
            if member.user_id == UserManager.getCurrentUser()?.id { continue }
            var activityMember = ActivityMember()
            activityMember.id = member.user_id
            activityMember.name = member.fullName
            if let info = groupInfo {
                activityMember.groupId = info.groupId
                activityMember.type = .tem
            } else {
                activityMember.type = .temate
            }
            if index == (members.count - 1) { //if this is the last string
                concatenator = ""
            }
            membersNameString += "\(member.fullName)\(concatenator)"
            self.groupActivity?.members?.append(activityMember)
        }
        return membersNameString
    }
    
    // MARK: Function to check user has entered data for all field with proper validation.
    func checkFormValidations() -> Bool {
        var emptyFieldsCount:Int = 0
        if self.groupActivity?.name == nil || self.groupActivity?.name == ""{
            emptyFieldsCount += 1
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.name,message:AppMessages.GroupActivityMessages.emptyName)
        } else {
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.name, message:"")
        }
        if self.groupActivity?.startDateToDisplay == nil || self.groupActivity?.startDateToDisplay == "" {
            emptyFieldsCount += 1
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.startDate,message:AppMessages.GroupActivityMessages.emptyStartDate)
        } else {
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.startDate,message:"")
        }
        if self.groupActivity?.duration == nil {
            emptyFieldsCount += 1
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.duration,message:AppMessages.GroupActivityMessages.emptyDuration)
        } else {
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.duration,message:"")
        }
        if self.groupActivity?.anyActivity == nil {
            emptyFieldsCount += 1
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.activitySelectionType, message:AppMessages.GroupActivityMessages.emptyActivityType)
        } else if self.groupActivity?.anyActivity == false {
            if let activityTypes = self.groupActivity?.activityTypes {
                if activityTypes.isEmpty {
                    emptyFieldsCount += 1
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.activity,message:AppMessages.GroupActivityMessages.emptyActivityType)
                } else {
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.activity, message:"")
                }
            } else {
                emptyFieldsCount += 1
                self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.activity,message:AppMessages.GroupActivityMessages.emptyActivityType)
            }
        } else {
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.activitySelectionType, message:"")
            self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.activity, message:"")
        }
        
        self.validateCreateChallengeMembers(emptyFieldsCount: &emptyFieldsCount)
        
        if self.groupActivity?.selectedMetrics == nil || self.groupActivity?.selectedMetrics?.count == 0 {
            emptyFieldsCount += 1
            if self.screenType! == .createChallenge {
                self.delegate?.reloadParentTableWithErrorMessage(atSection: .metrics, message: AppMessages.GroupActivityMessages.selectChallengeMetrics)
            } else {
                self.delegate?.reloadParentTableWithErrorMessage(atSection: .metrics, message: AppMessages.GroupActivityMessages.selectGoalMetric)
            }
        }
        
        if let fundraising = self.groupActivity?.fundraising {
            let fundsDestination = fundraising.destination
            var fundsDestinationError: String? = nil
            if fundsDestination == nil {
                fundsDestinationError = "Please select funds destination"
                emptyFieldsCount += 1
            }
            let goalAmount = fundraising.goalAmount
            var goalAmountError: String? = nil
            if goalAmount == nil || goalAmount!.isNaN || goalAmount!.isZero || goalAmount!.isSignMinus {
                goalAmountError = "Please enter goal amount"
                emptyFieldsCount += 1
            }
            self.delegate?.showFundraisingValidationError(fundsDestinationError, goalAmountError)
        }
        
        if emptyFieldsCount >= 1 {
            return false
        }
        return true
    }
    
    //validate create challenge members and tem
    private func validateCreateChallengeMembers( emptyFieldsCount: inout Int) {
        if self.screenType! == .createChallenge, let type = self.groupActivity?.activityMembersType {
            if type == .individual {
                if User.sharedInstance.isCompanyAccount != 1 && (self.groupActivity?.members?.count == 0 || self.groupActivity?.members?.count == nil) {
                    emptyFieldsCount += 1
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.temates,message:AppMessages.GroupActivityMessages.emptyTemates)
                } else {
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.temates, message:"")
                }
            } else if type == .individualVsTem {
                if self.groupActivity?.selectedTem == nil {
                    emptyFieldsCount += 1
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.temates,message:AppMessages.GroupActivityMessages.emptyTem)
                } else {
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.temates,message:"")
                }
            } else {
                if self.groupActivity?.tem1 == nil && self.groupActivity?.tem2 == nil {
                    emptyFieldsCount += 1
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem1,message:AppMessages.GroupActivityMessages.emptyTem1)
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem2,message:AppMessages.GroupActivityMessages.emptyTem2)
                } else if self.groupActivity?.tem1 == nil {
                    emptyFieldsCount += 1
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem1,message:AppMessages.GroupActivityMessages.emptyTem1)
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem2,message:"")
                } else if self.groupActivity?.tem2 == nil {
                    emptyFieldsCount += 1
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem2,message:AppMessages.GroupActivityMessages.emptyTem2)
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem1,message:"")
                } else if self.groupActivity?.tem1?.id == self.groupActivity?.tem2?.id {
                    emptyFieldsCount += 1
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem2,message:AppMessages.GroupActivityMessages.differentTems)
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem1,message:"")
                } else {
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem1,message:"")
                    self.delegate?.reloadParentTableWithErrorMessage(atSection: CreateGoalChallengeSection.tem2,message:"")
                }
            }
        }
    }
    
    /// updating the activity object with the new value
    func updateCurrentGroupActivity(isAllSelected:Bool = false,withValue value: Any?, currentSection: CreateGoalChallengeSection,target: [GoalTarget]? = nil) {
        guard let value = value else { return }
        switch currentSection {
        case .name:
            self.groupActivity?.name = "\(value)"
            self.delegate?.updateFieldsValue(atSection: currentSection, value: self.groupActivity?.name ?? "")
        case .description:
            self.groupActivity?.description = "\(value)"
            self.delegate?.updateFieldsValue(atSection: currentSection, value: self.groupActivity?.description ?? "")
        case .metrics:
            if let screenType = self.screenType {
                switch screenType {
                case .createChallenge:
                    if self.groupActivity?.selectedMetrics == nil {
                        self.groupActivity?.selectedMetrics = []
                    }
                    if isAllSelected {
                        if let metricsValue = value as? Metrics {
                            if let selectedMetrics = self.groupActivity?.selectedMetrics {
                                if selectedMetrics.contains(metricsValue.rawValue),
                                   let index = selectedMetrics.firstIndex(of: metricsValue.rawValue) { // if the metrics already contain the value, remove that from the array else insert
                                    //self.groupActivity?.selectedMetrics?.remove(at: index)
                                }
                                else {
                                    self.groupActivity?.selectedMetrics?.append(metricsValue.rawValue)
                                }
                            }
                        }
                    } else {
                        
                        if let metricsValue = value as? Metrics {
                            if let selectedMetrics = self.groupActivity?.selectedMetrics {
                                if selectedMetrics.count == 4 {
                                    self.groupActivity?.selectedMetrics?.removeAll()
                                    self.groupActivity?.selectedMetrics?.append(metricsValue.rawValue)
                                    return
                                }
                                
                                if selectedMetrics.contains(metricsValue.rawValue),
                                   let index = selectedMetrics.firstIndex(of: metricsValue.rawValue) { // if the metrics already contain the value, remove that from the array else insert
                                    self.groupActivity?.selectedMetrics?.remove(at: index)
                                }
                                
                                else {
                                    self.groupActivity?.selectedMetrics?.append(metricsValue.rawValue)
                                }
                            }
                            // self.delegate?.updateParentMetricsView(forSelectedMetric: metricsValue)
                        }
                    }
                case .createGoal:
                    self.groupActivity?.selectedMetrics = []
                    if let metricsValue = value as? Metrics {
                        self.groupActivity?.selectedMetrics?.append(metricsValue.rawValue)
                        if let goalTarget = target {
                            self.groupActivity?.target = goalTarget
                        }
                    }
                default:
                    break
                }
            }
        case .startDate:
            self.groupActivity?.startDateToDisplay = "\(value)"
            if let strValue = value as? String {
                let timestamp = strValue.convertToDate(inFormat: .displayDate).timestampInMilliseconds
                self.groupActivity?.startDate = timestamp
            }
            self.delegate?.updateFieldsValue(atSection: currentSection, value: self.groupActivity?.startDateToDisplay ?? "")
        case .activitySelectionType:
            if let value = value as? Bool{// New
                if value == true {
                    self.groupActivity?.anyActivity = true
                    self.groupActivity?.activityTypes?.removeAll()
                    self.delegate?.updateFieldsValue(atSection: currentSection, value: "Any activity")
                } else {
                    self.groupActivity?.anyActivity = false
                    self.delegate?.updateFieldsValue(atSection: currentSection, value: "Custom")
                }
                
            }
            if let index = value as? Int {// Old
                let selection = ActivitySelectionType.allCases[index]
                if selection == .any {
                    self.groupActivity?.anyActivity = true
                    self.groupActivity?.activityTypes?.removeAll()
                } else if selection == .custom {
                    self.groupActivity?.anyActivity = false
                }
                self.delegate?.updateFieldsValue(atSection: currentSection, value: selection.title)
            }
        case .activity:
            if let indexes = value as? [Int], let activities = self.groupActivity?.activities {
                let selectedActivities = indexes.map { index in activities[index] }
                let activities = selectedActivities.map({ activity in ActivityType(activity) })
                self.groupActivity?.activityTypes = activities
                let str = activities.map { activityType in activityType.activityName ?? "" }.joined(separator: ", ")
                self.delegate?.updateFieldsValue(atSection: currentSection, value: str)
            }
        case .duration:
            self.groupActivity?.duration = "\(value)"
            self.delegate?.updateFieldsValue(atSection: currentSection, value: groupActivity?.duration ?? "")
            if let index = value as? Int {
                let duration = self.groupActivity?.durationList[index] ?? ""
                self.groupActivity?.duration = duration
                self.delegate?.updateFieldsValue(atSection: currentSection, value: duration)
            }
        case .temates:
            if let value = value as? [Friends] {
                self.groupActivity?.members?.removeAll()
                let newValue = self.setInvitedMembers(members: value)
                self.delegate?.updateFieldsValue(atSection: currentSection, value: newValue)
            }
            if let groupInfo = value as? ChatRoom {
                if let members = groupInfo.members {
                    self.groupActivity?.members?.removeAll()
                    _ = self.setInvitedMembers(members: members, groupInfo: groupInfo)
                    self.delegate?.updateFieldsValue(atSection: currentSection, value: groupInfo.name ?? "")
                } else {
                    self.delegate?.updateFieldsValue(atSection: currentSection, value: groupInfo.name ?? "")
                }
            }
            if let info = value as? [String: Any] {
                self.setGroupAndMembersOnView(info: info, currentSection: currentSection)
            }
        case .doNotParticipate:
            if let value = value as? Bool {
                self.groupActivity?.doNotParticipate = value
            }
        case .publicGoal:
            if let value = value as? Bool {
                self.groupActivity?.isPublic = value
            }
        case .openToPublic:
            if let value = value as? Bool {
                self.groupActivity?.openToPublic = value
            }
        case .challengeType:
            if let value = value as? ActivityMembersType {
                self.groupActivity?.activityMembersType = value
            }
        case .tem1:
            if let value = value as? GroupActivityTem {
                self.groupActivity?.tem1 = value
                self.groupActivity?.tem1?.teamType = 1
                self.delegate?.updateFieldsValue(atSection: .tem1, value: "\(value.name ?? "")")
            }
            if let value = value as? String {
                //this would be the case when the tem name is edited by the user
                self.groupActivity?.tem1?.name = value
                self.delegate?.updateFieldsValue(atSection: .tem1, value: value)
            }
        case .tem2:
            if let value = value as? GroupActivityTem {
                self.groupActivity?.tem2 = value
                self.groupActivity?.tem2?.teamType = 2
                self.delegate?.updateFieldsValue(atSection: .tem2, value: "\(value.name ?? "")")
            }
            if let value = value as? String {
                //this would be the case when the tem name is edited by the user
                self.groupActivity?.tem2?.name = value
                self.delegate?.updateFieldsValue(atSection: .tem2, value: value)
            }
        case .enableFundraising:
            if let value = value as? Bool {
                if value {
                    self.groupActivity?.fundraising = GNCFundraising()
                }
                else {
                    self.groupActivity?.fundraising = nil
                }
            }
        case .fundraisingInfo:
            break
        case .isPerPerson:
            if let value = value as? Bool {
                self.groupActivity?.isPerPersonGoal = value
            }
        }
    }
    
    private func setGroupAndMembersOnView(info: [String: Any], currentSection: CreateGoalChallengeSection) {
        var fieldData = ""
        var groupData: ChatRoom?
        var membersData: [Friends]?
        if let groupInfo = info["group"] as? ChatRoom {
            groupData = groupInfo
            let name = groupInfo.name ?? ""
            fieldData = name
            self.groupActivity?.selectedTem = groupInfo.toGroupActivityType()
            if let members = groupInfo.members {
                self.groupActivity?.members?.removeAll(where: {$0.groupId != nil})
                _ = self.setInvitedMembers(members: members, groupInfo: groupInfo)
            }
        } else {
            self.groupActivity?.selectedTem = nil
            //remove all members from the group with the member type equals to group type
            self.groupActivity?.members?.removeAll(where: { (member) -> Bool in
                if let type = member.type {
                    return type == .tem
                }
                return false
            })
        }
        if let members = info["members"] as? [Friends],
           members.count > 0 {
            membersData = members.count > 0 ? members : nil
            self.groupActivity?.members?.removeAll(where: { (member) -> Bool in
                if let type = member.type {
                    return type == .temate
                }
                return false
            })
            let newValue = self.setInvitedMembers(members: members)
            fieldData = newValue
        }
        if groupData != nil && membersData != nil {
            let fieldData = (groupData?.name ?? "") + " and " + "\(membersData?.count ?? 0) temates"
            self.delegate?.updateFieldsValue(atSection: currentSection, value: fieldData)
        } else {
            self.delegate?.updateFieldsValue(atSection: currentSection, value: fieldData)
        }
    }
    
    func updateMembersFormatted(info: [String: Any], currentSection: CreateGoalChallengeSection) {
        var fieldData = ""
        var groupData: ChatRoom?
        var membersData: [Friends]?
        if let groupInfo = info["group"] as? ChatRoom {
            groupData = groupInfo
            let name = groupInfo.name ?? ""
            fieldData = name
        }
        if let members = info["members"] as? [Friends] {
            membersData = members.count > 0 ? members : nil
            if members.count > 0 {
                fieldData = "\(members.count) temates"
            }
        }
        if groupData != nil && membersData != nil {
            let fieldData = (groupData?.name ?? "") + " and " + "\(membersData?.count ?? 0) temates"
            self.delegate?.updateFieldsValue(atSection: currentSection, value: fieldData)
        } else {
            self.delegate?.updateFieldsValue(atSection: currentSection, value: fieldData)
        }
    }
    
    func resetActivityInfo(currentSection: CreateGoalChallengeSection) {
        switch currentSection {
        case .temates:
            self.groupActivity?.members?.removeAll()
            self.groupActivity?.selectedTem = nil
            self.delegate?.updateFieldsValue(atSection: currentSection, value: "")
        case .tem2:
            self.groupActivity?.tem2 = nil
            self.delegate?.updateFieldsValue(atSection: currentSection, value: "")
        case .tem1:
            self.groupActivity?.tem1 = nil
            self.delegate?.updateFieldsValue(atSection: currentSection, value: "")
        default:
            break
        }
    }
    
    func numberOfSections() -> Int {
        return CreateGoalChallengeSection.allCases.count
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        let currentSection = CreateGoalChallengeSection.allCases[section]
        if let screenType = self.screenType {
            switch currentSection {
            case .publicGoal:
                return screenType == .createGoal ? 1 : 0
            case .challengeType:
                return screenType == .createChallenge ? 1 : 0
            case .temates:
                if let activityMembersType = self.groupActivity?.activityMembersType,
                   activityMembersType == .temVsTem {
                    return 0
                }
                return 1
            case .doNotParticipate:
                if let isCompanyAccount = User.sharedInstance.isCompanyAccount {
                    if isCompanyAccount == 1 {
                        return 1
                    }
                    return 0
                }
                return 0
            case .openToPublic:
                if screenType == .createChallenge {
                    if let activityMembersType = self.groupActivity?.activityMembersType {
                        if activityMembersType == .individual {
                            return 1
                        }
                        return 0
                    }
                    return 1
                } else {
                    //goal
                    return 1
                }
            case .tem1, .tem2:
                if let activityMembersType = self.groupActivity?.activityMembersType,
                   activityMembersType == .temVsTem {
                    return 1
                }
                return 0
            case .enableFundraising:
                return 1
            case .fundraisingInfo:
                if self.groupActivity?.fundraising == nil {
                    return 0
                } else {
                    return 1
                }
            case .name:
                return 1
            case .description:
                return 1
            case .startDate:
                return 1
            case .duration:
                return 1
            case .activitySelectionType:
                return 1
            case .activity:
                if let anyActivity = groupActivity?.anyActivity {
                    return anyActivity ? 0 : 1
                } else {
                    return 0
                }
            case .metrics:
                return 1
            case .isPerPerson:
                if screenType == .createGoal || screenType == .editGoal {
                    return 1
                } else {
                    return 0
                }
            }
        }
        return 0
    }
    
    func viewModelForMetricsSelectionCell(atIndexPath indexPath: IndexPath) -> SelectMetricCellViewModel? {
        if let screenType = self.screenType {
            return SelectMetricCellViewModel(type: screenType)
        }
        return nil
    }
    
    func getChallengeType() -> ActivityMembersType? {
        return self.groupActivity?.activityMembersType
    }
    
    func getCurrentInfo() -> GroupActivity? {
        return self.groupActivity
    }
    
    func getUpdatedGoalTarget() -> [GoalTarget]? {
        return self.groupActivity?.target
    }
    
    func getFieldsArrayForController() -> [InputFieldTableCellViewModel] {
        var array:[InputFieldTableCellViewModel] = [InputFieldTableCellViewModel]()
        array.append(InputFieldTableCellViewModel(title: "", inputIconImage: UIImage(named: "challengesWhite") ?? #imageLiteral(resourceName: "avatar-g"), value: nil, errorMessage: "", isHighlighted: false, toggleState:false))
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.name, inputIconImage: UIImage(named: "challengesWhite") ?? #imageLiteral(resourceName: "avatar-g"), value: self.groupActivity?.name, errorMessage: "", isHighlighted: false, toggleState:false))
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.description, inputIconImage: #imageLiteral(resourceName: "TaskStroke"), value: self.groupActivity?.description, errorMessage: "", isHighlighted: false, toggleState:false))
        
        let displayDate = groupActivity?.startDate?.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? ""
        self.groupActivity?.startDateToDisplay = displayDate
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.startDate, inputIconImage: #imageLiteral(resourceName: "small-calendar"), value: displayDate, errorMessage: "", isHighlighted: false, toggleState:false))
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.duration, inputIconImage: #imageLiteral(resourceName: "act-clock"), value: self.groupActivity?.duration, errorMessage: "", isHighlighted: false, toggleState:false))
        
        let activitySelection: ActivitySelectionType?
        if let anyActivity = self.groupActivity?.anyActivity {
            activitySelection = anyActivity ? .any : .custom
        } else {
            activitySelection = nil
        }
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.activitySelection, inputIconImage: #imageLiteral(resourceName: "achievement"), value: activitySelection?.title, errorMessage: "", isHighlighted: false, toggleState:false))
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.activities, inputIconImage: #imageLiteral(resourceName: "act"), value: groupActivity?.activityTypes?.map({ activityType in activityType.activityName ?? "" }).joined(separator: ", "), errorMessage: "", isHighlighted: false, toggleState:false))
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.temates, inputIconImage: UIImage(named: "temsWhite")!, value: nil, errorMessage: "", isHighlighted: false, toggleState:false))
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.tem1, inputIconImage: UIImage(named: "temsWhite")!, value: self.groupActivity?.tem1?.name, errorMessage: "", isHighlighted: false, rightIconImage: UIImage(named: "edit"), toggleState:false))
        
        array.append(InputFieldTableCellViewModel(title: Constant.ActivityConstants.tem2, inputIconImage: UIImage(named: "temsWhite")!, value: self.groupActivity?.tem2?.name, errorMessage: "", isHighlighted: false, rightIconImage: UIImage(named: "edit"), toggleState:false))
        
        return array
    }
    
}
