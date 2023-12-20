//
//  DashboardErrorMessageTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 22/04/20.
//

import UIKit

class DashboardErrorMessageTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var errorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Helper
    func showErrorWith(message: String) {
        self.errorLabel.text = message
    }
}
