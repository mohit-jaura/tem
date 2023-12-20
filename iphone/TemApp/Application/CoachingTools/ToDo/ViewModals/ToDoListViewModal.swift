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
    let affiliateId: String?
    let userId: String?
    let media: [TodoMedia]?
    let isShared: Int? // 1 will show the condition like accept or deny and 0 and 2 will show the todos created or accepted by user.
    enum CodingKeys: String, CodingKey {
        case affiliateId = "affId"
        case id = "_id"
        case title = "title"
        case totalTasks = "totalTasks"
        case completedTasks = "completedTasks"
        case isCompleted = "isTodoCompleted"
        case affiliateFirstName = "affiliateFname"
        case affiliateLastName = "affiliateLname"
        case affiliateProfilePic = "affiliateProfilePic"
        case userId = "_user"
        case media = "titlemedia"
        case isShared
    }
}

class ToDoListViewModal {
    
    var modal: [ToDoList]?
    var error: DIError?
    var currentPage: Int = 0
    var totalCount: Int = 0
    var pendingToDo: Int = 0
    var sharedList: [ToDoList]?
    var createdList: [ToDoList]?

    func callToDoListApi(completion: @escaping OnlySuccess) {
        DIWebLayerTODO().getToDoList(currentPage: currentPage) { [weak self] (list, totalCount, pendingToDo) in
            if self?.currentPage ?? 0 > 0 {
                self?.modal?.append(contentsOf: list)
                self?.createdList?.append(contentsOf: list.filter({$0.isShared == 0 || $0.isShared == 2}))
                self?.sharedList?.append(contentsOf: list.filter({$0.isShared == 1}))
            } else {
                self?.modal = list
                self?.createdList =  list.filter({$0.isShared == 0 || $0.isShared == 2})
                self?.sharedList = list.filter({$0.isShared == 1})
            }

            self?.totalCount = totalCount
            self?.pendingToDo = pendingToDo
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }

    func getBookmarkedTodo(completion: @escaping OnlySuccess){
        DIWebLayerTODO().getBookmarkedTodoList(completion: { list in
            self.modal = list
            completion()
        }, failure: { error in
            self.error = error
        })
    }
    func addItemToBookmark(TodoItemID: String, completion: @escaping OnlySuccess){
        DIWebLayerTODO().addTodoInBookmark(params: ["bookmarkid": TodoItemID], completion: {
        completion()
        }, failure: {error in
            self.error = error
        })
    }

}
