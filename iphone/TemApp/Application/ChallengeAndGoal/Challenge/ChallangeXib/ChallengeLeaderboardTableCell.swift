//
//  leaderboardTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol UpdateUIDelegate{
    func updateUI()
}

protocol ChallengeLeaderboardTableCellDelegate: AnyObject {
    func didTapOnArrowButton(sender: UIButton, totalOpenedMetricViews: Int)
    func didTapOnUserInformation(atRow row: Int, section: Int)
}

class ChallengeLeaderboardTableCell: UITableViewCell {
    
    // MARK: Properties
    var updateUIDelegate: UpdateUIDelegate?
    var challenge: GroupActivity?
    var delegate:ChallengeLeaderboardTableCellDelegate?
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var backShadowView:SSNeumorphicView!{
        didSet{
            backShadowView.setOuterDarkShadow()
            backShadowView.viewDepthType = .innerShadow
            backShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    
    // MARK: UITableViewCell Functions.
    override func awakeFromNib() {
        super.awakeFromNib()
        table.delegate = self
        table.dataSource = self
        table.registerNibs(nibNames: [LeaderboardTableCell.reuseIdentifier])
        table.isScrollEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension ChallengeLeaderboardTableCell:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenge?.scoreboard?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableCell.reuseIdentifier, for: indexPath) as! LeaderboardTableCell
        cell.delegate = self
        if let activityInfo = self.challenge,
           let scoreboard = activityInfo.leaderboardArray {
            cell.hideAnimation()
            cell.setScoreView()
            cell.configureData(atIndexPath: indexPath, scoreboard: scoreboard[indexPath.row], activityInfo: activityInfo)
        }
        if indexPath.row == challenge?.scoreboard?.count ?? 0 - 1 {
            updateUIDelegate?.updateUI()
        }
        return cell
    }
}

extension ChallengeLeaderboardTableCell: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return LeaderboardTableCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
}

extension ChallengeLeaderboardTableCell: LeaderboardTableCellDelegate {
    func didTapOnArrowButton(sender: UIButton, totalOpenedMetricViws: Int) {
        self.delegate?.didTapOnArrowButton(sender: sender,totalOpenedMetricViews: totalOpenedMetricViws)
        self.table.reloadData()
    }

    func didTapOnUserInformation(atRow row: Int, section: Int) {
        self.delegate?.didTapOnUserInformation(atRow: row, section: section)
    }

}
