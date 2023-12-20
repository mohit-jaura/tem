//
//  LikesPresenter.swift
//  TemApp
//
//  Created by shilpa on 26/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

protocol UserListingPresenterDelegate: AnyObject {
    func reloadViewWith(data: [Friends], isFromSearch: Bool)
    func didReceiveError(_ error: DIError)
    func didTapRightBarButton(sender: UIBarButtonItem)
    func showEmptyScreenWith(message: String)
    func showNoInternetConnectionMessage()
    func initializeViewLayoutToStartSearch()
    func showSkeleton()
    func setScreenEmpty()
}

class UsersListingPresenter {
    
    weak var delegate: UserListingPresenterDelegate?
    /*
     this will hold the logic on the basis of different screen types
     */
    var screenType: Constant.ScreenFrom?
    //this string will hold the value of id corressponding to which the data for the presenting view will be fetched
    var id: String?
    var searchTextString:String?
    
    /// initializer for presenter. pass in the screen type and id corresponding to which the data needs to be fetched
    init(forScreenType type: Constant.ScreenFrom, id: String? = nil, text:String? = "") {
        self.screenType = type
        self.id = id
        self.searchTextString = text
    }
    
    /// set the presenting view as delegate of the presenter
    func initialize(currentView: UserListingPresenterDelegate) {
        self.delegate = currentView
        self.setUpViewLayout()
    }
    
    func setUpViewLayout() {
        if let screenType = self.screenType,
            screenType == .searchAppUsers {
            self.delegate?.initializeViewLayoutToStartSearch()
        }
    }
    
    func showSkeletonViewOnPresentingView() {
        if let screenType = self.screenType {
            switch screenType {
            case .postLikes, .othersTemates:
                self.delegate?.showSkeleton()
            default:
                break
            }
        }
    }
    
    // call this method to load the data for the presenting view
    func loadDataFor(page: Int) {
        guard Reachability.isConnectedToNetwork() else {
            self.delegate?.showNoInternetConnectionMessage()
            return
        }
        if let screenType = self.screenType {
            switch screenType {
            case .postLikes:
                if self.id != nil {
                    self.fetchLikesFor(page: page)
                }
            case .othersTemates:
                if self.id != nil {
                    self.fetchUserFriendsFor(page: page)
                }
            case .searchAppUsers:
                self.delegate?.setScreenEmpty()
                case .foodTrekLikes:
                    if self.id != nil {
                        self.fetchFoodTrekLikesFor(page: page)
                    }
            default:
                break
            }
        }
    }
    
    /*
     this function is called on pagination in presented view
     */
    func loadNextPageData(forPageNumber page: Int, searchText: String?) {
        if let screenType = self.screenType {
            switch screenType {
            case .postLikes, .othersTemates:
                if let searchString = searchText,
                    !searchString.isEmpty {
                    self.searchListingWithCurrentPage(page: page, withText: searchString)
                } else {
                    self.loadDataFor(page: page)
                }
            case .searchAppUsers:
                if let searchString = searchText,
                    !searchString.isEmpty {
                    self.searchUsers(page: page, searchText: searchString)
                } else {
                    self.delegate?.setScreenEmpty()
                }
            default:
                break
            }
        }
    }
    
    /// call this method to filter the results
    func searchListingWithCurrentPage(page: Int, withText searchText: String) {
        guard Reachability.isConnectedToNetwork() else {
            self.delegate?.showNoInternetConnectionMessage()
            return
        }
        if let screenType = self.screenType {
            switch screenType {
            case .postLikes:
                if self.id != nil {
                    self.searchPostLikes(page: page, searchText: searchText)
                }
            case .othersTemates:
                if self.id != nil {
                    self.fetchUserFriendsFor(page: page, searchText: searchText)
                }
            case .searchAppUsers:
                self.searchUsers(page: page, searchText: searchText)
            default:
                break
            }
        }
    }
    
    /*
     set message for the empty screen view for the presented view
     */
    func showEmptyScreenMessage(isResultFromSearch: Bool) {
        if let screenType = self.screenType {
            switch screenType {
            case .othersTemates, .searchAppUsers:
                var message = AppMessages.NetworkMessages.noFriendsListing
                if isResultFromSearch {
                    message = AppMessages.NetworkMessages.noSearchFound
                }
                self.delegate?.showEmptyScreenWith(message: message)
            case .postLikes:
                let message = AppMessages.NetworkMessages.noSearchFound
                self.delegate?.showEmptyScreenWith(message: message)
            default:
                break
            }
        }
    }
    
    /*
     method returning the title of the presenting view controller
     */
    func titleOfView() -> String {
        if let screenType = self.screenType {
            return screenType.title
        }
        return ""
    }
    
    /*
     function returning the right bar button item of the presenting view controller
     */
    func rightBarItem() -> UIBarButtonItem? {
        if let screenType = self.screenType {
            switch screenType {
            case .postLikes, .othersTemates:
                let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .plain, target: self, action: #selector(rightBarItemTapped(sender:)))
                barButton.tintColor = .black
                return barButton
            default:
                return nil
            }
        }
        return nil
    }
    
    @objc func rightBarItemTapped(sender: UIBarButtonItem) {
        self.delegate?.didTapRightBarButton(sender: sender)
    }
    
    // MARK: server hit
    ///Fetch likes of a post.
    private func fetchLikesFor(page: Int) {
        DIWebLayerUserAPI().getPostLikes(id: self.id ?? "", page: page, success: { (response) in
            self.delegate?.reloadViewWith(data: response, isFromSearch: false)
        }, failure: { (error) in
            self.delegate?.didReceiveError(error)
        })
    }
    
    private func fetchFoodTrekLikesFor(page: Int) {
        DIWebLayerUserAPI().getFoodTrekPostLikes(id: self.id ?? "", page: page, success: { (response) in
            self.delegate?.reloadViewWith(data: response, isFromSearch: false)
        }, failure: { (error) in
            self.delegate?.didReceiveError(error)
        })
    }
    /// search post likes
    private func searchPostLikes(page: Int, searchText: String) {
        DIWebLayerUserAPI().getSearchPostLikes(id: self.id ?? "", title: searchText, page: page, success: { (response) in
            self.delegate?.reloadViewWith(data: response, isFromSearch: true)
        }, failure: { (error) in
            self.delegate?.didReceiveError(error)
        })
    }
    
    /// fetch friends of user
    private func fetchUserFriendsFor(page: Int, searchText: String? = "") {
        DIWebLayerNetworkAPI().getUserFriendsWith(userId: self.id ?? "", page: page, searchText: searchText!, success: { (users) in
            if searchText != nil && !searchText!.isEmpty {
                self.delegate?.reloadViewWith(data: users, isFromSearch: true)
            } else {
                self.delegate?.reloadViewWith(data: users, isFromSearch: false)
            }
        }) { (error) in
            self.delegate?.didReceiveError(error)
        }
    }
    
    /// search users in app
    private func searchUsers(page: Int, searchText: String) {
        DIWebLayerNetworkAPI().searchUsers(page: page, textToSearch: searchText, success: { (response) in
            self.delegate?.reloadViewWith(data: response, isFromSearch: true)
        }, failure: { (error) in
            self.delegate?.didReceiveError(error)
        })
    }
}
