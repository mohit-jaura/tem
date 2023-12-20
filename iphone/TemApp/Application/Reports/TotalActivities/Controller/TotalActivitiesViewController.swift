//
//  TotalActivitiesViewController.swift
//  TemApp
//
//  Created by shilpa on 24/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SideMenu

class TotalActivitiesViewController: DIBaseController {

    // MARK: Properties
    var tableViewY: CGFloat = 230.0
    var activities: [UserActivity]? {
        didSet {
            if let activitiesData = activities {
                if !activitiesData.isEmpty {
                    self.messageBackgroundLabel.text = ""
                } else {
                    self.messageBackgroundLabel.text = AppMessages.Report.noActivitiesFound
                }
            }
        }
    }
    var currentPage = 0//1
    var lastPage = 0

    var selectedActivitiesIds: [Int]?
    var dateFilter: ActivityFilterByDate?
    private var filterViewController: TotalActivitiesFilterSideMenuViewController?
    private var filterQueryString = ""
    var totalCount = 0
    var flag: ReportFlag?

    // MARK: IBOutlets
    @IBOutlet weak var countViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var grayBackgroundView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var honeyCombView: ActivityLogHoneyCombView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageBackgroundLabel: UILabel!
    @IBOutlet weak var fullBackgroundView: UIView!

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.isHidden = true
        self.initRightSideMenu()
        self.configureNavigation()
        //self.showLoader()
        self.tableView.showAnimatedSkeleton()
        self.dateFilter = .descending
        self.getQueryString()
        self.setBackground()
        self.getTotalActivities()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setDefaultNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.createUserExperience()
    }

    // MARK: Initializer
    //configure the navigation bar and its properties
    private func configureNavigation() {
        self.navigationController?.navigationBar.isHidden = true
        _ = self.configureNavigtion(onView: navigationBarView, title: Constant.ScreenFrom.totalActivities.title, rightButtonAction: [.activityFilter])
    }

    private func setBackground() {
        let honeyCombView = ActivityLogHoneyCombView()
        honeyCombView.frame = self.view.bounds
        honeyCombView.frame.size.height = self.view.bounds.height - 44
        self.fullBackgroundView.addSubview(honeyCombView)
    }

    ///configure the right side menu for this screen
    func initRightSideMenu() {
        let sideMenuStoryboard = UIStoryboard(name: UIStoryboard.Storyboard.sidemenu.filename, bundle: nil)
        if let viewcontroller : SideMenuNavigationController = sideMenuStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController {
            let filterSideMenuController: TotalActivitiesFilterSideMenuViewController = UIStoryboard(storyboard: .reports).initVC()
            SideMenuManager.default.rightMenuNavigationController = viewcontroller
            self.filterViewController = filterSideMenuController
            viewcontroller.viewControllers = [filterSideMenuController]
            viewcontroller.settings.presentationStyle = .menuSlideIn
            viewcontroller.settings.statusBarEndAlpha = 0
            viewcontroller.settings.presentationStyle.onTopShadowRadius = 5.0
            viewcontroller.settings.presentationStyle.onTopShadowOpacity = 0.5
            viewcontroller.settings.presentationStyle.onTopShadowColor = .gray
            viewcontroller.settings.menuWidth = self.view.frame.width - 60
        }
    }

    func createUserExperience() {
        if let center = self.honeyCombView.valueDisplayHoneyCombCenterY {
            if let headerView = tableView.tableHeaderView {
                var headerFrame = headerView.frame
                headerFrame.size.height = center + 110
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
        //self.tableView.isHidden = false
        self.tableView.reloadData()
    }

    // MARK: Navigation bar helpers
    override func navigationBar(_ navigationBar: NavigationBar, leftButtonTapped leftButton: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    override func navigationBar(_ navigationBar: NavigationBar, rightButtonTapped rightButton: UIButton) {
        self.grayBackgroundView.isHidden = false
        if let rightSideMenu = SideMenuManager.default.rightMenuNavigationController {
            self.present(rightSideMenu, animated: true, completion: nil)
        }
    }

    // MARK: Api call
    func getTotalActivities() {
        if self.isConnectedToNetwork() {
            DIWebLayerReportsAPI().getTotalActivities(page: self.currentPage, endPoint: self.filterQueryString, success: { (activities, page) in
                self.hideLoader()
                self.setDataSource(data: activities, pageLimit: page)
            }) { (error) in
                self.hideLoader()
                self.tableView.hideSkeleton()
                self.tableView.tableFooterView = self.tableView.emptyFooterView()
                if let message = error.message {
                    self.showAlert(message: message)
                }
            }
        } else {
            self.tableView.tableFooterView = self.tableView.emptyFooterView()
        }
    }

    private func deleteActivityApiCall(id: String, index: Int) {
        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerReportsAPI().deleteActivity(activityId: id, completion: { (_) in
                self.completionAfterDeleteActivity(index: index)
            }) { (error) in
                self.hideLoader()
                if let message = error.message {
                    self.showAlert(message: message)
                }
            }
        }
    }

    // MARK: Helpers
    func getDataWithFilters() {
        self.getQueryString()
        self.resetData()
        self.getTotalActivities()
    }

    /// get the query for the api with the filter by date and activities types added
    private func getQueryString() {
        var endPoint = "&"
        if let selectedIds = self.selectedActivitiesIds {
            let filterStringsArray = selectedIds.map { (number) -> String in
                return "filter[]=\(number)"
            }
            let actualPath = filterStringsArray.joined(separator: "&")
            endPoint += actualPath
        }
        if let dateFilter = self.dateFilter {
            if endPoint == "&" {
                endPoint += "sort=\(dateFilter.key)"
            } else {
                endPoint += "&sort=\(dateFilter.key)"
            }
        }
        if endPoint != "&" {
            self.filterQueryString = endPoint
        } else {
            //get all the results
            self.filterQueryString = ""
        }
    }

    ///set data in table view
    private func setDataSource(data: [UserActivity], pageLimit: Int) {
        if self.currentPage == 0 {
            self.honeyCombView.value = self.totalCount
            self.honeyCombView.reportFlag = self.flag
            self.honeyCombView.setTotalActivitiesCount()
            self.activities?.removeAll()
        }
        if self.activities == nil {
            self.activities = [UserActivity]()
        }
        if data.count >= pageLimit {
            self.currentPage += 1
        }
        self.activities?.append(contentsOf: data)
        self.tableView.tableFooterView = self.tableView.emptyFooterView()
        //self.honeyCombView.setTotalActivitiesCount(count: 17, flag: ReportFlag.sameStats, backgroundColor: UIColor.appRed)
        self.tableView.hideSkeleton()
        self.tableView.reloadData()
    }

    private func resetData() {
        self.currentPage = 0
        self.lastPage = 0
        //self.showLoader()
        self.tableView.showAnimatedSkeleton()
    }

    /// this is called after delete activity success
    /// - Parameter index: index of the activity deleted
    private func completionAfterDeleteActivity(index: Int) {
        if let activities = self.activities,
            index < activities.count,
            let endDateTimestamp = activities[index].startTimestamp {
            let dateConverted = endDateTimestamp.timestampInMillisecondsToDate
            let date30 = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            //count would be decremented for activities in last 30 days
            if dateConverted >= date30 {
                //decerement the count of total activities
                if self.totalCount > 0 {
                    self.totalCount -= 1
                    self.honeyCombView.value = totalCount
                    self.honeyCombView.setTotalActivitiesCount()
                }
            }
        }

        self.activities?.remove(at: index)
        if self.activities?.count == 0 {
            //refresh
            self.activities?.removeAll()
            self.lastPage = 0
            self.currentPage = 0
            self.getTotalActivities()
        } else {
            self.hideLoader()
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension TotalActivitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityReportTableViewCell.reuseIdentifier, for: indexPath) as? ActivityReportTableViewCell else {
            return UITableViewCell()
        }
        if let activities = self.activities {
            cell.initializeAt(indexPath: indexPath, activityInfo: activities[indexPath.row])
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension TotalActivitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94.0
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let activities = self.activities,
            indexPath.row == activities.count - 1 {
            cell.roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
        } else {
            cell.roundCorners([], radius: 0)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let activities = self.activities,
            indexPath.row < activities.count {
            let activitySummaryController: ActivitySummaryViewController = UIStoryboard(storyboard: .activitysummary).initVC()
            activitySummaryController.screenFrom = .totalActivities
            if let currentActivity = self.activities?[indexPath.row] {
                activitySummaryController.summaryData = [currentActivity]
                //activitySummaryController.userActivitySummary = currentActivity
            }
            self.navigationController?.pushViewController(activitySummaryController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let activities = self.activities,
            !activities.isEmpty {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            if let activities = self.activities,
               indexPath.row < activities.count {
                if let activity = self.activities?[indexPath.row] {
                    if (activity.origin != ActivityOrigin.TEM.rawValue) {
                        self.showAlert(withTitle: "", message: AppMessages.GroupActivityMessages.editExternalActivity, okayTitle: "Yes", cancelTitle: "No", okCall:  {
                            self.openEditActivity(activity)
                        })
                    }
                    else {
                        self.openEditActivity(activity)
                    }
                }
            }
        }
        edit.backgroundColor = UIColor.appGreen
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            if let activities = self.activities,
                indexPath.row < activities.count,
                let id = self.activities?[indexPath.row].id {
                self.showAlert(withTitle: "", message: AppMessages.GroupActivityMessages.removeActivity, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {[weak self] in
                    self?.deleteActivityApiCall(id: id, index: indexPath.row)
                }) {
                }
            }
        }
        delete.backgroundColor = UIColor.appRed
        if let activities = self.activities,
            !activities.isEmpty {
            return [delete, edit]
        }
        return nil
    }
    
    private func openEditActivity(_ activity: UserActivity) {
        let activityEditController: ActivityEditController = UIStoryboard(storyboard: .activityedit).initVC()
        activityEditController.activityData = activity
        navigationController?.pushViewController(activityEditController, animated: true)
    }
}

// MARK: SkeletonTableViewDataSource
extension TotalActivitiesViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return ActivityReportTableViewCell.reuseIdentifier
    }
}

// MARK: UISideMenuNavigationControllerDelegate
extension TotalActivitiesViewController: SideMenuNavigationControllerDelegate {
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        self.grayBackgroundView.isHidden = true

        let activityFilterStatus = self.selectedActivitiesIds ?? [] == filterViewController?.selectedActivitiesIds ?? []
        let dateFilterStatus = self.dateFilter == self.filterViewController?.selectedDateFilter

        if activityFilterStatus == true && dateFilterStatus == true {
            //if the new selected filters are same as previous
            //return
            return
        }

        //adding filtered data
        if let ids = self.filterViewController?.selectedActivitiesIds {
            self.selectedActivitiesIds = []
            self.selectedActivitiesIds?.append(contentsOf: ids)
        } else {
            self.selectedActivitiesIds = nil
        }
        if let dateFilter = self.filterViewController?.selectedDateFilter {
            self.dateFilter = dateFilter
        } else {
            self.dateFilter = nil
        }
        if self.isConnectedToNetwork() {
            self.getDataWithFilters()
        }
    }
}

// MARK: UIScrollViewDelegate
extension TotalActivitiesViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 5) {
            if lastPage < currentPage {
                lastPage = currentPage
                self.tableView.tableFooterView = Utility.getPagingSpinner()
                self.getTotalActivities()
            }
        }
    }
}
