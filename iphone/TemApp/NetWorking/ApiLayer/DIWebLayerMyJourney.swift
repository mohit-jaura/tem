//
//  DIWebLayerMyJourney.swift
//  TemApp
//
//  Created by Mohit Soni on 28/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

class DIWebLayerMyJourney: DIWebLayer {
    
    func getJourneyNotes(completion: @escaping(_ list: [JourneyNote]) -> Void, failure: @escaping Failure) {
        let date = Date()
        let startDate = date.startOfDay.locaToUTCString(inFormat: .preDefined)
        let endDate = date.endOfDay.locaToUTCString(inFormat: .preDefined)
        let query = "?startDate=\(startDate)&endDate=\(endDate)"
        let url = Constant.SubDomain.notesList + query
        self.call(method: .get, function: url, parameters: nil) { responseValue in
            if let responseData = responseValue["data"] as? Parameters, let notesList = responseData["data"] as? [Parameters] {
                self.decodeFrom(data: notesList) { list in
                    completion(list)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func addNote(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .post, function: Constant.SubDomain.addNote, parameters: params) { responseValue in
            if let status = responseValue["status"] as? Int, status == 0 {
                let error = DIError(message: responseValue["message"] as? String)
                failure(error)
                return
            }
            
            if responseValue["data"] as? Parameters != nil {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func getNotesHistory(startOfMonth: Date, endOfMonth: Date, page: Int, completion: @escaping(_ list: [JourneyNote], _ totalCount: Int) -> Void, failure: @escaping Failure) {
        let query = "\(page)&startDate=\(startOfMonth.locaToUTCString(inFormat: .preDefined))&endDate=\(endOfMonth.locaToUTCString(inFormat: .preDefined))"
        let url = Constant.SubDomain.notesHistory + query
        self.call(method: .get, function: url, parameters: nil) { responseValue in
            if let responseData = responseValue ["data"] as? Parameters, let totalCount = responseData["count"] as? Int, let data = responseData["data"] {
                self.decodeFrom(data: data) { list in
                    completion(list, totalCount)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
    func getHistoryDetails(date: String, completion: @escaping(_ list: [JourneyNote]) -> Void, failure: @escaping Failure) {
        let localDate = Utility.timeZoneDateFormatter(format: .ratingDate, timeZone: deviceTimezone).date(from: date) ?? Date()
        let startDate = localDate.startOfDay.locaToUTCString(inFormat: .preDefined)
        let endDate = localDate.endOfDay.locaToUTCString(inFormat: .preDefined)
        let url = Constant.SubDomain.notesList
        let query = "?startDate=\(startDate)&endDate=\(endDate)"
        self.call(method: .get, function: url + query, parameters: nil) { responseValue in
            if let responseData = responseValue ["data"] as? Parameters, let data = responseData["data"] {
                self.decodeFrom(data: data) { list in
                    completion(list)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
}
