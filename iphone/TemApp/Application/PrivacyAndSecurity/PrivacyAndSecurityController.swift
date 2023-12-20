//
//  PrivacyAndSecurityController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 19/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
enum PrivacySections: Int, CaseIterable {
    case account = 0
    case blockedUser = 1
    case contacts = 2
    
    var title: String {
        switch self {
        case .account:
            return "Private Profile"
        case .blockedUser:
            return "Blocked list"
        case .contacts:
            return "Contacts"
        }
    }
    var message: String {
        switch self {
        case .account:
            return "IF YOU ARE PRIVATE, ONLY YOUR TĒMATES WILL BE ABLE TO VIEW YOUR POSTS. ACTIONS IN A TĒM WILL BE VISIBLE BY OTHER USERS IN THE TĒM."
        default:
            return ""
        }
    }
}

class PrivacyAndSecurityController: DIBaseController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var privateProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        initializer()
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        //self.configureNavigation()
    }
    
    // MARK: Set Navigation
    func configureNavigation(){
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.privacySecurity.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    func initializer(){
       // tableView.isHidden = true
        messageLabel.text = PrivacySections(rawValue: 0)?.message
        
        if User.sharedInstance.isPrivate == Proprivate.isPrivate.rawValue {
            privateProfileButton.isSelected = true
        }else{
            privateProfileButton.isSelected = false
        }
    }
    @IBAction func PrivateProfileButton(_ sender: UIButton) {
        privateProfileButton.isSelected = !privateProfileButton.isSelected
        setAccountPrivate(status: sender.isSelected)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func privacyActionsTapped(_ sender: UIButton) {
        if let selectedButton = PrivacySections(rawValue: sender.tag) {
            switch selectedButton {
                
            case .account:
                break
            case .blockedUser:
                let selectedVC:BlockedUserController = UIStoryboard(storyboard: .privacy).initVC()
                self.present(selectedVC, animated: true)
             //   self.navigationController?.pushViewController(selectedVC, animated: true)
            case .contacts:
                let selectedVC:ContactsController = UIStoryboard(storyboard: .privacy).initVC()
                self.present(selectedVC, animated: true)
               // self.navigationController?.pushViewController(selectedVC, animated: true)
            }
        }
    }
}

extension PrivacyAndSecurityController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PrivacySections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = PrivacySections(rawValue: indexPath.row) {
            guard let cell:PrivacyAndSecurityTableCell = tableView.dequeueReusableCell(withIdentifier: PrivacyAndSecurityTableCell.reuseIdentifier, for: indexPath) as? PrivacyAndSecurityTableCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setData(section:currentSection)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedSection = PrivacySections(rawValue: indexPath.row) {
            switch selectedSection {
                
            case .account:
                break
            case .blockedUser:
                let selectedVC:BlockedUserController = UIStoryboard(storyboard: .privacy).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .contacts:
                let selectedVC:ContactsController = UIStoryboard(storyboard: .privacy).initVC()
                self.navigationController?.pushViewController(selectedVC, animated: true)
            }
        }
    }
}

// MARK: Function will call when user set profile to private and vice versa.
extension PrivacyAndSecurityController:PrivacyAndSecurityTableCellDelegate {
    func setAccountPrivate(status: Bool) {
        guard Reachability.isConnectedToNetwork() else {
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
            return
        }
        self.showLoader()
        SettingsAPI().setProfifePrivate( success: { (status) in
            self.hideLoader()
            if User.sharedInstance.isPrivate == Proprivate.isPrivate.rawValue {
                User.sharedInstance.isPrivate = Proprivate.notPrivate.rawValue
            }else{
                User.sharedInstance.isPrivate = Proprivate.isPrivate.rawValue
            }
            UserManager.saveCurrentUser(user: User.sharedInstance)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
}
