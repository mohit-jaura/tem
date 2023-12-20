//
//  DIWebLayerActivityAPI.swift
//  TemApp
//
//  Created by Harpreet_kaur on 30/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase
class DIWebLayerActivityAPI: DIWebLayer {

    // MARK: Function to get activities from server
    func getUserActivity(forType type: Constant.ScreenFrom? = nil, success: @escaping (_ response: [ActivityCategory]) -> (), failure: @escaping (_ error: DIError) -> ()){
        var subdomain = Constant.SubDomain.getActivity
        if let type = type {
            if type == .createChallenge {
                subdomain += "?type=1"
            }
            if type == .createGoal {
                subdomain += "?type=2"
            }
        }
        self.call(method:.get,function: subdomain, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters] {
                do {
                    //get data from object
                    if type == nil {
                        ActivitiesViewModal().saveActivitiesDataToRealm(data: response)
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let activityData = try JSONDecoder().decode([ActivityCategory].self, from: jsonData)
                    success(activityData)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                }
            }else{

            }
        }) {
            failure($0)
        }
    }

    
    
    // MARK: Function to get activities from server
    func getUserActivityNew(forType type: Constant.ScreenFrom? = nil, success: @escaping (_ response: [ActivityData]) -> (), failure: @escaping (_ error: DIError) -> ()){
        var subdomain = Constant.SubDomain.getActivity
        if let type = type {
            if type == .createChallenge {
                subdomain += "?type=1"
            }
            if type == .createGoal {
                subdomain += "?type=2"
            }
        }
        self.call(method:.get,function: subdomain, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters] {
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let activityData = try JSONDecoder().decode([ActivityData].self, from: jsonData)
                    success(activityData)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                }
            }else{

            }
        }) {
            failure($0)
        }
    }
    
    
    
    // MARK: Function to get Duration List from server
    func getDurationList(success: @escaping (_ response: [MetricValue]) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.get,function: Constant.SubDomain.durationList, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters] {
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let metricValue = try JSONDecoder().decode([MetricValue].self, from: jsonData)
                    success(metricValue)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                }
            }else{

            }
        }) {
            failure($0)
        }
    }

    // MARK: Function to get Distance List from server
    func getDistanceList(success: @escaping (_ response: [MetricValue]) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.get,function: Constant.SubDomain.distanceList, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters] {
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let metricValue = try JSONDecoder().decode([MetricValue].self, from: jsonData)
                    success(metricValue)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                }
            }else{

            }
        }) {
            failure($0)
        }
    }

    // MARK: Function to create User Actvity.
    func createActivity(parameters: Parameters?,success: @escaping (_ response: Parameters) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.post,function: Constant.SubDomain.startUserActivity, parameters: parameters, success: { response in
            if let status = response["status"] as? Int , status == 1 {
                if let data = response["data"] as? Parameters {
                    success(data)
                    return
                }
            }
        }) {
            failure($0)
        }
    }
    
    func rateActivity(parameters: Parameters?, success: @escaping ( _ response: String) -> (), failure: @escaping(_ error: DIError) -> () ){
        self.call(method:.post,function: Constant.SubDomain.rateActivity, parameters: parameters, success: { response in
            if let status = response["status"] as? Int , status == 1 {
                if let data = response["data"] as? String {
                    success(data)
                    return
                }
            }
        }) {
            failure($0)
        }
    }

    // MARK: Function to create User Actvity.
    func completeActivity(parameters: Parameters?,success: @escaping (_ response: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.post,function: Constant.SubDomain.completeUserActivity, parameters: parameters, success: { response in
            if let status = response["status"] as? Int , status == 1 {
                if let data = response["message"] as? String {
                    success(data)
                    return
                }
            }
        }) {
            failure($0)
        }
    }
    
    func importActivities(parameters: Parameters?, success: @escaping (_ response: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.post, function: Constant.SubDomain.importExternalUserActivities, parameters: parameters, success: { response in
            if let status = response["status"] as? Int , status == 1 {
                if let data = response["message"] as? String {
                    success(data)
                    return
                }
            }
            let e = DIError(title: nil, message: "Error while importing activities", code: .unknown)
            failure(e)
        }) {
            failure($0)
        }
    }

    ///Updates the user steps count to server.
    func updateStepsOfUser(parameters: Parameters, success: @escaping (_ finished: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method:.post,function: Constant.SubDomain.updateSteps, parameters: parameters, success: { response in
            success(true)
        }) {
            failure($0)
        }
    }

    func createChallenge(method: HTTPMethod, parameters: Parameters, completion: @escaping (_ message: String?, _ data: GroupActivity?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: method, function: Constant.SubDomain.challenge, parameters: parameters, success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data, success: { (activityInfo) in
                    completion(response["message"] as? String ?? "", activityInfo)
                }) { (error) in
                    failure(error)
                }
            } else {
                if let message = response["message"] as? String {
                    completion(message, nil)
                } else {
                    completion(nil, nil)
                }
            }
        }) { (error) in
            failure(error)
        }
    }


    /// api call to get all Goals list
    ///
    /// - Parameters:
    ///   - type: 1 for open, 2 for completed, 3 for upcoming
    ///   - page: page number
    ///   - completion: success block with data
    ///   - failure: failure block with error
    func getChallenges(forType type: Constant.UserActivityType, groupId: String?, page: Int, completion: @escaping (_ activities: [GroupActivity], _ pageLimit: Int?, _ pendingItemCount: Int?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var subdomain = ""
        if groupId != nil {
            subdomain = Constant.SubDomain.getGroupChallenges
        } else {
            subdomain = Constant.SubDomain.challenge
        }
        var function = subdomain + "?status=\(type.rawValue)" + "&page=\(page)"
        if let groupId = groupId {
            function += "&group_id=\(groupId)"
        }
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
                    completion(activities, pageLimit,pendingCount)
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

    /// get the challenge details by id
    ///
    /// - Parameters:
    ///   - id: challenge id
    ///   - completion: success block with challenge information
    ///   - failure: failure block in case error occurred
    func getChallengeDetailsBy(id: String, page: Int, completion: @escaping (_ challenge: GroupActivity, _ pageLimit: Int?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let function = Constant.SubDomain.challenge + "/\(id)" + "?page=\(page)"
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

    func  joinActivity(isChallenge: Bool? = true, id: String, parameters: Parameters, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        
//        completion(true)
        var subdomain = Constant.SubDomain.challenge + "/\(id)/join"
        if !isChallenge! {
            subdomain = Constant.SubDomain.getGoals + "/\(id)/join"
        }
        self.call(method: .post, function: subdomain, parameters: parameters, success: { (response) in

            //save new member in chat room
            if let userId = UserManager.getCurrentUser()?.id {
                ChatManager().updateUserGroupChatStatusInChatRoom(roomId: id, userId: userId, status: .active)
                ChatManager().appendMembersToChatRoom(roomId: id, memberIds: [userId])
            }
            //Join Challenge
           // Analytics.logEvent("JoinChallengesCount", parameters: [:])
            AnalyticsManager.logEventWith(event: Constant.EventName.joinChallengesCount,parameter: [:])
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    // MARK: Event Activity Add on
    func startEventActivityAddOn(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionDataApi){
        
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(EventActStartDataModal.self, from: data)

                if modal.status == 1 {
                    completion(.Success(modal.data, modal.message))

                }else {
                    completion(.Failure(modal.message))
                }
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }
             completion(.Failure(error.message))
        }
    }
    
    func skipEventActivityAddOn(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionResponse){
        
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(ProductModal.self, from: data)

                if modal.status == 1 {
                    completion(.Success(modal.message))

                }else {
                    completion(.Failure(modal.message))
                }
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }
             completion(.Failure(error.message))
        }
    }
    func completeEventActivityAddOn(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionResponse){
        
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(DefaultModal.self, from: data)

                if modal.status == 1 {
                    completion(.Success(modal.message))

                }else {
                    completion(.Failure(modal.message))
                }
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }
             completion(.Failure(error.message))
        }
    }
    
    func completeProgramEvent(parameter:Parameters?,success: @escaping (_ data: String?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
    call(method: .post, function: Constant.SubDomain.completeProgramEvent, parameters: parameter, success: { (response) in
        success(response["data"] as? String)
    }) { (error) in
        failure(error)
    }
}
    func getRating(completion: @escaping(_ success: RatingData) -> Void, failure: @escaping(_ error:DIError) -> Void){
        self.call(method: .get, function: Constant.SubDomain.createRating, parameters: nil,
                  success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data, success: { (data) in
                    completion(data)
                }, failure: { (error) in
                    print(error)
                })
            }
            
        }, failure: { (error) in
            failure(error)
        })
    }
    
}
