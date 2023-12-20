//
//  NetworkLayer.swift
//  TemWatchApp Extension
//
//  Created by shilpa on 08/04/20.
//

import Foundation
import Alamofire

typealias Response = [String: Any]
typealias Parameters = [String: Any]

class NetworkLayer {
    /// This method will create the complete path for the api request with the help of base url, version and domain Name
    ///
    /// - Parameter apiName: Name of api domin like login
    /// - Returns: complete Url String
    func absolutePath(forApi apiName: String) -> String {
        var path = "https://tem-prod.capovela.com/"//BuildConfiguration.shared.serverUrl
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
    
    func sendRequest(method: Alamofire.HTTPMethod = .post, parameters: Parameters?, urlPath: String, completion: @escaping (_ responseValue: Response) -> (), failure: @escaping (_ error: DIError) -> ()) {
        guard let headers = Defaults.shared.get(forKey: .appHeaders) as? [String: String] else {
            return
        }
        let path = absolutePath(forApi: urlPath)
        print("url: \(path)")
        Alamofire.request(path, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (result) in
            print("headers-------->>",headers)
            print(result)
            if let errorResponse = result.error {
                if errorResponse._code == -999{
                    return
                }
                failure(self.parseError(error: errorResponse))
                return
            } else if let httpResponse = result.response {
                if httpResponse.statusCode == 200 {
                    if let data = self.handleResponseData(data: result.data) {
                        completion(data)
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
                    let error = self.handleResponseErrorData(data: result.data)
                    failure(error)
                    return
                }
                else if httpResponse.statusCode == 500 {
                    failure(DIError.serverResponseError(message: WatchConstants.APIResponse.internalServerError))
                    return
                }
                else if httpResponse.statusCode == 401 {
                    let error = self.handleResponseErrorData(data: result.data, isSessionExpire: true)
                    //handle alert for login here
                    Defaults.shared.remove(.appHeaders)
                    failure(error)
                    return
                }
                else if httpResponse.statusCode == 403 {
                    _ = self.handleResponseErrorData(data: result.data)
                    return
                }
                else if httpResponse.statusCode == 503 {
                    failure(DIError.serverResponseError(message: WatchConstants.APIResponse.clientError))
                    return
                }
                else if httpResponse.statusCode == 422 {
                    _ = self.handleResponseErrorData(data: result.data)
//                    failure(error)
                    return
                }
            }
            failure(DIError.nilData())
        }
    }
    
    /// This method will parse the error catch through the Api session manager and return an object of DIError with details about the error for debugging purpose
    ///
    /// - Parameter error: error catch by session manager
    /// - Returns: Convert Object to display error to user
    func parseError(error: Error) -> DIError {
        if error._code == -1001 || error._code == -1004 || error._code == -1005 {
            return DIError(title: "", message:WatchConstants.APIResponse.requestTimeOut, code: .invalidUrl)
        }else {
            return DIError(title: "", message:WatchConstants.APIResponse.internalServerError, code: .invalidUrl)
        }
    }
    
    /*func handleResponseErrorData(data: Data?)->DIError {
        
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
    } */
    
    func handleResponseErrorData(data: Data?, isSessionExpire:Bool = false)->DIError {
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
    
    func handleResponseData(data: Data?) -> Response? {
        guard let data = data else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let responseDict = json as? [String: AnyObject] else {
                //failure(DIError.invalidData())
                //handle invalid json error
                return nil
            }
            return responseDict
        } catch {
            //handle error
        }
        return nil
    }
    
    /// decode the json response from server to the custom model type
    ///
    /// - Parameters:
    ///   - data: response from server which needs to be decoded to codable type
    ///   - type: the custom Codable model type to which server response is to be converted
    ///   - success: the success completion invoked if decoding to custom model type is successfull
    ///   - failure: error block invoked, if any error occurs
   /* func decodeFrom<T: Codable>(data: Any, toType type: T.Type, success: ((_ type: T) -> ()), failure: (_ error: Error) -> Void) {
        do {
            //get data from object
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let customType = try JSONDecoder().decode(type, from: jsonData)
            success(customType)
        } catch (let error) {
            print("error in decoding \(error)")
            failure(error)
        }
    } */
}
