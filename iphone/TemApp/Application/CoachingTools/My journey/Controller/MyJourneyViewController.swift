//
//  MyJourneyViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 11/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class MyJourneyViewController: UIViewController, LoaderProtocol, NSAlertProtocol {

    // MARK: IBOutlets
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet var shadowViews: [UIView]!{
        didSet{
            for view in shadowViews{
                view.cornerRadius = view.frame.height / 2
                view.borderWidth = 2
                view.borderColor = UIColor.appCyanColor
            }
        }
    }
    @IBOutlet weak var todoButton: UIButton!
    @IBOutlet weak var chaterrBgView: UIView!
    @IBOutlet weak var chatterShadowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: IQTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    let viewModal = MyJourneyViewModal()
    private let listViewModal = ToDoListViewModal()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        initializer()
    }
    private func initializer(){
        currentDateLabel.text = Date().UTCToLocalString(inFormat: .coachingTools).uppercased()
        textView.delegate = self
        registerTableVIew()
        self.setSendButtonState(enableStatus: false)
        textView.placeholder = "ADD DAILY RECORD"
        getNotes()
        getToDoList()
    }

    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func statsTapped(_ sender: UIButton) {
        let statsVC: StatsViewController = UIStoryboard(storyboard: .coachingTools).initVC()
        self.navigationController?.pushViewController(statsVC, animated: true)
    }
    @IBAction func todoListTapped(_ sender: UIButton) {
        let todoVC:ToDoActivitiesListViewController = UIStoryboard(storyboard: .todo).initVC()
        self.navigationController?.pushViewController(todoVC, animated: true)
    }
    @IBAction func scheduleTapped(_ sender: UIButton) {
        let scheduleVC: ScheduleViewController = UIStoryboard(storyboard: .coachingTools).initVC()
        self.navigationController?.pushViewController(scheduleVC, animated: true)
    }
    @IBAction func coachingBtnTapped(_ sender: Any) {
        let coachingVC: CoachingViewController = UIStoryboard(storyboard: .coachingTools).initVC()
        self.navigationController?.pushViewController(coachingVC, animated: true)
    }
    @IBAction func trendsTapped(_ sender: UIButton) {
        let trendsVC: ReportViewController = UIStoryboard(storyboard: .reports).initVC()
        self.navigationController?.pushViewController(trendsVC, animated: true)
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        let message = textView.text ?? ""
        addNote(message: message)
    }

    private func registerTableVIew() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNibs(nibNames: [DailyRecordNoteTableViewCell.reuseIdentifier])
    }

    private func getToDoList() {
        showHUDLoader()
        listViewModal.callToDoListApi { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.listViewModal.error {
                print(error)
                return
            }
            if self?.listViewModal.modal?.count ?? 0 != 0 {
                self?.todoButton.setTitle("TO DO (\(self?.listViewModal.pendingToDo ?? 0)/\(self?.listViewModal.modal?.count ?? 0))", for: .normal)
            }
        }
    }
    private func getNotes() {
        self.showHUDLoader()
        viewModal.callJourneyNotesApi { [weak self] in
            if let error = self?.viewModal.error {
                self?.hideHUDLoader()
                self?.showAlert(withMessage: error.message ?? "Can not get notes at the moment")
                return
            }
            self?.handleApiResponse()
        }
    }
    
    private func addNote(message: String) {
        self.showHUDLoader()
        viewModal.callAddNoteApi(message: message) { [weak self] in
            if let error = self?.viewModal.error {
                self?.hideHUDLoader()
                self?.showAlert(withMessage: error.message ?? "Can not add note at the moment")
                return
            }
            self?.handleApiResponse()
            self?.setSendButtonState(enableStatus: false)
            self?.textView.text = ""
            self?.messageTextViewHeightConstraint.constant = 40
        }
    }
    
    private func handleApiResponse() {
        self.hideHUDLoader()
        if let error = self.viewModal.error {
            print(error)
            return
        }
        if self.viewModal.modal?.count ?? 0 == 0 {
            self.tableView.showEmptyScreen("No Daily Journey notes added for today", isWhiteBackground: false)
            return
        } else{
            self.tableView.showEmptyScreen("", isWhiteBackground: false)
        }
        self.tableView.reloadData()
        self.scrollToBottom()
    }
    
    private func scrollToBottom() {
        if viewModal.modal?.count ?? 0 > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(
                    row: self.tableView.numberOfRows(inSection:  self.tableView.numberOfSections - 1) - 1,
                    section: self.tableView.numberOfSections - 1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    private func setSendButtonState(enableStatus status: Bool) {
        sendButton.isEnabled = status
        let image = status ? "addNoteEnabled" :"addNoteDisabled"
        sendButton.setBackgroundImage(UIImage(named: image), for: .normal)
    }
}
// MARK:  UITableViewDelegate, UITableViewDataSource
extension MyJourneyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModal.modal?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: DailyRecordNoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: DailyRecordNoteTableViewCell.reuseIdentifier, for: indexPath) as? DailyRecordNoteTableViewCell else {
            return UITableViewCell()
        }
        if let data = viewModal.modal?[indexPath.row] {
            cell.setJourneyNotesData(data: data)
        }
        return cell
    }
}

// MARK: UITextViewDelegate
extension MyJourneyViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.scrollToBottom()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.messageTextViewHeightConstraint.constant = textView.contentSize.height
        if self.messageTextViewHeightConstraint.constant > 70 {
            self.messageTextViewHeightConstraint.constant = 70
        } else {
            self.messageTextViewHeightConstraint.constant = 40
        }
        var hidebutton = false
        if (textView.text.count == 1 && text.count == 0) {
            hidebutton = true
        }
        if (textView.text.count + text.count) >= 1 && (hidebutton == false){
            //enable send button
            self.setSendButtonState(enableStatus: true)
        }else{
            //disable send button
            self.setSendButtonState(enableStatus: false)
        }
        return true
    }
}
