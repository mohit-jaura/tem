//
//  DeviceController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 28/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

enum HealthAppType : Int , CaseIterable {
    
    case healthKit = 0
    case fitbit = 1
    case none = 2
    
    var title : String {
        switch self {
        case .healthKit:
            return "Apple Watch"
        case .fitbit:
            return "Fitbit"
        default:
            return ""
        }
    }
}

class DeviceController: DIBaseController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
     //   self.configureNavigation()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        self.setTrackerStatus()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: true, controller: self)
        }
    }
    
    // MARK: Set Navigation
    private func configureNavigation(){
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.tem.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.clear, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setTrackerStatus() {
        if let loggedInUser = UserManager.getCurrentUser(),
            let trackerStatus = loggedInUser.trackerStatus {
            let status = CustomBool(rawValue: trackerStatus) ?? .no
            switch status {
            case .no:
                Defaults.shared.set(value: HealthAppType.none.title, forKey: .healthApp)
            case .yes:
                if let value = loggedInUser.tracker {
                    if value == 1 {
                        //health app
                        Defaults.shared.set(value: HealthAppType.healthKit.title, forKey: .healthApp)
                    } else if value == 2 {
                        Defaults.shared.set(value: HealthAppType.fitbit.title, forKey: .healthApp)
                    }
                }
            }
        }
    }
    
    // MARK: Api call
    private func updateTrackerDevice(status: CustomBool, deviceType: HealthAppType, completion: @escaping(_ success: Bool) -> Void) {
        if isConnectedToNetwork() {
            self.showLoader()
            var params: Parameters = ["tracker_status": status.rawValue]
            if deviceType != .none {
                let type: String = "\(deviceType.rawValue + 1)" //1= apple watch , 2 = fitbit
                params["tracker"] = type
            }
            else {
                params["tracker"] = "0"
            }
            DIWebLayerUserAPI().updateTrackerStatus(params: params, completion: { (_) in
                self.hideLoader()
                completion(true)
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "Unable to update the device. Please try again")
            }
        }
    }
}

extension DeviceController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1//2//HealthAppType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let cell:DeviceControllerTableCell = tableView.dequeueReusableCell(withIdentifier: DeviceControllerTableCell.reuseIdentifier, for: indexPath) as? DeviceControllerTableCell else {
            return UITableViewCell()
        }
        cell.deviceNameLable.text = HealthAppType(rawValue: indexPath.row)?.title
        if let selectedDevice = Defaults.shared.get(forKey: .healthApp) as? String , selectedDevice == HealthAppType(rawValue: indexPath.row)?.title,
            selectedDevice != HealthAppType.none.title {
            cell.checkImageView.image = #imageLiteral(resourceName: "on toggle.png")
        }else{
            cell.checkImageView.image = #imageLiteral(resourceName: "Group 7-blue.png")
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if let isActivity = Defaults.shared.get(forKey: .isActivity) as? Bool , isActivity == true {
//            if let selectedDevice = Defaults.shared.get(forKey: .healthApp) as? String , selectedDevice == HealthAppType(rawValue: indexPath.row)?.title {
//                return
//            }
//            self.showAlert(withTitle: "", message: "You have an activity in running state. To switch the device you have to complete the current activity by Home -> Activity -> Activity Progress.", okayTitle: "OK", okCall: {
//            })
//            return
            self.showAlert(withTitle: "", message: "You have an activity in running state. To switch the device you have to complete the current activity by Home -> Activity -> Activity Progress.", okayTitle: "OK", okCall: {
            })
            return
        }
        if let currentSection = HealthAppType(rawValue: indexPath.row) {
            switch currentSection {
            case .fitbit:
                FitbitAuthHandler.shareManager()?.loadVars()
                FitbitAuthHandler.shareManager()?.login(self)
                if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String,
                    deviceType == HealthAppType.fitbit.title {
                    self.updateTrackerDevice(status: .no, deviceType: .none) { (_) in
                        Defaults.shared.set(value: HealthAppType.none.title , forKey: .healthApp)
                        self.updateUser(trackerSelected: .no, tracker: .fitbit)
                        self.tableView.reloadData()
                    }
                } else {
                    self.updateTrackerDevice(status: .yes, deviceType: .fitbit) { (_) in
                        Defaults.shared.set(value: HealthAppType.fitbit.title , forKey: .healthApp)
                        self.updateUser(trackerSelected: .yes, tracker: .fitbit)
                        self.tableView.reloadData()
                    }
                }
            case .healthKit:
                if let deviceType = Defaults.shared.get(forKey: .healthApp) as? String,
                    deviceType == HealthAppType.healthKit.title {
                    self.updateTrackerDevice(status: .no, deviceType: .none) { (_) in
                        Defaults.shared.set(value: HealthAppType.none.title , forKey: .healthApp)
                        self.updateUser(trackerSelected: .no, tracker: .healthKit)
                        self.tableView.reloadData()
                    }
                } else {
                    self.updateTrackerDevice(status: .yes, deviceType: .healthKit) { (_) in
                        Defaults.shared.set(value: HealthAppType.healthKit.title , forKey: .healthApp)
                        self.updateUser(trackerSelected: .yes, tracker: .healthKit)
                        self.tableView.reloadData()
                    }
                }
            default:
                break
            }
        }
    }
    
    func updateUser(trackerSelected: CustomBool, tracker: HealthAppType) {
        let user = User.sharedInstance
        user.trackerStatus = trackerSelected.rawValue
        switch tracker {
        case .fitbit:
            user.tracker = 2
        case .healthKit:
            user.tracker = 1
        default:
            user.tracker = 0
        }
        UserManager.saveCurrentUser(user: user)
    }
}
