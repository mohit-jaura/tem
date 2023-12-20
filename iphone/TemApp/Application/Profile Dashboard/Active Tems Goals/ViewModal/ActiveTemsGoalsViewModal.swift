//
//  ActiveTemsGoalsViewModal.swift
//  TemApp
//
//  Created by Mohit Soni on 05/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

final class ActiveTemsGoalsViewModal {
    var temsModal: [ChatRoom]?
    var goalsModal: [GroupActivity]?
    var challengesModal: [GroupActivity]?
    var error: DIError?
    var userId: String
    var currentPage: Int = 1
    var totalCount: Int = 0
    
    init(userId: String) {
        self.userId = userId
    }
    
    func updateCurrentPage() {
        self.currentPage += 1
    }
    func resetCurrentPage() {
        self.currentPage = 1
        self.totalCount = 0
    }
    
    func callActiveTemsAPI(completion: @escaping OnlySuccess) {
        if error != nil {
            error = nil
        }
        DIWebLayerActiveTems().getTems(userId: userId, page: currentPage) { [weak self] chatRooms, totalCount in
            if self?.currentPage ?? 0 > 1 {
                self?.temsModal?.append(contentsOf: chatRooms)
            } else {
                self?.temsModal = chatRooms
            }
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    func callActiveGoalsAPI(completion: @escaping OnlySuccess) {
        if error != nil {
            error = nil
        }
        DIWebLayerActiveTems().getGoals(userId: userId, page: currentPage) { [weak self] goals, totalCount in
            if self?.currentPage ?? 0 > 1 {
                self?.goalsModal?.append(contentsOf: goals)
            } else {
                self?.goalsModal = goals
            }
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    func callActiveChallengesAPI(completion: @escaping OnlySuccess) {
        if error != nil {
            error = nil
        }
        DIWebLayerActiveTems().getChallenges(userId: userId, page: currentPage) { [weak self] challenegs, totalCount in
            if self?.currentPage ?? 0 > 1 {
                self?.challengesModal?.append(contentsOf: challenegs)
            } else {
                self?.challengesModal = challenegs
            }
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
}
