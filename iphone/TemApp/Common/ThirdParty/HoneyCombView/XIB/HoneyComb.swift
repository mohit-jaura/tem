//
//  HoneyComb.swift
//
//  Created by Sourav on 4/5/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class HoneyCombButton: UIButton {
    var elements: [Any]? //you can store the elements that needs to be accessed for the button
}

protocol HoneyCombDelegate: AnyObject {
    func didSelectInfoView()
}

class HoneyComb: UIView {

    // MARK: IBOutlets
    @IBOutlet weak var titleTopToIconConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageCenterX: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var backGroundImage: UIImageView!
    @IBOutlet weak var honeyCombButton: HoneyCombButton!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var iconImageCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var upDownArrowView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var activityScoreLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var valueLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageHeightConstraint: NSLayoutConstraint!
    
    @IBAction func infoViewTapped(_ sender: Any) {
        print("tapped$$$$$$")
        self.delegate?.didSelectInfoView()
    }
    // MARK: Properties
    var isSelected: Bool = false
    weak var delegate: HoneyCombDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Convert the point to the target view's coordinate system.
        // The target view isn't necessarily the immediate subview
        let pointForTargetView = infoButton.convert(point, from: self)

        if infoButton.bounds.contains(pointForTargetView) {

            // The target view may have its view hierarchy,
            // so call its hitTest method to return the right hit-test view
            return infoButton.hitTest(pointForTargetView , with: event)
        }

        return super.hitTest(point, with: event)
    }
    
    private func intialize() {
        Bundle.main.loadNibNamed("HoneyComb", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame.size = self.frame.size
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    /// setting the view properties for the metrics honey comb view
    ///- Parameters:
    /// isViewSelected: the selected state, will contain either true or false
    func setMetricsViewFor(state isViewSelected: Bool, disabled: Bool = false) {
        if !disabled {
            if !isViewSelected {
                self.backGroundImage.isHidden = false
                self.backGroundImage.image = #imageLiteral(resourceName: "honey-blue-border")
                self.title.textColor = UIColor.grayishBlackColor
                self.valueLabel.textColor = UIColor.grayishBlackColor
            } else {
                self.backGroundImage.isHidden = false
                self.backGroundImage.image = #imageLiteral(resourceName: "blue")
                self.title.textColor = UIColor.white
                self.valueLabel.textColor = UIColor.white
            }
        } else {
            self.backGroundImage.image = #imageLiteral(resourceName: "honey-gray-border")
            self.title.textColor = UIColor.gray
            self.valueLabel.textColor = UIColor.gray
        }
    }
    
    func setData(value: String) {
        self.valueLabel.text = value
    }
    
    func setGoalMetricvalue(state isViewSelected: Bool, value:String? = nil) {
        if isViewSelected {
            self.valueLabel.text = value
            self.backGroundImage.isHidden = false
            self.backGroundImage.image = #imageLiteral(resourceName: "blue")
            self.title.textColor = UIColor.white
            self.valueLabel.textColor = UIColor.white
        }
    }
    
    /*
     set the default layout of the honey comb on initializing a new honeycomb
     */
    func initializeDefaultViewLayout() {
        self.shadowView.backgroundColor = .clear
        self.backGroundImage.image = #imageLiteral(resourceName: "gray-honey")
        self.backGroundImage.isHidden = true
        self.backGroundImage.contentMode = .scaleAspectFill
        self.iconImage.isHidden = true
        self.title.isHidden = true
        self.valueLabel.isHidden = true
        self.logoImageView.isHidden = true
        self.upDownArrowView.isHidden = true
        self.setInfoView(hide: true)
    }
    
    func setInfoView(hide: Bool) {
        self.infoView.isHidden = hide
        self.infoButton.isHidden = hide
    }
    
    /// Align the title label to the center of the view
    func alignTitleAtCenter() {
//        self.iconImageCenterConstraint.constant = -25
        self.titleTopToIconConstraint.constant = -30
    }
    
    func changeTitleViewConstraint() {
//        self.iconImageCenterConstraint.constant = -15
    }
    
    /// set the large size of imageIcon
    func setIconSize(imageUrl: URL){
        
        iconImage.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        iconImageHeightConstraint.constant = 40
        iconImageWidthConstraint.constant = 40
        iconImage.cornerRadius =  20
        iconImage.contentMode = .scaleAspectFill
    }
}
