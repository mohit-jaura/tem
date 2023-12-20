//
//  ActivityLogHoneyCombView.swift
//  TemApp
//
//  Created by shilpa on 24/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

class ActivityLogHoneyCombView: UIView, HoneyCombViewable {
    
    var minNumberOfItemsInRow: Int = 3
    var numberOfRows: Int = 7
    var dividerForHeight: Double = 6.2
    
    var scrollView:UIScrollView!
    var contentView: UIView!
    
    //storing the references of the value honey comb to update it later with the new data
    var valueDisplayHoneyComb: HoneyComb?
    var valueDisplayHoneyCombCenterY: CGFloat?
    var infoHoneyCombView: HoneyComb?
    
    var value: Any?
    var reportFlag: ReportFlag?
    var screenType: Constant.ScreenFrom = Constant.ScreenFrom.totalActivities
    
    var widthOfItem: CGFloat { get { (self.bounds.width - (4 * self.padding))/CGFloat(minNumberOfItemsInRow) } }
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
    }
    
    private func drawHoneyCombView() {
        var itemsInRow:Int = 0
        
        self.numberOfRows = Int(self.bounds.height/heightOfItem) + 2
        
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
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2 + (self.padding/2))
                    
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1))
                }
                
                centerY = (2 * (CGFloat(outerIndex)) + 1) * ((heightOfItem / 2)) - (heightOfItem / 2)
                if outerIndex == 2 && innerIndex == 2 {
                    self.infoHoneyCombView = honeyCombView
                }
                if outerIndex == 1 && innerIndex == 1 {
                    self.valueDisplayHoneyComb = honeyCombView
                    self.valueDisplayHoneyCombCenterY = centerY
                    
                    if self.value != nil {
                        switch self.screenType {
                        case .totalActivities:
                            self.setTotalActivitiesCount()
                        case .activityLog:
                            self.setViewForActivityLog()
                        default:
                            break
                        }
                    }
                }
                honeyCombView.center = CGPoint(x: centerX, y: centerY)
                self.contentView.addSubview(honeyCombView)
            }
            
        }
        let height = (heightOfItem * CGFloat(numberOfRows))
        self.contentView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: height)
        print("height of honeycombView ========= \(self.contentView.frame.size.height)")
    }
    
    private func setViewForReportDisplay() {
        if let flag = self.reportFlag {
            self.valueDisplayHoneyComb?.arrowImageView.image = flag.icon
            //self.valueDisplayHoneyComb?.backGroundImage.setImageColor(color: flag.color)
            self.valueDisplayHoneyComb?.backGroundImage.image = flag.honeyCombIcon ?? #imageLiteral(resourceName: "gray-honey")
            self.valueDisplayHoneyComb?.backGroundImage.shadowRadius = 10.0
        }
        self.valueDisplayHoneyComb?.upDownArrowView.isHidden = false
    }
    
    func setTotalActivitiesCount() {
        if let value = self.value as? Int {
            self.setViewForReportDisplay()
            self.valueDisplayHoneyComb?.activityScoreLabel.text = "TOTAL ACTIVITIES"
            self.valueDisplayHoneyComb?.countLabel.text = "\(value)"
        }
    }
    
    func setViewForActivityLog() {
        if let value = self.value as? Double {
            self.setViewForReportDisplay()
            self.valueDisplayHoneyComb?.countLabel.text = "\(value.rounded(toPlaces: 2).formatted ?? "0")"
            if self.screenType == .activityLog {
                self.infoHoneyCombView?.delegate = self
                self.infoHoneyCombView?.setInfoView(hide: false)
            }
        }
    }
}

// MARK: HoneyCombDelegate
extension ActivityLogHoneyCombView: HoneyCombDelegate {
    func didSelectInfoView() {
        let topController = UIApplication.shared.keyWindow?.rootViewController
        let popOverController: ActivityScoreInfoViewController = UIStoryboard(storyboard: .reports).initVC()
        topController?.present(popOverController, animated: true, completion: nil)
    }
}
