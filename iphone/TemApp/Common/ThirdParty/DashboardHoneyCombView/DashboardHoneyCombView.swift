//
//  DashboardHoneyCombView.swift
//  TemApp
//
//  Created by Sourav on 4/20/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

enum DashboardRedirection:Int {
    case leaderboard = 1
    case calendar = 2
    case activity = 3
    case challenge = 4
    case tems = 5
    case goals_challenge = 6
    case myProfile = 7
    case post = 8
    case activityLog = 9
    case shortcut
}


protocol DashboardRedirectionDelegate {
    func didClickOnHoneyCombView(sender:UIButton)
}

class DashboardHoneyCombView:UIView, HoneyCombViewable {
    
    // MARK: Variables.....
    struct ShortcutView {
        var honeyCombView: HoneyComb?
        var progressView: GoalProgressDisplayView?
    }
    var scrollView:UIScrollView!
    var contentView: UIView!
    var minNumberOfItemsInRow: Int = 3
    var numberOfRows: Int = 7
    var dividerForHeight:Double = 6.2
    var safeAreaHeight:CGFloat = 0.0
    var topSafeArea:CGFloat = 0.0
    var y_Cordinate:CGFloat = 0.0
    var delegate:DashboardRedirectionDelegate?
    
    //storing the references of the value honey comb to update it later with the new data
    var valueDisplayHoneyComb: HoneyComb?
    var haisView = HAISRotatingView()
    var haisScore: Double = 0
    var displayProfilePic : HoneyComb?
    var leaderboard : HoneyComb?
    
    var value: Any?
    var reportFlag: ReportFlag?
    
    //storing the reference of shortcut views to update later
    private var shortcutViewFirst: ShortcutView?
    private var shortcutViewSecond: ShortcutView?
    private var shortcutViewThird: ShortcutView?
    private var shortcutViewFourth: ShortcutView?
    private var shortcutViewFifth: ShortcutView?
    private var shortcutViewSixth: ShortcutView?
    
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
        
        haisView = HAISRotatingView()
        haisView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
        
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
                honeyCombView.title.isHidden = true
                
                //progress diplay view
                let progressView = GoalProgressDisplayView()
                progressView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                progressView.setViewsLayoutForGoalShortcut(widthOfFullTile: widthOfItem, heightOfFullTile: heightOfItem)
                let progressBackHoneyComb = HoneyComb()
                progressBackHoneyComb.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                progressBackHoneyComb.initializeDefaultViewLayout()
                progressBackHoneyComb.backGroundImage.image = #imageLiteral(resourceName: "gray-honey")
                progressView.isHidden = true
                
                var centerX:CGFloat!
                var centerY:CGFloat!
                
                if (isEven(outerIndex)) {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2 + (self.padding/2))
                    
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1))
                }
                
                centerY = (2 * (CGFloat(outerIndex)) + 1) * ((heightOfItem / 2)) - (heightOfItem / 2) + (2 * safeAreaHeight)
                
                if (outerIndex == 1 || outerIndex == 2 || outerIndex == 3 || outerIndex == 4 || outerIndex == 5) {
                    self.configureActiveElement(outerIndex: outerIndex, innerIndex: innerIndex, honeyCombView: honeyCombView, progressView: progressView)
                }
                
                honeyCombView.center = CGPoint(x: centerX, y: centerY)
                progressView.center = CGPoint(x: centerX, y: centerY)
                progressBackHoneyComb.center = CGPoint(x: centerX, y: centerY)
                
                if (outerIndex == 3 && innerIndex == 1) { // HAIS section
                    haisView.frame.size.height = haisView.backgroundImage.frameForPhoto().size.height
                    haisView.center = CGPoint(x: centerX, y: centerY)
                    self.contentView.addSubview(haisView)
                }
                else if (outerIndex == 1) {
                    if (innerIndex == 0 || innerIndex == 1 || innerIndex == 2) {
                        progressView.isHidden = true
                        self.contentView.addSubview(progressBackHoneyComb)
                        self.contentView.addSubview(progressView)
                        self.contentView.addSubview(honeyCombView)
                    }
                }
                else if (outerIndex == 5) {
                    if (innerIndex == 0 || innerIndex == 1 || innerIndex == 2) {
                        progressView.isHidden = true
                        self.contentView.addSubview(progressBackHoneyComb)
                        self.contentView.addSubview(progressView)
                        self.contentView.addSubview(honeyCombView)
                    }
                }
                else {
                    self.contentView.addSubview(honeyCombView)
                }
            }
        }
        haisView.layer.zPosition = 1
        let height = (heightOfItem * CGFloat(numberOfRows)) + (CGFloat(safeAreaHeight+topSafeArea + 100))
        self.contentView.frame = CGRect(x: 0, y: y_Cordinate , width: self.bounds.width, height: height)
    }
    
    private func configureActiveElement(outerIndex:Int, innerIndex:Int,honeyCombView:HoneyComb, progressView: GoalProgressDisplayView?) {
        honeyCombView.iconImageCenterX.constant = 0
        if (outerIndex == 1) { // top shortcuts row
            if (innerIndex == 0) {
                self.shortcutViewFirst = ShortcutView(honeyCombView: honeyCombView, progressView: progressView)//honeyCombView
            }
            else if (innerIndex == 1) {
                self.shortcutViewSecond = ShortcutView(honeyCombView: honeyCombView, progressView: progressView)
            }
            else if (innerIndex == 2) {
                self.shortcutViewThird = ShortcutView(honeyCombView: honeyCombView, progressView: progressView)
            }
        }
        else if (outerIndex == 2) {
            if (innerIndex == 1) {
                honeyCombView.honeyCombButton.tag = DashboardRedirection.leaderboard.rawValue
                honeyCombView.title.text = AppMessages.DashboardActions.leaderboard
                honeyCombView.title.isHidden = false
                honeyCombView.iconImage.image = #imageLiteral(resourceName: "leaderboard")
                honeyCombView.iconImage.isHidden = false
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
            }
            else if (innerIndex == 2) {
                honeyCombView.honeyCombButton.tag = DashboardRedirection.tems.rawValue
                honeyCombView.title.text = AppMessages.DashboardActions.tems
                honeyCombView.title.isHidden = false
                honeyCombView.iconImage.image = #imageLiteral(resourceName: "temsWhite")
                honeyCombView.iconImage.isHidden = false
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
            }
        }
        else if (outerIndex == 3) {
            if(innerIndex == 0) {
                honeyCombView.honeyCombButton.tag = DashboardRedirection.calendar.rawValue
                honeyCombView.title.text = AppMessages.DashboardActions.calendar
                honeyCombView.title.isHidden = false
                honeyCombView.iconImage.image = #imageLiteral(resourceName: "small-calendar-lWhite")
                honeyCombView.iconImage.isHidden = false
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
            }
            else if (innerIndex == 1) { // HAIS section
                honeyCombView.honeyCombButton.tag = DashboardRedirection.tems.rawValue
                honeyCombView.title.text = AppMessages.DashboardActions.hais
                haisView.initializeDefaultViewLayout()
                self.setHaisSvore()
            }
            else if(innerIndex == 2) {
                honeyCombView.honeyCombButton.tag = DashboardRedirection.goals_challenge.rawValue
                honeyCombView.title.text = AppMessages.DashboardActions.goals_challenge
                honeyCombView.title.isHidden = false
                honeyCombView.iconImageCenterX.constant = 3
                honeyCombView.iconImage.image = #imageLiteral(resourceName: "targetNew")
                honeyCombView.iconImage.isHidden = false
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
            }
        }
        else if (outerIndex == 4) {
            if (innerIndex == 1) { // Profile section
                honeyCombView.honeyCombButton.tag = DashboardRedirection.myProfile.rawValue
                honeyCombView.title.text = AppMessages.DashboardActions.profile
                honeyCombView.title.isHidden = false
                if let imageUrl = URL(string: UserManager.getCurrentUser()?.profilePicUrl ?? "" ) {
                    honeyCombView.setIconSize(imageUrl: imageUrl)
                }
                else{
                    honeyCombView.iconImage.image = #imageLiteral(resourceName: "userWhite")
                }
                honeyCombView.iconImage.isHidden = false
                honeyCombView.backGroundImage.image = #imageLiteral(resourceName: "blue")
                displayProfilePic = honeyCombView
            }
            else if (innerIndex == 2) {
                honeyCombView.honeyCombButton.tag = DashboardRedirection.activityLog.rawValue
                self.valueDisplayHoneyComb = honeyCombView
                if value != nil {
                    self.setViewForActivityLog()
                }
            }
        }
        else if (outerIndex == 5) { // bottom shortcuts row
            if (innerIndex == 0) {
                shortcutViewFourth = ShortcutView(honeyCombView: honeyCombView, progressView: progressView)
            }
            else if (innerIndex == 1) {
                shortcutViewFifth = ShortcutView(honeyCombView: honeyCombView, progressView: progressView)
            }
            else if (innerIndex == 2) {
                shortcutViewSixth = ShortcutView(honeyCombView: honeyCombView, progressView: progressView)
            }
        }
        
        honeyCombView.honeyCombButton.addTarget(self, action: #selector(clickedOnHoneyCombView(sender:)), for: .touchUpInside)
    }
    
    @objc func clickedOnHoneyCombView(sender:UIButton) {
        if let tag = DashboardRedirection(rawValue: sender.tag) {
            switch tag {
            case .activityLog:
                if value != nil {
                    delegate?.didClickOnHoneyCombView(sender: sender)
                }
            default:
                delegate?.didClickOnHoneyCombView(sender: sender)
            }
        }
        // delegate?.didClickOnHoneyCombView(sender: sender)
    }
    
    private func applyHexagonMaskOnUIView(view:UIView) {
        let maskPath = UIBezierPath(frame: view.bounds, numberOfSides: 6, cornerRadius: 0.0)
        let maskingLayer = CAShapeLayer()
        maskingLayer.path = maskPath?.cgPath
        view.transform = view.transform.rotated(by: CGFloat(Double.pi / 2))
        view.layer.mask = maskingLayer
    }
    
    ///set data for activity log of user
    func setViewForActivityLog() {
        if let value = self.value as? Double {
            self.valueDisplayHoneyComb?.honeyCombButton.tag = DashboardRedirection.activityLog.rawValue
            self.setViewForReportDisplay()
            self.valueDisplayHoneyComb?.countLabel.text = "\(value.rounded(toPlaces: 2).formatted ?? "0")"
            //self.valueDisplayHoneyComb?.honeyCombButton.addTarget(self, action: #selector(clickedOnHoneyCombView(sender:)), for: .touchUpInside)
        }
    }
    
    private func setViewForReportDisplay() {
        if let flag = self.reportFlag {
            self.valueDisplayHoneyComb?.arrowImageView.image = flag.icon
            //            self.valueDisplayHoneyComb?.backGroundImage.setImageColor(color: flag.color)
            self.valueDisplayHoneyComb?.backGroundImage.image = flag.honeyCombIcon ?? #imageLiteral(resourceName: "gray-honey")
            self.valueDisplayHoneyComb?.backGroundImage.shadowRadius = 10.0
        }
        self.valueDisplayHoneyComb?.upDownArrowView.isHidden = false
    }
    
    func setHaisSvore() {
        self.haisView.setScore(value: haisScore)
    }
    
}//Class.....

extension DashboardHoneyCombView {
    
    func setShortcuts(list: [HomeScreenShortcut]) {
        switch list.count {
        case 0:
            self.resetShortcutActions(views: [shortcutViewFirst, shortcutViewSecond, shortcutViewThird, shortcutViewFourth, shortcutViewFifth, shortcutViewSixth])
            shortcutViewFirst?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewSecond?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewThird?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewFourth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewFifth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewSixth?.honeyCombView?.honeyCombButton.elements = nil
            
        case 1:
            setViewForSelection(honeyCombView: shortcutViewFirst, dataInfo: list.first)
            self.resetShortcutActions(views: [shortcutViewSecond, shortcutViewThird, shortcutViewFourth, shortcutViewFifth, shortcutViewSixth])
            //set all other values nil
            shortcutViewSecond?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewThird?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewFourth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewFifth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewSixth?.honeyCombView?.honeyCombButton.elements = nil
        case 2:
            setViewForSelection(honeyCombView: shortcutViewSecond, dataInfo: list.last)
            setViewForSelection(honeyCombView: shortcutViewFirst, dataInfo: list.first)
            self.resetShortcutActions(views: [shortcutViewThird, shortcutViewFourth, shortcutViewFifth, shortcutViewSixth])
            
            shortcutViewThird?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewFourth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewFifth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewSixth?.honeyCombView?.honeyCombButton.elements = nil
        case 3:
            setViewForSelection(honeyCombView: shortcutViewFirst, dataInfo: list.first)
            setViewForSelection(honeyCombView: shortcutViewSecond, dataInfo: list[1])
            setViewForSelection(honeyCombView: shortcutViewThird, dataInfo: list.last)
            resetShortcutActions(views: [shortcutViewFourth, shortcutViewFifth, shortcutViewSixth])
            
            shortcutViewFourth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewFifth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewSixth?.honeyCombView?.honeyCombButton.elements = nil
        case 4:
            setViewForSelection(honeyCombView: shortcutViewFirst, dataInfo: list.first)
            setViewForSelection(honeyCombView: shortcutViewSecond, dataInfo: list[1])
            setViewForSelection(honeyCombView: shortcutViewThird, dataInfo: list[2])
            setViewForSelection(honeyCombView: shortcutViewFourth, dataInfo: list.last)
            resetShortcutActions(views: [shortcutViewFifth, shortcutViewSixth])
            shortcutViewFifth?.honeyCombView?.honeyCombButton.elements = nil
            shortcutViewSixth?.honeyCombView?.honeyCombButton.elements = nil
        case 5:
            setViewForSelection(honeyCombView: shortcutViewFirst, dataInfo: list.first)
            setViewForSelection(honeyCombView: shortcutViewSecond, dataInfo: list[1])
            setViewForSelection(honeyCombView: shortcutViewThird, dataInfo: list[2])
            setViewForSelection(honeyCombView: shortcutViewFourth, dataInfo: list[3])
            setViewForSelection(honeyCombView: shortcutViewFifth, dataInfo: list.last)
            resetShortcutActions(views: [shortcutViewSixth])
            shortcutViewSixth?.honeyCombView?.honeyCombButton.elements = nil
        case 6:
            setViewForSelection(honeyCombView: shortcutViewFirst, dataInfo: list.first)
            setViewForSelection(honeyCombView: shortcutViewSecond, dataInfo: list[1])
            setViewForSelection(honeyCombView: shortcutViewThird, dataInfo: list[2])
            setViewForSelection(honeyCombView: shortcutViewFourth, dataInfo: list[3])
            setViewForSelection(honeyCombView: shortcutViewFifth, dataInfo: list[4])
            setViewForSelection(honeyCombView: shortcutViewSixth, dataInfo: list.last)
        default:
            break
        }
    }
    
    private func setViewForSelection(honeyCombView: ShortcutView?, dataInfo: Any?) {
        honeyCombView?.honeyCombView?.honeyCombButton.tag = DashboardRedirection.shortcut.rawValue
        honeyCombView?.honeyCombView?.iconImage.isHidden = false
        honeyCombView?.honeyCombView?.title.isHidden = false
        honeyCombView?.honeyCombView?.backGroundImage.image = #imageLiteral(resourceName: "blue")
        honeyCombView?.honeyCombView?.isHidden = false
        honeyCombView?.progressView?.isHidden = true
        if let data = dataInfo as? HomeScreenShortcut,
           let type = data.type {
            switch type {
            case .tem:
                honeyCombView?.honeyCombView?.iconImage.image = #imageLiteral(resourceName: "temsWhite")
                honeyCombView?.honeyCombView?.title.text = data.name
            case .challenge:
                honeyCombView?.honeyCombView?.iconImage.image = #imageLiteral(resourceName: "challengesWhite")
                honeyCombView?.honeyCombView?.title.text = "CHALLENGE: \(data.name ?? "")"
            case .goal:
                self.setGoalProgressView(honeyCombView: honeyCombView, data: data)
            }
            honeyCombView?.honeyCombView?.honeyCombButton.elements = [data]
        }
    }
    
    private func setGoalProgressView(honeyCombView: ShortcutView?, data: HomeScreenShortcut) {
        honeyCombView?.honeyCombView?.iconImage.image = #imageLiteral(resourceName: "goalsWhite")
        honeyCombView?.honeyCombView?.title.text = "GOAL: \(data.name ?? "")"
        honeyCombView?.honeyCombView?.isHidden = true
        honeyCombView?.progressView?.isHidden = false
        if let goalPercent = data.goalPercent,
           let exactValue = goalPercent.toInt(),
           exactValue <= 100{
            honeyCombView?.progressView?.resizeGoalInfoViewForPercentLessThanHundred()
        }
        honeyCombView?.progressView?.setGoalInformation(completionPercentage: data.goalPercent, name: data.name)
        honeyCombView?.progressView?.updateProgressInstant()
        honeyCombView?.progressView?.tapButton.elements = [data]
        honeyCombView?.progressView?.tapButton.tag = DashboardRedirection.shortcut.rawValue
        honeyCombView?.progressView?.tapButton.addTarget(self, action: #selector(clickedOnHoneyCombView(sender:)), for: .touchUpInside)
    }
    
    private func resetShortcutActions(views: [ShortcutView?]) {
        _ = views.map({ (view) -> ShortcutView in
            view?.honeyCombView?.initializeDefaultViewLayout()
            view?.honeyCombView?.isHidden = false
            view?.progressView?.isHidden = true
            return view ?? ShortcutView()
        })
        
    }
}
