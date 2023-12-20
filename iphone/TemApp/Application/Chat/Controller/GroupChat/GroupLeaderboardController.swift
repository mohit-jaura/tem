//
//  LeaderBoardController.swift
//  TemApp
//
//  Created by Angry Bird on 12/09/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class GroupLeaderboardController: DIBaseController {
    
    // MARK: Variables.
    var refreshControl: UIRefreshControl!
    var users = [Friends]()
    var groupId: String?
    var groupName: String?
    
    // MARK: IBOutlets.
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: ViewLifeCycle.
    // MARK: ViewDidLoad.
    override func viewDidLoad(){
        super.viewDidLoad()
        initUI()
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.configureNavigation()
    }
    
    // MARK: PrivateFunction.
    // MARK: Function to set Navigation Bar.
    private func  initUI(){
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.registerNibs(nibNames: [LeaderboardTableCell.reuseIdentifier])
        self.tableView.registerHeaderFooter(nibNames: [LeaderboardHeader.reuseIdentifier])
        self.addRefreshController()
        self.getInitialData()
    }
    
    // MARK: Set Navigation
    func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        let title = (self.groupName ?? "") + " " + "Leaderboard".localized
        self.setNavigationController(titleName: title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    // MARK: Function to get Intial Notification Data.
    private func getInitialData(){
        self.tableView.showAnimatedSkeleton()
        self.getLeaderboardData()
    }
    
    // MARK: Api Calls
    private func getLeaderboardData() {
        guard Reachability.isConnectedToNetwork() else {
            self.handleError(message: AppMessages.AlertTitles.noInternet)
            return
        }
        if let groupId = self.groupId {
            DIWebLayerChatApi().getGroupLeaderboard(groupId: groupId, completion: { (members) in
                self.setDataSource(data: members)
            }) { (error) in
                if let msg = error.message {
                    self.handleError(message: msg)
                }
            }
        }
    }
    
    private func setDataSource(data: [Friends]) {
        self.users.removeAll()
        self.users.append(contentsOf: data)
        self.refreshControl.endRefreshing()
        self.tableView.hideSkeleton()
        self.tableView.reloadData()
    }
    
    private func handleError(message: String) {
        self.refreshControl.endRefreshing()
        self.tableView.hideSkeleton()
        if self.users.isEmpty {
            self.tableView.showEmptyScreen(message)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showAlert(message: message)
            }
        }
    }
    
    // MARK: AddRefreshController To TableView.
    private func addRefreshController(){
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(refreshNews(sender:)) , for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: Function To Refresh News Tableview Data.
    @objc func refreshNews(sender:AnyObject){
        if Reachability.isConnectedToNetwork(){
            self.getLeaderboardData()
        }else{
            refreshControl.endRefreshing()
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
}

// MARK: UITableViewDataSource
extension GroupLeaderboardController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableCell.reuseIdentifier, for: indexPath) as? LeaderboardTableCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configureCellForGroupLeaderboard(atIndexPath: indexPath, user: self.users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeaderboardHeader.reuseIdentifier) as? LeaderboardHeader else {
            return UITableViewCell()
        }
        headerView.setHeader(text: "Tēmates".localized)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSkeletonActive {
            cell.hideSkeleton()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension GroupLeaderboardController : LeaderboardTableCellDelegate {
    func didTapOnArrowButton(sender: UIButton, totalOpenedMetricViws: Int) {
        
    }
    
    func didTapOnUserInformation(atRow row: Int, section: Int) {
        
    }
}


// MARK: SkeletonTableViewDataSource
extension GroupLeaderboardController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return LeaderboardTableCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
}
