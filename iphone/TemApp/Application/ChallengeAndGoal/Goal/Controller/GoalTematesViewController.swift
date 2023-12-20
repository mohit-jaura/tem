//
//  GoalTematesViewController.swift
//  TemApp
//
//  Created by shilpa on 13/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

var refreshGoalData = "refreshGoalData"

enum GoalTematesSection: Int, CaseIterable {
    case info, temates
}

class GoalTematesViewController: DIBaseController {
    var refresh: RefreshGNCEventDelegate?
    var goalId: String?
    var goal: GroupActivity?

    weak var goalDetailPageDelegate: GoalDetailPageControllerDelegate?
    private var refreshControl: UIRefreshControl?
    private var refreshScreen: Bool = false
        
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotificationObservers()
        NotificationCenter.default.addObserver(self,selector: #selector(onPullToRefresh(sender:)),name: NSNotification.Name(rawValue:refreshGoalData),object: nil)
        tableView.delegate = self
        tableView.dataSource = self
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        if self.refreshScreen {
            self.refreshScreen = false
        }
        self.tableView.reloadData()
        self.handleTick()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotificationObservers()
    }
    
    func initUI() {
        self.tableView.registerNibs(nibNames: [LeaderboardTableCell.reuseIdentifier])
        self.tableView.registerHeaderFooter(nibNames: [LeaderboardHeader.reuseIdentifier, BlankFooterView.reuseIdentifier])
        self.addPullToRefresh()
    }
    
    private func addPullToRefresh() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func onPullToRefresh(sender: UIRefreshControl) {
        self.refresh?.refresh()
    }
    
    private func addNotificationObservers() {
        self.removeNotificationObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(goalEdited), name: Notification.Name.goalEdited, object: nil)
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.goalEdited, object: nil)
    }
    
    @objc func goalEdited() {
        self.refreshScreen = true
    }
}

// MARK: UITableViewDataSource
extension GoalTematesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return GoalTematesSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentSection = GoalTematesSection(rawValue: section),
            let goal = self.goal else {
                return 0
        }
        switch currentSection {
        case .info:
            return 1
        case .temates:
            return goal.scoreboard?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentSection = GoalTematesSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        switch currentSection {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: GoalInfoTableViewCell.reuseIdentifier, for: indexPath) as! GoalInfoTableViewCell
            if let goal = self.goal {
                cell.initializeWith(goal: goal)
            }
            self.addShadowTo(view: cell.contentView, mainView: cell.infoView)
            return cell
        case .temates:
            let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableCell.reuseIdentifier, for: indexPath) as! LeaderboardTableCell
           cell.delegate = self
            if let goalInfo = self.goal,
                let scoreboard = goalInfo.scoreboard {
                cell.hideAnimation()
                cell.configureData(atIndexPath: indexPath, scoreboard: scoreboard[indexPath.row], activityInfo: goalInfo)
            }
            return cell
        }
    }
    
    private func addShadowTo(view: UIView,mainView: UIView,radius: CGFloat = 15.0) {
        mainView.borderColor = ViewDecorator.viewBorderColor
        mainView.borderWidth = ViewDecorator.viewBorderWidth
        mainView.cornerRadius = radius
        view.cornerRadius = radius
        view.layer.masksToBounds = true
        view.layer.shadowColor = ViewDecorator.viewShadowColor
        view.layer.shadowOpacity = ViewDecorator.viewShadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        view.layer.shadowRadius = radius
    }
}

// MARK: UITableViewDelegate
extension GoalTematesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSkeletonActive {
            cell.hideSkeleton()
        }
        if let cell = cell as? LeaderboardTableCell {
            if let goalInfo = self.goal,
                let scoreboard = goalInfo.scoreboard {
                if indexPath.row == scoreboard.count - 1 { //last row
                    cell.showBottomBorder(shouldVisible: false)
                } else {
                    cell.showBottomBorder(shouldVisible: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let currentSection = GoalTematesSection(rawValue: section) else {
            return CGFloat.leastNormalMagnitude
        }
        if currentSection == .temates,
            let scoreboard = self.goal?.scoreboard,
            !scoreboard.isEmpty {
            return UITableView.automaticDimension
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let currentSection = GoalTematesSection(rawValue: section) {
            switch currentSection {
            case .temates:
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeaderboardHeader.reuseIdentifier) as! LeaderboardHeader
                headerView.setHeader(text: "Tēmates".localized)
                if let goalTarget = self.goal?.target {
                    headerView.initializeViewForGoal(target: goalTarget)
                }
                headerView.infoView.borderColor = .gray
                headerView.infoView.borderWidth = 1.0
                return headerView
            default:
                return nil
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let currentSection = GoalTematesSection(rawValue: section) {
            switch currentSection {
            case .temates:
                guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BlankFooterView.reuseIdentifier) as? BlankFooterView else {
                    return nil
                }
                footerView.mainView.borderColor = ViewDecorator.viewBorderColor
                return footerView
            default:
                return nil
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let currentSection = GoalTematesSection(rawValue: section) {
            switch currentSection {
            case .temates:
                return 20
            default:
                return CGFloat.leastNormalMagnitude
            }
        }
        return CGFloat.leastNormalMagnitude
    }
}

extension GoalTematesViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            self.tableView.tableFooterView = Utility.getPagingSpinner()
            self.refresh?.nextPage()
        }
    }
}

extension GoalTematesViewController: LeaderboardTableCellDelegate {
    func didTapOnArrowButton(sender: UIButton, totalOpenedMetricViws: Int) {}
    func didTapOnUserInformation(atRow row: Int, section: Int) {
        if let scoreboard = self.goal?.scoreboard,
            row < scoreboard.count {
            let profileDashboardVC: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
            if let userId = scoreboard[row].leaderboardMember?.id {
                if let currentUserId = UserManager.getCurrentUser()?.id,
                    currentUserId != userId {
                    //view my own profile
                    profileDashboardVC.otherUserId = userId
                }
            }
            self.navigationController?.pushViewController(profileDashboardVC, animated: true)
        }
    }
}

extension GoalTematesViewController : UpdateGNCEventInfoProtocol {
    func use(_ event: GroupActivity) {
        self.goal = event
        self.refreshControl?.endRefreshing()
        self.tableView.tableFooterView = self.tableView.emptyFooterView()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension GoalTematesViewController : UpdateByTimerProtocol {
    func handleTick() {
        guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else {
            return
        }
        for indexPath in visibleRowsIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? GoalInfoTableViewCell {
                if let goal = self.goal {
                    cell.updateTimeFor(goal: goal)
                }
            }
        }
    }
}
