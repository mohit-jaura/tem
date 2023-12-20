//
//  SearchViewControllerProtocol.swift
//  TemApp
//
//  Created by Egor Shulga on 15.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

protocol SearchViewControllerProtocol : PostTableVideoMediaDelegate, PresentActionSheetDelegate, PostTableCellDelegate, ViewPostDetailDelegate, SearchViewControllerOffsetsProtocol, SelectSearchModeProtocol, EventSearchDelegate {
}

protocol SearchViewControllerOffsetsProtocol {
    var collectionOffsets: [Int: CGPoint] { get }
}

protocol SelectSearchModeProtocol {
    func switchToPreviewSearch()
    func switchToCategorySearch(search: CategorySearch)
}

protocol EventSearchDelegate {
    func updateEvent(_ item: EventDetail)
    func deleteEvent(id: String)
    func eventListUpdated()
}
