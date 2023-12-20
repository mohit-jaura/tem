//
//  ToDoActivitiesListViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 23/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit




class ToDoActivitiesListViewController: UIViewController, LoaderProtocol, NSAlertProtocol {
    
    // MARK: IBOutlets
    @IBOutlet weak var createTodoButton: UIButton!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var pendingTasksLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private let viewModal = ToDoListViewModal()
    // MARK: Properties

    var toDoViewModal: ToDoDetailViewModal!
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLbl.text = Date().UTCToLocalString(inFormat: .coachingTools).uppercased()
        registerTableVIew()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getToDoList()
    }
    // MARK: IBActions
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addToDoTapped(_ sender: UIButton) {
        let itemVC: CreateTodoController = UIStoryboard(storyboard: .todo).initVC()
        self.navigationController?.pushViewController(itemVC, animated: true)
    }

    
    // MARK: Methods
    private func registerTableVIew() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNibs(nibNames: [ToDoListTableViewCell.reuseIdentifier, ])
        tableView.registerHeaderFooter(nibNames: [TodoFooterView.reuseIdentifier])
    }

    private func getToDoList() {
        showHUDLoader()
        viewModal.callToDoListApi { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error {
                self?.showAlert(withMessage: error.message ?? "Can not get detail at the moment")
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
            if self?.viewModal.modal?.count ?? 0 == 0 {
                self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                self?.tableView.reloadData()
                return
            }
            self?.tableView.showEmptyScreen("", isWhiteBackground: false)
            self?.setPendingTasksCount(count: self?.viewModal.pendingToDo ?? 0)
            self?.tableView.reloadData()
        }
    }
    
    private func setPendingTasksCount(count: Int) {
        pendingTasksLbl.text = "(\(count) Pending Tasks)"
    }

    private func callMarkToDOComplete(at index: Int) {
        let params = ["todo_id": viewModal.modal?[index].id,
                      "affiliateId": viewModal.modal?[0].affiliateId
        ]
        DIWebLayerTODO().markToDoCompleted(params: params) {
            self.getToDoList()
        } failure: { error in
            print(error.message ?? "failed to mark todo completed")
        }
    }

    private func deleteTodoApi(at index: Int) {
        DIWebLayerTODO().todoDeleteAPI(id: viewModal.createdList?[index].id ?? "") {
            self.getToDoList()
            self.tableView.reloadData()
            self.hideHUDLoader()
        } failure: { error in
            self.hideHUDLoader()
            print(error.message ?? "failed ")
        }
    }
    private func callAcceptDenyAPI(status: Int,todoID: String){
        let params = ["isShared": status]
        DIWebLayerTODO().acceptDenyAPI(todoId: todoID, params: params,completion: {
            self.hideHUDLoader()
            self.getToDoList()
        }, failure: { error in
            self.hideHUDLoader()
            print(error.message ?? "error")
        })
    }
}

extension ToDoActivitiesListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return viewModal.createdList?.count ?? 0
        } else{
            return viewModal.sharedList?.count ?? 0
        }
    //    return viewModal.modal?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ToDoListTableViewCell = tableView.dequeueReusableCell(withIdentifier: ToDoListTableViewCell.reuseIdentifier, for: indexPath) as? ToDoListTableViewCell else {
            return UITableViewCell()
        }
        cell.showMediaDelegate = self
        cell.acceptDenyTodoDelegate = self
        cell.acceptButton.tag = indexPath.row
        cell.denyButton.tag = indexPath.row
        if indexPath.section == 0{ //will show the created and accepted todos
            if let data = viewModal.createdList?[indexPath.row] {
                cell.listOfFiles = data.media?.filter{$0.url != "" } ?? []
                cell.setCellData(data: data)
            }
        } else{
            if let data = viewModal.sharedList?[indexPath.row] {
                cell.listOfFiles = data.media?.filter{$0.url != "" } ?? []
                cell.setCellData(data: data)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let todoId = viewModal.modal?[indexPath.row].id else {
            return
        }
        if indexPath.section == 0{
            if viewModal.modal?[indexPath.row].totalTasks == 0 && viewModal.modal?[indexPath.row].isCompleted == 0{
                self.showAlert(withTitle: "", message: "Do you want to mark this TODO completed? You can't change it later!", okayTitle: "Yes", cancelTitle: "No", okStyle: .default, okCall: {
                    self.callMarkToDOComplete(at: indexPath.row)
                }, cancelCall: {})
            } else if viewModal.modal?[indexPath.row].totalTasks != 0{
                let activityDetailVC: ToDoActivityDetailViewController = UIStoryboard(storyboard: .todo).initVC()
                if viewModal.modal?[indexPath.row].affiliateId ==  viewModal.modal?[indexPath.row].userId{
                    activityDetailVC.isCreatedByCurrentUSer = true
                    activityDetailVC.islistCompleted = viewModal.modal?[indexPath.row].isCompleted ?? 0
                }
                let toDoDetailViewModal = ToDoDetailViewModal(id: todoId) { [weak self] in
                    self?.getToDoList()
                }
                activityDetailVC.viewModal = toDoDetailViewModal
                self.navigationController?.pushViewController(activityDetailVC, animated: true)
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let  footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TodoFooterView.reuseIdentifier) as? TodoFooterView else{
            return UITableViewHeaderFooterView()
        }
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 || viewModal.sharedList?.count ?? 0 == 0{
            return 0
        }
        return 50

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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.showHUDLoader()
            self.deleteTodoApi(at: indexPath.row)
        }
    }

}

extension ToDoActivitiesListViewController: ShowMedia{
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

extension ToDoActivitiesListViewController: AcceptDenyTodoDelegate{
//    self.showHUDLoader()
    func acceptDenyCalled(tag: Int,isAccepted:Bool) {
        if isAccepted{//accepted todo
            callAcceptDenyAPI(status: 2,todoID: self.viewModal.sharedList?[tag].id ?? "") //need to pass the param/status 2 if accepted else pass 3
        } else{ // shared todos
            callAcceptDenyAPI(status: 3,todoID: self.viewModal.sharedList?[tag].id ?? "")
        }
    }
}
