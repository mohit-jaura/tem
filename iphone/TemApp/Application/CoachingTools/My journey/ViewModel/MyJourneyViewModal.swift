//
//  MyJourneyViewModal.swift
//  TemApp
//
//  Created by Mohit Soni on 28/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation
import KVKCalendar

class MyJourneyViewModal {
    var modal: [JourneyNote]?
    var error: DIError?
    var historyList: [JourneyNote]?
    var currentPage: Int = 0
    var totalCount: Int = 0
    let currentMonth: Int = Date().dateComponents.month ?? 0
    var dateOfNotes: [Date] = []
    var startDate: Date = Date().addMonth(n: -1)
    var endDate: Date = Date().addDay(n: 1)
    var isLoading: Bool = false
    func callJourneyNotesApi(completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        DIWebLayerMyJourney().getJourneyNotes { [weak self] list in
            self?.modal = list
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    
    func callAddNoteApi(message: String, completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        let currentDate = Utility.timeZoneDateFormatter(format: .editEventDate, timeZone: utcTimezone).string(from: Date())
        let noteDate = Utility.timeZoneDateFormatter(format: .preDefined, timeZone: utcTimezone).string(from: Date())
        let params = ["message": message, "journeyDate": currentDate, "noteDate": noteDate]
        DIWebLayerMyJourney().addNote(params: params) { [weak self] in
            self?.callJourneyNotesApi {
                completion()
            }
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    
    func callNotesHistoryApi(completion: @escaping OnlySuccess){
        isLoading = true
        DIWebLayerMyJourney().getNotesHistory(startOfMonth: startDate, endOfMonth: endDate, page: currentPage, completion: { [weak self] list, totalCount in
            self?.historyList = list
            self?.generateDateOfHistory()
            self?.totalCount = totalCount
            self?.isLoading = false
            completion()
        }, failure: { error in
            self.error = error
            self.isLoading = false
        })
    }
    
    private func generateDateOfHistory() {
        guard let modal = self.historyList else { return }
        for note in modal {
            if let dateString = note.updatedAt {
                let date = dateString.toDate(dateFormat: .preDefined).UTCToLocalDate(inFormat: .preDefined)
                let alreadyPresent = dateOfNotes.contains(where: { $0.dateTruncated(from: .hour) == date.dateTruncated(from: .hour) })
                if !alreadyPresent && date.dateTruncated(from: .hour) != Date().UTCToLocalDate(inFormat: .preDefined).dateTruncated(from: .hour) {
                    dateOfNotes.append(date)
                }
            }
        }
        dateOfNotes.sort { $0 > $1 }
    }
    
    func getNotesForSelectedDate(selectedDate: Date) -> [JourneyNote] {
        guard let modal = self.historyList else { return [] }
        var notes: [JourneyNote] = []
        for note in modal {
            if let dateString = note.updatedAt {
                let date = dateString.toDate(dateFormat: .preDefined).UTCToLocalDate(inFormat: .preDefined)
                if date.dateTruncated(from: .hour) == selectedDate.dateTruncated(from: .hour) {
                    notes.append(note)
                }
            }
        }
        notes.sort { firstNote, secondNot in
            if let firstDate = firstNote.updatedAt?.toDate(dateFormat: .preDefined).UTCToLocalDate(inFormat: .preDefined), let secondDate = secondNot.updatedAt?.toDate(dateFormat: .preDefined).UTCToLocalDate(inFormat: .preDefined) {
                return firstDate < secondDate
            }
            return false
        }
        return notes
    }
}
