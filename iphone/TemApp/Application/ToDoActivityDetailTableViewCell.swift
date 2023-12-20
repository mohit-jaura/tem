//
//  ToDoListTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 17/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class ToDoActivityDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var backShadowView: SSNeumorphicView!{
        didSet {
            backShadowView.viewDepthType = .outerShadow
            backShadowView.viewNeumorphicMainColor = UIColor.black.cgColor
            backShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            backShadowView.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            backShadowView.viewNeumorphicCornerRadius = 4
        }
    }
    
    @IBOutlet weak var taskNameLbl: UILabel!
    @IBOutlet weak var taskStatusBtn: UIButton!
    
    var taskSelected: OnlyIntCompletion?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func taskStatusTapped(_ sender: UIButton) {
        if sender.isUserInteractionEnabled {
            if let taskSelected = taskSelected {
                taskSelected(sender.tag)
            }
        }
    }
    
    func setCellData(data: ToDoTasks, tag: Int) {
        taskNameLbl.text = data.taskName ?? ""
        taskStatusBtn.tag = tag
        if let isCompleted = CustomBool(rawValue: data.isCompleted ?? 0) {
            if isCompleted == .yes {
                taskStatusBtn.setTitle("Completed", for: .normal)
                taskStatusBtn.setTitleColor(.systemGreen, for: .normal)
                taskStatusBtn.isUserInteractionEnabled = false
            } else {
                taskStatusBtn.setTitle("Incomplete", for: .normal)
                taskStatusBtn.setTitleColor(.systemRed, for: .normal)
                taskStatusBtn.isUserInteractionEnabled = true
            }
        }
    }
}
