//
//  RightSideMenu+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

// MARK: UITableViewDelegate&UITableViewDataSource.
extension RightSideMenuController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRowsInSection(section: section)
    }
    
    private func showChallengeCell( _ indexPath: IndexPath) -> UITableViewCell {
        if let cell:ActivityInformationTableCell = tableView.dequeueReusableCell(withIdentifier: ActivityInformationTableCell.reuseIdentifier, for: indexPath) as? ActivityInformationTableCell {
            cell.delegate = self
            cell.isFromMenuScreen = true
            if let dataArray = self.presenter.viewModelForChallengesView(atIndexPath: indexPath) {
                cell.setChallengeInformation(activity: dataArray, indexPath: indexPath)
                cell.setMetricsInfo(forActivity: dataArray)
            }
            cell.setViewForSideMenu()
            return cell
        }
        return UITableViewCell()
    }
    
    private func showWeightGoalCell(_ indexPath: IndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueReusableCell(withIdentifier: WeightGoalInfoTableViewCell.reuseIdentifier, for: indexPath) as? WeightGoalInfoTableViewCell {
                if let dataArray = self.presenter.viewModelForChallengesView(atIndexPath: indexPath) {
                    cell.setData(data: dataArray)
                }
                return cell
            }
        return UITableViewCell()
    }
    private func showGoalCell(_ indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: GoalInfoSideMenuTableViewCell.reuseIdentifier, for: indexPath) as? GoalInfoSideMenuTableViewCell {
            if let dataArray = self.presenter.viewModelForChallengesView(atIndexPath: indexPath) {
                cell.setDataWith(goal: dataArray, indexPath: indexPath)
            }
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.screenType {
        case .profileRightSideMenu:
            guard let cell:ChallengeDashboardTableCell = tableView.dequeueReusableCell(withIdentifier: ChallengeDashboardTableCell.reuseIdentifier, for: indexPath) as? ChallengeDashboardTableCell else {
                return UITableViewCell()
            }
            let viewModel = self.presenter.viewModelForProfileView(atIndexPath: indexPath)
            cell.initializeWith(viewModel: viewModel)
            return cell
        case .challenge(_):
            return showChallengeCell( indexPath)
        case .goal(_):
                if let data = self.presenter.viewModelForChallengesView(atIndexPath: indexPath), data.type == .weightGoal {
                    return showWeightGoalCell(indexPath)
                } else {
                    return showGoalCell(indexPath)
                }
        case .all(_):
            if let type = self.presenter.viewModelForActivityType(atIndexPath: indexPath) {
                print(type)
                switch type {
                case .goal:
                    if let data = self.presenter.viewModelForChallengesView(atIndexPath: indexPath), data.type == .weightGoal {
                        return showWeightGoalCell(indexPath)
                    } else {
                        return showGoalCell(indexPath)
                    }
                case .challenge:
                    return showChallengeCell( indexPath)
                case .weightGoal:
                    return showWeightGoalCell(indexPath)
                case .healthGoal:
                    return showWeightGoalCell(indexPath)
                }
            }
            
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func pushTochallengeDetail(_ indexPath: IndexPath) {
        if let id = self.presenter.getUniqueId(atIndex: indexPath.row),
           isConnectedToNetwork() {
            let selectedVC:ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
            selectedVC.challengeId = id
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
    private func pushToWeightGoalDetail(_ indexPath: IndexPath) {
        if let id = self.presenter.getUniqueId(atIndex: indexPath.row),
           isConnectedToNetwork() {
            let selectedVC: WeightGoalDetailViewController = UIStoryboard(storyboard: .weightgoaltracker).initVC()
            selectedVC.viewModal = WeightGoalDetailViewModal(id: id)
            self.navigationController?.pushViewController(selectedVC, animated: true)
            return
        }
    }
    private func pushToGoalDetail(_ indexPath: IndexPath) {
        if let id = self.presenter.getUniqueId(atIndex: indexPath.row),
           self.isConnectedToNetwork() {
            let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
            goalDetailController.goalId = id
            goalDetailController.selectedGoalName = self.presenter.viewModelForChallengesView(atIndexPath: indexPath)?.name
            self.navigationController?.pushViewController(goalDetailController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.screenType {
        case .profileRightSideMenu:
            self.didSelectProfileSideMenuRowAt(indexPath: indexPath)
        case .all(_):
            if let type = self.presenter.viewModelForActivityType(atIndexPath: indexPath) {
                print(type)
                switch type {
                case .goal:
                    if let data = self.presenter.viewModelForChallengesView(atIndexPath: indexPath), data.type == .weightGoal {
                        pushToWeightGoalDetail(indexPath)
                    } else {
                        pushToGoalDetail(indexPath)
                    }
                case .challenge:
                    pushTochallengeDetail(indexPath)
                case .weightGoal:
                    pushToWeightGoalDetail(indexPath)
                case .healthGoal:
                    pushToWeightGoalDetail(indexPath)
                }
            }
        case .challenge(_):
            print("")
            pushTochallengeDetail(indexPath)
        case .goal(_):
            print("")
            if let data = self.presenter.viewModelForChallengesView(atIndexPath: indexPath), data.type == .weightGoal {
                pushToWeightGoalDetail(indexPath)
            } else {
                pushToGoalDetail(indexPath)
            }
        default:
            break
        }
    }
    
    private func didSelectProfileSideMenuRowAt(indexPath: IndexPath) {
        if let selectedRow = ProfileFilter(rawValue: indexPath.row) {
            switch selectedRow {
            case .interest:
                let selectInterestVC:SelectInterestViewController = UIStoryboard(storyboard: .main).initVC()
                selectInterestVC.isComingFromDashBoard = true
                self.navigationController?.pushViewController(selectInterestVC, animated: true)
                return
            case .logout :
                let alert = UIAlertController(title: "title", message: AppMessages.Login.logout, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Logout", style: .default , handler:{ (UIAlertAction) in
                    if self.isConnectedToNetwork() {
                        let postUploadInProgressKey = Constant.CoreData.PostEntityKeys.uploadingInProgress.rawValue
                        let predicate = NSPredicate(format: "\(postUploadInProgressKey) == %d",1)
                        let posts:[Postinfo] = CoreDataManager.shared.getEntityData(with: predicate, of: Constant.CoreData.postEntity) as! [Postinfo]
                        if posts.count > 0 {
                            self.showAlert(withTitle: "Just a moment", message: AppMessages.AlertTitles.cannotLogoutWhilePostUploading, okayTitle: AppMessages.AlertTitles.Ok, okCall: {
                            })
                            return
                        }
                        self.logout()
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: {
                })
            }
        }
    }
    
    //clear all user information and
    private func logoutUserAction() {
        // Delete from here and move it to deinit
        UserManager.logout()
        let loginVC:LoginViewController = UIStoryboard(storyboard: .main).initVC()
        appDelegate.setNavigationToRoot(viewContoller: loginVC)
    }
    
    //logout api call
    private func logout() {
        self.showLoader()
        DIWebLayerUserAPI().logout(success: { (_) in
            self.hideLoader()
            self.logoutUserAction()
        }) { (error) in
            self.hideLoader()
            self.showAlert(withTitle: "", message: error.message ?? "", okayTitle: AppMessages.AlertTitles.Ok, okCall: {
                
            })
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if screenType == .profileRightSideMenu {
            let headerView = Bundle.main.loadNibNamed("ProfileFilterHaeder", owner: self, options: nil)?.first as? ProfileFilterHaeder
            headerView?.nameLabel.text = "\(User.sharedInstance.firstName ?? "") \(User.sharedInstance.lastName ?? "")".trim
            return headerView
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if screenType == .profileRightSideMenu {
            return UITableView.automaticDimension
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSkeletonActive {
            cell.hideSkeleton()
        }
        if let cell = cell as? ActivityInformationTableCell {
            presenter.setActivityLogo(atIndex: indexPath.row, cell)
        }
        if let cell = cell as? GoalInfoSideMenuTableViewCell {
            presenter.setActivityLogo(atIndex: indexPath.row, cell)
        }
    }
}

// MARK: SkeletonCollectionDataSource
extension RightSideMenuController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return ActivityInformationTableCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}

//For Join Goal......
extension RightSideMenuController: JoinGoal {
    
    func loader(shouldShow: Bool) {
        if shouldShow {
            self.showLoader()
        } else {
            self.hideLoader()
        }
    }
    
    func showAlertMsg(message: String) {
        self.showAlert(withTitle: AppMessages.AlertTitles.Alert, message: message)
    }
    
}//Extension....
