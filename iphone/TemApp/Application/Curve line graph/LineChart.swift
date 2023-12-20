//
//  LineChart.swift
//  LineChart
//
//  Created by Nguyen Vu Nhat Minh on 25/8/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit

struct PointEntry {
    let value: Double
    let label: String
}

extension PointEntry: Comparable {
    static func <(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value == rhs.value
    }
}

class LineChart: UIView {
    
    //days difference
    let daysDiff = 7
    
    /// gap between each point
    let lineGap: CGFloat = 9.0
    
    /// preseved space at top of the chart
    let topSpace: CGFloat = 40.0
    
    /// preserved space at bottom of the chart to show labels along the Y axis
    let bottomSpace: CGFloat = 40.0
    
    /// The top most horizontal line in the chart will be 10% higher than the highest value in the chart
    let topHorizontalLine: CGFloat = 110.0 / 110.0
    
    var isCurved: Bool = false
    
    /// Active or desactive animation on dots
    var animateDots: Bool = false
    
    /// Active or desactive dots
    var showDots: Bool = false
    
    /// Dot inner Radius
    var innerRadius: CGFloat = 8
    
    /// Dot outer Radius
    var outerRadius: CGFloat = 12
    
    var dataEntries: [PointEntry]? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Contains the main line which represents the data
    private let dataLayer: CALayer = CALayer()
    
    /// To show the gradient below the main line
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    /// Contains dataLayer and gradientLayer
    private let mainLayer: CALayer = CALayer()
    
    /// Contains mainLayer and label for each data entry
    private let scrollView: UIScrollView = UIScrollView()
    
    /// Contains horizontal lines
    private let gridLayer: CALayer = CALayer()
    
    /// An array of CGPoint on dataLayer coordinate system that the main line will go through. These points will be calculated from dataEntries array
    private var dataPoints: [CGPoint]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView)
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        if let dataEntries = dataEntries {
            scrollView.contentSize = CGSize(width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            gradientLayer.frame = dataLayer.frame
            dataPoints = convertDataEntriesToPoints(entries: dataEntries)
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            if showDots { drawDots() }
            clean()
            drawVerticalHorizontalLines()
            if isCurved {
                drawCurvedChart()
            } else {
                drawChart()
            }
            drawLables()
        }
    }
    
    /**
     Convert an array of PointEntry to an array of CGPoint on dataLayer coordinate system
     */
    private func convertDataEntriesToPoints(entries: [PointEntry]) -> [CGPoint] {
        let max = 100
        let min = 0
        
        var result: [CGPoint] = []
        let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine
        
        for i in 0..<entries.count {
            let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxRange))
            let point = CGPoint(x: CGFloat(i)*lineGap + 40, y: height)
            result.append(point)
        }
        return result
    }
    
    /**
     Draw a zigzag line connecting all points in dataPoints
     */
    private func drawChart() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0,
            let path = createPath() {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.darkGray.cgColor
            lineLayer.fillColor = UIColor.darkGray.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    /**
     Create a zigzag bezier path that connects all points in dataPoints
     */
    private func createPath() -> UIBezierPath? {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        for i in 1..<dataPoints.count {
            path.addLine(to: dataPoints[i])
        }
        return path
    }
    
    /**
     Draw a curved line connecting all points in dataPoints
     */
    private func drawCurvedChart() {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return
        }
        
        guard let dataEntries = dataEntries else {
            return
        }
        
        //draw circle for today
        let xValue = dataPoints[dataPoints.count-1].x
        let yValue = dataPoints[dataPoints.count-1].y
        let circleLayer = CAShapeLayer() 
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: xValue-5, y:yValue-5, width: 10, height: 10)).cgPath 
        circleLayer.lineWidth = 2.5
        circleLayer.strokeColor = UIColor.black.cgColor 
        circleLayer.fillColor = UIColor.white.cgColor
        //show coplete curve path
        if let path = CurveAlgorithm.shared.createCurvedPath(dataPoints,dataEntries: dataEntries) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.lineWidth = 3
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
        dataLayer.addSublayer(circleLayer)
    }
    /**
     Create titles at the bottom for all entries showed in the chart
     */
        private func drawLables() {
            if let dataEntries = dataEntries,
                dataEntries.count > 0 {
                
                var showValue = 6
                for i in 0..<dataEntries.count {
                    if i == showValue {
                        let textLayer = CATextLayer()
                        textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 10, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap + 50, height: 16)
                        textLayer.foregroundColor = UIColor.white.cgColor
                        textLayer.backgroundColor = UIColor.clear.cgColor
                        textLayer.alignmentMode = CATextLayerAlignmentMode.center
                        textLayer.contentsScale = UIScreen.main.scale
                        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                        textLayer.fontSize = 11
                        let value = showValue + 1 - dataEntries.count
                        textLayer.string = value == 0 ? "Today" : String(showValue + 1 - dataEntries.count)
                        mainLayer.addSublayer(textLayer)
                        showValue += daysDiff
                    }
                }
            }
        }
    /**
     Create vertical and horizontal lines (grid lines) and show the value of each line
     */
    private func drawVerticalHorizontalLines() {
        guard let dataEntries = dataEntries else {
            return
        }
        var gridValues: [CGFloat]? = nil
        gridValues = [0, 1]
        var showValue = -1
        
        for value in 0..<dataEntries.count {
            if value == showValue || value == 0{
                showValue += daysDiff
                guard let dataPoints = dataPoints, dataPoints.count > 0 else {
                    return
                }
                let xValue = dataPoints[value].x
                let lineLayer = CAShapeLayer()
                let path = CGMutablePath()
                if value>0 {
                    lineLayer.lineDashPattern = [4,4]
                    lineLayer.strokeColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
                    lineLayer.lineWidth = 0.5
                    path.addLines(between: [CGPoint(x: xValue, y: 0),
                                            CGPoint(x: xValue, y: gridLayer.frame.size.height)])
                }
                else{
                    lineLayer.strokeColor = UIColor.lightGrayAppColor.cgColor
                    lineLayer.lineWidth = 1.5
                    path.addLines(between: [CGPoint(x: xValue, y: 2),
                                            CGPoint(x: xValue, y: gridLayer.frame.size.height+2)])
                }
                lineLayer.path = path
                gridLayer.addSublayer(lineLayer)
            }
        }
        //end
        //draw horizontal path
        if let gridValues = gridValues {
            for value in gridValues {
                let height = value * gridLayer.frame.size.height
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 39, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width-40, y: height))
                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = UIColor.lightGrayAppColor.cgColor
                lineLayer.lineWidth = 1.5
                if (value > 0.0 && value < 1.0) {
                    lineLayer.lineDashPattern = [4, 4]
                }
                if (value == 0.0) {
                    lineLayer.lineDashPattern = [0, 0]
                }
                gridLayer.addSublayer(lineLayer)
                let minMaxGap:CGFloat = 100
                let min = 0
                var lineValue:Int = 0
                lineValue = Int((1-value) * minMaxGap) + Int(min)
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 10, y: height, width: 35, height: 16)
                textLayer.foregroundColor = UIColor.white.cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.alignmentMode = lineValue == 0 ? .center : .left
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 13
                textLayer.string = "\(lineValue)"
                gridLayer.addSublayer(textLayer)
            }
        }
    }
    /**
     clean all sub layes
     */
    private func clean() {
        mainLayer.sublayers?.forEach({
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        })
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    /**
     Create Dots on line points
     */
    private func drawDots() {
        var dotLayers: [DotCALayer] = []
        if let dataPoints = dataPoints {
            for dataPoint in dataPoints {
                let xValue = dataPoint.x - outerRadius/2
                let yValue = (dataPoint.y + lineGap) - (outerRadius * 2)
                let dotLayer = DotCALayer()
                dotLayer.dotInnerColor = UIColor.white
                dotLayer.innerRadius = innerRadius
                dotLayer.backgroundColor = UIColor.white.cgColor
                dotLayer.cornerRadius = outerRadius / 2
                dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
                dotLayers.append(dotLayer)
                mainLayer.addSublayer(dotLayer)
                if animateDots {
                    let anim = CABasicAnimation(keyPath: "opacity")
                    anim.duration = 1.0
                    anim.fromValue = 0
                    anim.toValue = 1
                    dotLayer.add(anim, forKey: "opacity")
                }
            }
        }
    }
}
