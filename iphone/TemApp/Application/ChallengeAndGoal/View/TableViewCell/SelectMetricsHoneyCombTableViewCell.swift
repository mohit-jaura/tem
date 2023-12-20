//
//  SelectMetricsHoneyCombTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

struct SelectMetricCellViewModel {
    var type: Constant.ScreenFrom
}

class SelectMetricsHoneyCombTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var metricsHoneyCombView: SelectMetricsHoneyCombView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: IBActions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        metricsHoneyCombView.delegate?.tappedOnStartButton()
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //initialize cell with the view model
    func initializeWith(viewModel: SelectMetricCellViewModel, isEditing: Bool, selectedMetrics: [Int]?, goalTarget: [GoalTarget]?) {
        if isEditing {
            self.startButton.setTitle("EDIT", for: .normal)
        } else {
            self.startButton.setTitle("START", for: .normal)
        }
        switch viewModel.type {
        case .createChallenge:
            self.metricsHoneyCombView.isEditingChallenge = isEditing
            self.metricsHoneyCombView.selectedMetrics = selectedMetrics
            self.headerLabel.text = "Challenge Metric: Used to determine winner"
        case .createGoal:
            self.metricsHoneyCombView.isEditingGoal = isEditing
            self.metricsHoneyCombView.value = goalTarget
            self.headerLabel.text = "Goal Metric: Used to determine winner"
        default:
            break
        }
    }
}

