//
//  AddTimePickerVC.swift
//  TemApp
//
//  Created by PrabSharan on 27/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class AddTimePickerVC: UIViewController {
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    var doneButton:H_M_S_Competion?
    @IBOutlet var timePickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    func initialise() {
        timePickerView.delegate = self
        timePickerView.dataSource = self
    }

    @IBAction func doneButtonPickerAction(_ sender: Any) {
        self.dismiss(animated: true) {
            self.doneButton?(self.hour,self.minutes,self.seconds)
        }
    }
   

}
extension AddTimePickerVC: UIPickerViewDelegate, UIPickerViewDataSource {

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                return 24
            case 1, 2:
                return 60
            default:
                return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return pickerView.frame.size.width/3
        }

    
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            switch component {
            case 0:
                return "\(row) hour"
            case 1:
                return "\(row) min"
            case 2:
                return "\(row) sec"
            default:
                return ""
            }
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
            case 0:
                hour = row
            case 1:
                minutes = row
            case 2:
                seconds = row
            default:
                break 
            }
        }
    }
