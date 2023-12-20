//
//  RightSideMenuController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

enum ProfileFilter : Int , CaseIterable {
    case interest = 0
//    case editProfile = 0
//    case linkDevices = 1
    case logout
    
    var title:String {
        switch self {
        case .interest:
            return "Interests"
//        case .editProfile:
//            return "Edit Profile"
//        case .linkDevices:
//            return "Link apps and devices"
        case .logout:
            return "Logout"
        }
    }
}

class RightSideMenuController: DIBaseController {
    
    // MARK: Variables.
    var screenType: Constant.ScreenFrom = .profileRightSideMenu
    var presenter: RightSideMenuViewPresenter!
    var currentPage = 1
    var lastPage = 1
    var pageLimit = 0
//    ProfileFilter.editProfile.title,
//    ProfileFilter.linkDevices.title,
    var profileHeadings = [ProfileFilter.interest.title,ProfileFilter.logout.title]
    
    ///timer to show the remaining time for an activity
    var timer: Timer?
    var refreshControl: UIRefreshControl?
    var groupId: String? //this will hold the id of the group in case the data is to be viewed for the chat group
    
    // MARK: IBOutlets.
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: ViewLifeCycle
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = RightSideMenuViewPresenter(forScreenType: self.screenType, currentView: self, groupId: groupId)
        self.setTableview()
        self.getUserData()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cancelTimer()
    }

    // MARK: Custom Functions.
    // MARK: Function to set Tabbar, Navigationbar and controller properties.
    func initUI() {
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: false, controller: self)
        }
        self.tableView.backgroundColor = UIColor.appThemeDarkGrayColor
        self.view.backgroundColor = UIColor.appThemeDarkGrayColor
        self.configureNavigation()
    }
    
    // MARK: Set Navigation
    func configureNavigation() {
        if self.screenType == .profileRightSideMenu {
            self.navigationController?.navigationBar.isHidden = true
        }else{
            self.navigationController?.navigationBar.isHidden = false
        }
        var screenTitle = self.screenType.title
        if screenType == .goal(type: .upcoming) || screenType == .challenge(type: .upcoming) || screenType == .all(type: .upcoming) {
            screenTitle = ""
        } else if screenType == .goal(type: .completed) || screenType == .challenge(type: .completed) || screenType == .all(type: .completed) {
            screenTitle = ""
        }
        self.setNavigationController(titleName: screenTitle.uppercased(), leftBarButton: nil, rightBarButtom: nil, backGroundColor: UIColor.appThemeDarkGrayColor, translucent: true)
    }
    
    // MARK: Function to register tablecell xib and set initial view of tableview.
    func setTableview() {
//        let sectionToReload = 0
//        let indexSet: IndexSet = [sectionToReload]
//        UIView.performWithoutAnimation {
//             self.tableView.reloadSections(indexSet, with: .none)
//        }
//        self.tableView.reloadSections(indexSet, with: .none)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 120
        self.tableView.estimatedSectionHeaderHeight = 140.0
        self.tableView.registerNibs(nibNames: [WeightGoalInfoTableViewCell.reuseIdentifier, GoalInfoSideMenuTableViewCell.reuseIdentifier, ActivityInformationTableCell.reuseIdentifier])
        self.addPullToRefresh()
    }
    
    func getUserData() {
        guard screenType != .profileRightSideMenu else {
            return
        }
        self.tableView.isSkeletonable = true
        self.tableView.showAnimatedSkeleton()
        self.presenter.getData(forPage: self.currentPage)
    }
    
    // MARK: Helper functions
    /// method to initialize timer
    private func createTimer() {
        switch screenType {
        case .challenge(let type):
            //return from the function if this is the past challenge
            if let type = type,
                type == .completed {
                return
            }
        case .goal(let type), .all(let type):
            if let type = type, type == .completed {
                return
            }
        default:
            break
        }
        if timer == nil {
            print("timer created")
            let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.timer = timer
        }
    }

    /// invalidates the timer
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// called each time the timer is triggered
    @objc func tickTimer() {
        guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else {
            return
        }
        
        for indexPath in visibleRowsIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? ActivityInformationTableCell {
                if let model = self.presenter.viewModelForChallengesView(atIndexPath: indexPath) {
                    cell.updateRemainingTimeForActivity()
                }
            } else if let cell = tableView.cellForRow(at: indexPath) as? GoalInfoSideMenuTableViewCell {
                if let model = self.presenter.viewModelForChallengesView(atIndexPath: indexPath) {
                    cell.updateRemainingTimeForActivity()
                }
            }
        }
    }
    
    // helper function to add pull to refresh
    private func addPullToRefresh() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    // called when refresh control is pulled down
    @objc func onPullToRefresh(sender: UIRefreshControl) {
        self.currentPage = 1
        self.lastPage = 1
        self.presenter.getData(forPage: self.currentPage)
    }
    
    private func endPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl?.endRefreshing()
        }
    }
}

// MARK: RightSideMenuViewDelegate
extension RightSideMenuController: RightSideMenuViewDelegate {
    func reloadParentTableRow(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showEmptyBackgroundViewWith(message: String) {
        self.endPullToRefresh()
        self.tableView.hideSkeleton()
        self.tableView.showEmptyScreen(message)
    }
    
    func setPageLimitForView(limit: Int) {
        self.pageLimit = limit
    }
    
    func showErrorAlertOnView(errorMessage: String) {
        self.lastPage -= 1
        self.tableView.hideSkeleton()
        self.endPullToRefresh()
        self.showAlert(message: errorMessage)
        self.tableView.tableFooterView = self.tableView.emptyFooterView()
    }
    
    func showLoader(shouldVisible: Bool) {
        if shouldVisible {
            self.showLoader()
        } else {
            self.hideLoader()
        }
    }
    
    func reloadViewAfterDataSet(isDataEmpty: Bool) {
        if !isDataEmpty {
            //create timer only if there is some data source
            self.createTimer()
        }
        self.tableView.hideSkeleton()
        self.refreshControl?.endRefreshing()
        self.tableView.tableFooterView = self.tableView.emptyFooterView()
        self.tableView.reloadData()
     
    }
    
    func updatePageNumber() {
        self.currentPage += 1
    }
}

// MARK: UIScrollViewDelegate
extension RightSideMenuController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if lastPage < currentPage {
                lastPage = currentPage
                self.tableView.tableFooterView = Utility.getPagingSpinner()
                self.presenter.getData(forPage: self.currentPage)
            }
        }
    }
}

// MARK: ActivityInformationTableCellDelegate
extension RightSideMenuController: ActivityInformationTableCellDelegate {
    func didClickOnJoinActivity(sender: UIButton) {
        self.presenter.joinActivity(index: sender.tag)
    }
}
