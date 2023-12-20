//
//  WeightGoalLogTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 25/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class WeightGoalLogTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for   selected state
    }

    func setData(data: WeightDetail, isHealthGoal: Bool) {
        let rawDate = data.date?.timestampInMillisecondsToDate ?? Date()
        let dateString = rawDate.toString(inFormat: .displayDate) ?? ""
        dateLbl.text = dateString
        if isHealthGoal{
            weightLbl.text = "\(data.healthLoggedUnits ?? 0)"
        }else{
            weightLbl.text = "\(data.weight?.rounded(toPlaces: 1) ?? 0.0)"
        }

    }
}
