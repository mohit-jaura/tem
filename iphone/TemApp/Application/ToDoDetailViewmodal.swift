//
//  ToDoDetailViewmodal.swift
//  TemApp
//
//  Created by Mohit Soni on 24/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct ToDoDetail: Decodable {
    let affiliateId: String?
    let toDoId: String?
    let title: String?
    var tasks: [ToDoTasks]?
    
    enum CodingKeys: String, CodingKey {
        case affiliateId = "affiliateId"
        case toDoId = "_id"
        case tasks = "tasks"
        case title = "title"
    }
}

struct ToDoTasks: Decodable {
    let taskName: String?
    let taskId: String?
    let isCompleted: Int?
    
    enum CodingKeys: String, CodingKey {
        case taskName = "task_name"
        case taskId = "_id"
        case isCompleted = "isCompleted"
    }
}

class ToDoDetailViewModal {
    
    var modal: ToDoDetail?
    var error: DIError?
    private var toDoId: String
    private var markTasksCompletedHandler: OnlySuccess?

    init(id: String, taskCompletedHandler: @escaping OnlySuccess) {
        self.toDoId = id
        self.markTasksCompletedHandler = taskCompletedHandler
    }

    func callToDoDetailApi(completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        DIWebLayerTODO().getToDoDetail(toDoId: toDoId) { [weak self] detail in
            let sortedList = detail.tasks?.sorted(by: { firstItem, secondItem in
                return firstItem.isCompleted ?? 0 < secondItem.isCompleted ?? 0
            })
            self?.modal = detail
            self?.modal?.tasks = sortedList
            completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    
    func callMarkTaskComplete(params: Parameters, completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        DIWebLayerTODO().markTaskCompleted(params: params) { [weak self] in
            self?.callToDoDetailApi(completion: {
                self?.callToDoComplete()
                if let markTasksCompletedHandler = self?.markTasksCompletedHandler {
                    markTasksCompletedHandler()
                }
                completion()
            })
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    
    private func callMarkToDOComplete(params: Parameters) {
        if error != nil {
            self.error = nil
        }
        DIWebLayerTODO().markToDoCompleted(params: params) {
            print("TODO mark completed successfully")
        } failure: { error in
            print(error.message ?? "failed to mark todo completed")
        }
    }
    
    private func callToDoComplete() {
        let completedTasks = modal?.tasks?.filter({$0.isCompleted == 1})
        if completedTasks?.count == modal?.tasks?.count {
            let params = ["todo_id": modal?.toDoId ?? "",
                          "affiliateId": modal?.affiliateId ?? ""
            ]
            callMarkToDOComplete(params: params)
        }
    }
}
