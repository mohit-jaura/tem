//
//  SelectInterestHoneyCombView.swift
//  TemApp
//
//  Created by Shilpa Vashisht on 29/06/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import SSNeumorphicView


protocol HoneyCombViewDelegate: AnyObject {
    func didSelectHoneyComb(_ honeyCombObject: SKHoneyCombObject,_ honeyCombView: HoneyComb)
    func didClickOnStart()
}

class SelectInterestHoneyCombView: UIView, HoneyCombViewable {
    var honeyCombObjectsArr: [SKHoneyCombObject] = []
    var minNumberOfItemsInRow: Int = 3
    var numberOfRows: Int = 7
    var dividerForHeight: Double = 0
    let padding: CGFloat = 4//8
    var scrollView: UIScrollView!
    var contentView: UIView!
    var rowHeight: CGFloat = 100
    var minContentSizeHeight: CGFloat = 0
    let buttonAreaHeight: CGFloat = 100//120
    weak var delegate:HoneyCombViewDelegate?

    override func layoutSubviews() {
        self.reloadData()
    }
    
    func layOutItems() {
        self.scrollView = UIScrollView(frame: self.bounds)
        scrollView.backgroundColor = .clear
        self.addSubview(self.scrollView)
        
        let fullScreenHeight = UIScreen.main.bounds.height
        minContentSizeHeight = fullScreenHeight - 81 - 2*(self.safeAreaLayoutGuide.layoutFrame.height)
        
        self.contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: self.rowHeight))
        self.contentView.backgroundColor = .clear
        self.scrollView.addSubview(self.contentView)
        self.addSubview(self.scrollView)
        self.scrollView.isScrollEnabled = true
        
        drawHoneyCombView()
        //for _ in 0...3 {
          //  self.drawHoneyCombView()
        //}
    }
    
    public func reloadData() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        
        self.layOutItems()
    }
    
    private func drawHoneyCombView() {
        
        let widthOfItem = (self.bounds.width - 3 * self.padding)/3.75//(self.bounds.width - 3 * self.padding)/4.5
        let heightOfItem = widthOfItem
//        y_Cordinate = 0//-safeAreaHeight
        var itemsInRow:Int = 0
        rowHeight = heightOfItem
        
        let dataSource = getDataSource()
        let quotient = honeyCombObjectsArr.count/minNumberOfItemsInRow
        let remainder = honeyCombObjectsArr.count % minNumberOfItemsInRow

        if remainder < minNumberOfItemsInRow {
            numberOfRows = quotient + 1
        } else {
            numberOfRows = quotient
        }
        
        for outerIndex in 0..<numberOfRows {
            if remainder < minNumberOfItemsInRow,
               outerIndex == numberOfRows - 1 {
                //last index
                itemsInRow = remainder
            } else {
                itemsInRow = minNumberOfItemsInRow
            }
            
            for innerIndex in 0..<itemsInRow {
                let backView = UIView()
                backView.clipsToBounds = true
                backView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)

                applyHexagonMaskOnUIView(view: backView)

                let honeyCombView = HoneyComb()
                honeyCombView.iconImage.isHidden = true

                honeyCombView.frame.size = CGSize(width: widthOfItem, height: heightOfItem)
                honeyCombView.transform = honeyCombView.transform.rotated(by: -CGFloat(Double.pi / 2))

                
                var centerX:CGFloat!
                var centerY:CGFloat!
                
                if (isEven(outerIndex)) {
                    centerX = (CGFloat(innerIndex) * widthOfItem) + (CGFloat(innerIndex + 1) * self.padding) + widthOfItem/1.25 - (CGFloat(innerIndex) * widthOfItem/4) + (3 * CGFloat(innerIndex) * self.padding)//+ (2 * CGFloat(innerIndex) * self.padding)
                    
                } else {
                    centerX = (CGFloat(innerIndex) * widthOfItem) + (CGFloat(innerIndex + 1) * self.padding) + widthOfItem/1.25 + widthOfItem/2 + self.padding/2 - (CGFloat(innerIndex) * widthOfItem/4) + (3 * CGFloat(innerIndex) * self.padding) - 2 * self.padding
                }
                centerY = (2 * (CGFloat(outerIndex)) + 1) * ((heightOfItem / 2)) - (heightOfItem / 2) + (heightOfItem/1.25) - (CGFloat(outerIndex) * 2 * self.padding) - (CGFloat(outerIndex) * widthOfItem/4) + (2.5 * CGFloat(outerIndex) * self.padding)
                
                if  dataSource[outerIndex]?[innerIndex].isSelected == true {
                    honeyCombView.isSelected = true
                    honeyCombView.shadowView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    honeyCombView.shadowView.alpha = 0.7
                    honeyCombView.iconImage.setImageColor(color: UIColor.black)
                    honeyCombView.title.textColor = UIColor.black
                }else{
                    honeyCombView.isSelected = false
                    honeyCombView.shadowView.backgroundColor = .black
                    honeyCombView.shadowView.alpha = 0.6
                    honeyCombView.iconImage.setImageColor(color: UIColor.white)
                    honeyCombView.title.textColor = UIColor.white
                }
                honeyCombView.backGroundImage.image = UIImage(named: "hexGrayShadow")
                if let url = URL(string: BuildConfiguration.shared.serverUrl + (dataSource[outerIndex]?[innerIndex].image ?? "")) {
                    honeyCombView.backGroundImage.kf.setImage(with: url, placeholder: UIImage(named: "gray-honey"))
                }
                honeyCombView.iconImage.isHidden = false
                if let url = URL(string: BuildConfiguration.shared.serverUrl + (dataSource[outerIndex]?[innerIndex].icon ?? "")) {
                    honeyCombView.iconImage.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (result) in
                        if honeyCombView.isSelected == true {
                            honeyCombView.iconImage.setImageColor(color: UIColor.black)
                        } else {
                            honeyCombView.iconImage.setImageColor(color: UIColor.white)
                        }
                    }
                }
                honeyCombView.honeyCombButton.elements = [dataSource[outerIndex]?[innerIndex] ?? [:],honeyCombView]
                honeyCombView.honeyCombButton.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
                honeyCombView.title.text = dataSource[outerIndex]?[innerIndex].name
                backView.center = CGPoint(x: centerX, y: centerY)
                backView.addSubview(honeyCombView)
                self.contentView.addSubview(backView)

            }
        }
        let honeyCombContentSize = CGFloat(numberOfRows - 2) * rowHeight// - (10 * CGFloat(numberOfRows))
        let contentSize = honeyCombContentSize + buttonAreaHeight
        addStartYourJourneyButtonAtBottom(at: honeyCombContentSize)
        self.scrollView.contentSize.height = contentSize
        self.contentView.frame = CGRect(x: 0, y: 0 , width: self.bounds.width, height: contentSize)
    }
    
    private func applyHexagonMaskOnUIView(view:UIView) {
        let maskPath = UIBezierPath(frame: view.bounds, numberOfSides: 6, cornerRadius: 0.0)
        let maskingLayer = CAShapeLayer()
        maskingLayer.path = maskPath?.cgPath
        view.transform = view.transform.rotated(by: CGFloat(Double.pi / 2))
        view.layer.mask = maskingLayer
        
        // Add border
        /*let borderLayer = CAShapeLayer()
        borderLayer.path = maskingLayer.path // Reuse the Bezier path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.red.cgColor
        borderLayer.lineWidth = 5.0
        borderLayer.frame = view.bounds
        view.layer.addSublayer(borderLayer) */
    }
    
    private func addBorder(view:UIView) {
        let borderLayer = CAShapeLayer()
        let maskPath = UIBezierPath(frame: view.bounds, numberOfSides: 6, cornerRadius: 0.0)
        let maskingLayer = CAShapeLayer()
        maskingLayer.path = maskPath?.cgPath
        borderLayer.path = maskingLayer.path // Reuse the Bezier path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.red.cgColor
        borderLayer.lineWidth = 5.0
        borderLayer.frame = view.bounds
        view.layer.addSublayer(borderLayer)
    }
    
    private func addStartYourJourneyButtonAtBottom(at yPosition: CGFloat) {
        guard !honeyCombObjectsArr.isEmpty else {
            return
        }
        let containerView = UIView(frame: CGRect(x: 0, y: yPosition, width: self.bounds.width, height: buttonAreaHeight))
        containerView.backgroundColor = UIColor.clear
        let button = ShadowButton()
        let buttonWidth = 150
        button.frame = CGRect(x: containerView.bounds.midX - CGFloat(buttonWidth/2), y: 30, width: 170, height: 45)
        button.setTitle("START YOUR JOURNEY", for: .normal)
        button.setTitleColor( #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1), for: .normal)
        button.dropShadow(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.49), offSet: CGSize(width: 1, height: 1))
        button.titleLabel?.font = UIFont(name: UIFont.robotoMedium, size: 13.0)
        button.addTarget(self, action: #selector(startJourneyTapped(sender:)), for: .touchUpInside)
        button.addShadowOnButton()
        button.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1882352941, blue: 0.2352941176, alpha: 1)

        containerView.addSubview(button)
        self.contentView.addSubview(containerView)
    }
    
    // MARK: Get the data source
    private func getDataSource() -> [Int:[SKHoneyCombObject]] {
        var sortedDataSource = [Int:[SKHoneyCombObject]]()
        var honeyCombMutableObjects = self.honeyCombObjectsArr
        var quotient = 0 
        var remainder = 0 
        let totalCountOfObjects = honeyCombMutableObjects.count
        let value = totalCountOfObjects.quotientAndRemainder(dividingBy: minNumberOfItemsInRow)//totalCountOfObjects.quotientAndRemainder(dividingBy: self.numberOfRows)
        quotient = value.quotient
        remainder = value.remainder
        var columnsInRow = minNumberOfItemsInRow
        for i in 0..<quotient {
            if i == quotient-1, remainder != 0 {
                columnsInRow = remainder
            }
            
            for _ in 0..<columnsInRow {
                if sortedDataSource[i] == nil {
                    sortedDataSource[i] = []
                }
                sortedDataSource[i]?.append(honeyCombMutableObjects.removeFirst())
            }
        }
        return sortedDataSource
    }
    
    // MARK: Action on click
    @objc func didSelectItem(_ target: HoneyCombButton) {
        if let firstData = target.elements?.first as? SKHoneyCombObject,let honeyView = target.elements?.last as? HoneyComb {
            delegate?.didSelectHoneyComb(firstData, honeyView)
        }
    }
    
    @objc func startJourneyTapped(sender: UIButton) {
        self.delegate?.didClickOnStart()
    }
}
