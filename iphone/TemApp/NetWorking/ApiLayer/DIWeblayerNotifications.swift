//
//  DIWeblayerNotifications.swift
//  TemApp
//
//  Created by Harpreet_kaur on 11/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DIWebLayerNotificationsAPI: DIWebLayer {
    
    func getNotifications(coachId: String, screenFrom: Constant.ScreenFrom?, page: Int, completion: @escaping (_ data: [Notifications], _ pageLimit: Int) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var url = ""
        if screenFrom == .dashboard{
          url = "\(Constant.SubDomain.getNotifications)\(page)"
        } else{
            if coachId != ""{ // add filter through coach id
                url = "\(Constant.SubDomain.getCoachNotifications)?coach_id=\(coachId)&page=\(page)"
            } else{
                url = "\(Constant.SubDomain.getCoachNotifications)?page=\(page)"
            }

        }
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            var pageLimit = 10
            if let limit = response["pagination_limit"] as? Int {
                pageLimit = limit
            }
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (data) in
                    completion(data, pageLimit)
                }, failure: { (error) in
                    failure(error)
                })
            }else{
                completion([Notifications](), pageLimit)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func readNotification(id: String, completion: @escaping (_ message: String?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: "\(Constant.SubDomain.readNotification)/\(id)", parameters: nil, success: { (response) in
            if let message = response["message"] as? String {
                completion(message)
            } else {
                completion(nil)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func deleteNotifcation(params: Parameters, completion: @escaping(_ success: Bool) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        self.call(method: .delete, function: Constant.SubDomain.readNotification, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
        
    func getUnreadNotificationsCount(completion: @escaping (_ count: Int?, _ chllange_id : String?) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getUnreadNotificationsCount, parameters: nil, success: { (response) in
            DILog.print(items: response)
            if let count = response["count"] as? Int, let chllange_id =  response["chllange_id"] as? String{
                if let user = UserManager.getCurrentUser() {
                    user.unreadNotiCount = count
                    UserManager.saveCurrentUser(user: user)
                }
                completion(count, chllange_id)
            } else {
                completion(nil,nil)
            }
        }) { (error) in
            print(error)
        }
    }
    
    func markAllReadNotifcation(completion: @escaping(_ success: Bool) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.readAllNotification, parameters: nil, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    func deleteAllNotifcation(completion: @escaping(_ success: Bool) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.clearNotifications, parameters: nil, success: { (response) in
               completion(true)
           }) { (error) in
               failure(error)
           }
       }
}
