//
//  DiSessionManger.swift
//  BaseProject
//
//  Created by Aj Mehra on 08/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import NVActivityIndicatorView
import SideMenu

typealias Success = (_ json:JSONObject) -> ()
typealias Failure = (_ error: DIError) -> ()
typealias Headers    = [String: String]

var timeout = 2 // seconds

typealias JSON = [String: Any]

typealias SuccessWidthEmptyBlock = () -> ()
typealias SuccessWithMessage = (_ message:String) -> ()

typealias Parameters = [String: Any]
typealias Parameters1 = [[String: Any]]
typealias Response = [String: Any]

// This could be a nested type inside JSONObject if you wanted.
enum JSONKeys: String {
    case status
    case data
    case message
    case friends
}

// Here's my JSONObject. It's much more type-safe than the dictionary,
// and it's trivial to add methods to it.
struct JSONObject {
    
    let json: [String: Any]
    
    init(_ json: [String: Any]) {
        self.json = json
    }
    
    // You of course could make this generic if you wanted so that it
    // didn't have to be exactly JSONKeys. And of course you could add
    // a setter.
    subscript(key: JSONKeys) -> Any? {
        return json[key.rawValue]
    }
}


enum HttpContentType: String {
  case urlecncoded = "application/x-www-form-urlencoded"
  case json = "application/json"
  case multipart = "multipart/form-data; boundary="
}

enum response: Int {
    case okResponse = 200
    case failureResponse = 400
}

class APIHandler {
  
  //Envirnoment Change
    func defaultHeader() -> [String: String] {
        var header = [String: String]()
        if UserManager.isUserLoggedIn() {
            header =  DeviceInfo.shared.getHeaderContent(true)
        } else {
            header =  DeviceInfo.shared.getHeaderContent(false)
        }
        
        return header
    }
  
    func post(method: Alamofire.HTTPMethod, function: String, parameters: Parameters?, success: @escaping (_ responseValue: Data) -> (), failure: @escaping (_ error: DIError) -> ()) {
        if !Reachability.isConnectedToNetwork() {
            if (Utility.getCurrentViewController() as? ActivityProgressController) != nil {
                return
            }
            failure(DIError.internetConnection())
            return
        }
        URLCache.shared.removeAllCachedResponses()
        
//        let manager = Alamofire.SessionManager.default
//        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(timeout)

        Alamofire.request(absolutePath(forApi: function), method: method, parameters: parameters, encoding: JSONEncoding.default, headers: defaultHeader())
            .responseJSON { result in
                
                DILog.print(items: "URL -> \(self.absolutePath(forApi: function))")
                DILog.print(items: "method -> \(method)")
                if let param = parameters {
                    DILog.print(items: "Parameters ->\(String(describing: param)) ")
                }
                DILog.print(items: "Headers ->\(self.defaultHeader()) ")
                DILog.print(items: "Reponse  ->\(result) ")
                DILog.print(items: "Reponse Code ->\(String(describing: result.response?.statusCode)) ")
                
                if let errorResponse = result.error {
                    if errorResponse._code == -999{
                        return
                    }
                    failure(self.parseError(error: errorResponse))
                    return
                } else if let httpResponse = result.response {
                    if httpResponse.statusCode == 200 {
                        if let data = result.data {
                            success(data)
                            return
                        }
                    } else if httpResponse.statusCode == 405 {
                        do {
                            if let data = result.data {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            guard let responseDict = json as? [String: AnyObject] else {
                                return
                            }
                            failure(DIError.userDisableResponseError(message:responseDict["message"] as? String ?? ""))
                            return
                            }
                        } catch {
                        }
                        
                        
                    }
                    else if httpResponse.statusCode == 400 {
                        let error = self.handleResponseData(data: result.data)
                        failure(error)
                        return
                    }
                    else if httpResponse.statusCode == 500 {
                        failure(DIError.serverResponseError(message: AppMessages.APIResponse.internalServerError))
                        return
                    }
                    else if httpResponse.statusCode == 401 {
                        let error = self.handleResponseData(data: result.data,isSessionExpire: true)
                        if (Utility.getCurrentViewController() as? ActivityProgressController) != nil {
                            SideMenuManager.default.rightMenuNavigationController?.dismiss(animated: false, completion: nil)
                            UserManager.logout()
                            let loginVC:LoginViewController = UIStoryboard(storyboard: .main).initVC()
                            appDelegate.setNavigationToRoot(viewContoller: loginVC)
                        }
                        //if user is logged in, log him out of the application
                        if UserManager.isUserLoggedIn() {
                            if UserManager.isUserLoggedIn() {
                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                                Utility.userLogoutPopup(message: error.message)
                            }
                        } else {
                            failure(error)
                        }
                        return
                    }
                    else if httpResponse.statusCode == 403 {
                        _ = self.handleResponseData(data: result.data)
                        // CustomAlertManager.shared.showCustomAlert(title: AppMessages.APIResponse.planExpired, message: error.message ?? "")
                        return
                    }
                    else if httpResponse.statusCode == 503 {
                        failure(DIError.serverResponseError(message: AppMessages.APIResponse.clientError))
                        return
                    }
                    else if httpResponse.statusCode == 422 {
                        let error = self.handleResponseErrorData(data: result.data)
                        failure(error)
                        return
                    }
                }
                failure(DIError.nilData())
        }
        
    }
  
    func uploadMultipart(parameters: Parameters?, file: Data, mimeType: String, key: String, fileName: String, url: URLConvertible, success: @escaping (_ imageUrl: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
//        let manager = Alamofire.SessionManager.default
//        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(timeout)
        print("multipart upload: \(url)")
        Alamofire.upload(multipartFormData: { (multiPart) in
            if parameters != nil {
                for (key, value) in parameters! {
                    multiPart.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            print("mime type ==================>\(mimeType)")
            //mime type for video: "video/mp4"
            multiPart.append(file, withName: key, fileName: fileName, mimeType: mimeType)
        }, usingThreshold: 10000, to: url, method: .post) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                print("got success multipart")
                upload.responseString(completionHandler: { (response) in
                    print("response string")
                    print(response)
                })
                upload.responseJSON { response in
                    print("got response multipart")
                    print(response)
                    print(response.result.isSuccess)
                    if let headers = response.response?.allHeaderFields,
                        let location = headers["Location"] as? String {
                        success(location)
                        return
                    }
                    switch response.result {
                    case .failure(let error):
                        failure(DIError(error: error))
                    default:
                        break
                    }
                }
            case .failure(let error):
                failure(self.parseError(error: error))
            }
        }
    }
  
  func multipart(parameters: Parameters?, image: UIImage, key: String, fileName: String, function: String, success: @escaping (_ responseData: Data?) -> (), failure: @escaping (_ error: DIError) -> ()) {
    
    Alamofire.upload(multipartFormData: { (multiPart) in
      
      multiPart.append(image.jpegData(compressionQuality: 0.5)!, withName: key, fileName: fileName, mimeType: "image/jpeg")
      
      if parameters != nil {
        for (key, value) in parameters! {
          multiPart.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
        }
      }
    }, usingThreshold: 10000, to: absolutePath(forApi: function), method: .post, headers: defaultHeader()) { (encodingResult) in
      switch encodingResult {
      case .success(let upload, _, _):
        
        upload.responseJSON { response in
          
          guard response.result.isSuccess else {
            failure(DIError.nilData())
            return
          }
          
          guard let responseJSON = response.result.value as? [String: AnyObject] else {
           DILog.print(items: "Invalid information received from service")
            failure(DIError.nilData())
            return
          }
         DILog.print(items: responseJSON)
          
          if let data = response.data {
            success(data)
            return
          }
        }
      case .failure(let error):
        failure(self.parseError(error: error))
      }
    }
  }
  
  
    /// This method will create the complete path for the api request with the help of base url, version and domain Name
    ///
    /// - Parameter apiName: Name of api domin like login
    /// - Returns: complete Url String
    func absolutePath(forApi apiName: String) -> String {
        var path = BuildConfiguration.shared.serverUrl
        let version = BuildConfiguration.shared.apiVersion
        if !path.hasSuffix("/") {
            path += "/"
        }
        if version.isEmpty {
            return path + apiName
        }
        if !version.hasSuffix("/") {
            path += version + "/"
        } else {
            path += version
        }
        return path + apiName
    }
    
    /// This method will parse the error catch through the Api session manager and return an object of DIError with details about the error for debugging purpose
    ///
    /// - Parameter error: error catch by session manager
    /// - Returns: Convert Object to display error to user
    func parseError(error: Error) -> DIError {
        if error._code == -1001 || error._code == -1004 || error._code == -1005 {
            return DIError(title: "", message:AppMessages.APIResponse.requestTimeOut, code: .invalidUrl)
        }else {
            return DIError(title: "", message:AppMessages.APIResponse.internalServerError, code: .invalidUrl)
        }
    }
    
    func handleResponseData(data: Data?,isSessionExpire:Bool = false) -> DIError {
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            guard let responseDict = json as? [String: AnyObject] else {
                return (DIError.invalidData())
            }
            if let message = responseDict["message"] as? String {
                if isSessionExpire {
                    return (DIError.serverResponse(message: message))
                }
                return (DIError.serverResponse(message: message))
            }
            if let error = responseDict["error"] as? String {
                return (DIError.serverResponse(message: error))
            }
            return (DIError.missingKey())
        } catch {
            return (DIError.invalidJSON())
        }
    }
    
   
    
    func handleResponseErrorData(data: Data?) -> DIError {
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            guard let responseDict = json as? [String: AnyObject] else {
                return (DIError.invalidData())
                
            }
            if let errorsDict = responseDict["errors"] as? NSDictionary {
                var commonMessage = ""
                let allKeys = errorsDict.allKeys
                
                for value in allKeys{
                    let errorArray = errorsDict[value] as? NSArray ?? []
                    for (_,value) in errorArray.enumerated(){
                        if commonMessage == "" {
                            commonMessage = value as? String ?? ""
                        } else {
                            commonMessage = "\(commonMessage) \n\(value)"
                        }
                    }
                }
                return (DIError.serverResponse(message: commonMessage))
            }
            if let message = responseDict["message"] as? String {
                return (DIError.serverResponse(message: message))
            }
            return (DIError.missingKey())
        } catch {
            return (DIError.invalidJSON())
        }
    }
}

extension Data {
  
  /// Append string to NSMutableData
  ///
  /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
  ///
  /// - parameter string:       The string to be added to the `NSMutableData`.
  
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }
}
