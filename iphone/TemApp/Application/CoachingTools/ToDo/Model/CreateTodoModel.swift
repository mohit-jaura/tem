//
//  CreateTodoModel.swift
//  TemApp
//
//  Created by Shiwani Sharma on 03/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation


struct TodoItems{
    var itemName: String?
    var itemDetails: [TodoTasks]?
    var media: [TodoMedia]?
}

struct TodoTasks{
    var name: String?
    var details: [TodoSubTasks]
    var media: [TaskMedia]?
}

struct TodoSubTasks{
    var name: String?
    var media: [SubTaskMedia]?
}
