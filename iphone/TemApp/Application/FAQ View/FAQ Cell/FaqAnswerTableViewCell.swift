//
//  FaqAnswerTableViewCell.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class FaqAnswerTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet  var imagView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
