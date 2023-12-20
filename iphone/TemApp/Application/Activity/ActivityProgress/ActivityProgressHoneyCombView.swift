//
//  ActivityProgressHoneyCombView.swift
//  TemApp
//
//  Created by Harpreet_kaur on 30/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

protocol  ActivityProgressDelegate:AnyObject {
    func stopAndStartActivity()
    func didSetProgressHoneyCombAt(center: CGPoint)
}
extension ActivityProgressDelegate {
    func didSetProgressHoneyCombAt(center: CGPoint) {}
}
class ActivityProgressHoneyCombView: UIView, HoneyCombViewable {
    
     // MARK: Properties
    weak var delegate:ActivityProgressDelegate?
    var isPlaying:Bool = true
    var minNumberOfItemsInRow: Int = 2
    var numberOfRows: Int = 5
    var dividerForHeight: Double = 3.0//3.6
    var scrollView:UIScrollView!
    var contentView: UIView!
    var safeAreaHeight:CGFloat = 0.0
    var topSafeArea:CGFloat = 0.0
    var y_Cordinate:CGFloat = 0.0
    var activityData:ActivityData = ActivityData()
    
    let outerInnerHoneyCombView = ProgresViewXib()
    let outerInnerGrayhoneyCombView = HoneyComb()
    
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
        
        let widthOfItem = (self.bounds.width + self.padding)/CGFloat(minNumberOfItemsInRow)
        let heightOfItem = widthOfItem / 1.13
        y_Cordinate = -safeAreaHeight
        var itemsInRow:Int = 0
        
        //        for outerIndex in 0..<7 {
        for outerIndex in 0..<numberOfRows {
            if (!isEven(outerIndex)) {
                itemsInRow = minNumberOfItemsInRow + 1
            } else {
                itemsInRow = minNumberOfItemsInRow
            }
            
            for innerIndex in 0..<itemsInRow {
                
                var centerX:CGFloat!
                var centerY:CGFloat!
                if (!isEven(outerIndex)) {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1)) - (widthOfItem / 2 + (self.padding/2))
                    
                } else {
                    centerX = ((CGFloat(innerIndex + 1)) * self.padding) + ((widthOfItem / 2) * ((2 * CGFloat(innerIndex)) + 1))
                }
                centerX -= self.padding
                centerY = (2 * (CGFloat(outerIndex)) + 1) * ((heightOfItem / 2)) - (heightOfItem / 2) + (2 * safeAreaHeight)
                
                if outerIndex == 1 && innerIndex == 1 {
                    let honeyCombView = outerInnerHoneyCombView
                    honeyCombView.delegate = self
                    let grayhoneyCombView = outerInnerGrayhoneyCombView
                    honeyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                    grayhoneyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                    grayhoneyCombView.initializeDefaultViewLayout()
                    honeyCombView.outerImageView.contentMode = .scaleAspectFill
                    honeyCombView.innerImageView.contentMode = .scaleAspectFill
                    honeyCombView.centerImageView.contentMode = .scaleAspectFill
                    honeyCombView.center = CGPoint(x: centerX, y: centerY)
                    grayhoneyCombView.center = CGPoint(x: centerX, y: centerY)
                    self.contentView.addSubview(grayhoneyCombView)
                    self.contentView.addSubview(honeyCombView)
                    honeyCombView.isPlaying = self.isPlaying
                    honeyCombView.configureView(frame: honeyCombView.bounds, activityData: self.activityData)
                } else {
                    let honeyCombView = HoneyComb()
                    honeyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                    honeyCombView.initializeDefaultViewLayout()
                    honeyCombView.center = CGPoint(x: centerX, y: centerY)
                    self.contentView.addSubview(honeyCombView)
                    if outerIndex == 2 && innerIndex == 0 {
                        let centerPosition = CGPoint(x: centerX, y: centerY)
                        self.delegate?.didSetProgressHoneyCombAt(center: centerPosition)
                    }
                }
            }
            
        }
        let height = (heightOfItem * CGFloat(numberOfRows)) + (CGFloat(safeAreaHeight+topSafeArea + 100))
        self.contentView.frame = CGRect(x: 0, y: y_Cordinate , width: self.bounds.width, height: height)
    }
    
    //start rotation animation
    func rotateViewOnAxis() {
        guard self.contentView != nil else {
            return
        }
        for subview in self.contentView.subviews where  subview is ProgresViewXib {
                print("start animations")
                //honeycombView.configureView(frame: honeycombView.bounds)
        }
    }
    
    //stop animations
    func stopViewRotation() {
        guard self.contentView != nil else {
            return
        }
        for subview in self.contentView.subviews {
            if let honeycombView = subview as? ProgresViewXib {
                print("stop all animations")
                honeycombView.isRecursiveCall = false
                outerInnerHoneyCombView.isRecursiveCall = false
               // honeycombView.stopAllAnimations()
            }
        }
    }
    
    func restartAnimation() {
        if self.contentView != nil {
            for subview in self.contentView.subviews {
                if let honeycombView = subview as? ProgresViewXib {
                    print("stop all animations")
                    honeycombView.restartAnimation()
                    honeycombView.isRecursiveCall = true
                }
            }
        }
    }
}

extension ActivityProgressHoneyCombView : ActivityProgressHoneyCombDelegate {
    func stopAndStartActivity() {
        self.delegate?.stopAndStartActivity()
    }
}

