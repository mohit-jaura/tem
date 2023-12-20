//
//  SeeAllCell.swift
//  TemApp
//
//  Created by Developer on 20/09/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.


import UIKit

class SeeAllCell: UITableViewCell {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataForMyContent(data:SeeAllModel){
        imageView1.image = UIImage(named: data.image ?? "")
        titleLabel.text = data.title ?? ""
        descLabel.text = data.description ?? ""
    }
    
    func setData(data:SeeAllModel){
        if let image = data.image, let url = URL(string: image){
            imageView1.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "ImagePlaceHolder"))
        }
        titleLabel.text = data.title ?? ""
        descLabel.text = data.description ?? ""
        descLabel.numberOfLines = 4
    }
}
