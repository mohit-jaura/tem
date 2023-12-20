//
//  DynamicPickerView.swift
//  TemApp
//
//  Created by Harpreet_kaur on 21/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
//class PickerValue {
//    var id:Int?
//    var value:String?
//}


class DynamicPickerView: UIView {
    
    
    // MARK: Variables......
    var firstComponentItems:[String] = []
    var secondComponentItems:[String] = []
    var numberOfComponents:Int = 1
    var firstComponentValue:String?
    var secondComponentValue:String?
    var delegate:MyPickerDelegate?
    
    //For Weight.....
    var selectedWeight:Int?
    private var selectedRowForWeight:Int = 0
    
    // MARK: @IBOutlets....
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: App life cycle...
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func intializer() {
        pickerView.reloadAllComponents()
        // getInitialValue()
    }
    
    //    private func getInitialValue() {
    //
    //        if (firstComponentValue != nil && firstComponentItems.contains(firstComponentValue ?? 0 )) {
    //            let value = firstComponentItems.firstIndex(of: firstComponentValue ?? 0)!
    //            pickerView.selectRow(value, inComponent: 0, animated: true)
    //        }
    //
    //        if (secondComponentValue != nil && secondComponentItems.contains(secondComponentValue!)) {
    //            let value = secondComponentItems.firstIndex(of: secondComponentValue!)!
    //            pickerView.selectRow(value, inComponent: 1, animated: true)
    //        }
    //    }
    
    // MARK: @IBAction methods.....
    
    @IBAction func removeButton(_ sender: UIButton) {
          delegate?.tappedOnDoneOrCancel()
        self.removeFromSuperview()
    }
    @IBAction func doneButton(_ sender: UIButton) {
        if firstComponentValue == nil {
            firstComponentValue = firstComponentItems.first
        }
        if secondComponentValue == nil {
            secondComponentValue = secondComponentItems.first
        }
        delegate?.getPickerValue(firstValue: firstComponentValue ?? "", secondValue: secondComponentValue ?? "")
        delegate?.tappedOnDoneOrCancel()
        self.removeFromSuperview()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
         delegate?.tappedOnDoneOrCancel()
        self.removeFromSuperview()
    }
    
    // MARK: Custom Methods....
    //This function will return weight arr
    
    private func getWeightArr() ->[Int] {
        var tempArr:[Int] = []
        var startValue = 50
        for _ in 1...250 {
            tempArr.append(startValue)
            startValue += 1
        }
        return tempArr
    }
    
}//

// MARK: Extension.....

// MARK: UIPickerView Data Source Methods.....
extension DynamicPickerView: UIPickerViewDataSource{
    //Component means Column
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return firstComponentItems.count
        } else {
            return secondComponentItems.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return "\(firstComponentItems[row])"
        } else {
            return "\(secondComponentItems[row])"
        }
    }
}

//// MARK: UIPickerView Delegate Methods.....
//extension MyPickerView: UIPickerViewDelegate{
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if (heightPicker) { //For Height
//            if(component == 0) {
//                selectedHeightInFeet = feetArray[row]
//            } else {
//                selectedHeightInInch = inchArray[row]
//            }
//            delegate?.getHeight(heightInFeet: selectedHeightInFeet ?? 0, heightIninch: selectedHeightInInch ?? 0)
//        } else { //For Weight
//            selectedWeight = weightArray[row]
//            delegate?.getWeight(weight: selectedWeight ?? 0)
//        }
//    }
//
//}//Extension.....


// MARK: UIPickerView Delegate Methods.....
extension DynamicPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            firstComponentValue = firstComponentItems[row]
        }else{
            secondComponentValue = secondComponentItems[row]
        }
        delegate?.getPickerValue(firstValue: firstComponentValue ?? "" , secondValue: secondComponentValue ?? "" )
    }
    
}//Extension.....
