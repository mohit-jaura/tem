//
//  TestEventDetailsViewController.swift
//  TemApp
//
//  Created by Shilpa Vashisht on 13/08/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class TestEventDetailsViewController: UIViewController {
    var isMoreTapped: Bool = false
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var descriptionShadowView: SSNeumorphicView! {
        didSet {
            descriptionShadowView.viewDepthType = .innerShadow
            descriptionShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.09).cgColor
            descriptionShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
            descriptionShadowView.viewNeumorphicMainColor = descriptionShadowView.backgroundColor?.cgColor
            descriptionShadowView.viewNeumorphicCornerRadius = 8
        }
    }
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    
    @IBOutlet var tematesTableShadowView: SSNeumorphicView! {
        didSet {
            tematesTableShadowView.viewDepthType = .innerShadow
            tematesTableShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.09).cgColor
            tematesTableShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
            tematesTableShadowView.viewNeumorphicMainColor = tematesTableShadowView.backgroundColor?.cgColor
            tematesTableShadowView.viewNeumorphicCornerRadius = 8
        }
    }
    
    @IBOutlet var signupSheetShadowView: SSNeumorphicView! {
        didSet {
            self.addShadowsToRadiobuttonViews(view: signupSheetShadowView)
        }
    }
    @IBOutlet var checklistShadowView: SSNeumorphicView! {
        didSet {
            self.addShadowsToRadiobuttonViews(view: checklistShadowView)
        }
    }
    @IBOutlet var reminderShadowView: SSNeumorphicView! {
        didSet {
            self.addShadowsToRadiobuttonViews(view: reminderShadowView)
        }
    }
        
    @IBAction func moreTapped(sender: UIButton) {
        if isMoreTapped == true {
            self.descLabel.text = "this is now to small size."
            isMoreTapped = false
        } else {
            self.descLabel.text = """
                    15 Minute AMRAP
                    5 Pull Ups
                    10 Sit Ups
                    15 Lunges
                    10 Box Jumps
                    5 Pullups Lorem ipsum is the dummy text which is being shown here now.Lorem ipsum is the dummy text which is being shown here now. Lorem ipsum is the dummy text which is being shown here now. Lorem ipsum is the dummy text which is being shown here now. Lorem ipsum is the dummy text which is being shown here now. Lorem ipsum is the dummy text which is being shown here now. This is the end.
                """
        self.isMoreTapped = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func addShadowsToRadiobuttonViews(view: SSNeumorphicView) {
        view.viewDepthType = .outerShadow
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.09).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        view.viewNeumorphicMainColor = view.backgroundColor?.cgColor
        view.viewNeumorphicCornerRadius = 4
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
