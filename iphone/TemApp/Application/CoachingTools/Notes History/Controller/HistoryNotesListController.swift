//
//  HistoryNotesListController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 03/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class HistoryNotesListController: UIViewController, LoaderProtocol,NSAlertProtocol {

    // MARK: - Variables
    let viewModal = MyJourneyViewModal()

    // MARK: IBOutlet
    @IBOutlet weak var tableView:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }

    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Methods
    private func initUI(){
        self.tableView.isSkeletonable = true
        self.getHistoryData()
        self.navigationController?.navigationBar.isHidden = true
    }

    private func getHistoryData(){
        self.showHUDLoader()
        viewModal.callNotesHistoryApi {
            self.handleApiResponse()
        }
    }

    private func handleApiResponse() {
        self.hideHUDLoader()
        if let error = self.viewModal.error {
            showAlert(withMessage: error.message ?? "Can't ")
            return
        }
        if self.viewModal.dateOfNotes.count == 0 {
            self.tableView.showEmptyScreen("No History available yet!", isWhiteBackground: false)
            return
        }else{
            self.tableView.showEmptyScreen("", isWhiteBackground: false)
        }
        self.tableView.reloadData()
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HistoryNotesListController:UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModal.dateOfNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: JournalListingTableViewCell.reuseIdentifier, for: indexPath) as! JournalListingTableViewCell
        if viewModal.dateOfNotes.count > 0 {
            cell.configureCellforHistoryNotes(date: viewModal.dateOfNotes[indexPath.row])
            cell.isUserInteractionEnabled = true
        } else {
            cell.journalDateLabel.text = "No History available yet!"
            cell.journalDateLabel.textAlignment = .center
            cell.isUserInteractionEnabled = false
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyVc: HistoryDetailsViewController = UIStoryboard(storyboard: .coachingTools).initVC()
        let date = viewModal.dateOfNotes[indexPath.row]
        historyVc.date = Utility.timeZoneDateFormatter(format: .ratingDate, timeZone: utcTimezone).string(from: date)
        historyVc.notes = viewModal.getNotesForSelectedDate(selectedDate: date)
        self.navigationController?.pushViewController(historyVc, animated: true)
    }
}

extension HistoryNotesListController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == tableView, (scrollView.contentOffset.y + scrollView.frame.size.height ) >= scrollView.contentSize.height + 100, !viewModal.isLoading else {
            return
        }
        viewModal.startDate = viewModal.startDate.addMonth(n: -1)
        viewModal.endDate = viewModal.endDate.addMonth(n: -1)
        getHistoryData()
    }
}
