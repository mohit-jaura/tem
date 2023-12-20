//
//  GoalProgressDisplayView.swift
//  TemApp
//
//  Created by shilpa on 13/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class GoalProgressDisplayView: UIView {

    // MARK: Properties
    var completionPercentage: Double?
    var metric: Metrics?
    var achievedValue: Double?
    var padding: CGFloat = 10
    var lineWidth: CGFloat?
    var focusSize: CGFloat?
    private var sizeOfInnerView: CGFloat = 0.0
    
    // MARK: IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var innerProgressView: BezierView!
    @IBOutlet weak var outerProgressView: BezierView!
    @IBOutlet weak var metricValueLabel: UILabel!
    @IBOutlet weak var metricTitleLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var honeyCombHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var honeyCombWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var outerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var outerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var goalNameIconView: UIView!
    @IBOutlet weak var goalIconImageView: UIImageView!
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var percentageView: UIView!
    @IBOutlet weak var tapButton: HoneyCombButton!
    @IBOutlet weak var blueImageView: UIImageView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    // MARK: View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    
    // MARK: Initializer
    private func intialize() {
        Bundle.main.loadNibNamed(GoalProgressDisplayView.reuseIdentifier, owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame.size = self.frame.size
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    func setViewsLayoutForGoalScreenshotView() {
        self.honeyCombWidthConstraint.constant = 60
        self.honeyCombHeightConstraint.constant = 60
        
        self.innerViewWidthConstraint.constant = 85
        self.innerViewHeightConstraint.constant = 85
        
        self.outerViewWidthConstraint.constant = 100
        self.outerViewHeightConstraint.constant = 100
        
        self.metricValueLabel.font = UIFont(name: UIFont.robotoMedium, size: 8.0)
        self.metricTitleLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
        self.percentageLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
    }
    
    func setViewsLayoutForOpenGoalView() {
        self.honeyCombWidthConstraint.constant = 65
        self.honeyCombHeightConstraint.constant = 65
        
        self.innerViewWidthConstraint.constant = 95
        self.innerViewHeightConstraint.constant = 95
        
        self.outerViewWidthConstraint.constant = 110
        self.outerViewHeightConstraint.constant = 110
        
        self.metricValueLabel.font = UIFont(name: UIFont.robotoMedium, size: 8.0)
        self.metricTitleLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
        self.percentageLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
    }
    
    func setViewsLayoutForOpenGoalView1() {
        self.honeyCombWidthConstraint.constant = 65
        self.honeyCombHeightConstraint.constant = 65
        
        self.innerViewWidthConstraint.constant = 95
        self.innerViewHeightConstraint.constant = 95
        
        self.outerViewWidthConstraint.constant = 150
        self.outerViewHeightConstraint.constant = 150
        
        self.metricValueLabel.font = UIFont(name: UIFont.robotoMedium, size: 8.0)
        self.metricTitleLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
        self.percentageLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
        self.blueImageView.isHidden = true
        self.innerProgressView.isHidden = true
        self.view1.isHidden = true
        self.view2.isHidden = true
    }
    
    
    func setViewsLayoutForGoalShortcut(widthOfFullTile: CGFloat, heightOfFullTile: CGFloat) {
        self.sizeOfInnerView = widthOfFullTile - 20
        self.honeyCombWidthConstraint.constant = sizeOfInnerView
        self.honeyCombHeightConstraint.constant = sizeOfInnerView
        
        self.innerViewWidthConstraint.constant = widthOfFullTile + 5
        self.innerViewHeightConstraint.constant = widthOfFullTile + 5
        
        self.outerViewWidthConstraint.constant = widthOfFullTile + 20
        self.outerViewHeightConstraint.constant = widthOfFullTile + 20
        
        self.metricValueLabel.font = UIFont(name: UIFont.robotoMedium, size: 8.0)
        self.metricTitleLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
        self.percentageLabel.font = UIFont(name: UIFont.robotoRegular, size: 8.0)
        self.setBezierProperties(padding: 4.0, focusSize: 6.0, lineWidth: 3.0)
    }
    
    func resizeGoalInfoViewForPercentLessThanHundred() {
        self.honeyCombWidthConstraint.constant = sizeOfInnerView + 15
        self.honeyCombHeightConstraint.constant = sizeOfInnerView + 15
    }
    
    func setBezierProperties(padding: CGFloat, focusSize: CGFloat, lineWidth: CGFloat) {
        self.padding = padding
        self.focusSize = focusSize
        self.lineWidth = lineWidth
    }

    //for testing purpose only
    func configureBezierPathFor(view: BezierView, withPercent percent: CGFloat) {
        view.transform = CGAffineTransform.identity
        let frame = CGRect(x: view.bounds.origin.x + padding, y: view.bounds.origin.y + padding, width: view.bounds.width - (padding * 2), height: view.bounds.height - (padding * 2))
        if let lineWidth = self.lineWidth {
            view.lineWidth = lineWidth
        }
        if let focusSize = self.focusSize {
            view.focusSize = focusSize
        }
        view.bezierPath = UIBezierPath(frame: frame, sides: 6, cornerRadius: 0.0)
        view.setProgress(endValue: 0.0)
        
        view.updateView(lastValue: 0.0, newValue: percent)
    }
    
    func resetBezierPathFor(view: BezierView, withPercent percent: CGFloat) {
        if let lineWidth = self.lineWidth {
            view.lineWidth = lineWidth
        }
        if let focusSize = self.focusSize {
            view.focusSize = focusSize
        }
        view.bezierPath = nil
        view.setProgress(endValue: 0.0)
        view.updateView(lastValue: 0.0, newValue: 0)
        
    }
    
    func updateCompletionPercentage() {
        if let percent = self.completionPercentage {
            self.percentageLabel.text = "\(percent.rounded(toPlaces: 2))%"
        }
        if let achievedScore = self.achievedValue,
            let metric = self.metric {
            self.metricTitleLabel.text = metric.title.uppercased()
            self.metricTitleLabel.isHidden = false
            switch metric {
            case .steps, .totalActivites:
                self.metricValueLabel.text = "\(achievedScore.toInt() ?? 0)"
            case .distance,.calories:
                self.metricValueLabel.text = "\(achievedScore.rounded(toPlaces: 2))"
            case .totalActivityTime:
                if let totalTime = achievedScore.toInt() {
                    let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTime)
                    let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                    self.metricValueLabel.text = displayTime
                }
            case .fundraising:
                self.metricValueLabel.text = "$\(achievedScore.rounded(toPlaces: 2))"
                self.metricTitleLabel.isHidden = true
            }
        }
    }
    
    func updateProgressAfterDelay() {
        self.perform(#selector(updateProgressViews), with: nil, afterDelay: 0.2)
    }
    
    func updateProgressInstant() {
        self.updateProgressViews()
    }
    
    //call this function to update the progress in hexagonal manner
    @objc private func updateProgressViews() {
        //check if the progress is greater than or less than 100%
        if let completionPercent = self.completionPercentage?.toInt() {
            if completionPercent <= 100 {
                //show only outer progress bar
                let percent = Double(completionPercent)/100
                self.configureBezierPathFor(view: self.outerProgressView, withPercent: CGFloat(percent.rounded(toPlaces: 2)))
                //new:
                self.resetBezierPathFor(view: innerProgressView, withPercent: 0)
            } else if completionPercent > 100 {
                outerProgressView.hasExceededTheMaxPercent = true
                self.configureBezierPathFor(view: self.innerProgressView, withPercent: 1.0)
                if completionPercent <= 200 {
                    let outerPercent = Double(completionPercent - 100)/100
                    self.configureBezierPathFor(view: self.outerProgressView, withPercent: CGFloat(outerPercent.rounded(toPlaces: 2)))
                } else {    //if percentage is greater than 200, create the progress with full 100%
                    let percentValue = Double(completionPercent % 100) / 100
                    var outerPercent = percentValue
                    if outerPercent == 0 {
                        outerPercent = 1.0
                    }
                    self.configureBezierPathFor(view: self.outerProgressView, withPercent: CGFloat(outerPercent.rounded(toPlaces: 2)))
                }
            }
        }
    }
    
    ///set the goal information in the view with the progress bar
    func setGoalInformation(completionPercentage: Double?, name: String?) {
        self.percentageView.isHidden = true
        self.goalNameIconView.isHidden = false
        self.tapButton.isUserInteractionEnabled = true
        self.tapButton.isHidden = false
        self.goalNameLabel.text = name
        self.goalIconImageView.image = #imageLiteral(resourceName: "goalsWhite")
        self.completionPercentage = completionPercentage
        self.updateCompletionPercentage()
        self.updateProgressInstant()
    }
}
