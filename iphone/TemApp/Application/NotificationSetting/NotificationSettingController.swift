//
//  NotificationSettingController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 20/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
enum NotificationSettingSections: Int, CaseIterable {
    
    case push = 0
    case calender = 1
    //case moments = 2
    
    
    var title: String {
        switch self {
        case .push:
            return "PUSH"
        case .calender:
            return "CALENDAR"
            //        case .moments:
            //            return "Success Moments"
            
        }
    }
}


class NotificationSettingController: DIBaseController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
       // self.configureNavigation()
    }
    
    // MARK: Set Navigation
    func configureNavigation(){
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.notificationSetting.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension NotificationSettingController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationSettingSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = NotificationSettingSections(rawValue: indexPath.row) {
            guard let cell:NotificationTableCell = tableView.dequeueReusableCell(withIdentifier: NotificationTableCell.reuseIdentifier, for: indexPath) as? NotificationTableCell else {
                return UITableViewCell()
            }
            cell.setData(section: currentSection,indexPath:indexPath)
            cell.delegate = self
            return cell
        }else{
            return UITableViewCell()
        }
    }
}

extension NotificationSettingController: NotificationTableCellDelegate {
    func handleTap(index: Int, status: Bool) {
        var toggleStatus = 0
        if status{
            toggleStatus = pushStatus.on.rawValue
        }
        else{
            toggleStatus = pushStatus.off.rawValue
        }
        if let section = NotificationSettingSections(rawValue: index){
            switch section{
            case .push:
                SettingsAPI().setPushNotificationStatus { message in
                    User.sharedInstance.pushNotificationStatus = toggleStatus
                    if toggleStatus == 0{
                        SettingsAPI().setCalenderNotificationStatus { message in
                            User.sharedInstance.calenderNotificationStatus = toggleStatus
                            self.tableView.reloadData()
                        } failure: { error in
                            self.showAlert(message:error.message)
                        }
                    }
                } failure: { error in
                    self.showAlert(message:error.message)
                }
                
            case .calender:
                SettingsAPI().setCalenderNotificationStatus { message in
                    User.sharedInstance.calenderNotificationStatus = toggleStatus
                } failure: { error in
                    self.showAlert(message:error.message)
                }
            }
        }
    }
    
    /*
     func handleTap(index: Int,status:Bool) {
     if let section = NotificationSettingSections(rawValue: index) {
     switch section {
     case .push:
     let calenderStatus = User.sharedInstance.calenderNotificationStatus
     if User.sharedInstance.pushNotificationStatus == pushStatus.on.rawValue {
     User.sharedInstance.calenderNotificationStatus = pushStatus.off.rawValue
     self.tableView.reloadRows(at: [IndexPath(row: (index+1), section: 0)], with: .none)
     }
     SettingsAPI().setPushNotificationStatus(success: { (message) in
     if User.sharedInstance.pushNotificationStatus == pushStatus.on.rawValue {
     User.sharedInstance.pushNotificationStatus = pushStatus.off.rawValue
     User.sharedInstance.calenderNotificationStatus = pushStatus.off.rawValue
     self.tableView.reloadRows(at: [IndexPath(row: (index+1), section: 0)], with: .none)
     }else{
     User.sharedInstance.pushNotificationStatus = pushStatus.on.rawValue
     }
     UserManager.saveCurrentUser(user: User.sharedInstance)
     }) { (error) in
     self.showAlert(message:error.message)
     if User.sharedInstance.pushNotificationStatus == pushStatus.on.rawValue {
     User.sharedInstance.calenderNotificationStatus = calenderStatus
     self.tableView.reloadRows(at: [IndexPath(row: (index+1), section: 0)], with: .none)
     }
     self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
     }
     case .calender:
     SettingsAPI().setPushNotificationStatus(success: { (message) in
     if User.sharedInstance.calenderNotificationStatus == pushStatus.on.rawValue {
     User.sharedInstance.calenderNotificationStatus = pushStatus.off.rawValue
     }else{
     User.sharedInstance.calenderNotificationStatus = pushStatus.on.rawValue
     }
     UserManager.saveCurrentUser(user: User.sharedInstance)
     }) { (error) in
     self.showAlert(message:error.message)
     self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
     }
     }
     }
     }
     */
    
}
