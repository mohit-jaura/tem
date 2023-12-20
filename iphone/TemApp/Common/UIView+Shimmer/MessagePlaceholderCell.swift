//
//  MessagePlaceholderCell.swift
//  TemApp
//
//  Created by shilpa on 27/05/20.
//

import UIKit

class MessagePlaceholderCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
