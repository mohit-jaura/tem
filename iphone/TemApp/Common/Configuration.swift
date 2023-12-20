//
//  Configuration.swift
//  TemApp
//
//  Created by Egor Shulga on 12.01.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation

enum Environment: String {
    case debugDevelopment = "Dev"
    case qa = "QA"
    case releaseProduction = "Production"
}

class BuildConfiguration {
    private var env: Environment
    static let shared = BuildConfiguration()

    var serverUrl: String {
        switch env {
            case .debugDevelopment:
              //  return "http://182.75.105.186:3061/"
                return  "https://tem-api-dev.debutinfotech.in/"
            case .qa:
                return "https://tem-qa.capovela.com/"
            case .releaseProduction:
                return "https://tem-prod.capovela.com/"
        }
    }

    var apiVersion: String {
        switch env {
            case .debugDevelopment:
                return "v1.9"
            case .qa:
                return "v1.9"
            case .releaseProduction:
                return "v1.9"
        }
    }

    var environment: String {
        switch env {
            case .debugDevelopment:
                return "dev"
            case .qa:
                return "qa"
            case .releaseProduction:
                return "prod"
        }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        let appVersion: String = "\(version) (\(build)) \(env)"
        return appVersion

    }


     init() {
         let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String ?? ""
         env = Environment(rawValue: currentConfiguration) ?? Environment.qa
    }
}
