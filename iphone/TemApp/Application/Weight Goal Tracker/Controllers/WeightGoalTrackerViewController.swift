//
//  WeightGoalTrackerViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 03/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

final class WeightGoalTrackerViewController: DIBaseController, LoaderProtocol, NSAlertProtocol {
    
    // MARK: IBOutlets
    @IBOutlet var backView: [SSNeumorphicView]!
    @IBOutlet var buttonbackView: [SSNeumorphicView]!
    @IBOutlet weak var startingWeightField: UITextField!
    @IBOutlet weak var goalWeightField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var durationField: UITextField!
    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var healthInfoButton: UIButton!
    @IBOutlet weak var healthInfoHeightConstraint: NSLayoutConstraint!

    // MARK: Properies
    private let durationList = Constant.GroupActivityConstants.durationList
    private let viewModal = WeightGoalViewModal()
    var createGoalHandler: OnlySuccess?
    var isHealthGoalTapped = false
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setWeightGoalData(data: viewModal.modal ?? WeightGoalModal())
        for view in backView {
            view.setOuterDarkShadow()
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            view.viewDepthType = .innerShadow
        }

        for view in buttonbackView {
            view.setOuterDarkShadow()
            if view.tag == 1 { // tag 1 is assigned to start button view in storyboard
                view.viewNeumorphicCornerRadius = view.frame.height / 2
            }
            if view.tag == 2 && !isHealthGoalTapped{ //for listing the health info typ
                view.isHidden = true
                healthInfoHeightConstraint.constant = 0
            }
            if isHealthGoalTapped{
                viewModal.modal?.healthInfoType = HealthInfoType(rawValue: 1)?.rawValue
                goalWeightField.placeholder = "BMI"
                startingWeightField.placeholder = "STARTING BMI"
            }
            view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
        //   configureTransformationForButton()
        setTextFieldsUI()
    }
    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func bmiTapped(_ sender: Any) {
        showSelectionModal(array: HealthInfoType.allCases, type: .healthInfoType)
    }

    @IBAction func checkInBtnTapped(_ sender: UIButton) {
        showSelectionModal(array: CheckInType.allCases, type: .checkInFrequency)
    }
    
    @IBAction func startBtnTapped(_ sender: UIButton) {
        addWeightGoal()
    }
    // MARK: Methods
    private func setTextFieldsUI() {
        startingWeightField.attributedPlaceholder = NSAttributedString(
            string: startingWeightField.placeholder ?? "STARTING WEIGHT",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        goalWeightField.attributedPlaceholder = NSAttributedString(
            string: goalWeightField.placeholder ?? "GOAL WEIGHT",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        startDateField.attributedPlaceholder = NSAttributedString(
            string: startDateField.placeholder ?? "START DATE",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        durationField.attributedPlaceholder = NSAttributedString(
            string: durationField.placeholder ?? "DURATION",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
    
    private func showDatePicker(textfield: UITextField, action: Selector, mode: UIDatePicker.Mode, selectedDate: Date, minDate: Date, maxDate: Date) {
        datePickerView = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePickerView?.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        datePickerView!.datePickerMode = mode
        datePickerView?.setDate(selectedDate, animated: true)
        datePickerView?.minimumDate = minDate
        datePickerView?.maximumDate = maxDate
        textfield.inputView = datePickerView
        datePickerView?.addTarget(self, action: action, for: .valueChanged)
    }
    
    @objc private func startDateChanged(_ sender: UIDatePicker) {
        viewModal.modal?.startDate = sender.date.timestampInMilliseconds
        startDateField.text = sender.date.toString(inFormat: .displayDate)
    }
    
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .checkInFrequency {
            viewModal.modal?.frequency = CheckInType.allCases[index].rawValue
            checkInBtn.setTitle(CheckInType.allCases[index].getTitle(), for: .normal)
        } else if type == .duration {
            viewModal.modal?.duration = durationList[index]
            durationField.text = durationList[index]
        } else if type == .healthInfoType{
            viewModal.modal?.healthInfoType = (HealthInfoType(rawValue: index)?.rawValue ?? 0) + 1 // 0  is already set for the weight so we need to start the other factors starting from 1
            let title = HealthInfoType(rawValue: index)?.getTitle()
            healthInfoButton.setTitle(title, for: .normal)
            goalWeightField.placeholder = "GOAL \(title?.uppercased() ?? "")"
            startingWeightField.placeholder = "CURRENT \(title?.uppercased() ?? "")"
        }
    }
    
    private func showDurationListingOnView(array: [String]) {
        self.showSelectionModal(array: array, type: .duration)
    }
    
    private func addWeightGoal() {
        self.showHUDLoader()
        viewModal.isHealthGoal = self.isHealthGoalTapped
        viewModal.callAddWeightGoalAPI { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error {
                self?.showAlert(withError: error)
            } else {
                if let createGoalHandler = self?.createGoalHandler {
                    createGoalHandler()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    private func setWeightGoalData(data: WeightGoalModal) {
        if !isHealthGoalTapped{
            startingWeightField.text = "\(data.currentHealthUnits ?? 0) lbs"
        }
    }
    
    func openWeightPicker(weight: Int, type: WeightPickerType) {
        let picker = UIPickerManager()
        picker.delegate = self
        picker.selectedWeight = weight
        picker.weightPickerType = type
        picker.addPickerView()
    }
}

extension WeightGoalTrackerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == startDateField {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == startDateField as UITextField {
            let startDate = viewModal.modal?.startDate?.timestampInMillisecondsToDate ?? Date()
            showDatePicker(textfield: startDateField,
                           action: #selector(startDateChanged),
                           mode: .date,
                           selectedDate: startDate,
                           minDate: Date(),
                           maxDate: Constant.Calendar.endDate)
            viewModal.modal?.startDate = startDate.timestampInMilliseconds
            startDateField.text = startDate.toString(inFormat: .displayDate)
        } else if textField == durationField as UITextField {
            self.view.endEditing(true)
            showDurationListingOnView(array: durationList)
        } else if textField == startingWeightField as UITextField {
            if !isHealthGoalTapped{
                viewModal.modal?.currentHealthUnits = Int(startingWeightField.text ?? "")
                self.view.endEditing(true)
                let defaultWeight = 120
                if let weight = viewModal.modal?.currentHealthUnits {
                    let unWrappedWeight = weight <= 0 ? defaultWeight : weight
                    openWeightPicker(weight: unWrappedWeight, type: .startingWeight)
                } else {
                    if let currentWeight = UserManager.getCurrentUser()?.weight {
                        let unWrappedWeight = currentWeight <= 0 ? defaultWeight : currentWeight
                        openWeightPicker(weight: unWrappedWeight, type: .startingWeight)
                    } else {
                        openWeightPicker(weight: defaultWeight, type: .startingWeight)
                    }
                }
            }
        } else if textField == goalWeightField as UITextField {
            if !isHealthGoalTapped{
                viewModal.modal?.goalHelathUnits = Int(goalWeightField.text ?? "")
                self.view.endEditing(true)
                let defaultWeight = 120
                if let weight = viewModal.modal?.goalHelathUnits {
                    let unWrappedWeight = weight <= 0 ? defaultWeight : weight
                    openWeightPicker(weight: unWrappedWeight, type: .goalWeight)
                } else {
                    if let currentWeight = UserManager.getCurrentUser()?.weight {
                        let unWrappedWeight = currentWeight <= 0 ? defaultWeight : currentWeight
                        openWeightPicker(weight: unWrappedWeight, type: .goalWeight)
                    } else {
                        openWeightPicker(weight: defaultWeight, type: .goalWeight)
                    }
                }
            }
        }
    }
            func textFieldDidEndEditing(_ textField: UITextField) {
                if textField == startingWeightField as UITextField {
                    if isHealthGoalTapped{
                        viewModal.modal?.currentHealthUnits = Int(textField.text ?? "")
                    }
                } else if textField == goalWeightField as UITextField{
                    if isHealthGoalTapped{
                        viewModal.modal?.goalHelathUnits = Int(textField.text ?? "")

                    }
                }

            }
        }

        extension WeightGoalTrackerViewController: MyPickerDelegate {
            func tappedOnDoneOrCancel() {}

            func getPickerValue(firstValue: String, secondValue: String) {}

            func getWeightGoalTracker(weight: Int, type: WeightPickerType) {
                switch type {
                case .startingWeight:
                    startingWeightField.text = "\(weight) lbs"
                    viewModal.modal?.currentHealthUnits = weight
                case .goalWeight:
                    goalWeightField.text = "\(weight) lbs"
                    viewModal.modal?.goalHelathUnits = weight
                }
            }
        }
