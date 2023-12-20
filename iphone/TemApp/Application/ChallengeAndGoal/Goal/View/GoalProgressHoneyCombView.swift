//
//  GoalProgressHoneyCombView.swift
//  TemApp
//
//  Created by shilpa on 12/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class GoalProgressHoneyCombView: UIView, HoneyCombViewable {
    var minNumberOfItemsInRow: Int = 2
    var numberOfRows: Int = 10// 4
    var dividerForHeight: Double = 3.0
    var scrollView: UIScrollView!
    var contentView: UIView!
    private var percent: Double?
    private var score: Double?
    private var metric: Metrics?
    var widthOfItem: CGFloat { get { (self.bounds.width + self.padding)/CGFloat(minNumberOfItemsInRow) } }
    var heightOfItem: CGFloat { get { widthOfItem / 1.13 } }
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
    private func createLayout() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.backgroundColor = .clear
        self.contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height ))
        self.scrollView.addSubview(self.contentView)
        self.addSubview(self.scrollView)
        drawHoneyCombView()
        redrawContent()
    }
    private func drawHoneyCombView() {
        var itemsInRow: Int = 0
        for outerIndex in 0..<numberOfRows {
            if (!isEven(outerIndex)) {
                itemsInRow = minNumberOfItemsInRow + 1
            } else {
                itemsInRow = minNumberOfItemsInRow
            }
            for innerIndex in 0..<itemsInRow {
                var centerX: CGFloat!
                var centerY: CGFloat!
                
                if (!isEven(outerIndex)) {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2 + (self.padding/2))
                    
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1))
                }
                centerX -= self.padding
                centerY = (2 * (CGFloat(outerIndex)) + 1) * ((heightOfItem / 2)) - (heightOfItem / 2)
                
                if outerIndex == 1 && innerIndex == 1 {
                    let honeyCombView = GoalProgressDisplayView()
                    honeyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                    honeyCombView.center = CGPoint(x: centerX, y: centerY)
                    let backHoneyComb = HoneyComb()
                    backHoneyComb.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                    backHoneyComb.initializeDefaultViewLayout()
                    backHoneyComb.backGroundImage.image = UIImage(named: "white-honey")
                    backHoneyComb.center = CGPoint(x: centerX, y: centerY)
                    self.contentView.addSubview(backHoneyComb)
                    self.contentView.addSubview(honeyCombView)
                } else {                    
                    let honeyCombView = HoneyComb()
                    honeyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                    honeyCombView.initializeDefaultViewLayout()
                    honeyCombView.center = CGPoint(x: centerX, y: centerY)
                    self.contentView.addSubview(honeyCombView)
                }
            }
            
        }
        let height = (heightOfItem * CGFloat(numberOfRows))
        self.contentView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: height)
    }
    
    func use(percent: Double, achievedScore: Double, metric: Metrics) {
        self.percent = percent
        self.score = achievedScore
        self.metric = metric
        self.redrawContent()
    }
    
    private func redrawContent() {
        guard self.contentView != nil else {
            return
        }
        let filteredViews = self.contentView.subviews.filter { (view) -> Bool in
            if view as? GoalProgressDisplayView != nil {
                return true
            }
            return false
        }
        if let progressDisplayView = filteredViews.first as? GoalProgressDisplayView {
            progressDisplayView.completionPercentage = percent
            progressDisplayView.achievedValue = score
            progressDisplayView.metric = metric
            progressDisplayView.updateCompletionPercentage()
            progressDisplayView.updateProgressAfterDelay()
        }
    }
    
    func screenshotOfProgressView() -> UIImage? {
        guard self.contentView != nil else {
            return nil
        }
        let filteredViews = self.contentView.subviews.filter { (view) -> Bool in
            if view as? GoalProgressDisplayView != nil {
                return true
            }
            return false
        }
        if let progressDisplayView = filteredViews.first as? GoalProgressDisplayView {
            if let image = progressDisplayView.screenshot() {
                return image
            }
        }
        return nil
    }
}
