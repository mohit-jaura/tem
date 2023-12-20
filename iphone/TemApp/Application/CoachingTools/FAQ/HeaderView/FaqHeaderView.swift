//
//  FaqHeaderView.swift
//  TemApp
//
//  Created by Shiwani Sharma on 06/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class FaqHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!

   

    func setData(data: FaqList){
        questionLabel.text = data.question
    }
}
