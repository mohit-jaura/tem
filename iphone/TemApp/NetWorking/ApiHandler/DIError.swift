//
//  DIError.swift
//  TemApp
//
//  Created by shilpa on 16/05/20.
//

import Foundation
enum APICallBacks {
  case success, failure
}

struct DIError {
    var title: String?
    var message: String?
    var code: DIErrorCode?
    
    init(error: Error) {
        self.message = error.localizedDescription
        //        self.code = DIErrorCode(rawValue: error._code)
    }
    init(message: String?) {
        self.message = message ?? ""
        //        self.code = DIErrorCode(rawValue: error._code)
    }
    init(title: String?, message: String, code: DIErrorCode) {
        self.message = message
        self.title = title
        self.code = code
//        self.icon = icon
    }
    
    static func internetConnection() -> DIError {
        return DIError(title: "Warning", message: "Oops! Your internet is gone. Please check your internet connection", code: .locationPermissionDenied)
    }
    
    static func locationPermissionDenied() -> DIError {
        return DIError(title: "Warning", message: "Location is required. Go to settings & enable location", code: .locationPermissionDenied)
    }
    static func emailRequestDenied() -> DIError {
        return DIError(title: "Permission Denied", message: "User has not provided access for email address", code: .unknown)
    }
    static func isCanceled() -> DIError {
        return DIError(title: "Cancelled", message: "User has cancel the facebook login request", code: .unknown)
    }
    static func noResponse () -> DIError {
        return DIError(title: "OOPS", message: "Sorry, something went wrong. We're working on getting this fixed as soon as we can.", code: .unknown)
    }
    static func unKnowError() -> DIError {
        return DIError(title: "", message: "Unable to find error.", code: .unknown)
    }
    static func invalidUrl () -> DIError {
        return DIError(title: "Invalid url", message: "Url is invalid.", code: .invalidUrl)
    }
    static func nilData () -> DIError {
        return DIError(title: "", message: "Data not found.", code: .nilData)
    }
    static func invalidJSON () -> DIError {
        return DIError(title: "", message: "Invalid JSON response.", code: .invalidJSON)
    }
    static func missingKey () -> DIError {
        return DIError(title: "", message: "Missing key for dictionary or array.", code: .missingKey)
    }
    static func invalidData () -> DIError {
        return DIError(title: "", message: "Invalid data.", code: .invalidData)
    }
    static func serverResponseError (error: Error) -> DIError {
        return DIError(title: "Response Error", message: error.localizedDescription, code: .invalidData)
    }
    static func serverResponseError (message:String) ->  DIError {
        return DIError(title: "Warning", message: message, code: .invalidData)
    }
    static func userDisableResponseError (message:String) ->  DIError {
        return DIError(title: "Warning", message: message, code: .userDisable)
    }
    static func NoDataFound (message:String) ->  DIError {
        return DIError(title: "NoDataFound", message: message, code: .userDisable)
    }
    static func
        
        serverResponse (message: String) -> DIError {
        return DIError(title: "", message: message, code: .invalidData)
    }
    static func invalidAppInfoDictionary () -> DIError {
        return DIError(title: "No Info Dictionary", message: "Unable to find info dictionary for application.", code: .invalidAppInfoDict)
    }
    
}

enum DIErrorCode {
    case unknown, invalidUrl, nilData, invalidJSON, missingKey, invalidData, userDisable, invalidAppInfoDict, locationPermissionDenied,newSocialAccount,emailVerified
}
