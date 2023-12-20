//
//  DeviceController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 28/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class AppsController: DIBaseController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var connectionShadowView: SSNeumorphicView!{
        didSet{
            connectionShadowView.setOuterDarkShadow()
        }
    }
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var kitActivationLabel: UILabel!
    override func viewDidLoad(){
        super.viewDidLoad()
        self.updateUI()
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
        self.setNavigationController(titleName: Constant.ScreenFrom.apps.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    private func updateUI() {
        if HealthKit.instance?.healthSyncEnabled == true {
            kitActivationLabel.text = "DISCONNECT FROM THE APPLE HEALTH KIT."
            self.subscribeButton.setTitle("DISCONNECT", for: .normal)
        }
        else {
            kitActivationLabel.text = "CONNECT TO THE APPLE HEALTH KIT."
            self.subscribeButton.setTitle("CONNECT", for: .normal)
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func importFromHealth(_ sender: Any) {
        let days = 30
        let end = Date()
        let start = end.addDay(n: -days)
        HealthKit.instance?.readWorkouts(startDate: start, endDate: end) { (exported, error) in
            if let workouts = exported {
                self.showLoader()
                DIWebLayerActivityAPI().importActivities(parameters: workouts.getDictionary()) { (response) in
                    self.hideLoader()
                    self.showAlert(withTitle: "", message: "New activities from Health are imported successfully")
                } failure: { error in
                    self.hideLoader()
                    self.showAlert(withError: error)
                }
            }
        }
    }
    
    @IBAction func subscribeAction(_ sender: Any) {
        if HealthKit.instance?.healthSyncEnabled == false {
            HealthKit.instance?.enableSyncWithHealthKit { (success, _) in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(withTitle: "", message: "Sync with Health enabled")
                        self.updateUI()
                    }
                    else {
                        self.showAlert(withError: DIError(title: "", message: "Error occured when subscribing to Health", code: .unknown))
                    }
                }
            }
        }
        else {
            HealthKit.instance?.disableSyncWithHealthKit { (success, _) in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(withTitle: "", message: "Sync with Health disabled")
                        self.updateUI()
                    }
                }
            }
        }
    }
}
