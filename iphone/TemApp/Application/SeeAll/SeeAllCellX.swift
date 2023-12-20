//
//  SeeAllCellX.swift
//  TemApp
//
//  Created by PrabSharan on 25/11/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class SeeAllCellX: UITableViewCell {
    @IBOutlet weak var backImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setData(_ data:SeeAllModel?){
        guard let data = data else {return}
        backImageView.setImg(data.image,#imageLiteral(resourceName: "ImagePlaceHolder"))
    }
}
