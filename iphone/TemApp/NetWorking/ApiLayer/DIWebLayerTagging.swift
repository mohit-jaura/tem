//
//  DIWebLayerTagging.swift
//  TemApp
//
//  Created by shilpa on 30/12/19.
//

import Foundation

class DIWebLayerTagging: DIWebLayer {
    ///fetch the chat group members list to tag
    func fetchChatGroupMembersForTagging(groupId: String, searchString: String, completion: @escaping(_ members: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var subdomain = Constant.SubDomain.fetchChatGroupMembersToTag + "?group_id=\(groupId)"
        //if !searchString.isEmpty {
            subdomain += "&search_by=\(searchString)"
        //}
        call(method: .get, function: subdomain, parameters: nil, success: { (response) in
            DILog.print(items: response)
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (friends) in
                    completion(friends)
                }, failure: { (error) in
                    //decoding error
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    //search the users globally for tagging
    func searchUsersForTagging(searchText: String, completion: @escaping(_ members: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var subdomain = Constant.SubDomain.searchTagUsers
        if !searchText.isEmpty {
            subdomain += "?search_by=\(searchText)"
        }
        let url = subdomain.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (members) in
                    completion(members)
                }, failure: { (error) in
                    failure(error)
                })
            }
            
        }) { (error) in
            failure(error)
        }
    }
    
    //save the tag added by the user
    func updateUserTagList(parameters: Parameters?) {
        call(method: .post, function: Constant.SubDomain.updateUserTagList, parameters: parameters, success: { (response) in
            
        }) { (_) in
            
        }
    }
    
    ///fetch the group activity chat group members list to tag
    func fetchActivityMembersForTagging(taggingType: TagUsersListType, groupId: String, searchString: String, completion: @escaping(_ members: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var subdomain = Constant.SubDomain.challengeChatMembersSearch
        if taggingType == .challengeChatTagging {
            subdomain = Constant.SubDomain.challengeChatMembersSearch
        } else if taggingType == .goalChatTagging {
            subdomain = Constant.SubDomain.goalChatMembersSearch
        }
        subdomain += "?id=\(groupId)&search_by=\(searchString)"
        call(method: .get, function: subdomain, parameters: nil, success: { (response) in
            DILog.print(items: response)
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (friends) in
                    completion(friends)
                }, failure: { (error) in
                    //decoding error
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
}
