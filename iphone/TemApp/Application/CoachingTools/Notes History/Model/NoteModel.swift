//
//  NoteModel.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct NotesHistory: Codable {
    let date: String

    enum CodingKeys: String, CodingKey {
        case date
    }
}
