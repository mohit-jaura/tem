//
//  FacebookHandler.swift
//  FriendSpire
//
//  Created by abhishek on 24/07/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

enum FBPermissions: String {
    case email = "email"
    case publicProfile = "public_profile"
    case birthday = "user_birthday"
    case publishAction = "publish_actions"
    case aboutMe = "user_about_me"
    case location = "user_location"
    case friends = "user_friends"
    case gender = "user_gender"
}

class FacebookManager:DIBaseController {
    
    // MARK: - SingleTon
    static let shared = FacebookManager()
   
    // MARK: - Login
    func login(_ permissions: [FBPermissions], success: @escaping (_ login: Login) -> (), failure: @escaping (_ error: DIError) -> (), onController controller: UIViewController) -> Void {
        let loginManager: LoginManager = LoginManager()
        //loginManager.loginBehavior = .native
        loginManager.logOut()
        let fbPermissions = permissions.map {
            $0.rawValue
        }
        loginManager.logIn(permissions: fbPermissions, from: controller) { (result, error) in
            if let error = error {
                failure(DIError(error: error))
                return
            }
            guard let fbResult = result else {
                failure(DIError.noResponse())
                return
            }
            self.showLoader()
            if fbResult.isCancelled {
                failure(DIError.isCanceled())
                return
            }
            if fbResult.grantedPermissions.contains(FBPermissions.email.rawValue) {
                self.userDetail(success: {
                    success($0)
                }, failure: {
                    failure($0)
                })
            } else {
                failure(DIError.emailRequestDenied())
            }
        }
    }
    
    
    func userDetail(success: @escaping (_ login: Login) -> (), failure: @escaping (_ error: DIError) -> ()) {
        if (AccessToken.current != nil) {
            let graphRequest = GraphRequest(graphPath: "me?fields=location", parameters: ["fields": "picture.type(large),id, first_name, last_name, email, birthday, gender,about, location{location},friends"])
            let connection = GraphRequestConnection()
            connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
                guard let data = result as? Parameters else {
                    failure(DIError.invalidData())
                    return
                }
                var login = Login()
                DILog.print(items: "facebook data: \(data)")
                login.username = data["email"] as? String ?? ""
                login.snsId = (data["id"] as? String) ?? ""
                login.snsType = UserType.fb.rawValue
                login.firstName = (data["first_name"] as? String) ?? ""
                login.lastName = (data["last_name"] as? String) ?? ""
                if let pictureDict = data["picture"] as? Parameters,
                    let pictureData = pictureDict["data"] as? Parameters,
                    let url = pictureData["url"] as? String {
                    login.profilePicure = url
                }
                //male : 1, //female: 2
                if let gender = data["gender"] as? String {
                    if gender == "male" {
                        login.gender = 1
                    }
                    if gender == "female" {
                        login.gender = 2
                    }
                }
                if let birthDay = data["birthday"] as? String {
                    login.dateOfBirth = birthDay.utcToLocal(.fbFormat, toFormat: .displayDate)
                }
                if let locationDict = data["location"] as? Parameters,
                    let location = locationDict["location"] as? Parameters {
                    if let long = location["longitude"] as? String,
                        let doubleValue = Double(long) {
                        //login.longlat.append(doubleValue)
                        login.address.lng = doubleValue
                    }
                    if let lat = location["latitude"] as? String,
                        let doubleValue = Double(lat) {
                        //login.longlat.append(doubleValue)
                        login.address.lat = doubleValue
                    }
                    if let city = location["city"] as? String {
                        login.address.city = city
                        login.address.formatted = city
                        if let country = location["country"] as? String {
                            login.address.country = country
                            login.address.formatted = city + ", " + country
                        }
                    }
                }
                success(login)
            })
            connection.start()
        }else {
//            failure(DIError.fbUserNotFound())
        }
    }
    
    func getFriendList(sucess: @escaping (_ list : [FBFriendModal]) ->() , failure : @escaping (_ error: Error?) -> ()  ) {
        if (getToken() != nil) {
            let params = ["fields": "id, first_name, last_name, name, email, picture"]
            let graphRequest = GraphRequest(graphPath: "/me/friends?limit=5000", parameters: params, httpMethod: HTTPMethod(rawValue: "GET"))
            let connection = GraphRequestConnection()
            connection.add(graphRequest, completionHandler: { (connection, result, error) in
                if error == nil {
                    if let userData = result as? [String:Any] {
                        var userList = [FBFriendModal]()
                        let decoder = JSONDecoder()
                        do{
                            guard let arrFrnds =  userData["data"] as? NSArray else {return}
                            
                            if arrFrnds.count > 0 {
                                for obj in arrFrnds{
                                    let jasonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                                    let modal = try decoder.decode(FBFriendModal.self, from: jasonData)
                                    userList.append(modal)
                                }
                            }
                            
                        }catch {
                            print("decoding error: \(error)")
                        }
                        
                        DILog.print(items: userData)
                        sucess(userList)
                    }
                } else {
                    DILog.print(items:"Error Getting Friends \(error.debugDescription)")
                    failure(error)
                }
                
            })
            
            connection.start()
        }
    }
    
    
    func getToken() -> AccessToken?{
        return  AccessToken.current
    }
    
    //This function will remove the Current FBSDKAcessToken.....
    
    func removeFBSDKAcessToken(){
        if (getToken() != nil) {
            LoginManager().logOut()
        }
    }
    
}//Class....



