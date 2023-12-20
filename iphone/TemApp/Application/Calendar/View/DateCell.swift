//
//  DateCell.swift
//  TemApp
//
//  Created by dhiraj on 09/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class DateCell: JTAppleCell {
    @IBOutlet weak var goalImgVw: UIImageView!
    @IBOutlet weak var challengeImgVw: UIImageView!
    @IBOutlet weak var activityImgVw: UIImageView!
    @IBOutlet weak var showMoreLbl: UILabel!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityImgVw.image = #imageLiteral(resourceName: "green")
    }
}
