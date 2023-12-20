//
//  ToDoViewModal.swift
//  TemApp
//
//  Created by Mohit Soni on 24/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct ToDoList: Codable {
    let id: String?
    let title: String?
    let totalTasks: Int?
    let completedTasks: Int?
    let isCompleted: Int?
    let affiliateFirstName: String?
    let affiliateLastName: String?
    let affiliateProfilePic: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title = "title"
        case totalTasks = "totalTasks"
        case completedTasks = "completedTasks"
        case isCompleted = "isTodoCompleted"
        case affiliateFirstName = "affiliateFname"
        case affiliateLastName = "affiliateLname"
        case affiliateProfilePic = "affiliateProfilePic"
    }
}

class ToDoListViewModal {
    
    var modal: [ToDoList]?
    var error: DIError?
    var currentPage: Int = 0
    var totalCount: Int = 0
    var pendingToDo: Int = 0
    
    func callToDoListApi(completion: @escaping OnlySuccess) {
        DIWebLayerTODO().getToDoList(currentPage: currentPage) { [weak self] (list, totalCount, pendingToDo) in
            let sortedList = list.sorted(by: { firstItem, secondItem in
                return firstItem.isCompleted ?? 0 < secondItem.isCompleted ?? 0
            })
            if self?.currentPage ?? 0 > 0 {
                self?.modal?.append(contentsOf: sortedList)
            } else {
                self?.modal = sortedList
            }
            self?.totalCount = totalCount
            self?.pendingToDo = pendingToDo
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
}
