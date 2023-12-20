//
//  WeightGoalDetailViewModal.swift
//  TemApp
//
//  Created by Mohit Soni on 28/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct WeightGoalDetailModal: Codable {
    let startMeasure: WeightDetail?
    let endMeasure: WeightDetail?
    let currentMeasure: WeightDetail?
    let weightLeft: Double?
    let daysLeft: Int?
    var weightLogs: [WeightDetail]?
    var healthLogs: [WeightDetail]?
    let currentHealthUnits: HealthDetail?
    let goalHelathUnits: HealthDetail?
    let healthInfoType: HealthDetail?
    let goalLeft: Int?

    enum CodingKeys: String, CodingKey {
        case startMeasure = "startmeasure"
        case endMeasure = "endmeasure"
        case currentMeasure = "currentweight"
        case weightLeft = "weightleft"
        case daysLeft = "daysleft"
        case weightLogs = "goalWeightRecord"
        case currentHealthUnits, goalHelathUnits, healthInfoType
        case goalLeft
        case healthLogs = "GoalHealthUnitRecords"
    }
}
struct HealthDetail: Codable {
    let data: Int?
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct WeightDetail: Codable {
    let date: Int?
    let weight: Double?
    let healthLoggedUnits: Int?
    let currentHealthUnits: Int?

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case weight = "weight"
        case healthLoggedUnits = "current_paramters_data"
        case currentHealthUnits
    }
}

class WeightGoalDetailViewModal {
    var modal: WeightGoalDetailModal?
    var error: DIError?
    var id: String = ""
    var isHealthInfo = false
    var graphData: [Graph_]?
    init(id: String) {
        self.id = id
    }
    
    func callGetWeightGoalDetailAPI(completion: @escaping OnlySuccess) {
        DIWebLayerWeightGoal().getWeightGoalDetail(getHealthInfo: isHealthInfo, id: self.id) { [weak self] (list) in
            self?.modal = list
            if (self?.isHealthInfo ?? false){
                let sortedHealthLogs: [WeightDetail]? = list?.healthLogs?.sorted(by: { firstLog, secondLog in
                    let date1 = firstLog.date?.timestampInMillisecondsToDate ?? Date()
                    let date2 = secondLog.date?.timestampInMillisecondsToDate ?? Date()
                    return date1 > date2
                })
                let uniqueHealthLogsList: [WeightDetail]? = self?.removeDuplicateLogs(list: sortedHealthLogs)
                self?.modal?.healthLogs = uniqueHealthLogsList
                self?.pullGraphData(isHealthInfo: self?.isHealthInfo ?? false, logs: uniqueHealthLogsList)
            } else{
                let sortedLogs: [WeightDetail]? = list?.weightLogs?.sorted(by: { firstLog, secondLog in
                    let date1 = firstLog.date?.timestampInMillisecondsToDate ?? Date()
                    let date2 = secondLog.date?.timestampInMillisecondsToDate ?? Date()
                    return date1 > date2
                })
                let uniqueLogsList: [WeightDetail]? = self?.removeDuplicateLogs(list: sortedLogs)
                self?.modal?.weightLogs = uniqueLogsList
                self?.pullGraphData(isHealthInfo: self?.isHealthInfo ?? false,logs: uniqueLogsList)
            }
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }

    func callAddWeightGoalLogAPI(isHealthInfo: Bool,weight: Double, completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        var parameters: Parameters = [
            "_id": id,
            "date": Date().timestampInMilliseconds,
        ]
        if isHealthInfo{
            parameters["current_paramters_data"] = weight
        }else{
            parameters["weight"] = weight
        }
        DIWebLayerWeightGoal().addWeightGoalLog(params: parameters) { [weak self] in
            self?.callGetWeightGoalDetailAPI {
                completion()
            }
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    
    private func pullGraphData(isHealthInfo: Bool,logs: [WeightDetail]?) {
        var slicedArray = logs ?? []
        let logsCount = logs?.count ?? 0
        if logsCount > 7 {
            slicedArray.removeSubrange(8...logsCount - 1)
        }
        var tempGraph = [Graph_]()
        for data in slicedArray {
            var graph = Graph_()
            let rawDate = data.date?.timestampInMillisecondsToDate ?? Date()
            graph.date = rawDate.toString(inFormat: .chatDate)
            if isHealthInfo{
                graph.score = Double(data.healthLoggedUnits ?? 0)
            }else{
                graph.score = data.weight
            }

            tempGraph.append(graph)
        }
        self.graphData = tempGraph
    }
    
    private func removeDuplicateLogs(list: [WeightDetail]?) -> [WeightDetail] {
        var filteredLogs: [WeightDetail] = []
        if let logs = list {
            for log in logs {
                let date = log.date?.timestampInMillisecondsToDate.toString(inFormat: .chatDate) ?? ""
                let alreadyPresent = filteredLogs.contains(where: { $0.date?.timestampInMillisecondsToDate.toString(inFormat: .chatDate) ?? "" == date })
                if !alreadyPresent {
                    filteredLogs.append(log)
                }
            }
        }
        return filteredLogs
    }
}
