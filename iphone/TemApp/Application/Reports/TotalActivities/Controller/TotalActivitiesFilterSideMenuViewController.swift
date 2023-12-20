//
//  TotalActivitiesFilterSideMenuViewController.swift
//  TemApp
//
//  Created by shilpa on 25/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class TotalActivitiesFilterSideMenuViewController: DIBaseController {

    // MARK: Properties
    var presenter: ActivityFilterViewPresenter!
    var selectedActivitiesIds: [Int]?
    var selectedDateFilter: ActivityFilterByDate?
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedDateFilter = .descending
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.registerHeaderFooter(nibNames: [ActivityFilterSideMenuHeaderView.reuseIdentifier])
        self.showLoader()
        self.presenter = ActivityFilterViewPresenter(view: self)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: UITableViewDataSource
extension TotalActivitiesFilterSideMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.numberOfSectionsForActivityFilterScreen()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRowsForActivityFilterIn(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FilterSideMenuTableViewCell.reuseIdentifier, for: indexPath) as? FilterSideMenuTableViewCell {
            if let viewModel = self.presenter.viewModelForFilterScreenAt(indexPath: indexPath) {
                cell.initializeWith(viewModel: viewModel)
            }
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension TotalActivitiesFilterSideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ActivityFilterSideMenuHeaderView.reuseIdentifier) as? ActivityFilterSideMenuHeaderView
        if let viewModel = self.presenter.viewModelForActivityFilterHeaderAt(section: section) {
            headerView?.initializeWith(viewModel: viewModel)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.didSelectRowAt(indexPath: indexPath)
    }
}

// MARK: ActivityFilterViewPresenterDelegate
extension TotalActivitiesFilterSideMenuViewController: ActivityFilterViewPresenterDelegate {
    func selectedActivities(array: [Int]?) {
        self.selectedActivitiesIds = []
        if let arrayItems = array {
            self.selectedActivitiesIds?.append(contentsOf: arrayItems)
        }
    }
    
    func selectedFilter(filter: ActivityFilterByDate?) {
        self.selectedDateFilter = filter
    }
    
    func reloadTableSectionAt(indexPath: IndexPath) {
        let section = IndexSet(integer: indexPath.section)
        self.tableView.reloadSections(section, with: .automatic)
    }
    
    func reloadTableAt(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FilterSideMenuTableViewCell,
            let viewModel = self.presenter.viewModelForFilterScreenAt(indexPath: indexPath) {
            cell.initializeWith(viewModel: viewModel)
        }
    }
    
    func showErrorAlertOnView(errorMessage: String) {
        self.showAlert(message: errorMessage)
    }
    
    func reloadParentView() {
        self.tableView.reloadData()
    }
    
    func showHideLoader(show: Bool) {
        if show {
            self.showLoader()
        } else {
            self.hideLoader()
        }
    }
}
