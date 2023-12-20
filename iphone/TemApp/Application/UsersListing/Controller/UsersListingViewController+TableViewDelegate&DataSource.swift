//
//  PostLikesController+TableViewDelegate&DataSource.swift
//  TemApp
//
//  Created by Harpreet_kaur on 26/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit


// MARK: UITableViewDataSource&UITableViewDelegate
extension UsersListingViewController : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return UserListingSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = UserListingSection(rawValue: section) {
            switch currentSection {
            case .myFriends:
                return myFriends.count
            case .others:
                return otherUsers.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:UserListTableViewCell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.reuseIdentifier, for: indexPath) as? UserListTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        if let currentSection = UserListingSection(rawValue: indexPath.section) {
            switch currentSection {
            case .myFriends:
                if indexPath.row == self.myFriends.count - 1 {
                    cell.underLineView.isHidden = true
                }else{
                    cell.underLineView.isHidden = false
                }
                cell.configureViewAt(indexPath: indexPath, user: self.myFriends[indexPath.row],likesScreen: true)
            case .others:
                if indexPath.row == self.otherUsers.count - 1 {
                    cell.underLineView.isHidden = true
                }else{
                    cell.underLineView.isHidden = false
                }
                cell.configureViewAt(indexPath: indexPath, user: self.otherUsers[indexPath.row],likesScreen: true)
                cell.removeButton.tag = indexPath.row
                cell.section = indexPath.section
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let currentSection = UserListingSection(rawValue: section) {
            switch currentSection {
            case .myFriends:
                if !self.myFriends.isEmpty {
                    return self.headerViewFor(section: section, tableView: tableView)
                }
            case .others:
                if !self.otherUsers.isEmpty {
                    return self.headerViewFor(section: section, tableView: tableView)
                }
            }
        }
        return nil
    }
    
    func headerViewFor(section: Int, tableView: UITableView) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandedNetworkHeader.reuseIdentifier) as? ExpandedNetworkHeader {
            if let currentSection = UserListingSection(rawValue: section) {
                header.configureFor(section: currentSection)
            }
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let section = UserListingSection(rawValue: section) {
            switch section {
            case .myFriends:
                if self.myFriends.count == 0 {
                    return CGFloat.leastNormalMagnitude
                }
            case .others:
                if self.otherUsers.count == 0 {
                    return CGFloat.leastNormalMagnitude
                }
            }
        }
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if cell.isSkeletonActive {
            cell.hideSkeleton()
        }
        //this is to set corner radius only on receiving data from server
        if !self.myFriends.isEmpty || !self.otherUsers.isEmpty {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.roundCorners([.bottomLeft, .bottomRight], radius: 10)
            } else {
                cell.roundCorners([], radius: 0)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentSection = UserListingSection(rawValue: indexPath.section) {
            switch currentSection {
            case .myFriends:
                if !self.myFriends.isEmpty {
                    if let userId = self.myFriends[indexPath.row].id {
                        if (self.myFriends[indexPath.row].isCompanyAccount ?? 0) == 0{
                            self.redirectToUserProfileWith(userId: userId)
                        }
                    }
                }
            case .others:
                if !self.otherUsers.isEmpty {
                    if let userId = self.otherUsers[indexPath.row].id {
                        if (self.otherUsers[indexPath.row].isCompanyAccount ?? 0) == 0{
                            self.redirectToUserProfileWith(userId: userId)
                        }
                    }
                }
            }
        }
    }
    
    //redirect to user profile screen
    func redirectToUserProfileWith(userId: String) {
        let profileDashboardVC: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        if let myId = User.sharedInstance.id {
            if userId != myId {
                profileDashboardVC.otherUserId = userId
            }
        }
        self.navigationController?.pushViewController(profileDashboardVC, animated: true)
    }
}
