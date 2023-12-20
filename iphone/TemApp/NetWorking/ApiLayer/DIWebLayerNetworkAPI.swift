//
//  DIWebLayerNetworkAPI.swift
//  TemApp
//
//  Created by dhiraj on 18/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import Alamofire

class DIWebLayerNetworkAPI: DIWebLayer {
    
    func getBusinessDynamicLink(url:String,parameters: Parameters?, success: @escaping (_ url: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        
        self.call(method:.get, function: url, parameters: parameters, success: { dataResponse in
            if let url = dataResponse["data"] as? String{
                success(url)
            }
            return
        }) {
            failure($0)
        }
    }
    
    func sendFriendRequest(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.put,function: Constant.SubDomain.sendFriendRequest, parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func remindRequest(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.put,function: Constant.SubDomain.remindFriendForSentRequest, parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func getPendingRequest(parameters: Parameters?,page:String,success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ()){
        let url:String = Constant.SubDomain.getMyPendingRequestList + "?page=\(page)"
        self.call(method:.get,function: url, parameters: parameters, success: { response in
            if let data = response["data"] as? [Parameters],let count = response["count"] as? Int {
                self.decodeFrom(data: data, success: { (friends) in
                    success(friends, count)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) {
            failure($0)
        }
    }
    
    func getSentRequest(parameters: Parameters?,page:String,success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        let url:String = Constant.SubDomain.getMySentRequestList + "?page=\(page)"
        self.call(method:.get,function: url, parameters: parameters, success: { response in
            if let data = response["data"] as? [Parameters],let count = response["count"] as? Int  {
                self.decodeFrom(data: data, success: { (friends) in
                    success(friends, count)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) {
            failure($0)
        }
    }
    
    func getFriendList(subdomain: String = Constant.SubDomain.getMyFriendList, parameters: Parameters?,page:String, searchString: String? = nil,userId:String = "", groupId: String = "",success: @escaping (_ response: [Friends],_ count:Int) -> (), failure: @escaping (_ error: DIError) -> ()){
        var url:String = subdomain + "?page=\(page)"
        if userId != "" {
            url  = url + "&user_id=\(userId)"
        }
        if groupId != "" {
            url  = url + "&group_id=\(groupId)"
        }
        if let searchText = searchString {
            url += "&text=\(searchText)"
        }
        if let params = parameters {
            if let status = params["status"] as? Int {
                url += "&status=\(status)"
            }
        }
        let encodedUrl:String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method:.get,function: encodedUrl, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters],let count = response["count"] as? Int{
                //get data from object
                self.decodeFrom(data: data, success: { (friends) in
                    success(friends, count)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) {
            failure($0)
        }
    }
    
    func getTemsList(searchString: String?, page: String, success: @escaping (_ response: [ChatRoom]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        var url = Constant.SubDomain.getGroupsListing + "?page=\(page)"
        if let searchText = searchString {
            url += "&text=\(searchText)"
        }
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (groups) in
                    success(groups)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getPublicTemsList(searchString: String?, page: String, success: @escaping (_ response: [ChatRoom]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        var url = Constant.SubDomain.getPublicGroupsListing + "?page=\(page)"
        if let searchText = searchString {
            url += "&text=\(searchText)"
        }
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (groups) in
                    success(groups)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func acceptRequest(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.put,function: "network/acceptRequest", parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func blockUser(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method: .post, function: "users/blockUser", parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func unBlockUser(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method: .post, function: "users/unblockUser", parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    /// reject a friend request
    func rejectRequest(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.put,function: Constant.SubDomain.rejectFriendRequest, parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func syncFacebookFriends(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.put,function: "sync_friends", parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
     //This Function will sync the phone number Contacts.....
    
    func syncContacts(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.post,function: Constant.SubDomain.syncContacts, parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    /// delete a sent request
    func deleteRequest(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.delete,function: Constant.SubDomain.deleteSentRequest, parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func deleteFriend(parameters: Parameters,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.delete,function: Constant.SubDomain.unfriend, parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
   
    
    
    func getSuggestedFriends(parameters: Parameters?,page:String,success: @escaping (_ response: [Friends]) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        var url:String = Constant.SubDomain.friendSuggestion// + "/\(page)"
        if !page.isEmpty {
            url += "/\(page)"
        }
        self.call(method:.get,function: url, parameters: parameters, success: { response in
            print("suggestions at page: \(page): \(response)")
            if let data = response["data"] as? [Parameters] {
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let friends = try JSONDecoder().decode([Friends].self, from: jsonData)
                    success(friends)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                }
            }else{
                
            }
        }) {
            failure($0)
        }
    }
    
    func searchFriends(parameters: Parameters?,page:String,textToSearch:String,success: @escaping (_ response: [Friends]?) -> (), failure: @escaping (_ error: DIError) -> ()){
        let url:String = "network/search/\(textToSearch)?page=\(page)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method:.get,function: url, parameters: parameters, success: { response in
            if let data = response["data"] as? NSArray {
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let dataClass = try JSONDecoder().decode([Friends].self, from: jsonData)
                    success(dataClass)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                    success(nil)
                }
            }else{
                success(nil)
            }
        }) {
            failure($0)
        }
    }
    
    func getUserFriendsWith(userId: String, page: Int, searchText: String? = "", success: @escaping (_ response: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> ()) {
        let urlString = Constant.SubDomain.getOtherUserFriendList + "?user_id=\(userId)" + "&page=\(page)" + "&title=\(searchText!)"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method:.get,function: url, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (friends) in
                    success(friends)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) {
            failure($0)
        }
    }
    
    /// search users within app
    func searchUsers(page: Int, textToSearch: String, success: @escaping (_ response: [Friends]) -> (), failure: @escaping (_ error: DIError) -> ()){
        var urlString = Constant.SubDomain.searchAllUsers + "?page=\(page)"
        if !textToSearch.isEmpty {
            urlString += "&text=\(textToSearch)"
        }
        
        let url:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method:.get,function: url, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (friends) in
                    success(friends)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) {
            failure($0)
        }
    }
}
