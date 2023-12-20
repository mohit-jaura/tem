//
//  ActivityNetworkLayer.swift
//  TemWatchApp Extension
//
//  Created by shilpa on 13/04/20.
//

import Foundation

class ActivityNetworkLayer: NetworkLayer {
    /// decode the json response from server to the custom model type
    ///
    /// - Parameters:
    ///   - data: response from server which needs to be decoded to codable type
    ///   - type: the custom Codable model type to which server response is to be converted
    ///   - success: the success completion invoked if decoding to custom model type is successfull
    ///   - failure: error block invoked, if any error occurs
    private func decodeFrom<T: Codable>(data: Any, toType type: T.Type, success: ((_ type: T) -> ()), failure: (_ error: DIError) -> Void) {
        do {
            //get data from object
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let customType = try JSONDecoder().decode(type, from: jsonData)
            success(customType)
        } catch (let error) {
            print("error in decoding \(error)")
            failure(DIError(error: error))
        }
    }

    ///get the user activity score api call
    func getUserScore(fullReport: Bool, completion: @escaping (_ score: UserActivityReport) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var path = WatchConstants.Subdomain.getUserReportScore
        if !fullReport {
            path += "?fullReport=0"
        } else {
            path += "?fullReport=1"
        }
        self.sendRequest(method: .get, parameters: nil, urlPath: path, completion: { (response) in
            if let data = response["data"] as? Parameters,
                let totalReport = data["totalActivityReport"] as? Parameters {
                self.decodeFrom(data: totalReport, toType: UserActivityReport.self, success: { (score) in
                    completion(score)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            //- Handle error
        }
    }

    /// get the list of activities, durations and distances
    /// - Parameter completion: list of data
    func getActivitiesList(completion: @escaping (_ activities: [ActivityCategory]?, _ distances: [MetricValue]?, _ duration: [MetricValue]?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var activitiesList: [ActivityCategory]?
//        var distanceList: [MetricValue]?
//        var durationList: [MetricValue]?
//        let group = DispatchGroup()
//        group.enter()
        self.sendRequest(method: .get, parameters: nil, urlPath: WatchConstants.Subdomain.getActivities, completion: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, toType: [ActivityCategory].self, success: { (activities) in
                    activitiesList = activities
                    //group.leave()
                    completion(activitiesList, nil, nil)
                }) { (error) in
                    //group.leave()
                    failure(error)
                }
            }
        }) { (error) in
            failure(error)
            //group.leave()
            //- Handle error
        }
        /*group.enter()
        self.getDurationList(success: { (duration) in
            durationList = duration
            group.leave()
        }) { (error) in
            failure(error)
            group.leave()
        }
        group.enter()
        self.getDistanceList(success: { (distances) in
            distanceList = distances
            group.leave()
        }) { (error) in
            failure(error)
            group.leave()
        }
        group.notify(queue: .main) {
            completion(activitiesList, distanceList, durationList)
        } */
    }

    func getDurationList(success: @escaping (_ response: [MetricValue]) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.sendRequest(method: .get, parameters: nil, urlPath: WatchConstants.Subdomain.durationListing, completion: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, toType: [MetricValue].self, success: { (activities) in
                    success(activities)
                }) { (error) in

                }
            }
        }) { (error) in
            //- Handle error
            failure(error)
        }
    }

    func getDistanceList(success: @escaping (_ response: [MetricValue]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.sendRequest(method: .get, parameters: nil, urlPath: WatchConstants.Subdomain.distanceListing, completion: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, toType: [MetricValue].self, success: { (activities) in
                    success(activities)
                }) { (error) in

                }
            }
        }) { (error) in
            //- Handle error
            failure(error)
        }
    }

    /// create user activity on server
    /// - Parameter parameters: parameters
    /// - Parameter success: completion
    /// - Parameter failure: failure
    func createActivity(parameters: Parameters?,success: @escaping (_ response: Parameters) -> (), failure: @escaping (_ error: DIError) -> ()){
        DILog.print(items: "parameters: \(parameters)")
        self.sendRequest(method: .post, parameters: parameters, urlPath: WatchConstants.Subdomain.startUserActivity, completion: { (response) in
            if let status = response["status"] as? Int , status == 1 {
                if let data = response["data"] as? Parameters {
                    success(data)
                    return
                }
            }
        }) { (error) in
            failure(error)
        }
    }

    //Function to complete User Actvity.
    func completeActivity(parameters: Parameters?,success: @escaping (_ response: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.sendRequest(method: .post, parameters: parameters, urlPath: WatchConstants.Subdomain.completeUserActivity, completion: { (response) in
            if let status = response["status"] as? Int , status == 1 {
                if let data = response["message"] as? String {
                    success(data)
                    return
                }
            }
        }) { (error) in
            failure(error)
        }
    }
}
