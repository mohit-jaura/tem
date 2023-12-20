//
//  HAISViewController.swift
//  TemApp
//
//  Created by shilpa on 07/11/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

struct NutritionPercent {
    var id: String
    var value: String
    
    init(id: String, value: String) {
        self.id = id
        self.value = value + "%"
    }
}
struct TrackingNutrition {
    var id: String
    var value: String
    
    init(id: String, value: String) {
        self.id = id
        self.value = value
    }
}

protocol HaisDelegate: AnyObject {
    func onClickOfPanel(isSelected: Bool)
}
class HAISViewController: DIBaseController {
    
    // MARK: Properties
    var generalFieldsDataArray = [InputFieldTableCellViewModel]()
    var selfAssessmentFieldsDataArray = [InputFieldTableCellViewModel]()
    var comprehensiveFieldsDataArray = [InputFieldTableCellViewModel]()
    private var isPanelSelected = false
    private var healthData: HealthData?
    final private var isPercentagesLoaded = false
    final private var nutritionPercents = [NutritionPercent]()
    var totalScore: Double?
    final private var isLoadedFromServer = false
    var isFromProfile = false
    var delegate: HaisDelegate?
    
    
    
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scoreLaebel: UILabel!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var haisOuterShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowViewNew(view: haisOuterShadowView, shadowType: .outerShadow, cornerRadius: haisOuterShadowView.frame.width / 2, shadowRadius: 0.2)
            haisOuterShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            haisOuterShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    
    @IBOutlet weak var haisInnerShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowViewNew(view: haisInnerShadowView, shadowType: .innerShadow, cornerRadius: haisInnerShadowView.frame.width / 2, shadowRadius: 0.2)
            haisInnerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            haisInnerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    
    @IBOutlet weak var saveButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowViewNew(view: saveButtonShadowView, shadowType: .outerShadow, cornerRadius: saveButtonShadowView.frame.width / 2, shadowRadius: 0.5)
        }
    }
    
    @IBOutlet weak var saveButtonGradientView:GradientDashedLineCircularView!{
        didSet{
            self.createGradientView(view: saveButtonGradientView)
        }
    }
    
    // MARK: IBActions
    @IBAction func submitTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.updateHealthData()
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
        initializeUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLoadedFromServer {
            self.setBodyMassIndex()
            self.tableView.reloadData()
        }
        DispatchQueue.global(qos: .background).async {
            self.getTotalScoreOfUser()
        }
    }
    
    // MARK: View Setup
    func configureNavigation() {
        if !isFromProfile {
            navigationBarHeight.constant = 45
            _ = configureNavigtion(onView: self.navigationBarView, title: "HAIS".localized, showBottomSeparator: true)
            tableView.isScrollEnabled = true
            tableView.clipsToBounds = true
        } else {
            tableView.isScrollEnabled = false
            tableView.clipsToBounds = false
            navigationBarHeight.constant = 0
            navigationBarView.isHidden = true
        }
    }
    
    func initializeUI() {
        self.configureNavigation()
        self.tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.size.width, height: 190)
        self.tableView.registerNibs(nibNames: [InputFieldTableViewCell.reuseIdentifier])
        self.tableView.registerHeaderFooter(nibNames: [HAISPanelSectionHeader.reuseIdentifier])
        self.showLoader()
        self.setDefaultPercents()
        if let score = self.totalScore {
            self.scoreLaebel.text = "\(score.rounded(toPlaces: 2))"
        }
        self.setInitialTableDataSource()
    }
    
    private func setInitialTableDataSource() {
        for row in GeneralSection.allCases {
            self.generalFieldsDataArray.append(InputFieldTableCellViewModel(title: row.fieldInfo.title, inputIconImage: row.fieldInfo.leftIcon ?? #imageLiteral(resourceName: "avatar-g"), value: nil, errorMessage: "", isHighlighted: false, toggleState:false))
        }
        for row in SelfAssessmentSection.allCases {
            self.selfAssessmentFieldsDataArray.append(InputFieldTableCellViewModel(title: row.fieldInfo.title, inputIconImage: row.fieldInfo.leftIcon ?? #imageLiteral(resourceName: "avatar-g"), value: nil, errorMessage: "", isHighlighted: false, toggleState:false))
        }
        
        for row in ComprehensiveSection.allCases {
            self.comprehensiveFieldsDataArray.append(InputFieldTableCellViewModel(title: row.fieldInfo.title, inputIconImage: row.fieldInfo.leftIcon ?? #imageLiteral(resourceName: "avatar-g"), value: nil, errorMessage: "", isHighlighted: false, toggleState:false))
        }
        self.getHealthData()
        self.getNutritionTrackingPercent()
        
    }
    
    //setting the default percentages, if could not fetch from server
    private func setDefaultPercents() {
        self.nutritionPercents = [NutritionPercent(id: "1", value: "100"),
                                  NutritionPercent(id: "2", value: "70-99"),
                                  NutritionPercent(id: "3", value: "40-69"),
                                  NutritionPercent(id: "4", value: "20-39"),
                                  NutritionPercent(id: "5", value: "1-19")
        ]
    }
    
    // MARK: Helpers
    private func mainFieldValueAt(section: GeneralSection) -> String? {
        if let value = generalFieldsDataArray[section.rawValue].value as? String {
            return value
        }
        return nil
    }
    
    private func panelFieldValueAt(section: ComprehensiveSection) -> String? {
        if let value = selfAssessmentFieldsDataArray[section.rawValue].value as? String {
            return value
        }
        return nil
    }
    
    private func setUserInteraction(enable: Bool) {
        if enable {
            self.submitButton.alpha = 1.0
        } else {
            self.submitButton.alpha = 0.6
        }
        self.submitButton.isUserInteractionEnabled = enable
    }
    
    private func checkForFieldsEmptyStatus(textField: UITextField?) {
        if mainFieldValueAt(section: .bodyMassIndex) != nil || mainFieldValueAt(section: .VO2_max) != nil || mainFieldValueAt(section: .bodyFat) != nil || mainFieldValueAt(section: .waistCircumference) != nil || mainFieldValueAt(section: .restingHeartRate) != nil ||
            panelFieldValueAt(section: .LDL) != nil ||
            panelFieldValueAt(section: .LDH) != nil ||
            panelFieldValueAt(section: .Hba1c) != nil ||
            panelFieldValueAt(section: .cholestrol) != nil ||
            panelFieldValueAt(section: .triglycerides) != nil || panelFieldValueAt(section: .systolic) != nil || panelFieldValueAt(section: .diastolic) != nil {
            
            //enable action button
            self.setUserInteraction(enable: true)
        } else {
            if let text = textField?.text,
               !text.trim.isEmpty {
                self.setUserInteraction(enable: true)
            } else {
                if isFromProfile{
                    if (mainFieldValueAt(section: .height) != nil || mainFieldValueAt(section: .weight) != nil){
                        self.setUserInteraction(enable: true)
                    } else {
                        self.setUserInteraction(enable: false)
                        
                    }
                } else {
                    self.setUserInteraction(enable: false)
                    
                }
                //disable action button
            }
        }
    }
    
    private func didEndEditingPanelFields(textField: CustomTextField) {
        if let text = textField.text,
           text != "" {
            self.comprehensiveFieldsDataArray[textField.row].value = textField.text
        } else {
            self.comprehensiveFieldsDataArray[textField.row].value = nil
        }
        self.comprehensiveFieldsDataArray[textField.row].isHighlighted = false
        if let currentRow = ComprehensiveSection(rawValue: textField.row) {
            switch currentRow {
            case .cholestrol:
                self.healthData?.panel?.cholesterol = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .Hba1c:
                healthData?.panel?.hba1c = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .LDH:
                healthData?.panel?.ldh = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .LDL:
                healthData?.panel?.ldl = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .triglycerides:
                healthData?.panel?.triglycerides = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .systolic:
                break
            case .diastolic:
                break
            }
        }
    }
    
    private func didEndEditingMainFields(textField: CustomTextField) {
        if let text = textField.text,
           text != "" {
            self.generalFieldsDataArray[textField.section].value = textField.text
        } else {
            self.generalFieldsDataArray[textField.section].value = nil
        }
        self.generalFieldsDataArray[textField.section].isHighlighted = false
        
        //        if let currentRow = HAISFormSections(rawValue: textField.section) {
        //            switch currentRow {
        //            case .systolicBloodPressure:
        //                healthData?.bloodPressure?.systolic = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .diastolicBloodPressure:
        //                healthData?.bloodPressure?.diastolic = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .happiness:
        //                healthData?.happiness = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .restingHeartRate:
        //                healthData?.restingHeartRate = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .bodyMassIndex:
        //                healthData?.bmi = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .selfAssessment:
        //                healthData?.selfAssessment = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .VO2_max:
        //                healthData?.vO2Max = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .waistCircumference:
        //                healthData?.waistCircumference = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            case .bodyFat:
        //                healthData?.bodyFat = textField.text?.toDouble()?.rounded(toPlaces: 2)
        //            default:
        //                break
        //            }
        //        }
    }
    
    
    //To open Weight Picker....
    func openWeightPicker() {
        let picker = UIPickerManager()
        picker.delegate = self
        picker.selectedWeight = 120
        picker.addPickerView()
    }
    
    //To open Height Picker...
    func openHeightPicker() {
        let picker = UIPickerManager()
        picker.openHeightPicker = true
        picker.delegate = self
        //set default value of height in inches
        picker.selectedHeightInFeet = 5
        picker.selectedHeightInInch = 0
        picker.addPickerView()
    }
    
    private func setDataSource() {
        self.generalFieldsDataArray[GeneralSection.VO2_max.rawValue].value = healthData?.vO2Max?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        //        self.mainFieldsDataArray[HAISFormSection.bloodPressure.rawValue].value = healthData?.bloodPressure?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        
        //        self.generalFieldsDataArray[GeneralSection.systolicBloodPressure.rawValue].value = healthData?.bloodPressure?.systolic?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        //        self.generalFieldsDataArray[GeneralSection.diastolicBloodPressure.rawValue].value = healthData?.bloodPressure?.diastolic?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        
        self.generalFieldsDataArray[GeneralSection.waistCircumference.rawValue].value = healthData?.waistCircumference?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.generalFieldsDataArray[GeneralSection.bodyFat.rawValue].value = healthData?.bodyFat?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.generalFieldsDataArray[GeneralSection.restingHeartRate.rawValue].value = healthData?.restingHeartRate?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        
        self.generalFieldsDataArray[GeneralSection.height.rawValue].value =  (healthData?.feet != nil && healthData?.feet != 0) ? "\(healthData?.feet ?? 0)' \(healthData?.inch ?? 0)''" : ""
        
        
        self.generalFieldsDataArray[GeneralSection.weight.rawValue].value =  (healthData?.weight != nil && healthData?.weight != 0) ? healthData?.weight ?? 0 : ""
        
        //        if let nutritionTrackingKey = healthData?.nutritionTrackingId,
        //            let percentage = self.nutritionPercents.first(where: {$0.id == "\(nutritionTrackingKey)"}) {
        //            self.mainFieldsDataArray[HAISFormSection.nutrition.rawValue].value = percentage.value
        //        }
        
        
        self.comprehensiveFieldsDataArray[ComprehensiveSection.LDH.rawValue].value = healthData?.panel?.ldh?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.comprehensiveFieldsDataArray[ComprehensiveSection.LDL.rawValue].value = healthData?.panel?.ldl?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.comprehensiveFieldsDataArray[ComprehensiveSection.triglycerides.rawValue].value = healthData?.panel?.triglycerides?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.comprehensiveFieldsDataArray[ComprehensiveSection.cholestrol.rawValue].value = healthData?.panel?.cholesterol?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.comprehensiveFieldsDataArray[ComprehensiveSection.Hba1c.rawValue].value = healthData?.panel?.hba1c?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.setBodyMassIndex()
        
        self.tableView.reloadData()
        //disable interaction initially
        self.setUserInteraction(enable: false)
    }
    
    private func setBodyMassIndex() {
        if let weightInLBS = healthData?.weight,
           weightInLBS != 0,
           let heightInFeets = healthData?.feet,
           heightInFeets != 0 {
            
            /*
             BMI = Weight in Kg/Height in Meters Squared.
             - Business Rules: Conversion of Weight and Height.
             o Weight:155lbs=70.30Kgs(Pounds/2.205)//81.63
             o Height:5’2”=1.57m(Inches/39.37)//1.57
             - Example BMI 70.30/1.57sq = 28.52
             */
            let weightInKg = (Double(weightInLBS)/2.205).rounded(toPlaces: 2)
            let heightInInches = healthData?.inch ?? 0
            let totalHeightInMeters = (Double(heightInFeets*12 + heightInInches)/39.37).rounded(toPlaces: 2)
            //            let heightSquared = pow(totalHeightInMeters, 2).rounded(toPlaces: 2)
            let value = weightInKg/totalHeightInMeters
            //            let bmiValue = (weightInKg/heightSquared).rounded(toPlaces: 2)
            let bmiValue = (value/totalHeightInMeters).rounded(toPlaces: 1)
            self.healthData?.bmi = bmiValue
            self.generalFieldsDataArray[GeneralSection.bodyMassIndex.rawValue].value = bmiValue.formattedWithTrailingZeroes
        } else {
            self.generalFieldsDataArray[GeneralSection.bodyMassIndex.rawValue].value = healthData?.bmi?.rounded(toPlaces: 1).formattedWithTrailingZeroes
        }
    }
    
    ///returns the params modified for update api call
    private func updatedHealthDataParams() -> HealthData? {
        var data = self.healthData
        if self.healthData?.panelComplete == nil {
            data?.panel = nil
        }
        if let panelComplete = self.healthData?.panelComplete,
           panelComplete == .no {
            data?.panel = nil
        }
        if let tracking = self.healthData?.nutritionTracking,
           tracking == .no {
            data?.nutritionTrackingId = nil
        }
        return data
    }
    
    private func formValidated() -> Bool {
        var errorCount = 0
        if let status = healthData?.nutritionTracking,
           status == .yes {
            if healthData?.nutritionTrackingId == nil || healthData?.nutritionTrackingId == 0 {
                errorCount += 1
                selfAssessmentFieldsDataArray[SelfAssessmentSection.doYourTrackYourNutrition.rawValue].errorMessage = AppMessages.HAIS.enterNutritionTrackingPercent
                let indexPath = IndexPath(row: SelfAssessmentSection.doYourTrackYourNutrition.rawValue, section: SelfAssessmentSection.doYourTrackYourNutrition.rawValue)
                if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                    cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterNutritionTrackingPercent)
                }
            } else {
                
            }
        } else {
            selfAssessmentFieldsDataArray[SelfAssessmentSection.doYourTrackYourNutrition.rawValue].errorMessage = ""
            let indexPath = IndexPath(row: SelfAssessmentSection.trackNutritionPercentages.rawValue, section: SelfAssessmentSection.doYourTrackYourNutrition.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: "")
            }
        }
        
        if healthData?.bloodPressure?.systolic == nil || healthData?.bloodPressure?.systolic == 0 {
            if (healthData?.bloodPressure?.diastolic ?? 0) > 0 {
                errorCount += 1
                comprehensiveFieldsDataArray[ComprehensiveSection.systolic.rawValue].errorMessage = AppMessages.HAIS.enterSystolicBloodPressure
                let indexPath = IndexPath(row: 0, section: ComprehensiveSection.systolic.rawValue)
                if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                    cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterSystolicBloodPressure)
                }
            }
        } else {
            comprehensiveFieldsDataArray[ComprehensiveSection.systolic.rawValue].errorMessage = ""
            let indexPath = IndexPath(row: 0, section: ComprehensiveSection.systolic.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: "")
            }
        }
        if healthData?.bloodPressure?.diastolic == nil || healthData?.bloodPressure?.diastolic == 0 {
            if (healthData?.bloodPressure?.systolic ?? 0) > 0 {
                errorCount += 1
                comprehensiveFieldsDataArray[ComprehensiveSection.diastolic.rawValue].errorMessage = AppMessages.HAIS.enterDiastolicBloodPressure
                let indexPath = IndexPath(row: 0, section: ComprehensiveSection.diastolic.rawValue)
                if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                    cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterDiastolicBloodPressure)
                }
            }
        } else {
            comprehensiveFieldsDataArray[ComprehensiveSection.diastolic.rawValue].errorMessage = ""
            let indexPath = IndexPath(row: 0, section: ComprehensiveSection.diastolic.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: "")
            }
        }
        
        if errorCount > 0 {
            let indexPath = IndexPath(row: 0, section: ComprehensiveSection.systolic.rawValue)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            return false
        }
        return true
    }
    
    ///validate nutrition fields
    private func validateNutritionTracking() -> Bool {
        if let isTracking = self.healthData?.nutritionTracking,
           isTracking == .yes {
            if healthData?.nutritionTrackingPercent != nil {
                return true
            }
            comprehensiveFieldsDataArray[ComprehensiveSection.systolic.rawValue].errorMessage = AppMessages.HAIS.enterNutritionTrackingPercent
            let indexPath = IndexPath(row: 0, section: ComprehensiveSection.systolic.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterNutritionTrackingPercent)
            }
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            return false
        }
        return true
    }
    
    // MARK: Activity sheet helpers
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .nutritionTrackingPercent {
            self.healthData?.nutritionTrackingPercent = self.nutritionPercents[index].value
            self.healthData?.nutritionTrackingId = nutritionPercents[index].id.toInt()
            let section = ComprehensiveSection.systolic.rawValue
            self.comprehensiveFieldsDataArray[section].value = self.nutritionPercents[index].value
            self.comprehensiveFieldsDataArray[section].isHighlighted = false
            self.setUserInteraction(enable: true)
            self.tableView.reloadData()
        }
    }
    
    override func cancelSelection(type: SheetDataType) {
        if type == .nutritionTrackingPercent {
            let section = SelfAssessmentSection.doYourTrackYourNutrition.rawValue
            let indexPath = IndexPath(row: SelfAssessmentSection.trackNutritionPercentages.rawValue, section: section)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                self.comprehensiveFieldsDataArray[section].isHighlighted = false
                cell.inputTextField.changeViewFor(selectedState: false)
            }
        }
    }
    
    // MARK: Api Calls
    func updateHealthData() {
        //        guard validateNutritionTracking(), formValidated() else {
        //            return
        //        }
        guard formValidated() else {
            return
        }
        if isConnectedToNetwork() {
            self.showLoader()
            let data = self.updatedHealthDataParams()?.json()
            DIWebLayerUserAPI().updateUserHealthData(parameters: data, completion: { (_) in
                self.hideLoader()
                self.showAlert(withTitle: "", message: "Your data is uploaded successfully!".localized, okayTitle: AppMessages.AlertTitles.Ok, okStyle: .default, okCall: {
                    if !self.isFromProfile {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.setUserInteraction(enable: false)
                })
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "Message")
            }
        }
    }
    
    private func getHealthData() {
        DIWebLayerUserAPI().getUserHealthData(completion: { (data) in
            self.hideLoader()
            self.healthData = HealthData()
            if data.bloodPressure == nil {
                self.healthData?.bloodPressure = BloodPressure()
            }
            self.isLoadedFromServer = true
            self.setDataSource()
        }) { (error) in
            self.hideLoader()
            self.setUserInteraction(enable: false)
            self.showAlert(message: error.message ?? "Error")
        }
    }
    
    private func getNutritionTrackingPercent() {
        DIWebLayerUserAPI().getNutritionTrackingPercent(completion: { (array) in
            self.isPercentagesLoaded = true
            if let arrayData = array as? [(key: String, value: String)] {
                self.nutritionPercents = arrayData.map({ (key, value) -> NutritionPercent in
                    return NutritionPercent(id: key, value: value)
                })
            }
        }) { (error) in
            self.isPercentagesLoaded = false
            DILog.print(items: error.message ?? "")
        }
    }
    
    private func getTotalScoreOfUser() {
        DIWebLayerUserAPI().getHAISTotalScore(completion: { (value) in
            self.totalScore = value
            DispatchQueue.main.async {
                self.scoreLaebel.text = "\(value.rounded(toPlaces: 2))"
            }
        }) { (error) in
            DILog.print(items: error.message ?? "There was some error fetching score")
        }
    }
    
    func createGradientView(view:GradientDashedLineCircularView){
        
        view.configureViewProperties(colors: [UIColor(red: 11.0 / 255.0, green: 249.0 / 255.0, blue: 243.0 / 255.0, alpha: 1), UIColor(red: 11.0 / 255.0, green: 249.0 / 255.0, blue: 243.0 / 255.0, alpha: 1)], gradientLocations: [0, 0])
        view.instanceWidth = 2.0
        view.instanceHeight = 3.0
        view.extraInstanceCount = 1
        view.lineColor = UIColor.gray
        view.updateGradientLocation(newLocations: [NSNumber(value: 0.00),NSNumber(value: 0.87)], addAnimation: false)
    }
    
    func createShadowViewNew(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor(red: 11.0 / 255.0, green: 130.0 / 255.0, blue: 220.0 / 255.0, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
}

// MARK: UITableViewDataSource

extension HAISViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  HAISFormSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = HAISFormSections(rawValue: section){
            switch currentSection {
            case .general:
                return GeneralSection.allCases.count
            case .selfAssessment:
                return SelfAssessmentSection.allCases.count
            case .comprehensive:
                return ComprehensiveSection.allCases.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inputFieldCell = tableView.dequeueReusableCell(withIdentifier: InputFieldTableViewCell.reuseIdentifier, for: indexPath) as? InputFieldTableViewCell
        //        let toggleOptionsCell = tableView.dequeueReusableCell(withIdentifier: HAISToggleButtonTableViewCell.reuseIdentifier, for: indexPath) as? HAISToggleButtonTableViewCell
        
        inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: true)
        inputFieldCell?.delegate = self
        inputFieldCell?.inputTextField.maxLength = 16
        inputFieldCell?.inputTextField.row = indexPath.row
        inputFieldCell?.inputTextField.section = indexPath.section
        inputFieldCell?.inputTextField.keyboardType = .decimalPad
        inputFieldCell?.showToggle(isHide: true)
        inputFieldCell?.backgroundColor = UIColor.clear
        inputFieldCell?.customiseTextFieldShadowFromCell(cornerRadius: 10.5, shadowType: .outerShadow, shadowRadius: 0.3, mainColor: UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor, lightShadowColor: UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.43).cgColor, darkShadowView: UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.98).cgColor)
        //        toggleOptionsCell?.delegate = self
        
        if let currentSection = HAISFormSections(rawValue: indexPath.section) {
            inputFieldCell?.inputTextField.placeholder = currentSection.fieldInfo.title
            switch currentSection {
            case .general:
                if let currentRow = GeneralSection(rawValue: indexPath.row) {
                    inputFieldCell?.inputTextField.placeholder = currentRow.fieldInfo.title
                    switch currentRow {
                    case .height:
                        if let feet = healthData?.feet, let inch = healthData?.inch{
                            inputFieldCell?.inputTextField.text = "\(feet)' \(inch)''"
                        }
                        inputFieldCell?.inputTextField.text = ""
                    case .weight:
                        inputFieldCell?.inputTextField.text = healthData?.weight != nil && healthData?.weight != 0 ? "\(healthData?.weight ?? 0) lbs" : ""
                    case .bodyMassIndex:
                        inputFieldCell?.inputTextField.isUserInteractionEnabled = false
                    case .bodyFat:
                        break
                    case .waistCircumference:
                        break
                    case .restingHeartRate:
                        break
                    case .VO2_max:
                        break
                    case .hrv:
                        break
                    }
                }
                inputFieldCell?.initializeWith(viewModel: generalFieldsDataArray[indexPath.row], indexPath: indexPath)
                
            case .selfAssessment:
                //                        toggleOptionsCell?.setUpViewForHappiness(value: self.healthData?.happinessSurvey)
                //                        return toggleOptionsCell ?? UITableViewCell()
                inputFieldCell?.inputTextField.placeholder = SelfAssessmentSection(rawValue: indexPath.row)?.fieldInfo.title
                inputFieldCell?.showToggle(isHide: false)
                inputFieldCell?.initializeWith(viewModel: selfAssessmentFieldsDataArray[indexPath.section], indexPath: indexPath)
                inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: false)
                inputFieldCell?.toggleButton.isUserInteractionEnabled = true
                //            case .nutrition:
                //                if let currentRow = NutritionSection(rawValue: indexPath.row) {
                //                    switch currentRow {
                //                    case .trackNutrition:
                //                        toggleOptionsCell?.setUpViewForNutrition(value: self.healthData?.nutritionTracking)
                //                        return toggleOptionsCell ?? UITableViewCell()
                //                    case .trackingPercentage:
                //                        inputFieldCell?.initializeWith(viewModel: mainFieldsDataArray[indexPath.section], indexPath: indexPath)
                //                        if let isTracked = self.healthData?.nutritionTracking,
                //                            isTracked == .yes {
                //                            inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: true)
                //                        } else {
                //                            inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: false)
                //                        }
                //                    }
                //                }
            case .comprehensive:
                //                toggleOptionsCell?.setUpViewForPanel(value: self.healthData?.panelComplete)
                inputFieldCell?.inputTextField.placeholder = ComprehensiveSection(rawValue: indexPath.row)?.fieldInfo.title
                inputFieldCell?.inputTextField.maxLength = 3
            }
            
        }
        return inputFieldCell ?? UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension HAISViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        if let currentSection = HAISFormSection(rawValue: section) {
        //            if (currentSection == .height || currentSection == .weight) && (!isFromProfile){
        //                return 0
        //            }
        //            switch currentSection {
        //            case .panel:
        //                return 58.0//UITableView.automaticDimension
        //            default:
        //                return CGFloat.leastNormalMagnitude
        //            }
        //        }
        
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HAISPanelSectionHeader.reuseIdentifier) as! HAISPanelSectionHeader
        if let currentSection = HAISFormSections(rawValue: section) {
            switch currentSection {
            case .general:
                header.titleLabel.text = currentSection.fieldInfo.title
            case .selfAssessment:
                header.titleLabel.text = currentSection.fieldInfo.title
            case .comprehensive:
                header.titleLabel.text = currentSection.fieldInfo.title
            }
        }
        header.backgroundColor = UIColor.clear
        return header
    }
    
}
/*
 // MARK: HAISPanelSectionHeaderDelegate
 extension HAISViewController: HAISPanelSectionHeaderDelegate {
 func didSelectPanelHeader(isSelected: Bool) {
 self.delegate?.onClickOfPanel(isSelected: isSelected)
 self.isPanelSelected = !isSelected
 self.tableView.reloadData()
 let lastRow = tableView.numberOfRows(inSection: HAISFormSection.panel.rawValue)
 if lastRow > 0 {
 let indexPath = IndexPath(row: lastRow - 1, section: HAISFormSection.panel.rawValue)
 self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
 }
 }
 }
 
 // MARK: 
 extension HAISViewController: HAISToggleTableCellDelegate {
 func didChangeToggleFor(section: HAISFormSection, isSelected: Bool) {
 switch section {
 case .happiness:
 self.healthData?.happinessSurvey = isSelected ? .yes : .no
 case .selfAssessment:
 self.healthData?.selfAssessmentToggle = isSelected ? .yes : .no
 case .nutrition:
 self.healthData?.nutritionTracking = isSelected ? .yes : .no
 //            if !isSelected {
 //                self.healthData?.nutritionTrackingId = nil
 //            }
 tableView.reloadData()
 if self.isPercentagesLoaded == false {
 self.getNutritionTrackingPercent()
 }
 case .panelComplete:
 self.healthData?.panelComplete = isSelected ? .yes : .no
 tableView.reloadData()
 default:
 break
 }
 self.setUserInteraction(enable: true)
 }
 }
 */
// MARK: InputFieldTableCellDelegate
extension HAISViewController: InputFieldTableCellDelegate {
    func inputTextFieldDidEndEditing(textField: UITextField) {
        guard let textField = textField as? CustomTextField else {
            return
        }
        if let currentField = HAISFormSections(rawValue: textField.section) {
            switch currentField {
            case .general:
                if self.healthData?.panel == nil {
                    self.healthData?.panel = UserPanelHealthData()
                }
                self.didEndEditingPanelFields(textField: textField)
            default:
                if self.healthData == nil {
                    self.healthData = HealthData()
                }
                self.didEndEditingMainFields(textField: textField)
            }
        }
        
    }
    
    func inputTextFieldEditingChanged(textField: UITextField) {
        guard let textField = textField as? CustomTextField else {
            return
        }
        if let currentField = HAISFormSections(rawValue: textField.section) {
            switch currentField {
            case .comprehensive:
                if let text = textField.text,
                   text != "" {
                    self.comprehensiveFieldsDataArray[textField.row].value = textField.text
                } else {
                    self.comprehensiveFieldsDataArray[textField.row].value = nil
                }
            default:
                if let text = textField.text,
                   text != "" {
                    self.generalFieldsDataArray[textField.section].value = textField.text
                    self.selfAssessmentFieldsDataArray[textField.section].value = textField.text
                } else {
                    self.generalFieldsDataArray[textField.section].value = nil
                    self.selfAssessmentFieldsDataArray[textField.section].value = nil
                }
            }
        }
        self.checkForFieldsEmptyStatus(textField: textField)
    }
    
    func inputTextFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField,
           let currentField = HAISFormSections(rawValue: textField.section) {
            switch currentField {
            case .comprehensive:
                self.view.endEditing(true)
                if nutritionPercents.isEmpty {
                    self.setDefaultPercents()
                }
                self.showSelectionModal(array: self.nutritionPercents, type: .nutritionTrackingPercent)
                return false
            case .general:
                if let currentRow = GeneralSection(rawValue: textField.row){
                    if currentRow == .height{
                        openHeightPicker()
                        return false
                    }
                    if currentRow == .weight{
                        openWeightPicker()
                        return false
                    }
                }
            default:
                return true
            }
        }
        return true
    }
    
    func inputTextFieldDidBeginEditing(textField: UITextField) {}
    
    func didTapDoneOnInputTextField(sender: UIBarButtonItem) {}
    
    func inputTextFieldShouldChangeCharacters(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if let text = textField.text {
            if text.isEmpty && string == "." {
                return false
            }
            let decimalCount = text.components(separatedBy: ".").count - 1
            if decimalCount > 0 && string == "." {
                return false
            }
        }
        return true
    }
}
extension HAISViewController:MyPickerDelegate {
    func tappedOnDoneOrCancel() {
        
    }
    
    func getPickerValue(firstValue: String, secondValue: String) {
        
    }
    
    //For Weight....
    
    func getWeight(weight: Int) {
        healthData?.weight = weight
        self.setBodyMassIndex()
        self.tableView.reloadData()
        self.setUserInteraction(enable: true)
    }
    
    //For Height...
    
    func getHeight(heightInFeet: Int, heightIninch: Int) {
        healthData?.feet = heightInFeet
        healthData?.inch = heightIninch
        self.setBodyMassIndex()
        self.tableView.reloadData()
        self.setUserInteraction(enable: true)
    }
}

// MARK: Old Code
/*
import UIKit

struct NutritionPercent {
    var id: String
    var value: String
    
    init(id: String, value: String) {
        self.id = id
        self.value = value + "%"
    }
}
protocol HaisDelegate {
    func onClickOfPanel(isSelected: Bool)
}
class HAISViewController: DIBaseController {

    // MARK: Properties
    private var mainFieldsDataArray = [InputFieldTableCellViewModel]()
    private var panelFieldsDataArray = [InputFieldTableCellViewModel]()
    private var isPanelSelected = false
    private var healthData: HealthData?
    final private var isPercentagesLoaded = false
    final private var nutritionPercents = [NutritionPercent]()
    var totalScore: Double?
    final private var isLoadedFromServer = false
    var isFromProfile = false
    var delegate: HaisDelegate?




    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scoreLaebel: UILabel!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBarHeight: NSLayoutConstraint!
    
    // MARK: IBActions
    @IBAction func submitTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.updateHealthData()
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
        initializeUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLoadedFromServer {
            self.setBodyMassIndex()
            self.tableView.reloadData()
        }
        DispatchQueue.global(qos: .background).async {
            self.getTotalScoreOfUser()
        }
    }
    
    // MARK: View Setup
    func configureNavigation() {
        if !isFromProfile {
            navigationBarHeight.constant = 45
        _ = configureNavigtion(onView: self.navigationBarView, title: "HAIS".localized, showBottomSeparator: true)
             tableView.isScrollEnabled = true
            tableView.clipsToBounds = true
        } else {
            tableView.isScrollEnabled = false
            tableView.clipsToBounds = false
            navigationBarHeight.constant = 0
            navigationBarView.isHidden = true
        }
    }
    
    func initializeUI() {
        self.configureNavigation()
        self.tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.size.width, height: 190)
        self.tableView.registerNibs(nibNames: [InputFieldTableViewCell.reuseIdentifier])
        self.tableView.registerHeaderFooter(nibNames: [HAISPanelSectionHeader.reuseIdentifier])
        self.showLoader()
        self.setDefaultPercents()
        if let score = self.totalScore {
            self.scoreLaebel.text = "\(score.rounded(toPlaces: 2))"
        }
        self.setInitialTableDataSource()
    }
    
    private func setInitialTableDataSource() {
        for section in HAISFormSection.allCases {
            self.mainFieldsDataArray.append(InputFieldTableCellViewModel(title: section.fieldInfo.title, inputIconImage: section.fieldInfo.leftIcon ?? #imageLiteral(resourceName: "avatar-g"), value: nil, errorMessage: "", isHighlighted: false))
        }
        for row in PanelCategories.allCases {
            self.panelFieldsDataArray.append(InputFieldTableCellViewModel(title: row.fieldInfo.title, inputIconImage: row.fieldInfo.leftIcon ?? #imageLiteral(resourceName: "avatar-g"), value: nil, errorMessage: "", isHighlighted: false))
        }
        self.getHealthData()
        self.getNutritionTrackingPercent()
        
    }
    
    //setting the default percentages, if could not fetch from server
    private func setDefaultPercents() {
        self.nutritionPercents = [NutritionPercent(id: "1", value: "100"),
                                  NutritionPercent(id: "2", value: "70-99"),
                                  NutritionPercent(id: "3", value: "40-69"),
                                  NutritionPercent(id: "4", value: "20-39"),
                                  NutritionPercent(id: "5", value: "1-19")
                                  ]
    }
    
    // MARK: Helpers
    private func mainFieldValueAt(section: HAISFormSection) -> String? {
        if let value = mainFieldsDataArray[section.rawValue].value as? String {
            return value
        }
        return nil
    }
    
    private func panelFieldValueAt(section: PanelCategories) -> String? {
        if let value = panelFieldsDataArray[section.rawValue].value as? String {
            return value
        }
        return nil
    }
    
    private func setUserInteraction(enable: Bool) {
        if enable {
            self.submitButton.alpha = 1.0
        } else {
            self.submitButton.alpha = 0.6
        }
        self.submitButton.isUserInteractionEnabled = enable
    }
    
    private func checkForFieldsEmptyStatus(textField: UITextField?) {
        if mainFieldValueAt(section: .bodyMassIndex) != nil || mainFieldValueAt(section: .VO2_max) != nil || mainFieldValueAt(section: .bodyFat) != nil || mainFieldValueAt(section: .systolicBloodPressure) != nil || mainFieldValueAt(section: .diastolicBloodPressure) != nil || mainFieldValueAt(section: .waistCircumference) != nil || mainFieldValueAt(section: .nutrition) != nil || mainFieldValueAt(section: .restingHeartRate) != nil ||
            panelFieldValueAt(section: .LDL) != nil ||
            panelFieldValueAt(section: .LDH) != nil ||
            panelFieldValueAt(section: .Hba1c) != nil ||
            panelFieldValueAt(section: .cholestrol) != nil ||
            panelFieldValueAt(section: .triglycerides) != nil {
            
            //enable action button
            self.setUserInteraction(enable: true)
        } else {
            if let text = textField?.text,
                !text.trim.isEmpty {
                self.setUserInteraction(enable: true)
            } else {
                if isFromProfile{
                    if (mainFieldValueAt(section: .height) != nil || mainFieldValueAt(section: .weight) != nil){
                        self.setUserInteraction(enable: true)
                    } else {
                        self.setUserInteraction(enable: false)
                        
                    }
                } else {
                    self.setUserInteraction(enable: false)
                    
                }
                //disable action button
            }
        }
    }
    
    private func didEndEditingPanelFields(textField: CustomTextField) {
        if let text = textField.text,
            text != "" {
            self.panelFieldsDataArray[textField.row].value = textField.text
        } else {
            self.panelFieldsDataArray[textField.row].value = nil
        }
        self.panelFieldsDataArray[textField.row].isHighlighted = false
        if let currentRow = PanelCategories(rawValue: textField.row) {
            switch currentRow {
            case .cholestrol:
                self.healthData?.panel?.cholesterol = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .Hba1c:
                healthData?.panel?.hba1c = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .LDH:
                healthData?.panel?.ldh = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .LDL:
                healthData?.panel?.ldl = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .triglycerides:
                healthData?.panel?.triglycerides = textField.text?.toDouble()?.rounded(toPlaces: 2)
            }
        }
    }
    
    private func didEndEditingMainFields(textField: CustomTextField) {
        if let text = textField.text,
            text != "" {
            self.mainFieldsDataArray[textField.section].value = textField.text
        } else {
            self.mainFieldsDataArray[textField.section].value = nil
        }
        self.mainFieldsDataArray[textField.section].isHighlighted = false
        
        if let currentRow = HAISFormSection(rawValue: textField.section) {
            switch currentRow {
            case .systolicBloodPressure:
                healthData?.bloodPressure?.systolic = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .diastolicBloodPressure:
                healthData?.bloodPressure?.diastolic = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .happiness:
                healthData?.happiness = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .restingHeartRate:
                healthData?.restingHeartRate = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .bodyMassIndex:
                healthData?.bmi = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .selfAssessment:
                healthData?.selfAssessment = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .VO2_max:
                healthData?.vO2Max = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .waistCircumference:
                healthData?.waistCircumference = textField.text?.toDouble()?.rounded(toPlaces: 2)
            case .bodyFat:
                healthData?.bodyFat = textField.text?.toDouble()?.rounded(toPlaces: 2)
            default:
                break
            }
        }
    }
    
    
    //To open Weight Picker....
    func openWeightPicker() {
        let picker = UIPickerManager()
        picker.delegate = self
        picker.selectedWeight = 120
        picker.addPickerView()
    }
    
    //To open Height Picker...
    func openHeightPicker() {
        let picker = UIPickerManager()
        picker.openHeightPicker = true
        picker.delegate = self
        //set default value of height in inches
        picker.selectedHeightInFeet = 5
        picker.selectedHeightInInch = 0
        picker.addPickerView()
    }
    
    private func setDataSource() {
        self.mainFieldsDataArray[HAISFormSection.VO2_max.rawValue].value = healthData?.vO2Max?.rounded(toPlaces: 2).formattedWithTrailingZeroes
//        self.mainFieldsDataArray[HAISFormSection.bloodPressure.rawValue].value = healthData?.bloodPressure?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        
        self.mainFieldsDataArray[HAISFormSection.systolicBloodPressure.rawValue].value = healthData?.bloodPressure?.systolic?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.mainFieldsDataArray[HAISFormSection.diastolicBloodPressure.rawValue].value = healthData?.bloodPressure?.diastolic?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        
        self.mainFieldsDataArray[HAISFormSection.waistCircumference.rawValue].value = healthData?.waistCircumference?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.mainFieldsDataArray[HAISFormSection.bodyFat.rawValue].value = healthData?.bodyFat?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.mainFieldsDataArray[HAISFormSection.restingHeartRate.rawValue].value = healthData?.restingHeartRate?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        
        self.mainFieldsDataArray[HAISFormSection.height.rawValue].value =  (healthData?.feet != nil && healthData?.feet != 0) ? "\(healthData?.feet ?? 0)' \(healthData?.inch ?? 0)''" : ""


        self.mainFieldsDataArray[HAISFormSection.weight.rawValue].value =  (healthData?.weight != nil && healthData?.weight != 0) ? healthData?.weight ?? 0 : ""

        if let nutritionTrackingKey = healthData?.nutritionTrackingId,
            let percentage = self.nutritionPercents.first(where: {$0.id == "\(nutritionTrackingKey)"}) {
            self.mainFieldsDataArray[HAISFormSection.nutrition.rawValue].value = percentage.value
        }
        
        
        self.panelFieldsDataArray[PanelCategories.LDH.rawValue].value = healthData?.panel?.ldh?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.panelFieldsDataArray[PanelCategories.LDL.rawValue].value = healthData?.panel?.ldl?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.panelFieldsDataArray[PanelCategories.triglycerides.rawValue].value = healthData?.panel?.triglycerides?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.panelFieldsDataArray[PanelCategories.cholestrol.rawValue].value = healthData?.panel?.cholesterol?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.panelFieldsDataArray[PanelCategories.Hba1c.rawValue].value = healthData?.panel?.hba1c?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        self.setBodyMassIndex()
        
        self.tableView.reloadData()
        //disable interaction initially
        self.setUserInteraction(enable: false)
    }
    
    private func setBodyMassIndex() {
        if let weightInLBS = healthData?.weight,
            weightInLBS != 0,
            let heightInFeets = healthData?.feet,
            heightInFeets != 0 {
            
            /*
             BMI = Weight in Kg/Height in Meters Squared.
             - Business Rules: Conversion of Weight and Height.
             o Weight:155lbs=70.30Kgs(Pounds/2.205)//81.63
             o Height:5’2”=1.57m(Inches/39.37)//1.57
             - Example BMI 70.30/1.57sq = 28.52
             */
            let weightInKg = (Double(weightInLBS)/2.205).rounded(toPlaces: 2)
            let heightInInches = healthData?.inch ?? 0
            let totalHeightInMeters = (Double(heightInFeets*12 + heightInInches)/39.37).rounded(toPlaces: 2)
//            let heightSquared = pow(totalHeightInMeters, 2).rounded(toPlaces: 2)
            let value = weightInKg/totalHeightInMeters
//            let bmiValue = (weightInKg/heightSquared).rounded(toPlaces: 2)
            let bmiValue = (value/totalHeightInMeters).rounded(toPlaces: 1)
            self.healthData?.bmi = bmiValue
            self.mainFieldsDataArray[HAISFormSection.bodyMassIndex.rawValue].value = bmiValue.formattedWithTrailingZeroes
        } else {
            self.mainFieldsDataArray[HAISFormSection.bodyMassIndex.rawValue].value = healthData?.bmi?.rounded(toPlaces: 1).formattedWithTrailingZeroes
        }
    }
    
    ///returns the params modified for update api call
    private func updatedHealthDataParams() -> HealthData? {
        var data = self.healthData
        if self.healthData?.panelComplete == nil {
            data?.panel = nil
        }
        if let panelComplete = self.healthData?.panelComplete,
            panelComplete == .no {
            data?.panel = nil
        }
        if let tracking = self.healthData?.nutritionTracking,
            tracking == .no {
            data?.nutritionTrackingId = nil
        }
        return data
    }
    
    private func formValidated() -> Bool {
        var errorCount = 0
        if let status = healthData?.nutritionTracking,
            status == .yes {
            if healthData?.nutritionTrackingId == nil || healthData?.nutritionTrackingId == 0 {
                errorCount += 1
                mainFieldsDataArray[HAISFormSection.nutrition.rawValue].errorMessage = AppMessages.HAIS.enterNutritionTrackingPercent
                let indexPath = IndexPath(row: NutritionSection.trackingPercentage.rawValue, section: HAISFormSection.nutrition.rawValue)
                if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                    cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterNutritionTrackingPercent)
                }
            } else {
                
            }
        } else {
            mainFieldsDataArray[HAISFormSection.nutrition.rawValue].errorMessage = ""
            let indexPath = IndexPath(row: NutritionSection.trackingPercentage.rawValue, section: HAISFormSection.nutrition.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: "")
            }
        }
        
        if healthData?.bloodPressure?.systolic == nil || healthData?.bloodPressure?.systolic == 0 {
            if (healthData?.bloodPressure?.diastolic ?? 0) > 0 {
                errorCount += 1
                mainFieldsDataArray[HAISFormSection.systolicBloodPressure.rawValue].errorMessage = AppMessages.HAIS.enterSystolicBloodPressure
                let indexPath = IndexPath(row: 0, section: HAISFormSection.systolicBloodPressure.rawValue)
                if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                    cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterSystolicBloodPressure)
                }
            }
        } else {
            mainFieldsDataArray[HAISFormSection.systolicBloodPressure.rawValue].errorMessage = ""
            let indexPath = IndexPath(row: 0, section: HAISFormSection.systolicBloodPressure.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: "")
            }
        }
        if healthData?.bloodPressure?.diastolic == nil || healthData?.bloodPressure?.diastolic == 0 {
            if (healthData?.bloodPressure?.systolic ?? 0) > 0 {
                errorCount += 1
                mainFieldsDataArray[HAISFormSection.diastolicBloodPressure.rawValue].errorMessage = AppMessages.HAIS.enterDiastolicBloodPressure
                let indexPath = IndexPath(row: 0, section: HAISFormSection.diastolicBloodPressure.rawValue)
                if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                    cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterDiastolicBloodPressure)
                }
            }
        } else {
            mainFieldsDataArray[HAISFormSection.diastolicBloodPressure.rawValue].errorMessage = ""
            let indexPath = IndexPath(row: 0, section: HAISFormSection.diastolicBloodPressure.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: "")
            }
        }
        
        if errorCount > 0 {
            let indexPath = IndexPath(row: 0, section: HAISFormSection.nutrition.rawValue)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            return false
        }
        return true
    }
    
    ///validate nutrition fields
    private func validateNutritionTracking() -> Bool {
        if let isTracking = self.healthData?.nutritionTracking,
            isTracking == .yes {
            if let _ = healthData?.nutritionTrackingPercent {
                return true
            }
            mainFieldsDataArray[HAISFormSection.nutrition.rawValue].errorMessage = AppMessages.HAIS.enterNutritionTrackingPercent
            let indexPath = IndexPath(row: 0, section: HAISFormSection.nutrition.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                cell.displayErrorMessage(errorMessage: AppMessages.HAIS.enterNutritionTrackingPercent)
            }
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            return false
        }
        return true
    }
    
    // MARK: Activity sheet helpers
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .nutritionTrackingPercent {
            self.healthData?.nutritionTrackingPercent = self.nutritionPercents[index].value
            self.healthData?.nutritionTrackingId = nutritionPercents[index].id.toInt()
            let section = HAISFormSection.nutrition.rawValue
            self.mainFieldsDataArray[section].value = self.nutritionPercents[index].value
            self.mainFieldsDataArray[section].isHighlighted = false
            self.setUserInteraction(enable: true)
            self.tableView.reloadData()
        }
    }
    
    override func cancelSelection(type: SheetDataType) {
        if type == .nutritionTrackingPercent {
            let section = HAISFormSection.nutrition.rawValue
            let indexPath = IndexPath(row: NutritionSection.trackingPercentage.rawValue, section: section)
            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
                self.mainFieldsDataArray[section].isHighlighted = false
                cell.inputTextField.changeViewFor(selectedState: false)
            }
        }
    }
    
    // MARK: Api Calls
    func updateHealthData() {
//        guard validateNutritionTracking(), formValidated() else {
//            return
//        }
        guard formValidated() else {
            return
        }
        if isConnectedToNetwork() {
            self.showLoader()
            let data = self.updatedHealthDataParams()?.json()
            DIWebLayerUserAPI().updateUserHealthData(parameters: data, completion: { (_) in
                self.hideLoader()
                self.showAlert(withTitle: "", message: "Your data is uploaded successfully!".localized, okayTitle: AppMessages.AlertTitles.Ok, okStyle: .default, okCall: {
                    if !self.isFromProfile {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.setUserInteraction(enable: false)
                })
            }) { (error) in
                self.hideLoader()
                self.showAlert(message: error.message ?? "Message")
            }
        }
    }
    
    private func getHealthData() {
        DIWebLayerUserAPI().getUserHealthData(completion: { (data) in
            self.hideLoader()
            self.healthData = data
            if data.bloodPressure == nil {
                self.healthData?.bloodPressure = BloodPressure()
            }
            self.isLoadedFromServer = true
            self.setDataSource()
        }) { (error) in
            self.hideLoader()
            self.setUserInteraction(enable: false)
            self.showAlert(message: error.message ?? "Error")
        }
    }
    
    private func getNutritionTrackingPercent() {
        DIWebLayerUserAPI().getNutritionTrackingPercent(completion: { (array) in
            self.isPercentagesLoaded = true
            if let arrayData = array as? [(key: String, value: String)] {
                self.nutritionPercents = arrayData.map({ (key, value) -> NutritionPercent in
                    return NutritionPercent(id: key, value: value)
                })
            }
        }) { (error) in
            self.isPercentagesLoaded = false
            DILog.print(items: error.message ?? "")
        }
    }
    
    private func getTotalScoreOfUser() {
        DIWebLayerUserAPI().getHAISTotalScore(completion: { (value) in
            self.totalScore = value
            DispatchQueue.main.async {
                self.scoreLaebel.text = "\(value.rounded(toPlaces: 2))"
            }
        }) { (error) in
            DILog.print(items: error.message ?? "There was some error fetching score")
        }
    }
}

// MARK: UITableViewDataSource
extension HAISViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  HAISFormSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = HAISFormSection(rawValue: section) {
            switch currentSection {
            case .panel:
                if isPanelSelected {
                    return PanelCategories.allCases.count
                }
            case .happiness:
                return HappinessSection.allCases.count
            case .selfAssessment:
                return SelfAssessmentSection.allCases.count
            case .nutrition:
                return NutritionSection.allCases.count
            default:
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inputFieldCell = tableView.dequeueReusableCell(withIdentifier: InputFieldTableViewCell.reuseIdentifier, for: indexPath) as? InputFieldTableViewCell
        let toggleOptionsCell = tableView.dequeueReusableCell(withIdentifier: HAISToggleButtonTableViewCell.reuseIdentifier, for: indexPath) as? HAISToggleButtonTableViewCell
        
        inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: true)
        inputFieldCell?.delegate = self
        inputFieldCell?.inputTextField.maxLength = 16
        inputFieldCell?.inputTextField.row = indexPath.row
        inputFieldCell?.inputTextField.section = indexPath.section
        inputFieldCell?.inputTextField.keyboardType = .decimalPad
        toggleOptionsCell?.delegate = self
        
        if let currentSection = HAISFormSection(rawValue: indexPath.section) {
            if currentSection == .bodyMassIndex {
                inputFieldCell?.inputTextField.isUserInteractionEnabled = false
            } else {
                inputFieldCell?.inputTextField.isUserInteractionEnabled = true
            }
            switch currentSection {
          
            case .panel:
                inputFieldCell?.initializeWith(viewModel: panelFieldsDataArray[indexPath.row], indexPath: indexPath)
                if let panelComplete = self.healthData?.panelComplete,
                    panelComplete == .yes {
                    inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: true)
                } else {
                    inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: false)
                }
            case .happiness:
                if let currentRow = HappinessSection(rawValue: indexPath.row) {
                    switch currentRow {
                    case .happinessSurvey:
                        toggleOptionsCell?.setUpViewForHappiness(value: self.healthData?.happinessSurvey)
                        return toggleOptionsCell ?? UITableViewCell()
                    case .happiness:
                        inputFieldCell?.initializeWith(viewModel: mainFieldsDataArray[indexPath.section], indexPath: indexPath)
                        inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: false)
                    }
                }
            case .selfAssessment:
                if let currentRow = SelfAssessmentSection(rawValue: indexPath.row) {
                    switch currentRow {
                    case .selfAssessmentToggle:
                        toggleOptionsCell?.setUpViewForSelfAssessment(value: self.healthData?.selfAssessmentToggle)
                        return toggleOptionsCell ?? UITableViewCell()
                    case .selfAssessmentValue:
                        inputFieldCell?.initializeWith(viewModel: mainFieldsDataArray[indexPath.section], indexPath: indexPath)
                        inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: false)
                    }
                }
            case .nutrition:
                if let currentRow = NutritionSection(rawValue: indexPath.row) {
                    switch currentRow {
                    case .trackNutrition:
                        toggleOptionsCell?.setUpViewForNutrition(value: self.healthData?.nutritionTracking)
                        return toggleOptionsCell ?? UITableViewCell()
                    case .trackingPercentage:
                        inputFieldCell?.initializeWith(viewModel: mainFieldsDataArray[indexPath.section], indexPath: indexPath)
                        if let isTracked = self.healthData?.nutritionTracking,
                            isTracked == .yes {
                            inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: true)
                        } else {
                            inputFieldCell?.inputTextField.setUserInteraction(shouldEnable: false)
                        }
                    }
                }
            case .panelComplete:
                toggleOptionsCell?.setUpViewForPanel(value: self.healthData?.panelComplete)
                return toggleOptionsCell ?? UITableViewCell()
            default:
                inputFieldCell?.initializeWith(viewModel: mainFieldsDataArray[indexPath.section], indexPath: indexPath)
            }
            if currentSection == .systolicBloodPressure || currentSection == .diastolicBloodPressure {
                inputFieldCell?.inputTextField.maxLength = 3
            }
            if currentSection ==  .height {
                inputFieldCell?.inputTextField.text =  healthData?.feet != nil && healthData?.feet != 0 ? "\(healthData?.feet ?? 0)' \(healthData?.inch ?? 0)''" : ""
            }
            if currentSection ==   .weight{
                inputFieldCell?.inputTextField.text = healthData?.weight != nil && healthData?.weight != 0 ? "\(healthData?.weight ?? 0) lbs" : ""
            }
                         
        }
        return inputFieldCell ?? UITableViewCell()
    }

}

// MARK: UITableViewDelegate
extension HAISViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection = HAISFormSection(rawValue: section) {
            if (currentSection == .height || currentSection == .weight) && (!isFromProfile){
                return 0
            }
            switch currentSection {
            case .panel:
                return 58.0//UITableView.automaticDimension
            default:
                return CGFloat.leastNormalMagnitude
            }
        }
        
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let currentSection = HAISFormSection(rawValue: section) {
            switch currentSection {
            case .panel:
                if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HAISPanelSectionHeader.reuseIdentifier) as? HAISPanelSectionHeader {
                    header.delegate = self
                    header.setLayout(isSelected: self.isPanelSelected)
                    return header
                }
            default:
                return nil
            }
        }
        return nil
    }
}

// MARK: HAISPanelSectionHeaderDelegate
extension HAISViewController: HAISPanelSectionHeaderDelegate {
    func didSelectPanelHeader(isSelected: Bool) {
        self.delegate?.onClickOfPanel(isSelected: isSelected)
        self.isPanelSelected = !isSelected
        self.tableView.reloadData()
        let lastRow = tableView.numberOfRows(inSection: HAISFormSection.panel.rawValue)
        if lastRow > 0 {
            let indexPath = IndexPath(row: lastRow - 1, section: HAISFormSection.panel.rawValue)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

// MARK: 
extension HAISViewController: HAISToggleTableCellDelegate {
    func didChangeToggleFor(section: HAISFormSection, isSelected: Bool) {
        switch section {
        case .happiness:
            self.healthData?.happinessSurvey = isSelected ? .yes : .no
        case .selfAssessment:
            self.healthData?.selfAssessmentToggle = isSelected ? .yes : .no
        case .nutrition:
            self.healthData?.nutritionTracking = isSelected ? .yes : .no
//            if !isSelected {
//                self.healthData?.nutritionTrackingId = nil
//            }
            tableView.reloadData()
            if self.isPercentagesLoaded == false {
                self.getNutritionTrackingPercent()
            }
        case .panelComplete:
            self.healthData?.panelComplete = isSelected ? .yes : .no
            tableView.reloadData()
        default:
            break
        }
        self.setUserInteraction(enable: true)
    }
}

// MARK: InputFieldTableCellDelegate
extension HAISViewController: InputFieldTableCellDelegate {
    func inputTextFieldDidEndEditing(textField: UITextField) {
        guard let textField = textField as? CustomTextField else {
            return
        }
        if let currentField = HAISFormSection(rawValue: textField.section) {
            switch currentField {
            case .panel:
                if self.healthData?.panel == nil {
                    self.healthData?.panel = UserPanelHealthData()
                }
                self.didEndEditingPanelFields(textField: textField)
            default:
                if self.healthData == nil {
                    self.healthData = HealthData()
                }
                self.didEndEditingMainFields(textField: textField)
            }
        }
    }
    
    func inputTextFieldEditingChanged(textField: UITextField) {
        guard let textField = textField as? CustomTextField else {
            return
        }
        if let currentField = HAISFormSection(rawValue: textField.section) {
            switch currentField {
            case .panel:
                if let text = textField.text,
                    text != "" {
                    self.panelFieldsDataArray[textField.row].value = textField.text
                } else {
                    self.panelFieldsDataArray[textField.row].value = nil
                }
            default:
                if let text = textField.text,
                    text != "" {
                    self.mainFieldsDataArray[textField.section].value = textField.text
                } else {
                    self.mainFieldsDataArray[textField.section].value = nil
                }
            }
        }
        self.checkForFieldsEmptyStatus(textField: textField)
    }
    
    func inputTextFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField,
            let currentField = HAISFormSection(rawValue: textField.section) {
            switch currentField {
            case .nutrition:
                self.view.endEditing(true)
                if nutritionPercents.isEmpty {
                    self.setDefaultPercents()
                }
                self.showSelectionModal(array: self.nutritionPercents, type: .nutritionTrackingPercent)
                return false
            case .height:
                openHeightPicker()
                return false
            case .weight:
                openWeightPicker()
                return false
            default:
                return true
            }
        }
        return true
    }
    
    func inputTextFieldDidBeginEditing(textField: UITextField) {}
    
    func didTapDoneOnInputTextField(sender: UIBarButtonItem) {}
    
    func inputTextFieldShouldChangeCharacters(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if let text = textField.text {
            if text.isEmpty && string == "." {
                return false
            }
            let decimalCount = text.components(separatedBy: ".").count - 1
            if decimalCount > 0 && string == "." {
                return false
            }
        }
        return true
    }
}

extension HAISViewController:MyPickerDelegate {
    func tappedOnDoneOrCancel() {
        
    }
    
    func getPickerValue(firstValue: String, secondValue: String) {
        
    }
    
    //For Weight....
    
    func getWeight(weight: Int) {
        healthData?.weight = weight
        self.setBodyMassIndex()
        self.tableView.reloadData()
        self.setUserInteraction(enable: true)
    }
    
    //For Height...
    
    func getHeight(heightInFeet: Int, heightIninch: Int) {
        healthData?.feet = heightInFeet
        healthData?.inch = heightIninch
        self.setBodyMassIndex()
        self.tableView.reloadData()
        self.setUserInteraction(enable: true)
    }
}
*/
