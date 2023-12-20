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
        let url = Constant.SubDomain.toDoList + "\(currentPage)"
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
    
    func markToDoCompleted(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .post, function: Constant.SubDomain.markToDoComplete, parameters: params) { responseValue in
            if responseValue["data"] as? Parameters != nil {
                completion()
            }
        } failure: { error in
            failure(error)
        }
    }
}
