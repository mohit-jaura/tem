//
//  TodoDetailsSubTaksVC.swift
//  TemApp
//
//  Created by Shiwani Sharma on 25/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class TodoDetailsSubTasksVC: UIViewController, LoaderProtocol,NSAlertProtocol {

    // MARK: IBOutlet
    @IBOutlet weak var activityNameLbl: UILabel!
    @IBOutlet weak var pendingTasksLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Properties
    var subTasks: [SubTasks]!
    var currentSubTask = 0
    var viewModal: ToDoDetailViewModal!
    var todoId = ""
    var completedSubtasks = 0
    var sub_subTask: Int?
    var screenFrom: Constant.ScreenFrom = .todo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableVIew()
        if subTasks.count > 0{
            if subTasks.filter({$0.isCompleted == 1}).count > 0{
                completedSubtasks = subTasks.filter({$0.isCompleted == 1}).count
            } else{
                completedSubtasks = 0//subTasks.count
            }
        }
        if let tasks = Defaults.shared.get(forKey: .completedTasks) as? [Int], tasks.count != 0{
            Defaults.shared.remove(.completedTasks)
        }
        setActivityDetails()
    }

    // MARK: IBActions
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    private func markTaskCompleted(index: Int) {
        showHUDLoader()
        let subtaskParams = [
            "todo_id": self.todoId,
            "subtask_id": subTasks[index].id ?? ""
        ]
        let taskParams = [
            "todo_id": viewModal.modal?.toDoId ?? "",
            "task_id": viewModal.modal?.tasks?[currentSubTask].taskId ?? "",
            "affiliateId": viewModal.modal?.affiliateId ?? ""
        ]
        viewModal.callSubtaskComplete(totalSubtasks: subTasks.count, completedSubtasks: completedSubtasks,params: subtaskParams, taskParams: taskParams) { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error {
                self?.showAlert(withMessage: error.message ?? "Can not mark this sub-task as completed at the moment")
                return
            }
            if self?.viewModal.modal?.tasks?.count ?? 0 == 0 {
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
            if self?.completedSubtasks != self?.subTasks.count{
                self?.completedSubtasks += 1
            }

            self?.setActivityDetails()
            self?.tableView.reloadData()
        }
    }

    private func registerTableVIew() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNibs(nibNames: [ToDoActivityDetailTableViewCell.reuseIdentifier])
    }

    private func setActivityDetails() {
        subTasks = viewModal.modal?.tasks?[currentSubTask].subTasks
        activityNameLbl.text = viewModal.modal?.tasks?[currentSubTask].taskName
        if subTasks.count >= completedSubtasks{
            let pendingTasks =  subTasks.count - completedSubtasks
            pendingTasksLbl.text = "(\(pendingTasks) Pending Tasks)"
        }

    }
}

extension TodoDetailsSubTasksVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ToDoActivityDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: ToDoActivityDetailTableViewCell.reuseIdentifier, for: indexPath) as? ToDoActivityDetailTableViewCell else {
            return UITableViewCell()
        }
         let data = subTasks[indexPath.row]
        if let completedTask = sub_subTask{
            cell.currentCompletedTask = completedTask
        }
        cell.showMediaDelegate = self
        cell.isScreenForSubtask = true
        if let media = data.media {
            cell.subtaskFiles = media.filter {$0.url != ""}
        }
        cell.configureCellForSubTasks(data: data, tag: indexPath.row)
        cell.taskSelected = { [weak self] selectedTask in
            self?.sub_subTask = selectedTask
            self?.showAlert(withTitle: "", message: "Do you want to mark this task completed? You can't change it later!", okayTitle: "Yes", cancelTitle: "No", okStyle: .default, okCall: {
                self?.markTaskCompleted(index: selectedTask)
            }, cancelCall: {})}
        return cell
    }
}


extension TodoDetailsSubTasksVC: ShowMedia{
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
