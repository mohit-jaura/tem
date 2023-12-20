//
//  HealthCollectionCell.swift
//  TemApp
//
//  Created by shivani on 08/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class HealthCollectionCell: UICollectionViewCell {
    
    // MARK: Properties
    var rightInset: CGFloat = 7
    
    // MARK: Outlets
    @IBOutlet weak var journalBtn: UIButton!
    @IBOutlet weak var activityBtn: UIButton!
    @IBOutlet var activityScoreView: UIView!
    @IBOutlet var lineView: GradientDashedLineCircularView!
    @IBOutlet var lightBrownCircleView: SSNeumorphicView!
    @IBOutlet var outerShadowView: SSNeumorphicView!
    @IBOutlet weak var innerShadowView: SSNeumorphicView!
    @IBOutlet var activityScoreValueLabel: UILabel!
    @IBOutlet var activityScoreTextLabel: UILabel!
   
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var reportsBtn:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
        //addShadow()
        resizeFonts()
        outerShadowView.viewNeumorphicCornerRadius = self.outerShadowView.frame.height/2
       innerShadowView.viewNeumorphicCornerRadius = self.innerShadowView.frame.height/2
        setLinesView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setUpLayout()
    }
    
    // MARK: Setup Layout
    private func setUpLayout() {
        self.setRadiusProperties()
        self.resizeFonts()
    }
    
    // MARK: Set view properties
    private func setRadiusProperties() {
        self.layoutIfNeeded()
        self.activityScoreView.cornerRadius = self.activityScoreView.frame.height/2
        self.lightBrownCircleView.cornerRadius = self.lightBrownCircleView.frame.height/2
        self.lineView.cornerRadius = self.lineView.frame.height/2
        outerShadowView.viewNeumorphicCornerRadius = self.outerShadowView.frame.height/2
    }
    
    private func resizeFonts() {
        let scoreValueFontSize = self.activityScoreView.frame.size.height/4
        self.activityScoreValueLabel.font = UIFont(name: UIFont.avenirNextMedium, size: scoreValueFontSize)
        self.activityScoreTextLabel.font = UIFont(name: UIFont.avenirNextRegular, size: scoreValueFontSize/4)
        self.activityScoreValueLabel.adjustsFontSizeToFitWidth = true
        self.activityScoreTextLabel.numberOfLines = 0
        self.activityScoreTextLabel.minimumScaleFactor = 0.25
    }
    
    func setLinesView() {
//        setRadiusProperties()
        lineView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.darkGray.withAlphaComponent(1)], gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        lineView.instanceWidth = 1.5
        lineView.instanceHeight = 20.0
        lineView.extraInstanceCount = 1
        lineView.lineColor = UIColor(red: 140/255, green: 148/255, blue: 147/255, alpha: 1.0)
//        self.lineView.updateGradientLocation(newLocations: [0.30, 0.33])
        self.outerShadowView.viewDepthType = .outerShadow
        outerShadowView.viewNeumorphicCornerRadius = self.outerShadowView.frame.height/2
        self.outerShadowView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        self.outerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        self.outerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        self.lightBrownCircleView.viewDepthType = .outerShadow
        lightBrownCircleView.viewNeumorphicCornerRadius = self.lightBrownCircleView.frame.height/2
        self.lightBrownCircleView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        self.lightBrownCircleView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.lightBrownCircleView.viewNeumorphicDarkShadowColor = UIColor.darkGray.cgColor
        
        
        self.innerShadowView.viewDepthType = .innerShadow
        innerShadowView.viewNeumorphicCornerRadius = self.innerShadowView.frame.height/2
        self.innerShadowView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        self.innerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        self.innerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
    }
    
    
    // MARK: Set data
    func setScore(value: Double?, withAnimation: Bool) {
        self.activityScoreValueLabel.text = "\(value ?? 0)"
        if let valueUnwrapped = value {
            let scoreGradientLocation = valueUnwrapped <= 100 ? valueUnwrapped/(100) : 1
            let nextGradientLocation = scoreGradientLocation + 0.03
            self.lineView.updateGradientLocation(newLocations: [NSNumber(value: scoreGradientLocation), NSNumber(value: nextGradientLocation)], addAnimation: withAnimation)
        }
    }

    
    func setViewStateFor(loadingState: ApiLoadingState) {
        switch loadingState {
        case .hasError(_), .isLoaded:
            self.activityIndicator.stopAnimating()
            self.activityScoreValueLabel.isHidden = false
        case .isLoading:
            self.activityIndicator.startAnimating()
            self.activityScoreValueLabel.isHidden = true
        }
    }
}

