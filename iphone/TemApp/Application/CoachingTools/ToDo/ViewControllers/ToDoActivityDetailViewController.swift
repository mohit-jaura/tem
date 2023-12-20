//
//  ToDoActivitiesListViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 23/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class ToDoActivityDetailViewController: UIViewController, LoaderProtocol, NSAlertProtocol {
    // MARK: IBOutlets
    @IBOutlet weak var activityNameLbl: UILabel!
    @IBOutlet weak var pendingTasksLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    // MARK: Properties
    var viewModal: ToDoDetailViewModal!
    var screenFrom: Constant.ScreenFrom = .todo
    var isCreatedByCurrentUSer = false
    var islistCompleted = 0
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableVIew()
        addItemButton.isHidden = true
        if isCreatedByCurrentUSer && islistCompleted == 0{
            editButton.isHidden = false
        } else {
            editButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        getToDoDetail()
    }

    // MARK: IBActions
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addTomyTodoTapped(_ sender: UIButton) {
        callAddtoMyTodoAPI()
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        let createTodoVC: CreateTodoController = UIStoryboard(storyboard: .todo).initVC()
        createTodoVC.isListEditing = true
        createTodoVC.itemTitle = viewModal.modal?.title ?? ""
        if let tasks = viewModal.modal?.tasks {
            createTodoVC.tasks = tasks
        }
        createTodoVC.todoId = viewModal.modal?.toDoId ?? ""
        self.navigationController?.pushViewController(createTodoVC, animated: true)
    }

    // MARK: Methods
    private func initUI(){
        if screenFrom == .notification{
            addItemButton.isHidden = false
            if self.viewModal.modal?.status == 1{
                addItemButton.isUserInteractionEnabled = false
                addItemButton.setTitle("ADDED", for: .normal)
            }
        } else{
        addItemButton.isHidden = true
        }
    }
    private func getToDoDetail() {
        showHUDLoader()
        viewModal?.callToDoDetailApi { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error {
                self?.showAlert(withMessage: error.message ?? "Can not get detail at the moment")
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
            self?.setActivityDetails()

            if self?.viewModal.modal?.tasks?.count ?? 0 == 0 {
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                self?.tableView.reloadData() // in case when user delete all the tasks
                return
            } else{
                self?.initUI()
            }
            self?.tableView.showEmptyScreen("", isWhiteBackground: false)
            self?.tableView.reloadData()
        }
    }
    private func callAddtoMyTodoAPI(){
        self.showHUDLoader()
        let params = ["status": 1,
                      "_id": viewModal.modal?.toDoId ?? ""] as [String : Any]
        viewModal.addTomyTodo(params: params , completion: { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error{
                self?.showAlert(withMessage: "\(error.message ?? "")")
            }
        }, sucessMsg: { msg in
            self.showAlert(withMessage: msg)
            self.addItemButton.setTitle("ADDED", for: .normal)
        })
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
                self?.showAlert(withMessage: error.message ?? "Can not mark todo as completed at the moment")
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
        cell.showMediaDelegate = self
        if let data = viewModal.modal?.tasks?[indexPath.row] {
            cell.taskFiles = data.media?.filter{$0.url != ""} ?? []
            cell.setCellData(data: data, tag: indexPath.row)
            cell.taskSelected = { [weak self] selectedTask in
                if self?.viewModal.modal?.tasks?[indexPath.row].subTasks?.count == 0 && self?.viewModal.modal?.tasks?[indexPath.row].isCompleted == 0 {
                    self?.showAlert(withTitle: "", message: "Do you want to mark this task completed? You can't change it later!", okayTitle: "Yes", cancelTitle: "No", okStyle: .default, okCall: {
                        self?.markTaskCompleted(index: selectedTask)
                    }, cancelCall: {
                        // cancel call
                    })
                }else if self?.viewModal.modal?.tasks?[indexPath.row].subTasks?.count != 0{
                    let subTasksVC: TodoDetailsSubTasksVC = UIStoryboard(storyboard: .todo).initVC()
                    subTasksVC.currentSubTask = indexPath.row
                    subTasksVC.screenFrom = self?.screenFrom ?? .todo
                    subTasksVC.viewModal = self?.viewModal
                    subTasksVC.todoId = self?.viewModal.modal?.toDoId ?? ""
                    subTasksVC.subTasks = self?.viewModal.modal?.tasks?[indexPath.row].subTasks
                    self?.navigationController?.pushViewController(subTasksVC, animated: true)
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if viewModal.modal?.tasks?[indexPath.row].subTasks?.count != 0{
            let subTasksVC: TodoDetailsSubTasksVC = UIStoryboard(storyboard: .todo).initVC()
            subTasksVC.currentSubTask = indexPath.row
            subTasksVC.screenFrom = screenFrom
            subTasksVC.viewModal = viewModal
            subTasksVC.todoId = viewModal.modal?.toDoId ?? ""
            subTasksVC.subTasks = viewModal.modal?.tasks?[indexPath.row].subTasks
            self.navigationController?.pushViewController(subTasksVC, animated: true)
        }
    }
}

extension ToDoActivityDetailViewController: ShowMedia{
    func showMediaSheet(media: ToDoMediaType, taskIndex: Int, subTaskIndex: Int) {}

    func redirectToMediaScreens(url: String, mediaType: EventMediaType) {
        switch EventMediaType(rawValue: mediaType.rawValue){
        case .video:
            let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
            episodeVideoVC.url = url
            self.navigationController?.pushViewController(episodeVideoVC, animated: false)
        case .pdf:
            let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
            selectedVC.urlString = url

            self.navigationController?.pushViewController(selectedVC, animated: true)
        default:
            break
        }
    }
}
