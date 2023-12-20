//
//  PostLikesController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 24/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Alamofire
import SSNeumorphicView

///*
// This will hold the section count for the Users listing screen
// */
enum UserListingSection: Int, CaseIterable {
    case myFriends = 0
    case others = 1

    var title: String {
        switch self {
        case .myFriends:
            return "tēmate".localized
        default:
            return "non-tēmate".localized
        }
    }
}

class UsersListingViewController: DIBaseController {
    
    // MARK: Variables.
    private var previousPage:Int = 1
    private var currentPage:Int = 1
    private var searchViewHeight: CGFloat = 50
    //this variable will hold the search text string if any
    private var searchTextString: String?
    let grayishColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
    var isApiCall:Bool = false {
        didSet {
            showActivityIndicator()
        }
    }
    var myFriends = [Friends]()
    var otherUsers = [Friends]()
    var refreshControl: UIRefreshControl!
    var isFromSearch:Bool = false
    var presenter: UsersListingPresenter?
    var rightBarButtonItem: UIBarButtonItem?
    
    // MARK: IBOutlets.
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var searchBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var postLikesTableView: UITableView!
    @IBOutlet weak var likesSearchbar: UISearchBar!
    @IBOutlet weak var closeButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewSearchbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchView: SSNeumorphicView!{
        didSet{
            setShadow(view: searchView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
        }
    }
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.initialize(currentView: self)
        initUI()
        self.configureNavigation()
    }
    func showActivityIndicator() {
        if isApiCall {
            refreshControl.beginRefreshing()
            postLikesTableView.setContentOffset(CGPoint(x: 0, y: postLikesTableView.contentOffset.y - (refreshControl.frame.size.height)), animated: true)

        } else {
            postLikesTableView.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: true, controller: self)
        }
        
    }
    
    // MARK: Function to set Initail Data.
    func initUI() {
        
        if let textfield = likesSearchbar.value(forKey: "searchField") as? UITextField {            textfield.backgroundColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
            textfield.cornerRadius = 15
       textfield.attributedPlaceholder =  NSAttributedString.init(string: "Search", attributes: [NSAttributedString.Key.foregroundColor:UIColor.gray])
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.gray
            }
            if let rightView = textfield.leftView as? UIImageView {
                rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
                rightView.tintColor = UIColor.gray
            }
        }
        
        addRefreshController()
        self.postLikesTableView.registerNibs(nibNames: [UserListTableViewCell.reuseIdentifier])
        self.postLikesTableView.registerHeaderFooter(nibNames: [ExpandedNetworkHeader.reuseIdentifier])
        self.presenter?.showSkeletonViewOnPresentingView()
        self.presenter?.loadDataFor(page: currentPage)
        likesSearchbar.cornerRadius = 15
    }
    
    func configureNavigation() {
        self.navigationController?.navigationBar.isHidden = false
        let title = self.presenter?.titleOfView() ?? ""
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButtonforSearch())
        if isFromSearch {
            self.setNavigationController( titleName: "", leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        }
        if let barItem = self.presenter?.rightBarItem() {
            self.rightBarButtonItem = barItem
        }
        if let barItem = self.rightBarButtonItem {
            self.setNavigationController( titleName: "", leftBarButton: [leftBarButtonItem], rightBarButtom: [barItem], backGroundColor: UIColor.white, translucent: true)
        } else {
            self.setNavigationController( titleName: "", leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        }
        self.navigationController?.setTransparentNavigationBar()
    }
    func getBackButtonforSearch() -> UIButton {
        let buttonBack = UIButton(type: .custom)
        buttonBack.setImage(UIImage(named: "right-arrow (4)"), for: .normal)
        buttonBack.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        buttonBack.addTarget(self, action: #selector(self.popToBackScreen), for: .touchUpInside)
        return buttonBack
    }
    
    private func setShadow(view: SSNeumorphicView, mainColor: UIColor,lightShadow:UIColor,darkShadow:UIColor){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = mainColor.cgColor
        view.viewNeumorphicLightShadowColor = lightShadow.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = darkShadow.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 15
    }

    // MARK: Function to set Response Data.
    func setDataAfterResponse(data:[Friends], resultFromSearch: Bool) {
        isApiCall = false
        if (self.currentPage == 1) {
            self.myFriends.removeAll()
            self.otherUsers.removeAll()
            
            //show empty screen text if the data is empty for first page
            if data.isEmpty {
                self.presenter?.showEmptyScreenMessage(isResultFromSearch: resultFromSearch)
            } else {
                self.postLikesTableView.restore()
            }
        }
        if (data.count > 0) {
            self.myFriends.append(contentsOf: data.filter {$0.id == User.sharedInstance.id ?? ""})
            self.myFriends.append(contentsOf:data.filter {$0.isFriend == 1 && $0.id != User.sharedInstance.id ?? "" })
            self.otherUsers.append(contentsOf: data.filter {$0.isFriend == 0 && $0.id != User.sharedInstance.id ?? "" })
        }
        if data.count >= 15 {
            self.currentPage += 1
        }
        self.postLikesTableView.hideSkeleton()
        self.postLikesTableView.tableFooterView = self.postLikesTableView.emptyFooterView()
        self.refreshControl.endRefreshing()
        self.postLikesTableView.reloadData()
    }
    
    /// stop all alamofire sessions before initiating a new request
    func stopAllSessions() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getAllTasks { (task) in
            task.forEach { $0.cancel()}
        }
    }
    
    // MARK: AddRefreshController To TableView.
    private func addRefreshController() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)) , for: .valueChanged)
        postLikesTableView.addSubview(refreshControl)
    }
    
    // MARK: Function To Refresh Posts Tableview Data.
    @objc func refreshData(sender:AnyObject) {
        fetchNewData()
    }
    
    func fetchNewData() {
        isApiCall = true
        currentPage = 1
        previousPage = 1
        //self.presenter?.loadDataFor(page: currentPage)
        self.presenter?.loadNextPageData(forPageNumber: currentPage, searchText: searchTextString)
    }
    
    // MARK: ScrollViewDelegate.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == postLikesTableView {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                if previousPage < currentPage {
                    previousPage = currentPage
                    self.postLikesTableView.tableFooterView = Utility.getPagingSpinner()
                    //self.presenter?.loadDataFor(page: self.currentPage)
                    isApiCall = true
                    self.presenter?.loadNextPageData(forPageNumber: self.currentPage, searchText: self.searchTextString)
                }
            }
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        /*if likesSearchbar.text != "" {
         fetchNewData()
         } */
        self.searchTextString = nil
        self.fetchNewData()
        if self.viewSearchbarHeightConstraint.constant == 0 {
            return
        }
        self.viewSearchbarHeightConstraint.constant = self.viewSearchbarHeightConstraint.constant - searchViewHeight
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: UserListTableCellDelegate
extension UsersListingViewController : UserListTableCellDelegate {
    func didTapremoveFriend(sender: UIButton, rowSection: Int?, userId: String?) {
        if !(Reachability.isConnectedToNetwork()) {
            self.showAlert(message:AppMessages.AlertTitles.noInternet)
            return
        }
        let networkConnectionManager = NetworkConnectionManager()
        let index = sender.tag
        let friend = self.otherUsers[index]
        if let id = friend.id {
            guard User.sharedInstance.id != id else {return}
            let params:FriendRequest = FriendRequest(friendId:id)
            guard let friendStatus = friend.friendStatus else {
                return
            }
            switch friendStatus {
            case .other :
                networkConnectionManager.sendRequest(params: params.getDictionary(), success: {[weak self] (response)  in
                    self?.handleResponse(statusValue: .requestSent, isFriend: 0, index: sender.tag)
                }) {[weak self] (error) in
                    self?.showAlert(withError: error)
                }
            default:
                break
            }
        }
    }
    
    func didTapAcceptOrRemindButton(sender: CustomButton) {
        if !(Reachability.isConnectedToNetwork()) {
            self.showAlert(message:AppMessages.AlertTitles.noInternet)
            return
        }
        let networkConnectionManager = NetworkConnectionManager()
        let index = sender.row
        let friend = self.otherUsers[index]
        if let id = friend.id {
            guard User.sharedInstance.id != id else {return}
            let params:FriendRequest = FriendRequest(friendId:id)
            guard let friendStatus = friend.friendStatus else {
                return
            }
            switch friendStatus {
            case .other :
                networkConnectionManager.sendRequest(params: params.getDictionary(), success: {[weak self] (response)  in
                    self?.handleResponse(statusValue: .requestSent, isFriend: 0, index: sender.row)
                }) {[weak self] (error) in
                    self?.showAlert(withError: error)
                }
            case .requestReceived:
                networkConnectionManager.acceptRequest(params: params.getDictionary(), success: {[weak self] (response) in
                    self?.handleResponse(statusValue: .connected, isFriend: 1, index: sender.row)
                    let currentFriend = self?.otherUsers[index]
                    if currentFriend != nil {
                        self?.myFriends.insert(currentFriend!, at: 0)
                    }
                    self?.otherUsers.remove(at: index)
                    self?.postLikesTableView.reloadData()
                }) {[weak self] (error) in
                    self?.showAlert(withError: error)
                }
            default:
                break
            }
            
        }
    }
    func didTapCancelButton(sender: CustomButton) {
    }
    func handleResponse(statusValue: FriendStatus,isFriend: Int,index: Int) {
        self.otherUsers[index].friendStatus = statusValue
        self.otherUsers[index].isFriend = isFriend
        self.postLikesTableView.reloadData()
    }
}

// MARK: UISearchBarDelegate
extension UsersListingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= 3 {
                //start search only on minimum 3 characters
                self.filterUserList(searchText)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= 3 {
                self.filterUserList(searchBar.text ?? "")
            }
        }
    }
    
    func filterUserList(_ searchText: String) {
        self.searchTextString = searchText
        isApiCall = true
        self.stopAllSessions()
        if searchText == "" {
            self.fetchNewData()
            return
        }
        currentPage = 1
        previousPage = 1
        self.presenter?.searchListingWithCurrentPage(page: currentPage, withText: searchText)
    }
}


// MARK: SkeletonTableViewDataSource
extension UsersListingViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return UserListTableViewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
}

// MARK: UserListingPresenterDelegate
extension UsersListingViewController: UserListingPresenterDelegate {
    func setScreenEmpty() {
        // show empty screen
        self.myFriends.removeAll()
        self.otherUsers.removeAll()
        self.postLikesTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func showSkeleton() {
        postLikesTableView.showSkeleton()
    }
    
    func initializeViewLayoutToStartSearch() {
        //set up view in case of load screen with search
        self.crossButton.isHidden = true
        self.viewSearchbarHeightConstraint.constant = self.searchViewHeight
        self.likesSearchbar.becomeFirstResponder()
    }
    
    func showEmptyScreenWith(message: String) {
        self.postLikesTableView.showEmptyScreen(message)
    }
    
    func reloadViewWith(data: [Friends], isFromSearch: Bool) {
        self.setDataAfterResponse(data: data, resultFromSearch: isFromSearch )
    }
    
    func didReceiveError(_ error: DIError) {
        self.postLikesTableView.hideSkeleton()
        if self.myFriends.isEmpty && self.otherUsers.isEmpty {
            self.postLikesTableView.showEmptyScreen(error.message ?? "")
        } else {
            self.showAlert(message:error.message)
        }
        self.setViewLayoutForError()
    }
    
    func didTapRightBarButton(sender: UIBarButtonItem) {
        if self.viewSearchbarHeightConstraint.constant == searchViewHeight {
            return
        }
        self.likesSearchbar.text = nil
        self.viewSearchbarHeightConstraint.constant = self.viewSearchbarHeightConstraint.constant + searchViewHeight
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showNoInternetConnectionMessage() {
        self.postLikesTableView.hideSkeleton()
        if self.myFriends.isEmpty && self.otherUsers.isEmpty {
            self.postLikesTableView.showEmptyScreen(AppMessages.AlertTitles.noInternet)
        } else {
            self.noInternetConnectionMessage()
        }
        self.setViewLayoutForError()
    }
    
    func setViewLayoutForError() {
        self.previousPage -= 1
        self.postLikesTableView.tableFooterView = self.postLikesTableView.emptyFooterView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
}
