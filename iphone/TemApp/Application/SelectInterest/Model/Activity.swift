//
//  Activity.swift
//  TemApp
//
//  Created by shilpa on 28/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

struct Activity: Codable {
    
    // MARK: Properties
    var name: String?
    var id: String?
    var image: String?
    var icon:String?
    var interestId: String?
    var metValue: Double?
    
    enum CodingKeys: String, CodingKey {
        case name
        case id = "_id"
        case image
        case icon
        case interestId = "interest_id"
        case metValue = "met"
    }
    
    /// converts self to the Activity type with the type of data needed in create group
    func toCreateGroupJson() -> Activity {
        var interest = Activity()
        if let id = self.id {
           interest.interestId = id
        }
        if let name = self.name {
           interest.name =  name
        }
        return interest
    }
}
