//
//  UpcomingChallengeJoinTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 27/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol ChallengeJoinTableCellDelegate: AnyObject {
    func didClickOnJoin(sender: UIButton)
}
class UpcomingChallengeJoinTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: ChallengeJoinTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var metricsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var honeyCombView: UpcomingChallengeHoneyCombView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var backView:SSNeumorphicView!{
        didSet{
            backView.setOuterDarkShadow()
            backView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    // MARK: Helpers
    @IBAction func joinTapped(_ sender: UIButton) {
        self.delegate?.didClickOnJoin(sender: sender)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        metricsViewHeightConstraint.constant = 450
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Initialize the data
    func initializeWith(activity: GroupActivity) {
        if let isJoined = activity.isActivityJoined {
            //user has already joined the activity
            if isJoined == true {
                self.joinButton.isUserInteractionEnabled = false
                self.joinButton.setTitle(AppMessages.GroupActivityMessages.joined, for: .normal)
            } else {
                self.joinButton.isUserInteractionEnabled = true
                self.joinButton.setTitle(AppMessages.GroupActivityMessages.joinTitle, for: .normal)
            }
        }
        if let metrics = activity.selectedMetrics {
            self.honeyCombView.setViewForMetricValues(values: metrics)
        }
    }
    
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.82).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.92).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
}
