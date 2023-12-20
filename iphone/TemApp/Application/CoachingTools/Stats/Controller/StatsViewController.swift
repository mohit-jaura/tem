//
//  StatsViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 13/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import Charts


class StatsViewController: UIViewController,NSAlertProtocol, LoaderProtocol {
    
    enum StatsMetrics: Int, CaseIterable{
        case activityScore = 1
        case accountabilityIndex
        case totalActivities
        case fGTracker
    }
    
    enum SliceType: Int,CaseIterable{
        case physicalFitness = 1
        case nutrition
        case sports
        case lifestyle
        case mentalStrength
    }
    
    var statsVM = StatsViewModal()
    var selectedCategory = 0
    var selectedIndexs = [Int]()
    
    // MARK: IBOutlets
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var ratingButtons: [UIButton]!
    @IBOutlet var metricsBgView: [UIView]!
    @IBOutlet var categoryColorViews: [UIView]!
    @IBOutlet var statsValueLabel: [UILabel]!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var categoryTypeStackView: UIStackView!
    // MARK: Variables
    var ratingData:RatingData?
    var isEditAble:Bool = false
    var selectedRateActivityNumber: Int = 0
    let selectedRatingImg = "star"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializer()
    }
    
    // MARK: Helper functions
    func initializer(){
        self.showHUDLoader()
        pieChartView.delegate = self
        for view in metricsBgView{
            view.cornerRadius = view.frame.height / 2
            view.borderWidth = 2
            view.borderColor = UIColor.appCyanColor
        }
        for view in categoryColorViews{
            view.cornerRadius = view.frame.height / 2
        }
        saveButton.cornerRadius = saveButton.frame.height / 2
        saveButton.borderWidth = 2
        saveButton.borderColor = UIColor.appCyanColor
        getRatingData()
        todayDateLabel.text = Date().UTCToLocalString(inFormat: .coachingTools).uppercased()
        tableView.registerNibs(nibNames: [StatsActivitiesTableCell.reuseIdentifier])
        getstatsData()
    }
    
    func getstatsData(){
        self.showHUDLoader()
        statsVM.getStatsData{[weak self] in
            self?.hideHUDLoader()
            if let error = self?.statsVM.error{
                self?.showAlert(withMessage: error.message ?? "")
            } else{
                if self?.statsVM.statsData?.totalActivities.value ?? 0 > 0{
                    self?.setStatsData()
                    self?.setPieChartData()
                    self?.tableView.showEmptyScreen("", isWhiteBackground: false)
                    self?.tableView.reloadData()
                } else{
                    self?.tableView.showEmptyScreen("No activities available")
                    self?.tableView.tableHeaderView?.frame.size.height = 0
                }
            }
        }
        
    }
    
    func setStatsData(){
        for label in statsValueLabel{
            switch StatsMetrics(rawValue: label.tag){
                case .activityScore:
                    label.text = "\(statsVM.statsData?.totalActivityScore.value ?? 0)"
                case .accountabilityIndex:
                    label.text = "\(statsVM.statsData?.activityAccountability.value ?? 0)"
                case .totalActivities:
                    label.text = "\(statsVM.statsData?.totalActivities.value ?? 0)"
                case .fGTracker:
                    label.text = "\(statsVM.statsData?.foodTrack?.value ?? 0)"
                case .none:
                    break
            }
        }
    }
    func setPieChartData(){
        let colors = [#colorLiteral(red: 0, green: 0.7137254902, blue: 1, alpha: 1), #colorLiteral(red: 0.7960784314, green: 0, blue: 0.8431372549, alpha: 1), #colorLiteral(red: 1, green: 0.7019607843, blue: 0, alpha: 1), #colorLiteral(red: 0.4274509804, green: 0.831372549, blue: 0, alpha: 1), #colorLiteral(red: 0.3843137255, green: 0.2117647059, blue: 1, alpha: 1)]
        var selectedColors = [UIColor]() // according to activities
        var value = [Double]()
        for val in 0 ..< (statsVM.statsData?.activityCategory?.count ?? 0) {
            let percentageValue = statsVM.statsData?.activityCategory?[val].percantageValue ?? 0.0
            if percentageValue != 0.0{
                value.append((percentageValue))
                selectedIndexs.append(val)
                selectedColors.append(colors[val])
            }
        }
        selectedCategory = selectedIndexs[0]
        if statsVM.statsData?.totalActivities.value ?? 0 > 0{
            configureChartView(pieChartView: self.pieChartView, values: value, colors: selectedColors)
            categoryTypeStackView.isHidden = false
        } else{
            pieChartView.clear()
            categoryTypeStackView.isHidden = true
        }
    }
    
    func configureChartView(pieChartView: PieChartView, values: [Double], colors: [UIColor]) {
        pieChartView.drawSlicesUnderHoleEnabled = false
        var dataEntries = [ChartDataEntry]()
        for data in 0..<values.count {
            let dataEntry = PieChartDataEntry(value: values[data], label: "")
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        pieChartDataSet.selectionShift = 2
        pieChartDataSet.colors = colors
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1
        formatter.percentSymbol = "%"
        
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        pieChartView.data = pieChartData
        pieChartView.holeColor = .black
        pieChartView.chartDescription?.text = ""
        pieChartView.legend.enabled = false
        pieChartView.drawEntryLabelsEnabled = false
        
        pieChartView.holeRadiusPercent = 0.5
        pieChartView.highlightPerTapEnabled = true
        pieChartView.highlightValue(x: 1, dataSetIndex: 1)
        
        //        pieChartView.animate(yAxisDuration: 2.0, easingOption: .easeInCirc)
    }
    
    private func callUpdateRatingAPI() {
        var params:[String:Any] = [:]
        params["rating"] = selectedRateActivityNumber
        params["_id"] = self.ratingData?.id
        params["quote"] = ""
        DIWebLayerJournalAPI().updateJournal(parameters: params) { _ in
            self.hideHUDLoader()
            self.showAlert(withMessage: AppMessages.RateDay.ratingUpdated)
            self.getRatingData()
        } failure: { error in
            self.hideHUDLoader()
            if let message = error.message {
                self.showAlert(withMessage: message)
            }
        }
    }
    private func getRatingData(){
        DIWebLayerActivityAPI().getRating(completion: { data in
            if data.rating != nil{
                self.isEditAble = true
            }
            self.ratingData = data
            self.configureViewForRatingDetails(data: data)
            
        }, failure: { error in
            print(error.message)
        })
    }
    private func configureViewForRatingDetails(data:RatingData) {
        selectedRateActivityNumber = data.rating ?? 0
        for button in ratingButtons{
            if button.tag <= selectedRateActivityNumber {
                button.setBackgroundImage(UIImage(named: selectedRatingImg), for: .normal)
            } else {
                button.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
            }
        }
    }
    func configureRateActivityLayouts(selectedButton: UIButton) {
        selectedRateActivityNumber = selectedButton.tag
        for button in ratingButtons{
            if button.tag <= selectedRateActivityNumber {
                button.setBackgroundImage(UIImage(named: selectedRatingImg), for: .normal)
            } else {
                button.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
            }
        }
    }
    func saveRating(){
        var paramerter:[String:Any] = [:]
        paramerter["rating"] = selectedRateActivityNumber
        paramerter["quote"] = ""
        DIWebLayerJournalAPI().createJournal(parameters: paramerter) { _ in
            self.hideHUDLoader()
            self.getRatingData()
            self.showAlert(withMessage: AppMessages.RateDay.ratingAdded)
        } failure: { error in
            self.hideHUDLoader()
            if let message = error.message {
                self.showAlert(withMessage: message)
            }
        }
    }
    @IBAction func saveRatingTapped(_ sender: UIButton) {
        if isEditAble {
            self.showHUDLoader()
            self.callUpdateRatingAPI()
        } else {
            if selectedRateActivityNumber != nil{
                self.hideHUDLoader()
                self.saveRating()
            } else{
                self.showAlert(withTitle:AppMessages.RateDay.RatingMsg , message: AppMessages.RateDay.selectRating)
            }
        }
    }
    @IBAction func rateActivityButtonsTapped(_ sender: UIButton) {
        self.configureRateActivityLayouts(selectedButton: sender)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

