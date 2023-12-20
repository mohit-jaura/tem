//
//  Search+Preview.swift
//  TemApp
//
//  Created by Egor Shulga on 8.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

/// Protocol for working with a search category with a known underlying items type.
protocol PreviewSearch : PreviewSearchTypeAgnostic, PreviewSearchItemSource {}

/// Protocol for retrieving preview info in the top-level GlobalSearch (agnostic to underlying items type).
protocol PreviewSearchTypeAgnostic : PreviewSearchTypeAgnosticDataSource, PreviewSearchCellSource {}

/// Protocol for preview data manipulations (agnostic to underlying items type).
protocol PreviewSearchTypeAgnosticDataSource {
    var isPreviewEmpty: Bool { get }
    func previewCellsCount() -> Int
    func clearPreview()
}

/// Protocol for acquiring table cells for search preview (when multiple categories are rendered in a same table).
protocol PreviewSearchCellSource {
    /// Return value 'true' means a cell to render is found.
    /// Otherwise, index is decremented by amount of cells in the current group, so we could continue search for the cell.
    func tryAcquirePreviewCell(_: SearchViewControllerProtocol, _: UITableView, _: IndexPath, _: inout Int, _: inout UITableViewCell?) -> Bool
}

/// Protocol for retrieving items (note the known underlying type).
protocol PreviewSearchItemSource {
    associatedtype T : Decodable
    func tryGetPreviewItem(_ index: Int, _ item: inout T?) -> Bool
}

extension GlobalSearch : PreviewSearchTypeAgnosticDataSource {
    var isPreviewEmpty: Bool {
        return subcategories.allSatisfy { (category) -> Bool in category.isPreviewEmpty }
    }
    
    func previewCellsCount() -> Int {
        var result = 0
        for category in subcategories {
            result += category.previewCellsCount()
        }
        return result
    }
    
    func clearPreview() {
        for category in subcategories {
            category.clearPreview()
        }
    }
}

extension GlobalSearch {
    func tryAcquirePreviewCell(_ controller: SearchViewControllerProtocol, _ table: UITableView, _ tableIndex: IndexPath, _ cell: inout UITableViewCell?) -> Bool {
        var index = tableIndex.row
        for category in subcategories {
            if category.tryAcquirePreviewCell(controller, table, tableIndex, &index, &cell) {
                return true
            }
        }
        return false
    }
    
    // No getItem() function there,
    // because top-level Search object comprises
    // searches of different underlying types.
}

/// Protocol for acquiring cells for preview for entire search category.
/// Search categories could be nested in other categories.
protocol PreviewSearchCategory : PreviewSearch {
    associatedtype S : PreviewSearch where S.T == T
    var subcategories: [S] { get }
    var header: (SearchViewControllerProtocol, UITableView, IndexPath) -> UITableViewCell { get }
}

extension PreviewSearchCategory {
    var isPreviewEmpty: Bool {
        let result = subcategories.allSatisfy { (category) -> Bool in category.isPreviewEmpty }
        return result
    }
    
    func previewCellsCount() -> Int {
        var result = 0
        for category in subcategories {
            result += category.previewCellsCount()
        }
        if result > 0 {
            // There would be header, if data in the category is not empty.
            result += 1
        }
        return result
    }
    
    func clearPreview() {
        for category in subcategories {
            category.clearPreview()
        }
    }
    
    func tryGetPreviewItem(_ blockIndex: Int, _ item: inout T?) -> Bool {
        var index = blockIndex
        if index == 0 {
            // Header, no item attached to it.
            return true
        }
        index -= 1
        for category in subcategories {
            let itemsCount = category.previewCellsCount()
            if index < itemsCount {
                return category.tryGetPreviewItem(index, &item)
            }
            index -= itemsCount
        }
        return false
    }

    func tryAcquirePreviewCell(_ controller: SearchViewControllerProtocol, _ table: UITableView, _ tableIndex: IndexPath, _ index: inout Int, _ cell: inout UITableViewCell?) -> Bool {
        if previewCellsCount() == 0 {
            return false
        }
        if index == 0 {
            cell = header(controller, table, tableIndex)
            return true
        }
        index -= 1
        for category in subcategories {
            let itemsCount = category.previewCellsCount()
            if index < itemsCount {
                return category.tryAcquirePreviewCell(controller, table, tableIndex, &index, &cell)
            }
            index -= itemsCount
        }
        return false
    }
}
