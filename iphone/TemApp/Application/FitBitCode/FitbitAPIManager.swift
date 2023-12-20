////
////  FitbitAPIManager.swift
////  TemApp
////
////  Created by Harpreet_kaur on 27/06/19.
////  Copyright © 2019 Capovela LLC. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class FitbitAPIManager {
//    private var session: URLSession?
//    
//    static var _sharedManager: FitbitAPIManager? = {
//        var _sharedManager = FitbitAPIManager()
//        return _sharedManager
//    }()
//    
//    //    class func shared() -> Self {
//    //        // `dispatch_once()` call was converted to a static variable initializer
//    //
//    //        return _sharedManager! as! FitbitAPIManager as! Self
//    //    }
//    
//    
//    func requestGET(_ strURL: String?, token: String?, success: @escaping (_ responseObject: [AnyHashable : Any]?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
//        
//        if !Utility.isInternetAvailable() {
//            Utility.showPopupOnTopViewController(message: AppMessages.AlertTitles.noInternet)
//        } else {
//            let manager = AFHTTPSessionManager()
//            manager.requestSerializer.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
//            manager.responseSerializer.acceptableContentTypes = manager.responseSerializer.acceptableContentTypes + Set<AnyHashable>(["text/html"])
//            manager.get(strURL, parameters: nil, progress: nil, success: { task, responseObject in
//                if (responseObject is [AnyHashable : Any]) {
//                    if success != nil {
//                        success(responseObject)
//                    }
//                } else {
//                    var response: [AnyHashable : Any]? = nil
//                    do {
//                        if let responseObject = responseObject as? Data {
//                            response = try JSONSerialization.jsonObject(with: responseObject, options: .allowFragments) as? [AnyHashable : Any]
//                        }
//                    } catch {
//                    }
//                    if success != nil {
//                        success(response)
//                    }
//                }
//                
//            }, failure: { task, error in
//                if failure != nil {
//                    failure(error)
//                }
//                
//            })
//        }
//    }
//    
//    
//    func requestPOST(_ strURL: String?, parameter param: [AnyHashable : Any]?, token: String?, success: @escaping (_ responseObject: [AnyHashable : Any]?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
//        
//        if !Utility.isInternetAvailable() {
//            Utility.showPopupOnTopViewController(message: AppMessages.AlertTitles.noInternet)
//        } else {
//            let manager = AFHTTPSessionManager()
//            manager.requestSerializer.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
//            manager.responseSerializer.acceptableContentTypes = manager.responseSerializer.acceptableContentTypes + Set<AnyHashable>(["text/html"])
//            
//            manager.post(strURL, parameters: param, progress: nil, success: { task, responseObject in
//                if (responseObject is [AnyHashable : Any]) {
//                    if success != nil {
//                        success(responseObject)
//                    }
//                } else {
//                    var response: [AnyHashable : Any]? = nil
//                    do {
//                        if let responseObject = responseObject as? Data {
//                            response = try JSONSerialization.jsonObject(with: responseObject, options: .allowFragments) as? [AnyHashable : Any]
//                        }
//                    } catch {
//                    }
//                    if success != nil {
//                        success(response)
//                    }
//                }
//                
//            }, failure: { task, error in
//                if failure != nil {
//                    failure(error)
//                }
//            })
//        }
//    }
//    
//}
