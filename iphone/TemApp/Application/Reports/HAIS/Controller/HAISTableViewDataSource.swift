//
//  HAISTableViewDataSource.swift
//  TemApp
//
//  Created by shilpa on 08/11/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

protocol HAISFormable {
    var fieldInfo: (title: String, leftIcon: UIImage?) { get }
}

//This contains the sections and rows to be set as the data source of HAIS screen tableview
/*
enum HAISFormSection: Int, CaseIterable, HAISFormable {
    
    case height = 0,weight,bodyMassIndex, VO2_max, happiness, selfAssessment, bodyFat, nutrition, systolicBloodPressure, diastolicBloodPressure, restingHeartRate, waistCircumference, panelComplete, panel
    
    ///title of the section
    var fieldInfo: (title: String, leftIcon: UIImage?) {
        switch self {
        case .VO2_max:
            return ("V02 Max".localized, UIImage(named: "lungs"))
        case .happiness:
            return ("Happiness".localized, UIImage(named: "happy"))
        case .selfAssessment:
            return ("Self assessment".localized, UIImage(named: "self-assessment"))
        case .bodyFat:
            return ("Body Fat (%)".localized, UIImage(named: "Bitmap"))
        case .systolicBloodPressure:
            return ("Blood Pressure (Systolic)".localized, UIImage(named: "pressure-gauge"))
        case .diastolicBloodPressure:
            return ("Blood Pressure (Diastolic)".localized, UIImage(named: "pressure-gauge"))
        case .restingHeartRate:
            return ("Resting Heart Rate".localized, UIImage(named: "cardiogram"))
        case .waistCircumference:
            return ("Waist Circumference (in inches)".localized, UIImage(named: "waist"))
        case .panel:
            return ("Panel".localized, nil)
        case .bodyMassIndex:
            return ("BMI".localized, UIImage(named: "bmi"))
        case .nutrition:
            return ("Nutrition Tracking %", UIImage(named: "nutrition-icon"))
        case .height:
            return ("Height".localized, UIImage(named: "height"))
        case .weight:
            return ("Weight", UIImage(named: "weighing-scale"))
        default:
            return ("Panel Complete", nil)
        }
    }
}

enum HappinessSection: Int, CaseIterable, HAISFormable {
    case happinessSurvey = 0
    case happiness
    
    var fieldInfo: (title: String, leftIcon: UIImage?) {
        switch self {
        case .happinessSurvey:
            return ("Happiness Survey".localized, nil)
        case .happiness:
            return ("",nil)
        }
    }
}

enum SelfAssessmentSection: Int, CaseIterable, HAISFormable {
    
    case selfAssessmentToggle = 0
    case selfAssessmentValue
    
    var fieldInfo: (title: String, leftIcon: UIImage?) {
        switch self {
        case .selfAssessmentToggle:
            return ("Self assessment".localized, nil)
        case .selfAssessmentValue:
            return ("",nil)
        }
    }
}

enum PanelCategories: Int, CaseIterable, HAISFormable {
    case LDL = 0, LDH, cholestrol, Hba1c, triglycerides
    
    var fieldInfo: (title: String, leftIcon: UIImage?) {
        switch self {
        case .LDL:
            return ("LDL".localized, UIImage(named: "cardiogram"))
        case .LDH:
            return ("HDL".localized, UIImage(named: "cardiogram"))
        case .cholestrol:
            return ("Cholesterol".localized, UIImage(named: "cardiogram"))
        case .Hba1c:
            return ("Hba1c".localized, UIImage(named: "hemo"))
        case .triglycerides:
            return ("Triglycerides".localized, UIImage(named: "Bitmap"))
        }
    }
}

enum NutritionSection: Int, CaseIterable, HAISFormable {
    case trackNutrition = 0, trackingPercentage
    
    var fieldInfo: (title: String, leftIcon: UIImage?) {
        switch self {
        case .trackNutrition:
            return ("Do you track your Nutrition?", nil)
        case .trackingPercentage:
            return ("",nil)
        }
    }
}
 */
enum HAISFormSections: Int, CaseIterable, HAISFormable{
    case general = 0, selfAssessment, comprehensive
    
    var fieldInfo: (title: String, leftIcon: UIImage?) {
        switch self{
            
        case .general:
            return ("GENERAL", nil)
        case .selfAssessment:
            return ("SELF ASSESSMENT", nil)
        case .comprehensive:
            return ("COMPREHENSIVE", nil)
        }
    }
}

enum GeneralSection: Int, CaseIterable, HAISFormable{
    case height = 0, weight, bodyMassIndex, bodyFat, waistCircumference, restingHeartRate, VO2_max, hrv
    
    var fieldInfo: (title: String, leftIcon: UIImage?) {
        switch self{
        case .height:
            return ("HEIGHT", nil)
        case .weight:
            return ("WEIGHT", nil)
        case .bodyMassIndex:
            return ("BMI", nil)
        case .bodyFat:
            return ("BODY FAT %", nil)
        case .waistCircumference:
            return ("WAIST CIRCUMFERENCE", nil)
        case .restingHeartRate:
            return ("RESTING HR", nil)
        case .VO2_max:
            return ("VO2 MAX", nil)
        case .hrv:
            return ("HRV", nil)
        }
    }
}

enum SelfAssessmentSection: Int, CaseIterable, HAISFormable{
    case total = 0, happiness, doYourTrackYourNutrition, trackNutritionPercentages
    
    var fieldInfo: (title: String, leftIcon: UIImage?){
        switch self {
        case .total:
            return ("TOTAL", nil)
        case .happiness:
            return ("HAPPINESS", nil)
        case .doYourTrackYourNutrition:
            return ("DO YOU TRACK YOUR NUTRITION?", nil)
        case .trackNutritionPercentages:
            return ("TRACK NUTRITION %?", nil)
        }
    }
}

enum ComprehensiveSection: Int, CaseIterable, HAISFormable{
    case systolic = 0, diastolic, LDL, LDH, cholestrol, Hba1c, triglycerides
    
    var fieldInfo: (title: String, leftIcon: UIImage?){
        switch self{

        case .systolic:
            return ("BLOOD PRESSURE (SYSTOLIC)", nil)
        case .diastolic:
            return ("BLOOD PRESSURE (DIASTOLIC)", nil)
        case .LDL:
            return ("LDL", nil)
        case .LDH:
            return ("HDL", nil)
        case .cholestrol:
            return ("CHOLESTROL", nil)
        case .Hba1c:
            return ("HBA1C", nil)
        case .triglycerides:
            return ("TRIGLYCERIDES", nil)
        }
    }
}

//
//extension HAISViewController: HAISToggleTableCellDelegate, InputFieldTableCellDelegate {
//    func inputTextFieldDidEndEditing(textField: UITextField) {}
//    
//    func inputTextFieldDidBeginEditing(textField: UITextField) {}
//    
//    func didTapDoneOnInputTextField(sender: UIBarButtonItem) {}
//    
//    func didChangeToggleFor(section: HAISFormSections, isSelected: Bool) {}
//}
