//
//  AffiliateTemListingViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 12/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class AffiliateTemListingViewController: DIBaseController {
    
    enum TemsType: Int {
        case our = 0, `public`
    }
    // MARK: IBOutlets
    @IBOutlet weak var navigationBarLineView: SSNeumorphicView! {
        didSet{
            navigationBarLineView.viewDepthType = .innerShadow
            navigationBarLineView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            navigationBarLineView.viewNeumorphicLightShadowColor = UIColor.appThemeDarkGrayColor.cgColor
            navigationBarLineView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
            navigationBarLineView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var myTemsBackView: SSNeumorphicView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChatsMessageLabel: UILabel!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var ourTemsBtn: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var publicTemsBtn: UIButton!
    @IBOutlet var buttonsBackViews: [SSNeumorphicView]!
    @IBOutlet var buttonsContainerViews: [UIView]!
    // MARK: Properties
    private var chatList: [ChatRoom]?
    private var filteredChatList: [ChatRoom]?
    private var isSearchActive = false
    private var searchText = ""
    private var searchViewHeightValue: CGFloat = 50.0
    var affiliateId = ""
    var groups:[ChatRoom] = [ChatRoom]()
    var screenSelection: TemsType = .our
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        myTemsBackView.setOuterDarkShadow()
        myTemsBackView.viewNeumorphicCornerRadius = myTemsBackView.frame.height / 2
        myTemsBackView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        backButton.addDoubleShadowToButton(cornerRadius: searchButton.frame.height / 2, shadowRadius: searchButton.frame.height / 2, lightShadowColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), darkShadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3), shadowBackgroundColor: UIColor.appThemeDarkGrayColor)
        setViewState(selectedType: .our)
    }
    
    // MARK: IBActions
    @IBAction func dismissSearchBar(_ sender: UIButton) {
        //dismiss the search bar
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func publicTemsTapped(_ sender: UIButton) {
        setViewState(selectedType: .public)
    }
    @IBAction func ourTemsTapped(_ sender: UIButton) {
        setViewState(selectedType: .our)
    }
    
    @IBAction func newTemButtonTapped(_ sender: UIButton) {
        getMyTemsListing()
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        if self.searchViewHeight.constant == searchViewHeightValue {
            return
        }
        self.searchBar.text = nil
        self.searchViewHeight.constant = self.searchViewHeight.constant + searchViewHeightValue
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Methods
    private func getDataFromAPI() {
        self.showLoader()
        switch screenSelection {
            case .our:
                getAffiliateTems()
            case .public:
                getPublicTems()
        }
    }
    private func setViewState(selectedType: TemsType) {
        screenSelection = selectedType
        setContainerViews()
        setShadowView()
        getDataFromAPI()
    }
    private func setContainerViews() {
        for view in buttonsContainerViews {
            view.cornerRadius = view.frame.height / 2
            if view.tag == screenSelection.rawValue {
                view.backgroundColor = UIColor(rgb: (11, 130, 220))
            } else {
                view.backgroundColor = UIColor.appThemeDarkGrayColor
            }
        }
    }
    private func setShadowView() {
        for view in buttonsBackViews {
            view.setOuterDarkShadow()
            view.viewDepthType = .innerShadow
            view.viewNeumorphicCornerRadius = view.frame.height / 2
            if view.tag == screenSelection.rawValue {
                view.viewNeumorphicMainColor = UIColor(rgb: (11, 130, 220)).cgColor
            } else {
                view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            }
        }
    }

    func getMyTemsListing() {
        let temsVC: ChatListingViewController = UIStoryboard(storyboard: .chatListing).initVC()
        temsVC.screenFrom = .affiliativeContent
        temsVC.chatType = ChatType.groupChat.rawValue
        self.navigationController?.pushViewController(temsVC, animated: true)
    }
    func getAffiliateTems(){
        DIWebLayerChatApi().getAffiliateGroupsList(id: affiliateId, completion: {members in
            self.hideLoader()
            self.groups = members
            self.tableView.reloadData()
        }, failure: { _ in
        })
    }
    func getPublicTems(){
        DIWebLayerChatApi().getPublicGroupsList(completion: {members in
            self.hideLoader()
            self.groups = members
            self.tableView.reloadData()
        }, failure: { _ in
        })
    }
    //filter the search list array from the chat list on the basis of search text
    private func filterSearchListArray() {
        let filteredArray = self.chatList?.filter({ (chatInfo) -> Bool in
            let name = chatInfo.name ?? ""
            return name.containsIgnoringCase(other: searchText)
        })
        self.filteredChatList?.removeAll()
        if let arr = filteredArray {
            self.filteredChatList?.append(contentsOf: arr)
        }
    }
    
    private func reloadTable() {
        self.tableView.restore()
        self.tableView.reloadData()
    }
    
    private func chatListArray() -> [ChatRoom]? {
        if isSearchActive {
            return self.filteredChatList
        } else {
            return self.chatList
        }
    }
}

// MARK: Extensions

// MARK: UITableViewDataSource
extension AffiliateTemListingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AffiliateTemListingTableViewCell.reuseIdentifier, for: indexPath) as! AffiliateTemListingTableViewCell
        cell.delegate = self
        cell.setDataForAffiliateTems(group:self.groups[indexPath.row],indexPath:indexPath.row)
        cell.joinButton.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = groups[indexPath.row]
        let vc: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        vc.chatRoomId = chat.chatRoomId ?? ""
        vc.chatName = chat.name ?? ""
        if let image = chat.icon, let url = URL(string: image) {
            vc.chatImageURL = url
        }
        vc.joinHandler = { [weak self] result in
            if result {
                self?.setViewState(selectedType: .our)
            }else{
                self?.setViewState(selectedType: .public)
            }
            self?.tableView.reloadData()
        }
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UISearchBarDelegate
extension AffiliateTemListingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.chatList != nil else {return}
        if let currentText = searchBar.text {
            if !currentText.isEmpty {
                self.isSearchActive = true
                
                if self.filteredChatList == nil {
                    self.filteredChatList = []
                }
                self.searchText = searchText
                self.filterSearchListArray()
                self.reloadTable()
                if let filterList = self.filteredChatList,
                   filterList.isEmpty {
                    //if filter results are empty, show background view of table
                    self.tableView.showEmptyScreen("No Results")
                } else {
                    self.tableView.restore()
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
        self.filteredChatList?.removeAll()
        self.tableView.restore()
    }
}
// MARK: AffiliateTemListingTableViewCellDelegate
extension AffiliateTemListingViewController:AffiliateTemListingTableViewCellDelegate{
    func didTapOnJoinButton(indexPath: Int) {
        ChatViewController().joinGroupApiCall(groupId: self.groups[indexPath].groupId ?? "", isFromContentMarket: true)
        getDataFromAPI()
        tableView.reloadData()
    }
}
