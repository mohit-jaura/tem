//
//  SelectFriendViewController.swift
//  TemApp
//
//  Created by shilpa on 23/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class SelectFriendViewController: DIBaseController {
    
    // MARK: Properties
    private var friends: [Friends]?
    var networkManager = NetworkConnectionManager()
    var page = 1
    var refreshControl: UIRefreshControl?
    let minimumSearchTextLength = 3
    private var chatList: [ChatRoom]?
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newGroupView: UIView!
    
    @IBOutlet weak var searchBarShadowView:SSNeumorphicView!{
        didSet{
            searchBarShadowView.viewDepthType = .innerShadow
            searchBarShadowView.viewNeumorphicMainColor =  UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
            searchBarShadowView.viewNeumorphicLightShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor
            searchBarShadowView.viewNeumorphicDarkShadowColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
            searchBarShadowView.viewNeumorphicCornerRadius = 4
            searchBarShadowView.viewNeumorphicShadowRadius = 0.5
            searchBarShadowView.viewNeumorphicShadowOpacity = 0.25
            searchBarShadowView.viewNeumorphicShadowOffset = CGSize(width: 0, height: 0.5 )
        }
    }
    
    @IBOutlet weak var searchBarOuterShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: searchBarOuterShadowView, shadowType: .outerShadow, cornerRadius: 0, shadowRadius: 2)
        }
    }
    
    @IBOutlet weak var clearButton:SSNeumorphicButton!{
        didSet{
            clearButton.btnNeumorphicCornerRadius = clearButton.frame.width / 2
            clearButton.btnNeumorphicShadowRadius = 0.8
            clearButton.btnDepthType = .outerShadow
            clearButton.btnNeumorphicLayerMainColor = UIColor.white.cgColor
            clearButton.btnNeumorphicShadowOpacity = 0.25
            clearButton.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.7)
            clearButton.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            clearButton.btnNeumorphicLightShadowColor = UIColor.black.cgColor
        }
    }
    
    // MARK: IBActions
    @IBAction func newGroupTapped(_ sender: UIButton) {
        let createGroupVC: CreateGroupViewController = UIStoryboard(storyboard: .chat).initVC()
        self.navigationController?.pushViewController(createGroupVC, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonTapped(_ sender:SSNeumorphicButton){
        
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    private func initUI() {
        self.tableView.backgroundColor = UIColor.clear
        self.setSearchBarApperance()
        self.addPagination()
        self.addPullToRefresh()
        self.tableView.showAnimatedSkeleton()
        self.getFriendsListing()
        self.getTemsListing(searchText: nil)
    }
    
    private func setSearchBarApperance(){
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        self.searchBar.backgroundColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
        searchBar.barTintColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
        searchBar.layer.cornerRadius = 6
        if #available(iOS 13, *) {
            self.searchBar.searchTextField.backgroundColor = UIColor.clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: Configure Navigation Bar
    private func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName:Constant.ScreenFrom.selectFriend.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.clear, translucent: true)
    }
    
    // MARK: Add Pagination
    private func addPagination() {
        self.tableView.infiniteScrolling(self) {[weak self] in
            if let wkSelf = self {
                wkSelf.page += 1
                if let searchText = self?.searchBar.text,
                   !searchText.isEmpty {
                    //if there is search text, fetch the list with search
                    self?.getFriendListWithSearch(text: searchText)
                } else {
                    self?.getFriendsListing()
                }
            }
        }
    }
    
    // MARK: Add pull to refresh
    private func addPullToRefresh() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl?.tintColor = appThemeColor
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func onPullToRefresh(sender: UIRefreshControl) {
        self.page = 1
        if let searchText = self.searchBar.text,
           !searchText.isEmpty {
            //if there is search text, fetch the list with search
            self.getFriendListWithSearch(text: searchText)
        } else {
            self.getFriendsListing()
        }
    }
    
    // MARK: Api call
    private func getFriendsListing() {
        guard Reachability.isConnectedToNetwork() else {
            self.showErrorOnView(error: AppMessages.AlertTitles.noInternet)
            return
        }
        
        networkManager.getFriendList(pageNo: page, parameters: nil, success: {[weak self] (friends, count) in
            DispatchQueue.main.async {
                self?.setDataSource(data: friends)
            }
        }) {[weak self] (error) in
            self?.showErrorOnView(error: error.message)
        }
    }
    
    func getTemsListing(searchText: String?) {
        self.showLoader()
        guard Reachability.isConnectedToNetwork() else {
            self.showErrorOnView(error: AppMessages.AlertTitles.noInternet)
            return
        }
        let subdomain = Constant.SubDomain.getChatListing
        DIWebLayerChatApi().getChatList(searchString: searchText, type: 2, subdomain: subdomain, completion: {[weak self] (chatList) in
            self?.hideLoader()
            if let list = chatList {
                DispatchQueue.main.async {
                    self?.setDataSourceWith(data: list)
                }
            } else {
                DispatchQueue.main.async {
                    self?.tableView.hideSkeleton()
                }
            }
        }) {[weak self] (error) in
            self?.showErrorOnView(error: error.message ?? "")
        }
    }
    
    /// call this function to set the data source from the api response
    ///
    /// - Parameter data: friends data
    func setDataSource(data: [Friends]) {
        if self.friends == nil {
            self.friends = [Friends]()
        }
        if self.page == 1 {
            self.friends?.removeAll()
        }
        self.friends?.append(contentsOf: data)
        self.refreshControl?.endRefreshing()
        self.tableView.hideSkeleton()
        self.tableView.stopSkeletonAnimation()
        self.tableView.endPull2RefreshAndInfiniteScrolling(count: data.count)
        if self.friends == nil || self.friends?.count == 0 {
            //if there was no data, show tableview background view
            self.newGroupView.isHidden = true
        } else {
            self.newGroupView.isHidden = false
        }
        self.tableView.reloadData()
    }
    
    private func setDataSourceWith(data: [ChatRoom]) {
        if self.chatList == nil {
            self.chatList = [ChatRoom]()
        }
        self.chatList?.removeAll()
        self.chatList?.append(contentsOf: data)
        self.refreshControl?.endRefreshing()
        self.tableView.hideSkeleton()
        self.tableView.stopSkeletonAnimation()
        self.tableView.endPull2RefreshAndInfiniteScrolling(count: data.count)
        if self.chatList == nil || self.chatList?.count == 0 {
            //if there was no data, show tableview background view
            self.newGroupView.isHidden = true
        } else {
            self.newGroupView.isHidden = false
        }
        self.tableView.reloadData()
    }
    
    /// present the error on screen to the user, in case of any error in fetching the data from the server
    ///
    /// - Parameter error: error log
    func showErrorOnView(error: String?) {
        //decrement page number value
        if self.page != 1 {
            self.page -= 1
        }
        self.tableView.hideSkeleton()
        self.tableView.endPull2RefreshAndInfiniteScrolling(count: 0)
        tableView.endRefreshing()
        if self.friends == nil || self.friends?.count == 0 {
            //if there was no data, show tableview background view
            self.tableView.showEmptyScreen(error ?? "Error in fetching data")
        } else {
            //show alert pop up to the user
            self.showAlert(message: error ?? "Error in fetching data")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    /// get friend list from search text
    ///
    /// - Parameter text: search string
    func getFriendListWithSearch(text: String) {
        if !Reachability.isConnectedToNetwork() {
            self.showErrorOnView(error: AppMessages.AlertTitles.noInternet)
            return
        }
        networkManager.getFriendListFromSearch(text: text, parameters: nil, pageNo: self.page, success: {[weak self] (data, count)
            in
            DispatchQueue.main.async {
                self?.setDataSource(data: data)
            }
        }) { (error) in
            self.showErrorOnView(error: error.message)
        }
    }
    
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
}

// MARK: UITableViewDataSource
extension SelectFriendViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.friends?.count ?? 0
        }
        else{
            return self.chatList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectFriendForChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: SelectFriendForChatTableViewCell.reuseIdentifier, for: indexPath) as! SelectFriendForChatTableViewCell
        if indexPath.section == 0{
            cell.setData(friend: self.friends?[indexPath.row], atIndexPath: indexPath)
        }
        else{
            cell.setTemsData(tem: self.chatList?[indexPath.row], atIndexPath: indexPath)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension SelectFriendViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            //select friend and push to chat screen
            guard let chatRoomId = self.friends?[indexPath.row].chatRoomId else {
                return
            }
            let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
            chatController.chatRoomId = chatRoomId
            chatController.chatName = self.friends?[indexPath.row].fullName
            if let url = URL(string: self.friends?[indexPath.row].profilePic ?? ""){
                chatController.chatImageURL = url
            }
            self.navigationController?.pushViewController(chatController, animated: true)
        }
        else{
            //select tem and push to chat screen
            guard let chatRoomId = self.chatList?[indexPath.row].chatRoomId else {
                return
            }
            let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
            chatController.chatRoomId = chatRoomId
            chatController.chatName = self.chatList?[indexPath.row].name
            if let url = URL(string: self.chatList?[indexPath.row].icon ?? ""){
                chatController.chatImageURL = url
            }
            self.navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            if self.friends?.count ?? 0 > 0{
                return "TĒMATES"
            }else{
                return AppMessages.NetworkMessages.noFriendsYet
            }
        }
        else{
            if self.chatList?.count ?? 0 > 0{
                return "TĒMS"
            }else{
                return AppMessages.NetworkMessages.noTemsYet
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SelectFriendForChatTableViewCell {
            if indexPath.section == 0{
                if indexPath.row == 0 {
                    if let friends = self.friends {
                        if friends.count == 1 {
                            //if there is a single row, then round the bottom corners also
                            cell.contentView.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
                        } else {
                            cell.contentView.roundCorners([.topLeft, .topRight], radius: 10.0)
                        }
                    }
                } else {
                    if let friends = self.friends,
                       indexPath.row == friends.count - 1 {
                        cell.contentView.roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
                    } else {
                        cell.contentView.roundCorners([], radius: 0)
                    }
                }
            }else{
                if indexPath.row == 0 {
                    if let friends = self.chatList {
                        if friends.count == 1 {
                            //if there is a single row, then round the bottom corners also
                            cell.contentView.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
                        } else {
                            cell.contentView.roundCorners([.topLeft, .topRight], radius: 10.0)
                        }
                    }
                } else {
                    if let friends = self.chatList,
                       indexPath.row == friends.count - 1 {
                        cell.contentView.roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
                    } else {
                        cell.contentView.roundCorners([], radius: 0)
                    }
                }
            }
        }
    }
}

// MARK: SkeletonTableViewDataSource
extension SelectFriendViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SelectFriendForChatTableViewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 5
        }
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 2
    }
}

// MARK: UISearchBarDelegate
extension SelectFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= self.minimumSearchTextLength {
                //start search only on minimum 3 characters
                self.page = 1
                self.getFriendListWithSearch(text: searchText)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let currentText = searchBar.text {
            if currentText.isEmpty || currentText.count >= self.minimumSearchTextLength {
                self.page = 1
                self.getFriendListWithSearch(text: searchBar.text ?? "")
            }
        }
    }
}
