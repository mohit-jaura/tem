//
//  LoaderManager.swift
//  TemApp
//
//  Created by Mohit Soni on 24/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

protocol LoaderProtocol {
    func showHUDLoader(msg: String)
    func hideHUDLoader()
}

extension LoaderProtocol where Self: UIViewController {
    func showHUDLoader(msg: String = "") {
        ProgressHUD.animationType = .circleSpinFade
        ProgressHUD.show(msg, interaction: false)
    }
    func hideHUDLoader() {
        ProgressHUD.dismiss()
    }
}
