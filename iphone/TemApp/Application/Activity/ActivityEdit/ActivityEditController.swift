//
//  ActivityEditController.swift
//  TemApp
//
//  Copyright © 2020 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

struct ActivityLogData {
    var duration: Double?
    var distance: Double?
    var name: String?
    var activityTypeId: Int?
    var activityType: Int?
    var calories: Double?
    var id : String?
    var rating: Int?
}

class ActivityEditController: DIBaseController {
    
    private var activityTypesArray: [ActivityData]? //this will hold the list of activity
    var activityData: UserActivity?
    var activityIndex: Int = -1
    var isFromActivityLog = false
    var onUpdate: (() -> Void)?
    var categoryType: ActivityCategoryType.RawValue = ActivityCategoryType.mentalStrength.rawValue
    var activityLogData: ActivityLogData = ActivityLogData()
    var ratingButtons:[UIButton] = [UIButton]()
    var selectedRateActivityNumber:Int?
    
    @IBOutlet weak var activityTypeButton: UIButton!
    @IBOutlet weak var activityDurationTxtFld: CustomTextField!
    @IBOutlet weak var activityDistanceTxtFld: CustomTextField!
    @IBOutlet weak var shadowLineView:UIView!
    @IBOutlet var shadowViews: [SSNeumorphicView]! {
        didSet {
            for view in shadowViews {
                view.viewDepthType = .outerShadow
                view.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.25).cgColor
                view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.25).cgColor
                view.viewNeumorphicMainColor = UIColor.black.cgColor
                view.viewNeumorphicCornerRadius = 8.0
                view.viewNeumorphicShadowOpacity = 0.6
            }
            
        }
    }
    
    @IBOutlet weak var badActivityButton: UIButton!
    @IBOutlet weak var poorActivityButton: UIButton!
    @IBOutlet weak var averageActivityButton: UIButton!
    @IBOutlet weak var goodActivityButton: UIButton!
    @IBOutlet weak var greatActivityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    func addShadowToView() {
        shadowLineView.layer.masksToBounds = false
        shadowLineView.layer.shadowRadius = 4
        shadowLineView.layer.shadowOpacity = 1
        shadowLineView.layer.shadowColor = UIColor.gray.cgColor
        shadowLineView.layer.shadowOffset = CGSize(width: 0 , height:2)
    }
    @IBAction func activityTapped(_ sender: UIButton) {
        self.showNewActivitiesList(activities: self.activityTypesArray ?? [])
    }
    
    func initialize() {
        activityDistanceTxtFld.attributedPlaceholder = NSAttributedString(
            string: "DISTANCE",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.midnightBlue])
        activityDurationTxtFld.attributedPlaceholder = NSAttributedString(
            string: "DURATION",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.midnightBlue])
        addShadowToView()
        self.getActivitiesFromBackend()
        if isFromActivityLog {
            activityTypeButton.setTitle(activityLogData.name, for: .normal)
            if let time = activityLogData.duration, let distance = activityLogData.distance {
                let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: Int(time))
                
                let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                
                activityDistanceTxtFld.text = "\(distance)"
                activityDurationTxtFld.text = "\(displayTime)"
            }
            
        } else {
            if (self.activityData != nil) {
                activityTypeButton.setTitle(self.activityData?.name, for: .normal)
                //  self.activityTypeTxtFld.text = self.activityData?.name
                self.activityDurationTxtFld.text = self.activityTimeAsString(activity: self.activityData ?? UserActivity())
                if (self.activityData?.type == 1) {
                    self.activityDistanceTxtFld.isUserInteractionEnabled = true
                    self.activityDistanceTxtFld.text = self.activityData?.distance?.stringValue
                } else {
                    self.activityDistanceTxtFld.isUserInteractionEnabled = false
                    self.activityDistanceTxtFld.text = "N/A"
                }
            }
        }
        ratingButtons = [goodActivityButton,poorActivityButton,averageActivityButton,greatActivityButton,badActivityButton]
        selectedRateActivityNumber = activityLogData.rating
        for button in ratingButtons where button.tag == selectedRateActivityNumber {
            button.setImage(UIImage(named: "selectActivity"), for: .normal)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func update(_ sender: Any) {
        self.updateActivityApiCall()
    }
    
    @IBAction func rateActivityButtonsTapped(_ sender: UIButton) {
        self.configureRateActivityLayouts(selectedButton: sender)
    }
    
    func configureRateActivityLayouts(selectedButton: UIButton) {
        selectedButton.setImage(UIImage(named: "selectActivity"), for: .normal)
        selectedRateActivityNumber = selectedButton.tag
        for button in ratingButtons where button.tag != selectedButton.tag {
            button.setImage(UIImage(named: "Rate Your wellness unselect"), for: .normal)
        }
    }
    
    private func updateActivityApiCall() {
        if isConnectedToNetwork() {
            self.showLoader()
            
            let activityType = self.findActivityType()
            let timeSpent = self.activityTimeAsNumber(value: self.activityDurationTxtFld.text ?? "") ?? 0
            //            let timeSpent = self.activityTimeAsNumber(value: self.activityDurationTxtFld.text ?? "") ?? 0
            let distanceCovered = self.activityDistanceTxtFld.text?.toDouble()
            let calories = HealthKit.instance?.calculateCalories(duration: Double(timeSpent), metValue: activityType?.metValue ?? 0) ?? 0
            
            var params: [String: Any] = [:]
            if isFromActivityLog {
                params["activityId"] = activityLogData.activityTypeId
                params["distanceCovered"] = Double(activityDistanceTxtFld.text ?? "") ?? 0.0
                params["timeSpent"] =  timeSpent//activityLogData.duration
                params["calories"] = calories//activityLogData.calories
                params["id"] = activityLogData.id
                params["activityName"] = activityTypeButton.currentTitle
                params["rating"] = selectedRateActivityNumber  // correct that rating param key after api changes
            } else {
                params["id"] = self.activityData?.id
                params["activityId"] = activityType?.id
                params["distanceCovered"] = distanceCovered
                params["timeSpent"] = timeSpent
                params["calories"] = calories
                params["activityName"] = activityTypeButton.currentTitle
            }
            DIWebLayerReportsAPI().updateActivity(parameters: params, completion: { (_) in
                self.hideLoader()
                self.completionAfterUpdateActivity(index: self.activityIndex)
                self.activityData?.image = activityType?.image
                self.activityData?.name = activityType?.name
                self.activityData?.distance = distanceCovered
                self.activityData?.timeSpent = Double(timeSpent)
                self.activityData?.calories = calories
                self.activityData?.rating = self.activityLogData.rating
                if let updateCallback = self.onUpdate {
                    updateCallback()
                }
            }, failure: { (error) in
                self.hideLoader()
                if let message = error.message {
                    self.showAlert(message: message)
                }
            })
        }
    }
    
    private func getActivitiesFromBackend() {
        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerActivityAPI().getUserActivity( success: { (activities) in
                self.hideLoader()
                
                for activityCount in 0..<activities.count where self.categoryType == activities[activityCount].categoryType {
                    self.activityTypesArray = activities[activityCount].type
                    // self.tableView.showEmptyScreen("")
                }
                
                //    self.activityTypesArray = activities[0].type
                //               let a = self.findActivityType()
                //                if a?.activityType == 1 {
                //                    self.activityDistanceTxtFld.isUserInteractionEnabled = true
                //                    self.activityDistanceTxtFld.text = self.activityData?.distance?.stringValue
                //                }
                //                else {
                //                    self.activityDistanceTxtFld.isUserInteractionEnabled = false
                //                    self.activityDistanceTxtFld.text = "N/A"
                //                }
            }, failure: { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            })
        }
    }
    
    private func findActivityType() -> ActivityData? {
        let activityTypeIndex = self.activityTypesArray?.firstIndex(where: {
            $0.name == self.activityTypeButton.currentTitle
        })
        let activityType = self.activityTypesArray?[activityTypeIndex ?? 0]
        return activityType
    }
    
    private func showNewActivitiesList(activities: [ActivityData]) {
        DispatchQueue.main.async {
            self.showSelectionModal(array: activities, type: .activity)
        }
    }
    
    override func handleSelection(index: Int, type: SheetDataType) {
        switch type {
        case .activity:
            let activity = self.activityTypesArray?[index]
            self.activityTypeButton.setTitle(activity?.name, for: .normal)
            if activity?.activityType == 1 {
                self.activityDistanceTxtFld.isUserInteractionEnabled = true
                self.activityDistanceTxtFld.text = self.activityData?.distance?.stringValue
            } else {
                self.activityDistanceTxtFld.isUserInteractionEnabled = false
                self.activityDistanceTxtFld.text = "N/A"
            }
        default:
            break
        }
    }
    
    private func completionAfterUpdateActivity(index: Int) {
        self.navigationController?.popViewController(animated: true)
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
        } else if parts.count == 2 {
            minutes = parts[0].toInt()
            seconds = parts[1].toInt()
        } else if parts.count == 1 {
            seconds = parts[0].toInt()
        }
        
        let result = hours * 60 * 60 + minutes * 60 + seconds
        return result
    }
    
    //    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
    //        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    //    }
    
    func formattedTimeWithLeadingZeros(hours: Int, minutes: Int, seconds: Int) -> String {
        // Format time vars with leading zero
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let displayTime = "\(strHours):\(strMinutes):\(strSeconds)"
        return displayTime
    }
}
