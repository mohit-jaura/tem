//
//  ChallangeDashBoard+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 27/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

// MARK: UITableViewDelegate&UITableViewDataSource.
extension ChallangeDashBoardController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewState {
        case .isLoading(let hasLoaded):
            return hasLoaded ? self.dataArray?.count ?? 0 : 3
        case .showError(_):
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRowForOpenList(tableView, cellForRowAt: indexPath)
    }
    
    func cellForRowForOpenList(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState {
        case .isLoading(let hasLoaded):
            if !hasLoaded {
                return tableView.PlacholderCell()
            } else {
                switch selectedSection {
                case .all:
                    if let data = self.dataArray?[indexPath.row],data.type == .goal {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: OpenGoalDashboardCell.reuseIdentifier, for: indexPath) as? OpenGoalDashboardCell {
                            cell.setCardUI(backGround: UIColor.appThemeDarkGrayColor, hideJoinButton: false)
                            cell.contentView.backgroundColor = UIColor.appThemeDarkGrayColor
                            cell.initialize(activity: data, indexPath: indexPath,showBottomSeparator: false)
                            return cell
                        }
                    } else if let data = self.dataArray?[indexPath.row],data.type == .weightGoal  || data.type == .healthGoal{
                        if let cell = tableView.dequeueReusableCell(withIdentifier: WeightGoalInfoTableViewCell.reuseIdentifier, for: indexPath) as? WeightGoalInfoTableViewCell {
                            cell.setData(data: data)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: OpenChallengeDashboardCell.reuseIdentifier, for: indexPath) as? OpenChallengeDashboardCell {
                            if let data = self.dataArray?[indexPath.row] {
                                cell.setCardUI(backGround: UIColor.appThemeDarkGrayColor, hideJoinButton: false)
                                cell.contentView.backgroundColor = UIColor.appThemeDarkGrayColor
                                cell.initialize(activity: data, indexPath: indexPath,showBottomSeparator: false)
                            }
                            return cell
                        }
                    }
                case .challenge:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: OpenChallengeDashboardCell.reuseIdentifier, for: indexPath) as? OpenChallengeDashboardCell {
                        if let data = self.dataArray?[indexPath.row] {
                            cell.setCardUI(backGround: UIColor.appThemeDarkGrayColor, hideJoinButton: false)
                            cell.contentView.backgroundColor = UIColor.appThemeDarkGrayColor
                            cell.initialize(activity: data, indexPath: indexPath,showBottomSeparator: false)
                        }
                        return cell
                    }
                case .goal:
                        if let data = self.dataArray?[indexPath.row], data.type == .weightGoal || data.type == .healthGoal {
                            if let cell = tableView.dequeueReusableCell(withIdentifier: WeightGoalInfoTableViewCell.reuseIdentifier, for: indexPath) as? WeightGoalInfoTableViewCell {
                                cell.setData(data: data)
                                return cell
                            }
                        }
                    if let cell = tableView.dequeueReusableCell(withIdentifier: OpenGoalDashboardCell.reuseIdentifier, for: indexPath) as? OpenGoalDashboardCell {
                        if let data = self.dataArray?[indexPath.row] {
                            cell.setCardUI(backGround: UIColor.appThemeDarkGrayColor, hideJoinButton: false)
                            cell.contentView.backgroundColor = UIColor.appThemeDarkGrayColor
                            cell.initialize(activity: data, indexPath: indexPath,showBottomSeparator: false)
                        }
                        return cell
                    } 
                }
            }
        case .showError(let error):
            let cell = tableView.dequeueReusableCell(withIdentifier: DashboardErrorMessageTableViewCell.reuseIdentifier, for: indexPath) as! DashboardErrorMessageTableViewCell
            cell.showErrorWith(message: error)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArray?.count ?? 0 > 0{
            var selectedData:GroupActivity = GroupActivity()
            switch selectedSection {
            case .all:
                if let data = self.dataArray?[indexPath.row],data.type == .goal {
                    selectedData = data
                    let controller: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                    controller.goalId = selectedData.id
                    self.navigationController?.pushViewController(controller, animated: true)
                } else if let data = self.dataArray?[indexPath.row],data.type == .weightGoal || data.type == .healthGoal {
                    let selectedVC: WeightGoalDetailViewController = UIStoryboard(storyboard: .weightgoaltracker).initVC()
                    selectedVC.gncController = self
                    selectedVC.viewModal = WeightGoalDetailViewModal(id: data.id ?? "")
                    selectedVC.isHealthInfo = (data.healthInfoType ?? 0 != 0) ? true : false
                    self.navigationController?.pushViewController(selectedVC, animated: true)
                    return
                } else {
                    if let data = self.dataArray?[indexPath.row] {
                        selectedData = data
                        let controller: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                        controller.challengeId = selectedData.id
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            case .challenge:
                if let data = self.dataArray?[indexPath.row] {
                    selectedData = data
                    let controller: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                    controller.challengeId = selectedData.id
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            case .goal:
                if let data = self.dataArray?[indexPath.row],data.type == .weightGoal || data.type == .healthGoal{
                        let selectedVC: WeightGoalDetailViewController = UIStoryboard(storyboard: .weightgoaltracker).initVC()
                    selectedVC.gncController = self
                    selectedVC.isHealthInfo = (data.healthInfoType ?? 0 != 0) ? true : false
                    selectedVC.viewModal = WeightGoalDetailViewModal(id: data.id ?? "")
                        self.navigationController?.pushViewController(selectedVC, animated: true)
                    return
                    }
                if let data = self.dataArray?[indexPath.row] {
                    selectedData = data
                    let controller: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                    controller.goalId = selectedData.id
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

// MARK: SideMenuNavigationControllerDelegate
extension ChallangeDashBoardController : SideMenuNavigationControllerDelegate {
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        self.topView.isHidden = true
    }
}
