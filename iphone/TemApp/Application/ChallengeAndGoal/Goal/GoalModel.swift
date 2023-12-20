//
//  GoalModel.swift
//  TemApp
//
//  Created by Egor Shulga on 4.03.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation

class GoalModel {
    private var api = DIWebLayerGoals()
    
    func loadGoal(_ id: String, _ page: Int, completion: @escaping (_ goal: GroupActivity) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        guard Reachability.isConnectedToNetwork() else {
            failure(DIError(title: "", message: AppMessages.AlertTitles.noInternet, code: .unknown))
            return
        }
        api.getGoalDetailsBy(id: id, page: page) { (goal, _) in completion(goal) } failure: { (e) in failure(e) }
    }
}
