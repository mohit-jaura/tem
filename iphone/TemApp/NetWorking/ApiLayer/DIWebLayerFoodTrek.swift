//
//  DIWebLayerFoodTrek.swift
//  TemApp
//
//  Created by Shiwani Sharma on 09/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit


class DIWebLayerFoodTrek: DIWebLayer {
    
    func getFriendList(type: Int , parameters: Parameters?, searchString: String? = nil,success: @escaping (_ response: [Friends],_ count:Int, _ isAllFriendSelected: Int) -> (), failure: @escaping (_ error: DIError) -> ()){
        var url:String = Constant.SubDomain.getFoodTrekFriends + "?type=\(type)"
        if let searchText = searchString {
            url += "&text=\(searchText)"
        }

        let encodedUrl:String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method:.get,function: encodedUrl, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters],let count = response["count"] as? Int, let isAllFriendSelected = response["isAllSelected"] as? Int{
                //get data from object
                self.decodeFrom(data: data, success: { (friends) in
                    success(friends, count, isAllFriendSelected)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) {
            failure($0)
        }
    }
    
    
    func addFriend(params: Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        self.call(method:.put,function: Constant.SubDomain.addFriends, parameters: params, success: { response in
            success(response)
        }) {
            failure($0)
        }
        
    }
    func setPostSharingStatus(params: Parameters?, success: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        self.call(method:.put,function: Constant.SubDomain.setSettingStatus, parameters: params, success: { response in
            success(response)
        }) {
            failure($0)
        }
        
    }
    func checkNewUpdate(success: @escaping (_ status: AppUpdateStatus) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.checkAppUpdate, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                if let updateAvailable = data["isUpdate"] as? Int {
                    if updateAvailable == 1 {
                        //means update available
                        if let forceUpdate = data["isForceUpdate"] as? Int,forceUpdate == 1 {
                            //force update
                            success(.available(updateType: .forceUpdate))
                        } else {
                            //normal update
                            success(.available(updateType: .normal))
                        }
                    } else {
                        success(.none) }     }
            }
        }) { (error) in}}
    
    func getPostSharingStatus(success: @escaping (_ status: Int) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getSettingStatus, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                if let status = data["isfoodsetting"] as? Int{
                    success(status)
                }
            }
        }) { (error) in
            failure(error)
        }
   }
}
