////
////  FitbitAuthHandler.swift
////  TemApp
////
////  Created by Harpreet_kaur on 27/06/19.
////  Copyright © 2019 Capovela LLC. All rights reserved.
////
//
import Foundation
import UIKit
import SafariServices
//
//
class FitbitLoginHandler {
    private var clientID = ""
    private var clientSecret = ""
    private var authUrl: URL?
    private var refreshTokenUrl: URL?
    private var redirectURI = ""
    private var defaultScope = ""
    private var expiresIn = ""
    private var authenticationCode = ""
     private var authorizationVC: SFSafariViewController?



    func loadVars() {
        //------ Initialize all required vars -----
        clientID = "22DKX7"
        clientSecret = "73be5224f71020997ecfe81c231534cc"
        redirectURI = "tem://fitbit"
        expiresIn = "604800"
        authUrl = URL(string: "https://www.fitbit.com/oauth2/authorize")
        refreshTokenUrl = URL(string: "https://api.fitbit.com/oauth2/token")
        defaultScope = "sleep+settings+nutrition+activity+social+heartrate+profile+weight+location"
    }
//
//
//    init(_ delegate_: Any?) {
//    //    super.init()
//        loadVars()
//        NotificationCenter.default.addObserver(forName: NSNotification.Name("SampleBitLaunchNotification"), object: nil, queue: nil, using: { note in
//            var success: Bool
//            let code = self.extractCode(note, key: "?code")
//            if code != nil {
//                self.authenticationCode = code ?? ""
//                print("You have successfully authorized")
//                success = true
//            } else {
//                print("There was an error extracting the access token from the authentication response.")
//                success = false
//            }
//            authorizationVC?.dismiss(animated: true) {
//                // [self.delegate authorizationDidFinish:success];
//                self.getAccessToken(success)
//            }
//        })
//    }
//
//    func login(_ viewController: UIViewController?) {
//
//        _ = URL(string: "\(authUrl)?response_type=code&client_id=\(clientID )&redirect_uri=\(redirectURI )&scope=\(defaultScope )&expires_in=\(expiresIn )")
//Utility.presentFitBitController(url: "\(authUrl)?response_type=code&client_id=\(clientID )&redirect_uri=\(redirectURI )&scope=\(defaultScope )&expires_in=\(expiresIn )")
////        var authorizationViewController: SFSafariViewController? = nil
////        if let url = url {
////            authorizationViewController = SFSafariViewController(url: url)
////        }
////        authorizationViewController?.delegate = self as! SFSafariViewControllerDelegate
////        authorizationVC = authorizationViewController
////        if let authorizationViewController = authorizationViewController {
////            viewController?.present(authorizationViewController, animated: true)
////        }
//    }
//
//    func extractCode(_ notification: Notification?, key: String?) -> String? {
//        let url = notification?.userInfo?["URL"] as? URL
//        let strippedURL = url?.absoluteString.replacingOccurrences(of: redirectURI, with: "")
//        let str = parameters(fromQueryStringCode: strippedURL)?[key ?? ""] as? String
//        return str
//    }
//
//    func parameters(fromQueryStringCode queryString: String?) -> [AnyHashable : Any]? {
//        var parameters: [AnyHashable : Any] = [:]
//        if queryString != nil {
//            let paramScanner = Scanner(string: queryString ?? "")
//            var name: String
//            var value: String
//            while paramScanner.isAtEnd != true {
//                name = ""
//                paramScanner.scanUpTo("=", into: name)
//                paramScanner.scanString("=", into: nil)
//
//                value = ""
//                paramScanner.scanUpTo("#", into: value)
//                paramScanner.scanString("#", into: nil)
//                paramScanner.scanUpTo("_", into: value)
//                paramScanner.scanString("_", into: nil)
//
//                if name != nil && value != nil {
//                    parameters[name.removingPercentEncoding ?? ""] = value.removingPercentEncoding
//                }
//            }
//        }
//
//        return parameters
//    }
//
//    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//        getAccessToken(false)
//    }
//
//    func showAlert(_ message: String?) {
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.rootViewController = UIViewController()
//        window.windowLevel = UIWindow.Level(UIWindow.Level.alert.rawValue + 1)
//
//        let alertView = UIAlertController(title: "Fitbit Error!", message: message, preferredStyle: .alert)
//
//        alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
//
//            window.isHidden = true
//        }))
//
//        window.makeKeyAndVisible()
//        window.rootViewController?.present(alertView, animated: true)
//    }
//
//    func getAccessToken(_ success: Bool) {
//        if success {
//            let manager = AFHTTPSessionManager()
//            let base64 = base64String("\(clientID):\(clientSecret)")
//            // NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbit_code"];
//            manager.requestSerializer.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
//            manager.responseSerializer.acceptableContentTypes = manager.responseSerializer.acceptableContentTypes + Set<AnyHashable>(["application/x-www-form-urlencoded"])
//
//            let param = [
//                "grant_type": "authorization_code",
//                "clientId": clientID,
//                "code": authenticationCode,
//                "redirect_uri": redirectURI
//            ]
//
//            manager.post("https://api.fitbit.com/oauth2/token", parameters: param, progress: nil, success: { task, responseObject in
//                //******************** Save Token to NSUserDedaults ******************
//                UserDefaults.standard.set(responseObject?["access_token"], forKey: "fitbit_token")
//                UserDefaults.standard.synchronize()
//                NotificationCenter.default.post(name: FitbitNotification, object: nil, userInfo: nil)
//                //********************* *********************** **********************
//            }, failure: { task, error in
//                self.showAlert("\(error.localizedDescription)")
//            })
//        }else{
//
//        }
//    }
//
//
//    func revokeAccessToken(_ token: String?) {
//
//        let manager = AFHTTPSessionManager()
//        let base64 = base64String("\(clientID):\(clientSecret)")
//
//        manager.requestSerializer.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
//        manager.responseSerializer.acceptableContentTypes = manager.responseSerializer.acceptableContentTypes + Set<AnyHashable>(["application/x-www-form-urlencoded"])
//
//        let params = [
//            "token": token ?? 0
//        ]
//        manager.post("https://api.fitbit.com/oauth2/revoke", parameters: params, progress: nil, success: { task, responseObject in
//            let response = task.response() as? HTTPURLResponse
//            let statusCode = response?.statusCode
//
//            if statusCode == 200 {
//                //******************** clear Token ******************
//                UserDefaults.standard.set(nil, forKey: "fitbit_token")
//                UserDefaults.standard.synchronize()
//                //********************* *********************** **********************
//                print("Fitbit RevokeToken Successfully")
//            } else {
//                if let responseObject = responseObject {
//                    print(String(format: "Fitbit RevokeToken Error: StatusCode= %ld Response= %@", Int(statusCode ?? 0), responseObject))
//                }
//            }
//        }, failure: { task, error in
//            self.showAlert("\(error.localizedDescription)")
//        })
//    }
//
//    -( as? String ?? "")
//    do {
//    // Create NSData object
//    let nsdata = string.data(using: .utf8)
//    // Get NSString from NSData object in Base64
//    let base64Encoded = nsdata?.base64EncodedString(options: [])
//    return base64Encoded
//    }
//
//    // MARK: - Token Methods ;
//    +(getToken as? String ?? "")
//    do {
//    let authToken = UserDefaults.standard.object(forKey: "fitbit_token") as? String
//    return authToken
//    }
//    +clearToken
//    do {
//    UserDefaults.standard.set(nil, forKey: "fitbit_token")
//    UserDefaults.standard.synchronize()
//    }
}
//
//
