//
//  LeaderboardHeader.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class LeaderboardHeader: UITableViewHeaderFooterView {

    // MARK: IBOutlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var matricNameLabel: UILabel!
    @IBOutlet weak var topConstraintToHeader: NSLayoutConstraint!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var temateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var bottomConstraintToView: NSLayoutConstraint!

    // MARK: Helpers
    func setHeader(text: String) {
        self.headerLabel.text = text
    }
    
    //set the metric name text for challenge
    func initializeViewForChallenge(selectedMetrics: [Int]) {
        if selectedMetrics.count > 1 {
            self.matricNameLabel.text = ""
        } else {
            if let value = selectedMetrics.first,
                let metric = Metrics(rawValue: value) {
                if metric == .distance {
                    self.matricNameLabel.text = metric.title.lowercased() + " (miles)"
                } else {
                    self.matricNameLabel.text = metric.title.lowercased()
                }
            }
        }
    }
    
    //set the metric name text for goal
    func initializeViewForGoal(target: [GoalTarget]) {
        if let goalTarget = target.first,
            let metricValue = goalTarget.matric,
            let metric = Metrics(rawValue: metricValue) {
            if metric == .distance {
                self.matricNameLabel.text = metric.title.lowercased() + " (miles)"
            } else {
                self.matricNameLabel.text = metric.title.lowercased()
            }
        }
    }
    
    //set the view for leaderboard of a user
    func initializeViewForUserCustomLeaderboard() {
        self.topConstraintToHeader.constant = 0
        self.headerLabel.text = ""
        self.rankLabel.text = "RANK".localized
        self.temateLabel.text = "TĒMATE".localized
        self.matricNameLabel.text = "SCORE".localized
        self.infoView.borderWidth = 1.0
        self.infoView.borderColor = UIColor.gray
    }
    
    func addBorder() {
        self.addTopBorderWithColor(color: UIColor.gray, width: 1.0)
        self.addLeftBorderWithColor(color: UIColor.gray, width: 1.0)
    }
}
