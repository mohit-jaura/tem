//
//  InviteFriendController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 24/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol InviteFriendControllerViewDelegate: AnyObject {
    func didSelectTemates(members: [Friends])
    func didSelectGroup(group: ChatRoom)
    func noMemberAndTemSelected()
    func didSelectMembersAndTem(members: [Friends]?, group: ChatRoom?)
}

extension InviteFriendControllerViewDelegate {
    func didSelectGroup(group: ChatRoom) {}
    func noMemberAndTemSelected() {}
    func didSelectMembersAndTem(members: [Friends]?, group: ChatRoom?) {}
}

class InviteFriendController: DIBaseController {
    
    
    // MARK: Variables.
    weak var delegate: InviteFriendControllerViewDelegate?
    let networkManager = NetworkConnectionManager()
    var friends:[Friends] = [Friends]()
    var groups:[ChatRoom] = [ChatRoom]()
    var publicGroups: [ChatRoom] = [ChatRoom]()
    var selectedFriends:[Friends] = [Friends]()
    var selectedGroup:ChatRoom?
    var isSearch:Bool = false
    var isGroup:Bool = false
    var friendsCount = 0
    var temsCount = 0
    var paginationLimit = 15
    var friendsPageNo:Int  = 1
    var temsPageNo: Int = 1
    var publicTemsPageNo: Int = 1
    var shouldFriendsShowMore:Bool = false
    var shouldTemsShowMore: Bool = false
    var shouldPublicTemsShowMore: Bool = false
    var hasAllFriendsDataLoaded:Bool = false
    var hasAllTemsDataLoaded = false
    var hasAllPublicTemsDataLoaded = false
    let minimumSearchTextLength = 3
    var refreshControl: UIRefreshControl?
    
    var screenFrom: Constant.ScreenFrom?
    var activityMembersType: ActivityMembersType?
    var chatGroupId: String?
    
    //this will be 1 when some entries are to be disabled for selection
    var status: Int?
    
    var showListForTem2Challenge = false
    
    // MARK: IBOutlets.
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarBackView: UIView!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    
    // MARK: ViewLifeCycle
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        searchBar.setImage(UIImage(), for: .search, state: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Custom Functions.
    // MARK: Function to set Tabbar, Navigationbar and controller properties.
    func initUI() {
        if #available(iOS 13.0, *) {
            self.searchBar.searchTextField.backgroundColor = .clear
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
                string: "SEARCH",
                attributes: [.foregroundColor: UIColor.appThemeColor]
            )
            searchBar.searchTextField.font = .systemFont(ofSize: 12)
        } else {
            // Fallback on earlier versions
        }
        
        searchBar.barTintColor = UIColor.blue
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.registerNibs(nibNames: [NetworkFooter.reuseIdentifier])
        self.tableView.registerHeaderFooter(nibNames: [ExpandedNetworkHeader.reuseIdentifier])
        self.addPullToRefresh()
        self.tableView.showAnimatedSkeleton()
        if self.selectedGroup != nil {
            self.isGroup = true
        }
        self.getTheDataList(searchText: nil)
        self.setCollectionHeight()
    }
    
    private func getTheDataList(searchText: String?) {
        if let screenType = self.screenFrom {
            switch screenType {
            case .createChallenge:
                if let type = self.activityMembersType {
                    switch type {
                    case .individualVsTem, .individual:
                        if searchText == nil {
                            self.getFriendList()
                        } else {
                            self.getFriendListWithSearch(text: searchText ?? "")
                        }
                        self.callTemsListApi(searchText: searchText)
                    case .temVsTem:
                        self.callTemsListApi(searchText: searchText)
                        if self.showListForTem2Challenge {
                            self.getPublicTeamsListing(searchString: searchText)
                        }
                    }
                } else {
                    if searchText == nil {
                        self.getFriendList()
                    } else {
                        self.getFriendListWithSearch(text: searchText ?? "")
                    }
                    self.callTemsListApi(searchText: searchText)
                }
            default:
                if searchText == nil {
                    self.getFriendList()
                } else {
                    self.getFriendListWithSearch(text: searchText ?? "")
                }
                self.callTemsListApi(searchText: searchText)
            }
        } else {
            if searchText == nil {
                self.getFriendList()
            } else {
                self.getFriendListWithSearch(text: searchText ?? "")
            }
            self.callTemsListApi(searchText: searchText)
        }
    }
    
    func callTemsListApi(searchText: String?) {
        if let screenFrom = self.screenFrom {
            switch screenFrom {
            case .createChallenge, .createGoal, .event:
                self.getTemsListing(searchString: searchText)
            default:
                break
            }
        }
    }
    
    // MARK: IBAction
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func doneTapped(_ sender: UIButton) {
        if let screenType = self.screenFrom {
            switch screenType {
            case .event, .createGoal, .createChallenge:
                if self.selectedGroup == nil && selectedFriends.isEmpty {
                    self.delegate?.noMemberAndTemSelected()
                    self.navigationController?.popViewController(animated: true)
                    return
                }
            default:
                break
            }
        }
        if self.temWithMembersSelectionEnabled() {
            //for this type, user can select a tem with the multiple individuals
            self.delegate?.didSelectMembersAndTem(members: self.selectedFriends, group: self.selectedGroup)
        } else {
            if isGroup {
                if let selectedGroup = self.selectedGroup {
                    self.delegate?.didSelectGroup(group: selectedGroup)
                }
            } else {
                if !self.selectedFriends.isEmpty {
                    self.delegate?.didSelectTemates(members: self.selectedFriends)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Pull to refresh
    private func addPullToRefresh() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func onPullToRefresh(sender: UIRefreshControl) {
        self.refreshControl?.endRefreshing()
        if Reachability.isConnectedToNetwork() {
            self.fetchMoreData()
        } else {
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                _ = self.isConnectedToNetwork()
            }
        }
    }
    
    // MARK: Get list of friends
    func fetchMoreData() {
        if let searchText = self.searchBar.text,
            !searchText.isEmpty {
            //if there is search text, fetch the list with search
            self.getTheDataList(searchText: searchText)
        } else {
            self.getTheDataList(searchText: nil)
        }
    }
    
    func getFriendList() {
        if !Reachability.isConnectedToNetwork() {
            //show error message
            self.showErrorOnView(errorMessage: AppMessages.AlertTitles.noInternet)
            return
        }
        if let screenFrom = self.screenFrom,
            screenFrom == .addGroupParticipants {
            networkManager.getNewGroupParticipantsList(pageNo: self.friendsPageNo, searchText: nil, groupId: self.chatGroupId, success: { (data, count) in
                self.friendsCount = count
                self.setFriendListData(data: data)
            }) { (error) in
                self.handleError(error: error)
            }
            return
        }
        var params: Parameters?
        if let status = self.status {
            params = [:]
            params?["status"] = status
        }
        networkManager.getFriendList(pageNo: self.friendsPageNo, parameters: params, success: { (data,count) in
            self.friendsCount = count
            self.setFriendListData(data: data)
        }, failure: { (error) in
            self.handleError(error: error)
        })
    }
    
    /// get friend list from search text
    ///
    /// - Parameter text: search string
    func getFriendListWithSearch(text: String) {
        if !Reachability.isConnectedToNetwork() {
            self.showErrorOnView(errorMessage: AppMessages.AlertTitles.noInternet)
            return
        }
        if let screenFrom = self.screenFrom,
            screenFrom == .addGroupParticipants {
            networkManager.getNewGroupParticipantsList(pageNo: self.friendsPageNo, searchText: text, groupId: self.chatGroupId, success: { (data, count) in
                self.friendsCount = count
                self.setFriendListData(data: data)
            }) { (error) in
                self.handleError(error: error)
            }
            return
        }
        var params: Parameters?
        if let status = self.status {
            params = [:]
            params?["status"] = status
        }
        networkManager.getFriendListFromSearch(text: text, parameters: params, pageNo: self.friendsPageNo, success: { (data, count) in
            self.friendsCount = count
            self.setFriendListData(data: data)
        }) { (error) in
            self.handleError(error: error)
        }
    }
    
    //Get list of tems
    func getTemsListing(searchString: String?) {
        networkManager.getTemsListing(searchString: searchString, pageNo: temsPageNo, success: {[weak self] (groups) in
            self?.setGroupsData(data: groups)
        }) { (_) in
            
        }
    }
    
    func getPublicTeamsListing(searchString: String?) {
        networkManager.getPublicTemsListing(searchString: searchString, pageNo: publicTemsPageNo, success: {[weak self] (groups) in
            self?.setPublicGroupsData(data: groups)
        }) { (_) in
            
        }
    }
    
    func handleError(error: DIError) {
        self.tableView.hideSkeleton()
        self.hasAllFriendsDataLoaded = true
        self.shouldFriendsShowMore = false
        self.showErrorOnView(errorMessage: error.title ?? "")
        self.tableView.reloadData()
    }
    
    func setFriendListData(data:[Friends]) {
        if self.friendsPageNo == 1 {
            self.friends.removeAll()
        }
        if data.count >= paginationLimit {
            self.friendsPageNo = self.friendsPageNo + 1
            self.shouldFriendsShowMore = true
        }
        for value in data {
            if !self.friends.contains(where: {($0.id == value.id)}) {
                self.friends.append(value)
            }
        }
        self.friends = self.friends.sorted {
            if let firstFname = $0.firstName, let secondLname = $1.firstName {
                return firstFname.localizedCaseInsensitiveCompare(secondLname) == ComparisonResult.orderedAscending
            }
            return true
        }
        self.hasAllFriendsDataLoaded = true
        self.handleEmptyDataSource()
         self.tableView.hideSkeleton()
        self.tableView.reloadData()
    }
    
    func setGroupsData(data:[ChatRoom]) {
        if self.temsPageNo == 1 {
            self.groups.removeAll()
        }
        if data.count >= paginationLimit {
            self.temsPageNo = self.temsPageNo + 1
            self.shouldTemsShowMore = true
        }
        for value in data {
            if !self.groups.contains(where: {($0.groupId == value.groupId)}), value.isDeleted != CustomBool.yes {
                self.groups.append(value)
            }
        }
        self.hasAllTemsDataLoaded = true
        self.handleEmptyDataSource()
        self.tableView.hideSkeleton()
        self.tableView.reloadData()
    }
    
    func setPublicGroupsData(data:[ChatRoom]) {
        if self.publicTemsPageNo == 1 {
            self.publicGroups.removeAll()
        }
        if data.count >= paginationLimit {
            self.publicTemsPageNo = self.publicTemsPageNo + 1
            self.shouldPublicTemsShowMore = true
        }
        for value in data {
            if !self.publicGroups.contains(where: {($0.groupId == value.groupId)}), value.isDeleted != CustomBool.yes {
                self.publicGroups.append(value)
            }
        }
        self.hasAllPublicTemsDataLoaded = true
        self.handleEmptyDataSource()
        self.tableView.hideSkeleton()
        self.tableView.reloadData()
    }
    
    private func handleEmptyDataSource() {
        if let screenFrom = self.screenFrom {
            switch screenFrom {
            case .createChallenge:
                if let type = self.activityMembersType,
                    type == .temVsTem,
                    showListForTem2Challenge {
                    if friends.isEmpty && groups.isEmpty && publicGroups.isEmpty {
                        self.displayMessageOnScreen()
                    } else {
                        self.tableView.restore()
                    }
                    return
                } else {
                    if friends.isEmpty && groups.isEmpty {
                        self.displayMessageOnScreen()
                    } else {
                        self.tableView.restore()
                    }
                    return
                }
            case .createGoal, .event:
                if friends.isEmpty && groups.isEmpty {
                    self.displayMessageOnScreen()
                } else {
                    self.tableView.restore()
                }
                return
            default:
                break
            }
        }
        //for other screen types
        if friends.isEmpty {
            self.displayMessageOnScreen()
        } else {
            self.tableView.restore()
        }
    }
    
    private func displayMessageOnScreen() {
        if let searchText = self.searchBar.text,
            !searchText.isEmpty {
            self.tableView.showEmptyScreen("No results found for \"\(searchText)\"")
        } else {
            self.tableView.showEmptyScreen(AppMessages.NetworkMessages.noFriendsYet)
        }
    }
    
    /// call this function to show error message on screen
    func showErrorOnView(errorMessage: String) {
        guard !self.friends.isEmpty else {
            self.tableView.showEmptyScreen(errorMessage)
            return
        }
        self.tableView.restore()
        self.showAlert(message: errorMessage)
    }
    
    ///cross button tapped for the case when user can select multiple members with tem
    private func crossTappedForMultipleMembersWithTem(sender: UIButton) {
        if sender.tag == 0 {
            if selectedGroup != nil {
                selectedGroup = nil
                self.isGroup = false
            } else {
                self.selectedFriends.remove(at: 0)
            }
        } else {
            if selectedGroup != nil {
                if sender.tag - 1 < selectedFriends.count {
                    self.selectedFriends.remove(at: sender.tag - 1)
                }
            } else {
                self.selectedFriends.remove(at: sender.tag)
            }
        }
    }
    
    ///cross button tapped in the case when user can either select a tem or multiple members
    private func crossTappedWithEitherTemOrMembers(sender: UIButton) {
        if !isGroup {
            self.selectedFriends.remove(at: sender.tag)
        } else {
            self.selectedGroup = nil
            self.isGroup = false
        }
    }
    func setViews(cell: InviteFriendsTableCell, isSelected: Bool){
        if isSelected {
            cell.addImageView.image = UIImage(named: "complete")
            cell.addButton.setTitle("ADDED", for: .normal)
            cell.addButton.setTitleColor(.black, for: .normal)
        }else{
            cell.addImageView.image = UIImage(named: "sync")
            cell.addButton.setTitle("+ADD", for: .normal)
            cell.addButton.setTitleColor(.white, for: .normal)
        }
    }
    func temWithMembersSelectionEnabled() -> Bool {
        if self.screenFrom == Constant.ScreenFrom.createChallenge,
            let type = self.activityMembersType {
            if type == .individualVsTem || type == .individual {
                return true
            }
        } else if self.screenFrom == Constant.ScreenFrom.createGoal {
            return true
        }
        return false
    }
    
    // MARK: IBActions.
    @IBAction func collectionCrossedTapped(_ sender: UIButton) {
        if self.temWithMembersSelectionEnabled() {
            self.crossTappedForMultipleMembersWithTem(sender: sender)
        } else {
            self.crossTappedWithEitherTemOrMembers(sender: sender)
        }
        self.tableView.reloadData()
        self.collectionView.reloadData()
        self.setCollectionHeight()
    }
}

// MARK: UISearchBarDelegate
extension InviteFriendController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= self.minimumSearchTextLength {
                //start search only on minimum 3 characters
                self.friendsPageNo = 1
                self.shouldFriendsShowMore = false
                self.temsPageNo = 1
                self.publicTemsPageNo = 1
                shouldTemsShowMore = false
                shouldPublicTemsShowMore = false
                self.getTheDataList(searchText: searchText)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= self.minimumSearchTextLength {
                self.friendsPageNo = 1
                self.shouldFriendsShowMore = false
                self.temsPageNo = 1
                self.publicTemsPageNo = 1
                shouldTemsShowMore = false
                shouldPublicTemsShowMore = false
                self.getTheDataList(searchText: searchBar.text ?? "")
            }
        }
    }
}
