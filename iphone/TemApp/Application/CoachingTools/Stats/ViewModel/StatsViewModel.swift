//
//  StatsViewModel.swift
//  TemApp
//
//  Created by Shiwani Sharma on 27/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation


class StatsViewModal{
    var statsData: Stats?
    var error: DIError?
    var activities: [Activities]?

    func getStatsData(completion: @escaping OnlySuccess){
        DIWebLayerCoachingToolsAPI().getStatsData( success: { list in
            self.statsData = list
            self.activities = list.activityCategory
            completion()
        }, failure: { error in
            self.error = error
        })
    }
}

