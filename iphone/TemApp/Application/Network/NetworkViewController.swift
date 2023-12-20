//
//  NetworkViewController.swift
//  VIZU
//
//  Created by shubam on 27/09/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit
import SideMenu
import SSNeumorphicView

protocol NetworkSearchDelegate{
    func getHeight(_ height:CGFloat)
}
enum NetworkSection:Int,CaseIterable{
    case suggestedFriends = 0
    case pendingRequests
    case sentRequests
    case friends
    
    func getSectionTitle() -> String{
        switch self {
        case .suggestedFriends:return"SUGGESTED TĒMATES"
        case .pendingRequests:return"PENDING REQUESTS"
        case .sentRequests:return"SENT REQUESTS"
        case .friends:return "TĒMATES"
        }
    }
}
enum NetworkSearchSection:Int,CaseIterable {
    
    case friendSearch = 0
    case otherfriennds
    
    func getSectionTitle() -> String{
        switch self {
        case .friendSearch:return"FRIENDS"
        case .otherfriennds:return"OTHERS"
        }
    }
}

enum CurrentView: Int, CaseIterable {
    case temates
    case suggestedFriends
}

class NetworkViewController: DIBaseController {
    
    // MARK: Properties
    var isFromProfile = false
    var isFromDashboard = true
    var isPendingRequestOpen = false
    var isSentRequestOpen = false
    var arrFbFriends:[FBFriendModal] = [FBFriendModal]()
    var arrPendingRequest:[Friends] = [Friends]()
    var arrSentRquest:[Friends] = [Friends]()
    var arrFriends:[Friends] = [Friends]()
    var arrSuggestedFriends:[Friends] = [Friends]()
    var pendingRequestPageNo:Int  = 1
    var sentRequestPageNo:Int  = 1
    var friendsPageNo:Int  = 1
    var suggestedFriendsPageNo:Int  = 1
    var hasDataLoaded:Bool = false
    var hasSentRequestDataLoaded:Bool = false
    var hasAllFriendsDataLoaded:Bool = false
    var hasAllSuggestionsDataLoaded: Bool = false
    var shouldShowMore:Bool = false
    var shouldSentRequestShowMore:Bool = false
    var shouldFriendsShowMore:Bool = false
    var hasMoreSuggestivefriends:Bool = false
    var isFBlogin = false
    let paginationLimit = 15
    var pendingRequestCount = 0
    var sentRequestCount = 0
    var friendsCount = 0
    var refreshControl:UIRefreshControl = UIRefreshControl()
    let networkManager = NetworkConnectionManager()
    
    //variables holding the single page count for each of the sections
    var pendingRequestSinglePageCount = 0
    var sentRequestSinglePageCount = 0
    var suggestedFriendsSinglePageCount = 0
    
    let collapseHeaderViewHeight: CGFloat = 63.0
    let currentViewColor = #colorLiteral(red: 0.4129237235, green: 0.9907485843, blue: 0.9624536633, alpha: 1)
    let grayishColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
    //variables holding the key whether the footer of a particular section is visible or not
    var isPendingRequestFooterVisible =  false
    var isSentRequestFooterVisible =  false
    var isFriendsFooterVisible =  false
    var isSuggestionsFooterVisible =  false
    var delegate : NetworkSearchDelegate?
    var tableHeight : CGFloat = 0
    var currentView: CurrentView = .temates {
        didSet {
            switch currentView {
            case .temates:
              self.tematesHighlightImageView.backgroundColor = currentViewColor
                setShadow(view: suggestedBgView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
                self.tematesCountLabel.textColor = UIColor.black
                self.suggestedTematesCountLabel.textColor = UIColor.white
                self.suggestedTematesHighlightImageView.backgroundColor = grayishColor
                self.facebookContactsSyncView.isHidden = true
                self.searchViewTopConstraint.constant = 15
            case .suggestedFriends:
            setShadow(view: tematesBgView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
                    self.tematesHighlightImageView.backgroundColor = grayishColor
                self.suggestedTematesCountLabel.textColor = UIColor.black
                self.tematesCountLabel.textColor = UIColor.white
                self.suggestedTematesHighlightImageView.backgroundColor = currentViewColor
                self.facebookContactsSyncView.isHidden = false
                self.searchViewTopConstraint.constant = self.facebookContactsSyncView.frame.height + 25
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tematesCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tematesHighlightImageView: UIImageView!
    @IBOutlet weak var suggestedTematesHighlightImageView: UIImageView!
    @IBOutlet weak var suggestedTematesCountLabel: UILabel!
    @IBOutlet weak var facebookContactsSyncView: UIView!
    @IBOutlet weak var facebookButton: SSNeumorphicButton!{
        didSet{
            self.setBtnShadow(btn: facebookButton, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var contactsButton: SSNeumorphicButton!{
        didSet{
            self.setBtnShadow(btn: contactsButton, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var profileTabsView: UIView!
    @IBOutlet weak var profileTabsViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var findNewTematesView: UIView!
    @IBOutlet weak var findNewTematesLbl: UILabel!
    @IBOutlet weak var findNewTematesButton: UIButton!
    
    @IBOutlet weak var myCurrentTematesView: UIView!
    @IBOutlet weak var myCurrentTematesLbl: UILabel!
    @IBOutlet weak var myCurrentTematesButton: UIButton!
    
    @IBOutlet weak var suggestedBgView: SSNeumorphicView!{
        didSet{
            setShadow(view: suggestedBgView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
        }
    }
    @IBOutlet weak var tematesBgView: SSNeumorphicView!{
        didSet{
            setShadow(view: tematesBgView, mainColor:grayishColor, lightShadow: currentViewColor, darkShadow: currentViewColor)
        }
    }
    @IBOutlet weak var networkTabsView: UIView!
    @IBOutlet weak var networkTabsHeight: NSLayoutConstraint!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchView: SSNeumorphicView!{
            didSet{
                setShadow(view: searchView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
            }
        }
    @IBOutlet weak var navigationBarLineView: SSNeumorphicView! {
        didSet{
            navigationBarLineView.viewDepthType = .outerShadow
            navigationBarLineView.viewNeumorphicMainColor = grayishColor.cgColor
            navigationBarLineView.viewNeumorphicLightShadowColor = grayishColor.cgColor
            navigationBarLineView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            navigationBarLineView.viewNeumorphicCornerRadius = 0
        }
    }
    // MARK: IBActions
    @IBAction func myCurrentTematesTapped(_ sender: UIButton) {
        self.currentView = .temates
        myCurrentTematesButton.setBackgroundImage(UIImage(named: "blueRectangle"), for: .normal)
        myCurrentTematesButton.setTitleColor(.white, for: .normal)
        
        
        findNewTematesButton.setTitleColor(.black, for: .normal)
        findNewTematesButton.setBackgroundImage(UIImage(named: "whiteRectangle"), for: .normal)
        searchView.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.searchViewHeight.constant = 0
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func findNewTemates(_ sender: UIButton) {
        self.currentView = .suggestedFriends
        myCurrentTematesButton.setBackgroundImage(UIImage(named: "whiteRectangle"), for: .normal)
        myCurrentTematesButton.setTitleColor(.black, for: .normal)
        
        findNewTematesButton.setTitleColor(.white, for: .normal)
        
        findNewTematesButton.setBackgroundImage(UIImage(named: "blueRectangle"), for: .normal)
        searchView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.searchViewHeight.constant = 45
        }
    }
    
    @IBAction func tematesTapped(_ sender: UIButton) {
        self.currentView = .temates
    }
    
    @IBAction func suggestedTematesTapped(_ sender: UIButton) {
        self.currentView = .suggestedFriends
    }
    
    @IBAction func searchTapped(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {
            let searchVC: UsersListingViewController = UIStoryboard(storyboard: .post).initVC()
            searchVC.presenter = UsersListingPresenter(forScreenType: .searchAppUsers)
            self.navigationController?.pushViewController(searchVC, animated: true)
        })
    }
    
    @IBAction func syncWithFacebookTapped(_ sender: UIButton) {
        if !self.isConnectedToNetwork() {
            return
        }
        FacebookManager.shared.login([.email, .publicProfile, .birthday, .friends], success: { (user) in
            self.isFBlogin = true
            self.showLoader()
            self.getFbFriends()
            self.hideLoader()
        }, failure: { (error) in
            self.isFBlogin = false
            self.hideLoader()
        }, onController: self)
    }
    
    @IBAction func syncPhoneContactsTapped(_ sender: UIButton) {
        self.syncPhoneNumberContacts()
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createUserExperience()
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            if self.tableHeight != self.tableView.contentSize.height {
                self.tableHeight = self.tableView.contentSize.height
                self.delegate?.getHeight(self.tableHeight)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavBar()
        self.tabBarController?.tabBar.selectedItem?.title = ""
        if isFromDashboard {
            if let tabBarController = self.tabBarController as? TabBarViewController {
                tabBarController.tabbarHandling(isHidden: false, controller: self)
            }
        }else{
            if let tabBarController = self.tabBarController as? TabBarViewController {
                tabBarController.tabbarHandling(isHidden: true, controller: self)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // self.dismiss(animated: false, completion: nil)
    }
    
    func createUserExperience(){
        backBtn.addDoubleShadowToButton(cornerRadius: backBtn.frame.height / 2, shadowRadius: 0.4, lightShadowColor: UIColor.white.withAlphaComponent(0.1).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor:grayishColor)
        registerXIb()
        addRefreshControl()
        profileTabsView.isHidden = true
        profileTabsViewHeight.constant = 0
        self.tableView.registerNibs(nibNames: [UserListTableViewCell.reuseIdentifier])
        self.tableView.registerHeaderFooter(nibNames: [ExpandedNetworkHeader.reuseIdentifier, NetworkHeader.reuseIdentifier])
        self.tableView.tableFooterView = tableView.emptyFooterView()
        // Do any additional setup after loading the view.
        if FacebookManager.shared.getToken() != nil {
            self.facebookButton.isHidden = true
            isFBlogin = true
            getFbFriends()
        } else {
            self.facebookButton.isHidden = false
            self.tableView.reloadData()
        }
        getAllData()
    }
    private func setShadow(view: SSNeumorphicView, mainColor: UIColor,lightShadow:UIColor,darkShadow:UIColor){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = mainColor.cgColor
        view.viewNeumorphicLightShadowColor = lightShadow.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = darkShadow.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 0
    }
    
    func setDefaultsForProfileScreen(){
        profileTabsView.isHidden = false
        networkTabsView.isHidden = true
        tableView.isScrollEnabled = false
        tableView.clipsToBounds = false
        searchView.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.profileTabsViewHeight.constant = 35
            self.networkTabsHeight.constant = 0
            self.searchViewHeight.constant = 0
        }
    }
    
    func addRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func registerXIb(){
        let nib = UINib(nibName: FriendRequestTableViewCell.reuseIdentifier, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: FriendRequestTableViewCell.reuseIdentifier)
        self.tableView.registerNibs(nibNames: [NetworkFooter.reuseIdentifier])
    }
    
    func configureNavBar() {
        var leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        if isFromDashboard {
            leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(openSideMenu))
            leftBarButtonItem.tintColor = UIColor.textBlackColor
        }
        let rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add-frnd"), style: .plain, target: self, action: #selector(rightBarButtonTapped(sender:)))
        rightBarButtonItem.tintColor = UIColor.textBlackColor
        self.setNavigationController(titleName: Constant.ScreenFrom.temates.title, leftBarButton: [leftBarButtonItem], rightBarButtom: [rightBarButtonItem], backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setTransparentNavigationBar()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func openSideMenu() {
        self.presentSideMenu()
    }
    
    @objc func rightBarButtonTapped(sender: UIBarButtonItem) {
        self.getShareUrl()
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.refreshControl.endRefreshing()
        if self.isConnectedToNetwork(shouldShowMessage: false) {
            resetData()
            /*if FacebookManager.shared.getToken() != nil {
             isFBlogin = true
             getFbFriends()
             } */
            self.getAllData()
        } else {
            self.refreshControl.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                _ = self.isConnectedToNetwork()
            }
        }
    }
    
    func resetData() {
        self.arrPendingRequest.removeAll()
        self.arrSentRquest.removeAll()
        self.arrFriends.removeAll()
        self.arrSuggestedFriends.removeAll()
        self.sentRequestPageNo = 1
        self.pendingRequestPageNo = 1
        self.friendsPageNo = 1
        self.suggestedFriendsPageNo = 1
        self.suggestedFriendsSinglePageCount = 0
        self.pendingRequestCount = 0
        self.sentRequestCount = 0
        self.shouldShowMore = false
        self.shouldFriendsShowMore = false
        self.shouldSentRequestShowMore = false
        self.hasMoreSuggestivefriends = false
        
        self.hasAllSuggestionsDataLoaded = false
        self.hasAllFriendsDataLoaded = false
    }
    
    // MARK:custom Methods
    func getAllData() {
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.async {
            self.getPendingRequest()
        }
        concurrentQueue.async {
            self.getSentFriendRequest()
        }
        concurrentQueue.async {
            self.getFriendList()
        }
        concurrentQueue.async {
            self.getSuggestedFriends()
        }
    }
    
    func setPendingRequestData(data:[Friends]) {
        self.pendingRequestSinglePageCount = data.count
        if data.count >= paginationLimit {
            self.pendingRequestPageNo = self.pendingRequestPageNo + 1
            self.shouldShowMore = true
        }
        for value in data {
            if !self.arrPendingRequest.contains(where: {($0.id == value.id)}) {
                self.arrPendingRequest.append(value)
            }
        }
        self.hasDataLoaded = true
        self.tableView.reloadData()
    }
    
    func setSentRequestData(data:[Friends]) {
        self.sentRequestSinglePageCount = data.count
        if data.count >= paginationLimit {
            self.sentRequestPageNo = self.sentRequestPageNo + 1
            self.shouldSentRequestShowMore = true
        }
        for value in data {
            if !self.arrSentRquest.contains(where: {($0.id == value.id)}) {
                self.arrSentRquest.append(value)
            }
        }
        self.hasSentRequestDataLoaded = true
        self.tableView.reloadData()
    }
    
    func setFriendListData(data:[Friends]) {
        if data.count >= paginationLimit {
            self.friendsPageNo = self.friendsPageNo + 1
            self.shouldFriendsShowMore = true
        }
        for value in data {
            if !self.arrFriends.contains(where: {($0.id == value.id)}) {
                self.arrFriends.append(value)
            }
        }
        self.arrFriends = self.arrFriends.sorted {
            if let firstFname = $0.firstName, let secondLname = $1.firstName {
                return firstFname.localizedCaseInsensitiveCompare(secondLname) == ComparisonResult.orderedAscending
            }
            return true
        }
        self.tematesCountLabel.text = "TĒMATES | \(self.friendsCount)"
        self.hasAllFriendsDataLoaded = true
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            if self.tableHeight != self.tableView.contentSize.height {
                self.tableHeight = self.tableView.contentSize.height
                self.delegate?.getHeight(self.tableHeight)
            }
        }
    }
    
    func setSuggestedFriendsData(data:[Friends]) {
        self.suggestedFriendsSinglePageCount = data.count
        if data.count >= paginationLimit {
            self.suggestedFriendsPageNo = self.suggestedFriendsPageNo + 1
            self.hasMoreSuggestivefriends = true
        }
        if self.suggestedFriendsPageNo == 1 {
            self.arrSuggestedFriends.removeAll()
        }
        for value in data {
            if !self.arrSuggestedFriends.contains(where: {($0.id == value.id)}) {
                self.arrSuggestedFriends.append(value)
            }
        }
        self.hasAllSuggestionsDataLoaded = true
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            if self.tableHeight != self.tableView.contentSize.height {
                self.tableHeight = self.tableView.contentSize.height
                self.delegate?.getHeight(self.tableHeight)
            }
        }
    }
    
    func calculateSentRequestPageNo() {
        //        var num = (Double(self.arrSentRquest.count)/5.0).rounded(.up)
        let num = self.arrSentRquest.count / paginationLimit
        //        if num == 0 {
        //            num = 1
        //        }
        self.sentRequestPageNo = num
    }
    
    func redirectToUserProfileController(id:String) {
        if !isConnectedToNetwork() {
            return
        }
        let controller: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        controller.otherUserId = id
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /// API Calling
    func getFbFriends(){
        //  self.showLoader()
        print("Get FB friends called")
        if !self.isConnectedToNetwork() {
            return
        }
        FacebookManager.shared.getFriendList(sucess: { (friendList) in
            self.arrFbFriends = friendList
            self.syncFacebookFriends()
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(message: error?.localizedDescription)
        })
    }
    
    /// Get all pending request
    func getPendingRequest() {
        if !self.isConnectedToNetwork() {
            return
        }
        networkManager.getPendingRequestList(pageNo: pendingRequestPageNo, success: { (data,count) in
            self.pendingRequestCount = count
            self.setPendingRequestData(data: data)
        }, failure: { (error) in
            self.hasDataLoaded = true
            self.shouldShowMore = false
            self.tableView.reloadData()
        })
    }
    
    /// Get list of sent request
    func getSentFriendRequest() {
        if !self.isConnectedToNetwork() {
            return
        }
        networkManager.getSentRequestList(pageNo: sentRequestPageNo, success: { (data,count) in
            self.sentRequestCount = count
            self.setSentRequestData(data: data)
        }, failure: { (error) in
            self.hasSentRequestDataLoaded = true
            self.shouldSentRequestShowMore = false
            self.tableView.reloadData()
        })
    }
    
    
    /// Get list of friends
    func getFriendList() {
        if !self.isConnectedToNetwork() {
            return
        }
        networkManager.getFriendList(pageNo: friendsPageNo, parameters: nil, success: { (data,count) in
            self.friendsCount = count
            self.setFriendListData(data: data)
        }, failure: { (error) in
            self.hasAllFriendsDataLoaded = true
            self.shouldFriendsShowMore = false
            self.tableView.reloadData()
        })
    }
    
    private func remindRequest(id: String, section: Int, row: Int) {
        if !self.isConnectedToNetwork() {
            return
        }
        var params:FriendRequest = FriendRequest()
        params.friendId = id
        //change the remind status
        self.arrSentRquest[row].canRemind = CustomBool.no
        let indexPath = IndexPath(row: row, section: section)
        self.tableView.reloadRows(at: [indexPath], with: .none)
        networkManager.remindUserForSentRequest(params: params.getDictionary(), success: {(response) in
            
        }) {[weak self] (error) in
            //in case of error, change the remind status for the current user back to the initial
            self?.arrSentRquest[row].canRemind = CustomBool.yes
            let indexPath = IndexPath(row: row, section: section)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
            self?.showAlert(withError: error)
        }
    }
    
    //Accept the friend request recieved
    func acceptRequest(id:String,section:Int,row:Int) {
        if !self.isConnectedToNetwork() {
            return
        }
        var params:FriendRequest = FriendRequest()
        params.friendId = id
        //self.showLoader()
        let user = self.currentUserInAction(atSection: section, atRow: row)
        self.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: true, user: nil)
        networkManager.acceptRequest(params: params.getDictionary(), success: {[weak self] (response) in
            //self.hideLoader()
            if let count = response["count"] as? Int {
                self?.pendingRequestCount = count
                if let status = response["status"] as? Int,let message = response["message"] as? String {
                    if status == 0  {
                        self?.showAlert(withTitle: AppMessages.ProfileMessages.warning, message: message, okayTitle: AppMessages.AlertTitles.Ok,okCall: {
                        })
                    }
                }
            }
            self?.shouldFriendsShowMore = false
            self?.hasAllFriendsDataLoaded = false
            self?.getFriendList()
        }) {[weak self] (error) in
            ///insert the user back in the list
            self?.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: false, user: user)
            self?.showAlert(withError:error)
        }
    }
    
    func updateLocalRequestsArrayFor(_ section: Int, atRow row: Int, shouldDelete: Bool, user: Friends?) {
        if let currentSection = NetworkSection(rawValue: section) {
            switch currentSection {
            case .pendingRequests:
                if self.arrPendingRequest.isEmpty {
                    return
                }
                if shouldDelete,
                   row < self.arrPendingRequest.count {
                    self.arrPendingRequest.remove(at: row)
                    if self.pendingRequestCount > 0 {
                        self.pendingRequestCount -= 1
                    }
                } else {
                    if let user = user,
                       row <= self.arrPendingRequest.count {
                        self.arrPendingRequest.insert(user, at: row)
                        self.pendingRequestCount += 1
                    }
                }
            case .sentRequests:
                if self.arrSentRquest.isEmpty {
                    return
                }
                if shouldDelete,
                   row < self.arrSentRquest.count {
                    self.arrSentRquest.remove(at: row)
                    if self.sentRequestCount > 0 {
                        //decrement the count
                        self.sentRequestCount -= 1
                    }
                } else {
                    if let user = user,
                       row <= self.arrSentRquest.count {
                        self.arrSentRquest.insert(user, at: row)
                        self.sentRequestCount += 1
                    }
                }
            case .suggestedFriends:
                if self.arrSuggestedFriends.isEmpty {
                    return
                }
                if shouldDelete,
                   row < self.arrSuggestedFriends.count {
                    self.arrSuggestedFriends.remove(at: row)
                } else {
                    if let user = user,
                       row <= self.arrSuggestedFriends.count {
                        self.arrSuggestedFriends.insert(user, at: row)
                    }
                }
            case .friends:
                if self.arrFriends.isEmpty {
                    return
                }
                if shouldDelete,
                   row < self.arrFriends.count {
                    self.arrFriends.remove(at: row)
                    if self.friendsCount > 0 {
                        self.friendsCount -= 1
                    }
                } else {
                    if let user = user,
                       row <= self.arrFriends.count {
                        self.arrFriends.insert(user, at: row)
                        self.friendsCount += 1
                    }
                }
                self.tematesCountLabel.text = "TĒMATES | \(self.friendsCount)"
            }
            self.tableView.reloadData()
        }
    }
    
    func currentUserInAction(atSection section: Int, atRow row: Int) -> Friends {
        if let currentSection = NetworkSection(rawValue: section) {
            switch currentSection {
            case .pendingRequests:
                return arrPendingRequest[row]
            case .sentRequests:
                return arrSentRquest[row]
            case .friends:
                return arrFriends[row]
            case .suggestedFriends:
                return arrSuggestedFriends[row]
            }
        }
        fatalError("section index out of bounds")
    }
    
    //send a new friend request
    func sendRequest(id: String, section: Int, row: Int) {
        if !isConnectedToNetwork() {
            return
        }
        let params: FriendRequest = FriendRequest(friendId: id)
        let user = self.currentUserInAction(atSection: section, atRow: row)
        self.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: true, user: nil)
        networkManager.sendRequest(params: params.getDictionary(), success: {[weak self] (response) in
            //
            self?.shouldSentRequestShowMore = false
            self?.hasSentRequestDataLoaded = false
            self?.getSentFriendRequest()
        }) {[weak self] (error) in
            self?.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: false, user: user)
            self?.showAlert(withError: error)
        }
    }
    
    //reject the friend request recieved
    func rejectRequest(id:String,section:Int,row:Int) {
        if !self.isConnectedToNetwork() {
            return
        }
        let params:FriendRequest = FriendRequest(friendId:id)
        //self.showLoader()
        let user = self.currentUserInAction(atSection: section, atRow: row)
        self.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: true, user: nil)
        networkManager.rejectRequest(params: params.getDictionary(), success: {[weak self] (response) in
            //self.hideLoader()
            if let count = response["count"] as? Int {
                self?.pendingRequestCount = count
            }
            /*self?.arrPendingRequest.remove(at: row)*/
            self?.tableView.reloadData()
        }) {[weak self] (error) in
            //self.hideLoader()
            //insert the current user in action back into the array
            self?.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: false, user: user)
        }
    }
    
    //reject the friend request sent
    func deleteRequest(id:String,section:Int,row:Int) {
        if !self.isConnectedToNetwork() {
            return
        }
        let user = self.currentUserInAction(atSection: section, atRow: row)
        self.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: true, user: nil)
        let params:FriendRequest = FriendRequest(friendId:id)
        networkManager.deleteRequest(params: params.getDictionary(), success: {[weak self] (response) in
            if let count = response["count"] as? Int {
                self?.sentRequestCount = count
            }
            /*self.arrSentRquest.remove(at: row) */
            self?.tableView.reloadData()
        }) {[weak self] (error) in
            self?.updateLocalRequestsArrayFor(section, atRow: row, shouldDelete: false, user: user)
        }
        
    }
    
    //Sync facebook friend with our server.
    func syncFacebookFriends() {
        if !self.isConnectedToNetwork() {
            return
        }
        var arrFriends:[String] = [String]()
        for value in arrFbFriends {
            if let id = value.id {
                arrFriends.append(id)
            }
        }
        var param = PhoneContactsKey()
        param.valuesArray = arrFriends
        param.snsType = SyncContactsType.facebook
        DIWebLayerNetworkAPI().syncContacts(parameters: param.getDictionary(), success: { (response) in
            
            // Hide facebookButton after FBFriends syncing...
            self.facebookButton.isHidden = true
            self.resetSuggestionsListing()
        }) { (_) in
            
        }
    }
    
    //get suggestion friends
    /* func getSuggestedFriends() {
     if !self.isConnectedToNetwork() {
     if self.arrSuggestedFriends.count == 0{
     hideCollectionViewLoader(message: AppMessages.NetworkMessages.retryErrorMessage)
     }
     }
     DIWebLayerNetworkAPI().getSuggestedFriends(parameters: nil, page: self.suggestedFriendsPageNo.stringValue, success: { (friends) in
     self.setSuggestedFriendsData(data: friends)
     }) { (error) in
     if self.arrSuggestedFriends.count == 0{
     self.hideCollectionViewLoader(message: AppMessages.NetworkMessages.retryErrorMessage)
     }
     self.tableView.reloadData()
     }
     } */
    func getSuggestedFriends() {
        if !self.isConnectedToNetwork() {
            return
        }
        DIWebLayerNetworkAPI().getSuggestedFriends(parameters: nil, page: self.suggestedFriendsPageNo.stringValue, success: { (friends) in
            self.setSuggestedFriendsData(data: friends)
        }) { (error) in
            //            if self.arrSuggestedFriends.count == 0{
            //                self.hideCollectionViewLoader(message: AppMessages.NetworkMessages.retryErrorMessage)
            //            }
            // self.tableView.reloadData()
            self.hasAllSuggestionsDataLoaded = true
            self.hasMoreSuggestivefriends = false
            self.tableView.reloadData()
        }
    }
    
    //Delete friend and remove from friend list.
    func deleteFriend(friendId:String,section:Int,row:Int) {
        self.showAlert(withTitle: AppMessages.ProfileMessages.warning, message: AppMessages.NetworkMessages.removeFriend, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
            if !self.isConnectedToNetwork() {
                return
            }
            var params:FriendRequest = FriendRequest()
            params.friendId = friendId
            self.showLoader()
            self.networkManager.deleteFriend(params: params.getDictionary() ?? [:], success: { (response) in
                self.hideLoader()
                self.arrFriends.remove(at: row)
                if self.friendsCount > 0 {
                    self.friendsCount -= 1
                    self.tematesCountLabel.text = "TĒMATES | \(self.friendsCount)"
                }
                self.tableView.reloadData()
            }, failure: { (error) in
                self.hideLoader()
            })
        }) {
        }
    }
    
    /*
     call this function to reload the suggestions after the user syncs his facebook or phone contacts
     */
    func resetSuggestionsListing() {
        self.suggestedFriendsPageNo = 1
        self.shouldSentRequestShowMore = false
        self.hasMoreSuggestivefriends = false
        self.arrSuggestedFriends.removeAll()
        self.getSuggestedFriends()
    }
    
    // MARK:IBActions
    @IBAction func actionFacebook(_ sender: Any) {
        if !self.isConnectedToNetwork() {
            return
        }
        FacebookManager.shared.login([.email, .publicProfile, .birthday, .friends], success: { (user) in
            self.isFBlogin = true
            //show loader
            let indexPath = IndexPath(row: 0, section: 0)
            if let cell:SuggestedFriendHeader = self.tableView.cellForRow(at: indexPath) as? SuggestedFriendHeader  {
                cell.noFbLoginView.isHidden = true
                cell.activityLoader.isHidden = false
            }
            self.getFbFriends()
            self.hideLoader()
        }, failure: { (error) in
            self.isFBlogin = false
            self.hideLoader()
        }, onController: self)
        
    }
    
    func getShareUrl(){
        self.showLoader()
        let url = Constant.SubDomain.inviteUsersLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        DIWebLayerNetworkAPI().getBusinessDynamicLink(url:url,parameters: nil, success: { (response) in
            self.hideLoader()
            let activityViewController = UIActivityViewController(activityItems: [ response ] , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }) { (error) in
            self.hideLoader()
            self.showAlert(withError:error)
        }
    }
    
    // MARK: Helper functions
    func handleExpandCollapseForSection(_ section: Int) {
        if let networkSection = NetworkSection(rawValue: section) {
            switch networkSection {
            case .pendingRequests:
                self.isPendingRequestOpen = !self.isPendingRequestOpen
                self.tableView.reloadData()
            case .sentRequests:
                self.isSentRequestOpen = !self.isSentRequestOpen
                self.tableView.reloadData()
            default:break
            }
        }
    }
    
    func setBtnShadow(btn: SSNeumorphicButton, shadowType: ShadowLayerType){
        btn.btnNeumorphicCornerRadius = btn.frame.height / 2
        btn.btnNeumorphicShadowRadius = 0.8
        btn.btnDepthType = shadowType
        btn.btnNeumorphicLayerMainColor = btn.backgroundColor?.cgColor ?? UIColor.white.cgColor
        btn.btnNeumorphicShadowOpacity = 0.25
        btn.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.7)
        btn.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        btn.btnNeumorphicLightShadowColor = UIColor.black.cgColor
    }
}

// MARK: PhoneContactProtocol
extension NetworkViewController: PhoneContactProtocol {
    
    //call this function to fetch phone book contacts and syncing them to the server
    private func syncPhoneNumberContacts() {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        let contactsArr = self.fetchContacts(filter: .phoneNumber, shouldShowAlertForPermission: true)
        var phoneNumberArr:[String] = []
        if (contactsArr.count > 0) {
            for contacts in contactsArr {
                phoneNumberArr.append(contacts.phoneNumber.first?.removeSpecialCharacters ?? "")
            }
            var param = PhoneContactsKey()
            param.valuesArray = phoneNumberArr
            param.snsType = SyncContactsType.phoneBook
            DIWebLayerNetworkAPI().syncContacts(parameters: param.getDictionary(), success: { (response) in
                self.resetSuggestionsListing()
                self.hideLoader()
                self.showAlert(withTitle: "", message: AppMessages.CommanMessages.success, okayTitle: AppMessages.AlertTitles.Ok,okCall: {
                })
            }) { (error) in
                self.showAlert(message:error.message)
                self.hideLoader()
            }
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension NetworkViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return NetworkSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let header = NetworkSection(rawValue: section){
            switch header{
            case .suggestedFriends :
                if currentView == .suggestedFriends {
                    return self.arrSuggestedFriends.count
                }
            case .pendingRequests:
                if currentView == .temates,
                   isPendingRequestOpen {
                    return self.arrPendingRequest.count
                }
            case .sentRequests:
                if currentView == .temates,
                   isSentRequestOpen {
                    return self.arrSentRquest.count
                }
            case .friends:
                if currentView == .temates {
                    return self.arrFriends.count
                }
            }
        }
        return 0
    }
    
    /* func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     guard let header = tableView.dequeueReusableCell(withIdentifier: NetworkHeader.reuseIdentifier) as? NetworkHeader else {return UIView()}
     header.isPendingRequestOpen = isPendingRequestOpen
     header.isSentRequestOpen = isSentRequestOpen
     if let networkSection = NetworkSection(rawValue: section){
     switch networkSection{
     case .pendingRequests:
     header.configureCell(section:section,count: pendingRequestCount)
     case .sentRequests:
     header.configureCell(section:section,count: sentRequestCount)
     case .friends:
     header.configureCell(section: section,count: friendsCount)
     default:
     header.configureCell(section: section)
     }
     }
     header.delegate = self
     return header
     } */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.currentView {
        case .temates:
            return headerViewForTemates(tableView: tableView, section: section)
        case .suggestedFriends:
            return headerViewForSuggestedTemates(tableView: tableView, section: section)
        }
    }
    
    func headerViewForTemates(tableView: UITableView, section: Int) -> UIView? {
        if let networkSection = NetworkSection(rawValue: section) {
            switch networkSection {
            case .pendingRequests:
                if !isPendingRequestOpen {
                    //configure header view for collapsed
                    if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NetworkHeader.reuseIdentifier) as? NetworkHeader {
                        header.delegate = self
                        header.configure(section: networkSection, count: pendingRequestCount)
                        return header
                    }
                } else {
                    //configure header view for expanded
                    if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandedNetworkHeader.reuseIdentifier) as? ExpandedNetworkHeader {
                        header.delegate = self
                        header.configureFor(section: networkSection)
                        return header
                    }
                }
                
            case .sentRequests:
                if !isSentRequestOpen {
                    //configure header view for collapsed
                    if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NetworkHeader.reuseIdentifier) as? NetworkHeader {
                        header.delegate = self
                        header.configure(section: networkSection, count: sentRequestCount)
                        return header
                    }
                } else {
                    //configure header view for expanded
                    if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandedNetworkHeader.reuseIdentifier) as? ExpandedNetworkHeader {
                        header.delegate = self
                        header.configureFor(section: networkSection)
                        return header
                    }
                }
                
            case .friends:
                if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandedNetworkHeader.reuseIdentifier) as? ExpandedNetworkHeader {
                    header.delegate = self
                    header.backView.backgroundColor = .clear
                    header.configureFor(section: networkSection)
                    return header
                }
            case .suggestedFriends:
                return nil
            }
        }
        return nil
    }
    
    func headerViewForSuggestedTemates(tableView: UITableView, section: Int) -> UIView? {
        if let networkSection = NetworkSection(rawValue: section) {
            switch networkSection {
            case .suggestedFriends:
                if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandedNetworkHeader.reuseIdentifier) as? ExpandedNetworkHeader {
                    header.delegate = self
                    header.configureFor(section: networkSection)
                    return header
                }
            default:
                return nil
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableCell(withIdentifier: NetworkFooter.reuseIdentifier) as? NetworkFooter else {return UIView()}
        footer.btnShowMore.tag = section
        footer.delegate = self
        footer.btnShowMore.isUserInteractionEnabled = true
        if let networkSection = NetworkSection(rawValue: section){
            switch networkSection {
            case .pendingRequests:
                footer.configureSection(hasDataLoaded: hasDataLoaded, shouldShowMore: shouldShowMore)
                /*if self.arrPendingRequest.count == 0 {
                 footer.btnShowMore.isUserInteractionEnabled = false
                 footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noRecordToDisplay, for: .normal)
                 footer.btnShowMore.layer.borderColor = UIColor.clear.cgColor
                 } */
            case .sentRequests:
                footer.configureSection(hasDataLoaded: hasSentRequestDataLoaded, shouldShowMore: shouldSentRequestShowMore)
                /*if self.arrSentRquest.count == 0 {
                 footer.btnShowMore.isUserInteractionEnabled = false
                 footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noRecordToDisplay, for: .normal)
                 footer.btnShowMore.layer.borderColor = UIColor.clear.cgColor
                 } */
            case .friends:
                footer.configureSection(hasDataLoaded: hasAllFriendsDataLoaded, shouldShowMore: shouldFriendsShowMore)
                if hasAllFriendsDataLoaded {
                    if self.arrFriends.count == 0 && !shouldFriendsShowMore {
                        footer.btnShowMore.isUserInteractionEnabled = false
                        footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noFriendsYet, for: .normal)
                        //footer.btnShowMore.layer.borderColor = UIColor.clear.cgColor
                    }
                }
            case .suggestedFriends:
                footer.configureSection(hasDataLoaded: hasAllSuggestionsDataLoaded, shouldShowMore: hasMoreSuggestivefriends)
                if hasAllSuggestionsDataLoaded {
                    if self.arrSuggestedFriends.count == 0 && !hasMoreSuggestivefriends {
                        footer.btnShowMore.isUserInteractionEnabled = false
                        footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noSuggestions, for: .normal)
                        //footer.btnShowMore.layer.borderColor = UIColor.clear.cgColor
                    }
                }
            }
        }
        return footer
    }
    
    /*func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     switch indexPath.section {
     case NetworkSection.suggestedFriends.rawValue:
     guard let suggestedFrndCell = tableView.dequeueReusableCell(withIdentifier: SuggestedFriendHeader.reuseIdentifier) as? SuggestedFriendHeader else {return UITableViewCell()}
     suggestedFrndCell.selectionStyle = .none
     if self.isConnectedToNetwork(shouldShowMessage: false) {
     suggestedFrndCell.hasMore = self.hasMoreSuggestivefriends
     } else {
     suggestedFrndCell.hasMore = false
     }
     suggestedFrndCell.arrSuggstedFriends = self.arrSuggestedFriends
     suggestedFrndCell.controller = self
     suggestedFrndCell.collectionView.reloadData()
     suggestedFrndCell.activityLoader.startAnimating()
     return suggestedFrndCell
     default:
     guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestTableViewCell.reuseIdentifier) as? FriendRequestTableViewCell else {return UITableViewCell()}
     cell.configureCell(section:indexPath.section)
     cell.delegate = self
     if let section = NetworkSection(rawValue: indexPath.section){
     switch section{
     case .pendingRequests:
     cell.setData(arrFriends: arrPendingRequest, indexPath: indexPath)
     case .sentRequests:
     cell.setData(arrFriends: arrSentRquest, indexPath: indexPath)
     case .friends:
     cell.setData(arrFriends: arrFriends, indexPath: indexPath)
     default:
     break
     }
     }
     cell.selectionStyle = .none
     return cell
     }
     } */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.reuseIdentifier, for: indexPath) as? UserListTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        if let currentSection = NetworkSection(rawValue: indexPath.section) {
            switch currentSection {
            case .sentRequests:
                if indexPath.row < self.arrSentRquest.count {
                    cell.configureViewAt(indexPath: indexPath, user: self.arrSentRquest[indexPath.row])
                }
            case .pendingRequests:
                if indexPath.row < self.arrPendingRequest.count {
                    cell.configureViewAt(indexPath: indexPath, user: self.arrPendingRequest[indexPath.row])
                }
            case .suggestedFriends:
                if indexPath.row < self.arrSuggestedFriends.count {
                    cell.removeButton.tag = indexPath.row
                    cell.section = indexPath.section
                    cell.configureViewAt(indexPath: indexPath, user: self.arrSuggestedFriends[indexPath.row])
                }
            case .friends:
                if indexPath.row < self.arrFriends.count {
                    cell.removeButton.tag = indexPath.row
                    cell.section = indexPath.section
                    cell.configureViewAt(indexPath: indexPath, user: self.arrFriends[indexPath.row])
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserListTableViewCell else {
            return
        }
        if let currentSection = NetworkSection(rawValue: indexPath.section) {
            switch currentSection {
            case .pendingRequests:
                if !self.arrPendingRequest.isEmpty,
                   indexPath.row < arrPendingRequest.count - 1 {
                    cell.contentView.roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
                }
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if editActionsForRowAt.section == NetworkSection.friends.rawValue {
            let diconnect = UITableViewRowAction(style: .normal, title:AppMessages.NetworkMessages.disconnect) { action, index in
                if editActionsForRowAt.row < self.arrFriends.count {
                    if let id = self.arrFriends[editActionsForRowAt.row].id {
                        self.deleteFriend(friendId: id, section: editActionsForRowAt.section, row: editActionsForRowAt.row)
                    }
                }
            }
            diconnect.backgroundColor = UIColor(0xFF6363)
            return [diconnect]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == NetworkSection.friends.rawValue {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.currentView {
        case .temates:
            return heightForHeaderForTematesView(tableView, heightForHeaderInSection: section)
        case .suggestedFriends:
            return heightForHeaderForSuggestedFrndsView(tableView, heightForHeaderInSection: section)
        }
    }
    
    // custom function to return height for headers for current selected view of temates
    func heightForHeaderForTematesView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let networkSection = NetworkSection(rawValue: section) {
            switch networkSection {
            case .pendingRequests:
                if self.arrPendingRequest.isEmpty {
                    if pendingRequestSinglePageCount < paginationLimit {
                        return 0.001
                    }
                    if pendingRequestSinglePageCount == paginationLimit {
                        return 48.0
                    }
                }else if !self.arrPendingRequest.isEmpty {
                    if !isPendingRequestOpen {
                        return collapseHeaderViewHeight
                    }
                    return 48.0
                }
            case .sentRequests:
                if self.arrSentRquest.isEmpty {
                    if sentRequestSinglePageCount < paginationLimit {
                        return 0.001
                    }
                    if sentRequestSinglePageCount == paginationLimit {
                        return 48.0
                    }
                } else if !self.arrSentRquest.isEmpty {
                    if !isSentRequestOpen {
                        return collapseHeaderViewHeight
                    }
                    return 48.0
                }
            case .friends:
                return 48.0
            case .suggestedFriends:
                return 0.001
            }
        }
        return 0.001
    }
    
    // custom function to return height for headers for current selected view of suggested friends
    func heightForHeaderForSuggestedFrndsView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let networkSection = NetworkSection(rawValue: section) {
            switch networkSection {
            case .pendingRequests, .sentRequests, .friends:
                return 0.001
            case .suggestedFriends:
                return 48.0
            }
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let currentSection = NetworkSection(rawValue: section) {
            switch currentSection {
            case .pendingRequests:
                if currentView == .temates,
                   isPendingRequestOpen {
                    if self.arrPendingRequest.isEmpty {
                        if pendingRequestSinglePageCount < paginationLimit {
                            return 0.001
                        }
                        if pendingRequestSinglePageCount == paginationLimit {
                            return 40.0
                        }
                    }
                    if hasDataLoaded == false {
                        return 40
                    }
                    if !shouldShowMore  && self.arrPendingRequest.count >= 0 {
                        return 0.001
                    }
                    return 40
                }
            case .sentRequests:
                if currentView == .temates,
                   isSentRequestOpen {
                    if self.arrSentRquest.isEmpty {
                        if sentRequestSinglePageCount < paginationLimit {
                            return 0.001
                        }
                        if sentRequestSinglePageCount == paginationLimit {
                            return 40.0
                        }
                    }
                    if hasSentRequestDataLoaded == false {
                        return 40
                    }
                    if !shouldSentRequestShowMore && self.arrSentRquest.count > 0 {
                        return 0.001
                    }
                    return 40
                }
            case .friends:
                if currentView == .temates {
                    if hasAllFriendsDataLoaded == false {
                        return 40
                    }
                    if !shouldFriendsShowMore && self.arrFriends.count > 0 {
                        return 0.001
                    }
                    return 40
                }
            case .suggestedFriends:
                if currentView == .suggestedFriends {
                    if hasAllSuggestionsDataLoaded == false {
                        return 40
                    }
                    if !hasMoreSuggestivefriends && self.arrSuggestedFriends.count > 0 {
                        return 0.001
                    }
                    return 40
                }
            }
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var userId = ""
        if let section = NetworkSection(rawValue: indexPath.section){
            switch section{
            case .pendingRequests:
                if indexPath.row < self.arrPendingRequest.count {
                    userId = self.arrPendingRequest[indexPath.row].id ?? ""
                }
            case .sentRequests:
                if indexPath.row < self.arrSentRquest.count {
                    userId = self.arrSentRquest[indexPath.row].id ?? ""
                }
            case .friends:
                if indexPath.row < self.arrFriends.count {
                    userId = self.arrFriends[indexPath.row].id ?? ""
                }
            case .suggestedFriends:
                if indexPath.row < self.arrSuggestedFriends.count {
                    userId = self.arrSuggestedFriends[indexPath.row].id ?? ""
                }
            }
        }
        if userId != "" {
            self.redirectToUserProfileController(id: userId)
        }
    }
}

// MARK: NetworkHeaderDelegate
extension NetworkViewController:NetworkHeaderDelegate{
    
    func selectedQuestion(cell: NetworkHeader, section: Int) {
        
    }
    
    func expandCollapseTapped(section: Int) {
        self.handleExpandCollapseForSection(section)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            if self.tableHeight != self.tableView.contentSize.height {
                self.tableHeight = self.tableView.contentSize.height
                self.delegate?.getHeight(self.tableHeight)
            }
        }
    }
}

// MARK: ExpandedNetworkHeaderDelegate
extension NetworkViewController: ExpandedNetworkHeaderDelegate {
    func didTapOnSelectAll(selectedAll:Bool) { }
    
    func didTapOnExpandedHeader(section: Int) {
        self.handleExpandCollapseForSection(section)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            if self.tableHeight != self.tableView.contentSize.height {
                self.tableHeight = self.tableView.contentSize.height
                self.delegate?.getHeight(self.tableHeight)
            }
        }
    }
}

// MARK: UITextFieldDelegate
extension NetworkViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}

// MARK: NetworkFooterDelegate
extension NetworkViewController:NetworkFooterDelegate {
    
    func showMoreTapped(section: Int) {
        
        if !self.isConnectedToNetwork() {
            return
        }
        
        if section == NetworkSection.pendingRequests.rawValue {
            let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: arrPendingRequest.count, paginationLimit: paginationLimit)
            self.pendingRequestPageNo = currentPage + 1
            self.hasDataLoaded = false
            self.shouldShowMore = false
            self.tableView.reloadData()
            self.getPendingRequest()
        } else if section == NetworkSection.sentRequests.rawValue {
            let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: arrSentRquest.count, paginationLimit: paginationLimit)
            self.sentRequestPageNo = currentPage + 1
            self.hasSentRequestDataLoaded = false
            self.shouldSentRequestShowMore = false
            self.tableView.reloadData()
            self.getSentFriendRequest()
        } else if section == NetworkSection.friends.rawValue {
            let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: arrFriends.count, paginationLimit: paginationLimit)
            self.friendsPageNo = currentPage + 1
            self.hasAllFriendsDataLoaded = false
            self.shouldFriendsShowMore = false
            self.tableView.reloadData()
            self.getFriendList()
        } else {
            let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: arrSuggestedFriends.count, paginationLimit: paginationLimit)
            self.suggestedFriendsPageNo = currentPage + 1
            self.hasAllSuggestionsDataLoaded = false
            self.hasMoreSuggestivefriends = false
            self.tableView.reloadData()
            self.getSuggestedFriends()
        }
    }
}

// MARK: UserListTableCellDelegate
extension NetworkViewController: UserListTableCellDelegate {
    func didTapremoveFriend(sender: UIButton, rowSection: Int?, userId: String?) {
        if let section = NetworkSection(rawValue: rowSection ?? 0) {
            switch section {
            case .friends:
                self.deleteFriend(friendId: userId ?? "", section: rowSection ?? 0, row: sender.tag)
            case .suggestedFriends:
                self.sendRequest(id: userId ?? "", section: rowSection ?? 0, row: sender.tag)
            default:
                break
            }
        }
    }
    
    func didTapAcceptOrRemindButton(sender: CustomButton) {
        if let section = NetworkSection(rawValue: sender.section) {
            switch section {
            case .pendingRequests:
                if let id = self.arrPendingRequest[sender.row].id {
                    self.acceptRequest(id: id, section: sender.section, row: sender.row)
                }
            case .sentRequests:
                if let id = self.arrSentRquest[sender.row].id {
                    self.remindRequest(id: id, section: sender.section, row: sender.row)
                }
                //            case .suggestedFriends:
                //                if let id = self.arrSuggestedFriends[sender.row].id {
                //                    self.sendRequest(id: id, section: sender.section, row: sender.row)
                //                }
                //                break
            case .friends, .suggestedFriends:
                break
            }
        }
    }
    
    func didTapCancelButton(sender: CustomButton) {
        if let section = NetworkSection(rawValue: sender.section) {
            switch section {
            case .pendingRequests:
                if sender.row < self.arrPendingRequest.count {
                    if let id = self.arrPendingRequest[sender.row].id {
                        self.rejectRequest(id: id, section: sender.section, row: sender.row)
                    }
                }
            case .sentRequests:
                if sender.row < self.arrSentRquest.count {
                    if let id = self.arrSentRquest[sender.row].id {
                        self.deleteRequest(id: id, section: sender.section, row: sender.row)
                    }
                }
            case .friends, .suggestedFriends:
                break
            }
        }
    }
    
}
