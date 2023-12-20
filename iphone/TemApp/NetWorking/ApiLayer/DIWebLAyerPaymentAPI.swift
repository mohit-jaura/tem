//
//  DIWebLAyerPaymentAPI.swift
//  TemApp
//
//  Created by Shiwani Sharma on 30/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class DIWebLAyerPaymentAPI: DIWebLayer {
    
    func getPaymentHistory(startDate:Int,endDate:Int,month:String,success: @escaping(_ data: [PaymentHistory], _ firstPaymentDate: String ) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let url = "\(Constant.SubDomain.getPaymentHistory)?startdate=\(startDate)&enddate=\(endDate)&month=\(month)"
        self.call(method: .get, function: url , parameters: nil, success: { (response) in
            var firstPaymentDate = ""
            if let date = response["extenddate"] as? String {
                firstPaymentDate = date
            }
            if let data = response["data"] as? [Parameters]{
                self.decodeFrom(data: data, success: { (history) in
                    success(history,firstPaymentDate)
                }, failure: { (error) in
                    failure(error)
                })
            }
            
        }, failure: { error in
            print(error)
            failure(error)
        })
    }
    
    func cancelSubscription(params: Parameters, success: @escaping(_ message:String) ->  Void,failure: @escaping (_ error: String) -> Void){
        let url = "\(Constant.SubDomain.cancelSubscription)"
        self.call(method: .post, function: url, parameters: params, success: { response in
            if let data = response["data"] as? String {
                success(data)
            }
        }, failure: { error in
            print(error)
            failure(error.message ?? "")
        })
    }
    
    func upgradePlan(parameters: Parameters,success:@escaping(_ mesage: String) ->  Void , failure: @escaping (_ error: String) -> Void){
        let url = Constant.SubDomain.upgradeSubscription
        self.call(method: .post, function: url, parameters: parameters, success: { response in
            print(response)
            if let link = response["genratelink"] as? String {
                success(link)
            }
        }, failure: { error in
            print(error)
            failure(error.message ?? "")
        })
    }
    
    func downgradePlan(planId: String, affiliateId: String,activeId: String,success:@escaping(_ mesage: String) ->  Void , failure: @escaping (_ error: String) -> Void){
        let url = "\(Constant.SubDomain.downgradeSubscription)?id=\(planId)&affiliateid=\(affiliateId)&activeid=\(activeId)"
        self.call(method: .get, function: url, parameters: nil, success: { response in
            print(response)
            if let data = response["message"] as? String {
                success(data)
            }
        }, failure: { error in
            print(error)
            failure(error.message ?? "")
        })
    }
    
    
    func getAddedCards(completion: @escaping(_ response: [CardsDetails]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        let uuid = UserManager.getCurrentUser()?.id ?? ""
        let subDomain = Constant.SubDomain.getAddedCards+uuid
        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (cards) in
                    completion(cards)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    
    func removeCard(cardId:String, completion: @escaping(_ message: String) -> Void ) {
        let subdomain = Constant.SubDomain.removeCard
        self.call(method: .post, function: subdomain, parameters: ["id":cardId], success: { (response) in
            if let data = response["data"] as? Response{
                if let message = data["message"] as? String{
                    completion(message)
                }
            }
        }, failure: { error in
            print(error)
            completion(error.message ?? "")
        })
    }
}
