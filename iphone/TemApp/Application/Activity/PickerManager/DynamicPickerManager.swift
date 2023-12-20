//
//  DynamicPickerManager.swift
//  TemApp
//
//  Created by Harpreet_kaur on 21/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//
import Foundation
import UIKit

class DynamicPickerManager:NSObject,MyPickerDelegate {
    func tappedOnDoneOrCancel() {
        delegate?.tappedOnDoneOrCancel()
    }
    
    // MARK: Variables.....
    var firstComponentValue:String?
    var secondComponentValue:String?
    var numberOfComponents:Int = 1
    var firstComponentItems:[String] = []
    var secondComponentItems:[String] = []
    var delegate:MyPickerDelegate?
    
    
    // MARK: App life Cycle....
    override init() {
        super.init()
    }
    
    
    // MARK: Custom Methods.....
    
    func addPickerView() {
        let mywindow = UIApplication.shared.keyWindow
        mywindow?.viewWithTag(100)?.removeFromSuperview()
        let myView = Bundle.main.loadNibNamed("DynamicPickerView", owner: self, options: nil)?.first as? DynamicPickerView
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
        if (firstComponentValue != nil) {
            myView?.firstComponentValue = firstComponentValue
        }
        if (secondComponentValue != nil) {
            myView?.secondComponentValue = secondComponentValue
        }
        myView?.firstComponentItems = firstComponentItems
        myView?.secondComponentItems = secondComponentItems
        myView?.numberOfComponents = numberOfComponents
        myView?.delegate = self
        myView?.intializer()
        mywindow?.addSubview(myView!)
    }
    
    func getPickerValue(firstValue: String, secondValue: String) {
        delegate?.getPickerValue(firstValue: firstValue, secondValue: secondValue)
    }
}//Class.....
