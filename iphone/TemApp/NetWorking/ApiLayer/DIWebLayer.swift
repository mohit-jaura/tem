//
//  DIWebLayer.swift
//  Dotz
//
//  Created by Aj Mehra on 08/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class DIWebLayer {
    static let instance = DIWebLayer()
    
     let webManager = APIHandler()
    
    func decodeFrom<T : Decodable>(data: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let result = try JSONDecoder().decode(T.self, from: jsonData)
        return result
    }
    
    /// decode the json response from server to the custom model type
    ///
    /// - Parameters:
    ///   - data: response from server which needs to be decoded to codable type
    ///   - type: the custom Codable model type to which server response is to be converted
    ///   - success: the success completion invoked if decoding to custom model type is successfull
    ///   - failure: error block invoked, if any error occurs
    func decodeFrom<T: Codable>(data: Any, toType type: T.Type, success: ((_ type: T) -> ()), failure: Failure) {
        do {
            //get data from object
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let customType = try JSONDecoder().decode(type, from: jsonData)
            success(customType)
        } catch (let error) {
            print("error in decoding \(error)")
            failure(DIError(error: error))
        }
    }
    func startLoading(_ isLoader:Bool = false,_ parent:DIBaseController?) {
        DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }
    }
    func hideLoading(_ isLoader:Bool = false, _ parent:DIBaseController?) {
        DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }
    }
    
    @available(*, deprecated, message: "Use non-callback decodeFrom() instead")
    func decodeFrom<T : Decodable>(data: Any, success: ((_ type: T) -> ()), failure: Failure) {
        do {
            let result: T = try decodeFrom(data: data)
            success(result)
        } catch (let error) {
            print("error in decoding \(error)")
            failure(DIError(error: error))
        }
    }
    
    
    func call(method: Alamofire.HTTPMethod, function: String, parameters: Parameters?,addBaseUrl: Bool? = true, isBaseUrlPointingToTem: Bool? = false, success: @escaping (_ responseValue: Response) -> (), failure: @escaping (_ error: DIError) -> ()) {
        webManager.post(method: method, function: function, parameters: parameters, success: { (data) in
            self.handleResponseData(data: data, success: {
                success($0)
            }, failure: {
                failure($0)
            })
        }) {
            failure($0)
        }
    }
    
    func mutipart(parameters: Parameters?, image: UIImage, key: String, fileName: String, function: String, success: @escaping (_ response: Response) -> (), failure: @escaping (_ error: DIError) -> ()) {
        webManager.multipart(parameters: parameters, image: image, key: key, fileName: fileName, function: function, success: { (data) in
            self.handleResponseData(data: data, success: {
                success($0)
            }, failure: {
                failure($0)
            })
        }) {
            failure($0)
        }
    }
    
    /// uploads to AWS S3 bucket
    func uploadMultipart(parameters: Parameters?, data: Data, key: String, mimeType: String, fileName: String, url: String, success: @escaping (_ imageUrl: String) -> Void, failure: @escaping (_ error: DIError) -> ()) {
        webManager.uploadMultipart(parameters: parameters, file: data, mimeType: mimeType, key: key, fileName: fileName, url: url, success: { (url) in
            success(url)
        }) { (error) in
            failure(error)
        }
    }
    
    func handleResponseData(data: Data?, success: @escaping (_ response: Response) -> (), failure: @escaping (_ error: DIError) -> ()) {
        guard let responseData = data else {
            failure(DIError.invalidData())
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
            guard let responseDict = json as? [String: AnyObject] else {
                failure(DIError.invalidData())
                return
            }
            success(responseDict)
        } catch {
            failure(DIError.invalidJSON())
            return
        }
    }
    func handleDataError(data: Data?, completion: @escaping (_ status: Bool,_ error:DIError?) -> ()) {
        guard let responseData = data else {
            completion(false,DIError.invalidData())
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
            guard let responseDict = json as? [String: AnyObject] else {
                completion(false,DIError.invalidData())
                return
            }
            if let status = responseDict["status"] as? Int,let message = responseDict["message"]as? String {
                completion( status == 1,DIError(message: message))
            }else {
                completion(false,DIError.invalidData())
            }
        } catch {
            completion(false,DIError.invalidJSON())
            return
        }
    }
}
