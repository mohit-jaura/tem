//
//  DeviceInfo.swift
//  SpotMe
//
//  Created by Saurav on 03/02/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
class DeviceInfo:NSObject {
 
  // MARK: Variables.....
  
  static var shared = DeviceInfo()
  
  // MARK: Private Methods...
  
   //This Function will be used to get appVersion...
  
    func getAppVersion() -> String {
        if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String {
            return text
        }else{
            return ""
        }
    }
  
  //This function to get the device Language...
  
    func getLanguage() -> String {
        let pre = Locale.preferredLanguages[0]
        return pre
    }
  
  
  //Os Version...
  
    func getOsVersion() -> String {
        let systemVersion = UIDevice.current.systemVersion
        return systemVersion
    }
  
  //Device Id...
  
    func getDeviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        return deviceId
    }
  
  //Time Zone-
    func getTimeZone() -> String {
        let timeZone =  TimeZone.current.identifier
        return timeZone 
    }
    
    //Off Set
    func getOffset() -> String {
        let offset =  TimeZone.current.secondsFromGMT()
        return "\(offset/60)"
    }
    
  //This function will get the basic info of Device
  
    
    
    
  
  //This Function will return the header content...
  
    func getHeaderContent(_ withToken:Bool? = false) -> [String:String] {
        //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YmI2ZjIwNzM5YzJjNjk4MjA4NzVmYzYiLCJlbWFpbCI6InBhcnRlZWtrdW1hcjE5OTdAZ21haWwuY29tIiwiZmlyc3ROYW1lIjoicGFydGVlayIsImxhc3ROYW1lIjoiYXJvcmEiLCJpYXQiOjE1Mzg4MjIxNDh9.9OlIiNM5bi6NCZlIpJLzgKfO02nWZctr54yfHbbfcOs"  
        let deviceId = getDeviceId()
        let deviceModel = UIDevice.current.modelName
        let appVersion = getAppVersion()
        let osVersion =  getOsVersion()
        let language = getLanguage()
        let timeZone = getTimeZone()
        let offSet = getOffset()
        var dict:[String:String] = [:]
        
        dict = ["device_id":deviceId,
                "app_version":appVersion,
                "device_type": "1",
                "Content-Type":"application/json",]
        
        if withToken == true {
            dict  =  ["device_id":deviceId,
                      "os_version":osVersion,
                      "device_model":deviceModel,
                      "app_version":appVersion,
                      "language":language,
                      "timezone":timeZone,
                      "offset": offSet,
                      "token": (UserManager.getCurrentUser()?.oauthToken ?? ""),
                      "device_type": "1",
                      "api_version": BuildConfiguration.shared.apiVersion
                
            ]
            
            return dict
            
        } else {
            dict  = ["device_id":deviceId,
                     "os_version":osVersion,
                     "device_model":deviceModel,
                     "app_version":appVersion,
                     "language":language,
                     "timezone":timeZone,
                     "offset": offSet,
                     "Content-Type":"application/json",
                     "device_type": "1",
                     "api_version": BuildConfiguration.shared.apiVersion
            ]
            return dict
        }
    }//
 
  
}//Class....
