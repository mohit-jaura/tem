//
//  MyCoachTableViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 20/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class MyCoachTableViewCell: UITableViewCell {

    // MARK: IBoutlet
    @IBOutlet weak var coachImgView: UIImageView!
    @IBOutlet weak var coachNameLabel: UILabel!
    @IBOutlet var shadowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(list: CoachList){
        coachNameLabel.text = list.fullName
        coachImgView.cornerRadius = coachImgView.frame.height / 2
        if let url = URL(string: list.profilePic ?? ""){
            coachImgView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user-dummy"))
        }
    }

}
