//
//  DIWebLayerReportsAPI.swift
//  TemApp
//
//  Created by shilpa on 24/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import RealmSwift

class DIWebLayerReportsAPI: DIWebLayer {
    
    func getUserReport(isFullReport: Bool? = true, success: @escaping (_ report: UserActivityReport, _ challengesReport: GroupActivityReport?, _ goalsReport: GroupActivityReport?,_ graphData: [Graph_]?, _ othersGraph: [Graph_]? ) -> (), failure: @escaping (_ error: DIError) -> ())  {
        var endPoint = Constant.SubDomain.reports
        if isFullReport! {
            endPoint += "?fullReport=1&graph=1"
        } else {
            endPoint += "?fullReport=0"
        }
        self.call(method: .get, function: endPoint, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                if let totalReport = data["totalActivityReport"] as? Parameters {
                    if let challenges = data["challenges"] as? Parameters,
                       let goals = data["goals"] as? Parameters,
                       let graph = data["graph"] as? [Parameters], let otherGraph = data["otherGraph"] as? [Parameters] {
                        //get data from object
                        do {
                            //get data from object
                            ReportViewModal().saveReportsDataToRealm(report: data)
                            let totalReportJsonData = try JSONSerialization.data(withJSONObject: totalReport, options: .prettyPrinted)
                            let customType = try JSONDecoder().decode(UserActivityReport.self, from: totalReportJsonData)
                            let challengesJsonData = try JSONSerialization.data(withJSONObject: challenges, options: .prettyPrinted)
                            let challengesCustomType = try JSONDecoder().decode(GroupActivityReport.self, from: challengesJsonData)
                            let goalsJsonData = try JSONSerialization.data(withJSONObject: goals, options: .prettyPrinted)
                            let goalsCustomType = try JSONDecoder().decode(GroupActivityReport.self, from: goalsJsonData)
                            let graphjsonData = try JSONSerialization.data(withJSONObject: graph, options: .prettyPrinted)
                            let othersGraphjsonData = try JSONSerialization.data(withJSONObject: otherGraph, options: .prettyPrinted)
                            let graph = try JSONDecoder().decode([Graph_].self, from: graphjsonData)
                            let othersGraph = try JSONDecoder().decode([Graph_].self, from: othersGraphjsonData)
                            success(customType, challengesCustomType, goalsCustomType, graph, othersGraph)
                        } catch (let error) {
                            print("error in decoding \(error)")
                            failure(DIError(error: error))
                        }
                    } else {
                        do {
                            //get data from object
                            let totalReportJsonData = try JSONSerialization.data(withJSONObject: totalReport, options: .prettyPrinted)
                            let customType = try JSONDecoder().decode(UserActivityReport.self, from: totalReportJsonData)
                            success(customType, nil, nil, nil, nil)
                        } catch (let error) {
                            print("error in decoding \(error)")
                            failure(DIError(error: error))
                        }
                    }
                } else {
                    success(UserActivityReport(), nil, nil,[], [])
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    
    //get the total activities of user from server
    func getTotalActivities(page: Int, endPoint: String, success: @escaping(_ activities: [UserActivity], _ pageLimit: Int) -> (), failure: @escaping (_ error: DIError) -> Void) {
        var subdomain = "reports" + "/getActivities?page=\(page)"
        if !endPoint.isEmpty {
            subdomain += endPoint
        }
        self.call(method: .get, function: subdomain, parameters: nil, success: { (response) in
            if let dataResp = response["data"] as? Parameters,
               let data = dataResp["resp"] as? [Parameters] {
                var pageLimit: Int = 15
                if let limit = dataResp["pagination_limit"] as? Int {
                    pageLimit = limit
                }
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let activities = try JSONDecoder().decode([UserActivity].self, from: jsonData)
                    success(activities, pageLimit)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                    let diError = DIError(error: error)
                    failure(diError)
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func shareActivityReport(success: @escaping(_ message: String) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let endPoint = Constant.SubDomain.reports + "/PDF"
        self.call(method: .get, function: endPoint, parameters: nil, success: { (response) in
            print(response)
            if let message = response["message"] as? String {
                success(message)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func updateSleepTime(last30DaysTime: Double, lastToLast30DaysTime: Double?, completion: @escaping(_ success: Bool) -> ()) {
        var endPoint = Constant.SubDomain.updateSleepTime + "?last30=\(last30DaysTime)"
        if let tym = lastToLast30DaysTime {
            endPoint += "&last3060=\(tym)"
        }
        self.call(method: .get, function: endPoint, parameters: nil, success: { (response) in
            completion(true)
        }) { (_) in
            completion(false)
        }
    }
    
    /// get radar score of user, this will include social score, nutrition, physical, mental
    func getRadarScore(completion: @escaping (_ radar: HealthRadar) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.radar, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data, success: { (radar) in
                    completion(radar)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    ///delete activity api function
    ///activityId: activity id of the activity to be deleted
    func deleteActivity(activityId: String, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        
        let params: [String: Any] = ["activityId": activityId]
        self.call(method: .post, function: Constant.SubDomain.deleteActivity, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func updateActivity(parameters: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.updateActivity, parameters: parameters, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    func completeActivity(parameters: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.completeUserActivity, parameters: parameters, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func addActivity( parameters: Parameters?, completion: @escaping (_ success: AddActivity) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        
        self.call(method: .post, function: Constant.SubDomain.addActivity, parameters: parameters, success: { (response) in
            if let data = response["data"] as? NSDictionary {
                //get data from object
                self.decodeFrom(data: data, success: { (response) in
                    completion(response)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    func createActivitiesLog(parameters:Parameters?, completion: @escaping(_ success:Bool) -> Void, failure: @escaping(_ error:DIError) -> Void){
        self.call(method: .post, function: Constant.SubDomain.createActivitiesLog, parameters: parameters,
                  success: { (response) in
            completion(true)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func getActivitiesLog(completion: @escaping(_ response: [ActivitiesLog]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        self.call(method: .get, function: Constant.SubDomain.getActivitiesLog, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (acitivityLog) in
                    completion(acitivityLog)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    
    
    
    
    func getAffilativeCommunity(id: String,completion: @escaping(_ response: [AffilativeCommunityDataModel]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        let url = "\(Constant.SubDomain.getAffilativeCommunity)/\(id)"
        self.call(method: .get, function: url , parameters: nil, success: { (response) in
            if let data = response["contentlistwise"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (affilativeCommunityDataModel) in
                    completion(affilativeCommunityDataModel)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getAffilativeContent(id:String = "",completion: @escaping(_ response: [AffilativeContentModel]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        self.call(method: .get, function: Constant.SubDomain.getAffilativeContent + id, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (affilativeContentModel) in
                    completion(affilativeContentModel)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
}


struct AddActivity: Codable{
    var id : String
    var startDate: Int
    
    enum CodingKeys: String, CodingKey{
        case id = "_id"
        case startDate = "startDate"
    }
}
