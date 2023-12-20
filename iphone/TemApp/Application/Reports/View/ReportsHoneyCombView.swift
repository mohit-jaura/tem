//
//  ReportsHoneyCombView.swift
//  TemApp
//
//  Created by shilpa on 22/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

protocol ReportsHoneyCombDelegate: AnyObject {
    func didClickOnActivityLogHoneyComb()
    func didClickOnTotalActivitiesHoneyComb()
    func contentViewDidSetToFullHeight(value: CGFloat)
}

enum ReportMetrics: Int {
    
    case averageCalories, averageDuration, typesOfActivities, totalActivities, activityLog
    
    var title: String {
        switch self {
        case .averageCalories:
            return "Average Calories"
        case .averageDuration:
            return "Average Duration"
        case .typesOfActivities:
            return "Type Of Activities"
        case .totalActivities:
            return "Total Activities"
        case .activityLog:
            return "Activity Log"
        }
    }
}

class ReportsHoneyCombView: UIView, HoneyCombViewable {

    // MARK: Properties
    var delegate: ReportsHoneyCombDelegate?
    
    var minNumberOfItemsInRow: Int = 3
    var numberOfRows: Int = 5//7
    var dividerForHeight: Double = 6.2
    
    var scrollView:UIScrollView!
    var contentView: UIView!
    var safeAreaHeight:CGFloat = 0.0
    var topSafeArea:CGFloat = 0.0
    var y_Cordinate:CGFloat = 0.0
    
    //storing the references of the values honey combs
    var averageCalories: HoneyComb?
    var averageDurationHoneyComb: HoneyComb?
    var activityTypesHoneyComb: HoneyComb?
    var totalActivitiesHoneyComb: HoneyComb?
    
    var showReport: Bool = false
    
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
        
        if !showReport {
            numberOfRows = 5
        }
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
                honeyCombView.initializeDefaultViewLayout()
                var centerX:CGFloat!
                var centerY:CGFloat!
                
                if (isEven(outerIndex)) {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2 + (self.padding/2))
                    
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1))
                }
                
                centerY = (2 * (CGFloat(outerIndex)) + 1) * ((heightOfItem / 2)) - (heightOfItem / 2) + (2 * safeAreaHeight)
                
                if showReport {
                    if(outerIndex == 1 || outerIndex == 2) {
                        self.setTitlesFor(outerIndex: outerIndex, innerIndex: innerIndex, honeyComb: honeyCombView)
                        
                        if outerIndex == 1 {
                            if (innerIndex == 0 || innerIndex == 1 || innerIndex == 2) {
                                honeyCombView.valueLabel.isHidden = false
                                honeyCombView.title.isHidden = false
                                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                            }
                        } else if outerIndex == 2 {
                            if innerIndex == 1 || innerIndex == 2 {
                                honeyCombView.valueLabel.isHidden = false
                                honeyCombView.title.isHidden = false
                                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                            }
                        }
                    }
                }
                
                honeyCombView.center = CGPoint(x: centerX, y: centerY)
                self.contentView.addSubview(honeyCombView)
            }
            
        }
        let height = (heightOfItem * CGFloat(numberOfRows)) + (CGFloat(safeAreaHeight+topSafeArea + 100))
        self.contentView.frame = CGRect(x: 0, y: y_Cordinate , width: self.bounds.width, height: height)
//        print("content view height ===========> \(height)")
        self.delegate?.contentViewDidSetToFullHeight(value: (heightOfItem * CGFloat(4)) - heightOfItem/2)
    }
    
    func setTitlesFor(outerIndex: Int, innerIndex: Int, honeyComb: HoneyComb) {
        if outerIndex == 1 {
            honeyComb.changeTitleViewConstraint()
            honeyComb.valueLabel.text = "0"
            switch innerIndex {
            case 0:
                self.averageCalories = honeyComb
                honeyComb.tag = ReportMetrics.averageCalories.rawValue
                honeyComb.title.text = ReportMetrics.averageCalories.title.uppercased()
            case 1:
                self.averageDurationHoneyComb = honeyComb
                honeyComb.tag = ReportMetrics.averageDuration.rawValue
                honeyComb.title.text = ReportMetrics.averageDuration.title.uppercased()
            case 2:
                self.activityTypesHoneyComb = honeyComb
                honeyComb.tag = ReportMetrics.typesOfActivities.rawValue
                honeyComb.title.text = ReportMetrics.typesOfActivities.title.uppercased()
            default:
                break
            }
        }
        if outerIndex == 2 {
            switch innerIndex {
            case 1:
                honeyComb.changeTitleViewConstraint()
                self.totalActivitiesHoneyComb = honeyComb
                honeyComb.valueLabel.text = "0"
                honeyComb.tag = ReportMetrics.totalActivities.rawValue
                honeyComb.title.text = ReportMetrics.totalActivities.title.uppercased()
                honeyComb.honeyCombButton.addTarget(self, action: #selector(totalActivitiesViewTapped), for: .touchUpInside)
            case 2:
                honeyComb.tag = ReportMetrics.activityLog.rawValue
                honeyComb.title.text = ReportMetrics.activityLog.title.uppercased()
                honeyComb.honeyCombButton.addTarget(self, action: #selector(activityLogViewTapped), for: .touchUpInside)
                honeyComb.alignTitleAtCenter()
            default:
                break
            }
        }
    }
    
    @objc func totalActivitiesViewTapped() {
        self.delegate?.didClickOnTotalActivitiesHoneyComb()
    }
    
    @objc func activityLogViewTapped() {
        self.delegate?.didClickOnActivityLogHoneyComb()
    }
    
    func setValuesInViews(reportInfo: UserActivityReport) {
        self.averageCalories?.valueLabel.text = (reportInfo.averageCalories?.value?.rounded(toPlaces: 2).formatted ?? "0")
//        self.averageDurationHoneyComb?.valueLabel.text =
//            (reportInfo.averageDuration?.value?.rounded(toPlaces: 2).formatted ?? "0") + " mins"
        self.averageDurationHoneyComb?.valueLabel.text =
            "\(reportInfo.averageDuration?.value?.rounded().toInt() ?? 0)" + " mins"
        self.activityTypesHoneyComb?.valueLabel.text = "\(reportInfo.typesOfActivities?.count ?? 0)"
        self.totalActivitiesHoneyComb?.valueLabel.text = "\(reportInfo.totalActivities?.value?.toInt() ?? 0)"
    }
}
