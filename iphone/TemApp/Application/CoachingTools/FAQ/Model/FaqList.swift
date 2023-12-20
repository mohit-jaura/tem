//
//  FaqList.swift
//  TemApp
//
//  Created by Shiwani Sharma on 06/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct FaqList: Codable {
    let id, question, answer: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case question, answer
    }
}
