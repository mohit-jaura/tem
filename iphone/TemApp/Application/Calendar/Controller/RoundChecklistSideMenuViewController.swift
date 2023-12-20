//
//  RoundChecklistSideMenuViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 02/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//
import SSNeumorphicView
import UIKit

class RoundChecklistSideMenuViewController: DIBaseController {
    // MARK: IBOutlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var roundNameLbl: UILabel!
    @IBOutlet weak var roundProgressBar: UIProgressView!
    @IBOutlet weak var roundProgressBarShadow: SSNeumorphicView! {
        didSet {
            setShadow(view: roundProgressBarShadow, shadowType: .innerShadow)
            roundProgressBarShadow.viewNeumorphicCornerRadius = roundProgressBarShadow.frame.height / 2
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextRoundBtn: UIButton!
    @IBOutlet weak var previousRoundBtn: UIButton!
    @IBOutlet weak var completeChecklistButton: UIButton!
    // MARK:Properties
    var selectedTasks: Float = Float(0)
    var rounds: [Checklist]?
    var currentRound = 0
    var eventId: String = "62e79662b773c95386d60e68"
    enum RoundType {
        case next, previous
    }
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.registerNibs(nibNames: [RoundChecklistSideMenuTableViewCell.reuseIdentifier])
        roundProgressBar.setProgress(0.0, animated: false)
        addGestures()
        getChecklist(eventId: eventId)
    }
    // MARK: IBActions
    @IBAction func nextRoundTapped(_ sender: UIButton) {
        changeRound(roundType: .next)
    }
    @IBAction func previousRoundTapped(_ sender: UIButton) {
        changeRound(roundType: .previous)
    }

    @IBAction func completeChecklistTapped(_ sender: UIButton) {
        let completeChecklistVC: CompleteChecklistViewController = UIStoryboard(storyboard: .createevent).initVC()
        self.present(completeChecklistVC, animated: true)
    }
    @IBAction func backTapped( _ sender: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: Methods
    private func changeRound(roundType:RoundType) {
        switch roundType {
        case .next:
            if currentRound < rounds?.count ?? 1 - 1 {
                currentRound += 1
            }
        case .previous:
            if currentRound > 0 {
                currentRound -= 1
            }
        }
        roundNameLbl.text = "Round \(currentRound + 1)"
        if currentRound == 0 {
            previousRoundBtn.isHidden = true
            nextRoundBtn.isHidden = false
            
            completeChecklistButton.isHidden = true
        }
        else if currentRound == (rounds?.count ?? 1) - 1 {
            nextRoundBtn.isHidden = true
            previousRoundBtn.isHidden = false
            completeChecklistButton.isHidden = false
        } else {
            nextRoundBtn.isHidden = false
            previousRoundBtn.isHidden = false
            completeChecklistButton.isHidden = true
        }
        changeSelectedTasks(checkList: rounds ?? [])
        self.tableView.reloadData()
    }
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1)
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
    }
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSideMenu))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideSideMenu))
        swipeGesture.direction = .right
        backView.addGestureRecognizer(tapGesture)
        backView.addGestureRecognizer(swipeGesture)
    }
    @objc func hideSideMenu() {
        self.dismiss(animated: true)
    }
    func changeSelectedTasks(checkList: [Checklist]) {
        selectedTasks = 0
        if let tasks = checkList[currentRound].tasks {
            for task in tasks where task.isDone == 1 {
                    selectedTasks += 1
            }
        }
        initializeRoundProgress(selectedTasks: selectedTasks)
    }
    func initializeRoundProgress(selectedTasks: Float) {
        let totalTasks: Float = Float(self.rounds?[currentRound].tasks?.count ?? 0)
        let newProgress: Float = selectedTasks / totalTasks
        roundProgressBar.setProgress(newProgress, animated: true)
    }
    func getChecklist(eventId: String) {
        DIWebLayerEvent().getEventChecklist(eventId: eventId) { checklist in
            self.rounds = checklist
            self.initUI()
            if checklist.count > 0 {
                self.changeSelectedTasks(checkList: checklist)
            }
        } failure: { _ in
        }
    }
    func initUI() {
        if rounds?.count == 0 {
            completeChecklistButton.isHidden = true
            roundNameLbl.text = "No checklist added"
            nextRoundBtn.isHidden = true
            previousRoundBtn.isHidden = true
        }else if rounds?.count ?? 1 == 1 {
            roundNameLbl.text = "Round \(currentRound + 1)"
            completeChecklistButton.isHidden = false
            nextRoundBtn.isHidden = true
            previousRoundBtn.isHidden = true
        } else if currentRound == 0 && rounds?.count ?? 0 - 1 > currentRound {
            completeChecklistButton.isHidden = true
            nextRoundBtn.isHidden = false
            previousRoundBtn.isHidden = true
        }else if currentRound != 0 && (rounds?.count ?? 0) - 1 > currentRound {
            completeChecklistButton.isHidden = true
            nextRoundBtn.isHidden = false
            previousRoundBtn.isHidden = false
        }else if  rounds?.count ?? 0 - 1 > currentRound {
            completeChecklistButton.isHidden = false
            nextRoundBtn.isHidden = true
            previousRoundBtn.isHidden = false
        }
        tableView.reloadData()
    }
    func updateTaskCheck(parameters: Parameters) {
        self.showLoader()
        DIWebLayerEvent().updateTaskCheck(parameters: parameters) { error in
            self.hideLoader()
            if error == nil {
                self.getChecklist(eventId: self.eventId)
            }
        }
    }
    func getDictForTaskCheckUpdation(taskIndex: Int, isChecked: Bool) -> Parameters {
        let roundId = rounds?[currentRound].roundId ?? ""
        let taskId = rounds?[currentRound].tasks?[taskIndex].task?.id ?? ""
        let isCompleted = isChecked ? 1 : 0
        let params: Parameters = [
            "eventId": eventId,
            "roundId": roundId,
            "taskId": taskId,
            "isCompleted": isCompleted
        ]
        return params
    }
}
// MARK: Extensions
extension RoundChecklistSideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rounds = rounds else { return 0 }
        if rounds.count > 0 {
            return rounds[currentRound].tasks?.count ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: RoundChecklistSideMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: RoundChecklistSideMenuTableViewCell.reuseIdentifier, for: indexPath) as? RoundChecklistSideMenuTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        guard let tasks = rounds?[currentRound].tasks else { return UITableViewCell() }
        cell.setData(tasks: tasks, index: indexPath.row)
        return cell
    }
}

extension RoundChecklistSideMenuViewController: RoundChecklistSideMenuTableViewCellDelegate {
    func openVideoPdf(sender: UIButton) {
        if let fileType = EventMediaType(rawValue: rounds?[currentRound].tasks?[sender.tag].task?.fileType ?? 0) {
            switch fileType {
            case .video:
                let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
                episodeVideoVC.url = rounds?[currentRound].tasks?[sender.tag].task?.file ?? ""
                episodeVideoVC.screenFrom = .event
                self.present(episodeVideoVC, animated: true)
            case .pdf:
                let selectedVC: AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
                selectedVC.urlString = rounds?[currentRound].tasks?[sender.tag].task?.file ?? ""
                selectedVC.screenFrom = .event
                self.present(selectedVC, animated: true)
            }
        }
    }
    func tasksSelection(sender: UIButton) {
        let parameters = getDictForTaskCheckUpdation(taskIndex: sender.tag, isChecked: sender.isSelected)
        self.updateTaskCheck(parameters: parameters)
    }
}
