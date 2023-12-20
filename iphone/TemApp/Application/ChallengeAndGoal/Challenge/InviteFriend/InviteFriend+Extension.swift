//
//  InviteFriend+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 27/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

enum inviteFriendsSection : Int, CaseIterable {
    case Groups = 0
    case publicGroups = 1
    case Friends = 2
    var title:String {
        switch self {
        case .Groups:
            return "TĒMS"
        case .publicGroups:
            return "PUBLIC TĒMS"
        case .Friends:
            return "TĒMATES"
        }
    }
}

// MARK: UICollectionViewDelegate&UICollectionViewDataSource.
extension InviteFriendController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.temWithMembersSelectionEnabled() {
            if self.selectedGroup != nil {
                return self.selectedFriends.count + 1
            } else {
                return self.selectedFriends.count
            }
        }
        if self.isGroup {
            return 1
        } else {
            return selectedFriends.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:InviteFriendsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: InviteFriendsCollectionCell.reuseIdentifier, for: indexPath) as? InviteFriendsCollectionCell else {
            return UICollectionViewCell()
        }
        if selectedGroup != nil {
            if indexPath.row == 0 {
                cell.setDataForChatGroup(indexPath: indexPath, data: selectedGroup ?? ChatRoom())
            } else {
                if indexPath.row <= selectedFriends.count {
                    cell.setData(indexPath: indexPath, data: self.selectedFriends[indexPath.row - 1])
                }
            }
        } else {
            if indexPath.row < selectedFriends.count {
                cell.setData(indexPath: indexPath, data: self.selectedFriends[indexPath.row])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: self.collectionView.frame.height)
    }
    
    private func selectTemates(section: Int, row: Int) {
        if let currentSection = inviteFriendsSection(rawValue: section) {
            switch currentSection {
                case .publicGroups:
                    if self.publicGroups.count > 0 {
                        if !self.temWithMembersSelectionEnabled() {
                            self.selectedFriends.removeAll()
                        }
                        if row < self.publicGroups.count {
                            self.selectedGroup = self.publicGroups[row]
                            self.isGroup = true
                        }
                    }
                case .Groups:
                    if self.groups.count > 0 {
                        if !self.temWithMembersSelectionEnabled() {
                            self.selectedFriends.removeAll()
                        }
                        if row < self.groups.count {
                            self.selectedGroup = self.groups[row]
                            self.isGroup = true
                        }
                    }
                case .Friends:
                    if friends.count > 0 {
                        if self.screenFrom == Constant.ScreenFrom.addGroupParticipants,
                           friends[row].memberExist == .yes {
                            // the member is already the part of chat group, disable the selection
                            return
                        }
                        let id = self.friends[row].id ?? ""
                        if !self.temWithMembersSelectionEnabled() {
                            self.selectedGroup = nil
                        }
                        if self.selectedFriends.contains(where: { friend in friend.id == id }) {
                            for (index,data) in self.selectedFriends.enumerated() {
                                if data.id ?? "" == id {
                                    self.selectedFriends.remove(at: index)
                                }
                            }
                        }else{
                            self.selectedFriends.append(self.friends[row])
                        }
                        self.isGroup = false
                    }
            }
        }
        if !self.groups.isEmpty || !self.friends.isEmpty || !self.publicGroups.isEmpty {
            self.tableView.reloadData()
            self.setCollectionHeight()
            self.collectionView.reloadData()
        }
    }
    
}

extension InviteFriendController : UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return inviteFriendsSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = inviteFriendsSection(rawValue: section) {
            switch currentSection {
            case .Groups:
                return self.groups.count
            case .publicGroups:
                return self.publicGroups.count
            case .Friends:
                return self.friends.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if inviteFriendsSection(rawValue: indexPath.section) != nil {
            guard let cell:InviteFriendsTableCell = tableView.dequeueReusableCell(withIdentifier: InviteFriendsTableCell.reuseIdentifier, for: indexPath) as? InviteFriendsTableCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            if let currentSection = inviteFriendsSection(rawValue: indexPath.section) {
                switch currentSection {
                case .publicGroups:
                    //Show selected Group.
                    if indexPath.row < publicGroups.count{
                        let id = self.publicGroups[indexPath.row].groupId ?? ""
                        cell.configureCellForGroup(indexPath: indexPath, data: self.publicGroups[indexPath.row])
                        if self.selectedGroup?.groupId ?? "" == id {
                            self.setViews(cell: cell, isSelected: true)
                        }else{
                            self.setViews(cell: cell, isSelected: false)
                        }
                    }
                case .Groups:
                    //Show selected Group.
                    if indexPath.row < groups.count{
                        let id = self.groups[indexPath.row].groupId ?? ""
                        cell.configureCellForGroup(indexPath: indexPath, data: self.groups[indexPath.row])
                        if self.selectedGroup?.groupId ?? "" == id {
                            self.setViews(cell: cell, isSelected: true)
                        }else{
                            self.setViews(cell: cell, isSelected: false)
                        }
                    }
                case .Friends:
                    //Show selected Friends.
                    if indexPath.row < self.friends.count {
                        let id = self.friends[indexPath.row].id ?? ""
                        cell.configureCell(indexPath: indexPath, data: self.friends[indexPath.row])
                        if self.selectedFriends.contains(where: { friend in friend.id == id }) {
                            self.setViews(cell: cell, isSelected: true)
                        }else{
                            self.setViews(cell: cell, isSelected: false)
                        }
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let currentSection = inviteFriendsSection(rawValue: section) {
            switch currentSection {
            case .Friends :
                if self.friends.isEmpty {
                    //dont create footer on empty screen
                    return 0.001
                }
                if hasAllFriendsDataLoaded == false {
                    return 40
                }
                if !shouldFriendsShowMore && self.friends.count > 0 {
                    return 0.001
                }
                return 40
            case .Groups:
                if self.groups.isEmpty {
                    return 0.001
                }
                if hasAllTemsDataLoaded == false {
                    return 40
                }
                if !shouldTemsShowMore && self.groups.count > 0 {
                    return 0.001
                }
                return 40
            case .publicGroups:
                if self.publicGroups.isEmpty {
                    return 0.001
                }
                if hasAllPublicTemsDataLoaded == false {
                    return 40
                }
                if !shouldPublicTemsShowMore && self.publicGroups.count > 0 {
                    return 0.001
                }
                return 40
            }
        }
        return 0.001
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectTemates(section: indexPath.section, row: indexPath.row)
    }
    
    func setCollectionHeight() {
        self.collectionViewHeight.constant = 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSkeletonActive {
            cell.hideSkeleton()
        }
        if let currentSection = inviteFriendsSection(rawValue: indexPath.section) {
            switch currentSection {
            case .publicGroups:
                if indexPath.row == self.publicGroups.count-1 {
                    cell.roundCorners([.bottomLeft, .bottomRight], radius: 10)
                }
            case .Groups:
                if indexPath.row == self.groups.count-1 {
                    cell.roundCorners([.bottomLeft, .bottomRight], radius: 10)
                }
            case .Friends:
                if !shouldFriendsShowMore && self.friends.count > 0 {
                    if indexPath.row == self.friends.count-1 {
                        cell.roundCorners([.bottomLeft, .bottomRight], radius: 10)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let currentSection = inviteFriendsSection(rawValue: section) {
            switch currentSection {
            case .publicGroups:
                if !self.publicGroups.isEmpty {
                    return self.headerViewFor(section: section, tableView: tableView)
                }
            case .Groups:
                if !self.groups.isEmpty {
                    return self.headerViewFor(section: section, tableView: tableView)
                }
            case .Friends:
                if !self.friends.isEmpty {
                    return self.headerViewFor(section: section, tableView: tableView)
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let section = inviteFriendsSection(rawValue: section) {
            switch section {
            case .publicGroups:
                if self.publicGroups.count == 0 {
                    return CGFloat.leastNormalMagnitude
                }
            case .Groups:
                if self.groups.count == 0 {
                    return CGFloat.leastNormalMagnitude
                }
            case .Friends:
                if self.friends.count == 0 {
                    return CGFloat.leastNormalMagnitude
                }
            }
        }
        return 48.0
    }
    
    func headerViewFor(section: Int, tableView: UITableView) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandedNetworkHeader.reuseIdentifier) as? ExpandedNetworkHeader {
            if let currentSection = inviteFriendsSection(rawValue: section) {
                header.delegate = self
                header.configureFor(section: currentSection)
            }
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableCell(withIdentifier: NetworkFooter.reuseIdentifier) as? NetworkFooter else {return UIView()}
        footer.btnShowMore.tag = section
        footer.delegate = self
        footer.btnShowMore.isUserInteractionEnabled = true
        if let section = inviteFriendsSection(rawValue: section) {
            switch section {
            case .Friends:
                footer.configureSection(hasDataLoaded: hasAllFriendsDataLoaded, shouldShowMore: shouldFriendsShowMore)
                if hasAllFriendsDataLoaded {
                    if self.friends.count == 0 && !shouldFriendsShowMore {
                        footer.btnShowMore.isUserInteractionEnabled = false
                        footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noFriendsYet, for: .normal)
                    }
                }
            case .Groups:
                footer.configureSection(hasDataLoaded: hasAllTemsDataLoaded, shouldShowMore: shouldTemsShowMore)
                if hasAllTemsDataLoaded {
                    if self.groups.count == 0 && !shouldTemsShowMore {
                        footer.btnShowMore.isUserInteractionEnabled = false
                        footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noTemsYet, for: .normal)
                    }
                }
            case .publicGroups:
                footer.configureSection(hasDataLoaded: hasAllPublicTemsDataLoaded, shouldShowMore: shouldPublicTemsShowMore)
                if hasAllPublicTemsDataLoaded {
                    if self.publicGroups.count == 0 && !shouldPublicTemsShowMore {
                        footer.btnShowMore.isUserInteractionEnabled = false
                        footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noTemsYet, for: .normal)
                    }
                }
            }
        }
        return footer
    }
    
}

// MARK: NetworkFooterDelegate
extension InviteFriendController: NetworkFooterDelegate {
    func showMoreTapped(section: Int) {
        if !self.isConnectedToNetwork() {
            return
        }
        if let currentSection = inviteFriendsSection(rawValue: section) {
            switch currentSection {
            case .Friends:
                let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: self.friends.count, paginationLimit: paginationLimit)
                self.friendsPageNo = currentPage + 1
                self.hasAllFriendsDataLoaded = false
                self.shouldFriendsShowMore = false
            case .publicGroups:
                let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: self.publicGroups.count, paginationLimit: paginationLimit)
                self.publicTemsPageNo = currentPage + 1
                self.hasAllPublicTemsDataLoaded = false
                self.shouldPublicTemsShowMore = false
            case .Groups:
                let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: self.groups.count, paginationLimit: paginationLimit)
                self.temsPageNo = currentPage + 1
                self.hasAllTemsDataLoaded = false
                self.shouldTemsShowMore = false
            }
            self.tableView.reloadData()
            self.fetchMoreData()
        }
    }
}

// MARK: UserInfoRedirectionDelegate
extension InviteFriendController: UserInfoRedirectionDelegate {
    func didTapOnUserInformation(atRow row: Int, section: Int) {
        if let currentSection = inviteFriendsSection(rawValue: section) {
            switch currentSection {
            case .Friends:
                //redirect to user profile
                if row < self.friends.count {
                    let profileDashboardVC: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                    profileDashboardVC.otherUserId = self.friends[row].id
                    self.navigationController?.pushViewController(profileDashboardVC, animated: true)
                }
            case .Groups, .publicGroups:
                break
            }
        }
    }
    
    func didTapOnAddBtn(atRow row: Int, section: Int) {
        self.selectTemates(section: section, row: row)
    }
}

// MARK: SkeletonTableViewDataSource
extension InviteFriendController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return InviteFriendsTableCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
}

extension InviteFriendController: ExpandedNetworkHeaderDelegate{
    func didTapOnExpandedHeader(section: Int) { }
    
    func didTapOnSelectAll(selectedAll:Bool) {
        self.selectedFriends = self.friends
        guard let cell:InviteFriendsTableCell = tableView.dequeueReusableCell(withIdentifier: InviteFriendsTableCell.reuseIdentifier) as? InviteFriendsTableCell else {
            return
        }
        if selectedAll {
            self.setViews(cell: cell, isSelected: true)
            self.selectedFriends = self.friends
        }else{
            self.setViews(cell: cell, isSelected: false)
            self.selectedFriends.removeAll()
        }
        self.tableView.reloadData()
    }
}
