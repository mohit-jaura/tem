//
//  ToDoListTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 17/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class ToDoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backShadowView: SSNeumorphicView!{
        didSet {
            backShadowView.viewDepthType = .outerShadow
            backShadowView.viewNeumorphicMainColor = UIColor.black.cgColor
            backShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            backShadowView.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            backShadowView.viewNeumorphicCornerRadius = 4
        }
    }
    
    @IBOutlet weak var coachImageView: UIImageView!
    @IBOutlet weak var activityLbl: UILabel!
    @IBOutlet weak var coachNameLbl: UILabel!
    @IBOutlet weak var todoStatusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellData(data: ToDoList) {
        activityLbl.text = data.title ?? ""
        coachNameLbl.text = "\(data.affiliateFirstName ?? "") \(data.affiliateLastName ?? "")"
        if let isCompleted = CustomBool(rawValue: data.isCompleted ?? 0) {
            if isCompleted == .yes {
                todoStatusLbl.text = "Completed"
                todoStatusLbl.textColor = .systemGreen
            } else {
                let pendingTasks = (data.totalTasks ?? 0) - (data.completedTasks ?? 0)
                if pendingTasks == data.totalTasks {
                    todoStatusLbl.text = "All Incomplete"
                } else {
                    todoStatusLbl.text = "Incomplete \n (\(pendingTasks)/\(data.totalTasks ?? 0))"
                }
                todoStatusLbl.textColor = .systemRed
            }
        }
        if let imageLink = data.affiliateProfilePic, let url = URL(string: imageLink) {
            coachImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user-dummy"))
        }
    }
}
