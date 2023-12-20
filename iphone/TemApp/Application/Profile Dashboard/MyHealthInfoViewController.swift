//
//  MyHealthInfoViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 03/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class MyHealthInfoViewController: DIBaseController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scoreLaebel:UILabel!
    
    @IBOutlet weak var saveShadowView: SSNeumorphicView!{
        didSet{
            saveShadowView.setOuterDarkShadow()
        }
    }
    @IBOutlet weak var haisOuterShadowView:SSNeumorphicView!{
        didSet{
            haisOuterShadowView.viewDepthType = .outerShadow
            haisOuterShadowView.viewNeumorphicMainColor =  UIColor(red: 11.0 / 255.0, green: 130.0 / 255.0, blue: 220.0 / 255.0, alpha: 1).cgColor
            haisOuterShadowView.viewNeumorphicCornerRadius = haisOuterShadowView.frame.width / 2
            haisOuterShadowView.viewNeumorphicShadowRadius = 0.2
            haisOuterShadowView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
            haisOuterShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            haisOuterShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    
    @IBOutlet weak var haisInnerShadowView:SSNeumorphicView!{
        didSet{
            haisInnerShadowView.viewDepthType = .innerShadow
            haisInnerShadowView.viewNeumorphicMainColor =  UIColor(red: 11.0 / 255.0, green: 130.0 / 255.0, blue: 220.0 / 255.0, alpha: 1).cgColor
            haisInnerShadowView.viewNeumorphicCornerRadius = haisInnerShadowView.frame.width / 2
            haisInnerShadowView.viewNeumorphicShadowRadius = 0.2
            haisInnerShadowView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
            haisInnerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            haisInnerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    
    @IBOutlet weak var saveButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowViewNew(view: saveButtonShadowView, shadowType: .outerShadow, cornerRadius: saveButtonShadowView.frame.width / 2, shadowRadius: 0.5)
            saveButtonShadowView.viewNeumorphicMainColor = UIColor(red: 11.0 / 255.0, green: 130.0 / 255.0, blue: 220.0 / 255.0, alpha: 1).cgColor
            saveButtonShadowView.viewNeumorphicLightShadowColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3).cgColor
            saveButtonShadowView.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.5).cgColor
        }
    }
    
    @IBOutlet weak var saveButtonGradientView:GradientDashedLineCircularView!{
        didSet{
            self.createGradientView(view: saveButtonGradientView)
        }
    }
    
    @IBOutlet weak var saveButton:UIButton!
    
    @IBOutlet weak var heightFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: heightFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var weightFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: weightFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var bmiFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: bmiFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var bodyFatFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: bodyFatFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var waistFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: waistFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var restingHRFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: restingHRFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var VO2FieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: VO2FieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var hrvFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: hrvFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var totalFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: totalFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var happinessFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: happinessFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var trackNutritionFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: trackNutritionFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var nutritionFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: nutritionFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var systolicFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: systolicFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var diastolicFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: diastolicFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var ldlFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: ldlFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var hdlFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: hdlFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var cholestrolFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: cholestrolFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var hba1cFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: hba1cFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var triglyceridesFieldSSView:SSNeumorphicView!{
        didSet{
            createShadowViewNew(view: triglyceridesFieldSSView, shadowType: .innerShadow, cornerRadius: 10.5, shadowRadius: 4)
        }
    }
    
    @IBOutlet weak var totalToggle:UIImageView!
    
    @IBOutlet weak var happinessToggle:UIImageView!
    
    @IBOutlet weak var trackNutritionToggle:UIImageView!
    
    @IBOutlet weak var nutritionToggle:UIImageView!
    
    @IBOutlet weak var heightField:UITextField!
    @IBOutlet weak var weightField:UITextField!
    @IBOutlet weak var bmiField:UITextField!
    @IBOutlet weak var bodyFatField:UITextField!
    @IBOutlet weak var waistField:UITextField!
    @IBOutlet weak var restingHRField:UITextField!
    @IBOutlet weak var vo2Field:UITextField!
    @IBOutlet weak var hrvField:UITextField!
    @IBOutlet weak var totalField:UITextField!
    @IBOutlet weak var happinessField:UITextField!
    @IBOutlet weak var trackNutritionField:UITextField!
    @IBOutlet weak var nutritionField:UITextField!
    @IBOutlet weak var systolicField:UITextField!
    @IBOutlet weak var diastolicField:UITextField!
    @IBOutlet weak var ldlField:UITextField!
    @IBOutlet weak var hdlField:UITextField!
    @IBOutlet weak var cholestrolField:UITextField!
    @IBOutlet weak var hba1cField:UITextField!
    @IBOutlet weak var triglyceridesField:UITextField!
    
    @IBOutlet weak var nutritionFieldHeight:NSLayoutConstraint!
    
    // MARK: - Properties
    var totalScore: Double?
    private var healthData: HealthDataNew?
    final private var isPercentagesLoaded = false
    final private var nutritionPercents = [NutritionPercent]()
    final private var trackingNutrition = [TrackingNutrition]()
    final private var happinessSurvey = [TrackingNutrition]()
    final private var totalAssesment = [TrackingNutrition]()
    final private var isLoadedFromServer = false
    var isFromProfile = false
    private var textFields:[UITextField] = [UITextField]()
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLoadedFromServer {
            self.setBodyMassIndex()
        }
        DispatchQueue.global(qos: .background).async {
            self.getTotalScoreOfUser()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.updateHealthData()
    }
    // MARK: - Methods
    
    func initializeUI() {
        self.setDefaultPercents()
        self.setNutritionTracking()
        self.getTotalScoreOfUser()
        self.getHealthData()
        self.getNutritionTrackingPercent()
        textFields = [heightField,weightField,bmiField,bodyFatField,waistField,restingHRField,vo2Field,hrvField,totalField,happinessField,trackNutritionField,nutritionField,systolicField,diastolicField,ldlField,hdlField,cholestrolField,hba1cField,triglyceridesField]
        for textField in textFields{
            textField.delegate = self
        }
    }
    
    private func setFieldsValue(healthData:HealthDataNew){
        heightField.text = (healthData.feet != nil && healthData.feet != 0) ? "\(healthData.feet ?? 0) feet \(healthData.inch ?? 0) inch" : ""
        vo2Field.text = healthData.vO2Max?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        waistField.text = healthData.waistCircumference?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        bodyFatField.text = healthData.bodyFat?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        restingHRField.text = healthData.restingHeartRate?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        weightField.text = (healthData.weight != nil && healthData.weight != 0) ? "\(healthData.weight ?? 0) lbs" : ""
        bmiField.text =  healthData.bmi?.rounded(toPlaces: 1).formattedWithTrailingZeroes
        hrvField.text =  healthData.hrv?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        
        if let totalAssessment = healthData.totalAssessmentToggle,totalAssessment == 1{
            totalToggle.image = UIImage(named: "on toggle")
        }else{
            totalToggle.image = UIImage(named: "off toggle")
        }
        if let happiness = healthData.happinessSurvey,happiness == 1{
            happinessToggle.image = UIImage(named: "on toggle")
        }else{
            happinessToggle.image = UIImage(named: "off toggle")
        }
        if let nutritionTracking = healthData.nutritionTrackingId,nutritionTracking == 1{
            trackNutritionToggle.image = UIImage(named: "on toggle")
            nutritionFieldHeight.constant = 41
        }else{
            trackNutritionToggle.image = UIImage(named: "off toggle")
            nutritionFieldHeight.constant = 0
        }
        if let nutrition = healthData.nutritionTracking,nutritionPercents[nutrition].value != ""{
            nutritionToggle.image = UIImage(named: "on toggle")
        }else{
            nutritionToggle.image = UIImage(named: "off toggle")
        }
        
        guard let nutritionId = healthData.nutritionTracking else{
            nutritionField.text = nutritionPercents[0].value
            return
        }
        totalField.text = totalAssesment[healthData.totalAssessmentToggle ?? 0].value
        happinessField.text = happinessSurvey[healthData.happinessSurvey ?? 0].value
        trackNutritionField.text = trackingNutrition[healthData.nutritionTrackingId ?? 0].value
        nutritionField.text = nutritionPercents[nutritionId].value
        
        systolicField.text = healthData.bloodPressure?.systolic?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        diastolicField.text = healthData.bloodPressure?.diastolic?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        hdlField.text = healthData.panel?.ldh?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        ldlField.text = healthData.panel?.ldl?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        triglyceridesField.text = healthData.panel?.triglycerides?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        cholestrolField.text = healthData.panel?.cholesterol?.rounded(toPlaces: 2).formattedWithTrailingZeroes
        hba1cField.text = healthData.panel?.hba1c?.rounded(toPlaces: 2).formattedWithTrailingZeroes
    }
    
    private func mainFieldValueAt(field: UITextField) -> String? {
        if let value = field.text {
            return value
        }
        return nil
    }
    
    private func panelFieldValueAt(field: UITextField) -> String? {
        if let value = field.text {
            return value
        }
        return nil
    }
    
    private func setUserInteraction(enable: Bool) {
        if enable {
            self.saveButton.alpha = 1.0
        } else {
            self.saveButton.alpha = 0.6
        }
        self.saveButton.isUserInteractionEnabled = enable
    }
    
    private func checkForFieldsEmptyStatus(textField: UITextField?) {
        if mainFieldValueAt(field: bmiField) != nil || mainFieldValueAt(field: vo2Field) != nil || mainFieldValueAt(field: bodyFatField) != nil || mainFieldValueAt(field: systolicField) != nil || mainFieldValueAt(field: diastolicField) != nil || mainFieldValueAt(field: waistField) != nil || mainFieldValueAt(field: nutritionField) != nil || mainFieldValueAt(field: restingHRField) != nil ||
            panelFieldValueAt(field: ldlField) != nil ||
            panelFieldValueAt(field: hdlField) != nil ||
            panelFieldValueAt(field: hba1cField) != nil ||
            panelFieldValueAt(field: cholestrolField) != nil ||
            panelFieldValueAt(field: triglyceridesField) != nil {
            
            //enable action button
            self.setUserInteraction(enable: true)
        } else {
            if let text = textField?.text,
               !text.trim.isEmpty {
                self.setUserInteraction(enable: true)
            } else {
                if isFromProfile{
                    if (mainFieldValueAt(field: heightField) != nil || mainFieldValueAt(field: weightField) != nil){
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
            self.bmiField.text = bmiValue.formattedWithTrailingZeroes
        } else {
            self.bmiField.text = healthData?.bmi?.rounded(toPlaces: 1).formattedWithTrailingZeroes
        }
    }
    
    private func updatedHealthDataParams() -> HealthDataNew? {
        var data = self.healthData
        //        if self.healthData?.panelComplete == nil {
        //            data?.panel = nil
        //        }
        //        if let panelComplete = self.healthData?.panelComplete,
        //           panelComplete == .no {
        //            data?.panel = nil
        //        }
        if let tracking = self.healthData?.nutritionTrackingId,
           tracking == 0 {
            data?.nutritionTracking = nil
        }
        return data
    }
    
    private func formValidated() -> Bool{
        //        var errorCount:Int = 0
        //        for textField in textFields {
        //            let error = fieldsValidation(textField)
        //            errorCount += error
        //        }
        //        if errorCount > 0{
        //            return false
        //        }
        //        else{
        //            return true
        //        }
        if heightField.text!.count == 0 || heightField.text!.hasPrefix(" "){
            return false
        }
        if weightField.text!.count == 0 || weightField.text!.hasPrefix(" "){
            return false

        }
        else if trackNutritionField.text == "Yes" && nutritionField.text?.count == 0{
            self.showAlert(message: "Please Enter Nutrition Value")
            self.nutritionField.becomeFirstResponder()
            return false
        }

        return true
    }
    
    private func fieldsValidation(_ textField:UITextField) -> Int{
        var errorCount = 0
        
        if textField == totalField {
            errorCount = 0
        }
        else if textField == happinessField {
            errorCount = 0
        }
        else if textField == trackNutritionField {
            errorCount = 0
        }
        else if textField == nutritionField && (trackNutritionField.text == "No" || trackNutritionField.text?.count == 0){
            errorCount = 0
        }
        else{
            if let text = textField.text{
                if text.count == 0 || text.hasPrefix(" "){
                    errorCount = 1
                }
            }
        }
        return errorCount
    }
    
    ///validate nutrition fields
    private func validateNutritionTracking() -> Bool{
        if let isTracking = self.healthData?.nutritionTrackingId,
           isTracking == 1 {
            if  healthData?.nutritionTracking != nil {
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    // MARK: Activity sheet helpers
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .nutritionTrackingPercent {
            self.healthData?.nutritionTracking = nutritionPercents[index].id.toInt() - 1
            self.nutritionField.text = self.nutritionPercents[index].value
            if self.nutritionPercents[index].value != ""{
                nutritionToggle.image = UIImage(named: "on toggle")
            }else{
                nutritionToggle.image = UIImage(named: "off toggle")
            }
            self.setUserInteraction(enable: true)
        }
        
        if type == .trackingNutrition{
            self.trackNutritionField.text = self.trackingNutrition[index].value
            self.healthData?.nutritionTrackingId = trackingNutrition[index].id.toInt()
            if self.trackingNutrition[index].id.toInt() == 1{
                trackNutritionToggle.image = UIImage(named: "on toggle")
                nutritionToggle.image = UIImage(named: "off toggle")
                nutritionFieldHeight.constant = 41
                nutritionToggle.isHidden = false
                healthData?.nutritionTracking = nil
                nutritionField.text = ""
            }else{
                trackNutritionToggle.image = UIImage(named: "off toggle")
                nutritionToggle.image = UIImage(named: "off toggle")
                nutritionFieldHeight.constant = 0
                nutritionToggle.isHidden = true
                healthData?.nutritionTracking = nil
                nutritionField.text = ""
            }
        }
        
        if type == .happinessSurvey{
            self.healthData?.happinessSurvey = happinessSurvey[index].id.toInt()
            self.happinessField.text = self.happinessSurvey[index].value
            if self.happinessSurvey[index].id.toInt() == 1{
                happinessToggle.image = UIImage(named: "on toggle")
            }else{
                happinessToggle.image = UIImage(named: "off toggle")
            }
        }
        
        if type == .totalAssesment{
            self.healthData?.totalAssessmentToggle = totalAssesment[index].id.toInt()
            self.totalField.text = self.totalAssesment[index].value
            if self.totalAssesment[index].id.toInt() == 1{
                totalToggle.image = UIImage(named: "on toggle")
            }else{
                totalToggle.image = UIImage(named: "off toggle")
            }
        }
    }
    
    override func cancelSelection(type: SheetDataType) {
        //        if type == .nutritionTrackingPercent {
        //            let section = HAISFormSection.nutrition.rawValue
        //            let indexPath = IndexPath(row: NutritionSection.trackingPercentage.rawValue, section: section)
        //            if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
        //                self.mainFieldsDataArray[section].isHighlighted = false
        //                cell.inputTextField.changeViewFor(selectedState: false)
        //            }
        //        }
    }
    
    // MARK: Api Calls
    
    func updateHealthData() {
        let isValidData = formValidated()
        if isValidData{
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
        else{
            self.showAlert(message: "Please enter your health details")
        }
    }
    
    private func getHealthData() {
        DIWebLayerUserAPI().getUserHealthData(completion: { (data) in
            self.hideLoader()
            self.healthData = data
            self.setFieldsValue(healthData: data)
            if data.bloodPressure == nil {
                self.healthData?.bloodPressure = BloodPressure()
            }
            self.isLoadedFromServer = true
            //            self.setDataSource()
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
    //setting the default percentages, if could not fetch from server
    private func setDefaultPercents() {
        self.nutritionPercents = [NutritionPercent(id: "1", value: "100"),
                                  NutritionPercent(id: "2", value: "70-99"),
                                  NutritionPercent(id: "3", value: "40-69"),
                                  NutritionPercent(id: "4", value: "20-39"),
                                  NutritionPercent(id: "5", value: "1-19")
        ]
    }
    
    private func setNutritionTracking(){
        self.trackingNutrition = [TrackingNutrition(id: "0", value: "No"),
                                  TrackingNutrition(id: "1", value: "Yes")
                                  
        ]
        
        self.happinessSurvey = [TrackingNutrition(id: "0", value: "No"),
                                TrackingNutrition(id: "1", value: "Yes")
        ]
        
        self.totalAssesment = [TrackingNutrition(id: "0", value: "No"),
                               TrackingNutrition(id: "1", value: "Yes")
        ]
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
        view.viewNeumorphicMainColor =  UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.98).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.43).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
}

extension MyHealthInfoViewController:UITextFieldDelegate{
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        
        if textField == nutritionField{
            self.view.endEditing(true)
            if nutritionPercents.isEmpty {
                self.setDefaultPercents()
            }
            self.showSelectionModal(array: self.nutritionPercents, type: .nutritionTrackingPercent)
            return false
        }
        else if textField == trackNutritionField{
            self.view.endEditing(true)
            if trackingNutrition.isEmpty {
                self.setNutritionTracking()
            }
            self.showSelectionModal(array: self.trackingNutrition, type: .trackingNutrition)
            return false
        }
        else if textField == happinessField{
            self.view.endEditing(true)
            if happinessSurvey.isEmpty {
                self.setNutritionTracking()
            }
            self.showSelectionModal(array: self.happinessSurvey, type: .happinessSurvey)
            return false
        }
        else if textField == totalField{
            self.view.endEditing(true)
            if totalAssesment.isEmpty {
                self.setNutritionTracking()
            }
            self.showSelectionModal(array: self.totalAssesment, type: .totalAssesment)
            return false
        }
        else if textField == heightField{
            openHeightPicker()
            return false
        }
        else if textField == weightField{
            openWeightPicker()
            return false
        }
        else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        guard let text = textField.text, text != "" else{
            return
        }
        if textField == systolicField{
            healthData?.bloodPressure?.systolic = text.toDouble()?.rounded(toPlaces: 2)
        }else if textField == diastolicField{
            healthData?.bloodPressure?.diastolic = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == restingHRField{
            healthData?.restingHeartRate = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == bmiField{
            healthData?.bmi = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == vo2Field{
            healthData?.vO2Max = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == waistField{
            healthData?.waistCircumference = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == bodyFatField{
            healthData?.bodyFat = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == cholestrolField{
            self.healthData?.panel?.cholesterol = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == hba1cField{
            healthData?.panel?.hba1c = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == ldlField{
            healthData?.panel?.ldl = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == hdlField{
            healthData?.panel?.ldh = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == triglyceridesField{
            healthData?.panel?.triglycerides = text.toDouble()?.rounded(toPlaces: 2)
        }
        else if textField == hrvField{
            healthData?.hrv = text.toDouble()?.rounded(toPlaces: 2)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn: NSRange, replacementString: String) -> Bool{
        if replacementString.isEmpty {
            return true
        }
        if let text = textField.text {
            if text.isEmpty && replacementString == "." {
                return false
            }
            let decimalCount = text.components(separatedBy: ".").count - 1
            if decimalCount > 0 && replacementString == "." {
                return false
            }
        }
        return true
    }
    
}

extension MyHealthInfoViewController:MyPickerDelegate {
    func tappedOnDoneOrCancel() {
        
    }
    
    func getPickerValue(firstValue: String, secondValue: String) {
        
    }
    
    //For Weight....
    
    func getWeight(weight: Int) {
        healthData?.weight = weight
        weightField.text = "\(weight) lbs"
        self.setBodyMassIndex()
        self.setUserInteraction(enable: true)
    }
    
    //For Height...
    
    func getHeight(heightInFeet: Int, heightIninch: Int) {
        healthData?.feet = heightInFeet
        healthData?.inch = heightIninch
        heightField.text = "\(heightInFeet) feet \(heightIninch) inch"
        self.setBodyMassIndex()
        self.setUserInteraction(enable: true)
    }
}

