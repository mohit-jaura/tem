//
//  ToDoActivitiesListViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 23/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class ToDoActivitiesListViewController: UIViewController, LoaderProtocol {
    
    // MARK: IBOutlets
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var pendingTasksLbl: UILabel!
    @IBOutlet weak var lineSepratorView: SSNeumorphicView! {
        didSet {
            lineSepratorView.viewDepthType = .innerShadow
            lineSepratorView.viewNeumorphicMainColor = UIColor.black.cgColor
            lineSepratorView.viewNeumorphicLightShadowColor = UIColor.black.cgColor
            lineSepratorView.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            lineSepratorView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var tableView: UITableView!
    private let viewModal = ToDoListViewModal()
    // MARK: Properties
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLbl.text = Date().UTCToLocalString(inFormat: .coachingTools).uppercased()
        registerTableVIew()
        getToDoList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    // MARK: IBActions
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Methods
    private func registerTableVIew() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNibs(nibNames: [ToDoListTableViewCell.reuseIdentifier])
    }
    
    private func getToDoList() {
        showHUDLoader()
        viewModal.callToDoListApi { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error {
                print(error)
                return
            }
            if self?.viewModal.modal?.count ?? 0 == 0 {
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
            self?.setPendingTasksCount(count: self?.viewModal.pendingToDo ?? 0)
            self?.tableView.reloadData()
        }
    }
    
    private func setPendingTasksCount(count: Int) {
        pendingTasksLbl.text = "(\(count) Pending Tasks)"
    }
}

extension ToDoActivitiesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModal.modal?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ToDoListTableViewCell = tableView.dequeueReusableCell(withIdentifier: ToDoListTableViewCell.reuseIdentifier, for: indexPath) as? ToDoListTableViewCell else {
            return UITableViewCell()
        }
        if let data = viewModal.modal?[indexPath.row] {
            cell.setCellData(data: data)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let todoId = viewModal.modal?[indexPath.row].id else {
            return
        }
        let activityDetailVC: ToDoActivityDetailViewController = UIStoryboard(storyboard: .todo).initVC()
        let toDoDetailViewModal = ToDoDetailViewModal(id: todoId) { [weak self] in
            self?.getToDoList()
        }
        activityDetailVC.viewModal = toDoDetailViewModal
        self.navigationController?.pushViewController(activityDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let modal = viewModal.modal else {
            return
        }
        if !modal.isEmpty {
            if modal.count < viewModal.totalCount && indexPath.row == (modal.count - 1) {
                viewModal.currentPage += 1
                getToDoList()
            }
        }
    }
}
