//
//  GoalAndChallengeSideMenuViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 23/11/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol GoalMetricData {
    func getMetricValue(value:String,metric:Metrics)
}
class GoalAndChallengeSideMenuViewController: DIBaseController,UITextFieldDelegate {
    var currentValue: Double?
    // MARK: IBOutlets
    @IBOutlet weak var distanceHeight: NSLayoutConstraint!
    @IBOutlet weak var caloriesHeight: NSLayoutConstraint!
    @IBOutlet weak var activityHeight: NSLayoutConstraint!
    @IBOutlet weak var timeHeight: NSLayoutConstraint!
    @IBOutlet var outerShadowViews: [SSNeumorphicView]!
    @IBOutlet var innerShadowViews: [SSNeumorphicView]!
    @IBOutlet weak var headerLabel:UILabel!
    @IBOutlet weak var distanceTF:UITextField!
    @IBOutlet weak var caloriesTF:UITextField!
    @IBOutlet weak var totalActivityTF:UITextField!
    @IBOutlet weak var timeTF:UITextField!
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var mainBackView: UIView!
    // MARK: Properties
    var screenFrom:Constant.ScreenFrom?
    var metricsDict:[String:[String]] = [:]
    var metric:Metrics = .distance
    var delegate:GoalMetricData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initOuterShadowView()
        self.initInnerShadowView()
        self.initTextFields()
        self.addTapGesture()
        self.setData()
    }
    
    // MARK: IBActions
    @IBAction func saveButtonTapped(_ sender:UIButton) {
        if isValidMatric() {
            if metric == .distance {
                delegate?.getMetricValue(value: distanceTF.text ?? "", metric: .distance)
            } else if metric == .calories {
                delegate?.getMetricValue(value: caloriesTF.text ?? "", metric: .calories)
            } else if metric == .totalActivites {
                delegate?.getMetricValue(value: totalActivityTF.text ?? "", metric: .totalActivites)
            } else {
                delegate?.getMetricValue(value: timeTF.text ?? "", metric: .totalActivityTime)
            }
            
        }
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func onClickDistanceAdd(_ sender:UIButton) {
        distanceHeight.constant = 59.0
        caloriesHeight.constant = 0.0
        activityHeight.constant = 0.0
        timeHeight.constant = 0.0
        metric = .distance
        caloriesTF.text = ""
        timeTF.text = ""
        totalActivityTF.text = ""
    }
    
    @IBAction func onClickActivitiesAdd(_ sender:UIButton) {
        distanceHeight.constant = 0.0
        caloriesHeight.constant = 0.0
        activityHeight.constant = 59.0
        timeHeight.constant = 0.0
        metric = .totalActivites
        distanceTF.text = ""
        caloriesTF.text = ""
        timeTF.text = ""
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func onClickCaloriesAdd(_ sender:UIButton) {
        distanceHeight.constant = 0.0
        caloriesHeight.constant = 59.0
        activityHeight.constant = 0.0
        timeHeight.constant = 0.0
        metric = .calories
        distanceTF.text = ""
        timeTF.text = ""
        totalActivityTF.text = ""
    }

    @IBAction func onClickTimeAdd(_ sender:UIButton) {
        distanceHeight.constant = 0.0
        caloriesHeight.constant = 0.0
        activityHeight.constant = 0.0
        timeHeight.constant = 59.0
        metric = .totalActivityTime
        distanceTF.text = ""
        caloriesTF.text = ""
        totalActivityTF.text = ""
    }
    // MARK: Methods
    private func addTapGesture() {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.addTarget(self, action: #selector(dismissSideMenu))
        self.view.addGestureRecognizer(gesture)
    }

    private func initInnerShadowView() {
        for view in innerShadowViews {
            view.setOuterDarkShadow()
            view.viewDepthType = .innerShadow
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }

    private func initOuterShadowView() {
        for view in outerShadowViews {
            view.setOuterDarkShadow()
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            if view.tag == 11 { // tag 11 set statictly in story board for start button
                view.viewNeumorphicCornerRadius = view.frame.height / 2
            }
        }
    }
    
    private func initTextFields() {
        let textFieldsArray: [UITextField] = [distanceTF, caloriesTF, totalActivityTF, timeTF]
        for field in textFieldsArray {
            field.setCustomPlaceholder(placeholder: field.placeholder?.uppercased(), color: UIColor.gray)
        }
    }
    private func setData() {
        if let value = currentValue {
            let intConversation = Int(value)
            if metric == .distance {
                distanceHeight.constant = 59.0
                caloriesHeight.constant = 0.0
                activityHeight.constant = 0.0
                timeHeight.constant = 0.0
                distanceTF.text = "\(intConversation)"
                metric = .distance
                caloriesTF.text = ""
                timeTF.text = ""
                totalActivityTF.text = ""
            } else if metric == .totalActivites {
                distanceHeight.constant = 0.0
                caloriesHeight.constant = 0.0
                activityHeight.constant = 59.0
                timeHeight.constant = 0.0
                metric = .totalActivites
                distanceTF.text = ""
                caloriesTF.text = ""
                timeTF.text = ""
                totalActivityTF.text = "\(intConversation)"
            } else if metric == .calories {
                distanceHeight.constant = 0.0
                caloriesHeight.constant = 59.0
                activityHeight.constant = 0.0
                timeHeight.constant = 0.0
                metric = .calories
                caloriesTF.text = "\(intConversation)"
                distanceTF.text = ""
                timeTF.text = ""
                totalActivityTF.text = ""
            } else if metric == .totalActivityTime {
                distanceHeight.constant = 0.0
                caloriesHeight.constant = 0.0
                activityHeight.constant = 0.0
                timeHeight.constant = 59.0
                metric = .totalActivityTime
                distanceTF.text = ""
                caloriesTF.text = ""
                totalActivityTF.text = ""
                timeTF.text = "\(intConversation)"
            }
        }
    }
    
    @objc func dismissSideMenu() {
        self.view.slideOut(to: .right, x: 0, y: 0, duration: 0.2, delay: 0) { _ in
            self.dismiss(animated: true)
        }
    }
    
    private func isValidMatric() -> Bool {
        var message:String?
        if distanceTF.text?.isBlank ?? false && caloriesTF.text?.isBlank ?? false  && totalActivityTF.text?.isBlank ?? false  && timeTF.text?.isBlank ?? false   {
            message = AppMessages.Metric.emptyValue
        }
        if message != nil {
            showAlert(withTitle: AppMessages.AlertTitles.Alert, message: message)
            return false
        }
        return true
    }
}
