//
//  ActivityFilterViewPresenter.swift
//  TemApp
//
//  Created by shilpa on 25/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

enum ActivityFilterSection: Int, CaseIterable {
    case filterByDate
    case filterByActivity
    
    var title: String {
        switch self {
        case .filterByActivity:
            return "FILTER BY ACTIVITY".localized
        case .filterByDate:
            return "FILTER BY DATE".localized
        }
    }
}

enum ActivityFilterByDate: Int, CaseIterable {
    case ascending, descending
    
    var title: String {
        switch self {
        case .ascending:
            return "Ascending".localized
        default:
            return "Descending".localized
        }
    }
    
    var key: String {
        switch self {
        case .ascending:
            return "asc"
        case .descending:
            return "desc"
        }
    }
}

protocol ActivityFilterViewPresenterDelegate: AnyObject {
    func showErrorAlertOnView(errorMessage: String)
    func reloadParentView()
    func showHideLoader(show: Bool)
    func reloadTableAt(indexPath: IndexPath)
    func reloadTableSectionAt(indexPath: IndexPath)
    func selectedActivities(array: [Int]?)
    func selectedFilter(filter: ActivityFilterByDate?)
}

class ActivityFilterViewPresenter {
    
    // MARK: Properties
    weak var delegate: ActivityFilterViewPresenterDelegate?
    var dataSourceArray: [ActivityData]?
    var selectedActivitiesIds: [Int] = []
    var dateFilter: ActivityFilterByDate?
    
    // MARK: Initializer
    init(view: ActivityFilterViewPresenterDelegate) {
        self.delegate = view
        self.dateFilter = .descending
        self.getActivityTypesFromServer()
    }
    
    // MARK: Api call
    func getActivityTypesFromServer() {
        guard Reachability.isConnectedToNetwork() else {
            self.delegate?.showErrorAlertOnView(errorMessage: AppMessages.AlertTitles.noInternet)
            return
        }
        self.delegate?.showHideLoader(show: true)
        DIWebLayerActivityAPI().getUserActivity(success: { (activities) in
            self.delegate?.showHideLoader(show: false)
            self.dataSourceArray = []
            self.dataSourceArray?.append(contentsOf: activities[0].type)//...
            self.delegate?.reloadParentView()
        }) { (error) in
            self.delegate?.showHideLoader(show: false)
            if let error = error.message {
                self.delegate?.showErrorAlertOnView(errorMessage: error)
            }
        }
    }
    
    // MARK: Table view data source helpers
    func numberOfSectionsForActivityFilterScreen() -> Int {
        return ActivityFilterSection.allCases.count
    }
    
    func numberOfRowsForActivityFilterIn(section: Int) -> Int {
        if let currentSection = ActivityFilterSection(rawValue: section) {
            switch currentSection {
            case .filterByDate:
                return ActivityFilterByDate.allCases.count
            case .filterByActivity:
                return self.dataSourceArray?.count ?? 0
            }
        }
        return 0
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        guard let activities = self.dataSourceArray else {
            return
        }
        if let currentSection = ActivityFilterSection(rawValue: indexPath.section) {
            switch currentSection {
            case .filterByDate:
                if let filterValue = ActivityFilterByDate(rawValue: indexPath.row) {
                    if let dateFilterValue = self.dateFilter {
                        if filterValue == dateFilterValue { //selecting already selected row
                            //deselect the row
                            self.dateFilter = nil
                            self.delegate?.reloadTableSectionAt(indexPath: indexPath)
                            self.delegate?.selectedFilter(filter: dateFilter)
                            return
                        }
                    }
                    self.dateFilter = filterValue
                    self.delegate?.reloadTableSectionAt(indexPath: indexPath)
                    self.delegate?.selectedFilter(filter: dateFilter)
                }
            case .filterByActivity:
                if let id = activities[indexPath.row].id {
                    if selectedActivitiesIds.contains(id),
                        let index = selectedActivitiesIds.firstIndex(of: id) {
                        selectedActivitiesIds.remove(at: index)
                        self.dataSourceArray?[indexPath.row].filterSelected = false
                    } else {
                        selectedActivitiesIds.append(id)
                        self.dataSourceArray?[indexPath.row].filterSelected = true
                    }
                    self.delegate?.reloadTableAt(indexPath: indexPath)
                    self.delegate?.selectedActivities(array: self.selectedActivitiesIds)
                }
            }
        }
    }
    
    /// view model for header in section
    func viewModelForActivityFilterHeaderAt(section: Int) -> ActivityFilterSideMenuHeaderViewModel? {
        if let currentSection = ActivityFilterSection(rawValue: section) {
            return ActivityFilterSideMenuHeaderViewModel(title: currentSection.title)
        }
        return nil
    }
    
    /// returns the view model to display data at each index path
    ///
    /// - Parameter indexPath: index path of the current tablecell
    /// - Returns: view model
    func viewModelForFilterScreenAt(indexPath: IndexPath) -> FilterSideMenuTableCellViewModel? {
        if let currentSection = ActivityFilterSection(rawValue: indexPath.section) {
            switch currentSection {
            case .filterByDate:
                if let currentRow = ActivityFilterByDate(rawValue: indexPath.row) {
                    if let dateFilter = self.dateFilter {
                        return FilterSideMenuTableCellViewModel(icon: nil, title: currentRow.title, isSelected: currentRow == dateFilter)
                    }
                    return FilterSideMenuTableCellViewModel(icon: nil, title: currentRow.title, isSelected: false)
                }
            case .filterByActivity:
                guard let activities = self.dataSourceArray else {
                    return nil
                }
                return FilterSideMenuTableCellViewModel(icon: activities[indexPath.row].image, title: activities[indexPath.row].name, isSelected: activities[indexPath.row].filterSelected)
            }
        }
        return nil
    }
}
