//
//  Search+Category.swift
//  TemApp
//
//  Created by Egor Shulga on 15.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

protocol CategorySearch : CategorySearchItemSource, CategorySearchCellSource {}

/// Protocol for  controlling paged data for 'Show all' (all in a category) search page.
protocol CategorySearchItemSource {
    var description: String { get }
    var emptyMessage: String { get }
    func clear()
    func resetAndLoad(filter: String, limit: Int, success: @escaping () -> (), failure: @escaping (_ error: DIError) -> ())
    func loadNextPage(success: @escaping () -> (), failure: @escaping (_ error: DIError) -> ())
}

/// Protocol for acquiring cells to render 'Show all' search page table.
protocol CategorySearchCellSource {
    var isEmpty: Bool { get }
    func cellsCount() -> Int
    /// Return value 'true' means a cell to render is found.
    func tryAcquireCell(_: SearchViewControllerProtocol, _: UITableView, _: IndexPath, _ cell: inout UITableViewCell?) -> Bool
}
