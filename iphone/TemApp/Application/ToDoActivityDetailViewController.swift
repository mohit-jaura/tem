//
//  ToDoActivitiesListViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 23/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class ToDoActivityDetailViewController: DIBaseController, LoaderProtocol {
    // MARK: IBOutlets
    @IBOutlet weak var activityNameLbl: UILabel!
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
    
    // MARK: Properties
    var viewModal: ToDoDetailViewModal!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableVIew()
        getToDoDetail()
    }
    
    // MARK: IBActions
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Methods
    private func getToDoDetail() {
        showHUDLoader()
        viewModal?.callToDoDetailApi { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error {
                print(error)
                return
            }
            self?.setActivityDetails()
            if self?.viewModal.modal?.tasks?.count ?? 0 == 0 {
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
            self?.tableView.reloadData()
        }
    }
    
    private func markTaskCompleted(index: Int) {
        showHUDLoader()
        let params = [
            "todo_id": viewModal.modal?.toDoId ?? "",
            "task_id": viewModal.modal?.tasks?[index].taskId ?? "",
            "affiliateId": viewModal.modal?.affiliateId ?? ""
        ]
        viewModal.callMarkTaskComplete(params: params) { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error {
                print(error)
                return
            }
            self?.setActivityDetails()
            if self?.viewModal.modal?.tasks?.count ?? 0 == 0 {
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
            self?.tableView.reloadData()
        }
    }
    
    private func registerTableVIew() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNibs(nibNames: [ToDoActivityDetailTableViewCell.reuseIdentifier])
    }
    
    private func setActivityDetails() {
        activityNameLbl.text = viewModal.modal?.title ?? ""
        let pendingTasks = viewModal.modal?.tasks?.filter({$0.isCompleted == 0})
        pendingTasksLbl.text = "(\(pendingTasks?.count ?? 0) Pending Tasks)"
    }
}

extension ToDoActivityDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModal.modal?.tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ToDoActivityDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: ToDoActivityDetailTableViewCell.reuseIdentifier, for: indexPath) as? ToDoActivityDetailTableViewCell else {
            return UITableViewCell()
        }
        
        if let data = viewModal.modal?.tasks?[indexPath.row] {
            cell.setCellData(data: data, tag: indexPath.row)
            cell.taskSelected = { [weak self] selectedTask in
                self?.showAlert(message: "Do you want to mark this task completed? You can't change it later!", okayTitle: "Yes", cancelTitle: "No", okCall: {
                    self?.markTaskCompleted(index: selectedTask)
                }, cancelCall: {
                    // cancel call
                })
            }
        }
        return cell
    }
}
