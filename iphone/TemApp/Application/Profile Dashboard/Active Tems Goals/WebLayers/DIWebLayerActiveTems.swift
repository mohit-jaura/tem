//
//  DIWebLayerActiveTems.swift
//  TemApp
//
//  Created by Mohit Soni on 05/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

final class DIWebLayerActiveTems: DIWebLayer {
    
    func getTems(userId: String, page: Int, completion: @escaping([ChatRoom], _ totalCount: Int) -> Void, failure: @escaping Failure) {
        var endPoint = Constant.SubDomain.getActivePublicTems + userId + "&page=\(page)"
        self.call(method: .get, function: endPoint, parameters: nil) { responseValue in
            if let responseData = responseValue["data"] as? [Parameters], let totalCount = responseValue["count"] as? Int { //
                self.decodeFrom(data: responseData) { detail in
                    completion(detail, totalCount)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func getGoals(userId: String, page: Int, completion: @escaping([GroupActivity], _ totalCount: Int) -> Void, failure: @escaping Failure) {
        let endPoint = Constant.SubDomain.getActivePublicGoals + userId + "&page=\(page)"
        self.call(method: .get, function: endPoint, parameters: nil) { responseValue in
            if let responseData = responseValue["data"] as? [Parameters], let totalCount = responseValue["count"] as? Int {
                self.decodeFrom(data: responseData) { activities in
                    completion(activities, totalCount)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
    func getChallenges(userId: String, page: Int, completion: @escaping([GroupActivity], _ totalCount: Int) -> Void, failure: @escaping Failure) {
        let endPoint = Constant.SubDomain.getActivePublicChallenges + userId + "&page=\(page)"
        self.call(method: .get, function: endPoint, parameters: nil) { responseValue in
            if let responseData = responseValue["data"] as? [Parameters], let totalCount = responseValue["count"] as? Int {
                self.decodeFrom(data: responseData) { activities in
                    completion(activities, totalCount)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
}
