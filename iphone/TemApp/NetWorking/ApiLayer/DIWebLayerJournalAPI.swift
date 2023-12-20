//
//  DIWebLayerJournalAPI.swift
//  TemApp
//
//  Created by Mohit Soni on 31/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import Alamofire

class DIWebLayerJournalAPI: DIWebLayer{
    func createJournal(parameters:Parameters?, completion: @escaping(_ success:Bool) -> Void, failure: @escaping(_ error:DIError) -> Void){
        self.call(method: .post, function: Constant.SubDomain.createJournal, parameters: parameters,
                  success: { (response) in
            completion(true)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func getJournalListing(completion: @escaping(_ response: [JournalList]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        let subDomain = Constant.SubDomain.getJournalsList
        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (groups) in
                    completion(groups)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    

    func getPlanList(affiliateId: String, completion: @escaping(_ response: [PlanList]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        let subDomain = "\(Constant.SubDomain.contentplanlist)?affiliateid=\(affiliateId)"

        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (groups) in
                    completion(groups)
                }, failure: { (error) in
                    failure(error)
                    
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    
    func selectPlan(id:String,affiliateid:String,completion: @escaping(_ response: String) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        let subDomain = Constant.SubDomain.selectedplan + id
        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? String {
                completion(data)
                //get data from object
//                self.decodeFrom(data: data, success: { response in
//                    completion(response)
//                }, failure: { (error) in
//                    failure(error)
//                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func updateJournal(parameters:Parameters?, completion: @escaping(_ success:Bool) -> Void, failure: @escaping(_ error:DIError) -> Void){
        self.call(method: .put, function: Constant.SubDomain.updateJournal, parameters: parameters,
                  success: { (response) in
            completion(true)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func getProducts(completion: @escaping(_ response: String) -> (Void)){
        self.call(method: .get, function: Constant.SubDomain.fetchProducts, parameters: nil,
                  success: { (response) in
            if let msg = response["message"] as? String{
                completion(msg)
            }
        }, failure: { (error) in
           
        })
    }
}
