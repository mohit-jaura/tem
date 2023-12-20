//
//  LeftSideMenuController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 20/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SideMenu

enum LeftSideMenuSections: Int, CaseIterable {
    case home = 0
    case notification
    case profile
    case leaderboard
//    case devices
    case shareApp
    case settings
    case version
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .notification:
            return "Notifications"
        case .profile:
            return "Profile & Account"
        case .leaderboard:
            return "Leaderboard"
//        case .devices:
//            return "Link Apps & Devices"
        case .shareApp:
            return "Share App"
        case .settings:
            return "Settings"
        case .version:
            return ""
        }
    }
    var icon: UIImage? {
        switch self {
        case .home:
            return #imageLiteral(resourceName: "Setting_Home")
        case .notification:
            return #imageLiteral(resourceName: "setting_notification")
        case .profile:
            return #imageLiteral(resourceName: "avatar-b")
        case .leaderboard:
            return #imageLiteral(resourceName: "leaderboard-b")
//        case .devices:
//            return #imageLiteral(resourceName: "setting_unlink")
        case .shareApp:
            return #imageLiteral(resourceName: "setting_share")
        case .settings:
            return #imageLiteral(resourceName: "setting_settings")
        case .version:
            return nil
        }
    }
}

enum SettingHeadings: Int, CaseIterable {
//    case account = 0
//    case privacyNadSecurity = 1
//    case notificationSettings = 2
    case contactUs = 0
    case faqs = 1
    case about = 2
    
    var title: String {
        switch self {
//        case .account:
//            return "Account"
//        case .privacyNadSecurity:
//            return "Privacy & Security"
//        case .notificationSettings:
//            return "Notification Settings"
        case .contactUs:
            return "Contact Us"
        case .faqs:
            return "FAQs"
        case .about:
            return "About"
        }
    }
    
    
}

class LeftSideMenuController: UIViewController {
    
    // MARK: Variables.
    var isSettingOpen:Bool = false
    // MARK: IBOutlets.
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.getUpdatedUnreadNotiCount()
        self.setData()
    }
    
    func setData() {
        if let imageUrl = User.sharedInstance.profilePicUrl {
            let url = URL(string: imageUrl)
            userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        userNameLabel.text = "\(User.sharedInstance.firstName ?? "") \(User.sharedInstance.lastName ?? "")".trim
    }
    
    func getUpdatedUnreadNotiCount() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count,id) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Fucntion to remove sidemenu
    @IBAction func buttonActionToHideSideMenu(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LeftSideMenuController:UITableViewDelegate,UITableViewDataSource {
    
    // MARK: TableView Delegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return LeftSideMenuSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedSection = LeftSideMenuSections(rawValue: section), (selectedSection == .settings && isSettingOpen == true ) {
            return SettingHeadings.allCases.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let cell:LeftMenuTableCell = (tableView.dequeueReusableCell(withIdentifier: LeftMenuTableCell.reuseIdentifier) as? LeftMenuTableCell) else {
            return UIView()
        }
        if let section = LeftSideMenuSections(rawValue: section) {
            cell.setData(section: section,isSettingOpen:self.isSettingOpen)
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:LeftMenuSettingOptionsTableCell = (tableView.dequeueReusableCell(withIdentifier: LeftMenuSettingOptionsTableCell.reuseIdentifier) as? LeftMenuSettingOptionsTableCell) else {
            return UITableViewCell()
        }
        if let selectedSection = LeftSideMenuSections(rawValue: indexPath.section), selectedSection == .settings {
            cell.headingLabel.text = SettingHeadings(rawValue: indexPath.row)?.title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedRow = SettingHeadings(rawValue: indexPath.row) {
            switch selectedRow {
            case .contactUs:
                let selectedVC:ContactAdministerController = UIStoryboard(storyboard: .settings).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .faqs:
                let selectedVC:FAQViewController = UIStoryboard(storyboard: .settings).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .about:
                let selectedVC:AboutController = UIStoryboard(storyboard: .settings).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            }
        }
    }
}

extension LeftSideMenuController : LeftMenuTableCellDelegate {
    func cellSelectionHandling(indexPath: IndexPath) {
        if let selectedSection = LeftSideMenuSections(rawValue: indexPath.section) {
            switch selectedSection {
            case .home:
                self.dismiss(animated: true) {
                    appDelegate.popToRootViewController()
                }
            case .notification:
                let selectedVC:NotificationsController = UIStoryboard(storyboard: .notification).initVC()
                    selectedVC.screenFrom = .dashboard
                self.navigationController?.pushViewController(selectedVC, animated: true)
//            case .devices:
//                let selectedVC:DeviceController = UIStoryboard(storyboard: .sidemenu).initVC()
//                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .shareApp:
                if let name = URL(string: AppMessages.AppUpdate.url), !name.absoluteString.isEmpty {
                    let objectsToShare = ["To download the TĒM App follow link:- \n \(name)"]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
            case .settings:
                self.isSettingOpen = !self.isSettingOpen
                self.tableView.reloadData()
            case .profile:
                let vc: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                vc.isComingFromDashboard = false
                self.navigationController?.pushViewController(vc, animated: true)
            case .leaderboard:
                let leaderboardController: LeaderboardViewController = UIStoryboard(storyboard: .dashboard).initVC()
                
                self.navigationController?.pushViewController(leaderboardController, animated: true)
            default:
                break
            }
        }
    }
}
