//
//  WeightGoalViewModal.swift
//  TemApp
//
//  Created by Mohit Soni on 04/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct WeightGoalModal: Codable {

    var startDate: Int?
    var currentHealthUnits: Int?
    var goalHelathUnits: Int?
    var frequency: Int?
    var duration: String?
    var healthInfoType: Int?
    
    enum CodingKeys: String, CodingKey {
        case startDate = "startDate"
        case currentHealthUnits = "currentHealthUnits"
        case goalHelathUnits = "goalHelathUnits"
        case frequency = "frequency"
        case duration = "duration"
        case healthInfoType = "healthInfoType"
    }
    
    func getHealthParameters() -> Parameters {
        let parameters: Parameters = [
            CodingKeys.startDate.rawValue: startDate ?? 0,
            CodingKeys.currentHealthUnits.rawValue: currentHealthUnits ?? 0,
            CodingKeys.goalHelathUnits.rawValue: goalHelathUnits ?? 0,
            CodingKeys.frequency.rawValue: frequency ?? 0,
            CodingKeys.duration.rawValue: duration ?? "0",
            CodingKeys.healthInfoType.rawValue: healthInfoType ?? 0
        ]

        return parameters
    }
    func getParameters() -> Parameters {
        
        let parameters: Parameters = [
            CodingKeys.startDate.rawValue: startDate ?? 0,
            "weight": currentHealthUnits ?? 0,
            "goal_weight": goalHelathUnits ?? 0,
            CodingKeys.frequency.rawValue: frequency ?? 0,
            CodingKeys.duration.rawValue: duration ?? "0",
            CodingKeys.healthInfoType.rawValue: 0
        ]
        return parameters
    }
}
class WeightGoalViewModal {
    
    var modal: WeightGoalModal?
    var error: DIError?
    var isHealthGoal: Bool?
    init() {
        let currentWeight = User.sharedInstance.weight ?? 120
        modal = WeightGoalModal(currentHealthUnits: currentWeight)
    }
    private func validateForm() -> Bool {
        var isValid = false
        if modal?.startDate != nil {
            isValid = true
        } else if modal?.currentHealthUnits != nil {
            isValid = true
        } else if modal?.goalHelathUnits != nil {
            isValid = true
        } else if modal?.duration != nil {
            isValid = true
        } else if modal?.frequency != nil {
            isValid = true
        } else {
            isValid = false
        }
        return isValid
    }
    
    func callAddWeightGoalAPI(completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        let isValid = validateForm()
        if isValid {
            var params: Parameters?
            if isHealthGoal ?? false{
                 params = modal?.getHealthParameters() ?? Parameters()
            } else{
                 params = modal?.getParameters() ?? Parameters()
            }
            DIWebLayerWeightGoal().addWeightGoal(isHealthGoal: self.isHealthGoal ?? false,params: params ?? Parameters()) {
                completion()
            } failure: { [weak self]  error in
                self?.error = error
                completion()
            }
        } else {
            self.error = DIError(message: "Please enter all the details properly.")
            completion()
        }
    }
}
