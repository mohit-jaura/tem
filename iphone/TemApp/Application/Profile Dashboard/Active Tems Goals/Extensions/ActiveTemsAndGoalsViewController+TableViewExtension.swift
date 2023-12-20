//
//  ActiveTemsAndGoalsViewController+TableViewExtension.swift
//  TemApp
//
//  Created by Mohit Soni on 05/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

extension ActiveTemsAndGoalsViewController: UITableViewDelegate, UITableViewDataSource {
    func reloadTableView() {
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch screenSelection {
            case .tems:
                return viewModal?.temsModal?.count ?? 0
            case .goals:
                return viewModal?.goalsModal?.count ?? 0
            case .challengs:
                return viewModal?.challengesModal?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch screenSelection {
            case .tems:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reuseIdentifier, for: indexPath) as? ChatListTableViewCell else {
                    return UITableViewCell()
                }
                if let chatInfo = self.viewModal?.temsModal?[indexPath.row] {
                    cell.setData(chatInfo: chatInfo, atIndexPath: indexPath)
                    cell.joinHandler = { [weak self] in
                        self?.getDataFromAPI()
                    }
                    cell.setActiveTemsUI()
                }
                return cell
            case .goals:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OpenGoalDashboardCell.reuseIdentifier, for: indexPath) as? OpenGoalDashboardCell else {
                    return UITableViewCell()
                }
                if let data = self.viewModal?.goalsModal?[indexPath.row] {
                    cell.initialize(activity: data, indexPath: indexPath,showBottomSeparator: false)
                    cell.joinHandler = { [weak self] in
                        self?.getDataFromAPI()
                    }
                    cell.setCardUI(backGround: UIColor.newAppThemeColor, hideJoinButton: true)
                }
                return cell
            case .challengs:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OpenChallengeDashboardCell.reuseIdentifier, for: indexPath) as? OpenChallengeDashboardCell else {
                    return UITableViewCell()
                }
                if let data = self.viewModal?.challengesModal?[indexPath.row] {
                    cell.initialize(activity: data, indexPath: indexPath,showBottomSeparator: false)
                    cell.joinHandler = { [weak self] in
                        self?.getDataFromAPI()
                    }
                    cell.setCardUI(backGround: UIColor.newAppThemeColor, hideJoinButton: true)
                }
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch screenSelection {
        case .tems:
            break
        case .goals:
            if let goal = self.viewModal?.goalsModal?[indexPath.row] {
                let controller: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                controller.goalId = goal.id
                self.navigationController?.pushViewController(controller, animated: true)
            }
        case .challengs:
            if let challenge = self.viewModal?.challengesModal?[indexPath.row] {
                let controller: ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                controller.challengeId = challenge.id
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
     
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var modal: [Any]?
        switch screenSelection{
            case .tems:
                modal = viewModal?.temsModal
            case .goals:
                modal = viewModal?.goalsModal
            case .challengs:
                modal = viewModal?.challengesModal
        }
        guard let modal = modal else {
            return
        }
        if !modal.isEmpty {
            if modal.count < viewModal?.totalCount ?? 0 && indexPath.row == (modal.count - 1) {
                self.viewModal?.updateCurrentPage()
                self.getDataFromAPI()
            }
        }
    }
}
