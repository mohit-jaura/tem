//
//  AddWeightLogViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 02/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

final class AddWeightLogViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var outerShadowView: [SSNeumorphicView]!
    @IBOutlet weak var textFieldShadowView: SSNeumorphicView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var weightField: UITextField!
    // MARK: - Properties
    var saveLogHandelr: OnlyDoublbeCompletion?
    var weight: Double = 0.0
    var healthType: Int?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
    }
    
    // MARK: - IBActions
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        weight = weightField.text?.toDouble() ?? 0.0
        if let saveLogHandelr = saveLogHandelr {
            saveLogHandelr(weight)
        }
    }
    // MARK: - Methods
    
    private func initUI() {
        for view in outerShadowView {
            view.setOuterDarkShadow()
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            if view.tag == 11 { // 11 set statically to save button view in storyboard
                view.viewNeumorphicCornerRadius = view.frame.height / 2
            }
        }
        textFieldShadowView.setOuterDarkShadow()
        textFieldShadowView.viewDepthType = .innerShadow
        textFieldShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        if healthType != 0{
            let title = HealthInfoType(rawValue: (healthType ?? 0) - 1)?.getTitle() ?? ""
            weightField.setCustomPlaceholder(placeholder: title.uppercased())
        } else{
            weightField.setCustomPlaceholder(placeholder: "WEIGHT")
        }

    }
}
