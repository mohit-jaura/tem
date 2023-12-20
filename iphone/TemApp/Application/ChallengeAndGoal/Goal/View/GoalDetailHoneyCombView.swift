//
//  GoalDetailHoneyCombView.swift
//  TemApp
//
//  Created by shilpa on 18/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

protocol GoalDetailHoneyComb {
    func getGoalHoneyComb(honeyComb:HoneyComb)
}

enum HoneyCombType:Int {
   case goal = 100
   case start = 101
   case duration = 102
}

class GoalDetailHoneyCombView: UIView, HoneyCombViewable {
    
    // MARK: Properties
    var minNumberOfItemsInRow: Int = 3
    var numberOfRows: Int = 5
    var dividerForHeight: Double = 6.2
    var goal = ""
    var start = ""
    var duration = ""
    var scrollView:UIScrollView!
    var contentView: UIView!
    var safeAreaHeight:CGFloat = 0.0
    var topSafeArea:CGFloat = 0.0
    var y_Cordinate:CGFloat = 0.0
    var userActivitySummary:UserActivity = UserActivity()
    
    var widthOfItem: CGFloat = 0.0
    var heightOfItem: CGFloat = 0.0
    var heightOfFullView: CGFloat?
    
    // MARK: App life Cycle.....
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
    
    func createLayout() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.backgroundColor = .clear
        self.contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height ))
        self.scrollView.addSubview(self.contentView)
        self.addSubview(self.scrollView)
        drawHoneyCombView()
    }
    
    private func drawHoneyCombView() {
        widthOfItem = ((UIScreen.main.bounds.width - 10))/CGFloat(minNumberOfItemsInRow)
        heightOfItem = (widthOfItem / 1.13)
        if let fullViewHeight = self.heightOfFullView {
            self.numberOfRows = Int(fullViewHeight/heightOfItem) + 1
        }
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
                
                if (!isEven(outerIndex)) {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2 + (self.padding/2))
                    
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1))
                }
                centerX -= self.padding
                centerY = (CGFloat(outerIndex) * heightOfItem) + heightOfItem/2 + (CGFloat(outerIndex) * self.padding/2)
                centerY -= heightOfItem
                centerY += (21)
                if outerIndex == 0 {
                    honeyCombView.backGroundImage.image = UIImage(named: "white-honey")
                }
                if outerIndex == 1 || outerIndex == 2 {
                    self.setViewForDifferentMetrics(outerIndex: outerIndex, innerIndex: innerIndex, honeyCombView: honeyCombView)
                }
                honeyCombView.center = CGPoint(x: centerX, y: centerY)
                self.contentView.addSubview(honeyCombView)
            }
        }
        let height = (heightOfItem * CGFloat(numberOfRows)) + (CGFloat(safeAreaHeight+topSafeArea + 100))
        self.contentView.frame = CGRect(x: 0, y: y_Cordinate , width: self.bounds.width, height: height)
    }
    
    private func setViewForDifferentMetrics(outerIndex:Int, innerIndex:Int,honeyCombView:HoneyComb) {
        honeyCombView.valueLabel.isHidden = false
        honeyCombView.title.isHidden = false
        if outerIndex == 1 {
            if innerIndex == 1 {
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                honeyCombView.valueLabel.text = self.goal
                honeyCombView.title.text = "GOAL"
                honeyCombView.tag = HoneyCombType.goal.rawValue
            }
            if innerIndex == 2 {
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                honeyCombView.valueLabel.text = self.start
                honeyCombView.title.text = "START"
                honeyCombView.tag = HoneyCombType.start.rawValue
            }
        } else {
            if innerIndex == 1 {
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                honeyCombView.valueLabel.text = self.duration
                honeyCombView.title.text = "DURATION"
                honeyCombView.tag =  HoneyCombType.duration.rawValue
            }
        }
    }
    
    func setGoalHoneyCombData(data: GroupActivity, fundraising: Bool = false) {
        guard self.contentView != nil else {
            return
        }
        for honeyCombView in self.contentView.subviews {
            if let honeyView = honeyCombView as? HoneyComb {
                if honeyView.tag == HoneyCombType.goal.rawValue {
                    if !fundraising {
                        if let matrictype = data.target?.first?.matric,
                           let unit = Metrics(rawValue: matrictype),
                           var value = data.target?.first?.value {
                            if data.isPerPersonGoal == true {
                                value = value * Double((data.membersCount ?? 0))
                            }
                            let text = unit.formatValue(value)
                            honeyView.valueLabel.text = text
                            self.goal = text
                        }
                    }
                    else {
                        let amount = Double(truncating: (data.fundraising?.goalAmount ?? 0) as NSNumber)
                        let text = Metrics.fundraising.formatValue(amount)
                        honeyView.valueLabel.text = text
                        self.goal = text
                    }
                }
                else if honeyView.tag == HoneyCombType.start.rawValue {
                    if let startDate = data.startDate {
                        let dateObj = startDate.timestampInMillisecondsToDate
                        honeyView.valueLabel.text = dateObj.toString(inFormat: .dateNumberFormat)
                        self.start = honeyView.valueLabel.text ?? ""
                    }
                }
                else if honeyView.tag == HoneyCombType.duration.rawValue {
                    if let duration = data.duration {
                        honeyView.valueLabel.text = duration
                        self.duration = honeyView.valueLabel.text ?? ""
                    }
                }
            }
        }
    }
}
