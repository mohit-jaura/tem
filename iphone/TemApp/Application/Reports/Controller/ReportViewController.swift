//
//  ReportViewController.swift
//  TemApp
//
//  Created by shilpa on 22/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Charts
import SSNeumorphicView
import RealmSwift

class ReportViewController: DIBaseController {

    // MARK: Properties
    var report: UserActivityReport?
    private var totalScore: Double?
    @IBOutlet weak var activityLogShadowView:  UIView!
    @IBOutlet weak var activityMetricsShadowView: UIView!
    @IBOutlet weak var streaksShadowView:  UIView!
    @IBOutlet weak var trophyCaseShadowView: UIView!
    @IBOutlet weak var journalShadowView:  UIView!
    private var healthradar: HealthRadar?
    private let topScore: Double = 100
    private var graphData:[Graph_]?
    private var othersGraphData:[Graph_]?
    @IBOutlet weak var curvedlineChart: LineChart!
    private let initialRadarLoadMsg = "Your balanced health radar is being loaded. Please wait."
    private var navBar: NavigationBar?

    // MARK: IBOutlets
    @IBOutlet var radarParamsCollection: [UILabel]!
    @IBOutlet weak var grayHoneyComb: UIImageView!
    @IBOutlet weak var blueHoneyComb: UIImageView!
    @IBOutlet weak var radarLegendsView: UIStackView!
    @IBOutlet weak var radarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var radarErrorLabel: UILabel!
    @IBOutlet weak var activityScoreLabel: UILabel!


    var rightInset: CGFloat = 25

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var chartView: LineChartView!
    @IBOutlet weak var radarView: UIView!
    @IBOutlet weak var radarChartView: RadarChartView!
    private var goalsReport: GroupActivityReport?
    var accountabilityIndex1:Int = 30
    // MARK: IBActions
    @IBAction func haisInfoViewTapped(_ sender: UIButton) {
        self.presentInfoPopOver(type: .hais)
    }
    @IBOutlet var circularViews: [CustomView]!

    @IBOutlet weak var accountabilityScoreLbl: UILabel!
    func addNeumorphicShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius: CGFloat, shadowRadius: CGFloat , opacity: Float, darkColor: CGColor, lightColor: CGColor, offset: CGSize){
        view.viewDepthType = shadowType
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicMainColor = UIColor.black.cgColor

        view.viewNeumorphicShadowOpacity = opacity
        view.viewNeumorphicDarkShadowColor =  darkColor
        view.viewNeumorphicShadowOffset = offset
        view.viewNeumorphicLightShadowColor = lightColor
    }
    @IBOutlet weak var indexGradientView: UIView!

    @IBAction func activitylogTapped(_ sender: UIButton) {
        let activityLogVC: ActivityLogNewViewController = UIStoryboard(storyboard: .reports).initVC()
        self.navigationController?.pushViewController(activityLogVC, animated: true)
    }
    @IBAction func activityMetricsTapped(_ sender: UIButton) {
        let activityMetricsController: ActivityMetricsViewController = UIStoryboard(storyboard: .reports).initVC()
        self.navigationController?.pushViewController(activityMetricsController, animated: true)
    }

    @IBAction func historyNotesTapped(_ sender: UIButton) {
        let historyVC: HistoryNotesListController = UIStoryboard(storyboard: .coachingTools).initVC()
        self.navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @IBAction func journalTapped(_ sender: UIButton) {
        let activityMetricsController: JournalListingViewController = UIStoryboard(storyboard: .journal).initVC()
        self.navigationController?.pushViewController(activityMetricsController, animated: true)
    }

    @IBAction func onClickTrophy(_ sender:UIButton)  {
        self.showAlert(withTitle: "Coming Soon!", message: nil, okayTitle: "Ok", cancelTitle: nil, okStyle: .default)
    }

    @IBAction func onClickStreaks(_ sender:UIButton)  {
        self.showAlert(withTitle: "Coming Soon!", message: nil, okayTitle: "Ok", cancelTitle: nil, okStyle: .default)
    }


    func removeSublayer(gradientLayer: CAGradientLayer, view: UIView?){
        gradientLayer.name = "gradientLayer"
        let sublayers: [CALayer]? = view?.layer.sublayers
        if let layeers = sublayers{
            for layer in  layeers{
                if layer.name == "gradientLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }

    @IBOutlet weak var indexViewInnerShadow: SSNeumorphicView!{
        didSet{
            addNeumorphicShadow(view: indexViewInnerShadow, shadowType: .innerShadow, cornerRadius: 4, shadowRadius: 0.4, opacity:  0.3, darkColor:  UIColor.black.cgColor, lightColor: UIColor.black.cgColor, offset: CGSize(width: -2, height: -2))
        }
    }

    @IBOutlet weak var indexSuperviewInnerShadow: SSNeumorphicView!{
        didSet{
            addNeumorphicShadow(view: indexSuperviewInnerShadow, shadowType: .outerShadow, cornerRadius: 4, shadowRadius: 0.4, opacity:  0.3, darkColor:  #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5), lightColor: UIColor.black.cgColor, offset: CGSize(width: 2, height: 2))
        }
    }

    @IBAction func radarInfoTapped(_ sender: UIButton) {
        //        self.presentInfoPopOver(type: .radar)

        let popverVC: CalendarPopupViewController = UIStoryboard(storyboard: .dashboard).initVC()
        popverVC.contentText = """
    This is a color-coded representation of how balanced each area of health is in relation to your other areas. It captures six major categories: Social, Medical, Physical Activity, Mental, Nutrition and Cardiovascular. As you engage with the app you will begin to fill the blue honeycomb with green from the middle out.
    """
        self.present(popverVC, animated: true, completion: nil)
    }

    @IBAction func lockHoneyCombTapped(_ sender: UIButton) {
        let healthInfoVC:MyHealthInfoViewController = UIStoryboard(storyboard: .profile).initVC()
        healthInfoVC.totalScore = self.totalScore
        self.navigationController?.pushViewController(healthInfoVC, animated: true)
    }

    @IBOutlet weak var dView: UIView!
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.createUserExperience()
        curvedlineChart.backgroundColor = .black

        //        curvedlineChart.x
        //        setScore(value: 100, withAnimation: true)
        getReportsDataFromRealm()
        dropGradient()
    }
    private func dropGradient(){
        for view in circularViews{
            view.cornerRadius = view.frame.size.height / 2
            switch view.tag {
                case 1:
                    view.addGradient(color: #colorLiteral(red: 0.01960784314, green: 1, blue: 0, alpha: 1))
                case 2:
                    view.addGradient(color: #colorLiteral(red: 0.3796130419, green: 0.9169438481, blue: 0.8876199126, alpha: 1))
                case 3:
                    view.addGradient(color:   #colorLiteral(red: 0.9960784314, green: 0, blue: 0.7921568627, alpha: 1))
                default:
                    break
            }

        }
    }
    private func getupperCasedDate(date:Date) -> String{
        let dateString = date.toString(inFormat: .chatDate) ?? ""
        let upperCasedDate = dateString.uppercased()
        return upperCasedDate
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getMyReportData()
        if self.healthradar == nil {
            handleErrorOnRadarView(errorMessage: initialRadarLoadMsg)
        }
        DispatchQueue.global(qos: .background).async {
            self.getTotalScoreOfUser()
            self.getRadarScoreFromServer()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // self.removeBadgeObserver()
    }

    // MARK: Initializers

    override func navigationBar(_ navigationBar: NavigationBar, rightButtonTapped rightButton: UIButton) {
        switch navigationBar.rightAction[rightButton.tag] {
        case .search:
            rightBarSearchButtonTapped()
        default:
            break
        }
    }


    /// Display error message on radar view
    ///
    /// - Parameter errorMessage: error message to display
    private func handleErrorOnRadarView(errorMessage: String) {
        if self.healthradar == nil {
            DispatchQueue.main.async {
                self.radarChartView.isHidden = true
                //  self.blueHoneyComb.isHidden = true
                self.grayHoneyComb.isHidden = true
                self.radarErrorLabel.isHidden = false
                self.radarErrorLabel.text = errorMessage
            }
        }
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    private func resetRadarView() {
        DispatchQueue.main.async {
            self.radarChartView.isHidden = false
            // self.blueHoneyComb.isHidden = false
            self.grayHoneyComb.isHidden = false
            self.radarErrorLabel.isHidden = true
            self.radarErrorLabel.text = ""
        }
    }

    private func addShadowTo(view: UIView) {

        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        view.layer.shadowRadius = 5.0
    }

    @objc func leftMenuButtonTapped(sender: UIBarButtonItem) {
        self.presentSideMenu()
    }

    private func rightBarSearchButtonTapped() {
        let searchVC: SearchViewController = UIStoryboard(storyboard: .search).initVC()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }

    func removePopOverIfAny() {
        if let presented = self.presentedViewController as? MessagePopOverViewController {
            presented.dismiss(animated: false, completion: nil)
        } else if let presented = self.presentedViewController as? ActivityScoreInfoViewController {
            presented.dismiss(animated: false, completion: nil)
        }
    }

    private func getReportsDataFromRealm() {
        let reportViewModal = ReportViewModal()
        reportViewModal.getAlreadySavedReports()
        reportViewModal.getAlreadySavedHaisScore()

        self.accountabilityScoreLbl.text = "\(Int(reportViewModal.accountAccountability ?? 0))%"
        self.setHaisScore(value: reportViewModal.haisResult?.first?.sum ?? 0.0)
        self.setActivityScore(value: reportViewModal.totalActivityScore ?? 0.0)
        self.graphData = reportViewModal.graphData ?? []
        self.othersGraphData = reportViewModal.othersGraphData ?? []

       self.loadDataInUI()
    }

    // MARK: Notification observers
    func addBadgeObserver() {
        self.removeBadgeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeNotificationRead), name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUnreadNotificationsCount), name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }

    private func removeBadgeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notificationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.applicationEnteredFromBackground, object: nil)
    }

    @objc func updateBadgeNotificationRead() {
        self.navBar?.displayBadge(unreadCount: UserManager.getCurrentUser()?.unreadNotiCount)
    }

    // MARK: Api call
    @objc func getUnreadNotificationsCount() {
        DIWebLayerNotificationsAPI().getUnreadNotificationsCount { (count,id) in
            self.navBar?.displayBadge(unreadCount: count)
        }
    }

    func setActivityScore(value: Double) {
        DispatchQueue.main.async {
            self.activityScoreLabel.text = "\(value)"

        }
    }

    func getMyReportData() {
        if isConnectedToNetwork() {
            DIWebLayerReportsAPI().getUserReport(success: { (report, _, _, graphData, othersGraph) in
                self.hideLoader()
                self.report = report
                self.graphData = graphData
                self.othersGraphData = self.othersGraphData
              self.loadDataInUI()
                self.accountabilityScoreLbl.text = "\(Int(report.accountAccountability?.value ?? 0))"
           ///     self.setGradientBackground()
                self.setActivityScore(value: report.totalActivityScore?.value ?? 0.0)
                DispatchQueue.main.async {
                    //  self.updateUserInterface(reportInfo: report)
                }
            }) { (error) in
                self.hideLoader()
                if let rootviewController = UIApplication.shared.keyWindow?.rootViewController,
                   rootviewController.isKind(of: ReportViewController.self) {
                    self.showAlert(message: error.message)
                }
            }
        } else {
            self.hideLoader()
        }
    }

    private func loadDataInUI() {
        //show curve line graph
        let dataEntries = generateRandomEntries()
//        self.graphData = graphData?.sorted(by: {
//            $0.date ??  "" < $1.date ?? ""
//        })
//        self.othersGraphData = othersGraphData?.sorted(by: {
//            $0.date ?? "" < $1.date ?? ""
//        })

        DispatchQueue.main.async {
            self.curvedlineChart.dataEntries = dataEntries
            self.curvedlineChart.isCurved = true
        }
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.chartDescription?.enabled = false
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.drawAxisLineEnabled = true
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.drawBordersEnabled = false
        chartView.xAxis.gridLineDashLengths = [6,6]

        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.highlightPerTapEnabled = false

//        chartView.xAxis.axisMinimum = -0.5;
//        chartView.xAxis.axisMaximum = Double(graphData?.count ?? 0) - 0.5;

        setDataCount(graphData?.count ?? 0, range: graphData?.reversed() ?? [Graph_](), othersRAnge: othersGraphData?.reversed() ?? [Graph_]())
    }



    func setDataCount(_ count: Int, range: [Graph_], othersRAnge: [Graph_]) {

        var lineChartEntry  = [ChartDataEntry]()
        var lineChartEntry2  = [ChartDataEntry]()

        for value in 0..<range.count {
           if value % 7 == 0 || value == 0{
               let value = ChartDataEntry(x: Double(value), y: range[value].score ?? 0.0)
                lineChartEntry.append(value)
          }
        }
        for value in 0..<othersRAnge.count {
      if value % 7 == 0 || value == 0{
                let value = ChartDataEntry(x: Double(value), y: othersRAnge[value].score ?? 0.0)
                lineChartEntry2.append(value)
         }
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "YOU")
        line1.colors = [NSUIColor.blue]
        line1.valueColors = [UIColor.white]

        let data = LineChartData()
        let line2 = LineChartDataSet(entries: lineChartEntry2, label: "AVG")
        line2.colors = [#colorLiteral(red: 0.370034039, green: 0.9103531241, blue: 0.8078178763, alpha: 1)]
        line2.fillAlpha = 1
        line2.fillColor = .black
        line2.fillFormatter = DefaultFillFormatter { _,_  -> CGFloat in
            return CGFloat(self.chartView.leftAxis.axisMaximum )
        }

        setLinesProperties(line: line1)
        setLinesProperties(line: line2)
        addGradientUnderLine(line: line1)
        data.addDataSet(line2)
        data.addDataSet(line1)
        chartView.legend.textColor = .white
        chartView.xAxis.labelTextColor = .white
        let customFormater = CustomFormatter()
    //    customFormater.labels = ["1","2","3","4","7"]//,"5","6","7","8","9","10"]
        customFormater.labels = ["-21","","","-14","", "","-7", "","","TODAY"]
        chartView.xAxis.valueFormatter = customFormater
//        chartView.xAxis.granularity = 1.0
//        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.setLabelCount(10, force: true)
        chartView.data = data
    }
    private func setLinesProperties(line:LineChartDataSet){
        line.mode = .cubicBezier
        line.lineWidth = 4.0
        line.drawCirclesEnabled = false
        line.drawValuesEnabled = false
    }

    private func addGradientUnderLine(line:LineChartDataSet){
        let gradientColors = [UIColor.cyan.cgColor, UIColor.clear.cgColor] as CFArray
        let colorsLocations: [CGFloat] = [0.7, 0.0]
        let gradients = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorsLocations)!
        line.fill = Fill.fillWithLinearGradient(gradients, angle: 90.0)
        line.drawFilledEnabled = true
    }

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

    func setHaisScore(value: Double) {
        self.totalScore = value
        DispatchQueue.main.async {
            self.scoreLabel.text = "\(value.rounded(toPlaces: 2))"

        }
    }
    func getTotalScoreOfUser() {
        DIWebLayerUserAPI().getHAISTotalScore(completion: { (value) in
            self.setHaisScore(value: value)
        }) { (error) in
            DILog.print(items: error.message ?? "There was some error fetching score")
        }
    }

    private func getRadarScoreFromServer() {
        if Reachability.isConnectedToNetwork() {
            DIWebLayerReportsAPI().getRadarScore(completion: { (radar) in
                self.healthradar = radar
                self.resetRadarView()
                self.setChartData()
            }) { (error) in
                self.handleErrorOnRadarView(errorMessage: error.message ?? "There was some error loading your health radar.")
            }
        } else {
            self.handleErrorOnRadarView(errorMessage: AppMessages.AlertTitles.noInternet)
        }
    }

    // MARK: Helpers
    //    private func updateUserInterface(reportInfo: UserActivityReport) {
    //        self.reportHoneyCombView.setValuesInViews(reportInfo: reportInfo)
    //    }

    /// present pop over info screen
    /// - Parameter type: Message pop over type
    private func presentInfoPopOver(type: MessagePopOverType) {
        let infoController: MessagePopOverViewController = UIStoryboard(storyboard: .reports).initVC()
        infoController.popOverType = type
        self.navigationController?.present(infoController, animated: true, completion: nil)
    }
}

// MARK: ReportsHoneyCombDelegate
extension ReportViewController: ReportsHoneyCombDelegate {
    func contentViewDidSetToFullHeight(value: CGFloat) {
        DispatchQueue.main.async {
        //    self.reportsViewHeightConstraint.constant = value
        }
    }

    func didClickOnActivityLogHoneyComb() {
        if self.isConnectedToNetwork() {
            let activityMetricsController: ActivityMetricsViewController = UIStoryboard(storyboard: .reports).initVC()
            self.navigationController?.pushViewController(activityMetricsController, animated: true)
        }
    }

    func didClickOnTotalActivitiesHoneyComb() {
        if self.isConnectedToNetwork(),
           let totalActivities = self.report?.totalActivities?.value,
           let intValue = totalActivities.toInt(),
           intValue > 0 {
            let totalActivitiesController: TotalActivitiesViewController = UIStoryboard(storyboard: .reports).initVC()
            totalActivitiesController.totalCount = intValue
            totalActivitiesController.flag = report?.totalActivities?.flag
            self.navigationController?.pushViewController(totalActivitiesController, animated: true)
        }
    }
}

// MARK: Radar
extension ReportViewController {

    private func setChartData() {
        let userScoreSet = RadarChartDataSet(entries:
                                                [
                                                    RadarChartDataEntry(value: healthradar?.socialScore?.formatToMax(value: topScore) ?? 0),
                                                    RadarChartDataEntry(value: healthradar?.medicalScore?.formatToMax(value: topScore) ?? 0),
                                                    RadarChartDataEntry(value: healthradar?.physicalActivityScore?.formatToMax(value: topScore) ?? 0),
                                                    RadarChartDataEntry(value: healthradar?.mentalScore?.formatToMax(value: topScore) ?? 0),
                                                    RadarChartDataEntry(value: healthradar?.nutritionScore?.formatToMax(value: topScore) ?? 0),
                                                    RadarChartDataEntry(value: healthradar?.cardiovascularScore?.formatToMax(value: topScore) ?? 0),
                                                ]
        )
        let topValueSet = RadarChartDataSet(entries:
                                                [
                                                    RadarChartDataEntry(value: topScore),
                                                    RadarChartDataEntry(value: topScore),
                                                    RadarChartDataEntry(value: topScore),
                                                    RadarChartDataEntry(value: topScore),
                                                    RadarChartDataEntry(value: topScore),
                                                    RadarChartDataEntry(value: topScore),
                                                ]
        )
        let xAxis = radarChartView.xAxis
        xAxis.labelFont = UIFont(name: UIFont.robotoRegular, size: 9) ?? .systemFont(ofSize: 9, weight: .light)
        xAxis.labelTextColor = .white
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = XAxisFormatter()
        xAxis.labelTextColor = .clear//.textBlackColor
        xAxis.drawLabelsEnabled = true

        let yAxis = radarChartView.yAxis
        yAxis.labelFont = UIFont(name: UIFont.robotoRegular, size: 5) ?? .systemFont(ofSize: 9, weight: .light)
  //      yAxis.labelTextColor = .white
        yAxis.labelCount = 3
        yAxis.drawTopYLabelEntryEnabled = true
        yAxis.axisMinimum = 0
        yAxis.forceLabelsEnabled = true //this is to force the maximum y layers to be equal to label count
        yAxis.valueFormatter = YAxisFormatter()
        yAxis.labelTextColor = .textBlackColor

        radarChartView.webColor = .white//UIColor(red: 149/255, green: 147/255, blue: 144/255, alpha: 1.0)
        radarChartView.innerWebColor = .gray//UIColor(red: 149/255, green: 147/255, blue: 144/255, alpha: 1.0)
        radarChartView.innerWebLineWidth = 1
        radarChartView.webLineWidth = 1.5
        radarChartView.legend.enabled = false
        radarChartView.rotationEnabled = false

  //      setRadarDataEntriesProperties(dataSet: userScoreSet, fillColor: UIColor(red: 59/255, green: 127/255, blue: 34/255, alpha: 1.0), borderColor: UIColor(red: 90/255, green: 188/255, blue: 104/255, alpha: 1.0))
        setRadarDataEntriesProperties(dataSet: userScoreSet, fillColor:  #colorLiteral(red: 0.1568627451, green: 0.7098039216, blue: 0.8823529412, alpha: 0.1), borderColor:    #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1))

        topValueSet.fillAlpha = 0.9
        let data = RadarChartData(dataSets: [userScoreSet])
        radarChartView.data = data
    }

    private func setRadarDataEntriesProperties(dataSet: RadarChartDataSet, fillColor: UIColor, borderColor: UIColor) {
        dataSet.setColor(borderColor)
        dataSet.fillColor = fillColor
        dataSet.drawFilledEnabled = true
        dataSet.fillAlpha = 0.7
        dataSet.lineWidth = 3
        dataSet.drawHighlightCircleEnabled = true
        dataSet.setDrawHighlightIndicators(false)
        dataSet.valueFormatter = DataSetValueFormatter()
        dataSet.formLineDashLengths = [5]
    }
}

// MARK: Value Formatter
class XAxisFormatter: IAxisValueFormatter {

    let titlesArr = [Constant.RadarMetrics.social, Constant.RadarMetrics.medical, Constant.RadarMetrics.physicalActivity, Constant.RadarMetrics.mental, Constant.RadarMetrics.nutrition, Constant.RadarMetrics.cardiovascular]
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return titlesArr[Int(value) % titlesArr.count]//.uppercased()
    }
}
class YAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return ""//"\(value)"
    }
}

class DataSetValueFormatter: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return ""
    }
}

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}


final class CustomFormatter: IAxisValueFormatter {

    var labels: [String] = [] // ["-21","-14", "-7","TODAY"]//
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let count = self.labels.count

        guard let axis = axis, count > 0 else {
            return ""
        }
        let factor = axis.axisMaximum / Double(count)

        let index = Int((value / factor).rounded())

        if index >= 0 && index < count {
                return self.labels[index]
       }
        return ""
    }
}
