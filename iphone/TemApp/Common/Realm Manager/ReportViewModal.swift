//
//  ReportViewModal.swift
//  TemApp
//
//  Created by Mohit Soni on 27/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import RealmSwift

final class ReportViewModal {
    
    var activitytime: String?
    var totalActivities: Int?
    var averageDistance: Double?
    var averageCalories: Double?
    var graphData: [Graph_]?
    var othersGraphData: [Graph_]?
    var accountAccountability: Double?
    var totalActivityScore: Double?
    private var reportsResults: Results<UserReportDataRealm>?
    var haisResult: Results<HaisScoreReportRealm>?
    
    func saveReportsDataToRealm(report: Parameters) {
        do {
            let realm = try Realm()
            let activityScore: UserReportDataRealm = UserReportDataRealm.fromDictionary(dictionary: report)
            self.reportsResults = realm.objects(UserReportDataRealm.self)
            try realm.write {
                if let reports = reportsResults {
                    realm.delete(reports)
                }
                realm.add(activityScore)
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    func saveHaisReportsDataToRealm(report: Parameters) {
        do {
            let realm = try Realm()
            let haisReport: HaisScoreReportRealm = HaisScoreReportRealm.fromDictionary(dictionary: report)
            self.haisResult = realm.objects(HaisScoreReportRealm.self)
            try realm.write {
                if let hais = haisResult {
                    realm.delete(hais)
                }
                realm.add(haisReport)
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    private func convertReportsDataModal(realmModal: UserReportDataRealm) {
        self.graphData = []
        self.othersGraphData = []
        if let activitytime = realmModal.totalActivityReport.averageDuration?.value,
            let distance = realmModal.totalActivityReport.averageDistance?.value,
            let totalActivityCount = realmModal.totalActivityReport.totalActivities?.value?.toInt(),
            let averageCalories = realmModal.totalActivityReport.averageCalories?.value?.rounded(.toNearestOrAwayFromZero),
           let accountAccountability = realmModal.totalActivityReport.activityAccountability?.value,
           let totalActivityScore = realmModal.totalActivityReport.totalActivityScore?.value{
            
            self.activitytime = Utility.shared.minutesToHoursAndMinutes(minutes: Int(activitytime))
            self.averageDistance = distance.rounded(.toNearestOrAwayFromZero)
            self.totalActivities = totalActivityCount
            self.averageCalories = averageCalories
            self.accountAccountability = accountAccountability
            self.totalActivityScore = totalActivityScore
        }
     
        
        for realmGraph in realmModal.graph {
            let graph = Graph_()
            graph.date = realmGraph.date
            graph.score = realmGraph.score
            self.graphData?.append(graph)
        }
        for realmGraph in realmModal.otherGraph {
            let graph = Graph_()
            graph.date = realmGraph.date
            graph.score = realmGraph.score
            self.othersGraphData?.append(graph)
        }
    }
    
     func getAlreadySavedReports() {
        do {
            let realm = try Realm()
            let reports = realm.objects(UserReportDataRealm.self)
            self.reportsResults = reports
            if reports.count > 0 {
                self.convertReportsDataModal(realmModal: reports[0])
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    func getAlreadySavedHaisScore() {
        do {
            let realm = try Realm()
            let reports = realm.objects(HaisScoreReportRealm.self)
            self.haisResult = reports
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
}
