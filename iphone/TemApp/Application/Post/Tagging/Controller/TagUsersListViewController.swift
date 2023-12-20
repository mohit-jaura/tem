//
//  TagUsersListViewController.swift
//  TemApp
//
//  Created by shilpa on 17/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

enum TagUserType: Int, CaseIterable{
    case allUsers = 1
    case singleUser = 0
}

enum TagUsersListType {
    case pictureTagging, postCaptionTagging, commentTagging, groupChatTagging, challengeChatTagging, goalChatTagging
}

protocol TagUsersListViewDelegate: AnyObject {
    func didSelectUserFromTagList(tagText: String, userId: String) //tagText: userName of the user
    func updateAttributedTextOnTagSelect(attributedValue: (NSMutableAttributedString, NSRange))
    func didChangeTaggableList(isEmpty: Bool)
    func didChangeTaggedList(taggedList: [TaggingModel])
    func didChangeTagListingTableContentSize(newSize: CGFloat)
    func didSelectUserToTag(user: Friends)
    func loadedSearchResultsForPictureTagging()
}

extension TagUsersListViewDelegate {
    func didChangeTagListingTableContentSize(newSize: CGFloat) {}
    func didSelectUserToTag(user: Friends) {}
    func didSelectUserFromTagList(tagText: String, userId: String) {} //tagText: userName of the user
    func updateAttributedTextOnTagSelect(attributedValue: (NSMutableAttributedString, NSRange)) {}
    func didChangeTaggableList(isEmpty: Bool) {}
    func didChangeTaggedList(taggedList: [TaggingModel]) {}
    func loadedSearchResultsForPictureTagging() {}
}

class TagUsersListViewController: DIBaseController {

    // MARK: Properties
    weak var delegate: TagUsersListViewDelegate?
    var listType: TagUsersListType = .pictureTagging
    var id: String? //this will be chatId for group chat tagging, postId for comment tagging etc.
    private let networkLayer = DIWebLayerTagging()
    private var searchText: String?
    var screenFrom: Constant.ScreenFrom = .createGoal

    private var matchedList: [Friends] = [] {
        didSet {
            taggableTableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    
    private var taggedList: [TaggingModel] = [] {
        didSet {}
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var taggableTableView: UITableView! {
        didSet {
            taggableTableView.dataSource = self
            taggableTableView.delegate = self
            taggableTableView.registerNibs(nibNames: [TaggedUserTableViewCell.reuseIdentifier, AllTaggedUserTableViewCell.reuseIdentifier])
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpInitialView()
        self.initialTagSetup()
    }
    
    // MARK:  Helpers
    private func setUpInitialView() {
        self.view.isHidden = false
        if self.listType == .pictureTagging {
            taggableTableView.keyboardDismissMode = .onDrag
            self.lineView.isHidden = true
            //hit api to get the listing initially
            self.searchUsers(searchText: "") {[weak self] (finished) in
                self?.getSuggestions()
            }
        }
    }
    
    private func initialTagSetup() {
//        Tagging.sharedInstance.symbolAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),
//                                                    convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.init(name: UIFont.robotoMedium, size: 15.0) as Any]
        
        switch self.listType {
        case .pictureTagging:
            self.taggableTableView.isHidden = false
        case .groupChatTagging, .challengeChatTagging, .goalChatTagging:
            self.setTaggingDataSource()
            self.taggableTableView.isHidden = true
            self.taggableTableView.backgroundColor = UIColor.clear
            self.view.backgroundColor = UIColor.clear
        case .commentTagging:
            self.setTaggingDataSource()
            self.taggableTableView.isHidden = true
            self.view.backgroundColor = .newAppThemeColor
            self.taggableTableView.backgroundColor = .newAppThemeColor
        default:
            self.setTaggingDataSource()
            self.taggableTableView.isHidden = true
            self.view.backgroundColor = UIColor.clear
        }
    }
    
    func setTaggingDataSource() {
        Tagging.sharedInstance.dataSource = self
        self.resetTagList()
    }
    
    func resetTagList() {
        Tagging.sharedInstance.tagableList = [String]()
        Tagging.sharedInstance.taggedList = []
    }
    
    func removePreviousMatches() {
        if !self.matchedList.isEmpty {
            matchedList.removeAll()
            self.taggableTableView.reloadData()
        }
    }
    
    func setTableViewVisibility(shouldHide: Bool) {
        self.taggableTableView.isHidden = shouldHide
        self.delegate?.didChangeTaggableList(isEmpty: shouldHide)
    }
    
    private func reloadList() {
        /*switch self.listType {
        case .groupChatTagging:
            self.taggableTableView.renderObjectsFromBottom()
        default:
            self.taggableTableView.reloadData()
        } */
        DispatchQueue.main.async {
            self.taggableTableView.setContentOffset(CGPoint.zero, animated: false)
            self.taggableTableView.reloadData()
        }
    }
    
    // MARK: Api Calls
    @objc private func getUsers(searchText: String) {
        switch self.listType {
        case .groupChatTagging:
            self.getGroupChatMembers(searchText: searchText)
        case .challengeChatTagging, .goalChatTagging:
            self.getGroupActivityChatMembers(searchText: searchText)
        default:
            self.searchUsers(searchText: searchText, completion: nil)
        }
    }
    
    private func searchUsers(searchText: String, completion: ((_ finished: Bool) -> Void)?) {
        self.searchText = searchText
        networkLayer.searchUsersForTagging(searchText: searchText, completion: {[weak self] (members) in
            if let wkSelf = self {
                wkSelf.searchText = nil
                wkSelf.matchedList = members
                if wkSelf.listType == .pictureTagging {
                    self?.delegate?.loadedSearchResultsForPictureTagging()
                }
                if !wkSelf.matchedList.isEmpty {
                    wkSelf.setTableViewVisibility(shouldHide: false)
                } else {
                    if wkSelf.listType == .pictureTagging {
                        if let completionBlock = completion {
                            //if matched list is empty
                            if wkSelf.matchedList.isEmpty {
                                completionBlock(true)
                            }
                        }
                    }
                }
                wkSelf.reloadList()
            }
        }) { (error) in
            if self.listType == .pictureTagging {
                self.delegate?.loadedSearchResultsForPictureTagging()
                if self.matchedList.isEmpty {
                    self.taggableTableView.showEmptyScreen(error.message ?? "")
                }
            }
        }
    }
    
    private func getGroupChatMembers(searchText: String) {
        guard let chatRoomId = self.id else {
            return
        }
        networkLayer.fetchChatGroupMembersForTagging(groupId: chatRoomId, searchString: searchText, completion: {[weak self] (members) in
            if let wkSelf = self {
                wkSelf.matchedList = members
                if !wkSelf.matchedList.isEmpty {
                    wkSelf.setTableViewVisibility(shouldHide: false)
                }
                wkSelf.reloadList()
            }
        }) { (_) in
            // error handling
        }
    }
    
    private func getGroupActivityChatMembers(searchText: String) {
        guard let chatRoomId = self.id else {
            return
        }
        networkLayer.fetchActivityMembersForTagging(taggingType: self.listType, groupId: chatRoomId, searchString: searchText, completion: {[weak self] (members) in
            if let wkSelf = self {
                wkSelf.matchedList = members
                if !wkSelf.matchedList.isEmpty {
                    wkSelf.setTableViewVisibility(shouldHide: false)
                }
                wkSelf.reloadList()
            }
        }) { (_) in
            
        }
    }
    
    private func getSuggestions() {
        DIWebLayerNetworkAPI().getSuggestedFriends(parameters: nil, page: "", success: { (friends) in
            self.matchedList = friends
            if !self.matchedList.isEmpty {
                self.setTableViewVisibility(shouldHide: false)
            }
            self.reloadList()
        }) { (_) in
            
        }
    }
    
    private func updateUserTagList(newUser: Friends) {
        if isConnectedToNetwork() {
            var userTag = UserTag()
            userTag.id = newUser.user_id
            userTag.text = newUser.fullName.replace(" ", replacement: "")
            networkLayer.updateUserTagList(parameters: userTag.json())
        }
    }
}

// MARK: UITableViewDataSource
extension TagUsersListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if screenFrom == .newsFeeds{
           return 1// return TagUserType.singleUser.rawValue
        } else if screenFrom == .chat{
            return TagUserType.allCases.count
        }
       return 1

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = TagUserType(rawValue: section)
        switch currentSection {
        case .allUsers:
            return 1
        case .singleUser:
            return self.matchedList.count
        case .none:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = TagUserType(rawValue: indexPath.section)
        switch currentSection {
        case .allUsers:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AllTaggedUserTableViewCell.reuseIdentifier, for: indexPath) as? AllTaggedUserTableViewCell else{
                return UITableViewCell()

            }
            switch listType{
            case.commentTagging:
                cell.contentView.backgroundColor = .newAppThemeColor
                cell.allLbl.textColor = .white
            default:
                break
            }
            return cell
        case .singleUser:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaggedUserTableViewCell.reuseIdentifier, for: indexPath) as? TaggedUserTableViewCell else {
                return UITableViewCell()
            }
            cell.initialize(user: self.matchedList[indexPath.row], currentSection: indexPath.section, row: indexPath.row, listType: self.listType)
            cell.lineView.isHidden = true
            return cell
        case .none:
            break
        }
        return UITableViewCell()
   }
}

// MARK: UITableViewDelegate
extension TagUsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.listType {
        case .pictureTagging:
            if indexPath.row < self.matchedList.count {
                self.updateUserTagList(newUser: matchedList[indexPath.row])
                self.delegate?.didSelectUserToTag(user: matchedList[indexPath.row])
            }
        default:
            
           let currentSection = TagUserType(rawValue: indexPath.section)
            switch currentSection{
                
            case .allUsers:
            
                for id in 0 ... matchedList.count - 1{
                    self.delegate?.didSelectUserFromTagList(tagText: "all", userId:  matchedList[id].user_id ?? "")
                }
             
                self.matchedList.removeAll()
                self.setTableViewVisibility(shouldHide: true)
            case .singleUser:
                let fullName = matchedList[indexPath.row].fullName.replacingOccurrences(of: " ", with: "")
                self.delegate?.didSelectUserFromTagList(tagText: fullName, userId: matchedList[indexPath.row].user_id ?? "")
                self.matchedList.removeAll()
                //tableView.deselectRow(at: indexPath, animated: true)
                self.setTableViewVisibility(shouldHide: true)
            case .none:
                break
            }
      
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.delegate?.didChangeTagListingTableContentSize(newSize: tableView.contentSize.height)
    }
}

// MARK: TaggingDataSource
extension TagUsersListViewController: TaggingDataSource {
    func tagging(searchUser: String) {
        let searchFor = searchUser.replace(Tagging.sharedInstance.symbol, replacement: "")
        if searchFor.isBlank == false {
            // hit api now after canceling all previous schedule task
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.getUsers(searchText:)), with: searchFor, afterDelay: 0.5)
        }else{
            if self.listType == .groupChatTagging || listType == .challengeChatTagging || listType == .goalChatTagging {
                //if just the '@' character is typed, then show all the results
                // hit api now after canceling all previous schedule task
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                self.perform(#selector(self.getUsers(searchText:)), with: searchFor, afterDelay: 0.5)
                return
            }
            if self.listType == .pictureTagging {
                self.delegate?.loadedSearchResultsForPictureTagging()
            }
            self.matchedList.removeAll()
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.setTableViewVisibility(shouldHide: true)
        }
    }
    
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String]) {
        if tagableList.count == 0 {
            self.setTableViewVisibility(shouldHide: true)
        }else{
            self.reloadList()
            self.setTableViewVisibility(shouldHide: false)
        }
    }
    
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel]) {
        self.taggedList = taggedList
        //DILog.print(items: "tagged list: ===========> \(self.taggedList)")
        if taggedList.isEmpty {
            self.setTableViewVisibility(shouldHide: true)
        } else {
            //self.setTableViewVisibility(shouldHide: false)
        }
        self.delegate?.didChangeTaggedList(taggedList: self.taggedList)
    }
    
    func tagging(_ tagged: (NSMutableAttributedString, NSRange)) {
        //update text view text on tag made
        self.delegate?.updateAttributedTextOnTagSelect(attributedValue: tagged)
    }
}
