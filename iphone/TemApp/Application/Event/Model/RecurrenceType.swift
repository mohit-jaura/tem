//
//  RecurranceType.swift
//  TemApp
//
//  Created by Egor Shulga on 19.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

enum RecurrenceType: Int, CaseIterable {
    case doesNotRepeat = 0
    case everyDay
    case week
    case eveyTwoWeeks
    case everyMonth
    
    func getTitle() -> String{
        switch self {
        case .doesNotRepeat:
            return "Does Not Repeat"
        case .everyDay:
            return "Every Day"
        case .week:
            return "Every Week"
        case .eveyTwoWeeks:
            return "Every 2 Weeks"
        case .everyMonth:
            return "Every Month"
        }
    }
}

enum RecurrenceFinishType: Int, CaseIterable {
    case never = 1
    case date
    
    func getTitle() -> String{
        switch self {
        case .never:
            return "Never"
        case .date:
            return "Select End Date"
        }
    }
}

enum CheckInType: Int, CaseIterable {
    case daily
    case weekly
    case biWeekly
    case monthly
    
    func getTitle() -> String {
        switch self {
            case .daily:
                return "Daily"
            case .weekly:
                return "Weekly"
            case .biWeekly:
                return "Bi-Weekly"
            case .monthly:
                return "Monthly"
        }
    }
}

enum HealthInfoType: Int, CaseIterable {
  //  case weight = 0
    case bmi =  0
    case bodyFat
    case waist
    case restingHR
    case vo2
    case maxHrv
    case bpSystolic
    case bpDiasystolic
    case ldl
    case hdl
    case cholesterol
    case hba1c
    case triglycerides

    func getTitle() -> String {
        switch self {
//           case .weight:
//            return "Weight"
        case .bmi:
            return "BMI"
        case .bodyFat:
            return "Body fat percentage"
        case .waist:
            return "Waist"
        case .restingHR:
            return "Resting heart rate"
        case .vo2:
            return "VO2"
        case .maxHrv:
            return "Max HRV"
        case .bpSystolic:
            return "BP(SYSTOLIC)"
        case .bpDiasystolic:
            return "BP(DIASTOLIC)"
        case .ldl:
            return "LDL"
        case .hdl:
            return "HDL"
        case .cholesterol:
            return "CHOLESTEROL"
        case .hba1c:
            return "HBA1C"
        case .triglycerides:
            return "TRIGLYCERIDES"
        }
    }
    func getUnitType() -> String {
        switch self {
        case .bmi:
           return "m*2"
        case .bodyFat:
            return "%"
        case .waist:
            return "inches"
        case .restingHR:
            return "bpm"
        case .vo2:
            return "L/min"
        case .maxHrv:
            return "hrv"
        case .bpSystolic:
            return "ml"
        case .bpDiasystolic:
            return "ml"
        case .ldl:
            return "mmol/L"
        case .hdl:
            return "mmol/L"
        case .cholesterol:
            return "mmol/L"
        case .hba1c:
            return "%"
        case .triglycerides:
            return "mmol/L"
        }
    }
}
