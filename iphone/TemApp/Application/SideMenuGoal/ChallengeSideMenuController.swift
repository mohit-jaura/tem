//
//  ChallengeSideMenuController.swift
//  TemApp
//
//  Created by Developer on 28/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
enum ChallengeMetrics: Int {
    case all = 1, distance, calories, activities, time
}
protocol ChallengeSideMenuDelegate: AnyObject {
    func didClickOnMetricHoneyComb(isAllSelected:Bool,metrics: Metrics)
}
class ChallengeSideMenuController: DIBaseController,UITextFieldDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var totalLbl:UILabel!
    @IBOutlet weak var distanceLbl:UILabel!
    @IBOutlet weak var caloriesLbl:UILabel!
    @IBOutlet weak var activityLbl:UILabel!
    @IBOutlet weak var timeLbl:UILabel!

    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var selectAllShadowView:SSNeumorphicView!
    @IBOutlet weak var distanceLabelShadowView:SSNeumorphicView!
    @IBOutlet weak var caloriesShadowView:SSNeumorphicView!
    @IBOutlet weak var activitiesShadowView:SSNeumorphicView!
    @IBOutlet weak var timeShadowView:SSNeumorphicView!
    @IBOutlet weak var headerLabel:UILabel!
    @IBOutlet weak var distanceTF:UITextField!
    @IBOutlet weak var caloriesTF:UITextField!
    @IBOutlet weak var totalActivityTF:UITextField!
    @IBOutlet weak var timeTF:UITextField!
    
    @IBOutlet weak var saveButtonShadowView:SSNeumorphicView! {
        didSet {
            saveButtonShadowView.setOuterDarkShadow()
            saveButtonShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            saveButtonShadowView.viewNeumorphicCornerRadius = saveButtonShadowView.frame.height / 2
        }
    }
    @IBOutlet weak var saveButton:UIButton!
    
    // MARK: Properties
    var allSelected:Bool = false
    private var values:[Bool] = [false, false, false, false]
    weak var delegate: ChallengeSideMenuDelegate?
    var selectedChallenges:[Int] = [Int]()
    var screenFrom:Constant.ScreenFrom?
    var metricsDict:[String:[String]] = [:]
    var selectedMetrics: [SSNeumorphicView] = []
    var unselectedMetrics: [SSNeumorphicView] = []
    var selectedLabels: [UILabel] = []
    var unselectedLabels: [UILabel] = []
    var selectedMetricss: [ChallengeMetrics] = []
    private var metric:Metrics = .distance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGesture()
        selectedMetricss = []
        selectedMetrics = []
        unselectedMetrics = [selectAllShadowView, distanceLabelShadowView, caloriesShadowView, activitiesShadowView, timeShadowView]
        unselectedLabels = [totalLbl, distanceLbl, caloriesLbl, activityLbl, timeLbl]
        selectedLabels = []
        if selectedChallenges.count > 0 {
            for challenge in selectedChallenges {
                if let metric = ChallengeMetrics(rawValue: challenge) {
                    selectedMetricss.append(metric)
                }
            }
            if selectedMetricss.count == 4 {
                selectedMetricss.append(.all)
            }
        }
        resetUI()
    }
    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        dismissSideMenu()
    }
    @IBAction func onClickTotal(_ sender:UIButton) {
        if allSelected {
            allSelected = false
            selectedMetricss.removeAll()
        } else {
            allSelected = true
            selectedMetricss.append(.all)
            for i in 0 ..< 4 {
                values[i] = false
                if i == 0 {
                    self.delegate?.didClickOnMetricHoneyComb(isAllSelected:true, metrics: .distance)
                } else if i == 1 {
                    self.delegate?.didClickOnMetricHoneyComb(isAllSelected:true,metrics: .calories)
                } else if i == 2 {
                    self.delegate?.didClickOnMetricHoneyComb(isAllSelected:true,metrics: .totalActivites)
                } else {
                    self.delegate?.didClickOnMetricHoneyComb(isAllSelected:true,metrics: .totalActivityTime)
                }
            }
        }
        resetUI()
    }
    
    @IBAction func onClickDistance(_ sender:UIButton) {
        if values[0] {
            values[0] = false
            selectedMetricss.removeAll { metric in
                return metric == .distance
            }
        }else {
            values[0] = true
            selectedMetricss.append(.distance)
        }
        
        if allSelected {
            allSelected = false
            selectedMetricss = []
            selectedMetricss.append(.distance)
        }
        resetUI()
    }
    @IBAction func onClickCalories(_ sender:UIButton) {
        if values[1]{
            values[1] = false
            selectedMetricss.removeAll { metric in
                return metric == .calories
            }
        }else{
            values[1] = true
            selectedMetricss.append(.calories)
        }
        if allSelected {
            allSelected = false
            selectedMetricss = []
            selectedMetricss.append(.calories)
        }
        resetUI()
    }
    
    @IBAction func onClickActivities(_ sender:UIButton) {
        if values[2]{
            values[2] = false
            selectedMetricss.removeAll { metric in
                return metric == .activities
            }
        }else{
            values[2] = true
            selectedMetricss.append(.activities)
        }
        if allSelected {
            allSelected = false
            selectedMetricss = []
            selectedMetricss.append(.activities)
        }
        resetUI()
    }
    
    @IBAction func onClickTime(_ sender:UIButton) {
        if values[3]{
            values[3] = false
            selectedMetricss.removeAll { metric in
                return metric == .time
            }
        }else{
            values[3] = true
            selectedMetricss.append(.time)
        }
        if allSelected {
            allSelected = false
            selectedMetricss = []
            selectedMetricss.append(.time)
        }
        resetUI()
    }
    @IBAction func saveButtonTapped(_ sender:UIButton){
        if allSelected {
            self.dismiss(animated: false, completion: nil)
        } else {
            for i in 0 ..< 4 {
                if i == 0 {
                    if values[0] {
                        self.delegate?.didClickOnMetricHoneyComb( isAllSelected:false,metrics: .distance)
                    }
                } else if i == 1 {
                    if values[1] {
                        self.delegate?.didClickOnMetricHoneyComb( isAllSelected:false,metrics: .calories)
                    }
                } else if i == 2 {
                    if values[2] {
                        self.delegate?.didClickOnMetricHoneyComb( isAllSelected:false,metrics: .totalActivites)
                    }
                } else if i == 3 {
                    if values[3] {
                        self.delegate?.didClickOnMetricHoneyComb( isAllSelected:false,metrics: .totalActivityTime)
                    }
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    private func initShadowViews(views: [SSNeumorphicView], color: UIColor) {
        for view in views {
            view.setOuterDarkShadow()
            view.viewNeumorphicMainColor = color.cgColor
        }
    }
    
    private func resetUI() {
        selectedMetrics = []
        unselectedMetrics = [selectAllShadowView, distanceLabelShadowView, caloriesShadowView, activitiesShadowView, timeShadowView]
        unselectedLabels = [totalLbl, distanceLbl, caloriesLbl, activityLbl, timeLbl]
        selectedLabels = []
        for metric in selectedMetricss {
            switch metric {
            case .all:
                selectedMetrics = [selectAllShadowView, distanceLabelShadowView, caloriesShadowView, activitiesShadowView, timeShadowView]
                unselectedMetrics = []
                selectedLabels = [totalLbl, distanceLbl, caloriesLbl, activityLbl, timeLbl]
                unselectedLabels = []
            case .distance:
                addRemoveShadowViews(view: distanceLabelShadowView)
                addRemoveLabels(label: distanceLbl)
            case .calories:
                addRemoveShadowViews(view: caloriesShadowView)
                addRemoveLabels(label: caloriesLbl)
            case .activities:
                addRemoveShadowViews(view: activitiesShadowView)
                addRemoveLabels(label: activityLbl)
            case .time:
                addRemoveShadowViews(view: timeShadowView)
                addRemoveLabels(label: timeLbl)
            }
        }
        initShadowViews(views: selectedMetrics, color: UIColor.appCyanColor)
        initShadowViews(views: unselectedMetrics, color: UIColor.appThemeDarkGrayColor)
        setLabelColor(labels: selectedLabels, color: .black)
        setLabelColor(labels: unselectedLabels, color: .white)
    }
    
    private func addRemoveShadowViews(view: SSNeumorphicView) {
        selectedMetrics.append(view)
        unselectedMetrics.removeAll { vw in
            return vw == view
        }
    }
    
    private func addRemoveLabels(label: UILabel) {
        selectedLabels.append(label)
        unselectedLabels.removeAll { lbl in
            return lbl == label
        }
    }
    private func setLabelColor(labels: [UILabel], color: UIColor) {
        for label in labels {
            label.textColor = color
        }
    }
    private func addTapGesture() {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.addTarget(self, action: #selector(dismissSideMenu))
        self.view.addGestureRecognizer(gesture)
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
