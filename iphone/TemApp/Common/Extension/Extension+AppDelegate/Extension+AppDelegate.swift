//
//  Extension+AppDelegate.swift
//  TemApp
//
//  Created by Sourav on 2/7/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import KeychainSwift
import FirebaseDynamicLinks
import SideMenu

struct DeepLinkInfo: Codable {
    var postId: String?
    var affiliateMarketPlaceId: String?
}

extension AppDelegate {
    
    
    public func appIntializerAfterLaunch(application: UIApplication) {
        //Firebase Implementation......
        
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "temapp.page.link"
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)

        self.registerForFirebaseNotification(application: application)
        //Google Signin setup
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        //Implementation of IQKeyboardManager....
        addKeyboardManager()
    }
    
    ///clear keychain if the app is installed
    func clearKeychainOnFirstInstall() {
        if UserDefaults.standard.value(forKey: DefaultKey.firstRun.rawValue) == nil {
            KeychainSwift().clear()
            UserDefaults.standard.setValue(true, forKey: DefaultKey.firstRun.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    //This Fucntion will add The IQKeyboardManager
    private func addKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    //This Fucntion will call to connect socket:---
    public func connectSocket() {
//        if SocketIOManger.shared.isSocketConnected() == false {
//            SocketIOManger.shared.connect()
//        }
    }
    
    // This Fucntion will call to disconnect socket:---
    public func disconnectSocket() {
//        if SocketIOManger.shared.isSocketConnected() == true{
//            SocketIOManger.shared.dissConnect()
//        }
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool{
        let notification = Notification(name: NSNotification.Name("SampleBitLaunchNotification"), object: nil, userInfo: [
            "URL": url
            ])
        NotificationCenter.default.post(notification)
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            self.handleDynamicLink(dynamicLink: dynamicLink)
            return true
        }
        let facebookInstance = ApplicationDelegate.shared.application(application, open: url, options: options)
        let googleInstance = GIDSignIn.sharedInstance()?.handle(url) ?? false//GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,annotation: [:])
        
        return facebookInstance || googleInstance
    }

    func setNavigationToRoot(viewContoller: UIViewController, animated: Bool = false) {
        //Setting Login to Root Controller
        let navController = UINavigationController()
        //App Theming
        NavigTO.navigateTo?.navigation  =  navController
        navController.navigationBar.barTintColor = Constant.AppColor.navigationColor
        navController.navigationBar.tintColor = Constant.AppColor.navigationBarTintColor
        navController.pushViewController(viewContoller, animated: animated)
        navController.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func setNavigationToRootWithHome(viewContoller: UIViewController) {
        //Setting Login to Root Controller
        let controller:TabBarViewController = UIStoryboard(storyboard: .dashboard).initVC()
        let navController = UINavigationController()
        //App Theming
        NavigTO.navigateTo?.navigation  =  navController

        navController.navigationBar.barTintColor = Constant.AppColor.navigationColor
        navController.navigationBar.tintColor = Constant.AppColor.navigationBarTintColor
        navController.viewControllers = [controller]
        navController.pushViewController(viewContoller, animated: false)
        navController.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func popToRootViewController() {
        (self.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
        if let tabBarController = (self.window?.rootViewController as? UINavigationController)?.findController(controller: TabBarViewController.self) {
            if tabBarController.selectedIndex != 0 {
                tabBarController.selectedIndex = 0
            } else {
                //if selected index is already 0
                ///below handling is for the page view controller
                if let dashboardController = tabBarController.viewControllers?.first as? DashboardViewController {
                    guard let firstController = dashboardController.viewControllers?.first else {return}
                    if firstController is ActivityContoller {
                        guard let nextController = dashboardController.dataSource?.pageViewController(dashboardController, viewControllerAfter: firstController) else { return }
                        dashboardController.setViewControllers([nextController], direction: .forward, animated: false, completion: nil)
                        dashboardController.handleTabBarForController(vc: nextController, isHidden: false)
                    } else if firstController is ChatListingViewController {
                        guard let nextController = dashboardController.dataSource?.pageViewController(dashboardController, viewControllerBefore: firstController) else { return }
                        dashboardController.setViewControllers([nextController], direction: .reverse, animated: false, completion: nil)
                        dashboardController.handleTabBarForController(vc: nextController, isHidden: false)
                    }
                    
                }
            }
        }
    }
    
}//Extension

