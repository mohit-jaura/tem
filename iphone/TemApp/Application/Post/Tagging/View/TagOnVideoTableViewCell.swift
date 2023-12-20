//
//  TagOnVideoTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 04/01/20.
//

import UIKit

class TagOnVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var roundAddButton: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        roundAddButton.setImageColor(color: UIColor.appThemeColor)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
