//
//  CoachingFAQTableCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 06/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class CoachingFAQTableCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(data: FaqList){
        answerLabel.text = data.answer
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
