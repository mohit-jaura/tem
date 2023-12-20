//
//  FundraisingViewController.swift
//  TemApp
//
//  Created by Egor Shulga on 25.02.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation

class FundraisingViewController : DIBaseController {
    var refresh: RefreshGNCEventDelegate?
    var eventId: String?
    var event: GroupActivity?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var content: UIView!
    
    @IBOutlet weak var progressHoneycomb: GoalProgressHoneyCombView!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    
    @IBOutlet weak var goalInfoCard: UIView!
    @IBOutlet weak var goalInfo: UIView!
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var goalIcon: UIImageView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var tematesCount: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var goalDescription: UILabel!
    @IBOutlet weak var goalStatusContainer: UIView!
    @IBOutlet weak var goalStatus: UILabel!

    @IBOutlet weak var goalDetailHoneycomb: GoalDetailHoneyCombView!
    @IBOutlet weak var goalDetailHoneycombHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullToRefresh()
    }
    
    private func addPullToRefresh() {
        let attr = [NSAttributedString.Key.foregroundColor:appThemeColor]
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "",attributes:attr)
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        self.scrollView.refreshControl = refreshControl
    }

    @objc func onPullToRefresh(sender: UIRefreshControl) {
        self.refresh?.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        goalInfoCard.layer.shadowColor = ViewDecorator.viewShadowColor
        goalInfoCard.layer.shadowOpacity = ViewDecorator.viewShadowOpacity
        goalInfoCard.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        self.handleTick()
        self.reloadView()
    }
    
    private func reloadView() {
        guard let event = self.event else { return }
        
        scrollView.refreshControl?.endRefreshing()
        donateButton.isHidden = event.status == .completed

        if let fundraising = event.fundraising, let collectedAmount = fundraising.collectedAmount, let goalAmount = fundraising.goalAmount {
            let percentage = Double(truncating: collectedAmount / goalAmount * 100 as NSNumber)
            progressHoneycomb.use(percent: percentage, achievedScore: Double(truncating: collectedAmount as NSNumber), metric: .fundraising)
        }
        self.goalName.text = event.name
        event.setActivityLabelAndImage(activityName, goalIcon)
        self.tematesCount.text = event.getTematesLabel()
        self.goalDescription.text = event.description
        goalDetailHoneycomb.setGoalHoneyCombData(data: event)
        if let status = event.status {
            switch status {
            case .completed:
                self.goalStatusContainer.isHidden = false
                self.remainingTime.text = ""
                if let fundraising = event.fundraising, let collectedAmount = fundraising.collectedAmount, let goalAmount = fundraising.goalAmount {
                    if collectedAmount >= goalAmount {
                        self.goalStatus.text = AppMessages.GroupActivityMessages.goalAchieved
                    } else {
                        self.goalStatus.text = AppMessages.GroupActivityMessages.goalIncomplete
                    }
            }
            default:
                self.goalStatusContainer.isHidden = true
            }
        }
        DispatchQueue.main.async {
            self.progressHeight.constant = 3 * self.progressHoneycomb.heightOfItem
            self.goalDetailHoneycombHeight.constant = 380
            self.goalDetailHoneycomb.heightOfFullView = 380
            self.goalDetailHoneycomb.createLayout()
            self.goalDetailHoneycomb.setGoalHoneyCombData(data: event, fundraising: true)
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func startDonation(_ sender: Any) {
        if let event = self.event {
            DIWebLayerGoals().startDonation(event: event) { (response) in
                if let completed = response.completed, completed {
                    self.showAlert(withTitle: AppMessages.Fundraising.title, message: AppMessages.Fundraising.fundraisingFinished)
                }
                else if let link = response.link, let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            } failure: { (error) in
                self.showAlert(message: error.message ?? "")
            }

        }
    }
}

extension FundraisingViewController : UpdateGNCEventInfoProtocol {
    func use(_ event: GroupActivity) {
        self.event = event
        reloadView()
    }
}

extension FundraisingViewController : UpdateByTimerProtocol {
    func handleTick() {
        self.remainingTime.text = self.event?.remainingTime()
    }
}
