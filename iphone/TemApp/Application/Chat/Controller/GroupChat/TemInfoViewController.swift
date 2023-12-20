//
//  TemInfoViewController.swift
//  TemApp
//
//  Created by shilpa on 12/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

enum TemInfoSection: Int, CaseIterable {
    case temInfo = 0, temMembers
}

enum TemInfoRow: Int, CaseIterable {
    case groupIcon = 0, name, admin, groupType, interest, temates, desc
    
    var title: String {
        switch self {
        case .groupIcon:
            return ""
        case .name:
            return "NAME".localized
        case .admin:
            return "GROUP ADMIN".localized
        case .groupType:
            return "GROUP VISIBILITY".localized
        case .interest:
            return "INTEREST".localized
        case .temates:
            return "TĒMATES".localized
        case .desc:
            return "DESCRIPTION".localized
        }
    }
}

class TemInfoViewController: DIBaseController {
    
    // MARK: Variables.
    var selectedFriends:[Friends]?
    private var temMembers: [Friends]?
    private var searchedTemMembers: [Friends]?
    private var isSearchActive = false
    private var isSearchFieldEditing = false //true when user taps on search field to search something, false when the
    private let chatNetworkLayer = DIWebLayerChatApi()
    private var searchText = ""
    var currentPage = 1
    var lastPage = 1
    var groupInfo: ChatRoom?
    var actionSheet: CustomBottomSheet?
    private var membersLoadingFromStart = true // this will be used to display footer below the tem info section until the members are loaded from the server
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var navBarShadowView:SSNeumorphicView!{
        didSet{
            navBarShadowView.viewDepthType = .innerShadow
            navBarShadowView.viewNeumorphicMainColor = #colorLiteral(red: 0.9882352948, green: 0.988235414, blue: 0.9882352948, alpha: 1)
            navBarShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            navBarShadowView.viewNeumorphicDarkShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
            navBarShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editTapped(_ sender: UIButton) {
        editGroupInfoRightBarButtonTapped()
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createUserExperience()
        self.getMembersList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setDefaultNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureRightBarButtonForGroupType()
    }
    
    // MARK: Initializer
    private func createUserExperience() {
        self.tableView.estimatedSectionHeaderHeight = 55.0
        self.tableView.registerHeaderFooter(nibNames: [ChatSearchHeaderTableCell.reuseIdentifier])
        self.tableView.registerNibs(nibNames: [GroupImageHeaderTableViewCell.reuseIdentifier])
    }
    
    //configure the navigation bar and its properties
    private func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        leftBarButtonItem.tintColor = UIColor.textBlackColor
        self.setNavigationController(titleName: Constant.ScreenFrom.temInfo.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
    }
    
    private func configureRightBarButtonForGroupType() {
        /*
         for open group: any of the member can edit the group information
         for closed group: only the admin can edit the group information
         for the group the user is not part of, edit option will not be available
        */
        if groupInfo?.groupChatStatus == .active {
            if groupInfo?.editableByMembers == true || groupInfo?.admin?.userId == UserManager.getCurrentUser()?.id {
                editImage.isHidden = false
                editButton.isHidden = false
                return
            }
        }
        editImage.isHidden = true
        editButton.isHidden = true
    }
    
     private func editGroupInfoRightBarButtonTapped() {
        guard let groupInfo = self.groupInfo else {
            return
        }
        let editGroupVC: CreateGroupViewController = UIStoryboard(storyboard: .chat).initVC()
        editGroupVC.delegate = self
        editGroupVC.screenFrom = .editGroup
        if let chatRoomCopy = groupInfo.copy() as? ChatRoom {
            editGroupVC.chatGroup = chatRoomCopy
        }
        self.navigationController?.pushViewController(editGroupVC, animated: true)
    }
    
    // MARK: Api Call
    private func addGroupParticipants() {
        let params = self.groupInfo?.editParticipantsJson().json()
        self.chatNetworkLayer.editGroup(params: params, completion: {[weak self] (finished) in
            self?.updateNewMembersChatStatusInRoom()
            self?.updateMembersInChatRoom()
            self?.getMembersList()
        }) {[weak self] (error) in
            self?.hideLoader()
            if let msg = error.message {
                self?.showAlert(message: msg)
            }
        }
    }
    
    private func getMembersList() {
        guard let groupId = self.groupInfo?.groupId else {
            return
        }
        self.chatNetworkLayer.getChatGroupMembersList(groupId: groupId, completion: {[weak self] (friends) in
            self?.setDataSource(data: friends)
            self?.hideLoader()
        }) {[weak self] (error) in
            self?.hideLoader()
            if let msg = error.message {
                self?.showAlert(message: msg)
            }
        }
    }
    
    // setting the screen data to display
    private func setDataSource(data: [Friends]) {
        if self.temMembers == nil {
            self.temMembers = []
        }
        self.temMembers?.removeAll()
        self.groupInfo?.memberIds?.removeAll()
        let ids = data.map({$0.user_id ?? ""})
        self.groupInfo?.memberIds = []
        self.groupInfo?.memberIds?.append(contentsOf: ids)
        self.groupInfo?.membersCount = data.count
        self.temMembers?.append(contentsOf: data)
        self.membersLoadingFromStart = false
        self.tableView.tableFooterView = nil
        self.tableView.reloadData()
    }
    
    /// api call to remove the participant from this group
    private func removeMemberFromGroup(atIndex index: Int) {
        if self.isConnectedToNetwork(),
            let memberId = self.membersArray()?[index].user_id {
            self.showLoader()
            let params = self.groupInfo?.actionOnMemberApiJson(memberId: memberId, status: .delete)
            self.chatNetworkLayer.deleteGroupMember(params: params, completion: {[weak self] (finished) in
                self?.hideLoader()
                //remove value at this index from array both from the searched array list and the main list array
                self?.updateDataSourceOnRemovingMember(index: index)
                if let membersCount = self?.groupInfo?.membersCount {
                    self?.groupInfo?.membersCount = membersCount - 1
                }
                ChatManager().updateUserGroupChatStatusInChatRoom(roomId: self?.groupInfo?.chatRoomId ?? "", userId: memberId, status: .notPartOfGroup)
                self?.updateMembersInChatRoom()
                self?.tableView.reloadData()
            }) {[weak self] (error) in
                self?.hideLoader()
                if let msg = error.message {
                    self?.showAlert(message: msg)
                }
            }
        }
    }
    
    /// api call to change the group admin
    private func changeGroupAdmin(atIndex index: Int) {
        if self.isConnectedToNetwork(),
            let memberId = self.membersArray()?[index].user_id {
            self.showLoader()
            let params = self.groupInfo?.actionOnMemberApiJson(memberId: memberId, status: nil)
            self.chatNetworkLayer.makeGroupAdmin(params: params, completion: {[weak self] (finished) in
                self?.hideLoader()
                self?.groupInfo?.admin?.userId = memberId
                self?.configureRightBarButtonForGroupType()
                self?.tableView.reloadData()
            }) {[weak self] (error) in
                self?.hideLoader()
                if let msg = error.message {
                    self?.showAlert(message: msg)
                }
            }
        }
    }
    
    ///removes the member from the data source array
    private func updateDataSourceOnRemovingMember(index: Int) {
        if self.isSearchActive {
            if let memberId = self.searchedTemMembers?[index].user_id {
                self.searchedTemMembers?.remove(at: index)
                if let indexInMainList = self.temMembers?.firstIndex(where: ({$0.user_id == memberId})) {
                    self.temMembers?.remove(at: indexInMainList)
                }
                if let index = self.groupInfo?.memberIds?.firstIndex(of: memberId) {
                    self.groupInfo?.memberIds?.remove(at: index)
                }
            }
        } else {
            if let memberId = self.temMembers?[index].user_id,
                let index = self.groupInfo?.memberIds?.firstIndex(of: memberId) {
                self.groupInfo?.memberIds?.remove(at: index)
            }
            self.temMembers?.remove(at: index)
        }
        self.tableView.reloadData()
    }

    // MARK: Helpers
    //filter the search list array from the members list on the basis of search text
    private func filterSearchListArray() {
        let filteredArray = self.temMembers?.filter({ (member) -> Bool in
            return member.fullName.containsIgnoringCase(other: searchText)
        })
        self.searchedTemMembers?.removeAll()
        if filteredArray != nil {
            self.searchedTemMembers?.append(contentsOf: filteredArray!)
        }
    }
    
    ///returns the data source of the table view
    private func membersArray() -> [Friends]? {
        if isSearchActive {
            return self.searchedTemMembers
        } else {
            return self.temMembers
        }
    }
    
    private func updateMembersInChatRoom() {
        if let memberIds = self.groupInfo?.memberIds,
            let roomId = groupInfo?.chatRoomId {
            ChatManager().addMembersToChatRoom(roomId: roomId, memberIds: memberIds)
        }
    }
    
    ///update the status of each member in chat room
    private func updateNewMembersChatStatusInRoom() {
        if let selected = self.selectedFriends,
            let roomId = self.groupInfo?.chatRoomId {
            _ = selected.map { (member) -> Friends in
                ChatManager().updateUserGroupChatStatusInChatRoom(roomId: roomId, userId: member.id ?? "", status: .active)
                return member
            }
        }
    }
}

// MARK: UITableViewDataSource
extension TemInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return TemInfoSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = TemInfoSection(rawValue: section) {
            switch currentSection {
            case .temInfo:
                if isSearchFieldEditing {
                    return 0
                }
                return TemInfoRow.allCases.count
            default:
                return self.membersArray()?.count ?? 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = TemInfoSection(rawValue: indexPath.section) {
            switch currentSection {
            case .temInfo:
                if let currentRow = TemInfoRow(rawValue: indexPath.row) {
                    if currentRow == .groupIcon {
                        let cell = tableView.dequeueReusableCell(withIdentifier: GroupImageHeaderTableViewCell.reuseIdentifier, for: indexPath) as! GroupImageHeaderTableViewCell
                        cell.setImage(urlString: groupInfo?.icon)
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: TemInfoTableViewCell.reuseIdentifier, for: indexPath) as! TemInfoTableViewCell
                        cell.initializeAt(indexPath: indexPath, groupInfo: groupInfo)
                        return cell
                    }
                }
            case .temMembers:
                let cell = tableView.dequeueReusableCell(withIdentifier: TemMembersTableViewCell.reuseIdentifier, for: indexPath) as! TemMembersTableViewCell
                cell.delegate = self
                if let member = self.membersArray()?[indexPath.row] {
                    cell.setData(memberInfo: member, groupInfo: self.groupInfo, indexPath: indexPath)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension TemInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let currentSection = TemInfoSection(rawValue: indexPath.section) {
            switch currentSection {
            case .temInfo:
                if indexPath.row == TemInfoRow.groupIcon.rawValue {
                    if let cell = cell as? GroupImageHeaderTableViewCell {
                        cell.roundView.roundCorners([.topLeft, .topRight], radius: 10.0)
                    }
                }
                if indexPath.row == TemInfoRow.desc.rawValue {
                    cell.roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
                }
            case .temMembers:
                if let membersArray = self.membersArray() {
                    if indexPath.row == membersArray.count - 1 {
                        cell.roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let currentSection = TemInfoSection(rawValue: section) {
            switch currentSection {
            case .temMembers:
                //if the data is being loaded from start, show an activity indicator here, else show the search view
                if membersLoadingFromStart {
                    return Utility.getPagingSpinner()
                }
                guard let cell:ChatSearchHeaderTableCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ChatSearchHeaderTableCell.reuseIdentifier) as? ChatSearchHeaderTableCell else {
                    return nil
                }
                cell.initialize(groupInfo: self.groupInfo)
                cell.delegate = self
                return cell
            default: break
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection = TemInfoSection(rawValue: section) {
            if currentSection == .temMembers {
                return 65.0
            }
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 13.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
}

// MARK: TemMemberTableCellDelegate
extension TemInfoViewController: TemMemberTableCellDelegate {
    func didTakeActionOnTemMember(tag: Int) {
        self.view.endEditing(true)
        let memberName = self.membersArray()?[tag].firstName ?? ""
        var titleArray: [UserActions] = [.makeAdmin, .deleteMemberFromGroup, .cancel]
        var colorsArray: [UIColor] = [.gray, .gray, .gray]
        var customTitles: [String] = [AppMessages.Chat.makeGroupAdmin, "Remove \(memberName)", UserActions.cancel.title]
        if let editableByMembers = self.groupInfo?.editableByMembers {
            switch editableByMembers {
            case false:
                //show options: make this person as admin and remove participant
                self.actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: colorsArray, customTitles: customTitles, tag: tag)
            case true:
                if UserManager.getCurrentUser()?.id != self.groupInfo?.admin?.userId {
                    titleArray.removeFirst()
                    colorsArray.removeFirst()
                    customTitles.removeFirst()
                }
                self.actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: colorsArray, customTitles: customTitles, tag: tag)
            }
            self.actionSheet?.delegate = self
        }
    }
}

// MARK: EditGroupViewDelegate
extension TemInfoViewController: EditGroupViewDelegate {
    func didUpdateGroupInformation(updatedGroup: ChatRoom) {
        self.groupInfo = updatedGroup
        self.tableView.reloadData()
    }
}

// MARK: CustomBottomSheetDelegate
extension TemInfoViewController: CustomBottomSheetDelegate {
    func customSheet(actionForItem action: UserActions) {
        actionSheet?.dismissSheet()
        let tag = actionSheet?.tag ?? 0
        switch action {
        case .deleteMemberFromGroup:
            let memberName = self.membersArray()?[tag].fullName ?? ""
            let groupName = self.groupInfo?.name ?? ""
            let displayMessage = "Remove \(memberName) from \"\(groupName)\" group?"
            self.showAlert(withTitle: "", message: displayMessage, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
                self.removeMemberFromGroup(atIndex: tag)
            }) {
            }
        case .makeAdmin:
            self.changeGroupAdmin(atIndex: tag)
        default:
            return
        }
    }
}

// MARK: ChatSearchHeaderDelegate
extension TemInfoViewController : ChatSearchHeaderDelegate {
    func didEndEditingSearchBar() {
        self.isSearchFieldEditing = false
        self.tableView.reloadData()
    }
    
    func didStartSearch() {
        self.isSearchFieldEditing = true
        self.tableView.reloadData()
    }
    
    func didEnterTextInSearchBar(text: String) {
        self.isSearchActive = true
        
        if self.searchedTemMembers == nil {
            self.searchedTemMembers = []
        }
        self.searchText = text
        self.filterSearchListArray()
        self.tableView.reloadData()
        if let filterList = self.searchedTemMembers,
            filterList.isEmpty {
            //if filter results are empty, show background view of table
            self.tableView.showEmptyScreen("No Results")
        } else {
            self.tableView.restore()
        }
    }
    
    func searchBarCleared() {
        //reset search list
        self.isSearchActive = false
        self.searchText = ""
        self.searchedTemMembers?.removeAll()
        self.tableView.restore()
        self.tableView.reloadData()
    }
    
    func didClickOnAddButton() {
        let inviteFrndVC:InviteFriendController = UIStoryboard(storyboard: .challenge).initVC()
        inviteFrndVC.screenFrom = .addGroupParticipants
        inviteFrndVC.chatGroupId = self.groupInfo?.groupId
        inviteFrndVC.delegate = self
        navigationController?.pushViewController(inviteFrndVC, animated: true)
    }
}

// MARK: InviteFriendControllerViewDelegate
extension TemInfoViewController : InviteFriendControllerViewDelegate {
    func didSelectTemates(members: [Friends]) {
        self.selectedFriends = members
        self.showLoader(message: "Adding participants")
        if groupInfo?.memberIds == nil {
            groupInfo?.memberIds = []
        }
        for (_, member) in members.enumerated() {
            if let memberId = member.id {
                self.groupInfo?.memberIds?.append(memberId)
            }
        }
        //edit group api call
        self.addGroupParticipants()
    }
}
