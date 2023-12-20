//
//  RoundChecklistViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 18/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

protocol RoundChecklistViewControllerDelegate: AnyObject {
    func passChecklistsModal(newCheckList: [Rounds])
}

class RoundChecklistViewController: DIBaseController {
    // MARK: IBOutlet
    @IBOutlet weak var emptyMessageStackVIew: UIStackView!
    @IBOutlet weak var addChecklistBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addRoundBtn: UIButton!
    @IBOutlet weak var copyRoundBtn: UIButton!
    // MARK: Variables?
    var createdRounds = [Rounds]()
    var fetchedRounds: [EventRounds]?
    var createdRoundsWithBool = [CreatedRounds]()
    weak var delegate: RoundChecklistViewControllerDelegate?
    var screenFrom: Constant.ScreenFrom = .event
    var eventId = ""
    var fetchedRoundsAlreadyAdded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNibs(nibNames: [RoundChecklistTableCell.reuseIdentifier])
        tableView.registerHeaderFooter(nibNames: [RoundChecklistSectionHeader.reuseIdentifier, RoundChecklistSectionFooter.reuseIdentifier])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeRounds()
    }
    // MARK: IBActions
    @IBAction func addChecklistTapped(_ sender: UIButton) {
        saveRoundsAndPopController()
    }
    @IBAction func addRoundTapped(_ sender: UIButton) {
        let createRoundVC: CreateRoundViewController = UIStoryboard(storyboard: .calendarActivity).initVC()
        createRoundVC.delegate = self
        self.navigationController?.pushViewController(createRoundVC, animated: true)
    }
    @IBAction func backTapped(_ sender: UIButton) {
        saveRoundsAndPopController()
    }
    @IBAction func copyRoundTapped(_ sender: UIButton) {
        if let copiedRound = createdRounds.last {
            createdRounds.append(copiedRound)
            initializeRounds()
        }
    }
    private func saveRoundsAndPopController() {
        self.delegate?.passChecklistsModal(newCheckList: self.createdRounds)
        self.navigationController?.popViewController(animated: true)
    }
    private func initUI() {
        if screenFrom == .eventInfo {
            addRoundBtn.isHidden = true
            addChecklistBtn.isHidden = true
            copyRoundBtn.isHidden = true
            if createdRoundsWithBool.count == 0 {
                tableView.showEmptyScreen("No rounds added yet !")
            } else {
                tableView.showEmptyScreen("")
            }
        } else {
            if createdRoundsWithBool.count == 0 {
                emptyMessageStackVIew.isHidden = false
                tableView.isHidden = true
                addRoundBtn.isHidden = true
            } else {
                emptyMessageStackVIew.isHidden = true
                tableView.isHidden = false
                addRoundBtn.isHidden = false
            }
        }
    }
    private func initializeRounds() {
        if createdRounds.count > 0 || fetchedRounds?.count ?? 0 > 0 {
            if let fetchedRounds = fetchedRounds, fetchedRounds.count > 0, fetchedRoundsAlreadyAdded == false {
                for fetchedRound in fetchedRounds {
                    var round = Rounds()
                    round.roundId = fetchedRound.id ?? nil
                    round.round_name = fetchedRound.roundName ?? ""
                    round.tasks = []
                    if let fetchedTasks = fetchedRound.tasks, fetchedTasks.count > 0 {
                        for fetchedTask in fetchedTasks {
                            var task = Tasks()
                            task.task_name = fetchedTask.taskName ?? ""
                            task.taskId = fetchedTask.id ?? nil
                            task.file = fetchedTask.file ?? ""
                            task.fileType = fetchedTask.fileType ?? 0
                            round.tasks?.append(task)
                        }
                    }
                    createdRounds.append(round)
                }
                fetchedRoundsAlreadyAdded = true
            }
            createdRoundsWithBool = []
            for createdRound in createdRounds {
                createdRoundsWithBool.append(CreatedRounds(round: createdRound, isOpened: false))
            }
        }
        initUI()
        tableView.reloadData()
    }
    private func deleteRoundAPI(index: Int, completion: @escaping (_ message: String?) -> Void ) {
        if isConnectedToNetwork() {
            self.showLoader()
            guard let roundID = createdRoundsWithBool[index].round?.roundId else {
                createdRoundsWithBool.remove(at: index)
                createdRounds.remove(at: index)
                self.hideLoader()
                if createdRoundsWithBool.count == 0 {
                    copyRoundBtn.isHidden = true
                } else {
                    copyRoundBtn.isHidden = false
                }
                self.tableView.reloadData()
                return
            }
            DIWebLayerEvent().deleteRound(roundId: roundID, eventId: eventId, completion: {[weak self] (success) in
                DispatchQueue.main.async {
                    // refresh tableView
                    self?.hideLoader()
                    NotificationCenter.default.post(name: NSNotification.Name(Constant.NotiName.refreshEvent), object: nil)
                    self?.createdRoundsWithBool.remove(at: index)
                    self?.createdRounds.remove(at: index)
                    completion(success)
                    self?.tableView.reloadData()
                }
            }, failure: { (error) in
                self.hideLoader()
                if let message = error.message {
                    self.showAlert(message: message)
                }
            })
        }
    }
    private func deleteTaskAPI( section: Int, row: Int, completion: @escaping(_ msg: String) -> Void) {
        if isConnectedToNetwork() {
            self.showLoader()
            guard let roundId = createdRoundsWithBool[section].round?.roundId, let taskId = createdRoundsWithBool[section].round?.tasks?[row].taskId else {
                createdRoundsWithBool[section].round?.tasks?.remove(at: row)
                self.tableView.restore()
                self.tableView.reloadData()
                return
            }
            DIWebLayerEvent().deleteTask(roundId: roundId, eventId: eventId, taskID: taskId, completion: {[weak self] (success) in
                // refresh tableView
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(Constant.NotiName.refreshEvent), object: nil)
                    
                    self?.hideLoader()
                    self?.createdRoundsWithBool[section].round?.tasks?.remove(at: row)
                    self?.tableView.restore()
                    self?.tableView.reloadData()
                    completion(success ?? "")
                }
                
            }, failure: { (error) in
                self.hideLoader()
                if let message = error.message {
                    self.showAlert(message: message)
                }
            })
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension RoundChecklistViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        createdRoundsWithBool.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if createdRoundsWithBool[section].isOpened ?? false {
            return createdRoundsWithBool[section].round?.tasks?.count ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: RoundChecklistTableCell = tableView.dequeueReusableCell(withIdentifier: RoundChecklistTableCell.reuseIdentifier, for: indexPath) as? RoundChecklistTableCell else {
            return UITableViewCell()
        }
        guard let round = createdRoundsWithBool[indexPath.section].round else { return UITableViewCell()}
        cell.mediaDelegate = self
        cell.setData(round: round, index: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RoundChecklistSectionHeader.reuseIdentifier) as! RoundChecklistSectionHeader
        headerView.delegate = self
        headerView.backgroundColor = .clear
        headerView.setData(rounds: createdRoundsWithBool, section: section, screenFrom: screenFrom)
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RoundChecklistSectionFooter.reuseIdentifier) as! RoundChecklistSectionFooter
        if createdRoundsWithBool[section].isOpened ?? false {
            return footerView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if createdRoundsWithBool[section].isOpened ?? false {
            return 75
        }
        return 78
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if createdRoundsWithBool[section].isOpened ?? false {
            return 12
        }
        return 0
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if screenFrom != .eventInfo {
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteTask = UITableViewRowAction(style: .normal, title: "Delete Task") { _, _ in
            self.showAlert(withTitle: "", message: "Do you want to delete?", okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No) {
                self.deleteTaskAPI(section: indexPath.section, row: indexPath.row, completion: { msg in
                    self.showAlert(withTitle: "", message: msg, okayTitle: AppMessages.AlertTitles.Ok)
                })
            }cancelCall: {
                self.tableView.restore()
                self.tableView.reloadData()
            }
        }
        deleteTask.backgroundColor = UIColor.appRed
        return [deleteTask]
    }
}

extension RoundChecklistViewController: RoundChecklistSectionHeaderDelegte {
    func didTappedDelete(at section: Int) {
        self.showAlert(withTitle: "", message: "Do you want to delete?", okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No) {
            self.deleteRoundAPI(index: section, completion: { msg in
                self.showAlert(withTitle: "", message: msg, okayTitle: AppMessages.AlertTitles.Ok)
            })
        } cancelCall: {
            self.tableView.reloadData()
        }
    }
    func didTappedArrow(at section: Int) {
        // perform expand/collapse action
        let isOpened = createdRoundsWithBool[section].isOpened ?? false
        createdRoundsWithBool[section].isOpened = !isOpened
        tableView.reloadSections([section], with: .none)
    }
    func didTappedDetails(at section: Int) {
        // perform details action
        let createRoundVC: CreateRoundViewController = UIStoryboard(storyboard: .calendarActivity).initVC()
        createRoundVC.delegate = self
        createRoundVC.fetchedRound = createdRoundsWithBool[section].round ?? Rounds()
        self.navigationController?.pushViewController(createRoundVC, animated: true)
    }
}

extension RoundChecklistViewController: CreateRoundViewControllerDelegate {
    func passRoundModal(newRound: Rounds) {
        for round in (0..<createdRounds.count) where newRound.roundId != nil{
            if createdRounds[round].roundId == newRound.roundId ?? nil {
                createdRounds[round].round_name = newRound.round_name
                createdRounds[round].tasks = newRound.tasks
                self.tableView.reloadData()
                return
            }
        }
        createdRounds.append(newRound)
        NotificationCenter.default.post(name: NSNotification.Name(Constant.NotiName.refreshEvent), object: nil)
        self.tableView.reloadData()
    }
}

extension RoundChecklistViewController: OpenMediaDelagate {
    func openMediaView(fileType: EventMediaType, url: String) {
        switch fileType {
        case .video:
            let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
            episodeVideoVC.url = url
            self.navigationController?.pushViewController(episodeVideoVC, animated: false)
        case .pdf:
            let selectedVC: AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
            selectedVC.urlString = url
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
}
