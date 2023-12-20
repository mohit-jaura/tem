//
//  CreateRoundViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 18/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol CreateRoundViewControllerDelegate: AnyObject {
    func passRoundModal(newRound: Rounds)
}

class CreateRoundViewController: DIBaseController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTitleView: SSNeumorphicView! {
        didSet {
            setShadow(view: addTitleView, shadowType: .innerShadow)
        }
    }
    @IBOutlet weak var titleField: UITextField!
    var tasks = [Tasks]()
    var fetchedRound: Rounds?
    weak var delegate: CreateRoundViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(CreateRoundChecklistTableCell.self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeRound()
    }
    func initializeRound() {
        if let fetchedTasks = fetchedRound?.tasks, fetchedTasks.count > 0 {
            tasks.append(contentsOf: fetchedTasks)
            titleField.text = fetchedRound?.round_name ?? ""
        }
    }
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, isType: Bool = false) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
    }
    @IBAction func saveRoundTapped(_ sender: UIButton) {
        if tasks.count == 0 {
            self.showAlert(withTitle: "", message: "Please create atleast one task ", okayTitle: AppMessages.AlertTitles.Ok)
        } else {
            self.delegate?.passRoundModal(newRound: Rounds(tasks: self.tasks, round_name: titleField.text ?? "", roundId: fetchedRound?.roundId ?? nil))
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func createTaskTapped(_ sender: UIButton) {
        let popverVC: TaskPopoverViewController = UIStoryboard(storyboard: .calendarActivity).initVC()
        popverVC.delegate = self
        self.present(popverVC, animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension CreateRoundViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CreateRoundChecklistTableCell  = tableView.dequeueReusableCell(withIdentifier: CreateRoundChecklistTableCell.reuseIdentifier, for: indexPath) as? CreateRoundChecklistTableCell else {
            return UITableViewCell()
        }
        cell.setData(task: tasks[indexPath.row], index: indexPath.row)
        return cell
    }
}

extension CreateRoundViewController: TaskPopoverViewControllerDelegate {
    func passTaskModal(newtask: Tasks) {
        for task in (0..<tasks.count) where tasks[task].taskId != nil && tasks[task].taskId == newtask.taskId ?? nil {
            tasks[task].task_name = newtask.task_name
            tasks[task].file = newtask.file
            tasks[task].fileType = newtask.fileType
            self.tableView.reloadData()
            return
        }
        tasks.append(newtask)
        self.tableView.reloadData()
    }
}
