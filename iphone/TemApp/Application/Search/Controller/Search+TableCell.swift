//
//  Search+TableCell.swift
//  TemApp
//
//  Created by Egor Shulga on 8.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//
import UIKit

extension GlobalSearch {
    static let createGoalsSearchHeader = createHeaderFactory(text: "Goals".uppercased(), showTopSeparator: true)
    static let createChallengesSearchHeader = createHeaderFactory(text: "Challenges".uppercased(), showTopSeparator: true)
    
    static func createHeaderFactory(text: String, showTopSeparator: Bool = false, smaller: Bool = false, isLargest: Bool = false) -> (SearchViewControllerProtocol, UITableView, IndexPath) -> UITableViewCell {
        return { _, tableView, index  in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchCategoryHeader.reuseIdentifier, for: index) as! SearchCategoryHeader
            cell.label.text = text.uppercased()
            cell.topSeparator.isHidden = !showTopSeparator || index.row == 0

            cell.headerBackgroundView.clipsToBounds = true
            cell.headerBackgroundView.layer.cornerRadius = cell.headerBackgroundView.frame.height / 2
            cell.headerBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]

            cell.headerBackgroundView.isHidden = true
            if smaller {
                cell.label.text = text.uppercased()
                cell.label.font = UIFont(name: UIFont.avenirNextMedium, size: 16)
                cell.label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.headerBackgroundView.isHidden = true
                
            } else {
                if isLargest{
                    cell.headerBackgroundView.isHidden = false
                    cell.label.textColor = UIColor.white
                  //  cell.label.font = cell.label.font.withSize(17)
                    cell.label.font = UIFont(name: UIFont.avenirNextMedium, size: 16)
                    cell.headerBackgroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

                }else{
                    cell.label.textColor = #colorLiteral(red: 0.4167382121, green: 0.9899950624, blue: 1, alpha: 1)
                    cell.label.font = UIFont(name: UIFont.avenirNextBold, size: 16)
                    cell.headerBackgroundView.isHidden = true
                }

            }
            return cell
        }
    }
    
    static func createGoalCell(_: SearchViewControllerProtocol, _ table: UITableView, _ index: IndexPath, item: GroupActivity) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: OpenGoalDashboardCell.reuseIdentifier, for: index) as! OpenGoalDashboardCell
        cell.initialize(activity: item, indexPath: index, showBottomSeparator: false)
        return cell
    }
    
    static func createChallengeCell(_: SearchViewControllerProtocol, _ table: UITableView, _ index: IndexPath, item: GroupActivity) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: OpenChallengeDashboardCell.reuseIdentifier, for: index) as! OpenChallengeDashboardCell
        cell.initialize(activity: item, indexPath: index, showBottomSeparator: false)
        return cell
    }
    
    static let footerCellFactory = { (_ controller: SearchViewControllerProtocol, _ table: UITableView, _ index: IndexPath, _ search: CategorySearch) -> UITableViewCell in
        let cell = table.dequeueReusableCell(withIdentifier: SearchCategoryFooter.reuseIdentifier, for: index) as! SearchCategoryFooter
        cell.initialize(search, controller)
        return cell
    }
}

extension SearchPeople {
    static let createSearchHeader = GlobalSearch.createHeaderFactory(text: "People".uppercased(), showTopSeparator: true,isLargest: true)
    static let createSearchByNameHeader = GlobalSearch.createHeaderFactory(text: "Name")
    static let createSearchByLocationHeader = GlobalSearch.createHeaderFactory(text: "Location")
    static let createSearchByGymHeader = GlobalSearch.createHeaderFactory(text: "Gym / Club")
    static let createSearchByInterestsHeader = GlobalSearch.createHeaderFactory(text: "Interests")
    static let createSearchFriendsHeader = GlobalSearch.createHeaderFactory(text: "tēmates", smaller: true)
    static let createSearchOtherHeader = GlobalSearch.createHeaderFactory(text: "non-tēmates", smaller: true)

    static func createCell(_: SearchViewControllerProtocol, _ table: UITableView, _ index: IndexPath, item: Friends) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: UserListTableViewCell.reuseIdentifier, for: index) as! UserListTableViewCell
        cell.backgroundColor = .clear

        cell.configureViewAt(indexPath: index, user: item, likesScreen: false, isSearch: true)
        return cell
    }
}

extension SearchPosts {
    static let createSearchHeader = GlobalSearch.createHeaderFactory(text: "Posts".uppercased(), showTopSeparator: true)
    static let createSearchByPeopleHeader = GlobalSearch.createHeaderFactory(text: "Tēmates")
    static let createSearchByCaptionHeader = GlobalSearch.createHeaderFactory(text: "Caption")
    static let createSearchByTagsHeader = GlobalSearch.createHeaderFactory(text: "Tags")
    
    static func createCell(_ controller: SearchViewControllerProtocol, _ table: UITableView, _ index: IndexPath, item: Post) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: PostTableCell.reuseIdentifier, for: index) as! PostTableCell
        cell.isReadMoreShow = true
        cell.postButton.tag = index.row
        cell.commentTextView.tag = (index.section * 100) + index.row
        cell.mainView.layer.cornerRadius = 0
        cell.setData(post: item, atIndexPath: index, user: item.user ?? Friends(), isFromFeed: false)
        // Unfortunately, PostTableCell is not self-contained,
        // it queries info & starts actions using multiple delegates.
        // We init some info required by post cell ONLY.
        // FIXME: make PostTableCell self-contained, eliminate code copy-paste.
        cell.postTableVideoMediaDelegate = controller
        cell.actionDelegate = controller
        cell.delegate = controller
        cell.redirectPostDelegate = controller
        cell.setContentOffset(contentOffset: controller.collectionOffsets[index.row] ?? CGPoint.zero)
        return cell
    }
}

extension SearchGroups {
    static let createSearchHeader = GlobalSearch.createHeaderFactory(text: "Tēms".uppercased(), showTopSeparator: true)
    static let createAvailableGroupsSearchHeader = GlobalSearch.createHeaderFactory(text: "Available to Join")
    static let createParticipatingGroupsSearchHeader = GlobalSearch.createHeaderFactory(text: "Participating")

    static func createCell(_: SearchViewControllerProtocol, _ table: UITableView, _ index: IndexPath, item: Friends) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reuseIdentifier, for: index) as! ChatListTableViewCell
        cell.setData(item)
        return cell
    }
}

extension SearchEvents {
    static let createSearchHeader = GlobalSearch.createHeaderFactory(text: "Calendar events".uppercased(), showTopSeparator: true,isLargest: true)
    static let createFutureEventsSearchHeader = GlobalSearch.createHeaderFactory(text: "Future")
    static let createPastEventsSearchHeader = GlobalSearch.createHeaderFactory(text: "Past")
    static let createAvailableEventsSearchHeader = GlobalSearch.createHeaderFactory(text: "Available to Join")
    static let createParticipatingEventsSearchHeader = GlobalSearch.createHeaderFactory(text: "Participating")

    static func createCell(_ controller: SearchViewControllerProtocol, _ table: UITableView, _ index: IndexPath, item: EventDetail) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: EventSearchCell.reuseIdentifier, for: index) as! EventSearchCell
        cell.use(item, controller)
        return cell
    }
}
