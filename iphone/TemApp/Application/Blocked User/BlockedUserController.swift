//
//  BlockedUserController.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class BlockedUserController: DIBaseController {
    
    
    // MARK: Variables.
    var blockedUserArray = [Friends]()
    var currentPageNumber = 1
    var previousPageNumber = 1
    var refreshControl: UIRefreshControl!
    var minimumSearchTextLength = 3
    var tableMessage:String = ""
    
    
    // MARK: IBOutlets.
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var crossButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockedUserTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topView: UIView!
    
    
    // MARK: ViewLifeCycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshController()
        self.showLoader()
        getBlockedUser()
        blockedUserTableView.clipsToBounds = false
        blockedUserTableView.layer.masksToBounds = false
        blockedUserTableView.layer.shadowColor = UIColor.black.cgColor
        blockedUserTableView.layer.shadowOffset = CGSize(width: 2, height: 0)
        blockedUserTableView.layer.shadowRadius = 5.0
        blockedUserTableView.layer.shadowOpacity = 0.7
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.configureNavigation()
    }
    
    // MARK: PrivateFunction.
    // MARK: Set Navigation
    func configureNavigation(){
        self.blockedUserTableView.tableFooterView = UIView()
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: "", leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Function to fetch Blocked User.
    func getBlockedUser() {
        guard Reachability.isConnectedToNetwork() else {
            self.tableMessage = AppMessages.AlertTitles.noInternet
            blockedUserTableView.showEmptyScreen(self.tableMessage)
            self.refreshControl.endRefreshing()
            self.hideLoader()
            return
        }
        SettingsAPI().getBlockedUser(page:currentPageNumber, success: { (data) in
            self.hideLoader()
            self.setDataAfterFetching(data: data)
        }) { (error) in
            self.hideLoader()
            self.refreshControl.endRefreshing()
            self.showAlert(message:error.message)
        }
    }
    
    // MARK: Function to fetch Blocked User.
    func getBlockedUserBySearchText(text: String) {
        guard Reachability.isConnectedToNetwork() else {
            self.tableMessage = AppMessages.AlertTitles.noInternet
            blockedUserTableView.showEmptyScreen(self.tableMessage)
            self.refreshControl.endRefreshing()
            self.hideLoader()
            return
        }
        SettingsAPI().searchBlockedUser(parameters:["query":text], page:currentPageNumber, success: { (data) in
            self.hideLoader()
            self.setDataAfterFetching(data: data)
        }) { (error) in
            self.hideLoader()
            self.refreshControl.endRefreshing()
            self.showAlert(message:error.message)
        }
    }
    
    func fetchBlockedUser() {
        if let searchText = self.searchBar.text,
            !searchText.isEmpty {
            self.getBlockedUserBySearchText(text: searchText)
        } else {
            self.getBlockedUser()
        }
    }
    
    func setDataAfterFetching(data:[Friends]) {
        if self.currentPageNumber == 1{
            self.blockedUserArray.removeAll()
        }
        self.blockedUserArray += data
        if self.blockedUserArray.count == 0 {
            self.tableMessage = "".localized
        }else{
            self.tableMessage = "".localized
        }
        if data.count == 10 {
            self.currentPageNumber += 1
        }
        self.refreshControl.endRefreshing()
        self.blockedUserTableView.reloadData()
    }
    
    // MARK: AddRefreshController To TableView.
    private func addRefreshController() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(refreshControlAction(sender:)) , for: .valueChanged)
        blockedUserTableView.addSubview(refreshControl)
    }
    
    // MARK: Function To Refresh News Tableview Data.
    @objc func refreshControlAction(sender:AnyObject) {
        blockedUserTableView.viewWithTag(100)?.removeFromSuperview()
        blockedUserTableView.viewWithTag(100)?.removeFromSuperview()
        if Utility.isInternetAvailable() {
            currentPageNumber = 1
            previousPageNumber = 1
        }
        fetchBlockedUser()
    }
}


// MARK: UISearchBarDelegate
extension BlockedUserController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= self.minimumSearchTextLength {
                self.fetchBlockedUser()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= self.minimumSearchTextLength {
               self.fetchBlockedUser()
            }
        }
    }
}


// MARK: UIScrollViewDelegate
extension BlockedUserController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if previousPageNumber < currentPageNumber {
                previousPageNumber = currentPageNumber
                self.blockedUserTableView.tableFooterView = Utility.getPagingSpinner()
                fetchBlockedUser()
            }
        }
    }
}
