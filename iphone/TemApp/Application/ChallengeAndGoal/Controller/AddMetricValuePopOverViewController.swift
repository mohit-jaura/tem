//
//  AddMetricValuePopOverViewController.swift
//  TemApp
//
//  Created by shilpa on 29/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit


protocol MetricData {
    func getMetricValue(value:String,metric:Metrics)
}

class AddMetricValuePopOverViewController: DIBaseController {

    // MARK: Properties....
    var currentMetric: Metrics = Metrics.steps
    var delegate:MetricData?
    var currentValue: Double?
    
    // MARK: IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var inputTextField: CustomTextField!
    
    // MARK: IBActions....
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if isValidMatric() {
            delegate?.getMetricValue(value: inputTextField.text!,metric:self.currentMetric)
            self.dismissContentView()
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismissContentView()
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentView.roundCorners([.topLeft, .topRight], radius: 10.0)
    }
    
    // MARK: Helpers
    
    private func isValidMatric() -> Bool {
        var message:String?
        if (inputTextField.text?.isBlank == nil) || (inputTextField.text?.isBlank)! {
            message = AppMessages.Metric.emptyValue
        }
        if message != nil {
            showAlert(withTitle: AppMessages.AlertTitles.Alert, message: message)
            return false
        }
        return true
    }
    
    
    /// setting the frame zero
    private func setInitialFrameOfBackgroundView() {
        self.backgroundView.frame = CGRect(x: 0, y: view.frame.height, width: 0, height: 0)
    }
    
    /// animate the view height to fit the main screen height
    private func animateContentView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        })
    }
    
    /// animate the view height to zero and dismiss the current controller
    private func dismissContentView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.setInitialFrameOfBackgroundView()
            self.view.layoutIfNeeded() // call it also here to finish pending layout operations
        }) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// setting the view layout for different metrices
    private func setViewLayout() {
        self.setInitialFrameOfBackgroundView()
        self.inputTextField.delegate = self
        self.inputTextField.keyboardType = .numberPad
        if let value = self.currentValue,
            value != 0 {
            self.inputTextField.text = value.formatted ?? ""
        }
        switch self.currentMetric {
        case .steps:
            self.inputTextField.placeholder = Constant.Metrics.stepsCount
        case .distance:
            self.inputTextField.keyboardType = .decimalPad
            self.inputTextField.placeholder = Constant.Metrics.distanceValue
        case .calories:
            self.inputTextField.placeholder = Constant.Metrics.maxCalories
        case .totalActivites:
            self.inputTextField.placeholder = Constant.Metrics.totalActivities
        case .totalActivityTime:
            self.inputTextField.placeholder = Constant.Metrics.totalActivityTime
        default:
            break
        }
    }
    
    
    /// this is called when the input is entered in the textfield for the current selected metrics as distance.
    ///
    /// - Parameters:
    ///   - textField: textfield on which editing is being done
    ///   - range: range
    ///   - string: the value of the text entered
    /// - Returns: true or false
    func shoouldChangeCharactersForDistanceMetricField(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        
        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
}

// MARK: UITextFieldDelegate
extension AddMetricValuePopOverViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: true)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: false)
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch currentMetric {
        case .distance:
            return self.shoouldChangeCharactersForDistanceMetricField(textField: textField, range: range, replacementString: string)
        default:
            return true
        }
    }
}
