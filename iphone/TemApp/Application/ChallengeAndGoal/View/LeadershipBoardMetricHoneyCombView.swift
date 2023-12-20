//
//  LeadershipBoardMetricHoneyCombView.swift
//  TemApp
//
//  Created by shilpa on 28/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class LeadershipBoardMetricHoneyCombView: UIView, HoneyCombViewable {
    
    // MARK: Properties
    var minNumberOfItemsInRow: Int = 4
    var numberOfRows: Int = 4//3
    var dividerForHeight: Double = 3.2
    
    var scrollView:UIScrollView!
    var contentView: UIView!
    var y_Cordinate:CGFloat = 0.0
    var safeAreaHeight:CGFloat = 0.0
    var topSafeArea:CGFloat = 0.0
    
    var selectedMetrics: [Int]?
    var scoreboard: Leaderboard?
    
    // MARK: View life Cycle.....
    override func layoutSubviews() {
        self.reloadData()
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
        guard self.bounds.height > 0 else {
            return
        }
        let widthOfItem = ((UIScreen.main.bounds.width - 20))/3.5
        let heightOfItem = (widthOfItem / 1.11)
        y_Cordinate = -safeAreaHeight
        
        var itemsInRow:Int = 0
        for outerIndex in 0..<numberOfRows {
            if (!isEven(outerIndex)) {
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
                
                //determine the center of the honey comb views
                if (!isEven(outerIndex)) {
                    centerX = self.center.x
                    if innerIndex == 2 {
                        centerX = self.center.x
                    }
                    if innerIndex == 1 {
                        centerX = self.center.x - (widthOfItem) - self.padding
                    }
                    if innerIndex == 0 {
                        centerX = self.center.x - (2 * widthOfItem) -  2 * self.padding
                    }
                    if innerIndex == 3 {
                        centerX = self.center.x + (widthOfItem) + self.padding
                    }
                    if innerIndex == 4 {
                        centerX = self.center.x + (2 * widthOfItem) +  2 * self.padding
                    }
                } else {
                    
                    if innerIndex == 1 {
                        centerX = self.center.x - (widthOfItem/2) - self.padding / 2
                    }
                    if innerIndex == 0 {
                        centerX = self.center.x - (widthOfItem + widthOfItem/2 + self.padding + self.padding/2)
                    }
                    if innerIndex == 2 {
                        centerX = self.center.x + (widthOfItem/2) + self.padding / 2
                    }
                    if innerIndex == 3 {
                        centerX = self.center.x + (widthOfItem + widthOfItem/2 + self.padding + self.padding/2)
                    }
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
                
                //update the views if there is scoreboard and selectedmetrics information
                if let scoreboard = self.scoreboard,
                    let selectedMetrics = self.selectedMetrics {
                    self.setViewForMetricValues(values: selectedMetrics, scoreboard: scoreboard)
                }
            }
            
        }
        self.contentView.frame = CGRect(x: 0, y: y_Cordinate , width: self.bounds.width, height: self.bounds.height)
    }
    
    /// setting the honeycombs for different metrics
    private func setViewForDifferentMetrics(outerIndex:Int, innerIndex:Int,honeyCombView:HoneyComb) {
        var selectionMetric: Metrics?
        if outerIndex == 1 {
            if innerIndex == 1 {
                selectionMetric = Metrics.steps
            }
            if innerIndex == 2 {
                selectionMetric = Metrics.distance
            }
            if innerIndex == 3 {
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
            honeyCombView.valueLabel.isHidden = false
            honeyCombView.title.isHidden = false
            honeyCombView.setMetricsViewFor(state: false)
            honeyCombView.tag = selectionMetric.rawValue
            honeyCombView.honeyCombButton.tag = selectionMetric.rawValue
            if (selectionMetric == Metrics.steps) {
                // replace steps with Total Effort tile
                honeyCombView.title.text = Metrics.totalEffortTitle
                honeyCombView.valueLabel.text = Metrics.totalEffortLabel
            } else {
                honeyCombView.title.text = selectionMetric.title
                honeyCombView.valueLabel.text = selectionMetric.measuringText
            }
        }
    }
    
    /// call this function to update the selected metrics view
    ///
    /// - Parameter values: the selected metrics value for the challenge
    func setViewForMetricValues(values: [Int], scoreboard: Leaderboard) {
        guard self.contentView != nil else {
            return
        }
        var totalEffort: HoneyComb? = nil
        for subview in self.contentView.subviews {
            if let honeycombView = subview as? HoneyComb {
                if (honeycombView.tag == Metrics.steps.rawValue) {
                    totalEffort = honeycombView
                }
                for value in values {
                    if honeycombView.tag == value {
                        if (value == Metrics.steps.rawValue) {
                            // restore steps for old challenge
                            honeycombView.title.text = Metrics.steps.title
                            honeycombView.valueLabel.text = Metrics.steps.measuringText
                            totalEffort = nil
                        }
                        honeycombView.setMetricsViewFor(state: true)
                        
                        if let metric = Metrics(rawValue: value) {
                            self.updateHoneyCombValue(forMetric: metric, scoreboard: scoreboard, honeycombView: honeycombView)
                        }
                    }
                }
            }
        }
        if (totalEffort != nil && values.count == Metrics.selectableMetricsCount) {
            totalEffort?.setMetricsViewFor(state: true)
        }
    }
    
    func setDefaultViewForMetrics() {
        guard self.contentView != nil else {
            return
        }
        for subview in self.contentView.subviews {
            if let honeycombView = subview as? HoneyComb {
                honeycombView.setMetricsViewFor(state: false)
            }
        }
    }
    
    private func updateHoneyCombValue(forMetric metric: Metrics, scoreboard: Leaderboard, honeycombView: HoneyComb) {
        switch metric {
        case .steps:
            honeycombView.setData(value: "\(scoreboard.steps?.toInt() ?? 0)")
        case .calories:
            honeycombView.setData(value: "\(scoreboard.calories?.rounded(toPlaces: 2) ?? 0)")
        case .distance:
            honeycombView.setData(value: "\(scoreboard.distance?.rounded(toPlaces: 2) ?? 0) Miles")
        case .totalActivites:
            honeycombView.setData(value: "\(scoreboard.totalActivities?.toInt() ?? 0)")
        case .totalActivityTime:
            if let totalTimeInSeconds = scoreboard.totalTime?.toInt() {
                let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTimeInSeconds)
                
                let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                honeycombView.setData(value: displayTime)
            }
        default:
            break
        }
    }
}
