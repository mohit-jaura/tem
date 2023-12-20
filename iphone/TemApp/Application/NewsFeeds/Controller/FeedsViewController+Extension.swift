//
//  FeedsViewController+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 30/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit


extension FeedsViewController : PostTableCellDelegate, URLTappableProtocol {
    func didTapOnUrl(url: URL) {
        self.pushToSafariVCOnUrlTap(url: url)
    }
    
    func didBeginEdit(textView: UITextView) {
        self.activeTextView = textView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.scrollWithKeyboard(keyboardHeight: self.keyboardSize, inputView: textView, extraOffset: self.tabBarHeight)
            var safeArea: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            } else {
                // Fallback on earlier versions
            }
            textView.resignFirstResponder()
            var constraintValue = self.keyboardSize - safeArea
            if self.tabBarHeight != 0 {
                constraintValue = constraintValue - self.tabBarHeight + safeArea
            }
            self.tagListBottomConstraint.constant = constraintValue
            self.tagListContainerView.isHidden = false
            self.postCommentFullScreenVC?.setFirstResponder()
            self.postCommentFullScreenVC?.indexPath = IndexPath(row: textView.tag, section: FeedSections.Feeds.rawValue)
            if let post = self.posts?[textView.tag].id {
                self.postCommentFullScreenVC?.postId = post
            }
        }
    }
    
    func didTapOnViewTaggedPeople(sender: CustomButton)  {
        if let taggedIds = self.posts?[sender.section].media?[sender.row].taggedPeople {
            self.showSelectionModal(array: taggedIds, type: .taggedList)
        }
    }
    
    func didTapMentionOnCaptionAt(row: Int, section: Int, tagText: String) {
        if let section = FeedSections(rawValue: section),
            section == .Feeds {
            if let captionTaggedIds = self.posts?[row].captionTags {
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
        if let section = FeedSections(rawValue: section),
            section == .Feeds {
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
        if let link = self.posts?[index].shortLink , link != ""{
            self.shareLink(data: link)
            return
        }else{
            let urlString = Constant.SubDomain.sharePost + "?post_id=\(id)"
            let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            self.showLoader()
            DIWebLayerNetworkAPI().getBusinessDynamicLink(url:url,parameters: nil, success: { (response) in
                self.hideLoader()
                self.shareLink(data: response)
                self.posts?[index].shortLink = response
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
        let index = indexPath.row
        switch action {
        case .like:
            self.posts?[index].updateLikes(withStatus: isDecrease)
            //save the value in core data for that pos
            self.feedsDataProvider.updateLikesInPostInDatabaseWith(postId: self.posts?[index].id, isLikeByMe: self.posts?[index].isLikeByMe , likesCount: self.posts?[index].likesCount)
            
        case .comment :
            self.posts?[index].updateCommentsCount(forStatus: isDecrease)
            if let comment = actionInformation as? Comments {
                self.posts?[index].updateLatestComment(info: comment, value: isDecrease)
            }
            if let comments = actionInformation as? [Comments] {
                self.posts?[index].updateLatestCommentsArray(data: comments, value: isDecrease)
            }
        default:
            break
        }
     //   let indexPath = IndexPath(item: index, section: 1)
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func adjustTableHeight(scrollToTp:Bool) {
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    // MARK: Server call
    // delete post api call
    func deletePostAt(index: Int) {
        self.showLoader()
        let params = DeletePostApiKey(id: self.posts?[index].id ?? "")
        PostManager.shared.deletepost(parameters: params.toDictionary(), success: { (message) in
            self.showAlert(message:message)
            self.dotsButtonAction(indexPath: IndexPath(row: index, section: 0), type: .delete)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    
    // delete friend api call
    func deleteFriendAt(index: Int) {
        self.showLoader()
        let params = DeleteFriendApiKey(friendId: self.posts?[index].user?.id  ?? "")
        NetworkConnectionManager().deleteFriend(params: params.toDictionary() , success: { (message) in
            self.showAlert(message:message)
            self.dotsButtonAction(indexPath:IndexPath(row: index, section: 0) , type: .unfriend)
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        })
    }
}

extension FeedsViewController: PresentActionSheetDelegate{
    func presentActionSheet(titleArray: [UserActions], titleColorArray: [UIColor], tag: Int, indexPath: IndexPath) {
        actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: titleColorArray, tag: tag,section: indexPath.section)
        actionSheet.delegate = self
        
    }
}


extension FeedsViewController: CustomBottomSheetDelegate {
    
    func customSheet(actionForItem action: UserActions) {
        let actionIndex = actionSheet.tag
        let indexPath = IndexPath(row: actionIndex, section: 0)
        self.actionSheet.dismissSheet()
        if action == .report {
            if Constant.reportHeadings.isEmpty {
                Utility.getHeadings()
            }
        }
        if action == .challenge {
            let controller:CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
            controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
            controller.isType = false
            if let user = self.posts?[actionIndex].user {
                controller.selectedFriends = [user]
            }
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        if action == .cancel {
            return
        }
        self.showAlert(withTitle: "", message: action.message, okayTitle: action.action, cancelTitle: AppMessages.AlertTitles.No,okStyle:.destructive, okCall: {
            guard self.isConnectedToNetwork() else {
                return
            }
            switch action {
            case .delete:
                self.deletePostAt(index: actionIndex)
            case .unfriend:
                self.deleteFriendAt(index: actionIndex)
            case .report:
                self.addTableView(indexPath:indexPath)
            default:
                break
            }
        }) {
        }
    }
    
    
}


//This Extension will use pagination for suggested friends.....
extension FeedsViewController: SuggestedFriendPaginationProtocol {
    func callLoadMoreData() {
        if (currentPageForSuggestedFriend > previousPageForSuggestedFriend) {
            previousPageForSuggestedFriend = currentPageForSuggestedFriend
            getUserSuggestion(pagenumber: previousPageForSuggestedFriend)
        }
        
    }
    
}



protocol NewsFeedDelegate {
    
}
