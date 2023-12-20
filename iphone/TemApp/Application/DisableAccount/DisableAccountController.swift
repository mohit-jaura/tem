//
//  DisableAccountController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 19/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SideMenu

class DisableAccountController: DIBaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.configureNavigation()
    }
    
    // MARK: Set Navigation
    func configureNavigation(){
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.disableAccount.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    // MARK: Click to delete account.
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        guard Reachability.isConnectedToNetwork() else {
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
            return
        }
        self.showAlert(withTitle: "", message: "Are you sure you want to disable your account?", okayTitle: "DISABLE", cancelTitle: "CANCEL", okStyle: .destructive, okCall: {
            self.showLoader()
            SettingsAPI().disableAccount(success: { (message) in
                self.hideLoader()
                self.showAlert(withTitle: "", message:message, okayTitle: "ok".localized, okCall: {
                    UserManager.logout()
                    let loginVC:LoginViewController = UIStoryboard(storyboard: .main).initVC()
                    appDelegate.setNavigationToRoot(viewContoller: loginVC)
                })
            }) { (error) in
                self.hideLoader()
                self.showAlert(withTitle: "", message: error.message ?? "", okayTitle: AppMessages.AlertTitles.Ok, okCall: {
                    
                })
            }
        }) {
        }
    }
}
