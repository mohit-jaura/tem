//
//  SelectMetricsHoneyCombView.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

enum Metrics: Int {
    case steps = 1
    case distance
    case calories
    case totalActivites
    case totalActivityTime
    case fundraising
    
    var title: String {
        switch self {
        case .steps:
            return Constant.MetricsConstants.steps
        case .distance:
            return Constant.MetricsConstants.distance
        case .calories:
            return Constant.MetricsConstants.calories
        case .totalActivites:
            return Constant.MetricsConstants.activities
        case .totalActivityTime:
            return Constant.MetricsConstants.activityTime
        default:
            return ""
        }
    }
    
    var measuringText: String {
        switch self {
        case .steps, .calories, .distance:
            return "Max".localized
        default:
            return "Total".localized
        }
    }
    
    static let totalEffortLabel: String = "Total Effort"
    static let totalEffortTitle: String = "All Metrics"
    
    static let selectableMetricsCount: Int = 4
    
    func formatValue(_ value: Double) -> String {
        switch self {
        case .totalActivityTime:
            let totalTime = value.toInt() ?? 0
            let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTime)
            let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
            return "\(displayTime)"
        case .totalActivites, .steps:
            let value = value.toInt() ?? 0
            return "\(value)"
        case .distance:
            let value = value.rounded(toPlaces: 2)
            return "\(value) \(value == 1 ? "mile" : "miles")"
        case .calories:
            let value = value.rounded(toPlaces: 2)
            return "\(value) \(value == 1 ? "calorie" : "calories")"
        case .fundraising:
            return "$\(value.rounded(toPlaces: 2))"
        }
    }
}

protocol SelectMetricsHoneCombViewDelegate: AnyObject {
    func didClickOnMetricHoneyComb(sender: UIButton, metrics: Metrics)
    func tappedOnStartButton()
    func isGoal() -> Bool
}

class SelectMetricsHoneyCombView: UIView, HoneyCombViewable {
    
    // MARK: Properties
    weak var delegate: SelectMetricsHoneCombViewDelegate?
    var minNumberOfItemsInRow: Int = 3
    var numberOfRows: Int = 5//4
    var dividerForHeight: Double = 3.2
    
    var scrollView:UIScrollView!
    var contentView: UIView!
    var y_Cordinate:CGFloat = 0.0
    var safeAreaHeight:CGFloat = 0.0
    var topSafeArea:CGFloat = 0.0
    var isEditingChallenge: Bool?
    var isEditingGoal: Bool?
    var selectedMetrics: [Int]?
    var value: Any?
    
    var isFirstSubviewsLayout: Bool = true // fix Goal target selection
    
    // MARK: View life Cycle.....
    override func layoutSubviews() {
        if (self.isFirstSubviewsLayout) {
            self.reloadData()
            self.isFirstSubviewsLayout = false
        }
    }
    
    // MARK: Private Methods.....
    
    private func reloadData() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        createLayout()
    }
    
    private func createLayout() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.backgroundColor = .clear
        self.contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height ))
        self.scrollView.addSubview(self.contentView)
        self.addSubview(self.scrollView)
        drawHoneyCombView()
    }
    
    private func drawHoneyCombView() {
        let widthOfItem = (UIScreen.main.bounds.width - 3*self.padding)/CGFloat(minNumberOfItemsInRow)
        let heightOfItem = (widthOfItem / 1.13) + self.padding/2 //1.13 is the aspect ratio of width and height
        y_Cordinate = -safeAreaHeight
        
        var itemsInRow:Int = 0
        
        for outerIndex in 0..<numberOfRows {
            if (isEven(outerIndex)) {
                itemsInRow = minNumberOfItemsInRow + 1
            } else {
                itemsInRow = minNumberOfItemsInRow
            }
            
            for innerIndex in 0..<itemsInRow {
                
                let honeyCombView = HoneyComb()
                honeyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                honeyCombView.initializeDefaultViewLayout()
                var centerX:CGFloat!
                var centerY:CGFloat!
                
                if (isEven(outerIndex)) {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2) - (self.padding)
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (self.padding/2)
                }
                centerY = (CGFloat(outerIndex) * heightOfItem)
                centerY -= heightOfItem/3
                centerY += self.padding/2

                if outerIndex == 0 {
                    honeyCombView.backGroundImage.image = UIImage(named: "white-honey")
                }
                if(outerIndex == 1 || outerIndex == 2) {
                    self.setViewForDifferentMetrics(outerIndex: outerIndex, innerIndex: innerIndex, honeyCombView: honeyCombView)
                }
                
                honeyCombView.center = CGPoint(x: centerX, y: centerY)
                self.contentView.addSubview(honeyCombView)
            }
            
        }
        self.contentView.frame = CGRect(x: 0, y: y_Cordinate , width: self.bounds.width, height: self.bounds.height)
    }
    
    /// setting the honeycombs for different metrics
    private func setViewForDifferentMetrics(outerIndex:Int, innerIndex:Int,honeyCombView:HoneyComb) {
        var selectionMetric: Metrics?
        if outerIndex == 1 {
            if innerIndex == 0 {
                selectionMetric = Metrics.steps
            }
            if innerIndex == 1 {
                selectionMetric = Metrics.distance
            }
            if innerIndex == 2 {
                selectionMetric = Metrics.calories
            }
        } else if outerIndex == 2 {
            if innerIndex == 1 {
                selectionMetric = Metrics.totalActivites
            }
            if innerIndex == 2 {
                selectionMetric = Metrics.totalActivityTime
            }
        }
        if let selectionMetric = selectionMetric {
            honeyCombView.tag = selectionMetric.rawValue
            honeyCombView.honeyCombButton.tag = selectionMetric.rawValue
            
            if (selectionMetric == Metrics.steps) {
                // replace steps with Total Effort tile
                honeyCombView.title.text = Metrics.totalEffortTitle.uppercased()
                honeyCombView.valueLabel.text = Metrics.totalEffortLabel.uppercased()
                honeyCombView.honeyCombButton.addTarget(self, action: #selector(totalEffortHoneyCombTapped(sender:)), for: .touchUpInside)
            }
            else {
                honeyCombView.title.text = selectionMetric.title.uppercased()
                honeyCombView.valueLabel.text = selectionMetric.measuringText.uppercased()
                
                honeyCombView.honeyCombButton.addTarget(self, action: #selector(metricHoneyCombTapped(sender:)), for: .touchUpInside)
            }
            honeyCombView.valueLabel.isHidden = false
            honeyCombView.title.isHidden = false
            let disabled: Bool = selectionMetric == Metrics.steps && self.delegate?.isGoal() == true
            honeyCombView.setMetricsViewFor(state: false, disabled: disabled)
            self.updateSelectedViewsInitially(honeyComb: honeyCombView)
        }
    }
    
    /// this function is called when the honeycomb is tapped
    @objc func metricHoneyCombTapped(sender: UIButton) {
        for subview in self.contentView.subviews {
            if let honecombView = subview as? HoneyComb {
                if honecombView.tag == sender.tag {
                    honecombView.isSelected.toggle()
                    if let currentMetric = Metrics(rawValue: sender.tag) {
                        self.delegate?.didClickOnMetricHoneyComb(sender: sender, metrics: currentMetric)
                    }
                }
            }
        }
        if (delegate?.isGoal() != true) {
            var totalEffort: HoneyComb? = nil
            var allSelected: Bool = true
            for subview in self.contentView.subviews {
                if let honecombView = subview as? HoneyComb {
                    if honecombView.tag == Metrics.steps.rawValue {
                        totalEffort = honecombView
                    } else if (Metrics(rawValue: honecombView.tag) != nil) {
                        allSelected = allSelected && honecombView.isSelected
                    }
                }
            }
            totalEffort?.setMetricsViewFor(state: allSelected)
        }
    }
    
    /// this function is called when the Total Effort honeycomb is tapped
    @objc func totalEffortHoneyCombTapped(sender: UIButton) {
        if (delegate?.isGoal() != true) {
            // only for Challenge
            var totalEffort: HoneyComb? = nil
            var all: [HoneyComb] = []
            var unselected: [HoneyComb] = []
            for subview in self.contentView.subviews {
                if let honecombView = subview as? HoneyComb {
                    if honecombView.tag == Metrics.steps.rawValue {
                        totalEffort = honecombView
                    } else {
                        if (Metrics(rawValue: honecombView.tag) != nil) {
                            all.append(honecombView)
                            if (!honecombView.isSelected) {
                                unselected.append(honecombView)
                            }
                        }
                    }
                }
            }
            var toToggle: [HoneyComb] = []
            if (unselected.count == 0) {
                totalEffort?.setMetricsViewFor(state: false)
                toToggle = all
            } else {
                totalEffort?.setMetricsViewFor(state: true)
                toToggle = unselected
            }
            for honecombView in toToggle {
                honecombView.isSelected.toggle()
                if let currentMetric = Metrics(rawValue: honecombView.tag) {
                    self.delegate?.didClickOnMetricHoneyComb(sender: sender, metrics: currentMetric)
                }
            }
        }
    }
    
    /// call this function to update the view for the selected or unselected honey comb view
    /// - Parameters:
    /// - metric: the value of the selected or unselected metric
    func updateViewForMetricHoneyComb(withMetric metric: Metrics) {
        for subview in self.contentView.subviews {
            if let honeycombView = subview as? HoneyComb {
                if honeycombView.tag == metric.rawValue {
                    honeycombView.setMetricsViewFor(state: honeycombView.isSelected)
                }
            }
        }
    }
    
    /// this will set the honeycombs preselected
    /// - Parameter honeyComb: honeycomb view instance
    func updateSelectedViewsInitially(honeyComb: HoneyComb) {
        if let selectedMetrics = self.selectedMetrics {
            if let isEditingChallenge = self.isEditingChallenge,
               isEditingChallenge {
                
                //for challenge
                if let m = selectedMetrics.first(where: {$0 == honeyComb.tag}) {
                    if m == Metrics.steps.rawValue {
                        // restore steps for old challenge
                        honeyComb.title.text = Metrics.steps.title.uppercased()
                        honeyComb.valueLabel.text = Metrics.steps.measuringText.uppercased()
                        honeyComb.honeyCombButton.removeTarget(self, action: #selector(totalEffortHoneyCombTapped(sender:)), for: .touchUpInside)
                        honeyComb.honeyCombButton.addTarget(self, action: #selector(metricHoneyCombTapped(sender:)), for: .touchUpInside)
                    }
                    honeyComb.setMetricsViewFor(state: true)
                } else {
                    let selected: Bool = (honeyComb.tag == Metrics.steps.rawValue && selectedMetrics.count == Metrics.selectableMetricsCount)
                    honeyComb.setMetricsViewFor(state: selected)
                }
                //disable buttons, user cannot edit the challenge metrics
                honeyComb.honeyCombButton.isUserInteractionEnabled = false
                return
            }
        }
        if let isEditingGoal = self.isEditingGoal,
           isEditingGoal {
            if let target = self.value as? [GoalTarget],
               let first = target.first {
                
                if honeyComb.tag == first.matric ?? 0 {
                    honeyComb.honeyCombButton.isUserInteractionEnabled = true
                    if let metric = Metrics(rawValue: honeyComb.tag) {
                        var displayValue = first.value?.formatted ?? ""
                        switch metric {
                        case .totalActivites, .steps:
                            displayValue = "\(first.value?.rounded(toPlaces: 2).toInt() ?? 0)"
                        default:
                            break
                        }
                        if (metric == .steps) {
                            // restore steps for old goal
                            honeyComb.title.text = Metrics.steps.title.uppercased()
                            honeyComb.honeyCombButton.removeTarget(self, action: #selector(totalEffortHoneyCombTapped(sender:)), for: .touchUpInside)
                            honeyComb.honeyCombButton.addTarget(self, action: #selector(metricHoneyCombTapped(sender:)), for: .touchUpInside)
                        }
                        self.updateGoalTargetOn(honeyComb: honeyComb, value: displayValue, metric: metric, state: true)
                    }
                    
                } else {
                    honeyComb.honeyCombButton.isUserInteractionEnabled = false
                    if let metric = Metrics(rawValue: honeyComb.tag) {
                        self.updateGoalTargetOn(honeyComb: honeyComb, value: "", metric: metric, state: false)
                    }
                }
            }
        }
    }
    
    func updateForGoalMetricValue(withMetric metric: Metrics, value:String){
        
        /*This Fucntion will reset all honey combview because in case of goal user can select
         one metric at a time.
         */
        self.reloadData()
        
        //Then update value of selected metric...
        
        for subview in self.contentView.subviews {
            if let honeycombView = subview as? HoneyComb {
                if honeycombView.tag == metric.rawValue {
                    self.updateGoalTargetOn(honeyComb: honeycombView, value: value, metric: metric, state: true)
                }
            }
        }
        
    }
    
    private func updateGoalTargetOn(honeyComb: HoneyComb, value: String, metric: Metrics, state: Bool) {
        var displayValue = value
        if metric == .distance {
            displayValue = value + " Miles"
        }
        honeyComb.setGoalMetricvalue(state: state, value: displayValue)
    }
    
}//Class..

