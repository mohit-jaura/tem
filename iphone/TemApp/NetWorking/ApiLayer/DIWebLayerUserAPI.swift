//
//  DIWebLayerUserAPI.swift
//  BaseProject
//
//  Created by TpSingh on 05/04/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit
import Alamofire
class DIWebLayerUserAPI: DIWebLayer {
    
    
//    ///Get the order payment information from the shopify server
//    func getOrderPaymentInfo(orderId: String, url: String, success: @escaping(_ paymentInfo: PaymentInfo) -> Void, failure: @escaping(_ error: DIError) -> Void) {
//        self.call(method: .get,  function: url,parameters: nil, success: { (response) in
//            if let orderData = response["order"] as? Parameters {
//                if let paymentDetails = orderData["payment_details"] as? Parameters {
//                    self.decodeFrom(data: paymentDetails, toType: PaymentInfo.self, success: { (paymentInfo) in
//                        //success(comments)
//                        success(paymentInfo)
//                    }, failure: { (error) in
//                        failure(error)
//                    })
//                }
//            }
//        }) { (error) in
//            failure(error)
//        }
//    }
    // MARK: Order History
    func orderHistory(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.post,function: Constant.SubDomain.kOrder , parameters:parameters, success: { response in
            print(response)
            if let responseDict = response["message"] as? String {
                
                success(responseDict)
                return
            }
        }) {
            failure($0)
        }
    }
    
    // MARK: Handling Cart item Value
        func cartQuantity(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()){
            self.call(method:.put,function:Constant.SubDomain.kQuantity,  parameters:parameters, success: { response in
            print(response)
            if let responseDict = response["message"] as? String {
                
                success(responseDict)
                return
            }
        }) {
            failure($0)
        }
    }
    func addCart(parameters: Parameters?,success: @escaping (_ message: String, _ statusKey: Int) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.post,function:Constant.SubDomain.addCart , parameters: parameters, success: { response in
            print(response)
            if let responseDict = response["message"] as? String {
                var key = 0
                if let data = response["data"] as? Parameters,
                    let count = data["count"] as? Int {
                    key = count //0 for new item added, 1 when product quantity is increased
                }
                success(responseDict, key)
                return
            }
        }) {
            failure($0)
        }
    }
    
    
//    // MARK: Get Cart
//    
//    func getCartList(success: @escaping (_ cartModel: [CartModel]) -> Void, failure: @escaping (_ error: DIError) -> ()){
//        self.call(method:.get,function:  Constant.SubDomain.getCartList, parameters:nil, success: { response in
//            if let data = response["data"] as? [Parameters] {
//                self.decodeFrom(data: data, toType: [CartModel].self, success: { (cartModel) in
//                    success(cartModel)
//                }, failure: { (error) in
//                    failure(error)
//                })
//            }
//        }) {
//            failure($0)
//        }
//    }
    
    
    // MARK: Delete Cart Item
    
    
    
func deleteCartItem(parameters: Parameters?,success: @escaping() -> Void, failure: @escaping (_ error: DIError) -> Void) {
    let url = Constant.SubDomain.deleteCartItem
    
    self.call(method: .put, function:url , parameters: parameters, success: { (response) in
        if let data = response["message"] as? String {
            success()
            return
        }
    }) { (error) in
        failure(error)
    }
}
    func login (parameters: Parameters?, success: @escaping (_ user: User,_ status : Int, _ type: Int? ) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.login, parameters: parameters, success: { dataResponse in
            print(dataResponse)
            if let responseDict = dataResponse["data"] as? NSDictionary {
                let type = responseDict["type"] as? Int
                let user = User(responseDict as! Parameters)
                user.oauthToken = responseDict["token"] as? String ?? ""
                success(user, dataResponse["status"] as? Int ?? 0, type)
                return
            }else{
                let type = dataResponse["type"] as? Int
                success(User(), dataResponse["status"] as? Int ?? 0, type)
                return
            }
        }) {
            failure($0)
        }
    }
    func socialLogin (parameters: Parameters?, success: @escaping (_ response: (Dictionary<String, Any>)) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.login, parameters: parameters, success: { dataResponse in
            DILog.print(items: dataResponse)
            success(dataResponse)
        }) {
            failure($0) }
    }
    
    
    func socialUserCheck(parameters: Parameters?,success: @escaping (_ user: User?, [String:Any]?) -> (), failure: @escaping (_ error: DIError) -> ()) {
        
        self.call(method: .post, function: Constant.SubDomain.isSocialMediaExist, parameters: parameters, success: { response in
            DILog.print(items: response)
            if let responseDict = response["data"] as? NSDictionary {
                let user = User(responseDict as! Parameters)
                user.oauthToken = responseDict["token"] as? String ?? ""
                success(user,nil)
                return
            }
            success(nil,response)
            
        }) {
            failure($0) }
    }
    
    
    func registation (parameters: Parameters?, success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.signUp, parameters: parameters, success: { dataResponse in
            var otp = ""
            if let otpCode = dataResponse["otp"] as? String{
                otp = otpCode
            }
            
            if let message = dataResponse["message"] as? String {
                success(message + "\n\(otp)")
                return
            }
        }) {
            failure($0)
        }
    }
    
    func updateFirebaseToken (parameters: Parameters?, success: @escaping (_ response: Response) -> (), failure: @escaping (_ error: DIError) -> ()) {
        
        self.call(method:.put, function: Constant.SubDomain.updateFirebaseToken, parameters: parameters, success: { dataResponse in
            success(dataResponse)
            return
        }) {
            failure($0)
        }
    }
    
    
    func forgotPassword(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.forgotPassword, parameters: parameters, success: { response in
            var otp = ""
            if let otpCode = response["otp_code"] as? String{
                otp = otpCode
            }
            if let message = response["message"] as? String {
                success(message + "\n\(otp)")
                return
            }
        }) {
            failure($0)
        }
    }
    
    func registerVerifyOtp(parameters: Parameters?,success: @escaping (_ user: User) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method: .post, function: Constant.SubDomain.signupOtpVeify, parameters: parameters, success: { response in
            if let responseDict = response["data"] as? NSDictionary {
                let user = User(responseDict as! Parameters)
                user.oauthToken = responseDict["token"] as? String ?? ""
                success(user)
                return
            }
        }) {
            failure($0)
        }
    }
    
    func forgotVerifyOtp(parameters: Parameters?,success: @escaping (_ message: Response) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method: .post, function: Constant.SubDomain.forgotPasswordOtpVerify, parameters: parameters, success: { response in
            success(response)
        }) {
            failure($0)
        }
    }
    
    func resetPassword(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.put,function: "reset_password", parameters: parameters, success: { response in
            print(response)
            if let message = response["message"] as? String {
                success(message)
            }
        }) {
            failure($0)
        }
    }
    
    func resendOtp(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method: .post, function: "resend_otp", parameters: parameters, success: { response in
            if let message = response["message"] as? String {
                success(message)
                return
            }
        }) {
            failure($0)
        }
    }
    func resendForgotOtp(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method: .post, function: "forgot_password", parameters: parameters, success: { response in
            print(response)
            if let message = response["message"] as? String {
                success(message)
                return
            }
        }) {
            failure($0)
        }
    }
    
    func verifyAndRegisterUser(parameters: Parameters?,success: @escaping (_ user: User) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.put,function: "signup/otp_verify", parameters: parameters, success: { response in
            print(response)
            if let responseDict = response["data"] as? NSDictionary {
                let user = User(responseDict as! Parameters)
                user.oauthToken = responseDict["token"] as? String ?? ""
                success(user)
                return
            }
        }) {
            failure($0)
        }
    }
    
    func verifyAndUpdatPhoneEmail(parameters: Parameters?,success: @escaping (_ data: Parameters) -> (), failure: @escaping (_ error: DIError) -> ()){
        self.call(method:.put,function: "profile/verify_otp", parameters: parameters, success: { response in
            print(response)
            if let responseDict = response["data"] as? Parameters {
                success(responseDict)
                return
            }
        }) {
            failure($0)
        }
    }
    
    func addFoodTrek(parameters: Parameters?, success: @escaping (_ message: String) -> (),failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.foodTrekAdd, parameters: parameters, success: { (response) in
            if let status = response["status"] as? Int, status == 0 {
                let error = DIError(message: response["message"] as? String)
                failure(error)
                return
            }
            if let message = response["message"] as? String {
                success(message)
                return
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func uplodaProfileData(parameters: Parameters?, success: @escaping (_ message: String) -> (),failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .put, function: Constant.SubDomain.createProfile, parameters: parameters, success: { (response) in
            if let message = response["message"] as? String {
                success(message)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func updateProfileCompletionStatus(parameters: Parameters?, success: @escaping (_ finished: Bool) -> ()) {
        self.call(method: .put, function: Constant.SubDomain.markProfileCompletionStatus, parameters: parameters, success: { (response) in
            success(true)
        }) { (error) in
            DILog.print(items: error.message ?? "")
        }
    }
    
    func updateEmailPhone(parameters: Parameters?, success: @escaping (_ finished: Bool, _ message: String?) -> (),failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .put, function: Constant.SubDomain.updateEmailPhone, parameters: parameters, success: { (response) in
            if let message = response["message"] as? String {
                success(true, message)
            } else {
                success(true, nil)
            }
        }) { (error) in
            DILog.print(items: error.message ?? "")
            failure(error)
        }
    }
    
    
    func getInterestsList(success: @escaping (_ data: [Activity]) -> (),failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .get, function: Constant.SubDomain.getInterest, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (interests) in
                    success(interests)
                }, failure: { (error) in
                    failure(error)
                })
            }else{
                failure(DIError.unKnowError())
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getCountryCode(success: @escaping (_ data: [String]) -> (),failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .get, function: Constant.SubDomain.countryCode, parameters: nil, success: { (response) in
            if let data = response["data"] as? [String] {
                success(data)
                return
            }else{
                success([String]())
                return
            }
        }) { (error) in
            failure(error)
        }
    }
    
    
    func saveInterestsList(parameters: Parameters?, success: @escaping (_ message: String) -> (),failure: @escaping (_ error: DIError) -> ()) {
        self.call(method: .post, function: Constant.SubDomain.saveInterest, parameters: parameters, success: { (response) in
            if let message = response["message"] as? String {
                success(message)
            }
        }) { (error) in
            failure(error)
        }
    }
    //
    //    func profile(parameters: Parameters?,success: @escaping (_ user: User) -> (), failure: @escaping (_ error: DIError) -> ()){
    //
    //        self.webService(httpMethod:.put,parameters: parameters, function: "profile", success: { response in
    //            if let responseDict = response["data"] as? NSDictionary {
    //                let user = User(responseDict as! Parameters)
    //                user.oauthToken = responseDict["token"] as? String ?? ""
    //                success(user)
    //                return
    //            }
    //        }) {
    //            failure($0)
    //        }
    //    }
    
    //save the last searched location by user
    func saveLastSearchLocation(parameters: Parameters?, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.searchLocation, parameters: parameters, success: { (response) in
            DILog.print(items: "last searched location saved")
        }) { (error) in
            failure(error)
        }
    }
    
    //save the last searched location by user
    func saveLastGymSearchLocation(parameters: Parameters?, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.gymSearchLocation, parameters: parameters, success: { (response) in
            DILog.print(items: "last searched location saved")
        }) { (error) in
            failure(error)
        }
    }
    //get the recent location searches
    func getRecentLocationSearches(success: @escaping (_ locations: [Address]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.searchLocation, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (locations) in
                    success(locations)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getRecentGymLocationSearches(success: @escaping (_ locations: [Address]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.gymSearchLocation, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                var locationArr:[Address] = []
                for locationObj in data {
                    let obj = locationObj as Parameters
                    let address = Address(gymLocationObj: obj)
                    locationArr.append(address)
                }
                success(locationArr)
            }
        }) { (error) in
            failure(error)
        }
    }
    //5cbd82b2e312be0a6296bab2
    func getPostComments(isFromFoodTrek:Bool = false,id:String,page:Int,success: @escaping (_ comments: [Comments]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        
        let value = isFromFoodTrek ? "\(Constant.SubDomain.foodPostComments)\(id)&page=\(page)": "\(Constant.SubDomain.postComments)\(id)&page=\(page)"
        self.call(method: .get, function: value, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (comments) in
                    success(comments)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getPostLikes(id:String,page:Int,success: @escaping (_ likes: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: "\(Constant.SubDomain.postLikes)\(id)&page=\(page)", parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (likes) in
                    success(likes)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getFoodTrekPostLikes(id:String,page:Int,success: @escaping (_ likes: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: "\(Constant.SubDomain.getFoodTrekPostlikes)\(id)&page=\(page)", parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (likes) in
                    success(likes)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    func getSearchPostLikes(id:String,title:String,page:Int,success: @escaping (_ likes: [Friends]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let url = "\(Constant.SubDomain.searchPostLikes)\(page)&title=\(title)&post_id=\(id)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (likes) in
                    success(likes)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    //save the last searched location by user
    func likeOrDislikePost(isFromTrek:Bool = false,parameters: Parameters?, success: @escaping (_ message: String) -> Void,failure: @escaping (_ error: DIError) -> Void) {
        
        let value = isFromTrek ? Constant.SubDomain.foodtreklike: Constant.SubDomain.likeOrDislikePost
        self.call(method: .put, function: value, parameters: parameters, success: { (response) in
            if let message = response["message"] as? String {
                success(message)
                return
            }
        }) { (error) in
            failure(error)
        }
    }
    
    
    func addcomment(isFromFoodTrek:Bool = false,parameters: Parameters?,success: @escaping (_ data: Parameters) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let value = isFromFoodTrek ? Constant.SubDomain.foodComments: Constant.SubDomain.comments
        self.call(method: .post, function: value, parameters: parameters, success: { (response) in
            if let data = response["data"] as? Parameters {
                success(data)
                return
            }
            DILog.print(items: "last searched location saved")
        }) { (error) in
            failure(error)
        }
    }
    
    //save the last searched location by user
    func deletecomment(parameters: Parameters?,success: @escaping (_ data: String) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .delete, function: Constant.SubDomain.comments, parameters: parameters, success: { (response) in
            if let data = response["message"] as? String {
                success(data)
                return
            }
            DILog.print(items: "last searched location saved")
        }) { (error) in
            failure(error)
        }
    }
    
    func logout(success: @escaping (_ finished: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .put, function: Constant.SubDomain.logout, parameters: nil, success: { (response) in
            success(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func updateDeviceToken(parameters: Parameters) {
        self.call(method: .put, function: Constant.SubDomain.updateDeviceToken, parameters: parameters, success: { (response) in
            print(response)
        }) { (_) in
        }
    }
    
    ///api call to get the leaderboard for the user
    func getLeaderboard(page: Int, searchString: String?, completion: @escaping (_ response: MyLeaderboard) -> Void, failure: @escaping (_ error: DIError) -> ()) {
        var subdomain = Constant.SubDomain.getUserLeaderboard// + "?page=\(page)"
        if let searchText = searchString {
            subdomain += "?search=\(searchText)"
        }
        subdomain = subdomain.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.call(method: .get, function: subdomain, parameters: nil, success: { (response) in
            self.decodeFrom(data: response, success: { (result) in
                completion(result)
            }, failure: { (error) in
                failure(error)
            })
        }) { (error) in
            failure(error)
        }
    }
    
    func addMemberToLeaderboard(parameters: Parameters?, completion: @escaping (_ finished: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.addMembersToLeaderboard, parameters: parameters, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func removeMemberFromLeaderboard(parameters: Parameters?, completion: @escaping (_ finished: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.deleteMemberFromLeaderboard, parameters: parameters, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    /// Add or remove a screen (tem, challenge or goal) as home screen shortcut
    ///
    /// - Parameters:
    ///   - parameters: parameters
    ///   - completion: called on success
    ///   - failure: called if any error
    func updateToHomeScreen(parameters: Parameters?, completion: @escaping(_ finished: Bool) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.addShortcutToHome, parameters: parameters, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func getHomeScreenStatus(type: HomeScreenShortCutType, id: String, completion: @escaping (_ status: Int) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var url = Constant.SubDomain.checkShortcutStatus
        url += "?type=\(type.rawValue)" + "&id=\(id)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters,
               let status = data["showHoneyComb"] as? Int {
                completion(status)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    ///get the list of all screens which are added as shortcuts by user
    func getListOfShortcutsOnHome(completion: @escaping (_ data: [HomeScreenShortcut]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getAllShortcuts, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters,
               let screensData = data["honey_comb_screens"] as? [Parameters] {
                self.decodeFrom(data: screensData, success: { (response) in
                    completion(response)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getUserHealthData(completion: @escaping (_ healthData: HealthDataNew) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getBiomarkerPillar, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters,
               var healthData = data["biomarker_pillar"] as? Parameters {
                if let weight = data["weight"] as? Int,let height = data["height"] as? Parameters, let feet = height["feet"] as? Int,let inch = height["inch"] as? Int{
                    healthData["weight"] = weight
                    healthData["feet"] = feet
                    healthData["inch"] = inch
                }
                self.decodeFrom(data: healthData, success: { (data) in
                    completion(data)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func updateUserHealthData(parameters: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.updateBiomarkerPillar, parameters: parameters, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func getNutritionTrackingPercent(completion: @escaping(_ percentages: [Any]) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getNutritionTrackingPercent, parameters: nil, success: { (response) in
            if let data = response["data"] as? [String: String] {
                let arrayOfData = data.sorted(by: {$0 < $1})
                completion(arrayOfData)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getHAISTotalScore(completion: @escaping(_ sum: Double) -> Void, failure: @escaping(_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getHaisTotalScore, parameters: nil, success: { (response) in
            if let data = response["sum"] as? Double {
                ReportViewModal().saveHaisReportsDataToRealm(report: response)
                completion(data)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getS3UrlForFileUpload(data: Any? = nil, completion: @escaping (_ data: AWSCredentials) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.getS3UrlForFileUpload, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                completion(AWSCredentials(data: data))
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func uploadToS3Bucket(atPath url: String, data: AWSCredentials, file: Data, key: String, fileName: String, mimeType: String, media: Media?, completion: @escaping (_ fileUrl: String) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        var parameters = data.json()
        parameters?["key"] = (data.prefix ?? "") + "\(fileName)"
        var contentType = "image/jpeg"
        if let type = media?.mimeType {
            contentType = type
        }
        parameters?["Content-Type"] = contentType
        //DILog.print(items: parameters)
        self.uploadMultipart(parameters: parameters, data: file, key: key, mimeType: mimeType, fileName: fileName, url: url, success: { (url) in
            //image url
            completion(url)
        }) { (error) in
            failure(error)
        }
    }
    
    func updateTrackerStatus(params: Parameters?, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .post, function: Constant.SubDomain.updateTrackerStatus, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    ///update option to see temates post
    func updateOptionToSeeTematesPosts(optionType: NewsFeedAlgoOption, completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let params: Parameters = ["algo_type": optionType.rawValue]
        self.call(method: .put, function: Constant.SubDomain.updateAlgoType, parameters: params, success: { (response) in
            completion(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func getInfo(id: String, completion: @escaping (_ user: User) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        call(method: .get, function: "users/info/\(id)", parameters: nil) { response in
            var user: User?
            do {
                if let data = response["data"] {
                    user = try self.decodeFrom(data: data)
                } else {
                    failure(DIError.invalidJSON())
                }
            } catch {
                failure(DIError.invalidJSON())
            }
            if let user = user {
                completion(user)
            }
        } failure: { error in
            failure(error)
        }
    }
}

