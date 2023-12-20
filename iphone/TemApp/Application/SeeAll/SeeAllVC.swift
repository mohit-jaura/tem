//
//  SeeAllVC.swift
//  TemApp
//
//  Created by Developer on 20/09/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
//import CoreMIDI

enum MyContent : Int, CaseIterable{
    case whatsNew = 0, nutrition, temTv, goalsAndChallenges, temStore
}
enum SelecedContent{
    case myContent, contentMarket
}
class SeeAllVC: DIBaseController {

    // MARK: IBOutlets
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var myContent:UIButton!
    @IBOutlet weak var contentMarket:UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!

    @IBOutlet weak var adminLiveButton: UIButton!
    @IBOutlet weak var adminLiveImageView: UIImageView!
    @IBOutlet weak var favouritesView: UIView!
    @IBOutlet weak var favouritesCountLbl: UILabel!
    
    // MARK: Properties

    var userProfile: Friends?
    var contentMarketData:[SeeAllModel]?
    var filteredContentList:[SeeAllModel]?
    var selectedContent:SelecedContent = .myContent
    private var searchViewHeightValue: CGFloat = 50.0
    private var isSearchActive = false
    private var searchText = ""
    var challengeId = ""
    var myContentData:[SeeAllModel] = []
    var updateNotificationsCountHandler: OnlySuccess?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        inialise()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Stream.connect.getAllStreamers()
        self.navigationController?.navigationBar.isHidden = true
    }

    private func inialise() {
        adminLiveButton.isHidden = true
        adminLiveImageView.isHidden = true
        checkHostLive()
        tableInitialise()
        setButtonsState(selectedContent: selectedContent)
        initializeData()
    }
    func tableInitialise() {
        tableview.register(SeeAllCellX.nib, forCellReuseIdentifier: SeeAllCellX.identifier)
        tableview.register(SeeAllCoachingCell.nib, forCellReuseIdentifier: SeeAllCoachingCell.identifier)
    }

    // MARK: IBActions
    @IBAction func searchTapped(_ sender: UIButton) {
        switch selectedContent {
        case .myContent:
            let selectedVC:SearchViewController = UIStoryboard(storyboard: .search).initVC()
            self.navigationController?.pushViewController(selectedVC, animated: true)
        case .contentMarket:
            presentSearchBar()
        }
    }

    @IBAction func adminLiveTapped(_ sender: UIButton) {
        Stream.connect.toServer(StreamHelper.adminID,true,self)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func contentMarketTapped(_ sender: UIButton) {
        adminLiveButton.isHidden = true
        adminLiveImageView.isHidden = true
       // fetchContentMarketListing()
        selectedContent = .contentMarket
        setButtonsState(selectedContent: selectedContent)
    }

    @IBAction func myContentTapped(_ sender: UIButton) {
        checkHostLive()
        dismissSearchBar()
        fetchContentMarketListing(false)
        selectedContent = .myContent
        setButtonsState(selectedContent: selectedContent)
    }

    @IBAction func dismissSearchBar(_ sender: UIButton) {
        //dismiss the search bar
        dismissSearchBar()
    }

    // MARK: Methods
    // Check whether admin is live or not
    private func checkHostLive(){
        Stream.connect.toServer(StreamHelper.adminID,false,self, {[weak self] isStreamOn,modal  in
            DispatchQueue.main.async {
                self?.adminLiveButton.isHidden = !isStreamOn
                self?.adminLiveImageView.isHidden = !isStreamOn
            }
        })
    }

    private func initializeData(){

        let carousal = MyContentCarousal()
        carousal.getContentCarousal(type: .seeAllScreen) {[weak self] response, error in
            self?.fetchContentMarketListing()
            if error != nil { print(error); return }
            guard let tiles = response as? [SeeAllModel] else { return }
            self?.myContentData = tiles
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
    }

    private func setButtonsState(selectedContent:SelecedContent){
        switch selectedContent {
        case .myContent:
            dismissSearchBar()
            myContent.backgroundColor = .white
            myContent.borderColor = .white
            myContent.setTitleColor(.black, for: .normal)
            contentMarket.borderColor = .white
            contentMarket.setTitleColor(.white, for: .normal)
            contentMarket.backgroundColor = .black
            favouritesView.isHidden = true
        case .contentMarket:
            fetchContentMarketListing(false)
            favouritesView.isHidden = false
            myContent.backgroundColor = .black
            myContent.borderColor = .white
            myContent.setTitleColor(.white, for: .normal)
            contentMarket.borderColor = .white
            contentMarket.setTitleColor(.black, for: .normal)
            contentMarket.backgroundColor = .white
        }
        self.tableview.reloadData()
    }

    private func fetchContentMarketListing(_ showLoader: Bool = true){
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable {
            if showLoader { self.showLoader() }
            DIWebLayerContentMarket().getContentMarketListing { [weak self] contentListing in
                DispatchQueue.main.async {
                    self?.hideLoader()
                    let filteredContent = contentListing.filter { data in
                            return data.isBookMark ?? 0 == 1
                    }
                    self?.setFavouritesCount(count: filteredContent.count)
                    self?.contentMarketData = contentListing
                    self?.tableview.reloadData()
                }
            } failure: { error in
                self.hideLoader()
                print("error\(error)")
            }
        }else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
    
    private func myContentNavigation(index:Int){
        let tileType = myContentData[index].id ?? "1"
        let tile = TileType(rawValue: Int(tileType) ?? 1)

        switch tile {
        case .whatsNew:
            let selectedVC:NotificationsController = UIStoryboard(storyboard: .notification).initVC()
                selectedVC.updateNotificationsCountHandler = { [weak self] in
                    if let updateNotificationsCountHandler = self?.updateNotificationsCountHandler {
                        updateNotificationsCountHandler()
                    }
                }
            self.navigationController?.pushViewController(selectedVC, animated: true)
        case .foodTrek:
            let foodTrekListingVC:FoodTrekListingVC = UIStoryboard(storyboard: .foodTrek).initVC()
            self.navigationController?.pushViewController(foodTrekListingVC, animated: true)
        case .temTv:
            let selectedVC:TemTvViewController = UIStoryboard(storyboard: .temTv).initVC()
            self.navigationController?.pushViewController(selectedVC, animated: true)
        case .goalsAndChallenges:
            let selectedVC:ChallangeDashBoardController = UIStoryboard(storyboard: .challenge).initVC()
            self.navigationController?.pushViewController(selectedVC, animated: true)
        case .temStore:
            let selectedVC = loadVC(.ProductListingViewController) as! ProductListingViewController
            if let nav = UIApplication.topViewController()?.navigationController {
                NavigTO.navigateTo?.navigation = nav
                nav.pushViewController(selectedVC, animated: true)
            }
        case .contentMarket:
            selectedContent = .contentMarket
            setButtonsState(selectedContent: selectedContent)
            case .coachingTools:
                let journeyVC: MyJourneyViewController = UIStoryboard(storyboard: .coachingTools).initVC()
                self.navigationController?.pushViewController(journeyVC, animated: true)
            default:
                break
        }
    }

    private func contentMarketNavigation(indexPath: IndexPath){
        let affiliateDetails = getAffiliateDetails(indexPath: indexPath)
        let selectedVC:ContentMarketViewController = UIStoryboard(storyboard: .contentMarket).initVC()
        selectedVC.marketPlaceId = affiliateDetails.marketPlaceId
        selectedVC.affiliateId = affiliateDetails.affiliateId
        selectedVC.isPlanAdded = affiliateDetails.isPlanAdded
        self.navigationController?.pushViewController(selectedVC, animated: true)
    }

    private func pushToAffiliateLandingVC(indexPath: IndexPath){
        let affiliateDetails = self.getAffiliateDetails(indexPath: indexPath)
        let affiliateLandingVC: AffiliateLandingViewController = UIStoryboard(storyboard: .contentMarket).initVC()
        affiliateLandingVC.affiliateId = affiliateDetails.affiliateId
        affiliateLandingVC.marketPlaceId = affiliateDetails.marketPlaceId
        affiliateLandingVC.isPlanPurchased = false
        self.navigationController?.pushViewController(affiliateLandingVC, animated: true)
    }

    private func presentSearchBar(){
        if self.searchViewHeight.constant == searchViewHeightValue {
            return
        }
        self.searchBar.text = nil
        self.searchViewHeight.constant = self.searchViewHeight.constant + searchViewHeightValue
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    private func dismissSearchBar(){
        isSearchActive = false
        if self.searchViewHeight.constant == 0 {
            return
        }
        self.searchBar.resignFirstResponder()
        self.resetSearchList()
        self.reloadTable()
        self.searchViewHeight.constant = self.searchViewHeight.constant - searchViewHeightValue
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func reloadTable() {
        self.tableview.restore()
        self.tableview.reloadData()
    }

    //filter the search list array from the chat list on the basis of search text
    private func filterSearchListArray() {
        let filteredArray = self.contentMarketData?.filter({ (contentData) -> Bool in
            let name = contentData.title ?? ""
            let tags = contentData.tags

            let nameMatch = name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let tagsMatch = tags.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return nameMatch != nil || tagsMatch != nil
        })
        self.filteredContentList?.removeAll()
        if filteredArray != nil{
            self.filteredContentList?.append(contentsOf: filteredArray!)
        }
    }

    private func isConnectedToNetwork() -> Bool {
        if !Reachability.isConnectedToNetwork() {
            AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet, duration: 2.0) {
                print("alert displayed")
            }
            return false
        }
        return true
    }
    
    private func getFilteredBookmarkedContent(section: Int) -> [SeeAllModel] {
        if isSearchActive {
            if section == 0 {
                let bookMarkedContent = filteredContentList?.filter({return $0.isBookMark ?? 0 == 1})
                return bookMarkedContent ?? []
            } else {
                let notBookMarkedContent = filteredContentList?.filter({return $0.isBookMark ?? 1 == 0})
                return notBookMarkedContent ?? []
            }
        } else {
            if section == 0 {
                let bookMarkedContent = contentMarketData?.filter({return $0.isBookMark ?? 0 == 1})
                return bookMarkedContent ?? []
            } else {
                let notBookMarkedContent = contentMarketData?.filter({return $0.isBookMark ?? 1 == 0})
                return notBookMarkedContent ?? []
            }
        }
    }
    private func setFavouritesCount(count: Int) {
        let countText = count > 0 ? "\(count) SELECTED" : "NONE SELECTED"
        self.favouritesCountLbl.text = countText
    }
    
    private func addRemoveBookMark(isBookMark: Int, indexPath: IndexPath) {
        var marketplaceid: String = ""
        let content = self.getFilteredBookmarkedContent(section: indexPath.section)
        marketplaceid = content[indexPath.row].id ?? ""
        let successText = isBookMark == 0 ? "removed from" : "added to"
        let parameters: Parameters = [ "isBookMark": isBookMark,
                                       "marketplaceid": marketplaceid
        ]
        
        DIWebLayerContentMarket().addRemoveBookmark(parameter: parameters) { [weak self] msg in
            self?.fetchContentMarketListing()
            self?.showAlert(message: "Affiliate " + successText + " favourites successfully", okCall: {
                self?.tableview.reloadData()
            })
        } failure: { [weak self] error in
            if let error = error {
                self?.showAlert(withError: error)
            }
        }
    }
}

// MARK: Extensions
extension SeeAllVC:UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch selectedContent{
            case .myContent:
                return 1
            case .contentMarket:
                return 2
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedContent{
        case .myContent:
            return myContentData.count
        case .contentMarket:
            let content = self.getFilteredBookmarkedContent(section: section)
            return content.count
        }
    }
    func dataForIndex(_ indexPath:IndexPath) -> SeeAllModel? {
        switch selectedContent{
            case .myContent:
                return myContentData[indexPath.row]
            case .contentMarket:
                let content = self.getFilteredBookmarkedContent(section: indexPath.section)
                return content[indexPath.row]
        }
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch selectedContent{
        case .myContent:
                let cell = tableView.dequeueReusableCell(withIdentifier: SeeAllCellX.identifier, for: indexPath) as? SeeAllCellX
                cell?.selectionStyle = .none
                cell?.setData(dataForIndex(indexPath))
                return cell ?? UITableViewCell()
        case .contentMarket:
                let cell = tableView.dequeueReusableCell(withIdentifier: SeeAllCoachingCell.identifier, for: indexPath) as? SeeAllCoachingCell
                cell?.selectionStyle = .none
                cell?.setData(dataForIndex(indexPath), indexPath: indexPath)
                cell?.redirectMsg = {[weak self](indexSelected) in
                    self?.redirectToChatRoom(indexSelected)
                }
                cell?.profileRedirect = {[weak self](indexSelected) in
                    self?.redirectToProfile(indexSelected)
                }
                cell?.bookMarkHandler = { [weak self] (isBookMark, index) in
                    self?.addRemoveBookMark(isBookMark: isBookMark, indexPath: index)
                }
                return cell ?? UITableViewCell()
        }
    }
    func redirectToChatRoom(_ indexPath:IndexPath) {
        if let id = dataForIndex(indexPath)?.affiliateId {
            getProfileData(id) {
                DispatchQueue.main.async {
                    if let status = self.userProfile?.friendStatus, status == .blocked {
                        // You have been blocked by user
                        self.alertOpt("You have been blocked by this user")
                    } else {
                        self.openChatRoom(affiliateId: id)
                    }
                }
            }
        }
    }
    private func initiateChatRoom(chatRoomId: String) {
        let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        chatController.chatRoomId = chatRoomId
        chatController.chatName = self.userProfile?.fullName
        chatController.chatNotInitiatedWithAffiliate = true
        if let adminType = userProfile?.admintype, adminType != 1 {
            chatController.canAlwaysChat = true
        }
        if let url = URL(string: self.userProfile?.profilePic ?? ""){
            chatController.chatImageURL = url
        }else{
            chatController.chatImageURL = URL(string: "")
        }
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    private func openChatRoom(affiliateId: String){
        if let chatRoomId = self.userProfile?.chatRoomId,!chatRoomId.isEmpty {
            self.initiateChatRoom(chatRoomId: chatRoomId)
        } else {
            self.getAffiliateChatRoomId(affiliateId: affiliateId)
        }
    }

    private func getAffiliateChatRoomId(affiliateId: String) {
        DIWebLayerContentMarket().getAffiliateChatId(affiliateId: affiliateId) { chatRoomId in
            self.initiateChatRoom(chatRoomId: chatRoomId)
        } failure: { error in
            print(error.message ?? "")
        }
    }
    func redirectToProfile(_ indexPath:IndexPath) {
        if let id = dataForIndex(indexPath)?.affiliateId {
            getProfileData(id) {
                DispatchQueue.main.async {
                    self.openProfileVC(id)
                }
            }
        }
    }
    func openProfileVC(_ id:String?) {
        let controller: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        controller.otherUserId = id
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func getProfileData(_ id:String?,completion:OnlySuccess? = nil) {
        guard id != userProfile?.userId else { completion?(); return }
        showLoader()
        DIWebLayerProfileAPI().getProfileDetails(page: 1, userId: id ?? "", success: {[weak self] (_, user, _) in
            DispatchQueue.main.async {
                self?.hideLoader()
                self?.userProfile = user
                completion?()
            }
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedContent{
        case .myContent:
            myContentNavigation(index: indexPath.row)
        case .contentMarket:
            if dataForIndex(indexPath)?.isPlanPurchased ?? 0 == 0 && dataForIndex(indexPath)?.isPaid ?? 0 == 1{
                self.pushToAffiliateLandingVC(indexPath: indexPath)
            }else{
                contentMarketNavigation(indexPath: indexPath)
            }
        }
    }

    private func getAffiliateDetails(indexPath: IndexPath) -> (marketPlaceId:String, affiliateId:String, isPlanAdded:Int) {
        let data = dataForIndex(indexPath)
        let affiliateId = data?.affiliateId ?? ""
        let marketPlaceId = data?.id ?? ""
        let isPlanAdded = data?.isPaid ?? 0
        return (marketPlaceId,affiliateId,isPlanAdded)
    }
}

// MARK: - UISearchBarDelegate extension
extension SeeAllVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        guard self.chatList != nil else {return}
        if let currentText = searchBar.text {
            if !currentText.isEmpty {
                self.isSearchActive = true
                if self.filteredContentList == nil {
                    self.filteredContentList = []
                }
                self.searchText = searchText
                self.filterSearchListArray()
                self.reloadTable()
                if let filterList = self.filteredContentList,
                   filterList.isEmpty {
                    //if filter results are empty, show background view of table
                    self.tableview.showEmptyScreen("No Results")
                } else {
                    self.tableview.restore()
                }
            } else {
                self.resetSearchList()
                self.reloadTable()
            }
        }
    }

    func resetSearchList() {
        self.isSearchActive = false
        self.searchText = ""
        self.filteredContentList?.removeAll()
        self.tableview.restore()
    }
}
