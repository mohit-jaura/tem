//
//  RightSideMenuViewPresenter.swift
//  TemApp
//
//  Created by shilpa on 20/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

protocol RightSideMenuViewDelegate: AnyObject {
    func showErrorAlertOnView(errorMessage: String)
    func showEmptyBackgroundViewWith(message: String)
    func showLoader(shouldVisible: Bool)
    func setPageLimitForView(limit: Int)
    func reloadViewAfterDataSet(isDataEmpty: Bool)
    func updatePageNumber()
    func reloadParentTableRow(atIndex index: Int)
}

class RightSideMenuViewPresenter {
    
    weak var delegate: RightSideMenuViewDelegate?
    var screenType: Constant.ScreenFrom?
    let networkLayer = DIWebLayerActivityAPI()
    //ProfileFilter.editProfile.title,
//    ProfileFilter.linkDevices.title,
    let profileHeadings = [ProfileFilter.interest.title,ProfileFilter.logout.title]
    
    //data for challenges or goals
    var dataArray: [GroupActivity]?
    var groupId: String?
    
    /// initializer for presenter. pass in the screen type
    init(forScreenType type: Constant.ScreenFrom, currentView: RightSideMenuViewDelegate, groupId: String? = nil) {
        self.screenType = type
        self.groupId = groupId
        self.delegate = currentView
    }
    
    // MARK: Server call
    func getData(forPage page: Int) {
        if let screenType = self.screenType {
            switch screenType {
            case .all(let type):
                self.getGoalsChallengesServerCall(forType: type!, page: page)
            case .challenge(let type):
                if let type = type {
                    self.getChallengesServerCall(forType: type, page: page)
                }
            case .goal(let type):
                if let type = type {
                    self.getGoalsServerCall(forType: type, page: page)
                }
            default:
                break
            }
        }
    }
    
    /// get challenges method pointing to api call
    ///
    /// - Parameters:
    ///   - type: 1 for open, 2 for completed, 3 for upcoming
    ///   - page: page number
    private func getChallengesServerCall(forType type: Constant.UserActivityType, page: Int) {
        guard Reachability.isConnectedToNetwork() else {
            self.displayMessage(message: AppMessages.AlertTitles.noInternet)
            return
        }
        self.networkLayer.getChallenges(forType: type, groupId: self.groupId, page: page, completion: {[weak self] (challenges, pageLimit, pendingItemCount) in
            if let wkSelf = self {
                wkSelf.setDataSource(withData: challenges, pageLimit: pageLimit, currentPage: page)
            }
        }) { (error) in
            if let error = error.message {
                self.displayMessage(message: error)
            }
        }
    }
    
    /// get goals method pointing to api call
    ///
    /// - Parameters:
    ///   - type: 1 for open, 2 for completed, 3 for upcoming
    ///   - page: page number
    private func getGoalsServerCall(forType type: Constant.UserActivityType, page: Int) {
        guard Reachability.isConnectedToNetwork() else {
            self.displayMessage(message: AppMessages.AlertTitles.noInternet)
            return
        }
        DIWebLayerGoals().getGoals(forType: type, page: page, completion: {[weak self] (goals, pageLimit,pendingItemCount) in
            if let wkSelf = self {
                wkSelf.setDataSource(withData: goals, pageLimit: pageLimit, currentPage: page)
            }
        }) { (error) in
            if let error = error.message {
                self.displayMessage(message: error)
            }
        }
    }
    /// get goals/challenges method pointing to api call
    ///
    /// - Parameters:
    ///   - type: 1 for open, 2 for completed, 3 for upcoming
    ///   - page: page number
    private func getGoalsChallengesServerCall(forType type: Constant.UserActivityType, page: Int) {
        guard Reachability.isConnectedToNetwork() else {
            self.displayMessage(message: AppMessages.AlertTitles.noInternet)
            return
        }
        DIWebLayerGoals().getGoalsandChallenges(forType: type, page: page, completion: {[weak self] (goals, pageLimit, pendingItemCount) in
            if let wkSelf = self {
                wkSelf.setDataSource(withData: goals, pageLimit: pageLimit, currentPage: page)
            }
        }) { (error) in
            if let error = error.message {
                self.displayMessage(message: error)
            }
        }
    }
    
    
    func joinActivity(index: Int) {
        guard Reachability.isConnectedToNetwork() else {
            self.delegate?.showErrorAlertOnView(errorMessage: AppMessages.AlertTitles.noInternet)
            return
        }
        if let dataArray = self.dataArray,
            let id = dataArray[index].id {
            let params = JoinActivityApiKey().toDict()
            self.dataArray?[index].isActivityJoined = true
            self.delegate?.reloadParentTableRow(atIndex: index)
            self.networkLayer.joinActivity(id: id, parameters: params, completion: {[weak self] (success) in
                NotificationCenter.default.post(name: Notification.Name.activityJoined, object: nil, userInfo: ["id": id])
                if let wkSelf = self {
                    if wkSelf.dataArray != nil {
                        wkSelf.dataArray?[index].isActivityJoined = true
                        if let count = wkSelf.dataArray?[index].membersCount {
                            wkSelf.dataArray?[index].membersCount = count + 1
                        }
                    }
                    wkSelf.delegate?.reloadParentTableRow(atIndex: index)
                }
            }) {[weak self] (error) in
                self?.dataArray?[index].isActivityJoined = false
                self?.delegate?.reloadParentTableRow(atIndex: index)
                if let error = error.message {
                    self?.displayMessage(message: error)
                }
            }
        }
    }
    
    // MARK: Helpers
    //set data source
    private func setDataSource(withData data: [GroupActivity], pageLimit: Int?, currentPage: Int) {
        if let limit = pageLimit {
            self.delegate?.setPageLimitForView(limit: limit)
        }
        if self.dataArray == nil {
            self.dataArray = []
        }
        if currentPage == 1 {
            //remove all data from first page
            self.dataArray?.removeAll()
        }
        self.dataArray?.append(contentsOf: data)
        if data.count >= (pageLimit ?? 15) {
            //increment page number in controller if data count is equal to the pagination limit
            self.delegate?.updatePageNumber()
        }
        if let array = self.dataArray {
            if array.isEmpty,
                let screenMessage = self.emptyScreenMessage() {
                self.delegate?.showEmptyBackgroundViewWith(message: screenMessage)
            }
        }
        //calling this to update the data source in parent controller
        let isEmptyData = self.dataArray?.count == 0 ? true : false
        self.delegate?.reloadViewAfterDataSet(isDataEmpty: isEmptyData)
    }
    
    /// call this method to handle display of message on screen to user
    ///
    /// - Parameter message: message string to display
    private func displayMessage(message: String) {
        if self.dataArray == nil {
            self.delegate?.showEmptyBackgroundViewWith(message: message)
        } else if let array = dataArray,
            array.isEmpty {
            self.delegate?.showEmptyBackgroundViewWith(message: message)
        } else {
            self.delegate?.showErrorAlertOnView(errorMessage: message)
        }
    }
    
    /// returns the screen message to display for current screen type
    ///
    /// - Returns: the string decsription of the message
    private func emptyScreenMessage() -> String? {
        if let screenType = self.screenType {
            switch screenType {
            case .all(let type):
                guard let type = type else {
                    return nil
                }
                switch type {
                case .open:
                    return AppMessages.GroupActivityMessages.noOpenChallengesorgoal
                case .completed:
                    return AppMessages.GroupActivityMessages.noPastChallengesorgoal
                case .upcoming:
                    return AppMessages.GroupActivityMessages.noFutureChallengesorgoal
                }
            case .challenge(let type):
                guard let type = type else {
                    return nil
                }
                switch type {
                case .open:
                    return AppMessages.GroupActivityMessages.noOpenChallenges
                case .completed:
                    return AppMessages.GroupActivityMessages.noPastChallenges
                case .upcoming:
                    return AppMessages.GroupActivityMessages.noFutureChallenges
                }
            case .goal(let type):
                guard let type = type else {
                    return nil
                }
                switch type {
                case .open:
                    return AppMessages.GroupActivityMessages.noOpenGoals
                case .completed:
                    return AppMessages.GroupActivityMessages.noPastGoals
                case .upcoming:
                    return AppMessages.GroupActivityMessages.noFutureGoals
                }
            default:
                break
            }
        }
        return nil
    }
    
    /// returns the id of the group activity
    ///
    /// - Parameter index: index at which the id is to be returned
    /// - Returns: String value
    func getUniqueId(atIndex index: Int) -> String? {
        if let dataArray = self.dataArray {
            return dataArray[index].id
        }
        return nil
    }
    
    func setActivityLogo(atIndex index: Int, _ cell: ActivityInformationTableCell) {
        if let dataArray = self.dataArray {
            let item = dataArray[index]
            item.setActivityImage(cell.activityImageView)
        }
    }
    
    func setActivityLogo(atIndex index: Int, _ cell: GoalInfoSideMenuTableViewCell) {
        if let dataArray = self.dataArray {
            let item = dataArray[index]
            item.setActivityImage(cell.activityIconLabel)
        }
    }
    
    //Tableview data source
    func numberOfRowsInSection(section: Int) -> Int {
        if let screenType = self.screenType {
            switch screenType {
            case .all(_):
                return self.dataArray?.count ?? 0
            case .profileRightSideMenu:
                return self.profileHeadings.count - 1
            case .challenge(_):
                return self.dataArray?.count ?? 0
            case .goal(_):
                return self.dataArray?.count ?? 0
            default:
                break
            }
        }
        return 0
    }
    
    //view models for display views
    func viewModelForProfileView(atIndexPath indexPath: IndexPath) -> ChallengeDashboardTableCellViewModel {
        return ChallengeDashboardTableCellViewModel(headingText: self.profileHeadings[indexPath.row])
    }
    
    func viewModelForChallengesView(atIndexPath indexPath: IndexPath) -> GroupActivity? {
        if let dataArray = self.dataArray {
            return dataArray[indexPath.row]
        }
        return nil
    }
    
    func viewModelForActivityType(atIndexPath indexPath: IndexPath) -> GroupActivityType? {
        if let dataArray = self.dataArray {
            return dataArray[indexPath.row].type
        }
        return nil
    }

}//Class...

