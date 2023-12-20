//
//  DIWebLayerOrderAddressAPI.swift
//  TemApp
//
//  Created by Mohit Soni on 17/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation

class DIWebLayerOrderAddressAPI:DIWebLayer{
    
    func getAllAddresses(success:@escaping(_ addresses:[SavedAddresses]) ->  Void,failure:@escaping(_ error:DIError) ->  Void){
        let subDomain = Constant.SubDomain.getAllAddresses
        self.call(method: .get, function: subDomain, parameters: nil) { response in
            let data = response["result"] as? [Parameters]
            //get data from object
            self.decodeFrom(data: data, success: { (addresses) in
                success(addresses)
            }, failure: { (error) in
                failure(error)
            })
        } failure: { error in
            failure(error)
        }
    }
    
    func addNewAddress(parameters:Parameters,completion:@escaping(_ message:String) -> Void){
        let subDomain = Constant.SubDomain.addNewAddress
        self.call(method: .post, function: subDomain, parameters: parameters) { responseValue in
            if let message = responseValue["message"] as? String{
                completion(message)
            }
        } failure: { error in
            completion(error.message ?? "")
        }
    }
    
    func updateAddress(parameters:Parameters,completion:@escaping(_ message:String) -> Void){
        let subDomain = Constant.SubDomain.updateAddress
        self.call(method: .put, function: subDomain, parameters: parameters) { responseValue in
            if let message = responseValue["message"] as? String{
                completion(message)
            }
        } failure: { error in
            completion(error.message ?? "")
        }
    }
    
}
