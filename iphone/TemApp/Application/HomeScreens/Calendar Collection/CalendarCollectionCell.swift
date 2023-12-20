//
//  CalendarCollectionCell.swift
//  TemApp
//
//  Created by shivani on 08/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol ShowCalendarDetailsDelegate {
    func openPopupScreen()
}

class CalendarCollectionCell: UICollectionViewCell {
    
    // MARK: Properties
    var rightInset: CGFloat = 7
    var calendarDetailsDelegate : ShowCalendarDetailsDelegate?
    var accountabilityIndex1:Int = 50
    var imageOff = "Oval Copy 5"
    var imageOn = "Oval Copy 3"
    
    // MARK: Outlets
    @IBOutlet weak var myScheduleLabel: UILabel!
    @IBOutlet weak var sunImage: UIImageView!
    @IBOutlet weak var monImage: UIImageView!
    @IBOutlet weak var tueImage: UIImageView!
    @IBOutlet weak var wedImage: UIImageView!
    @IBOutlet weak var thuImage: UIImageView!
    @IBOutlet weak var friImage: UIImageView!
    @IBOutlet weak var satImage: UIImageView!
    @IBOutlet weak var accountabilityCountLabel: UILabel!
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountabilityIndex: UILabel!
    @IBOutlet weak var indexGradientView: UIView!
    
    @IBOutlet weak var dashedLineView: UIView!
    @IBOutlet weak var indexSuperviewInnerShadow: SSNeumorphicView!{
        didSet{
            addNeumorphicShadow(view: indexSuperviewInnerShadow, shadowType: .outerShadow, cornerRadius: 4, shadowRadius: 0.4, opacity:  0.3, darkColor:  #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5), lightColor: UIColor.black.cgColor, offset: CGSize(width: 2, height: 2))
        }
    }
    @IBOutlet weak var indexViewInnerShadow: SSNeumorphicView!{
        didSet{
            addNeumorphicShadow(view: indexViewInnerShadow, shadowType: .innerShadow, cornerRadius: 4, shadowRadius: 0.4, opacity:  0.3, darkColor:  UIColor.black.cgColor, lightColor: UIColor.black.cgColor, offset: CGSize(width: -2, height: -2))
        }
    }
    
    @IBOutlet weak var innerView: SSNeumorphicView! {
        didSet{
            addNeumorphicShadow(view: innerView, shadowType: .innerShadow, cornerRadius: 8, shadowRadius: 0.5, opacity:  0.3, darkColor:  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), lightColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), offset: CGSize(width: 2, height: 2))
        }
    }
    @IBOutlet weak var viewControllerButton: SSNeumorphicButton! {
        didSet{
            viewControllerButton.btnNeumorphicCornerRadius = 8
            viewControllerButton.btnNeumorphicShadowRadius = 0.8
            viewControllerButton.btnDepthType = .outerShadow
            viewControllerButton.btnNeumorphicLayerMainColor = #colorLiteral(red: 0.2445561886, green: 0.5110852718, blue: 0.8627218604, alpha: 1)
            viewControllerButton.btnNeumorphicShadowOpacity = 0.25
            viewControllerButton.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.7)
            viewControllerButton.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            viewControllerButton.btnNeumorphicLightShadowColor = UIColor.black.cgColor
        }
    }
    @IBOutlet weak var mainView: SSNeumorphicView! {
        didSet {
            addNeumorphicShadow(view: mainView, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 0.8, opacity:  0.3, darkColor:  #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5), lightColor: UIColor.black.cgColor, offset: CGSize(width: -2, height: -2))
        }
    }
    @IBOutlet weak var outerShadowView: SSNeumorphicView!{
        didSet{
            addNeumorphicShadow(view: outerShadowView, shadowType: .outerShadow, cornerRadius: 4, shadowRadius: 0.4, opacity:  0.3, darkColor:  #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5), lightColor: UIColor.black.cgColor, offset: CGSize(width: -2, height: -2))
        }
    }
    // MARK: Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        labelTrailingConstraint.constant = rightInset - myScheduleLabel.frame.width/2 + myScheduleLabel.frame.height/2
        myScheduleLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addDashedLineView()
        setGradientBackground()
    }
    
    // MARK: IBAction
    @IBAction func indexDetailsTapped(_ sender: UIButton) {
        calendarDetailsDelegate?.openPopupScreen()
    }
    
    // MARK: Helper Function
    func addNeumorphicShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius: CGFloat, shadowRadius: CGFloat , opacity: Float, darkColor: CGColor, lightColor: CGColor, offset: CGSize){
        view.viewDepthType = shadowType
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.2439696491, green: 0.5112304091, blue: 0.85862571, alpha: 1)
        view.viewNeumorphicShadowOpacity = opacity
        view.viewNeumorphicDarkShadowColor =  darkColor
        view.viewNeumorphicShadowOffset = offset
        view.viewNeumorphicLightShadowColor = lightColor
    }
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        var colorArray = [CGColor]()
        var gradientLoc: [NSNumber] = [0.0]
        
        if accountabilityIndex1 > 100{
            accountabilityIndex1 = 100
        }
        if accountabilityIndex1 > 0{
            for value in 1...accountabilityIndex1  {
                let gradientColors = StaticColors().getColor(colorValue: value).cgColor
                colorArray.append(gradientColors)
            }
            colorArray.append(#colorLiteral(red: 0.2352643311, green: 0.2353112996, blue: 0.2352614105, alpha: 1).cgColor)
            gradientLayer.colors = colorArray
            
            for locations in 1...accountabilityIndex1 {
                let  location = NSNumber(value: Double(locations) / Double(100))
                gradientLoc.append(location)
            }
        } else {
            colorArray.append(#colorLiteral(red: 0.2352643311, green: 0.2353112996, blue: 0.2352614105, alpha: 1).cgColor)
            colorArray.append(#colorLiteral(red: 0.2352643311, green: 0.2353112996, blue: 0.2352614105, alpha: 1).cgColor)
            gradientLayer.colors = colorArray
            let number: NSNumber = 1
            gradientLoc.append(number)
            
        }
        
        // adding the increased location for fading in b/w of two colors
        if let lastNumber = gradientLoc.last{
            var addedVal: NSNumber = 0.1
            if accountabilityIndex1 < 10{
                addedVal = 0.03
            }
            let addedValue = NSDecimalNumber(decimal: addedVal.decimalValue)
            let newAddedValue: NSNumber = NSDecimalNumber(decimal: lastNumber.decimalValue).adding(addedValue)
            gradientLoc.removeLast()
            gradientLoc.append(newAddedValue)
        }
        //Setting the direction
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.locations = gradientLoc
        gradientLayer.frame = self.indexGradientView.bounds
        indexGradientView.backgroundColor = .black
        
        removeSublayer(gradientLayer: gradientLayer, view: indexGradientView )
        self.indexGradientView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func addDashedLineView(){
        let outerPath =   UIBezierPath(roundedRect: indexSuperviewInnerShadow.bounds, byRoundingCorners: .allCorners,cornerRadii: CGSize(width: 8.0, height: 8.0))
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = outerPath.bounds
        gradientLayer.colors = [ UIColor.cyan.withAlphaComponent(0.5).cgColor, UIColor.purple.withAlphaComponent(0.6).cgColor,UIColor.yellow.withAlphaComponent(0.5).cgColor ]
        
        let shapeMask = CAShapeLayer()
        shapeMask.path = outerPath.cgPath
        shapeMask.lineWidth = 3
        shapeMask.lineDashPattern = [ 1, 1 ]
        shapeMask.lineCap = .butt
        shapeMask.lineJoin = .round
        shapeMask.strokeColor = UIColor.black.cgColor
        shapeMask.fillColor = nil
        gradientLayer.mask = shapeMask
        
        removeSublayer(gradientLayer: gradientLayer, view: indexSuperviewInnerShadow)
        indexSuperviewInnerShadow.layer.addSublayer( gradientLayer )
    }
    
    func removeSublayer(gradientLayer: CAGradientLayer, view: UIView?){
        gradientLayer.name = "gradientLayer"
        let sublayers: [CALayer]? = view?.layer.sublayers
        if let layeers = sublayers{
            for layer in  layeers{
                if layer.name == "gradientLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    // 2022-03-21 11:51:45 +0000 Date()
    //2022-03-22T10:16:46.000Z  Coming
    //2015-04-01T11:42:00    Needed
    
    func setData(weeklyDays: [WeekDays], accountabilityIndex: Double){
        accountabilityCountLabel.text = "\(accountabilityIndex)%"
        accountabilityIndex1 = Int(accountabilityIndex)
        
        monImage.image = UIImage(named: imageOff)
        tueImage.image = UIImage(named: imageOff)
        wedImage.image = UIImage(named: imageOff)
        thuImage.image = UIImage(named: imageOff)
        friImage.image = UIImage(named:imageOff)
        satImage.image = UIImage(named: imageOff)
        for date in weeklyDays{
            if let day = getDate(date: date.date ?? "" ){
                let dayNumber = day.dayNumberOfWeek()
                
                if dayNumber == 1 {
                    sunImage.image = UIImage(named: imageOn)
                } else if dayNumber == 2 {
                    monImage.image = UIImage(named:imageOn)
                } else if dayNumber == 3 {
                    tueImage.image = UIImage(named: imageOn)
                } else if dayNumber == 4 {
                    wedImage.image = UIImage(named: imageOn)
                }else if dayNumber == 5 {
                    thuImage.image = UIImage(named: imageOn)
                }else if dayNumber == 6 {
                    friImage.image = UIImage(named: imageOn)
                }else if dayNumber == 7 {
                    satImage.image = UIImage(named: imageOn)
                }
            }
        }
    }
    
    func getDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let updatedAtStr = date
        return  dateFormatter.date(from: updatedAtStr)
    }
}

