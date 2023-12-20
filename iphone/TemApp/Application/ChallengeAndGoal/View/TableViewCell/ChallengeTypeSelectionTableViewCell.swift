//
//  ChallengeTypeSelectionTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 27/07/20.
//  Copyright © 2020 Capovela LLC. All rights reserved.
//

import UIKit

protocol ChallengeTypeSelectionTableCellDelegate: AnyObject {
    func didSelectChallengeTypeButton(sender: UIButton, type: ActivityMembersType)
}


class ChallengeTypeSelectionTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: ChallengeTypeSelectionTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var indVsIndButton: UIButton!
    @IBOutlet weak var indVsTemTypeButton: UIButton!
    @IBOutlet weak var temVsTemTypeButton: UIButton!
    
    // MARK: IBActions
    @IBAction func indVsIndTypeTapped(_ sender: UIButton) {
        sender.isSelected = true
        indVsTemTypeButton.isSelected = false
        temVsTemTypeButton.isSelected = false
        self.delegate?.didSelectChallengeTypeButton(sender: sender, type: .individual)
    }
    
    @IBAction func indVsTemTypeTapped(_ sender: UIButton) {
        sender.isSelected = true
        temVsTemTypeButton.isSelected = false
        indVsIndButton.isSelected = false
        self.delegate?.didSelectChallengeTypeButton(sender: sender, type: .individualVsTem)
    }
    
    @IBAction func temVsTemTypeTapped(_ sender: UIButton) {
        sender.isSelected = true
        indVsTemTypeButton.isSelected = false
        indVsIndButton.isSelected = false
        self.delegate?.didSelectChallengeTypeButton(sender: sender, type: .temVsTem)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initializeWith(groupActivity: GroupActivity?, screenType: Constant.ScreenFrom? = .createChallenge) {
        if let type = groupActivity?.activityMembersType {
            switch type {
            case .individual:
                self.indVsIndButton.isSelected = true
            case .individualVsTem:
                self.indVsTemTypeButton.isSelected = true
            case .temVsTem:
                self.temVsTemTypeButton.isSelected = true
            }
        }
        if screenType! == .createGroupChallenge {
            //disable tem vs tem and individual vs tem buttons
            self.indVsTemTypeButton.isEnabled = false
            self.temVsTemTypeButton.isEnabled = false
        }
    }
}


class ActivityTypeCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: ChallengeTypeSelectionTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
