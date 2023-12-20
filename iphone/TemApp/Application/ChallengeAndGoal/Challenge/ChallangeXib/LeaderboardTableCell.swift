//
//  leaderboardTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

protocol LeaderboardTableCellDelegate: AnyObject {
    func didTapOnArrowButton(sender: UIButton, totalOpenedMetricViws: Int)
    func didTapOnUserInformation(atRow row: Int, section: Int)
}

extension LeaderboardTableCellDelegate {
    func didTapOnArrowButton(sender: UIButton) {}
}



class LeaderboardTableCell: UITableViewCell {
    
    // MARK: Properties
    weak var delegate: LeaderboardTableCellDelegate?
    var openedMetricViewsCount = 0
    
    @IBOutlet weak var infoView: UIView!
    
    // MARK: IBOutlets.
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var rankHoneyCombImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var userImageView: CustomImageView!
    @IBOutlet weak var userNameLabel: CustomLabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var metricsView: UIView!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var locationIconImage: UIImageView!
    @IBOutlet weak var metricValueLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var userNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var metricsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideBorderView: UIView!
    @IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet weak var distanceCountLabel: UILabel!
    @IBOutlet weak var caloriesCountLabel: UILabel!
    @IBOutlet weak var activitiesCountLabel: UILabel!
    @IBOutlet weak var timeCountLabel: UILabel!
    // MARK: IBActions
    @IBAction func arrowTapped(_ sender: UIButton) {
        self.delegate?.didTapOnArrowButton(sender: sender,totalOpenedMetricViws: self.openedMetricViewsCount)
    }
    
    // MARK: UITableViewCell Functions.
    override func awakeFromNib() {
        super.awakeFromNib()
        [self.userNameLabel, self.locationLabel, self.rankView, self.rankHoneyCombImageView, self.locationIconImage].forEach { (view) in
            view?.showAnimatedSkeleton()
        }
        self.userImageView.showAnimatedSkeleton()
    }
    
    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }
    
    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask
    }
    
    func hideAnimation() {
        [self.userNameLabel, self.locationLabel, self.rankView, self.rankHoneyCombImageView, self.locationIconImage, self.scoreView].forEach { (label) in
            label?.hideSkeleton()
        }
        self.userImageView.hideSkeleton()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Function to configure tablecell with data.
    func configureData(atIndexPath indexPath: IndexPath, scoreboard: Leaderboard, activityInfo: GroupActivity) {
        self.arrowButton.tag = indexPath.row
        
        self.rankLabel.text = "-"
        if let rank = scoreboard.rank {
            self.rankLabel.text = "\(rank)"
        }
        
        self.addGestures(indexPath: indexPath)
        if let score = scoreboard.score {
            self.scoreLbl.text = score.rounded(toPlaces: 0).formatted ?? "0"
        } else {
            self.scoreLbl.text = "\(0)"
        }
        self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        var urlString: String? = scoreboard.leaderboardMember?.profilePic
        var name: String? = scoreboard.leaderboardMember?.fullName
        if let type = activityInfo.activityMembersType {
            if type == .individualVsTem || type == .temVsTem {
                if let title = scoreboard.leaderboardMember?.groupTitle,
                   !title.isEmpty {
                    name = scoreboard.leaderboardMember?.groupTitle
                    urlString = scoreboard.leaderboardMember?.groupIcon
                }
            }
        }
        self.userNameLabel.text = name
        if let imageUrl = urlString,
           let url = URL(string: imageUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }
        self.setUserLocationInformation(address: scoreboard.leaderboardMember?.address)
        self.setMetricsInformation(atIndexPath: indexPath, activityInfo: activityInfo, scoreboard: scoreboard)
        setDarkThemeUI()
    }
    
    private func addGestures(indexPath: IndexPath) {
        //add tap gesture
        self.userImageView.row = indexPath.row
        self.userNameLabel.row = indexPath.row
        let tapGestureOnLabel = UITapGestureRecognizer(target: self, action: #selector(userNameLabelTapped(recognizer:)))
        self.userNameLabel.addGestureRecognizer(tapGestureOnLabel)
        let tapGestureOnProfilePic = UITapGestureRecognizer(target: self, action: #selector(profilePicTapped(recognizer:)))
        self.userImageView.addGestureRecognizer(tapGestureOnProfilePic)
    }
    
    //Gestures hanlders
    @objc func userNameLabelTapped(recognizer: UITapGestureRecognizer) {
        if let tappedView = recognizer.view as? CustomLabel {
            self.delegate?.didTapOnUserInformation(atRow: tappedView.row, section: tappedView.section)
        }
    }
    
    @objc func profilePicTapped(recognizer: UITapGestureRecognizer) {
        if let tappedView = recognizer.view as? CustomImageView {
            self.delegate?.didTapOnUserInformation(atRow: tappedView.row, section: tappedView.section)
        }
    }
    
    //set user location information on view
    private func setUserLocationInformation(address: Address?) {
        self.locationIconImage.isHidden = false
        self.locationLabel.text = ""
        self.userNameLabelTopConstraint.constant = 2
        if let location = address,
           let formattedAddress = location.formatAddress(),
           !formattedAddress.isEmpty {
            self.locationLabel.text = formattedAddress
        } else {
            self.locationIconImage.isHidden = true
            self.userNameLabelTopConstraint.constant = 10
        }
    }
    
    func setScoreView() {
        self.scoreView.isHidden = false
    }
    
    private func setMetricsValue(values: [Int], scoreboard: Leaderboard) {
        for value in values {
            if let metric = Metrics(rawValue: value) {
                switch metric {
                    case .steps:
                        distanceCountLabel.text = "\(scoreboard.steps?.toInt() ?? 0)"
                    case .calories:
                        caloriesCountLabel.text = "\(scoreboard.calories?.rounded(toPlaces: 2) ?? 0)"
                    case .distance:
                        distanceCountLabel.text = "\(scoreboard.distance?.rounded(toPlaces: 2) ?? 0) Miles"
                    case .totalActivites:
                        activitiesCountLabel.text = "\(scoreboard.totalActivities?.toInt() ?? 0)"
                    case .totalActivityTime:
                        if let totalTimeInSeconds = scoreboard.totalTime?.toInt() {
                            let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: totalTimeInSeconds)
                            let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                            timeCountLabel.text = displayTime
                        }
                    default:
                        break
                }
            }
        }
    }
    private func setMetricsInformation(atIndexPath indexPath: IndexPath, activityInfo: GroupActivity, scoreboard: Leaderboard) {
        metricsView.tag = indexPath.row
        let arrowIcon = scoreboard.isOpened ? UIImage(named: "UpArrowWhite") :  UIImage(named: "downarrowWhite")
        self.arrowButton.setImage(arrowIcon, for: .normal)
        self.underlineView.isHidden = !scoreboard.isOpened
        if let type = activityInfo.type {
            switch type {
                case .challenge:
                    if let metrics = activityInfo.selectedMetrics,
                       !metrics.isEmpty {
                        if metrics.count == 1 {
                            self.metricsView.isHidden = true
                            metricsHeightConstraint.constant = 0
                            self.arrowButton.isHidden = true
                            if let metric = metrics.first {
                                self.setMetricValue(selectedMetric: metric, scoreboard: scoreboard)
                            }
                        } else {
                            self.metricsView.isHidden = !scoreboard.isOpened
                            self.arrowButton.isHidden = false
                            if !metricsView.isHidden {
                                metricsHeightConstraint.constant = 22
                                self.setMetricsValue(values: metrics, scoreboard: scoreboard)
                            } else {
                                metricsHeightConstraint.constant = 0
                            }
                        }
                    }
                case .goal:
                    self.metricsView.isHidden = true
                    self.arrowButton.isHidden = true
                    if let selectedMetric = activityInfo.target?.first?.matric {
                        self.setMetricValue(selectedMetric: selectedMetric, scoreboard: scoreboard)
                    }
                default:
                    break
            }
        }
    }
    
    /// set the metrics value in label in case only single metric was selected
    private func setMetricValue(selectedMetric: Int, scoreboard: Leaderboard) {
        self.metricValueLabel.text = ""
        if let metricSelected = Metrics(rawValue: selectedMetric) {
            switch metricSelected {
                case .steps:
                    if let steps = scoreboard.steps {
                        self.metricValueLabel.text = "\(steps.toInt() ?? 0)"
                    }
                case .calories:
                    if let calories = scoreboard.calories {
                        self.metricValueLabel.text = "\(calories.rounded(toPlaces: 2))"
                    }
                case .distance:
                    if let distance = scoreboard.distance {
                        self.metricValueLabel.text = "\(distance.rounded(toPlaces: 2))"
                    }
                case .totalActivites:
                    if let activities = scoreboard.totalActivities {
                        self.metricValueLabel.text = "\(activities.toInt() ?? 0)"
                    }
                case .totalActivityTime:
                    if let time = scoreboard.totalTime?.toInt() {
                        let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: time)
                        
                        let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                        self.metricValueLabel.text = "\(displayTime)"
                    }
                default:
                    break
            }
        }
    }
    func setDarkThemeUI() {
        self.rankHoneyCombImageView.image = UIImage(named: "grayishPolygon")
        self.rankLabel.font = UIFont(name:"AvenirNext-Medium", size: 12.0)
        self.userNameLabel.font = UIFont(name:"AvenirNext-Medium", size: 16.0)
        self.locationLabel.font = UIFont(name:"AvenirNext-Medium", size: 12.0)
        self.metricValueLabel.font = UIFont(name:"AvenirNext-Medium", size: 20.0)
        self.scoreLbl.font = UIFont(name:"AvenirNext-Medium", size: 20.0)
        self.rankLabel.textColor = .white
        self.userNameLabel.textColor = .white
        self.locationLabel.textColor = .white
        self.metricValueLabel.textColor = .white
        self.scoreLbl.textColor = UIColor.appCyanColor
        self.locationIconImage.isHidden = true
        NSLayoutConstraint.activate([
            locationLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor)
        ])
    }
}

extension LeaderboardTableCell {
    func configureCellForGroupLeaderboard(atIndexPath indexPath: IndexPath, user: Friends) {
        self.hideAnimation()
        self.userNameLabelTopConstraint.constant = 2
        self.arrowButton.isHidden = true
        let score = (user.accountabilityScore?.rounded(toPlaces: 2).formatted ?? "0")
        self.metricValueLabel.textAlignment = .center
        self.metricValueLabel.text = score
        self.rankLabel.text = "\(user.rank ?? 0)"
        self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        if let imageUrl = user.profilePic,
           let url = URL(string: imageUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }
        self.addGestures(indexPath: indexPath)
        self.userNameLabel.text = user.fullName
        self.setUserLocationInformation(address: user.address)
    }
    func configureCellForHomeLeaderboard(atIndexPath indexPath: IndexPath, user: Friends) {
        self.hideAnimation()
        self.userNameLabelTopConstraint.constant = 2
        self.arrowButton.isHidden = true
        let score = (user.accountabilityScore?.rounded(toPlaces: 2).formatted ?? "0")
        self.metricValueLabel.textAlignment = .center
        self.metricValueLabel.text = score
        self.rankLabel.text = "\(user.rank ?? 0)"
        self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        if let imageUrl = user.profilePic,
           let url = URL(string: imageUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }
        self.addGestures(indexPath: indexPath)
        self.userNameLabel.text = user.fullName
        self.userImageView.borderColor = .white
        self.userImageView.borderWidth = 1
        self.setUserLocationInformation(address: user.address)
        setDarkThemeUI()
    }
    func showBottomBorder(shouldVisible: Bool) {
        self.sideBorderView.borderWidth = ViewDecorator.viewBorderWidth
        self.sideBorderView.borderColor = ViewDecorator.viewBorderColor
        self.bottomBorderView.isHidden = shouldVisible
    }
}
