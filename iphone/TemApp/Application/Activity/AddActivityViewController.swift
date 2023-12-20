//
//  AddActivityViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 28/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import simd
import FacebookCore

struct Validations{
    var isDateAdded = false
    var isCategoryAdded = false
    var isActivityAdded = false
}

struct Category {
    var type: Int
    var name: String
}
struct RateActivityData{
    var name: String
    var id: Int
}
class AddActivityViewController: DIBaseController {
    
    // MARK: variables
    var dateTimeStamp = 0
    var startDatePicker: UIDatePicker?
    var categoryType = 0  //will show the category out of 5 categories
    var activityArray:[ActivityData] = []//this will hold the list of activity
    var validations = Validations()
    var activityData: UserActivity? = nil
    var rating = 0
    var activityLogData:[String:Any] = [:]
    var activityType = 0
    var distanceCovered = 0.0
    var activityId = 0
    var activityIndex = 0
    var activityIcon = ""
    var timePickerView:UIDatePicker?
    var timeSpent = 0
    var activityMongoId = ""
    var startDate = 0
    var rateActivityData: [RateActivityData] = [RateActivityData(name: "Bad", id: 1),
                                                RateActivityData(name: "Poor", id: 2),
                                                RateActivityData(name: "Average", id: 3),
                                                RateActivityData(name: "Good", id: 4),
                                                RateActivityData(name: "Great", id: 5)]
    // MARK: IBOutlet
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    //    @IBOutlet weak var distanceButton: UIButton!
    //    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var distanceTExtField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var startDateField:UITextField!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var dateShadowView: UIView!
    @IBOutlet weak var categoryShadowView: UIView!
    @IBOutlet weak var activityShadowView: UIView!
    @IBOutlet weak var durationShadowView: UIView!
    @IBOutlet weak var distanceShaadowView: UIView!
    @IBOutlet weak var rateShadowView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView.addShadowToView()
        self.initialize()
        
        
    }
    
    // MARK: IBAction
    
    @IBAction func saveTapped(_ sender: UIButton) {
        if  validations.isDateAdded,validations.isCategoryAdded,validations.isActivityAdded == true{
            addActivityApiCall()
        }else{
            showAlert( message: "Please check activity details", okayTitle: "ok")
        }
    }
    
    @IBAction func categoryTapped(_ sender: UIButton) {
        self.showSelectionModal(array: Utility.categories , type: .activityCategory)
    }
    
    @IBAction func activityTapped(_ sender: UIButton) {
        self.showLoader()
        getActivitiesFromBackend(categoryType: categoryType)
        
    }
    @IBAction func rateButtonTapped(_ sender: UIButton) {
        self.showSelectionModal(array: rateActivityData , type: .rateActivity)
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Helper function
    
    func setPlaceholders(){
        
        distanceTExtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: distanceTExtField.frame.height))
        distanceTExtField.leftViewMode = .always
        durationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: distanceTExtField.frame.height))
        durationTextField.leftViewMode = .always
    }

    private func showNewActivitiesList(activities: [ActivityData]) {
        DispatchQueue.main.async {
            self.showSelectionModal(array: activities, type: .activity)
        }
    }
    
    @objc func updateDateField(sender: UIDatePicker) {
        dateButton.setTitle(formatDateForDisplay(date: sender.date), for: .normal)
        validations.isDateAdded = true
        //startDateField.text = formatDateForDisplay(date: sender.date)
    }
    
    private func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    
    @objc func onClickDoneButton() {
        if let sender = startDatePicker{
            let date = sender.date.toString(inFormat: .displayDate)
            if let date = date?.toDate(dateFormat: .displayDate) {
                let dateFMT = DateFormatter()
                        dateFMT.locale = Locale(identifier: "en_US_POSIX")
                        dateFMT.dateFormat = "yyyyMMdd'T'HHmmss.SSSS"
                print(String(format: "%@", dateFMT.string(from: date)))
                dateTimeStamp = sender.date.timeStamp
                dateButton.setTitle(formatDateForDisplay(date: sender.date), for: .normal)
                validations.isDateAdded = true
            }
        }
        if let sender = timePickerView{
            
            timeSpent =  Int(sender.countDownDuration)
            let (h,m,_) = secondsToHoursMinutesSeconds(seconds: Int(sender.countDownDuration))
            durationTextField.text = "\(String(format: "%02d", h)) : \(String(format: "%02d", m)) "
        }
        self.view.endEditing(true)
    }
    override func handleSelection(index: Int, type: SheetDataType) {
        switch type {
        case .activity:
            validations.isActivityAdded = true
            let a = self.activityArray[index]
            self.activityButton.setTitle(a.name?.capitalized, for: .normal)
            activityIndex = index
            if let id = a.id, let image = a.image{
                activityId = id
                activityIcon = image
            }
            activityType = a.activityType ?? 0
            if a.activityType == 1 {
                self.distanceTExtField.isUserInteractionEnabled = true
               
                if activityData?.distance != nil{
                    self.distanceTExtField.text = "\(self.activityData?.distance?.stringValue) mi"
                }else{
                    self.distanceTExtField.text = self.activityData?.distance?.stringValue
                }
                distanceTExtField.textColor = UIColor.appThemeColor
            }
            else {
                self.distanceTExtField.isUserInteractionEnabled = false
                distanceTExtField.textColor = UIColor.midnightBlue
                self.distanceTExtField.text = "N/A"
            }
        case .activityCategory:
            validations.isCategoryAdded = true
            activityButton.isEnabled = true
            let a = Utility.categories[index]
            self.categoryButton.setTitle(a.name.capitalized, for: .normal)
            categoryType = a.type
            self.activityButton.setTitle("Activity", for: .normal)
            self.distanceTExtField.text = nil
        case .rateActivity:
            let a = self.rateActivityData[index]
            rating = a.id
            self.rateButton.setTitle(a.name.capitalized, for: .normal)
        default:
            break
        }
    }
    
    func getActivitiesFromBackend(categoryType: ActivityCategoryType.RawValue){
        DIWebLayerActivityAPI().getUserActivity( success: { (activities) in
            self.hideLoader()
            self.activityArray.removeAll()
            for activityCount in 0..<activities.count{
                if categoryType == activities[activityCount].categoryType{
                    self.activityArray = activities[activityCount].type
                }
            }
            if self.activityArray.count > 0{
                self.showNewActivitiesList(activities: self.activityArray )
            }else{
                self.showAlert( message:AppMessages.GroupActivityMessages.activityNotFound )
            }
            
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
            
        }
    }
    
    func initialize() {
        startDateField.delegate = self
        durationTextField.delegate = self
        distanceTExtField.delegate = self
        setPlaceholders()
        self.distanceTExtField.keyboardType = UIKeyboardType.decimalPad
        if (self.activityData != nil) {
            self.durationTextField.text = self.activityTimeAsString(activity: self.activityData!)
            if (self.activityData?.type == 1) {
                self.distanceTExtField.isUserInteractionEnabled = true
                self.distanceTExtField.text = "\(self.activityData?.distance?.stringValue) mi"
            }
            else {
                self.distanceTExtField.isUserInteractionEnabled = false
                distanceTExtField.textColor = UIColor.midnightBlue
                self.distanceTExtField.text = "N/A"
            }
        }
    }
    
   
    
    private func addActivityApiCall() {
        if isConnectedToNetwork() {
            self.showLoader()
          
            
                                               
            DIWebLayerReportsAPI().addActivity(parameters:generateParams(isCompleted: false), completion: { [self] (success) in
                activityMongoId = success.id
                self.startDate = success.startDate
                let params: [String: Any] = ["activities": [generateParams(isCompleted: true)]]
                
                DIWebLayerReportsAPI().completeActivity(parameters: params, completion: { msg in
                    self.hideLoader()
                    print("------>>>>>>\(msg)")
                    self.showAlert( message: "Activity has been added successfully !", okayTitle: "Ok", okCall: {
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                }, failure: {(error) in
                                        self.hideLoader()
                                        if let message = error.message {
                                            self.showAlert(message: message)
                                        }})
            }) { (error) in
                self.hideLoader()
                if let message = error.message {
                    self.showAlert(message: message)
                }
            }
        }
    }
    
    func generateParams(isCompleted: Bool) -> [String: Any]{
      
        let endDate = dateTimeStamp.toDate.adding(seconds: timeSpent)
        distanceCovered = Double(self.distanceTExtField.text ?? "0") ?? 0.0
        
        let startDate = dateTimeStamp.toDate
        let dateDifference = endDate.timeIntervalSince(startDate)
        let calories = HealthKit.instance?.calculateCalories(duration: dateDifference, metValue: activityArray[activityIndex].metValue ?? 0) ?? 0
       let totalCalories = calculateCalories(calories: calories, duration: Double(timeSpent), metValue: activityArray[activityIndex].metValue ?? 0)
        
        var params: [String: Any] = [:]
        
        if isCompleted{
            params["startDate"] = self.startDate
            params["categoryType"] = categoryType
            params["activityType"] = activityType
            params["timeSpent"] = timeSpent // duration in seconds
            params["activityName"] = activityButton.currentTitle
            params["distanceCovered"] = distanceCovered
            params["rating"] = rating
            params["activityId"] = activityMongoId
            params["endDate"] = endDate.timeStamp
            params["date"] = dateTimeStamp
            params["activityImage"] = activityIcon
            params["calories"] = totalCalories
        } else {
            params["activityId"] = activityId
            params["activityType"] = activityType
            params["activityTarget"] = ""
            params["isScheduled"] = 0
        }
        
        
        return params
    }
    
    //check if user has any linked device on "Link devices" screen, if not, then if the calories count is zero then calculate it
    func calculateCalories(calories: Double?, duration: Double?, metValue: Double?) -> Double? {
        let timeInSeconds = duration ?? 0
        let timeInHours = timeInSeconds/3600
        return Utility.calculatedCaloriesFrom(metValue: metValue ?? 0, duration: timeInHours)
    }
    
    override func datePickerValueChanged(sender:UIDatePicker) {
        dateTimeStamp = sender.date.timeStamp
    }
    
    func activityTimeAsString(activity: UserActivity) -> String? {
        if let time = activity.timeSpent?.toInt() {
            let timeConverted = self.secondsToHoursMinutesSeconds(seconds: time)
            let displayTime = self.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
            //self.distOrTimMeasure = "\(displayTime) hrs"
            return displayTime
        }
        return nil
    }
    func activityTimeAsNumber(value: String) -> Int? {
        var hours = 0
        var minutes = 0
        var seconds = 0
        
        let parts = value.components(separatedBy: ":")
        if parts.count == 3 {
            hours = parts[0].toInt()
            minutes = parts[1].toInt()
            seconds = parts[2].toInt()
        }
        else if parts.count == 2 {
            minutes = parts[0].toInt()
            seconds = parts[1].toInt()
        }
        else if parts.count == 1 {
            seconds = parts[0].toInt()
        }
        
        let result = hours * 60 * 60 + minutes * 60 + seconds
        return result
    }
    
    
    
    func formattedTimeWithLeadingZeros(hours: Int, minutes: Int, seconds: Int) -> String {
        // Format time vars with leading zero
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let displayTime = "\(strHours):\(strMinutes):\(strSeconds)"
        return displayTime
    }
    
    @objc private func startDateChanged(sender: UIDatePicker) {
//        dateButton.setTitle(formatDateForDisplay(date: sender.date), for: .normal)
//        validations.isDateAdded = true
        
        
        timeSpent =  Int(sender.countDownDuration)
        let (h,m,_) = secondsToHoursMinutesSeconds(seconds: Int(sender.countDownDuration))
        durationTextField.text = "\(String(format: "%02d", h)) : \(String(format: "%02d", m)) "
    }
}

// MARK: UITextFieldDelegate

extension AddActivityViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == startDateField {
            //set date picker as input view for the textfield
            if self.startDatePicker == nil {
                self.startDatePicker = UIDatePicker()
            }
            if #available(iOS 13.4, *) {
                self.startDatePicker?.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            self.startDatePicker?.minimumDate = Date()
            self.startDatePicker?.datePickerMode = .date
        //    self.startDatePicker?.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
            
            textField.inputView = self.startDatePicker
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onClickDoneButton))
            
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()
            textField.inputAccessoryView = toolBar
            
            datePickerValueChanged(sender: datePickerView ?? UIDatePicker())
        }
        else if textField == durationTextField{
  
            if self.timePickerView == nil {
                self.timePickerView = UIDatePicker()
            }
            if #available(iOS 13.4, *) {
                self.timePickerView?.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            self.timePickerView?.datePickerMode = .countDownTimer
         
            
            textField.inputView = self.timePickerView
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onClickDoneButton))
            
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()
            textField.inputAccessoryView = toolBar
            
            
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == distanceTExtField{
            let countdots = textField.text?.components(separatedBy: ".").count ?? 1

            if countdots > 1 && string == "."
            {
                return false
            }
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == distanceTExtField, let _ = distanceTExtField.text{
//         //   textField.text = "\(text) mi"
//        }
    }
    
}
extension Date {
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

