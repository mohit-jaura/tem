//
//  DIWebLayerProfileAPI.swift
//  VIZU
//
//  Created by dhiraj on 29/11/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation
import Alamofire

class DIWebLayerProfileAPI: DIWebLayer {
    
    func getProfileDetails(page:Int, userId: String?,success: @escaping (_ response: [Post], _ userModel: Friends?, _ activityData:UserActivityReport?) -> (), failure: @escaping (_ error: DIError) -> ()){
        var url:String = "profile/my_profile/\(page)"
        
        if let userId = userId,
            !userId.isEmpty {
            //get other user profile
            url = "profile?id=\(userId)&page=\(page)"
        }
        
        self.call(method:.get,function: url, parameters: nil, success: { response in
           
            var postArray:[Post] = [Post]()
            var user: Friends?
            var activity: UserActivityReport?
            
            //
          //  print("================ ",response)
            
            let userId = userId ?? ""
            if userId.isEmpty {
                if (page > 1 ) {
                    if let postData = response["data"] as? [[String:Any]] {
                        self.decodeFrom(data: postData, success: { (data) in
                            postArray = data
                        }, failure: { (error) in
                            print(error)
                        })
                    }
                    success(postArray, nil, nil)
                    return
                }
            }
            if let profileData = response["data"] as? [String:Any] {
                if let userData = profileData["user"] as? [String:Any] {
                    /*User.sharedInstance.postCount = userData["feed_posted"] as? Int
                     User.sharedInstance.tematesCount = userData["number_of_temmates"] as? Int
                     User.sharedInstance.temsCount = userData["number_of_tems"] as? Int
                     User.sharedInstance.profilePicUrl = userData["profile_pic"] as? String
                     UserManager.saveCurrentUser(user: User.sharedInstance) */
                    self.decodeFrom(data: userData, success: { (friend) in
                        user = friend
                    }, failure: { (error) in
                    })
                }
                
                if let userPosts = profileData["posts"] as? [[String:Any]] {
                    self.decodeFrom(data: userPosts, success: { (data) in
                        postArray = data
                    }, failure: { (error) in
                        print(error)
                    })
                }
                if let activityJson = profileData["activity"] as? Parameters, let totalReport = activityJson["totalActivityReport"] as? Parameters {
                    do {
                        //get data from object
                        let totalReportJsonData = try JSONSerialization.data(withJSONObject: totalReport, options: .prettyPrinted)
                        activity = try JSONDecoder().decode(UserActivityReport.self, from: totalReportJsonData)
                }
                    catch (let error) {
                        print("error in decoding \(error)")
                        failure(DIError(error: error))
                    }
                }
                success(postArray, user, activity)
                return
            }
        }) {
            failure($0)
        }
    }
    
    func deleteStory(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()) {
        
        self.call(method:.delete,function: "stories", parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func getBadgeCount(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method:.get,function: "profile/bell_count", parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func getUserSuggestion(success: @escaping (_ userList: [String]) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.get,function: Constant.SubDomain.userSuggestion, parameters: nil, success: { response in
            if let data = response["data"] as? [String] {
                success(data)
                return
            }
        }) {
            failure($0)
        }
    }
    
    func getFriendSuggestion(page:Int,success: @escaping (_ friendsList: [Friends]) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.get,function: "\(Constant.SubDomain.friendSuggestion)/\(page)", parameters: nil, success: { response in
            print("suggestions at page: \(page): \(response)")
            var friendsArray = [Friends]()
            if let data = response["data"] as? [[String:Any]] {
                self.decodeFrom(data: data, success: { (data) in
                    friendsArray = data
                }, failure: { (error) in
                    print(error)
                })
            }
            success(friendsArray)
            return
        }) {
            failure($0)
        }
    }
    
    func checkUserNameExist(name: String,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        let url = "profile/username?username=\(name)"
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }
        print("check user name at url \(encodedUrl)")
        self.call(method:.get,function: encodedUrl, parameters: nil, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    
}
