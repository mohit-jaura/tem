//
//  DIWebLayerWeightGoal.swift
//  TemApp
//
//  Created by Mohit Soni on 04/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

class DIWebLayerWeightGoal: DIWebLayer {
    
    func addWeightGoal(isHealthGoal: Bool,params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        var url = ""
        if isHealthGoal{
            url = Constant.SubDomain.addHealthGoal
        } else{
            url = Constant.SubDomain.addWeightGoal
        }
        self.call(method: .post, function: url, parameters: params) { responseValue in
            if let status = responseValue["status"] as? Int, status == 0 {
                let error = DIError(message: responseValue["message"] as? String)
                failure(error)
            } else {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }

    func getWeightGoalDetail(getHealthInfo: Bool,id: String, completion: @escaping (WeightGoalDetailModal?) -> Void, failure: @escaping Failure) {
        var endPoint = ""
        if getHealthInfo{
            endPoint = Constant.SubDomain.getHealthGoalDetails + "/" + id
        } else{
            endPoint = Constant.SubDomain.getWeightGoal + "/" + id
        }
        self.call(method: .get, function: endPoint, parameters: nil) { responseValue in
            if let responseData = responseValue["data"] as? Parameters {
                self.decodeFrom(data: responseData) { result in
                    completion(result)
                } failure: { error in
                    failure(error)
                }
            } else {
                completion(nil)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func addWeightGoalLog(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .put, function: Constant.SubDomain.addWeightGoalLog, parameters: params) { responseValue in
            completion()
        } failure: { error in
            failure(error)
        }
    }
    
    func getGoalSharingStatus(completion: @escaping (_ status: Int) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getWeightGoalSharingStatus, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                if let status = data["isGoalsetting"] as? Int{
                    completion(status)
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func setPostSharingStatus(params: Parameters, completion: @escaping (Response) -> (), failure: @escaping (DIError) -> ()) {
        self.call(method:.put,function: Constant.SubDomain.setWeightGoalSharingStatus, parameters: params, success: { response in
            completion(response)
        }) {
            failure($0)
        }
        
    }
    
    func getFriendList(subdomain: String = Constant.SubDomain.getFoodTrekFriends, parameters: Parameters?, searchString: String? = nil,success: @escaping (_ response: [Friends],_ count:Int, _ isAllFriendSelected: Int) -> (), failure: @escaping (_ error: DIError) -> ()){
        var url:String = subdomain
        if let searchText = searchString {
            url += "?text=\(searchText)"
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
}
