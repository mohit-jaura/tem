//
//  HAISData.swift
//  TemApp
//
//  Created by shilpa on 14/11/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

struct HealthData: Codable {
    var vO2Max: Double?
    var happiness: Double?
    var selfAssessment: Double?
    var bodyFat: Double?
    var bloodPressure: BloodPressure?
    var restingHeartRate: Double?
    var waistCircumference: Double?
    var panel: UserPanelHealthData?
    var happinessSurvey: CustomBool?
    var selfAssessmentToggle: CustomBool?
    var nutritionTracking: CustomBool?
    var nutritionTrackingPercent: String?
    var feet:Int?
    var weight:Int?
    var inch:Int?
    
    var panelComplete: CustomBool?
    var nutritionTrackingId: Int?
    var bmi: Double?
    
    enum CodingKeys: String, CodingKey {
        case vO2Max = "v02_max"
        case feet = "feet"
        case inch = "inch"
        case weight = "weight"
        case panel
        case bodyFat = "body_fat"
        case restingHeartRate = "resting_heart_rate"
        case waistCircumference = "waist_circumference"
        case panelComplete = "panel_completed"
        case happinessSurvey = "happyness_index"
        case selfAssessmentToggle = "self_assessment"
        case nutritionTracking = "nutrition_tracker_status"
        case nutritionTrackingId = "nutrition_tracker_value"
        case bloodPressure = "blood_pressure_obj"
        case bmi = "bmi"
    }
}

struct HealthDataNew: Codable {
    var vO2Max: Double?
    var hrv: Double?
    var selfAssessment: Double?
    var bodyFat: Double?
    var bloodPressure: BloodPressure?
    var restingHeartRate: Double?
    var waistCircumference: Double?
    var panel: UserPanelHealthData?
    var happinessSurvey: Int?
    var totalAssessmentToggle: Int?
    var nutritionTracking: Int?
    var nutritionTrackingPercent: String?
    var feet:Int?
    var weight:Int?
    var inch:Int?
    
    var panelComplete: CustomBool?
    var nutritionTrackingId: Int?
    var bmi: Double?
    
    enum CodingKeys: String, CodingKey {
        case vO2Max = "v02_max"
        case feet = "feet"
        case inch = "inch"
        case weight = "weight"
        case panel
        case bodyFat = "body_fat"
        case restingHeartRate = "resting_heart_rate"
        case waistCircumference = "waist_circumference"
        case panelComplete = "panel_completed"
        case happinessSurvey = "happyness_index"
        case totalAssessmentToggle = "self_assessment"
        case nutritionTracking = "nutrition_tracker_value"
        case nutritionTrackingId = "nutrition_tracker_status"
        case bloodPressure = "blood_pressure_obj"
        case bmi = "bmi"
        case hrv = "happiness"
    }
}

struct BloodPressure: Codable {
    var systolic: Double?
    var diastolic: Double?
}

struct Height: Codable {
    var feet: Int?
    var inch: Int?
}

struct UserPanelHealthData: Codable {
    var ldl: Double?
    var ldh: Double?
    var cholesterol: Double?
    var hba1c: Double?
    var triglycerides: Double?
}

