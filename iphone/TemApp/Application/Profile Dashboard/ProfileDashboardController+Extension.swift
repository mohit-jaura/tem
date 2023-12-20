//
//  ProfileDashboardController+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 02/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

// MARK: UITableViewDataSource&UITableViewDelegate
extension ProfileDashboardController : UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch selectedSection {
        case .profile:
            return (ProfileSection.allCases.count)
        case .accountSetting:
            //  return (AccountSettingSection.allCases.count)
            return 1
        case .healthMeasures,.temates:
            return 1
        case .other:
            if otherUserId != nil {
                return 2
            }
            if viewingMyOwnProfileAsOthers {
                return 2
            }
            return 0//otherUserId != nil ? 2 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = nil
        switch selectedSection {
        case .profile:
            if sectionOpenStatus[section] == .isClose {
                return 0
            }
            //            if let _ = selectedRow {
            //                if selectedRow != section {
            //                    return 0
            //                }
            let value = ProfileSection(rawValue: section)
            switch value {
            case .profileInfo:
                return 1
            case .accountabilityMission:
                return 1
            case .seeYourProfile:
                return 0
            case .posts:
                let headerView = Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?.first as? MessageView
                if !(Reachability.isConnectedToNetwork()) {
                    headerView?.messageLabel.text = AppMessages.AlertTitles.noInternet
                    headerView?.titleLabel.text = ""
                }
                if self.userPosts.count == 0 {
                    if self.freindsSuggestion.count == 0 {
                        headerView?.titleLabel.text = ""
                        if let id = otherUserId , id != "" {
                            headerView?.messageLabel.text = "No Post created by user"
                            if let status = self.userProfile?.friendStatus, status == .blocked {
                                headerView?.messageLabel.text = "No Content\nYou have blocked the user and unable to view this user's video."
                            }
                        }
                        tableView.showCenterBackgroundView(view: headerView ?? UIView(), centerY: self.headerView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height ?? 500)
                        return 0
                    }
                    return 1
                }
                if isGridView {
                    return 1
                }
                return self.userPosts.count
            case .none:
                return 0
            }
            //    }
            //  return 0
            
        case .accountSetting:
            return 1
        case .healthMeasures,.temates:
            return 1
        case .other:
             let value = OtherProfileSection(rawValue: section)
             switch value {
             case .accountabilityMission:
                return 1
             case .posts:
                let headerView = Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?.first as? MessageView
                if !(Reachability.isConnectedToNetwork()) {
                    headerView?.messageLabel.text = AppMessages.AlertTitles.noInternet
                    headerView?.titleLabel.text = ""
                }
                if self.userPosts.count == 0 {
                    if self.freindsSuggestion.count == 0 {
                        headerView?.titleLabel.text = ""
                        if let id = otherUserId , id != "" {
                            headerView?.messageLabel.text = "No Post created by user"
                            if let status = self.userProfile?.friendStatus, status == .blocked {
                                headerView?.messageLabel.text = "No Content\nYou have blocked the user and unable to view this user's video."
                            }
                        }
                        tableView.showCenterBackgroundView(view: headerView ?? UIView(), centerY: self.headerView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height ?? 500)
                        return 0
                    }
                    return 1
                }
                if isGridView {
                    return 1
                }
                return self.userPosts.count
             case .none:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch selectedSection {
        case .profile:
            if sectionOpenStatus[indexPath.section] == .isClose {
                return UITableViewCell()
            }
            //            if let _ = selectedRow {
            //                if selectedRow != indexPath.section {
            //                    return UITableViewCell()
            //                }
            let value = ProfileSection(rawValue: indexPath.section)
            switch value {
            case .profileInfo:
                
                guard let cell:ProfileContainerViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileContainerViewCell", for: indexPath) as? ProfileContainerViewCell else {
                    return UITableViewCell()
                }
                cell.addProfileView(view: self,type: .profile, createProfileVC: createProfileVC, haisView:haisView, tematesVC: tematesVC,temHeight:temHeight, haisViewheight: CGFloat(haisViewheight))
                return cell
                
            case .accountabilityMission:
                
                guard let cell:ProfileTextViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTextViewCell", for: indexPath) as? ProfileTextViewCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.textView.tag = indexPath.row
                cell.configureCell(userProfile:self.userProfile)
                // cell.accountabilityTextView.delegate = self
                // cell.addProfileView(view: self)
                return cell
                
            case .posts:
                if self.userPosts.count == 0 {
                    guard let cell:SuggestionTableCell = tableView.dequeueReusableCell(withIdentifier: SuggestionTableCell.reuseIdentifier, for: indexPath) as? SuggestionTableCell else {
                        return UITableViewCell()
                    }
                    cell.delegate = self
                    cell.suggestionList = self.freindsSuggestion
                    cell.suggestionCollectionView.reloadData()
                    return cell
                }
                if isGridView {
                    guard let cell:ProfileTableCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableCell.reuseIdentifier, for: indexPath) as? ProfileTableCell else {
                        return UITableViewCell()
                    }
                    cell.userPosts = self.userPosts
                    cell.delegate = self
                    cell.frame = tableView.bounds
                    cell.layoutSubviews()
                    cell.layoutIfNeeded()
                    cell.profileCollectionView.reloadData()
                    return cell
                }else{
                    guard let cell:PostTableCell = tableView.dequeueReusableCell(withIdentifier: PostTableCell.reuseIdentifier, for: indexPath) as? PostTableCell else {
                        return UITableViewCell()
                    }
                    cell.postTableVideoMediaDelegate = self
                    cell.actionDelegate = self
                    cell.isReadMoreShow = true
                    cell.delegate = self
                    cell.redirectPostDelegate = self
                    cell.postButton.tag = indexPath.row
                    //cell.mediaCollectionHeightConstraint.constant = 250
                    if indexPath.row < self.userPosts.count {
                        cell.setData(post: self.userPosts[indexPath.row], atIndexPath: indexPath, user: self.userProfile ?? Friends())
                        cell.setContentOffset(contentOffset: self.collectionOffsets[indexPath.row] ?? CGPoint.zero)
                        //                if let media = self.userPosts[indexPath.row].media,
                        //                    let height = media.first?.height,
                        //                    height != 0 {
                        //                    cell.mediaCollectionHeightConstraint.constant = CGFloat(height)
                        //                } else {
                        //                    cell.mediaCollectionHeightConstraint.constant = 0
                        //                }
                    }
                    return cell
                }
                
            default:
                return UITableViewCell()
            }
        //     }
        case .accountSetting:
            guard let cell:TableAccountViewCell = tableView.dequeueReusableCell(withIdentifier: "TableAccountViewCell", for: indexPath) as? TableAccountViewCell else {
                return UITableViewCell()
            }
            cell.setVc(vcc: self)
            return cell
        case .healthMeasures:
            print("healthMeasurescell",indexPath)
            guard let cell:ProfileContainerViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileContainerViewCell", for: indexPath) as? ProfileContainerViewCell else {
                return UITableViewCell()
            }
            cell.addProfileView(view: self,type: .healthMeasures, createProfileVC: createProfileVC, haisView: haisView,tematesVC:tematesVC,temHeight:temHeight,haisViewheight:CGFloat(haisViewheight))
            return cell
        case .temates:
            guard let cell:ProfileContainerViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileContainerViewCell", for: indexPath) as? ProfileContainerViewCell else {
                return UITableViewCell()
            }
            cell.addProfileView(view: self,type: .temates, createProfileVC: createProfileVC, haisView: haisView,tematesVC:tematesVC,temHeight:temHeight, haisViewheight: CGFloat(haisViewheight))
            return cell
        case .other:
            let value = OtherProfileSection(rawValue: indexPath.section)
            
            switch value {
            case .accountabilityMission:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountabilityMissionCell", for: indexPath) as? AccountabilityMissionCell else {
                    return UITableViewCell()
                }
                cell.accountabilityMissionlbl.text = userProfile?.accountabilityMission ?? ""
                // cell.accountabilityTextView.delegate = self
                // cell.addProfileView(view: self)
                return cell
            case .posts:
                
                if self.userPosts.count == 0 {
                    guard let cell:SuggestionTableCell = tableView.dequeueReusableCell(withIdentifier: SuggestionTableCell.reuseIdentifier, for: indexPath) as? SuggestionTableCell else {
                        return UITableViewCell()
                    }
                    cell.delegate = self
                    cell.suggestionList = self.freindsSuggestion
                    cell.suggestionCollectionView.reloadData()
                    return cell
                }
                if isGridView {
                    guard let cell:ProfileTableCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableCell.reuseIdentifier, for: indexPath) as? ProfileTableCell else {
                        return UITableViewCell()
                    }
                    cell.userPosts = self.userPosts
                    cell.delegate = self
                    cell.frame = tableView.bounds
                    cell.layoutSubviews()
                    cell.layoutIfNeeded()
                    cell.profileCollectionView.reloadData()
                    return cell
                }else{
                    guard let cell:PostTableCell = tableView.dequeueReusableCell(withIdentifier: PostTableCell.reuseIdentifier, for: indexPath) as? PostTableCell else {
                        return UITableViewCell()
                    }
                    cell.postTableVideoMediaDelegate = self
                    cell.actionDelegate = self
                    cell.isReadMoreShow = true
                    cell.delegate = self
                    cell.redirectPostDelegate = self
                    cell.postButton.tag = indexPath.row
                    //cell.mediaCollectionHeightConstraint.constant = 250
                    if indexPath.row < self.userPosts.count {
                        cell.setData(post: self.userPosts[indexPath.row], atIndexPath: indexPath, user: self.userProfile ?? Friends())
                        cell.setContentOffset(contentOffset: self.collectionOffsets[indexPath.row] ?? CGPoint.zero)
                        //                if let media = self.userPosts[indexPath.row].media,
                        //                    let height = media.first?.height,
                        //                    height != 0 {
                        //                    cell.mediaCollectionHeightConstraint.constant = CGFloat(height)
                        //                } else {
                        //                    cell.mediaCollectionHeightConstraint.constant = 0
                        //                }
                    }
                    return cell
                }
            case .none:
                return UITableViewCell()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedSection {
        case .profile:
            //            if let _ = selectedRow {
            //                if selectedRow != indexPath.section {
            //                    return 0
            //                }
            let value = ProfileSection(rawValue: indexPath.section)
           
          
            if sectionOpenStatus[indexPath.section] == .isClose  {
                return 0
            }
            switch value {
            case .profileInfo:
                return 950
            case .accountabilityMission, .seeYourProfile:
                return UITableView.automaticDimension
                /* if selectedTextViewTag  != nil && indexPath.row == selectedTextViewTag && keyboardVisible {
                 print(textviewDisplayHeight)
                 return textviewDisplayHeight ?? 350
                 }
                 let width:CGFloat = 30
                 let height:CGFloat = 60
                 if indexPath.row == 0  {
                 let user = User.sharedInstance
                 
                 if user.accountabilityMission == "" || Constant.Profile.accountabilityMission == user.accountabilityMission {
                 print("*******************888",user.accountabilityMission?.height(withConstrainedWidth: self.view.frame.width-width, font: UIFont.systemFont(ofSize: 18)))
                 
                 return Constant.Profile.accountabilityMission.height(withConstrainedWidth: self.view.frame.width-width, font: UIFont.systemFont(ofSize: 18)) + height
                 }else{
                 
                 print("*******************888",user.accountabilityMission?.height(withConstrainedWidth: self.view.frame.width-width, font: UIFont.systemFont(ofSize: 18)))
                 return (user.accountabilityMission?.height(withConstrainedWidth: self.view.frame.width-width, font: UIFont.systemFont(ofSize: 18)) ?? 5) + height
                 }
                 
                 }*/
            case .posts:
                if (isGridView && userPosts.count > 0) {
                    return getUserPostCollectionViewHeight()
                } else {
                    return UITableView.automaticDimension
                }
            case .none:
                return 0
            }
        //     }
        case .accountSetting:
            return 569
        case .healthMeasures:
            return CGFloat(haisViewheight)
        case .temates:
            print("temHeight----->\(temHeight)")
            return temHeight + 300
        case .other:
            if otherUserId != nil {
                let value = OtherProfileSection(rawValue: indexPath.section)
                if value == .accountabilityMission{
                    return (userProfile?.accountabilityMission != nil && !(userProfile?.accountabilityMission?.isBlank ?? true)) ? UITableView.automaticDimension : 0
                } else if value == .posts{
                    if (isGridView && userPosts.count > 0) {
                        
                        return getUserPostCollectionViewHeight()
                    } else {
                        return UITableView.automaticDimension
                    }
                }
            } else {
                return 0
            }
        }
        return 0
    }
    
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        if (isGridView && userPosts.count > 0 && tableView.contentOffset.y >= 0.0) {
    //            return getUserPostCollectionViewHeight()
    //        } else {
    //            print(tableView.contentOffset.y)
    //            print("Automatic dimentions")
    //
    //            if tableView.contentOffset.y < 0.0{
    //                DispatchQueue.main.async {
    //                    tableView.beginUpdates()
    //                    tableView.layoutSubviews()
    //                    tableView.endUpdates()
    //                }
    //            }
    //            return UITableView.automaticDimension
    //        }
    //    }
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell:ProfileHeaderCell = (tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell") as! ProfileHeaderCell)
        cell.gridListHeightConstraint.constant = 0
        cell.gridButton.isHidden = true
        cell.listButton.isHidden = true
        cell.bottomStackView.isHidden = true
        cell.cellTopView.isHidden = false

        
        switch selectedSection {
        case .profile:
            cell.title.text = profileSectionTitleArray[section]
            // if let _ = selectedRow{
            if section == 2 && sectionOpenStatus[2] == .isOpen{
                cell.bottomStackView.isHidden = false
                if isGridView {
                    cell.gridButton.tintColor = appThemeColor
                    cell.listButton.tintColor = .black
                }else{
                    cell.listButton.tintColor = appThemeColor
                    cell.gridButton.tintColor = .black
                }
                cell.gridButton.addTarget(self, action: #selector(self.switchPostViewActions) , for: .touchUpInside)
                cell.listButton.addTarget(self, action: #selector(self.switchPostViewActions) , for: .touchUpInside)
                if self.userPosts.count == 0 {
                    cell.gridListHeightConstraint.constant = 0
                    cell.gridButton.isHidden = true
                    cell.listButton.isHidden = true
                }else{
                    cell.gridListHeightConstraint.constant = 41.5
                    cell.gridButton.isHidden = false
                    cell.listButton.isHidden = false
                }
            }
            //  }
            // case .accountSetting:
        // cell.title.text = accountSectionTitleArray[section]
        case .other:
            cell.cellTopView.isHidden = true
            cell.dropDounButton.isHidden = true
            cell.title.text = ""
            cell.title.isHidden = true
            // if let _ = selectedRow{
            if section == 1 {
                cell.bottomStackView.isHidden = false
                if isGridView {
                    cell.gridButton.tintColor = appThemeColor
                    cell.listButton.tintColor = .black
                }else{
                    cell.listButton.tintColor = appThemeColor
                    cell.gridButton.tintColor = .black
                }
                cell.gridButton.addTarget(self, action: #selector(self.switchPostViewActions) , for: .touchUpInside)
                cell.listButton.addTarget(self, action: #selector(self.switchPostViewActions) , for: .touchUpInside)
                if self.userPosts.count == 0 {
                    cell.gridListHeightConstraint.constant = 0
                    cell.gridButton.isHidden = true
                    cell.listButton.isHidden = true
                }else{
                    cell.gridListHeightConstraint.constant = 41.5
                    cell.gridButton.isHidden = false
                    cell.listButton.isHidden = false
                }
            }
        default:
            cell.title.text = ""
        }
        //              cell.title.text = faqArray[section].heading
        cell.cellTopView.tag = section
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideShowCell(sender:)))
        cell.cellTopView.addGestureRecognizer(gesture)
        cell.dropDounButton.contentMode = .scaleAspectFit
        cell.dropDounButton.image =  #imageLiteral(resourceName: "right-arrow")

        if sectionOpenStatus[section] == .isClose {
            cell.title.textColor = .black
            cell.sectionIsExpanded = false
        } else {
            cell.footerView.isHidden = true
//            cell.dropDounButton.image =  #imageLiteral(resourceName: "arrowDown")
            cell.title.textColor = appThemeColor
            cell.sectionIsExpanded = true
        }
        if let profileSection = ProfileSection(rawValue: section) {
            if profileSection == .seeYourProfile {
                cell.dropDounButton.image = nil
                cell.title.textColor = .black
            }
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        //        if self.userPosts.count > 0 {
        //            return 0
        //        }
        switch selectedSection {
        case .profile:
            //if let _ = selectedRow{
            if otherUserId != nil {
                return 0
            }
            if sectionOpenStatus[2] == .isOpen && section == 2 && self.userPosts.count != 0 {
                return 92
            }
        // }
        case .accountSetting:
            return 0
        case .healthMeasures:
            return 0
        case .temates:
            return 0
        case .other:
             let value = OtherProfileSection(rawValue: section)
             switch value {
             case .accountabilityMission:
                return 0
             case .posts:
                return 50
             case .none:
                return 0
            }
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch selectedSection {
        case .profile,.other:
            if indexPath.section == 0{
                if cell.isKind(of: EditProfile.self) {
                }
            }
        default:
            //remove player if the cell playing the video goes offscreen
            if self.player != nil,
                self.player.state == .playing,
                let currentPlayIndex = self.currentPlayerIndex?.tableIndexPath,
                currentPlayIndex == indexPath {
                self.removePlayer()
            }
        }
    }
}

extension ProfileDashboardController : PostTableCellDelegate, URLTappableProtocol {
    func didTapOnUrl(url: URL) {
        self.pushToSafariVCOnUrlTap(url: url)
    }
    
    func didBeginEdit(textView: UITextView) {
        self.activeTextView = textView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.userTableView.scrollWithKeyboard(keyboardHeight: self.keyboardHeight, inputView: textView)
            //let pointInTable = textView.superview?.convert(textView.frame, to: self.view)//textView.superview?.convert(textView.frame.origin, to: self.tableView) ?? CGPoint.zero
            // let point = self.userTableView.frame.height - (pointInTable?.minY ?? 0.0)
            var safeArea: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            } else {
                // Fallback on earlier versions
            }
            textView.resignFirstResponder()
            self.tagListBottomConstraint.constant = (self.keyboardHeight - safeArea)//point + textView.frame.height + CGFloat(safeArea)// + 50//pointInTable?.y ?? 0.0//self.keyboardSize//pointInTable.y
            self.tagListContainerView.isHidden = false
            self.postCommentFullScreenVC?.setFirstResponder()
            self.postCommentFullScreenVC?.indexPath = IndexPath(row: textView.tag, section: 0)
            if let post = self.userPosts[textView.tag].id {
                self.postCommentFullScreenVC?.postId = post
            }
        }
        //self.tagUsersListController?.resetTagList()
    }
    
    func didTapOnViewTaggedPeople(sender: CustomButton) {
        if let taggedPeople = self.userPosts[sender.section].media?[sender.row].taggedPeople {
            self.showSelectionModal(array: taggedPeople, type: .taggedList)
        }
    }
    
    func didTapMentionOnCaptionAt(row: Int, section: Int, tagText: String) {
        if !self.userPosts.isEmpty {
            if let captionTaggedIds = self.userPosts[row].captionTags {
                let currentTagged = captionTaggedIds.filter({$0.text == tagText})
                if let userId = currentTagged.first?.id {
                    let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                    if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                        profileController.otherUserId = userId
                    }
                    self.navigationController?.pushViewController(profileController, animated: true)
                }
            }
        }
    }
    
    func didTapMentionOnCommentAt(row: Int, section: Int, tagText: String, commentFirst: Comments?, commentSecond: Comments?) {
        if !self.userPosts.isEmpty {
            var comment = commentFirst
            if commentSecond != nil {
                comment = commentSecond
            }
            if let first = comment,
                let taggedIds = first.taggedIds {
                let current = taggedIds.filter({$0.text == tagText})
                if let userId = current.first?.id {
                    let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                    if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                        profileController.otherUserId = userId
                    }
                    self.navigationController?.pushViewController(profileController, animated: true)
                }
            }
        }
    }
    
    func didTapOnSharePostWith(id: String, indexPath: IndexPath) {
        let index = indexPath.row
        if let link = self.userPosts[index].shortLink , link != ""{
            self.shareLink(data: link)
            return
        }else{
            let urlString = Constant.SubDomain.sharePost + "?post_id=\(id)"
            let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            self.showLoader()
            DIWebLayerNetworkAPI().getBusinessDynamicLink(url:url,parameters: nil, success: { (response) in
                self.hideLoader()
                self.shareLink(data: response)
                self.userPosts[index].shortLink = response
            }) { (error) in
                self.hideLoader()
                self.showAlert(withError:error)
            }
        }
    }
    
    func shareLink(data:String) {
        let activityViewController = UIActivityViewController(activityItems: [ data ] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func UserActions(indexPath: IndexPath, isDecrease: Bool, action: UserActions, actionInformation: Any?) {
        switch action {
        case .like:
            self.userPosts[indexPath.row].updateLikes(withStatus: isDecrease)
        case .comment :
            self.userPosts[indexPath.row].updateCommentsCount(forStatus: isDecrease)
            if let commentInfo = actionInformation as? Comments {
                self.userPosts[indexPath.row].updateLatestComment(info: commentInfo, value: isDecrease)
            }
            if let comments = actionInformation as? [Comments] {
                self.userPosts[indexPath.row].updateLatestCommentsArray(data: comments, value: isDecrease)
            }
        default:
            break
        }
        UIView.performWithoutAnimation {
            let postIndexPath = IndexPath(row: indexPath.row, section:  2)
            if otherUserId != nil {
                self.userTableView.reloadData()
            } else {
                self.userTableView.reloadRows(at: [postIndexPath], with: .none)
            }
        }
    }
    
    func adjustTableHeight(scrollToTp:Bool) {
        UIView.setAnimationsEnabled(false)
        self.userTableView.beginUpdates()
        self.userTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func collectionViewDidScroll(newContentOffset: CGPoint, scrollView: UIScrollView) {
        self.collectionOffsets[scrollView.tag] = newContentOffset
    }
}

//This Extension will use pagination for suggested friends.....
extension ProfileDashboardController: SuggestedFriendPaginationProtocol {
    func callLoadMoreData() {
        
        if (currentPageForSuggestedFriend > previousPageForSuggestedFriend) {
            previousPageForSuggestedFriend = currentPageForSuggestedFriend
            getUserSuggestion(pagenumber: previousPageForSuggestedFriend)
        }
        
    }
    
}


// MARK: SkeletonTableViewDataSource
extension ProfileDashboardController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SuggestionTableCell.reuseIdentifier
    }
}



// MARK: ViewPostDetailDelegate
extension ProfileDashboardController: ViewPostDetailDelegate {
    func redirectToPostDetail(indexPath: IndexPath) {
        let controller : PostDetailController = UIStoryboard(storyboard: .profile).initVC()
        controller.post = self.userPosts[indexPath.row]
        controller.indexPath = indexPath
        controller.user = self.userProfile
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: PostDetailDotsDelegate
// MARK: Function to reload UserPostTable after delting post.
extension ProfileDashboardController: PostDetailDotsDelegate {
    func dotsButtonAction(indexPath: IndexPath, type: UserActions) {
        self.hideLoader()
        switch type {
        case .delete:
            if let postCount = self.userProfile?.feedsCount,
                postCount > 0 {
                self.userProfile?.feedsCount = postCount - 1
                self.updatePostsCountOnView()
            }
            if self.userPosts.count == 0 {
                self.getUserSuggestion(pagenumber: self.previousPageForSuggestedFriend)
            }
            self.userPosts.remove(at: indexPath.row)
            self.userTableView.reloadData()
        case .unfriend:
            self.userProfile?.friendStatus = .other
            self.updateConnectionStatusButtonView()
            self.userTableView.reloadData()
        case .report :
            self.userPosts.remove(at: indexPath.row)
            self.userTableView.reloadData()
        case .block :
            self.userProfile?.friendStatus = .blocked
            self.postButton.isUserInteractionEnabled = false
            self.tematesButton.isUserInteractionEnabled = false
            self.userPosts.removeAll()
            self.updateConnectionStatusButtonView()
            self.userTableView.reloadData()
        default:
            break
        }
    }
    
}
extension ProfileDashboardController: PresentActionSheetDelegate{
    func presentActionSheet(titleArray: [UserActions], titleColorArray: [UIColor], tag: Int, indexPath: IndexPath) {
        actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: titleColorArray, tag: tag,section: indexPath.section)
        actionSheet.delegate = self
    }
}

extension ProfileDashboardController: CustomBottomSheetDelegate {
    
    func customSheet(actionForItem action: UserActions) {
        let actionIndex = actionSheet.tag
        let indexPath = IndexPath(row: actionIndex, section: 0)
        self.actionSheet.dismissSheet()
        if action == .message {
            guard let chatRoomId = self.userProfile?.chatRoomId else {
                return
            }
            //to chat screen
            let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
            chatController.chatRoomId = chatRoomId
            chatController.chatName = self.userProfile?.fullName
            self.navigationController?.pushViewController(chatController, animated: true)
            return
        }
        if action == .report {
            if Constant.reportHeadings.isEmpty {
                Utility.getHeadings()
            }
        }
        if action == .createGoal{
            let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
            controller.isType = true
            controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createGoal)
            if let user = self.userProfile {
                controller.selectedFriends = [user]
            }
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        
        if action == .createChallenge {
            let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
            controller.isType = false
            controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
            if let user = self.userProfile {
                controller.selectedFriends = [user]
            }
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
            if action == .challenge {
                let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
                controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
                controller.isType = false
                if let user = self.userProfile {
                    controller.selectedFriends = [user]
                }
                self.navigationController?.pushViewController(controller, animated: true)
                return
            }

        if action == .cancel {
            return
        }
        self.showAlert(withTitle: "", message: action.message, okayTitle: action.action, cancelTitle: AppMessages.AlertTitles.Cancel,okStyle:.destructive, okCall: {
            guard self.isConnectedToNetwork() else {
                return
            }
            switch action {
            case .delete:
                self.deletePostAt(index: actionIndex)
            case .unfriend:
                break
            case .report:
                self.addTableView(indexPath: indexPath)
            case .block:
                self.blockUser(index: actionIndex)
            case .unBlock:
                self.unblockUser()
            default:
                break
            }
        }) {
        }
    }
}

extension ProfileDashboardController:ProfileTextViewCellDelegate{
    func submitTapped(text: String) {
        if !text.isBlank{
             createProfile(accountabilityMission:text)
        }else{
            self.showAlert(message:AppMessages.ProfileMessages.accountabilityMission)
        }
    }
    
    // MARK: UserNameValidation Functions.
     func checkUserNameValidation(text:String) -> (String,Bool) {
         if text.isBlank {
             return("emptyUserName".localized,false)
         } else if text.containsNoLetter() {
             return ("Username must contain atleast one letter.".localized, false)
         } else if text.trim.length < 3 {
             return("invalidUserName".localized,false)
         }else{
             return("".localized,true)
         }
     }
    
    private func filledPercentage() -> Float {
        let regiseterUser = UserManager.getCurrentUser() ?? User()
        regiseterUser.address = UserManager.getCurrentUser()?.address

        var overallCompletionFieldsCount = 0.0
        if (regiseterUser.profilePicUrl != nil && regiseterUser.profilePicUrl != "") {
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.userName != "" && checkUserNameValidation(text: regiseterUser.userName ?? "").1{
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.dateOfBirth != nil && regiseterUser.dateOfBirth != "" {
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.gender != nil && regiseterUser.gender != 0 {
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.address?.formatted != nil && regiseterUser.address?.formatted != ""{
            overallCompletionFieldsCount += 1.0
        }
        if (regiseterUser.gymAddress != nil && regiseterUser.gymAddress?.name != nil){
            if(!(regiseterUser.gymAddress?.name!.isBlank)!){
                overallCompletionFieldsCount += 1.0
            }
        }
        if regiseterUser.firstName?.count ?? 0 >= 2 {
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.lastName?.count ?? 0 >= 2{
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.email != ""{
            overallCompletionFieldsCount += 1.0
        }
        if regiseterUser.phoneNumber != ""{
            overallCompletionFieldsCount += 1.0
        }
        
        return Float(overallCompletionFieldsCount/10.0)
    }
    
    //This Fucntion will return param to create profile....
    private func getParameterKey(accountabilityMission:String) -> Parameters {
        let regiseterUser = UserManager.getCurrentUser() ?? User()
        regiseterUser.address = UserManager.getCurrentUser()?.address
        var param = CreateProfile()
        param.location = regiseterUser.address ?? Address()
        param.firstName = regiseterUser.firstName ?? ""
        param.lastName = regiseterUser.lastName ?? ""
        param.imgUrl = regiseterUser.profilePicUrl ?? ""
        if regiseterUser.dateOfBirth?.toInt() == 0 {
            if let date = regiseterUser.dateOfBirth?.toDate(dateFormat: .preDefined) {
                param.dateOfBirth = "\(date.timeStamp)"
            }
        } else {
            param.dateOfBirth = regiseterUser.dateOfBirth ?? ""
        }
        param.gender = regiseterUser.gender ?? 0
        param.lat = regiseterUser.address?.lat ?? 0.0
        param.long = regiseterUser.address?.lng ?? 0.0
        param.profileCompletion = Double(self.filledPercentage())
        param.gymLocation = regiseterUser.gymAddress ?? Address()
        if let gymType = regiseterUser.gymAddress?.gymType {
            if let hasGymType = regiseterUser.gymAddress?.hasGymType,
                hasGymType == .yes {
                switch gymType {
                case .home:
                    param.gymAddressType = .home
                case .other:
                    param.gymAddressType = .other
                }
            }
        }
        param.accountabilityMission = accountabilityMission

        DILog.print(items: "parameters for Create Profile:- \(param.getDictionary() ?? [:])")
        return param.getDictionary() ?? [:]
    }
   
    
    //This fucntion will call API to save data on backend server....
    private func createProfile(accountabilityMission:String) {
        self.view.endEditing(true)
           guard isConnectedToNetwork() else {
               return
           }
        DIWebLayerUserAPI().uplodaProfileData(parameters: getParameterKey(accountabilityMission:accountabilityMission), success: { (message) in
               self.hideLoader()
            self.setUserData(accountabilityMission: accountabilityMission)
               self.showAlert(withTitle: "", message:"Accountability Mission updated successfully", okayTitle: "OK".localized, okCall: {
                  
               })
           }) { (error) in
               self.hideLoader()
               self.showAlert(withError: error)
           }
       }
    
    
    func setUserData(accountabilityMission:String) {
        Defaults.shared.remove(DefaultKey.socialLoginInfo)
        let user = User.sharedInstance
        user.accountabilityMission = accountabilityMission
        UserManager.saveCurrentUser(user: user)
        //update the user information on firebase as well.
        ChatManager().updateCurrentUserInfoToDatabase()
    }
    
    func updateCurrentUserTemates(count: Int) {
        Defaults.shared.remove(DefaultKey.socialLoginInfo)
        let user = User.sharedInstance
        user.tematesCount = count
        UserManager.saveCurrentUser(user: user)
        //update the user information on firebase as well.
        ChatManager().updateCurrentUserInfoToDatabase()
    }
    
}

extension ProfileDashboardController:UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == accountbilityMissionTextView{
            if accountbilityMissionTextView.text == AppMessages.ProfileMessages.accountabilityPlaceholder {
                accountbilityMissionTextView.text = ""
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == accountbilityMissionTextView{
            if let text = textView.text{
                if !text.isEmpty || text != ""{
                    textView.textColor = UIColor.black
                }
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == accountbilityMissionTextView{
            if let text = textView.text{
                if text.isEmpty || text.hasPrefix(" "){
                    textView.text = AppMessages.ProfileMessages.accountabilityPlaceholder
                    self.createProfile(accountabilityMission: AppMessages.ProfileMessages.accountabilityPlaceholder)
                    self.setUserData(accountabilityMission: AppMessages.ProfileMessages.accountabilityPlaceholder)
                    self.accountbilityMissionToggle.image = UIImage(named: "")
                }else{
                    self.accountbilityMission = textView.text
                    self.createProfile(accountabilityMission: self.accountbilityMission)
                    self.setUserData(accountabilityMission: self.accountbilityMission)
                    self.accountbilityMissionToggle.image = UIImage(named: "Oval Copy 3")
                }
            }
        }
    }
}

//This extension will add gradient to AccountbilityMission text
extension ProfileDashboardController{
    func addGradientToAccountbilityMission(){
        let gradient = getGradientLayer(bounds: self.accountbilityMissionTextView.bounds)
        accountbilityMissionTextView.textColor = GradientOnText().gradientColor(bounds: accountbilityMissionTextView.bounds, gradientLayer: gradient)
    }
    
    func getGradientLayer(bounds : CGRect) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = bounds

        gradient.colors = [UIColor(red: 0.71, green: 0.13, blue: 0.88, alpha: 1.00).cgColor,UIColor(red: 50.0 / 255.0, green: 197.0 / 255.0, blue: 255.0 / 255.0, alpha: 1).cgColor]

        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }
}


