//
//  CoachVM.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

class CoachViewModal{
    var coachList: [CoachList]?
    var error: DIError?

    func getCoachList(completion: @escaping OnlySuccess){
        DIWebLayerCoachingToolsAPI().getCoachList( success: { list in
            self.coachList = list
            completion()
        }, failure: { error in
            self.error = error
        })
    }
}
