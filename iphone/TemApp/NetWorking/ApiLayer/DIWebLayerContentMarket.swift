//
//  DIWebLayerContentMarket.swift
//  TemApp
//
//  Created by Mohit Soni on 12/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation


class DIWebLayerContentMarket: DIWebLayer{
    func getContentMarketListing(completion: @escaping(_ response: [SeeAllModel]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        
        let subDomain = Constant.SubDomain.getContentMarketListing
        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (content) in
                    completion(content)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getAffiliateData(id: String, completion: @escaping(_ response: SeeAllModel) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        
        let subDomain = "\(Constant.SubDomain.getAffiliateMarketContent)?id=\(id)"
        
        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                //get data from object
                self.decodeFrom(data: data, success: { (content) in
                    completion(content)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    
    func getAffiliateData1(id: String, completion: @escaping(_ response: SeeAllModelNew) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        
        let subDomain = "\(Constant.SubDomain.getparticularcontentdata)?contentid=\(id)"
        
        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                //get data from object
                self.decodeFrom(data: data, success: { (content) in
                    completion(content)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getMyContentList(completion: @escaping(_ response: [Tile]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        self.call(method: .get, function: Constant.SubDomain.getMyContentList, parameters: nil) { response in
            if let  data = response["data"] as? Parameters, let tilesData = data["tiles"] as? [Parameters]{
                self.decodeFrom(data: tilesData, success: { (tiles) in
                    completion(tiles)
                }, failure: { (error) in
                    failure(error)
                })
            }
        } failure: { error in
            print(error)
        }
    }
    
    func addProgram(programId: String,parameter:Parameters?, success: @escaping (_ msg:String?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        let url = "\(Constant.SubDomain.addProgram)?id=\(programId)"
        call(method: .post, function: url, parameters: parameter, success: { (response) in
            if let data = response["data"] as? Parameters{
                success(data["message"] as? String ?? "")
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func addRemoveBookmark(parameter: Parameters?, success: @escaping (_ msg: String?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method: .post, function: Constant.SubDomain.addRemoveBookmark, parameters: parameter, success: { (response) in
            if let data = response as? Parameters{
                success(data["message"] as? String ?? "")
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getAffiliateChatId(affiliateId: String, success: @escaping(_ chatRoomId: String) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        let params = ["affiliate_id": affiliateId]
        let url = Constant.SubDomain.getAffiliateChatRoomId
        call(method: .post, function: url, parameters: params) { responseValue in
            if let data = responseValue["data"] as? Parameters{
                success(data["chatroom_id"] as? String ?? "")
            }
        } failure: { error in
            failure(error)
        }
    }
}
