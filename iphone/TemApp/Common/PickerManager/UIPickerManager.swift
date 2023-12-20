//
//  UIPickerManager.swift
//  UIPickerDemo
//
//  Created by Sourav on 2/14/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class UIPickerManager:NSObject,MyPickerDelegate {
    func tappedOnDoneOrCancel() {
        
    }
    
    func getPickerValue(firstValue: String, secondValue: String) {
        
    }
    
    
    // MARK: Variables.....
    
    
    var openHeightPicker:Bool = false
    var selectedHeightInFeet:Int?
    var selectedHeightInInch:Int?
    var selectedWeight:Int?
    var delegate:MyPickerDelegate?
    var weightPickerType: WeightPickerType?
    
    // MARK: App life Cycle....
    override init() {
        super.init()
    }
   
    
    // MARK: Custom Methods.....
    
     func addPickerView() {
        let mywindow = UIApplication.shared.keyWindow
        mywindow?.viewWithTag(100)?.removeFromSuperview()
        let myView = Bundle.main.loadNibNamed("MyPickerView", owner: self, options: nil)?.first as? MyPickerView
        if (myView == nil) {
            return
        }
        let frame = CGRect(x: 0, y: (mywindow?.frame.height)!, width: (mywindow?.frame.width)!, height: (mywindow?.frame.height)!)
        myView?.frame = frame
        UIView.animate(withDuration: 0.4, animations: {
            myView?.frame.origin.y =  ((myView?.frame.origin.y)!) - (mywindow?.frame.height)!
            myView?.layoutIfNeeded()
        }) { (complete) in
            
            print("Picker view has been added")
        }
        myView?.tag = 100
        myView?.heightPicker = openHeightPicker
        if (openHeightPicker) {
            if (selectedHeightInInch != nil) {
               myView?.selectedHeightInInch = selectedHeightInInch
            }
            if (selectedHeightInFeet != nil) {
                myView?.selectedHeightInFeet = selectedHeightInFeet
            }
        } else {
            if(selectedWeight != nil) {
                myView?.selectedWeight = selectedWeight
            }
        }
        myView?.delegate = self
        myView?.intializer()
        mywindow?.addSubview(myView!)
    }
    
    func getWeight(weight: Int) {
        print("weight of the user:-\(weight)")
        if let weightPickerType = self.weightPickerType {
            delegate?.getWeightGoalTracker(weight: weight, type: weightPickerType)
        } else {
            delegate?.getWeight(weight: weight)
        }
    }
    
    func getHeight(heightInFeet: Int, heightIninch: Int) {
        delegate?.getHeight(heightInFeet: heightInFeet, heightIninch: heightIninch)
    }
}//Class.....
