//
//  WeeklyCell.swift
//  TemApp
//
//  Created by dhiraj on 23/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class WeeklyCell: UITableViewCell {
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var weekSlotLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(slot:WeekSlot, section: Int) {
        seperatorView.isHidden = section == 0 || slot.eventList.count == 0
        let startDate = Utility.dateFormatter(format: .weekSlot).string(from: slot.startDate)
        let endDate = Utility.dateFormatter(format: .weekSlot).string(from: slot.endDate)
        weekSlotLbl.text = startDate + " - " + endDate
    }

}
