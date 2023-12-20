//
//  TodoLibraryController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 29/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class TodoLibraryController: UIViewController, LoaderProtocol,NSAlertProtocol {

    //MARK: Variable
    private let viewModal = ToDoListViewModal()
    private var toDoIndex: Int?
    private var selectedIndexForBookmark : Int?

    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerViews()
        getToDoList()
    }

    //MARK: Helper functions
    private func registerViews(){
        self.tableView.registerNibs(nibNames: [TematesTableCell.reuseIdentifier])
    }

    private func getToDoList() {
        showHUDLoader()
        viewModal.getBookmarkedTodo {
            self.hideHUDLoader()
            if let error = self.viewModal.error{
                self.showAlert(withMessage: error.message ?? "Can not get detail at the moment")
                self.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
            }
            if self.viewModal.modal?.count ?? 0 == 0 {
                self.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
            self.tableView.reloadData()
        }
    }
    //MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addToDoTapped(_ sender: Any) {
        if selectedIndexForBookmark != nil{
            self.showHUDLoader()
            viewModal.addItemToBookmark(TodoItemID: viewModal.modal?[selectedIndexForBookmark ?? 0].id ?? "", completion: {
                self.hideHUDLoader()
                if let error = self.viewModal.error{
                    self.showAlert(withMessage: error.message ?? "Not bookmarked")
                }
                self.selectedIndexForBookmark = nil
                self.getToDoList()
                self.tableView.reloadData()
            })
        } else{
            self.showAlert(withMessage: "Please select an item")
        }
    }
}

extension TodoLibraryController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModal.modal?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell: TematesTableCell = tableView.dequeueReusableCell(withIdentifier: TematesTableCell.reuseIdentifier) as? TematesTableCell else {return UITableViewCell()}
        cell.addButton.isUserInteractionEnabled = false
        cell.contentView.backgroundColor = .black
        if let list = viewModal.modal {

            if selectedIndexForBookmark != nil && selectedIndexForBookmark == indexPath.row {
                cell.configureViewforBookmarkedTodo(isButtonSelected: true, data: list[indexPath.row])
            } else{
                cell.configureViewforBookmarkedTodo(isButtonSelected: false, data: list[indexPath.row])
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexForBookmark = indexPath.row
        tableView.reloadData()
    }
}
