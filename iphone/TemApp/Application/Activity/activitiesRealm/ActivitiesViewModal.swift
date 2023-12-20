//
//  ActivitiesViewModal.swift
//  TemApp
//
//  Created by Mohit Soni on 13/01/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation
import RealmSwift


final class ActivitiesViewModal {
    
    private var activitiesResult: Results<ActivitiesRealm>?
    var activityCategories: [ActivityCategory] = []
    
    func saveActivitiesDataToRealm(data: Parameters) {
        do {
            let realm = try Realm()
            let activities: ActivitiesRealm = ActivitiesRealm.fromDictionary(dictionary: data)
            self.activitiesResult = realm.objects(ActivitiesRealm.self)
            try realm.write {
                if let activitiesResult = activitiesResult {
                    realm.delete(activitiesResult)
                }
                realm.add(activities)
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    func getAlreadySavedActivities() {
        do {
            let realm = try Realm()
            let activitiesResult = realm.objects(ActivitiesRealm.self)
            self.activitiesResult = activitiesResult
            if activitiesResult.count > 0 {
                self.convertActivitiesDataModal(realmModal: activitiesResult[0].activitiesData)
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    private func convertActivitiesDataModal(realmModal: List<ActivityDataRealm>) {
        for realmCategory in realmModal {
            var category: ActivityCategory = ActivityCategory(name: "", type: [], categoryType: 0)
            category.name = realmCategory.categoryName ?? ""
            category.categoryType = realmCategory.categoryType ?? 0
            var activityArray:[ActivityData] = []
            for activityType in realmCategory.activityType {
                var activity: ActivityData = ActivityData()
                activity.activityType = activityType.activityType
                activity.name = activityType.name
                activity.id = activityType.id
                activity.metValue = Double(activityType.met)
                activity.image = activityType.image
                activity.isBinary = activityType.isBinary
                    activityArray.append(activity)
            }
            category.type = activityArray
            activityCategories.append(category)
        }
    }
}
