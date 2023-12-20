//
//  CreateTodoVM.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation


class CreateTodoModel{
    var error: DIError?
    var sucessMsg: String?

    func createTodo(isBookmarkTodo: Bool,params: Parameters?, completion: @escaping OnlySuccess) {
        if error != nil {
            self.error = nil
        }
        DIWebLayerTODO().createTodo(params: params ?? Parameters(), isBookmarkTodo: isBookmarkTodo) { msg in
            self.sucessMsg = msg
            completion()
        } failure: { error in
            self.error = error
        }
    }
    
    func editTodo(params: Parameters, todoId: String, completion: @escaping OnlySuccess){
        if error != nil{
            self.error = nil
        }
        DIWebLayerTODO().editTodo(id: todoId, params: params, completion:{ msg in
            self.sucessMsg = msg
            completion()
        }, failure: { error in
            self.error = error
        })
    }
}
