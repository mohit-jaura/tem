//
//  ActiveTemsAndGoalsViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 04/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

final class ActiveTemsAndGoalsViewController: UIViewController, LoaderProtocol, NSAlertProtocol {

    enum ScreenSelectionType: Int {
        case tems = 0, goals, challengs
    }
    // MARK: IBOutlets
    @IBOutlet var buttonsBackViews: [SSNeumorphicView]!
    @IBOutlet var buttonsContainerViews: [UIView]!
    @IBOutlet weak var temsBtn: UIButton!
    @IBOutlet weak var challengsBtn: UIButton!
    @IBOutlet weak var goalsBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    // MARK: Properties
    var screenSelection: ScreenSelectionType = .tems
    var dataArray: [GroupActivity]?
    var userId = ""
    var viewModal: ActiveTemsGoalsViewModal?
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModal = ActiveTemsGoalsViewModal(userId: userId)
        setViewState(selectedType: .tems)
        registerTableView()
    }
    
    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func temsTapped(_ sender: UIButton) {
        setViewState(selectedType: .tems)
    }
    @IBAction func goalsTapped(_ sender: UIButton) {
        setViewState(selectedType: .goals)
    }
    @IBAction func challengesTapped(_ sender: UIButton) {
        setViewState(selectedType: .challengs)
    }
    // MARK: Methods
    private func registerTableView() {
        tableView.registerNibs(nibNames: [ChatListTableViewCell.reuseIdentifier, OpenGoalDashboardCell.reuseIdentifier, OpenChallengeDashboardCell.reuseIdentifier])
    }
    private func setViewState(selectedType: ScreenSelectionType) {
        screenSelection = selectedType
        setContainerViews()
        setShadowView()
        viewModal?.resetCurrentPage()
        getDataFromAPI()
    }
    private func setContainerViews() {
        for view in buttonsContainerViews {
            view.cornerRadius = view.frame.height / 2
            if view.tag == screenSelection.rawValue {
                view.backgroundColor = UIColor.appCyanColor
            } else {
                view.backgroundColor = UIColor.newAppThemeColor
            }
        }
    }
    private func setShadowView() {
        for view in buttonsBackViews {
            view.setOuterDarkShadow()
            view.viewDepthType = .innerShadow
            view.viewNeumorphicCornerRadius = view.frame.height / 2
            if view.tag == screenSelection.rawValue {
                view.viewNeumorphicMainColor = UIColor.appCyanColor.cgColor
            } else {
                view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
            }
        }
    }
}
