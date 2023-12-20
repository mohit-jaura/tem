//
//  AccountController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 19/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SideMenu
import SSNeumorphicView
enum AccountSections: Int, CaseIterable {
    case seeTematesPostsOption = 0
    case changePassword
    case disableAccount
    case logout
    
    var title: String {
        switch self {
        case .seeTematesPostsOption:
            return "TĒMATE Only Feed"
        case .changePassword:
            return "Change Password"
        case .disableAccount:
            return "Disable Account"
        case .logout:
            return "Logout"
        }
    }
}
class AccountController: DIBaseController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet var backView: [SSNeumorphicView]!
    @IBOutlet weak var logoutBtnView: SSNeumorphicView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for view in backView {
            view.setOuterDarkShadow()
            view.viewNeumorphicCornerRadius = 12
        }
        logoutBtnView.setOuterDarkShadow()
        if let algoType = UserManager.getCurrentUser()?.algoOption {
            if algoType == .new {
                self.switchBtn.setOn(false, animated: false)
            } else {
                self.switchBtn.setOn(true, animated: false)
            }
        } else {
            self.switchBtn.setOn(false, animated: false)
        }
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
     //   self.configureNavigation()
    }
    @IBAction func onClickNotificationSetting(_ sender:UIButton) {
        let deviceController:NotificationSettingController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(deviceController, animated: true)
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onClickChangePassword(_ sender:UIButton) {
        let deviceController:ChangePasswordController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(deviceController, animated: true)
    }
     
    @IBAction func onClickPrivacy(_ sender:UIButton) {
        let deviceController:PrivacyAndSecurityController = UIStoryboard(storyboard: .privacy).initVC()
        self.navigationController?.pushViewController(deviceController, animated: true)
    }
    
    @IBAction func onClickDisableAccount(_ sender:UIButton) {
        let deviceController:DisableAccountController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(deviceController, animated: true)
    }
    
    @IBAction func onClickSettings(_ sender:UIButton) {
        let deviceController:SettingsViewController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(deviceController, animated: true)
    }
    
    @IBAction func onClickLinkDevices(_ sender:UIButton) {
        let deviceController:DeviceController = UIStoryboard(storyboard: .sidemenu).initVC()
        self.navigationController?.pushViewController(deviceController, animated: true)
    }
    
    @IBAction func onClickShare(_ sender:UIButton) {
        if let name = URL(string: AppMessages.AppUpdate.url), !name.absoluteString.isEmpty {
            let objectsToShare = ["To download the TĒM App follow link:- \n \(name)"]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickLinkApps(_ sender:UIButton) {
        let deviceController:AppsController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(deviceController, animated: true)
    }
    
    @IBAction func onClickFAQS(_ sender:UIButton) {
        let selectedVC:FAQViewController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(selectedVC, animated: true)
    }
    @IBAction func onClickLogout(_ sender:UIButton) {
        let alert = UIAlertController(title: "", message: AppMessages.Login.logout, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Logout", style: .default , handler: { (_) in
            guard Reachability.isConnectedToNetwork() else {
                self.showAlert(message: AppMessages.AlertTitles.noInternet)
                return
            }
            let postUploadInProgressKey = Constant.CoreData.PostEntityKeys.uploadingInProgress.rawValue
            let predicate = NSPredicate(format: "\(postUploadInProgressKey) == %d",1)
            let posts:[Postinfo] = CoreDataManager.shared.getEntityData(with: predicate, of: Constant.CoreData.postEntity) as! [Postinfo]
            if posts.count > 0 {
                self.showAlert(withTitle: "Just a moment", message: AppMessages.AlertTitles.cannotLogoutWhilePostUploading, okayTitle: AppMessages.AlertTitles.Ok, okCall: {
                })
                return
            }
            self.logout()
        }))

        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: {
        })
    }
    
    // MARK: Api helpers
    private func updateFeedsOption(option: NewsFeedAlgoOption) {
        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerUserAPI().updateOptionToSeeTematesPosts(optionType: option, completion: { (_) in
                self.hideLoader()
                User.sharedInstance.algoOption = option
                UserManager.saveCurrentUser(user: User.sharedInstance)
            }, failure: { (error) in
                self.hideLoader()
                //self.tableView.reloadData()
                self.showAlert(message: error.message ?? "")
            })
        }
    }
    
    // MARK: Set Navigation
    func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.account.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
}

extension AccountController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if AccountSections(rawValue: indexPath.row) != nil {
            guard let cell:AccountTableCell = tableView.dequeueReusableCell(withIdentifier: AccountTableCell.reuseIdentifier, for: indexPath) as? AccountTableCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.initialize(atIndexPath: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    //clear all user information and
    private func logoutUserAction() {
        UserManager.logout()
        
        let data: [String: Any] = ["request": MessageKeys.logout]
        Watch_iOS_SessionManager.shared.updateApplicationContext(data: data)
        
        let loginVC:LoginViewController = UIStoryboard(storyboard: .main).initVC()
        appDelegate.setNavigationToRoot(viewContoller: loginVC)
    }
    
    //logout api call
    private func logout() {
        self.showLoader()
        DIWebLayerUserAPI().logout(success: { (_) in
            self.hideLoader()
            self.logoutUserAction()
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(withTitle: "", message: error.message ?? "", okayTitle: AppMessages.AlertTitles.Ok, okCall: {
            })
        })
    }
}

// MARK: AccountTableCellDelegate
extension AccountController: AccountTableCellDelegate {
    func noInternetConnection() {
        self.showAlert(message: AppMessages.AlertTitles.noInternet)
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        if Reachability.isConnectedToNetwork() {
            self.seeOnlyTematesFeedSwitchTapped(sender: sender)
        } else {
            if sender.isOn {
                sender.setOn(false, animated: true)
            } else {
                sender.setOn(true, animated: true)
            }
            
        }
    }
    func seeOnlyTematesFeedSwitchTapped(sender: UISwitch) {
        if let algoType = UserManager.getCurrentUser()?.algoOption {
            self.updateFeedsOption(option: algoType == .new ? .old : .new)
        }
    }
}
