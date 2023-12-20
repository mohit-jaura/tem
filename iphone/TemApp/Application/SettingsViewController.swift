//
//  SettingsViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 13/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func contactUsTapped(_ sender: CustomButton) {
        let contactUsVC: ContactAdministerController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(contactUsVC, animated: true)
        
    }
    
    @IBAction func aboutTapped(_ sender: CustomButton) {
        let aboutVC: AboutController = UIStoryboard(storyboard: .settings).initVC()
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
}
