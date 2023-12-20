//
//  DIWebLayerTODO.swift
//  TemApp
//
//  Created by Mohit Soni on 24/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

class DIWebLayerTODO: DIWebLayer {
    
    func getToDoList(currentPage: Int, completion: @escaping(_ list: [ToDoList], _ totalCount: Int, _ pendingToDo: Int) -> Void, failure: @escaping Failure) {
        let date = Date()
        let startDate = date.startOfDay.locaToUTCString(inFormat: .preDefined)
        let endDate = date.endOfDay.locaToUTCString(inFormat: .preDefined)
        let query = "\(currentPage)&startDate=\(startDate)&endDate=\(endDate)"
        let url = Constant.SubDomain.toDoList + query
        self.call(method: .get, function: url, parameters: nil) { responseValue in
            if let responseData = responseValue["data"] as? Parameters, let totalCount = responseData["count"] as? Int, let pendingToDo = responseData["pendingTodos"] as? Int, let toDoList = responseData["data"] as? [Parameters] {
                self.decodeFrom(data: toDoList) { list in
                    completion(list, totalCount, pendingToDo)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func getToDoDetail(toDoId: String, completion: @escaping(ToDoDetail) -> Void, failure: @escaping Failure) {
        let endPoint = Constant.SubDomain.toDoDetail + toDoId
        self.call(method: .get, function: endPoint, parameters: nil) { responseValue in
            if let responseData = responseValue["data"] as? Parameters {
                self.decodeFrom(data: responseData) { detail in
                    completion(detail)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func markTaskCompleted(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .post, function: Constant.SubDomain.markTaskComplete, parameters: params) { responseValue in
            if responseValue["data"] as? Parameters != nil {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }

    func subTaskCompleted(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .post, function: Constant.SubDomain.subTaskComplete, parameters: params) { responseValue in
            if responseValue["data"] as? Parameters != nil {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }

    func markToDoCompleted(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .post, function: Constant.SubDomain.markToDoComplete, parameters: params) { responseValue in
            if responseValue["data"] as? Parameters != nil {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }

    func todoDeleteAPI(id:String, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        let url = "\(Constant.SubDomain.deleteTodo)/\(id)"
        self.call(method: .delete, function: url, parameters: nil) { responseValue in
            if responseValue["status"] as? Int == 1 {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }
    func acceptDenyAPI(todoId: String, params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {

        self.call(method: .put, function: "\(Constant.SubDomain.acceptRejectTodo)/\(todoId)", parameters: params) { responseValue in
            if responseValue["status"] as? Int == 1 {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }
    //This will create the to do list(created by user itself)
    func createTodo(params: Parameters,isBookmarkTodo: Bool, completion: @escaping(_ response: String) -> (Void), failure: @escaping Failure) {
        var url = ""
        if isBookmarkTodo{
            url = Constant.SubDomain.addBookmark
        } else{
        url = Constant.SubDomain.createTodo
        }
        self.call(method: .post, function: url, parameters: params) { responseValue in
            if let msg = responseValue["message"] as? String {
           completion(msg)
            }
        } failure: { error in
            failure(error)
        }
    }

    // this will add the todos in user's to do list(created by any temates or affiliates)
    func addToMyTodo(params: Parameters, completion: @escaping(_ response: String) -> (Void), failure: @escaping Failure) {
        self.call(method: .put, function: Constant.SubDomain.createTodo, parameters: params) { responseValue in
            if let msg = responseValue["message"] as? String {
                completion(msg)
            }
        } failure: { error in
            failure(error)
        }
    }

    func editTodo(id: String,params: Parameters, completion: @escaping(_ response: String) -> (Void), failure: @escaping Failure) {
        self.call(method: .put, function: "\(Constant.SubDomain.editTodo)/\(id)", parameters: params) { responseValue in
            if let msg = responseValue["message"] as? String {
                completion(msg)
            }
        } failure: { error in
            failure(error)
        }
    }
    func getBookmarkedTodoList(completion: @escaping(_ list: [ToDoList]) -> Void, failure: @escaping Failure) {
        self.call(method: .get, function: Constant.SubDomain.getBookmarkedList, parameters: nil) { responseValue in
            if let toDoList = responseValue["data"] as? [Parameters] {
                self.decodeFrom(data: toDoList) { list in
                    completion(list)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }

    func addTodoInBookmark(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .post, function: Constant.SubDomain.saveInBookmark, parameters: params) { responseValue in
            if responseValue["status"] as? Int == 1 {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }
}

