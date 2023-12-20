//
//  ToDoDetailViewmodal.swift
//  TemApp
//
//  Created by Mohit Soni on 24/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

struct ToDoDetail: Codable {
    let affiliateId: String?
    let toDoId: String?
    let title: String?
    var tasks: [ToDoTasks]?
    let status: Int? // Will show the status of todo i.e. added in my to do list or not(0 means not added and 1 means added)
    let media: [TodoMedia]?

    enum CodingKeys: String, CodingKey {
        case affiliateId = "affiliateId"
        case toDoId = "_id"
        case tasks = "tasks"
        case title = "title"
        case status
        case media = "titlemedia"
    }
}

struct ToDoTasks: Codable {//
    let taskName: String?
    let taskId: String?
    let isCompleted: Int?
    let subTasks: [SubTasks]?
    let media: [TaskMedia]?

    enum CodingKeys: String, CodingKey {
        case taskName = "task_name"
        case taskId = "_id"
        case isCompleted = "isCompleted"
        case subTasks = "subtasks"
        case media = "taskmedia"
    }
}
struct TodoMedia: Codable{
    var url: String?
    var mediaType: EventMediaType?

    enum CodingKeys: String, CodingKey{
        case url = "titlefile"
        case mediaType
    }
}

struct TaskMedia: Codable{//
    let url: String?
    let mediaType: EventMediaType?

    enum CodingKeys: String, CodingKey{
        case url = "taskfile"
        case mediaType
    }
}

struct SubTaskMedia: Codable{//
    let url: String?
    let mediaType: EventMediaType?

    enum CodingKeys: String, CodingKey{
        case url = "subtaskfile"
        case mediaType
    }
}
struct SubTasks: Codable {//
    let subtaskName: String?
    let id: String?
    let isCompleted: Int?
    let media: [SubTaskMedia]?

    enum CodingKeys: String, CodingKey {
        case subtaskName = "subtask_name"
        case id = "_id"
        case isCompleted = "isCompleted"
        case media = "subtaskmedia"
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
            self?.modal = detail
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
    func callSubtaskComplete(totalSubtasks: Int, completedSubtasks: Int,params: Parameters,taskParams: Parameters, completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        DIWebLayerTODO().subTaskCompleted(params: params) { [weak self] in
                if totalSubtasks == completedSubtasks + 1{
                    self?.callMarkTaskComplete(params: taskParams, completion: {})
                }
                completion()
        } failure: { [weak self] error in
            self?.error = error
            completion()
        }
    }
    func addTomyTodo(params: Parameters?, completion: @escaping OnlySuccess, sucessMsg: @escaping (String)-> ()){
        if error != nil {
            self.error = nil
        }
        DIWebLayerTODO().addToMyTodo(params: params ?? Parameters()) { msg in
            sucessMsg(msg)
            completion()
        } failure: { error in
            self.error = error
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
