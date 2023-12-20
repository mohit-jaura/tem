//
//  DIWebLayerSettings.swift
//  TemApp
//
//  Created by Harpreet_kaur on 19/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
class SettingsAPI:DIWebLayer {
    
    
    // MARK: Disbale Account.
    func disableAccount( success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post ,function: Constant.SubDomain.deleteAccount, parameters: nil, success: { dataResponse in
            if let status = dataResponse["status"] as? Int , status == 1 , let message = dataResponse["message"] as? String {
                success(message)
                return
            }
        }) {
            failure($0)
        }
    }
    
    // MARK: Get FAQS.
    func getFaqs( success: @escaping (_ data: [FaqData]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .get ,function: Constant.SubDomain.faqs, parameters: nil, success: { dataResponse in
            if let status = dataResponse["status"] as? Int , status == 1  {
                let data = FaqDataArray(dataResponse)
                success(data.data)
                return
            }
        }) {
            failure($0)
        }
    }
    
    // MARK: Contact Administrator
    func contactAdmin (parameters: Parameters?, success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.contactAdmin, parameters: parameters, success: { dataResponse in
            if let status = dataResponse["status"] as? Int, status == 1,let message = dataResponse["message"] as? String {
                success(message)
                return
            }
        }) {
            failure($0)
            
        }
    }
    
    // MARK: Change PassWord.
    func changePassword (parameters: Parameters?, success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.changePassword, parameters: parameters, success: { dataResponse in
            if let status = dataResponse["status"] as? Int, status == 1,let message = dataResponse["message"] as? String {
                success(message)
                return
            }
        }) {
            failure($0)
            
        }
    }
    
    //    // MARK: Change setting status.
    //    func changeStatus (parameters: Parameters?, success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
    //        self.webService(parameters: parameters, function: APIFunctionName.settings, success: { dataResponse in
    //            if let status = dataResponse["status"] as? Int, status == 1,let message = dataResponse["message"] as? String {
    //                success(message)
    //                return
    //            }
    //        }) {
    //            failure($0)
    //
    //        }
    //    }
    
    // MARK: Get Blocked User.
    func searchBlockedUser(parameters: Parameters?, page: Int,success: @escaping (_ data: [Friends]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post ,function: "\(Constant.SubDomain.searchBlockedUser)?page=\(page)&limit=15", parameters: parameters, success: { dataResponse in
            if let status = dataResponse["status"] as? Int , status == 1 {
                if let data = dataResponse["data"] as? [Parameters] {
                    self.decodeFrom(data: data, success: { (response) in
                        success(response)
                    }, failure: { (error) in
                        
                    })
                }
            }
        }) {
            failure($0)
            
        }
    }
    // MARK: Get Blocked User.
    func getBlockedUser(page: Int, success: @escaping (_ data: [Friends]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .get ,function: "\(Constant.SubDomain.blockedUser)?page=\(page)&limit=15", parameters: nil, success: { dataResponse in
            if let status = dataResponse["status"] as? Int , status == 1 {
                if let data = dataResponse["data"] as? [Parameters] {
                    self.decodeFrom(data: data, success: { (response) in
                        success(response)
                    }, failure: { (error) in
                        
                    })
                }
            }
        }) {
            failure($0)
            
        }
    }
    
    // MARK: Get Blocked User.
    func setProfifePrivate( success: @escaping (_ status: Bool) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.setProprivate, parameters: nil, success: { dataResponse in
            if let status = dataResponse["status"] as? Int , status == 1 {
                success(true)
                return
            }
        }) {
            failure($0)
            
        }
    }
    // MARK: Set Push Notification Status.
    func setPushNotificationStatus( success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.pushNotificationToggle, parameters: nil, success: { dataResponse in
            if let status = dataResponse["status"] as? Int , status == 1 {
                success(dataResponse["message"] as? String ?? "")
                return
            }
        }) {
            failure($0)
            
        }
    }
    
    // MARK: Set Clender 
    func setCalenderNotificationStatus(success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.calenderNotification, parameters: nil, success: { dataResponse in
            if let status = dataResponse["status"] as? Int , status == 1 {
                success(dataResponse["message"] as? String ?? "")
                return
            }
        }) {
            failure($0)
            
        }
    }
}
