//
//  CompleteChecklistViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 19/10/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class CompleteChecklistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backTapped( _ sender: UIButton) {
        self.presentingViewController?.presentingViewController!.dismiss(animated: true, completion: nil)
    }

}
