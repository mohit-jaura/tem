//
//  PostReport.swift
//  TemApp
//
//  Created by Harpreet_kaur on 02/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
class ReportData : Codable {
    var id : String?
    var title : String?
    var desc:Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case desc
    }
}

