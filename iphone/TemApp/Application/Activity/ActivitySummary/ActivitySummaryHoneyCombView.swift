//
//  ActivitySummaryHoneyCombView.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Saurav. All rights reserved.
//

import Foundation
import UIKit

class ActivitySummaryHoneyCombView: UIView, HoneyCombViewable {
    
    fileprivate enum SummaryMetric {
        case distance, duration, calories
        
        var title: String {
            switch self {
            case .calories:
                return "CALORIES"
            case .distance:
                return "DISTANCE"
            case .duration:
                return "DURATION"
            }
        }
    }
    
    //MARK:- Properties
    var minNumberOfItemsInRow: Int = 3
    var numberOfRows: Int = 8
    var dividerForHeight: Double = 6.2
    
    var scrollView:UIScrollView!
    var contentView: UIView!
    var safeAreaHeight:CGFloat = 0.0
    var topSafeArea:CGFloat = 0.0
    var y_Cordinate:CGFloat = 0.0
    var activityData: [UserActivity] = [UserActivity]()
    
    //MARK:- App life Cycle.....
    override func layoutSubviews() {
        self.reloadData()
    }
    
    //MARK:- Private Methods.....
    
    private func reloadData() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        createLayout()
    }
    
    private func createLayout() {
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first {
                let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                safeAreaHeight = window.frame.maxY - safeFrame.maxY
                if (safeAreaHeight > 0) {
                    topSafeArea = safeFrame.minY
                    dividerForHeight = 7.5
                }
            }
        }
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.backgroundColor = .clear
        self.contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height ))
        self.scrollView.addSubview(self.contentView)
        self.addSubview(self.scrollView)
        drawHoneyCombView()
    }
    
    private func drawHoneyCombView() {
        
        let widthOfItem = (self.bounds.width - (4 * self.padding))/CGFloat(minNumberOfItemsInRow)
        let heightOfItem = (UIScreen.main.bounds.height)/CGFloat(dividerForHeight)
        y_Cordinate = -safeAreaHeight
        var itemsInRow:Int = 0
        
        //        for outerIndex in 0..<7 {
        for outerIndex in 0..<numberOfRows {
            if (isEven(outerIndex)) {
                itemsInRow = minNumberOfItemsInRow + 1
            } else {
                itemsInRow = minNumberOfItemsInRow
            }
            
            for innerIndex in 0..<itemsInRow {
                
                let honeyCombView = HoneyComb()
                honeyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                honeyCombView.shadowView.backgroundColor = .clear
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "gray-honey")
                honeyCombView.backGroundImage.contentMode = .scaleAspectFill
                honeyCombView.iconImage.isHidden = true
                honeyCombView.valueLabel.isHighlighted = true
                honeyCombView.logoImageView.isHidden = true
                honeyCombView.title.isHidden = true
                var centerX:CGFloat!
                var centerY:CGFloat!
                
                if (isEven(outerIndex)) {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2 + (self.padding/2))
                    
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1))
                }
                
                centerY = ((2 * (CGFloat(outerIndex)) + 1) * ((heightOfItem / 2)) - (heightOfItem / 2) + (2 * safeAreaHeight)) + 10//heightOfItem/4
                
                if(outerIndex == 2 || outerIndex == 3) {
                    
                    self.setTitleFor(outerIndex: outerIndex, innerIndex: innerIndex, honeycombView: honeyCombView)
                    
                    if outerIndex == 2 {
                        if (innerIndex == 1 || innerIndex == 2) {
                            honeyCombView.valueLabel.isHidden = false
                            honeyCombView.title.isHidden = false
                            honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                            
                            if self.totalDistanceActivities() <= 0 {
                                if (innerIndex == 2) {
                                    honeyCombView.valueLabel.isHidden = true
                                    honeyCombView.title.isHidden = true
                                    honeyCombView.logoImageView.isHidden = false
                                }
                            }
                        }
                    } else {
                        if innerIndex == 1 {
                            honeyCombView.valueLabel.isHidden = false
                            honeyCombView.title.isHidden = false
                            honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                        }
                    }
                }
                honeyCombView.center = CGPoint(x: centerX, y: centerY)
                self.contentView.addSubview(honeyCombView)
            }
            
        }
        let height = (heightOfItem * CGFloat(numberOfRows)) + (CGFloat(safeAreaHeight+topSafeArea + 100))
        self.contentView.frame = CGRect(x: 0, y: y_Cordinate , width: self.bounds.width, height: height)
    }
    
    func setTitleFor(outerIndex: Int, innerIndex: Int, honeycombView: HoneyComb) {
        if outerIndex == 2 {
            if innerIndex == 1 {
                honeycombView.title.text = "DURATION".localized
                let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: self.totalTime())
                
                let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                honeycombView.valueLabel.text = "\(displayTime)"
            }
            if innerIndex == 2 {
                if self.totalDistanceActivities() > 0 {
                    honeycombView.valueLabel.text = "\(self.totalDistance().rounded(toPlaces: 2)) Miles"
                    honeycombView.title.text = "DISTANCE".localized
                }
            }
        } else if outerIndex == 3 {
            if innerIndex == 1 {
                honeycombView.valueLabel.text = "\(self.totalCalories().rounded(toPlaces: 2))"
                honeycombView.title.text = "CALORIES".localized
            }
        }
        
    }
    
    /// return the total number of distance type activities
    private func totalDistanceActivities() -> Int {
        let distanceActivities = self.activityData.filter { (activity) -> Bool in
            //parent distance
            //goal: either distance or open
            let selectedActivityType = activity.selectedActivityType ?? 1
            if let type = activity.type {
                if selectedActivityType == ActivityType.distance.rawValue {
                    if type == ActivityType.distance.rawValue || type == ActivityType.none.rawValue {
                        return true
                    }
                }
            }
            return false
        }
        return distanceActivities.count
    }
    
    /// returns the total distance by adding distance in each UserActivity object
    ///
    /// - Returns: total distance
    private func totalDistance() -> Double {
        let distanceActivities = self.activityData.filter { (activity) -> Bool in
            //parent: distance
            //goal: either distance or open
            let selectedActivityType = activity.selectedActivityType ?? 1
            if let type = activity.type {
                if selectedActivityType == ActivityType.distance.rawValue {
                    if type == ActivityType.distance.rawValue || type == ActivityType.none.rawValue {
                        return true
                    }
                }
            }
            return false
        }
        let distance = distanceActivities.compactMap({$0.distance}).reduce(0, {$0 + $1})
        return distance
    }
    
    /// returns the total time by adding time in each UserActivity object
    ///
    /// - Returns: total time
    private func totalTime() -> Int {
        let time = self.activityData.compactMap({$0.timeSpent?.toInt()}).reduce(0, {$0 + $1})
        return time
    }
    
    /// returns the total calories by adding calories in each UserActivity object
    ///
    /// - Returns: total calories
    private func totalCalories() -> Double {
        let total = self.activityData.compactMap({$0.calories}).reduce(0, {$0 + $1})
        return total
    }
}
