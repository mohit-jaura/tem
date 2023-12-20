//
//  ChallengeDashboardTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 24/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class ChallengeDashboardTableCell: UITableViewCell {

    // MARK: IBOutlets.
    @IBOutlet weak var headingLabel: UILabel!
    
    
    // MARK: UITableviewCell Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func initializeWith(viewModel: ChallengeDashboardTableCellViewModel) {
        self.headingLabel.text = viewModel.headingText
    }
}

struct ChallengeDashboardTableCellViewModel {
    var headingText: String?
}
