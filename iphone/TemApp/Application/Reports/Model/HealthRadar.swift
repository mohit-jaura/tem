//
//  HealthRadar.swift
//  TemApp
//
//  Created by shilpa on 01/04/20.
//

import Foundation

/// The parameters for the balanced health radar of the user
struct HealthRadar: Codable {
    var socialScore: Double?
    var medicalScore: Double?
    var physicalActivityScore: Double?
    var mentalScore: Double?
    var nutritionScore: Double?
    var cardiovascularScore: Double?
    
    var avgSocialScore: Double?
    var avgMedicalScore: Double?
    var avgPhysicalScore: Double?
    var avgMentalScore: Double?
    var avgNutritionScore: Double?
    var avgCardiovascularScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case socialScore = "socialScore"
        case medicalScore = "medicalScore"
        case physicalActivityScore = "physicalActivityScore"
        case mentalScore = "mentalScore"
        case nutritionScore = "nutritionScore"
        case cardiovascularScore = "cardiovascularScore"
        
        case avgSocialScore = "averageSocialScore"
        case avgMedicalScore = "averageMedicalScore"
        case avgPhysicalScore = "averagePhysicalActivityScore"
        case avgMentalScore = "averageMentalScore"
        case avgNutritionScore = "averageNutritionScore"
        case avgCardiovascularScore = "averageCardiovascularScore"
    }
}
