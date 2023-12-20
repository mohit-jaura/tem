//
//  WeightGoalDetailViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 25/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Charts
import SSNeumorphicView
import UIKit

final class WeightGoalDetailViewController: UIViewController, NSAlertProtocol, LoaderProtocol {

    // MARK: - IBOutlets
    @IBOutlet var navBarButtons: [UIButton]!
    @IBOutlet weak var navigationBarLineView: SSNeumorphicView! {
        didSet{
            navigationBarLineView.viewDepthType = .innerShadow
            navigationBarLineView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            navigationBarLineView.viewNeumorphicLightShadowColor = UIColor.appThemeDarkGrayColor.cgColor
            navigationBarLineView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            navigationBarLineView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet var containersBackViews: [SSNeumorphicView]!
    @IBOutlet weak var startWeightLbl: UILabel!
    @IBOutlet weak var endWeightLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var currentWeightLbl: UILabel!
    @IBOutlet weak var daysLeftLbl: UILabel!
    @IBOutlet weak var weightLeftLbl: UILabel!
    @IBOutlet var chartView: LineChartView!
    @IBOutlet weak var goalTrackerTitleLAbel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Properties
    var graphData:[Graph_]?
    var viewModal: WeightGoalDetailViewModal?
    var isHealthInfo = false
    var gncController: ChallangeDashBoardController?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
    }
    
    // MARK: - IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        gncController?.initializeData()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        let settingsVC: FoodTrekSettingsController = UIStoryboard(storyboard: .settings).initVC()
        settingsVC.screenFrom = .weightGoal
        self.present(settingsVC, animated: true)
    }
    @IBAction func addTapped(_ sender: UIButton) {
        let logVC: AddWeightLogViewController = UIStoryboard(storyboard: .weightgoaltracker).initVC()
        logVC.saveLogHandelr = { [weak self] weight in
            if !weight.isZero {
                self?.addWeightLog(weight: weight)
            }
            logVC.dismiss(animated: true)
        }
        logVC.healthType = self.viewModal?.modal?.healthInfoType?.data ?? 0
        self.navigationController?.present(logVC, animated: true)
    }
    // MARK: - Methods
    private func addShadowToButtons() {
        for button in navBarButtons {
            button.addDoubleShadowToButton(cornerRadius: button.frame.height / 2, shadowRadius: 0.4, lightShadowColor: UIColor.white.withAlphaComponent(0.1).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor: UIColor.appThemeDarkGrayColor)
        }
    }
    
    private func setOuterShadowView() {
        for view in containersBackViews {
            view.setOuterDarkShadow()
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            if view.tag == 11 { // 11 set statically for ADD button in storyboard
                view.viewNeumorphicCornerRadius = view.frame.height / 2
            }
        }
    }
    
    private func initUI() {
        addShadowToButtons()
        setOuterShadowView()
        getGoalDetails()
    }
    
    private func reloadGraphKit() {
        self.graphData = viewModal?.graphData ?? []
        self.loadDataInUI()
    }
    
    private func getGoalDetails() {
        self.showHUDLoader()
        viewModal?.isHealthInfo = self.isHealthInfo
        viewModal?.callGetWeightGoalDetailAPI { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal?.error {
                self?.showAlert(withMessage: error.message ?? "Can not get detail at the moment")
                return
            }
            self?.reloadUI()
        }
    }
    
    private func addWeightLog(weight: Double) {
        self.showHUDLoader()
        viewModal?.callAddWeightGoalLogAPI(isHealthInfo: self.isHealthInfo, weight: weight) { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal?.error {
                self?.showAlert(withMessage: error.message ?? "Can not add log at the moment")
                return
            }
            self?.getGoalDetails()
            self?.reloadGraphKit()
            self?.reloadWeightLogTableView()
        }
    }
    
    private func reloadUI() {
        if let modal = viewModal?.modal {

            startDateLbl.text = "\(modal.startMeasure?.date?.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? "")"
            endDateLbl.text = "\(modal.endMeasure?.date?.timestampInMillisecondsToDate.toString(inFormat: .displayDate) ?? "")"
            daysLeftLbl.text = "\(modal.daysLeft ?? 0) DAYS LEFT"
            currentWeightLbl.text = "\(modal.goalHelathUnits?.data ?? 0)"
            if modal.healthInfoType?.data != 0{
                goalTrackerTitleLAbel.text = "\(HealthInfoType(rawValue: (modal.healthInfoType?.data ?? 0) - 1)?.getTitle().uppercased() ?? "") GOAL TRACKER"
                weightLeftLbl.text = "\(modal.goalLeft ?? 0) \(HealthInfoType(rawValue: (modal.healthInfoType?.data ?? 0) - 1)?.getUnitType() ?? "") LEFT"
                endWeightLbl.text = "\(modal.goalHelathUnits?.data ?? 0)"
              currentWeightLbl.text = "\(modal.currentHealthUnits?.data ?? 0)"
                startWeightLbl.text = "\(modal.startMeasure?.currentHealthUnits ?? 0)"
            } else{
                startWeightLbl.text = "\(modal.startMeasure?.weight?.rounded(toPlaces: 1) ?? 0.0)"
                currentWeightLbl.text = "\(modal.currentMeasure?.weight?.rounded(toPlaces: 1) ?? 0.0)"
                endWeightLbl.text = "\(modal.endMeasure?.weight?.rounded(toPlaces: 1) ?? 0.0)"
                weightLeftLbl.text = "\(modal.weightLeft?.rounded(toPlaces: 2) ?? 0.0) LBS LEFT"
            }
            reloadWeightLogTableView()
            reloadGraphKit()
        }
    }
    
    private func reloadWeightLogTableView() {
        if viewModal?.modal?.weightLogs?.count ?? 0 > 0 || viewModal?.modal?.healthLogs?.count ?? 0 > 0{
            self.tableView.showEmptyScreen("")
            self.tableView.reloadData()
        } else {
            self.tableView.showEmptyScreen("No records found!")
        }
    }
    private func loadDataInUI() {
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.chartDescription?.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont(name: UIFont.avenirNextMedium, size: 10) ?? UIFont.systemFont(ofSize: 10)
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.drawBordersEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.highlightPerTapEnabled = false
        setDataCount(graphData?.count ?? 0, range: graphData?.reversed() ?? [Graph_]())
    }
    func setDataCount(_ count: Int, range: [Graph_]) {
        var lineChartEntry  = [ChartDataEntry]()
        var labels: [String] = []
        //here is the for loop
        if viewModal?.modal?.healthInfoType?.data != 0{
            lineChartEntry.append(ChartDataEntry(x: 0.0, y: Double(viewModal?.modal?.currentHealthUnits?.data ?? 0)))
        } else{
            lineChartEntry.append(ChartDataEntry(x: 0.0, y: viewModal?.modal?.startMeasure?.weight ?? 0.0))
        }
        for i in 0..<range.count {
            if i % 7 == 0 || i == 0{
                let value = ChartDataEntry(x: Double(i+1), y: range[i].score ?? 0.0)
                lineChartEntry.append(value)
                labels.append(range[i].date ?? "")
            }
        }
        if viewModal?.modal?.healthInfoType?.data != 0{
            lineChartEntry.append(ChartDataEntry(x: Double(viewModal?.graphData?.count ?? 0), y: Double(viewModal?.modal?.goalHelathUnits?.data ?? 0)))
        } else{
            lineChartEntry.append(ChartDataEntry(x: Double(viewModal?.graphData?.count ?? 0), y: viewModal?.modal?.endMeasure?.weight ?? 0.0))
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: nil)
        line1.colors = [NSUIColor(0xF126A5)]
        line1.mode = .cubicBezier
        line1.lineWidth = 2.0
        line1.drawCirclesEnabled = true
        line1.circleRadius = CGFloat(4.0)
        line1.valueColors = [UIColor.white]
        line1.circleColors = [NSUIColor(0xF126A5)]
        line1.drawCircleHoleEnabled = false
        line1.drawValuesEnabled = false ///for removing the values on line
        
        let data = LineChartData()
        data.addDataSet(line1) //Adds the line to the dataSet
        chartView.legend.form = .none
        chartView.xAxis.labelTextColor = .white
        
        let customFormater = CustomFormatter()
        customFormater.labels = labels
        chartView.xAxis.valueFormatter = customFormater
        chartView.xAxis.setLabelCount(range.count, force: true)
        chartView.xAxis.centerAxisLabelsEnabled = true
        chartView.data = data
    }
}
