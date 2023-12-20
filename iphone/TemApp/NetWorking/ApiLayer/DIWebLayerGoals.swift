//
//  DIWebLayerGoals.swift
//  TemApp
//
//  Created by Sourav on 6/27/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import Alamofire
import Firebase
class DIWebLayerGoals: DIWebLayer {

    func createGoal(httpMethod: HTTPMethod, parameter:Parameters, success: @escaping (_ message:String?, _ data: GroupActivity?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method: httpMethod, function: Constant.SubDomain.createGoal, parameters: parameter, success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data) { (activityInfo) in
                    success(response["message"] as? String ?? "", activityInfo)
                } failure: { (error) in
                    failure(error)
                }
            } else {
                if let message = response["message"] as? String {
                    success(message, nil)
                } else {
                    success(nil, nil)
                }
            }
        }) { (error) in
            failure(error)
        }
    }

    /// api call to get all challenges list
    ///
    /// - Parameters:
    ///   - type: 1 for open, 2 for completed, 3 for upcoming
    ///   - page: page number
    ///   - completion: success block with data
    ///   - failure: failure block with error

    func getGoals(forType type: Constant.UserActivityType, page: Int, completion: @escaping (_ activities: [GroupActivity], _ pageLimit: Int?, _ pendingCount: Int?) -> Void, failure: @escaping (_ error: DIError) -> Void) {

        let function = Constant.SubDomain.getGoals + "?status=\(type.rawValue)" + "&page=\(page)"

        self.call(method: .get, function: function, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                var pageLimit: Int?
                if let paginationLimit = response["paginationLimit"] as? Int {
                    pageLimit = paginationLimit
                }
                var pendingCount = 0
                if let count = response["count"] as? Int,page == 1 {
                    pendingCount = count
                }

                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let activities = try JSONDecoder().decode([GroupActivity].self, from: jsonData)
                    completion(activities, pageLimit, pendingCount)
                } catch (let error) {
                    DILog.print(items: error)
                    let diError = DIError(error: error)
                    failure(diError)
                }
            }
        }) { (error) in
            failure(error)
        }
    }

    /// get the goal details by id
    ///
    /// - Parameters:
    ///   - id: challenge id
    ///   - completion: success block with challenge information
    ///   - failure: failure block in case error occurred
    func getGoalDetailsBy(id: String, page: Int, completion: @escaping (_ challenge: GroupActivity, _ pageLimit: Int?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let function = Constant.SubDomain.getGoals + "/\(id)" + "?page=\(page)"
        self.call(method: .get, function: function, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                var pageLimit: Int?
                if let paginationLimit = response["paginationLimit"] as? Int {
                    pageLimit = paginationLimit
                }
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let activity = try JSONDecoder().decode(GroupActivity.self, from: jsonData)
                    completion(activity, pageLimit)
                } catch (let error) {
                    DILog.print(items: error)
                    let diError = DIError(error: error)
                    failure(diError)
                }
            }
        }) { (error) in
            failure(error)
        }
    }

    /// api call to get all challenges list
    ///
    /// - Parameters:
    ///   - type: 1 for open, 2 for completed, 3 for upcoming
    ///   - page: page number
    ///   - completion: success block with data
    ///   - failure: failure block with error

    func getGoalsandChallenges(forType type: Constant.UserActivityType, page: Int, completion: @escaping (_ activities: [GroupActivity], _ pageLimit: Int?, _ pendingItemCount: Int?) -> Void, failure: @escaping (_ error: DIError) -> Void) {

        let function = Constant.SubDomain.getGoalsandChallenges + "?status=\(type.rawValue)" + "&page=\(page)"

        self.call(method: .get, function: function, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                var pageLimit: Int?
                if let paginationLimit = response["paginationLimit"] as? Int {
                    pageLimit = paginationLimit
                }
                var pendingCount = 0
                if let count = response["count"] as? Int {
                    pendingCount = count
                }
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let activities = try JSONDecoder().decode([GroupActivity].self, from: jsonData)
                    completion(activities, pageLimit, pendingCount)
                } catch (let error) {
                    DILog.print(items: error)
                    let diError = DIError(error: error)
                    failure(diError)
                }
            }
        }) { (error) in
            print(error)
            failure(error)
        }
    }


    //This Fucntion will call to join goal by goal Id.

    func  joinGoal(id: String, parameters: Parameters, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let subdomain = Constant.SubDomain.getGoals + "/\(id)/join"
        self.call(method: .post, function: subdomain, parameters: parameters, success: { (response) in
            //save new member in chat room
            if let userId = UserManager.getCurrentUser()?.id {
                ChatManager().updateUserGroupChatStatusInChatRoom(roomId: id, userId: userId, status: .active)
                ChatManager().appendMembersToChatRoom(roomId: id, memberIds: [userId])
            }
            // Join goals
            //  Analytics.logEvent("JoinGoalsCount", parameters: [:])
            AnalyticsManager.logEventWith(event: Constant.EventName.joinGoalsCount,parameter: [:])
            completion(true)
        }) { (error) in
            failure(error)
        }
    }

    /// get the list of the completed goals which are to be automatically shared to the news feed
    func getCompletedGoals(completion: @escaping (_ activities: [GroupActivity]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getCompletedGoals, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let activities = try JSONDecoder().decode([GroupActivity].self, from: jsonData)
                    completion(activities)
                } catch (let error) {
                    DILog.print(items: error)
                    let diError = DIError(error: error)
                    failure(diError)
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func startDonation(event: GroupActivity, completion: @escaping (_ response: StartDonationResponse) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        if let eventId = event.id {
            let eventType = event.type == .goal ? "goal" : "challenge"
            call(method: .post, function: "fundraising/start", parameters: ["eventId": eventId, "eventType": eventType]) { (response) in
                if let data = response["data"] as? Parameters {
                    do {
                        //get data from object
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let startDonationResponse = try JSONDecoder().decode(StartDonationResponse.self, from: jsonData)
                        completion(startDonationResponse)
                    } catch (let error) {
                        DILog.print(items: error)
                        let diError = DIError(error: error)
                        failure(diError)
                    }
                }
            } failure: { (error) in
                failure(error)
            }
        }
    }

}//Classs......
