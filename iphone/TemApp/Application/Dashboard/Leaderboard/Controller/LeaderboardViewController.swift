//
//  LeaderboardViewController.swift
//  TemApp
//
//  Created by shilpa on 07/11/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

enum LeaderboardSection: Int, CaseIterable {
    case leaderInformation = 0
    case scoreWithRanks = 1
}

protocol HomeLeaderboardViewDelegate: AnyObject {
    func updateNewMembersInLeaderboard(leaderboard: MyLeaderboard?)
}

class LeaderboardViewController: DIBaseController {

    // MARK: Properties
    weak var delegate: HomeLeaderboardViewDelegate?
    //private var leaderboardList: [Friends]?
    private var myLeaderboard: MyLeaderboard?
    private var searchHeaderView: ChatSearchHeaderTableCell?
    private var selectedFriends: [Friends]?
    private var previousPage:Int = 1
    private var currentPage:Int = 1
    private var searchText: String?
    private var refreshControl: UIRefreshControl?
    private let ranksHeaderHeight: CGFloat = 50
    
    // MARK: IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:  View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.setDefaultNavigationBar()
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        self.navigationController?.popViewController(animated: true)
        }
    // MARK: View Setup
    private func configureNavigation() {
        self.navigationController?.navigationBar.isHidden = false
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: "LEADERBOARD".localized, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
    }
    
    private func initializeUI() {
       // self.configureNavigation()
        if let searchHeaderView = ChatSearchHeaderTableCell.loadNib() as? ChatSearchHeaderTableCell {
            self.searchHeaderView = searchHeaderView
            searchHeaderView.frame = self.headerView.frame
            searchHeaderView.borderColor = .clear
            searchHeaderView.initUIForLeaderBoard()
            searchHeaderView.clipsToBounds = true
            searchHeaderView.delegate = self
            self.headerView.addSubview(searchHeaderView)
        }
        if let searchView = searchHeaderView {
            self.addShadowTo(view: headerView, borderView: searchView, radius: 10.0)
        }
        self.headerView.isHidden = true
        self.tableView.estimatedRowHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 140.0
        self.tableView.registerNibs(nibNames: [ LeaderboardTableCell.reuseIdentifier])
//        self.tableView.registerHeaderFooter(nibNames: [LeaderboardHeader.reuseIdentifier, BlankFooterView.reuseIdentifier])
        
        self.addRefreshControl()
        //self.tableView.startSkeletonAnimation()
        self.tableView.showAnimatedSkeleton()
        self.getLeaderboardInfo(searchText: searchText)
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(refreshControl:)) , for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    // MARK: Api Calls
    private func getLeaderboardInfo(searchText: String?, updateHomeLeaderboard: Bool? = false) {
        guard Reachability.isConnectedToNetwork() else {
            self.searchHeaderView?.searchBar.isLoading = false
            self.showErrorOnView(message: AppMessages.AlertTitles.noInternet)
            return
        }
        DIWebLayerUserAPI().getLeaderboard(page: currentPage, searchString: searchText, completion: { (response) in
            self.hideLoader()
            self.myLeaderboard = response
            if updateHomeLeaderboard! {
                self.delegate?.updateNewMembersInLeaderboard(leaderboard: self.myLeaderboard)
            }
            self.reloadViewWithData()
        }) { (error) in
            self.searchHeaderView?.searchBar.isLoading = false
            self.showErrorOnView(message: error.message ?? "")
        }
    }
    
    private func addMembersToLeaderboard(memberIds: [String]) {
        if isConnectedToNetwork() {
            let params: Parameters = ["leaderBoardMembers": memberIds]
            DIWebLayerUserAPI().addMemberToLeaderboard(parameters: params, completion: { (_) in
                //refresh the screen
                self.getLeaderboardInfo(searchText: self.searchText, updateHomeLeaderboard: true)
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "Error")
            }
        } else {
            self.hideLoader()
        }
    }
    
    private func removeMemberFromLeaderboard(memberId: String) {
        if isConnectedToNetwork() {
            self.showLoader()
            let params: Parameters = ["leaderBoardMember": memberId]
            DIWebLayerUserAPI().removeMemberFromLeaderboard(parameters: params, completion: { (_) in
                //refresh the list
                self.getLeaderboardInfo(searchText: self.searchText, updateHomeLeaderboard: true)
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "Error")
            }
        }
    }
    
    // MARK: Helpers
    private func reloadViewWithData() {
        headerView.isHidden = false
        self.searchHeaderView?.searchBar.isLoading = false
        self.tableView.restore()
        self.tableView.hideSkeleton()
        
        if self.myLeaderboard?.leaderInformation?.user_id == nil && myLeaderboard?.myRank?.user_id == nil && myLeaderboard?.addedTemates?.count == 0 {
            self.tableView.showEmptyScreen("You have no tēmate added in leaderboard. Click on the add button on the right of search bar to add tēmates.")
        } else {
            self.tableView.restore()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // present the error message to user
    private func showErrorOnView(message: String) {
        self.tableView.hideSkeleton()
        if myLeaderboard == nil {
            self.headerView.isHidden = true
            self.tableView.showEmptyScreen(message, isWhiteBackground: false)
        } else {
            self.showAlert(message: message)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func searchBarTextDidChange(searchBar: UISearchBar) {
        self.getLeaderboardInfo(searchText: searchText)
    }
    
    @objc func onPullToRefresh(refreshControl: UIRefreshControl) {
        if Reachability.isConnectedToNetwork() {
            self.getLeaderboardInfo(searchText: searchText)
        } else {
            showErrorOnView(message: AppMessages.AlertTitles.noInternet)
        }
    }
    
    private func addShadowTo(view: UIView,borderView: UIView,radius: CGFloat = 10.0) {
        borderView.borderWidth = ViewDecorator.viewBorderWidth
//        borderView.borderColor = ViewDecorator.viewBorderColor
        borderView.cornerRadius = radius
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = ViewDecorator.viewShadowColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        view.layer.shadowRadius = 5.0
    }
}

// MARK: UITableViewDataSource
extension LeaderboardViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return LeaderboardSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = LeaderboardSection(rawValue: section) {
            switch currentSection {
            case .leaderInformation:
               print("")
            case .scoreWithRanks:
                return self.myLeaderboard?.addedTemates?.count ?? 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = LeaderboardSection(rawValue: indexPath.section) {
            switch currentSection {
            case .leaderInformation:
                print("")
            case .scoreWithRanks:
                if let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableCell.reuseIdentifier, for: indexPath) as? LeaderboardTableCell {
                    cell.delegate = self
                    if let list = myLeaderboard?.addedTemates {
                        cell.configureCellForHomeLeaderboard(atIndexPath: indexPath, user: list[indexPath.row])
                   }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension LeaderboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let list = myLeaderboard?.addedTemates {
            if let cell = cell as? LeaderboardTableCell {
                if indexPath.row == list.count - 1 { //last row
                   // cell.showBottomBorder(shouldVisible: false)
                } else {
                   // cell.showBottomBorder(shouldVisible: false)
                }
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if let currentSection = LeaderboardSection(rawValue: section) {
//            switch currentSection {
//            case .scoreWithRanks:
//                if let data = self.myLeaderboard?.addedTemates,
//                    !data.isEmpty {
//                    return self.ranksHeaderHeight
//                }
//            case .leaderInformation:
//                return CGFloat.leastNormalMagnitude
//            }
//        }
//        return CGFloat.leastNormalMagnitude
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if let currentSection = LeaderboardSection(rawValue: section) {
//            switch currentSection {
//            case .scoreWithRanks:
//                guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeaderboardHeader.reuseIdentifier) as? LeaderboardHeader else {
//                    return nil
//                }
//                headerView.initializeViewForUserCustomLeaderboard()
////                headerView.addBorder()
//                return headerView
//            case .leaderInformation:
//                return nil
//            }
//        }
//        return UIView()
//    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if let currentSection = LeaderboardSection(rawValue: section) {
//            switch currentSection {
//            case .scoreWithRanks:
//                guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BlankFooterView.reuseIdentifier) as? BlankFooterView else {
//                    return nil
//                }
//                footerView.mainView.borderColor = ViewDecorator.viewBorderColor
//                return footerView
//            default:
//                break
//            }
//        }
//        return nil
//    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if let currentSection = LeaderboardSection(rawValue: section) {
//            switch currentSection {
//            case .scoreWithRanks:
//                return 20//30
//            default:
//                return CGFloat.leastNormalMagnitude
//            }
//        }
//        return CGFloat.leastNormalMagnitude
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let currentSection = LeaderboardSection(rawValue: indexPath.section),
            currentSection == .scoreWithRanks,
            let members = myLeaderboard?.addedTemates,
            !members.isEmpty {
            if members[indexPath.row].user_id != UserManager.getCurrentUser()?.id {
                //if this the row for the current user then donot add the action
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            if let memberId = self.myLeaderboard?.addedTemates?[indexPath.row].user_id {
                self.showAlert(withTitle: "", message: AppMessages.Leaderboard.removeMember, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {[weak self] in
                    self?.removeMemberFromLeaderboard(memberId: memberId)
                }) {
                }
            }
        }
        delete.backgroundColor = UIColor.appRed
        return [delete]
    }
}

// MARK: SkeletonTableViewDataSource
extension LeaderboardViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return LeaderboardTableCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

// MARK: LeaderboardTableCellDelegate
extension LeaderboardViewController: LeaderboardTableCellDelegate {
    func didTapOnArrowButton(sender: UIButton, totalOpenedMetricViws: Int) {
        
    }
    
    func didTapOnUserInformation(atRow row: Int, section: Int) {
        if let user = self.myLeaderboard?.addedTemates?[row],
            let userId = user.user_id,
            let currentUserId = UserManager.getCurrentUser()?.id {
            let profileDashboardVC: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
            if currentUserId != userId {
                profileDashboardVC.otherUserId = userId
            }
            self.navigationController?.pushViewController(profileDashboardVC, animated: true)
        }
    }
}

// MARK: ChatSearchHeaderDelegate
extension LeaderboardViewController: ChatSearchHeaderDelegate {
    func didClickOnAddButton() {
        let inviteFrndVC:InviteFriendController = UIStoryboard(storyboard: .challenge).initVC()
        inviteFrndVC.delegate = self
        inviteFrndVC.status = 1
        navigationController?.pushViewController(inviteFrndVC, animated: true)
    }
    
    func didEnterTextInSearchBar(text: String) {
        if text.isEmpty || text.count >= 3 {
            self.searchText = text
            self.searchHeaderView?.searchBar.isLoading = true
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchBarTextDidChange(searchBar:)), object: nil)
            self.perform(#selector(searchBarTextDidChange(searchBar:)), with: nil, afterDelay: 0.5)
        }
    }
    
    func searchBarCleared() {
        self.searchText = nil
        self.searchHeaderView?.searchBar.isLoading = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchBarTextDidChange(searchBar:)), object: nil)
        self.getLeaderboardInfo(searchText: nil)
    }
    
    func didStartSearch() {}
    
    func didEndEditingSearchBar() {}
}

// MARK: InviteFriendControllerViewDelegate
extension LeaderboardViewController: InviteFriendControllerViewDelegate {
    func didSelectTemates(members: [Friends]) {
        self.selectedFriends = members
        // Add api to add to leaderboard
        self.showLoader(message: "Adding members")
        var memberIds: [String] = []
        for (_, member) in members.enumerated() {
            if let memberId = member.id {
                memberIds.append(memberId)
            }
        }
        self.addMembersToLeaderboard(memberIds: memberIds)
    }
}

// MARK: UIScrollViewDelegate
extension LeaderboardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let count = self.myLeaderboard?.addedTemates?.count,
            count > 0 else {
            return
        }
        for cell in tableView.visibleCells {
            if let leaderboardCell = cell as? LeaderboardTableCell {
                let hiddenFrameHeight = scrollView.contentOffset.y + self.ranksHeaderHeight - cell.frame.origin.y
                if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
//                    print("123 ----------")
                  //  leaderboardCell.maskCell(cell: cell, margin: Float(hiddenFrameHeight))
                }
            }
            
        }
    }
}
