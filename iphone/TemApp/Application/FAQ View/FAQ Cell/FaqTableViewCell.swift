//
//  FaqTableViewCell.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class FaqTableViewCell: UITableViewCell {

    
    // MARK: IBOutlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dropDounButton: UIImageView!
    @IBOutlet weak var footerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
