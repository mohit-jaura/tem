//
//  ActivityMetricsViewController.swift
//  TemApp
//
//  Created by shilpa on 25/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ActivityMetricsViewController: DIBaseController {
    
    // MARK: Properties
    private var totalActivityReport: UserActivityReport?
    private var challengesReport: GroupActivityReport?
    private var goalsReport: GroupActivityReport?
    private var last30thDayDate: Date?
    private var graphData:[Graph_]?
    private var othersGraphData:[Graph_]?
    
    
    // MARK: IBOutlets
    @IBOutlet weak var appAvgScoreViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chartTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var honeycombView: ActivityLogHoneyCombView!
    @IBOutlet weak var appAverageScoreLabel: UILabel!
    @IBOutlet weak var currentUserScoreLabel: UILabel!
    @IBOutlet weak var appAverageScoreSlider: CustomSlider!
    @IBOutlet weak var appAverageScoreView: UIView!
    @IBOutlet weak var currentUserScoreView: UIView!
    @IBOutlet weak var currentUserScoreViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var challengeProgressView: CircleView!
    @IBOutlet weak var goalsProgressView: CircleView!
    @IBOutlet weak var totalActivitiesCountLabel: UILabel!
    @IBOutlet weak var totalActivityTypesLabel: UILabel!
    @IBOutlet weak var accountAccountabilityLabel: UILabel!
    @IBOutlet weak var averageDurationLabel: UILabel!
    @IBOutlet weak var averageDistanceLabel: UILabel!
    @IBOutlet weak var averageCaloriesLabel: UILabel!
    @IBOutlet weak var averageDailyStepsLabel: UILabel!
    @IBOutlet weak var averageSleepLabel: UILabel!
    @IBOutlet weak var totalChallengesLabek: UILabel!
    @IBOutlet weak var completedChallengesLabel: UILabel!
    @IBOutlet weak var wonChallengesLabel: UILabel!
    @IBOutlet weak var activeChallengesLabel: UILabel!
    @IBOutlet weak var totalGoalsLabel: UILabel!
    @IBOutlet weak var activeGoalsLabel: UILabel!
    @IBOutlet weak var completedGoalsLabek: UILabel!
    @IBOutlet weak var challengeCircleView: UIView!
    @IBOutlet weak var goalCircleView: UIView!
    @IBOutlet weak var challengesCircleViewCountLabel: UILabel!
    @IBOutlet weak var goalsCircleViewCountLabel: UILabel!
    @IBOutlet weak var curvedlineChart: LineChart!
    
    @IBOutlet weak var totalactivitiesShadowView:  UIView!
    @IBOutlet weak var totalactivitiesTypeShadowView:  UIView!
    @IBOutlet weak var accountabilityIndexShadowView:  UIView!
    @IBOutlet weak var averageDurationShadowView:  UIView!
    @IBOutlet weak var averageDistanceShadowView:  UIView!

    @IBOutlet weak var dailyStepsShadowView:  UIView!
    @IBOutlet weak var averageSleepShadowView:  UIView!
    @IBOutlet weak var challengeView:
        UIView!
    @IBOutlet weak var goalsView:
        UIView!
    @IBOutlet weak var shadowView: UIView!
    
    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func challengesTapped(_ sender: UIButton) {
        self.pushToGroupActivityScreen(showChallenges: true)
    }
    @IBAction func goalsTapped(_ sender: UIButton) {
        self.pushToGroupActivityScreen(showChallenges: false)
    }
    /*
     Method to genrate entries for curve line graph
     */
    private func generateRandomEntries() -> [PointEntry] {
        var result: [PointEntry] = []
        for value in 0 ..< self.graphData!.count {
            let graphObj = self.graphData?[value]
            if value == 0{
                result.append(PointEntry(value: graphObj?.score ?? 0, label: "Today" ))
            } else {
                result.append(PointEntry(value: graphObj?.score ?? 0, label: graphObj?.date ?? ""))
            }
        }
        return result.reversed()
    }

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
     /* /  self.setInitialProgressView()
        self.setCircleViewProperties()
        self.configureNavigationBar()*/
        self.getActivityLog()
        // Do any additional setup after loading the view.
        addShadowToView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: false, controller: self)
        }
        
    }
    
    // MARK: Initializer
        func addShadowToView(){
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 4
            shadowView.layer.shadowOpacity = 1
            shadowView.layer.shadowColor = UIColor.gray.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0 , height:2)
    }
    
    func setCircleViewProperties() {
        self.challengeProgressView.backgroundStrokeColor = UIColor.themeLightColor
        self.challengeProgressView.lineWidth = 4.0
        self.goalsProgressView.backgroundStrokeColor = UIColor.themeLightColor
        self.goalsProgressView.lineWidth = 4.0
        let gradientColors = [UIColor(0x007DDC).cgColor, UIColor(0x0199E6).cgColor, UIColor(0x01B5EF).cgColor]
        self.challengeCircleView.applyGradient(inDirection: .leftToRight, colors: gradientColors)
        self.goalCircleView.applyGradient(inDirection: .leftToRight, colors: gradientColors)
    }
    
    func configureNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        let rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "postShare"), style: .plain, target: self, action: #selector(rightShareBarButtonTapped(sender:)))
        rightBarButtonItem.tintColor = UIColor.textBlackColor
        self.setNavigationController(titleName: Constant.ScreenFrom.activityLog.title, leftBarButton: [leftBarButtonItem], rightBarButtom: [rightBarButtonItem], backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    private func setShareAsRightBarButton() {
        let rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "postShare"), style: .plain, target: self, action: #selector(rightShareBarButtonTapped(sender:)))
        rightBarButtonItem.tintColor = UIColor.textBlackColor
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func setActivityIndicatorOnRightBarButton() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.style = .gray
        let rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        rightBarButtonItem.tintColor = UIColor.textBlackColor
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        activityIndicator.startAnimating()
    }
    
    // MARK: Propgress helpers
    func setScoreOnSliderView(myScore: Double, appAverageScore: Double?) {
        self.slider.value = Float(myScore)
        self.currentUserScoreLabel.text = "\(myScore.rounded(toPlaces: 2).formatted ?? "0")"
        self.currentUserScoreView.layoutIfNeeded()
        if let appAvgScore = appAverageScore {
            
            self.appAverageScoreLabel.text = "\(appAvgScore.rounded(toPlaces: 2).formatted ?? "0")" + "-Avg"
            self.appAverageScoreSlider.value = Float(appAvgScore)
            self.appAverageScoreView.layoutIfNeeded()
            
            if myScore == appAvgScore {
                //set same thumb image for both sliders
                self.slider.setThumbImage(#imageLiteral(resourceName: "2 drop"), for: .normal)
                self.appAverageScoreSlider.setThumbImage(#imageLiteral(resourceName: "2 drop"), for: .normal)
            } else {
                self.slider.setThumbImage(#imageLiteral(resourceName: "raindrop-close-up"), for: .normal)
                self.appAverageScoreSlider.setThumbImage(#imageLiteral(resourceName: "raindrop-close-down"), for: .normal)
            }
            self.appAverageScoreView.isHidden = false
            
        } else {
            //if app avg score is nil
            self.slider.setThumbImage(#imageLiteral(resourceName: "raindrop-close-up"), for: .normal)
        }
        self.currentUserScoreViewLeadingConstraint.constant = (slider.thumbCenterX - currentUserScoreView.bounds.width/2)
        self.appAvgScoreViewLeadingConstraint.constant = (appAverageScoreSlider.thumbCenterX - appAverageScoreView.bounds.midX)
        self.chartTopConstraint.constant = honeycombView.heightOfItem * 2
        self.currentUserScoreView.isHidden = false
    }
    
    func setInitialProgressView() {
        self.slider.setThumbImage(UIImage(), for: .normal)
        self.appAverageScoreSlider.setThumbImage(UIImage(), for: .normal)
        self.appAverageScoreView.isHidden = true
        self.currentUserScoreView.isHidden = true
    }
    
    @objc func rightShareBarButtonTapped(sender: UIBarButtonItem) {
        if isConnectedToNetwork() {
            self.setActivityIndicatorOnRightBarButton()
            DIWebLayerReportsAPI().shareActivityReport(success: { (message) in
                self.setShareAsRightBarButton()
                self.showAlert(message: message)
            }) { (error) in
                self.setShareAsRightBarButton()
                if let msg = error.message {
                    self.showAlert(message: msg)
                }
            }
        }
    }
    
    // MARK: Api Call
    private func getActivityLog() {
        if self.isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerReportsAPI().getUserReport(success: { (activityReport, challengesReport, goalsReport,graphData, othersGraph)  in
                self.hideLoader()
                self.totalActivityReport = activityReport
                self.challengesReport = challengesReport
                self.goalsReport = goalsReport
                self.graphData = graphData
                self.othersGraphData = othersGraph
                self.loadDataInUI()
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message)
            }
        }
    }
    
    // MARK: helpers
    private func loadDataInUI() {
        //show curve line graph
        /*        let dataEntries = generateRandomEntries()
///       curvedlineChart.dataEntries = dataEntries
//        curvedlineChart.isCurved = true
        self.honeycombView.screenType = .activityLog
        self.honeycombView.value = self.totalActivityReport?.totalActivityScore?.value
        self.honeycombView.reportFlag = self.totalActivityReport?.totalActivityScore?.flag
        self.honeycombView.setViewForActivityLog()
        
      if let myScore = self.totalActivityReport?.totalActivityScore?.value {
            self.setScoreOnSliderView(myScore: myScore, appAverageScore: self.totalActivityReport?.averageTotalActivityScore)
        }*/
        
        self.totalActivitiesCountLabel.text = "\(self.totalActivityReport?.totalActivities?.value?.toInt() ?? 0)"
        self.totalActivityTypesLabel.text = "\(self.totalActivityReport?.typesOfActivities?.count ?? 0)"
        self.averageCaloriesLabel.text = (totalActivityReport?.averageCalories?.value?.rounded(toPlaces: 2).formatted ?? "0")
        self.averageDistanceLabel.text = (totalActivityReport?.averageDistance?.value?.rounded(toPlaces: 2).formatted ?? "0")
        self.averageDailyStepsLabel.text = "\(totalActivityReport?.averageDailySteps?.value?.rounded().toInt() ?? 0)"
        self.averageDurationLabel.text = "\(totalActivityReport?.averageDuration?.value?.rounded().toInt() ?? 0)"
        self.accountAccountabilityLabel.text = (totalActivityReport?.accountAccountability?.value?.rounded(toPlaces: 2).formatted ?? "0") + "%"
        self.formatAndSetSleepTime()
        
        //setting colors according to stats
        self.setColorOf(label: totalActivitiesCountLabel, forFlag: totalActivityReport?.totalActivities?.flag)
        self.setColorOf(label: totalActivityTypesLabel, forFlag: totalActivityReport?.typesOfActivities?.flag)
        self.setColorOf(label: averageDailyStepsLabel, forFlag: totalActivityReport?.averageDailySteps?.flag)
        self.setColorOf(label: averageCaloriesLabel, forFlag: totalActivityReport?.averageCalories?.flag)
        self.setColorOf(label: averageDistanceLabel, forFlag: totalActivityReport?.averageDistance?.flag)
        self.setColorOf(label: averageDurationLabel, forFlag: totalActivityReport?.averageDuration?.flag)
        self.setColorOf(label: accountAccountabilityLabel, forFlag: totalActivityReport?.accountAccountability?.flag)
        self.setColorOf(label: averageSleepLabel, forFlag: totalActivityReport?.averageSleep?.flag)
        
        self.loadChallengesInfo()
        self.loadGoalInfo()
    }
    
    //change the color of label according to the flag status
    func setColorOf(label: UILabel, forFlag flag: ReportFlag?) {
        if let flag = flag {
            label.textColor = flag.color
        } else {
            label.textColor = ReportFlag.sameStats.color
        }
    }
    
    //format sleep time in hours, minutes and seconds and display
    func formatAndSetSleepTime() {
        let sleepTimeInHours = totalActivityReport?.averageSleep?.value ?? 0
        let sleepTimeInSeconds = sleepTimeInHours * 3600
        
        if let time = sleepTimeInSeconds.toInt() {
            let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: time)
            
            var formattedTime = ""
            if timeConverted.hours != 0 {
                formattedTime += "\(timeConverted.hours) hrs"
            }
            if timeConverted.minutes != 0 {
                if !formattedTime.isEmpty {
                    formattedTime += " "
                }
                formattedTime += "\(timeConverted.minutes) mins"
            }
            if timeConverted.seconds != 0 {
                if !formattedTime.isEmpty {
                    formattedTime += " "
                }
                formattedTime += "\(timeConverted.seconds) seconds"
            }
            
            if formattedTime.isEmpty {
                averageSleepLabel.text = "0"
            } else {
                averageSleepLabel.text = formattedTime
            }
        }
    }
    
    //set data in challenges view
    private func loadChallengesInfo() {
        self.totalChallengesLabek.text = "\(self.challengesReport?.total ?? 0)"
        self.wonChallengesLabel.text = "\(self.challengesReport?.won ?? 0)"
        self.completedChallengesLabel.text = "\(self.challengesReport?.completed ?? 0)"
        self.activeChallengesLabel.text = "\(self.challengesReport?.active ?? 0)"
     /*  / self.challengesCircleViewCountLabel.text = "\(self.challengesReport?.completed ?? 0)"
        self.challengesCircleViewCountLabel.layer.zPosition = 1 */
        
        var percent = 0.0
        if let total = challengesReport?.total,
            total != 0 {
            percent = self.getPercentageOfActivityCompletion(total: total, completed: challengesReport?.completed ?? 0)
        }
     //*   self.challengeProgressView.setCircleProgress(endValue: CGFloat(percent))
    }
    
    private func loadGoalInfo() {
        self.totalGoalsLabel.text = "\(self.goalsReport?.total ?? 0)"
        self.completedGoalsLabek.text = "\(self.goalsReport?.completed ?? 0)"
        self.activeGoalsLabel.text = "\(self.goalsReport?.active ?? 0)"
       /* / self.goalsCircleViewCountLabel.text = "\(self.goalsReport?.completed ?? 0)"
        self.goalsCircleViewCountLabel.layer.zPosition = 1*/
        
        var percent = 0.0
        if let total = goalsReport?.total,
            total != 0 {
            percent = self.getPercentageOfActivityCompletion(total: total, completed: goalsReport?.completed ?? 0)
        }
    /*   / self.goalsProgressView.setCircleProgress(endValue: CGFloat(percent))*/
    }
    
    private func getPercentageOfActivityCompletion(total: Int, completed: Int) -> Double {
        let percent: Double = Double(completed)/Double(total)
        return percent
    }
    
    /// show the challenges or the goals screen
    ///
    /// - Parameter showChallenges: true when to show challenges, false otherwise
    private func pushToGroupActivityScreen(showChallenges: Bool) {
        let viewController: ChallangeDashBoardController = UIStoryboard(storyboard: .challenge).initVC()
        if (showChallenges) {
            viewController.selectedSection = .challenge
        } else {
            viewController.selectedSection = .goal
        }
     //   viewController.isFromChallenge = showChallenges
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

