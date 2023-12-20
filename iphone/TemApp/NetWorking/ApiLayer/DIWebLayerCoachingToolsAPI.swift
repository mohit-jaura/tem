//
//  DIWebLayerCoachingToolsAPI.swift
//  TemApp
//
//  Created by Shiwani Sharma on 21/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

class DIWebLayerCoachingToolsAPI: DIWebLayer{


    func getCoachProfileData(coachID: String, success: @escaping (_ response: CoachProfile) -> (), failure: @escaping (_ error: DIError) -> ()) {
        let url = "\(Constant.SubDomain.getCoachProfile)\(coachID)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data, success: { (coachData) in
                    success(coachData)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }

    func getCheckoutURL(params: Parameters, success: @escaping(_ message:String) ->  Void,failure: @escaping (_ error: String) -> Void){
        let url = "\(Constant.SubDomain.checkoutUrl)"
        self.call(method: .post, function: url, parameters: params, success: { response in
            if let data = response["url"] as? String {
                success(data)
            }
        }, failure: { error in
            print(error)
            failure(error.message ?? "")
        })
    }

    func cancelSubscription(serviceId: String, affiliateId: String, success: @escaping(_ message:String) ->  Void,failure: @escaping (_ error: String) -> Void){
        let url = "\(Constant.SubDomain.cancelSuscriptionCoach)\(affiliateId)/\(serviceId)"
        self.call(method: .post, function: url, parameters: nil, success: { response in
            if let data = response["message"] as? String {
                success(data)
            }
        }, failure: { error in
            print(error)
            failure(error.message ?? "")
        })
    }


    func getCoachList(success: @escaping (_ response: [CoachList]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        let url = "\(Constant.SubDomain.getCoachList)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
               if let data = data["data"]
                {
                   self.decodeFrom(data: data, success: { (coachData) in
                       success(coachData)
                   }, failure: { (error) in
                       failure(error)
                   })
               }
            }
        }) { (error) in
            failure(error)
        }
    }

    func getStatsData(success: @escaping (_ response: Stats) -> (), failure: @escaping (_ error: DIError) -> ()) {
        let date = Date()
        let startDate = date.startOfDay.locaToUTCString(inFormat: .preDefined)
        let endDate = date.endOfDay.locaToUTCString(inFormat: .preDefined)
        let query = "?startDate=\(startDate)&endDate=\(endDate)"
        let url = Constant.SubDomain.getStatsData + query
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                    self.decodeFrom(data: data, success: { (coachData) in
                        success(coachData)
                    }, failure: { (error) in
                        failure(error)
                    })
            }
        }) { (error) in
            failure(error)
        }
    }

    func getFaqsList(affiliateId: String, success: @escaping (_ response: [FaqList]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        let url = "\(Constant.SubDomain.getFaqs)\(affiliateId)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                if let data = data["data"]
                {
                    self.decodeFrom(data: data, success: { (list) in
                        success(list)
                    }, failure: { (error) in
                        failure(error)
                    })
                }
            }
        }) { (error) in
            failure(error)
        }
    }
}
