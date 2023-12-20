//
//  GroupInfoSideMenuViewController.swift
//  TemApp
//
//  Created by shilpa on 10/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SideMenu

enum GroupInfoSideMenuSection: Int, CaseIterable {
    case info = 0, calendar, challenges, leaderboard, mute, clearMessage, exitGroup, joinGroup
    
    var title: String {
        switch self {
        case .info:
            return "INFO".localized
        case .calendar:
            return "CALENDAR".localized
        case .challenges:
            return "GOALS & CHALLENGES".localized
        case .leaderboard:
            return "LEADERBOARD".localized
        case .mute:
            return "MUTE".localized
        case .clearMessage:
            return "CLEAR MESSAGES".localized
        case .exitGroup:
            return "Exit Group".localized
        case .joinGroup:
            return "Join Group".localized
        }
    }
}

protocol GroupInfoSideMenuDelegate: AnyObject {
    func didTapOnClearGroupMessages()
}

class GroupInfoSideMenuViewController: DIBaseController {
    
    // MARK: Properties
    weak var delegate: GroupInfoSideMenuDelegate?
    var groupInfo: ChatRoom?
    private let chatNetworkLayer = DIWebLayerChatApi()
    
    // MARK: IBOutlets
    @IBOutlet weak var activityScoreLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var tematesCountAndGroupStatusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var groupImageGradientView:GradientDashedLineCircularView!{
        didSet{
            groupImageGradientView.configureViewProperties(colors: [ #colorLiteral(red: 0.8862745098, green: 0.6784313725, blue: 0.3921568627, alpha: 1),#colorLiteral(red: 0.7294117647, green: 0.3647058824, blue: 0.7176470588, alpha: 1),UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0])
            groupImageGradientView.instanceWidth = 2.0
            groupImageGradientView.instanceHeight = 6.0
            groupImageGradientView.extraInstanceCount = 1
            groupImageGradientView.lineColor = UIColor.gray
            groupImageGradientView.updateGradientLocation(newLocations: [NSNumber(value: 0.35),NSNumber(value: 0.60),NSNumber(value: 0.89),NSNumber(value: 0.99)], addAnimation: false)
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNibs(nibNames: [
            GroupInfoMuteAndExitActionTableViewCell.reuseIdentifier
        ])
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.setGroupInformation()
        self.tableView.reloadData()
    }
    
    // MARK: Helpers
    func setGroupInformation() {
        self.groupNameLabel.text = groupInfo?.name
        self.tematesCountAndGroupStatusLabel.text = "\(self.groupInfo?.membersCount ?? 0) TĒMATES"
        + " | " + (self.groupInfo?.visibility?.name ?? "N/A")
        if let grpIcon = groupInfo?.icon,
           let url = URL(string: grpIcon) {
            self.groupImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "grp-image"))
        } else{
        }
        self.activityScoreLabel.text = "Average Activity Score: " + "\(groupInfo?.avgActivityScore?.rounded(toPlaces: 2) ?? 0)"
    }
    
    private func updateMuteStatus() {
        if let muteStatus = self.groupInfo?.isMuted {
            self.groupInfo?.isMuted = muteStatus.toggle()
            let indexPath = IndexPath(row: 0, section: GroupInfoSideMenuSection.mute.rawValue)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func askForGroupExitConfirmation() {
        if let memberIds = self.groupInfo?.memberIds,
           memberIds.count > 1,
           self.groupInfo?.admin?.userId == UserManager.getCurrentUser()?.id {
            self.showAlert(message: AppMessages.Chat.adminExitGroup)
        } else {
            self.showAlert(withTitle: "", message: AppMessages.Chat.memberExitGroup, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
                self.exitGroupApiCall()
            }) {
            }
        }
    }
    
    private func askForGroupJoinConfirmation() {
        self.showAlert(withTitle: "", message: AppMessages.Chat.memberExitGroup, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okCall: {
            self.joinGroupApiCall()
        }) {
        }
    }
    
    private func updateChatStatusInRoom(_ status: GroupChatStatus) {
        guard let roomId = self.groupInfo?.chatRoomId,
              let userId = UserManager.getCurrentUser()?.id else {
                  return
              }
        ChatManager().updateUserGroupChatStatusInChatRoom(roomId: roomId, userId: userId, status: status)
    }
    
    private func updateMembersInChatRoom() {
        if let memberIds = self.groupInfo?.memberIds,
           let roomId = groupInfo?.chatRoomId {
            ChatManager().addMembersToChatRoom(roomId: roomId, memberIds: memberIds)
        }
    }
    
    private func pushToChallengesView() {
        let challengeListingScreen: ChallangeDashBoardController = UIStoryboard(storyboard: .challenge).initVC()
        challengeListingScreen.groupId = groupInfo?.groupId
        challengeListingScreen.selectedSection = .challenge
        self.navigationController?.pushViewController(challengeListingScreen, animated: true)
    }
    
    private func redirectToGroupCalendar() {
        
    }
    
    // MARK: Api Calls
    private func exitGroupApiCall() {
        if self.isConnectedToNetwork() {
            self.showLoader()
            let params = self.groupInfo?.actionOnMemberApiJson(memberId: UserManager.getCurrentUser()?.id, status: .exit)
            self.chatNetworkLayer.deleteGroupMember(params: params, completion: {[weak self] (_) in
                self?.hideLoader()
                //remove value at this index from array both from the searched array list and the main list array
                if let membersCount = self?.groupInfo?.membersCount {
                    self?.groupInfo?.membersCount = membersCount - 1
                }
                if let index = self?.groupInfo?.memberIds?.firstIndex(of: UserManager.getCurrentUser()?.id ?? "") {
                    self?.groupInfo?.memberIds?.remove(at: index)
                }
                var newStatus = GroupChatStatus.notPartOfGroup
                if self?.groupInfo?.visibility == .open {
                    newStatus = .observer
                }
                else {
                    newStatus = .notPartOfGroup
                }
                self?.updateChatStatusInRoom(newStatus)
                self?.updateMembersInChatRoom()
                self?.groupInfo?.groupChatStatus = newStatus
                NotificationCenter.default.post(name: Notification.Name.exitedFromGroup, object: self, userInfo: [ChatRoom.CodingKeys.chatRoomId: self?.groupInfo?.chatRoomId ?? ""])
                self?.dismiss(animated: true, completion: nil)
            }) {[weak self] (error) in
                self?.hideLoader()
                if let msg = error.message {
                    self?.showAlert(message: msg)
                }
            }
        }
    }
    
    // MARK: Api Calls
    private func joinGroupApiCall() {
        if self.isConnectedToNetwork() {
            self.showLoader()
            let params = self.groupInfo?.joinGroupJson()
            self.chatNetworkLayer.joinGroup(params: params, completion: {[weak self] (_) in
                self?.hideLoader()
                //remove value at this index from array both from the searched array list and the main list array
                if let membersCount = self?.groupInfo?.membersCount {
                    self?.groupInfo?.membersCount = membersCount + 1
                }
                if let userId = UserManager.getCurrentUser()?.id {
                    self?.groupInfo?.memberIds?.append(userId)
                }
                let newStatus = GroupChatStatus.active
                self?.updateChatStatusInRoom(newStatus)
                self?.updateMembersInChatRoom()
                self?.groupInfo?.groupChatStatus = newStatus
                NotificationCenter.default.post(name: Notification.Name.joinedGroup, object: self, userInfo: [ChatRoom.CodingKeys.chatRoomId: self?.groupInfo?.chatRoomId ?? ""])
                self?.dismiss(animated: true, completion: nil)
            }) {[weak self] (error) in
                self?.hideLoader()
                if let msg = error.message {
                    self?.showAlert(message: msg)
                }
            }
        }
    }
    
    private func muteChatNotifications() {
        if isConnectedToNetwork() {
            var params: Parameters = ["group_id": self.groupInfo?.groupId ?? ""]
            if let muteStatus = groupInfo?.isMuted {
                params["is_mute"] = muteStatus.toggle().rawValue
            }
            self.updateMuteStatus()
            self.chatNetworkLayer.muteChatNotifications(params: params, completion: { (_) in
            }) {[weak self] (error) in
                //revert the mute status on error
                self?.updateMuteStatus()
                if let msg = error.message {
                    self?.showAlert(message: msg)
                }
            }
        }
    }
}

// MARK: UITableViewDataSource
extension GroupInfoSideMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return GroupInfoSideMenuSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = GroupInfoSideMenuSection(rawValue: section) {
            switch currentSection {
            case .exitGroup:
                if groupInfo?.groupChatStatus == .active {
                    return 1
                }
            case .mute:
                return 0
            case .joinGroup:
                if groupInfo?.groupChatStatus == .observer {
                    return 1
                }
            default:
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = GroupInfoSideMenuSection(rawValue: indexPath.section) {
            switch currentSection {
            case .info, .calendar , .challenges, .leaderboard, .clearMessage:
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupActionSideMenuTableViewCell.reuseIdentifier, for: indexPath) as! GroupActionSideMenuTableViewCell
                cell.delegate = self
                cell.initialize(atSection: currentSection, indexPath: indexPath, groupInfo: groupInfo)
                return cell
            case .exitGroup:
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupInfoMuteAndExitActionTableViewCell.reuseIdentifier, for: indexPath) as! GroupInfoMuteAndExitActionTableViewCell
                cell.muteExitView.isHidden = false
                cell.joinView.isHidden = true
                cell.muteButton.tag = GroupInfoSideMenuSection.mute.rawValue
                cell.exitButton.tag = GroupInfoSideMenuSection.exitGroup.rawValue
                cell.delegate = self
                return cell
            case .joinGroup:
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupInfoMuteAndExitActionTableViewCell.reuseIdentifier, for: indexPath) as! GroupInfoMuteAndExitActionTableViewCell
                cell.muteExitView.isHidden = true
                cell.joinView.isHidden = false
                cell.joinButton.tag = GroupInfoSideMenuSection.joinGroup.rawValue
                cell.delegate = self
                return cell
            default:
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension GroupInfoSideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentSection = GroupInfoSideMenuSection(rawValue: indexPath.section) {
            switch currentSection {
            case .info:
                if let rightSideMenu = SideMenuManager.default.rightMenuNavigationController {
                    rightSideMenu.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                let temInfoVC: TemInfoViewController = UIStoryboard(storyboard: .chat).initVC()
                temInfoVC.groupInfo = self.groupInfo
                self.navigationController?.pushViewController(temInfoVC, animated: true)
            case .clearMessage:
                self.delegate?.didTapOnClearGroupMessages()
                self.dismiss(animated: true, completion: nil)
            case .leaderboard:
                if let rightSideMenu = SideMenuManager.default.rightMenuNavigationController {
                    rightSideMenu.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                let leaderboardController: GroupLeaderboardController = UIStoryboard(storyboard: .chat).initVC()
                leaderboardController.groupId = self.groupInfo?.groupId
                leaderboardController.groupName = self.groupInfo?.name
                self.navigationController?.pushViewController(leaderboardController, animated: true)
            case .challenges:
                if let rightSideMenu = SideMenuManager.default.rightMenuNavigationController {
                    rightSideMenu.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                self.pushToChallengesView()
            case .calendar:
                self.redirectToGroupCalendar()
            case .joinGroup:
                self.askForGroupJoinConfirmation()
            default: break
            }
        }
    }
}

// MARK: GroupSideMenuTableCellDelegate
extension GroupInfoSideMenuViewController: GroupSideMenuTableCellDelegate {
    func didTapOnActionOnGroupSideMenu(sender: UIButton) {
        if let section = GroupInfoSideMenuSection(rawValue: sender.tag) {
            switch section {
            case .mute:
                self.muteChatNotifications()
            default:
                break
            }
        }
    }
}

extension GroupInfoSideMenuViewController:GroupInfoMuteAndExitActionTableViewCellDelegate{
    func didTapOnMuteJoinAndExitButton(sender: UIButton) {
        if let section = GroupInfoSideMenuSection(rawValue: sender.tag) {
            switch section {
            case .mute:
                self.muteChatNotifications()
            case .exitGroup:
                self.exitGroupApiCall()
            case .joinGroup:
                self.joinGroupApiCall()
            default:
                break
            }
        }
    }
}
