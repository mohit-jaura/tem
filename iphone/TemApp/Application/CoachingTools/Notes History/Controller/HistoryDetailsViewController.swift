//
//  HistoryDetailsViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 03/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class HistoryDetailsViewController: UIViewController,LoaderProtocol {


    // MARK: IBOutlet
    @IBOutlet weak var historyDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var bgShadowView: SSNeumorphicView!{
        didSet {
            bgShadowView.setNeumorphicView(shadowType: .innerShadow)
        }
    }

    // MARK: Variables
    var date: String = ""
    var notes: [JourneyNote]?

    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView.addShadowToView()
        tableView.registerNibs(nibNames: [SenderTextMessageTableViewCell.reuseIdentifier])
        historyDateLabel.text = date
    }
    
    private func initUI() {
        if self.notes?.count ?? 0 == 0 {
            self.tableView.showEmptyScreen("No History available!", isWhiteBackground: false)
            return
        } else {
            self.tableView.showEmptyScreen("", isWhiteBackground: false)
        }
        self.tableView.reloadData()
        self.scrollToBottom()
    }

    private func scrollToBottom() {
        if notes?.count ?? 0 > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(
                    row: self.tableView.numberOfRows(inSection:  self.tableView.numberOfSections - 1) - 1,
                    section: self.tableView.numberOfSections - 1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension HistoryDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SenderTextMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: SenderTextMessageTableViewCell.reuseIdentifier, for: indexPath) as? SenderTextMessageTableViewCell else {
            return UITableViewCell()
        }
        if let data = notes?[indexPath.row] {
            cell.setJourneyNotesData(data: data)
        }
        return cell
    }
}


