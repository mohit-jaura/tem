//
//  ActivityPauseResumeVC.swift
//  TemApp
//
//  Created by PrabSharan on 05/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class ActivityPauseResumeVC: UIViewController {
    var playPause:OnlySuccess?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func playPauseTapped(_ sender: UIButton) {
        playPause?()
    }

}
