//
//  LeaderBoardNewCell.swift
//  TemApp
//
//  Created by Developer on 17/08/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit

class LeaderBoardNewCell: UITableViewCell {

        // MARK: Properties
        weak var delegate: LeaderboardTableCellDelegate?
        @IBOutlet weak var infoView: UIView!
        // MARK: IBOutlets.
        @IBOutlet weak var scoreView: UIView!
        @IBOutlet weak var scoreLbl: UILabel!
        @IBOutlet weak var rankHoneyCombImageView: UIImageView!
        @IBOutlet weak var rankLabel: UILabel!
        @IBOutlet weak var userImageView: CustomImageView!
        @IBOutlet weak var userNameLabel: CustomLabel!
        @IBOutlet weak var locationLabel: UILabel!
        @IBOutlet weak var metricsView: LeadershipBoardMetricHoneyCombView!
        @IBOutlet weak var arrowButton: UIButton!
        @IBOutlet weak var locationIconImage: UIImageView!
        @IBOutlet weak var metricValueLabel: UILabel!
        @IBOutlet weak var underlineView: UIView!
        @IBOutlet weak var rankView: UIView!
        @IBOutlet weak var userNameLabelTopConstraint: NSLayoutConstraint!
        @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
        @IBOutlet weak var sideBorderView: UIView!
        @IBOutlet weak var bottomBorderView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    }

extension LeaderBoardNewCell {
    func configureCellForGroupLeaderboard(atIndexPath indexPath: IndexPath, user: Friends) {
        self.userNameLabelTopConstraint.constant = 2
        self.arrowButton.isHidden = true
        let score = (user.accountabilityScore?.rounded(toPlaces: 2).formatted ?? "0")
        self.metricValueLabel.textAlignment = .center
        self.metricValueLabel.text = score
        self.rankLabel.text = "\(user.rank ?? 0)"//"\(indexPath.row + 1)"
        self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        if let imageUrl = user.profilePic,
            let url = URL(string: imageUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }
        self.userNameLabel.text = user.fullName
    }
    
    func showBottomBorder(shouldVisible: Bool) {
        self.sideBorderView.borderWidth = ViewDecorator.viewBorderWidth
        self.sideBorderView.borderColor = ViewDecorator.viewBorderColor
        self.bottomBorderView.isHidden = shouldVisible
    }
}
